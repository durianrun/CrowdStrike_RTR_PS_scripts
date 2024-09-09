# Greps a single file for a string. Optionally redirects output to file.
# Author: Nathan Hoffman

Param(
  [string]$Path,
  [string]$Grep,
  [switch]$CaseSensitive,
  [switch]$OutputToFile
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Search-GrepSingleFile.ps1', $Cmd='-Path c:\users\notes.txt -Grep pass') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path <filename> -Grep <search term> [-CaseSensitive] [-OutputToFile]"')) |Out-Null
  $help.Add('  Example: grep specific file for possible passwords') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Path', 'Grep')
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

if ($CaseSensitive) {
  $res = Select-String -Path $Path -Pattern $Grep -CaseSensitive
}
else {
  $res = Select-String -Path $Path -Pattern $Grep
}

if ($OutputToFile) {
  $output_path = "$env:SystemDrive\CS_GrepSingle__$Grep.txt"
  $res |Out-File -FilePath $output_path
  echo "Output results to $output_path"
}
else {
  echo $res
}
