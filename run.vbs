CreateObject("Shell.Application").ShellExecute _
  "powershell.exe", _
  "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & _
  CreateObject("Scripting.FileSystemObject").BuildPath( _
    CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName), _
    "run.ps1") & """", _
  CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName), _
  "runas", 0