# Author: Steven Duong
# Execute the kape tool using a specific target configuration file against the host system.
# https://ericzimmerman.github.io/KapeDocs/#!index.md

Param(
  [string]$Drive,
  [string]$TargetFile,
  [string]$TargetDestination,
  [switch]$Help
)

######## STANDARD HELP TEMPLATE ########
function Print-Help ($ScriptName='Run-Kape.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="<drive letter> <target file> <destination path>"')) |Out-Null
  $help.Add('  Example: Execute the kape tool using SOCTriage target configuration file against the host system.') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="C SOCTriage C:\Temp\RTR\kape_results"')) |Out-Null
  echo $help
  exit
}

$required_args = @('Drive', 'TargetFile', 'TargetDestination')
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

C:\Temp\RTR\kape\kape.exe --tsource $Drive --target $TargetFile --tdest $TargetDestination
