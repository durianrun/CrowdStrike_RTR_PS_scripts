# Prints target of a shortcut file (.lnk).
# Author: Nathan Hoffman

Param(
  [string]$File
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-ShortcutTarget.ps1', $Cmd='c:\users\jsmith\Desktop\suspicious.lnk') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-File <file path>"')) |Out-Null
  $help.Add('  Example: list target of a shortcut file') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('File')
$e = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
foreach ($req_arg in $required_args) {
  try {
    # check if the argument was passed via -CommandLine
    $res = Get-Variable -Name $req_arg -ErrorAction 'Stop'
    
    # argument exists, make sure it has a value
    if (-not ($res.Value)) {
      Print-Help
    }
  }
  catch {
    Print-Help
  }
}
$ErrorActionPreference = $e
########################################

if (Test-Path $File) {
  $full_name = (Get-ChildItem $File).FullName
  $sh = New-Object -ComObject WScript.Shell
  $target = $sh.CreateShortcut($full_name).TargetPath
  echo "Target of $File`:"
  echo "   $target"
}
else {
  echo "File not found: $File"
}
