# Prints last N lines of a file.
# Author: Nathan Hoffman

Param(
  [string]$File,
  [int]$Lines=10
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-FileTail.ps1', $Cmd='c:\users\jsmith\config.txt 25') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-File <file path> -Lines <number of lines>"')) |Out-Null
  $help.Add('  Example: list last 25 lines of a config file') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('File', 'Lines')
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

Get-Content $File -Tail $Lines
