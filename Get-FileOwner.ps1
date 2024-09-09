# Check ownership of a file
# Author: Nathan Hoffman

Param(
  [string]$Path
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-FileOwner.ps1', $Cmd='-Path c:\users\administrator\ntuser.dat') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-Path <file path>"')) |Out-Null
  $help.Add('  Example: check a file to see who owns it') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', "'", $Cmd, "'", '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Path')
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

function Get-FileOwner ($Path) {
  if (Test-Path $Path) {
    $fullname = (dir $Path -Force).FullName
    $a = Get-Acl $Path
    echo ("File:`t`t{0}" -f $fullname)
    echo ("Owner:`t`t{0}" -f $a.Owner)
    echo ("Permissions:")
    echo $a.AccessToString
  }
  else {
    echo "[!] Could not locate file"
  }
}

Get-FileOwner $Path
