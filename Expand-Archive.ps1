# Author: Steven Duong
# Extracts files from a specified archive (zipped) file.
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.1

Param(
  [string]$Path,
  [string]$DestinationPath
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Expand-Archive.ps1', $Cmd='-Path Foo.zip -DestinationPath C:\Example') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-Path <source file path> -DestinationPath <destination file path>"')) |Out-Null
  $help.Add('  Example: Extract the contents of an existing archive file in the current folder into the folder specified by the DestinationPath parameter.') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Path', 'DestinationPath')
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

Expand-Archive -Path $Path -DestinationPath $DestinationPath
