Set-Location -LiteralPath $PSScriptRoot

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. CurrentVersion 存在性检查
while (-not (Test-Path -LiteralPath "CurrentVersion")) {
    Set-Content -LiteralPath "CurrentVersion" -Value 0 -NoNewline
}

New-Item -ItemType Directory -Path "Temp" -Force | Out-Null

# 2. version 下载及比较
$downloaded = $false
for ($i = 0; $i -lt 3 -and -not $downloaded; $i++) {
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rdudyfrjctst/classisland-mgmt-cfg/data/version" -OutFile "Temp\version" -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop
        $downloaded = $true
    } catch {}
}

if (-not $downloaded) {
    Start-Process -FilePath "ClassIsland.exe"
    exit
}

$a = [int]((Get-Content -LiteralPath "Temp\version" -Raw).Trim())
$b = [int]((Get-Content -LiteralPath "CurrentVersion" -Raw).Trim())

if ($a -le $b) {
    Remove-Item -LiteralPath "Temp\version" -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath "ClassIsland.exe"
    exit
}

# 3. 档案文件下载及替换（统一从 zipball 获取）
New-Item -ItemType Directory -Path "data" -Force | Out-Null

# 下载并解压仓库 zipball
Invoke-WebRequest -Uri "https://api.github.com/repos/rdudyfrjctst/classisland-mgmt-cfg/zipball" -OutFile "Temp\repo.zip" -UseBasicParsing
Remove-Item -LiteralPath "Temp\repo" -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive -LiteralPath "Temp\repo.zip" -DestinationPath "Temp\repo" -Force

# 获取解压后的顶层目录
$repoRoot = (Get-ChildItem -LiteralPath "Temp\repo" -Directory | Select-Object -First 1).FullName

# 替换 Settings.json
Remove-Item -LiteralPath "data\Settings.json" -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $repoRoot "Settings.json") -Destination "data\Settings.json" -Force

# 替换 Config 文件夹
Remove-Item -LiteralPath "data\Config" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $repoRoot "Config") -Destination "data\Config" -Recurse -Force

# 替换 Profiles 文件夹
Remove-Item -LiteralPath "data\Profiles" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $repoRoot "Profiles") -Destination "data\Profiles" -Recurse -Force

# 更新 CurrentVersion 并清理
Set-Content -LiteralPath "CurrentVersion" -Value $a -NoNewline
Remove-Item -LiteralPath "Temp\version" -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "Temp\repo.zip" -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "Temp\repo" -Recurse -Force -ErrorAction SilentlyContinue

# 4. 主程序启动
Start-Process -FilePath "ClassIsland.exe"