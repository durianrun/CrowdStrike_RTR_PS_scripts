# Outputs the process list with a filter.  Optionally redirects output to file.
# Author: Nathan Hoffman

Param(
  [string]$Process,
  [switch]$OutputToFile
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Filter-ProcessList.ps1', $Cmd='-Process scvhost') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Process <process name> [-OutputToFile]"')) |Out-Null
  $help.Add('  Example: filter process list for fake svchost.exe entries') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Process')
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

$processes = Get-Process |? {$_.ProcessName -like "*$Process*"} |select Name,Path,@{N='PID';E={$_.Id}},Company,Description,FileVersion,ProductVersion,CPU,Handles

if ($OutputToFile) {
  $path = "$env:SystemDrive\CS_ProcessList__$Process.csv"
  $processes |Export-Csv -Path $path -NoTypeInformation
  echo "Output results to $path"
}
else {
  $processes |ConvertTo-Csv -NoTypeInformation
}
