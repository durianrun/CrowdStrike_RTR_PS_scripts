# Open a message window
# adapted from a script provided by Dan Lussier

Param(
  [string]$Message
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='New-DesktopMessage.ps1', $Cmd='Your computer has been quarantined due to a possible malware infection.`nPlease contact the SOC at 401-770-3111 for more information.') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-Message <message to the end user>"')) |Out-Null
  $help.Add('  Example: inform the user that their machine is quarantined') |Out-Null
  $help.Add('    Note that to include a newline you use `n (backtick + n)') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', "'", $Cmd, "'", '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Message')
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

function New-DesktopMessage($Message=$Message) {
  $msg_path = 'c:\WINDOWS\system32\msg.exe'
  if (Get-ChildItem $msg_path -ErrorAction SilentlyContinue) {
    $strCmd = ('{0} /time:600 * "{1}"' -f $msg_path, $Message)
    iex $strCmd
  }
  else {
    echo "Error: could not find msg.exe. Exiting."
    return
  }
}

New-DesktopMessage $Message