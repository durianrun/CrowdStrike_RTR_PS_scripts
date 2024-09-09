# Search for files created by reference file or timestamp
# Author: Nathan Hoffman

Param
 (
  [string]$Path = '',
  [string]$FileOrTimestamp = '',
  [int]$BeforeHours = 1,
  [int]$AfterHours = 1
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Search-FilesByReferenceFileOrTime.ps1', $Cmd='-Path C:\Users -BeforeHours 3 -AfterHours 2 -FileOrTimestamp c:\users\admin\bad.exe') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -CommandLine="-Path <path> -FileOrTimestamp <reference file or time> [-BeforeHours <hours> -AfterHours <hours>]"')) |Out-Null
  $help.Add('  This script finds files created shortly before or after a given file was created,') |Out-Null
  $help.Add('    or a timestamp specified by the user.') |Out-Null
  $help.Add('  -Path is where to start the recursive search.') |Out-Null
  $help.Add('  -BeforeHours and -AfterHours both default to 1 hour.') |Out-Null
  $help.Add('  -FileOrTimestamp can be a file or a timestamp.') |Out-Null
  $help.Add('  If this is a file, its creation time will be used as the reference time.') |Out-Null
  $help.Add('  If this is a timestamp, it will be used as the reference time.') |Out-Null
  $help.Add('  Timestamps should be formatted like this:') |Out-Null
  $help.Add('    2051-03-25T15:22:00') |Out-Null
  $help.Add('') |Out-Null
  $help.Add('  Example: search the C:\Users directory for files created between 3 hours before and 2 hours after a reference file') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -CommandLine="', $Cmd, '"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Path', 'FileOrTimestamp')
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

function Search-FilesByReferenceFileOrTime ($Path, $FileOrTimestamp, $BeforeHours, $AfterHours) {
  # check if it's a file or a timestamp
  try {
    $timestamp = [datetime]$FileOrTimestamp
    echo ("[+] Got timestamp as input: {0}" -f $timestamp)
  }
  catch {
    $file = $FileOrTimestamp
    if (! (Test-Path $file)) {
      echo ("[!] Got file as input, but does not exist: {0}" -f $file)
      return
    }
    else {
      echo ("[+] Got file as input: {0}" -f $file)
    }
  }
  
  if ($file) {
    $ref_creation_time = (dir $file).CreationTimeUtc
  }
  else {
    $ref_creation_time = $timestamp
  }
  
  $earlier = $ref_creation_time.AddHours(-$BeforeHours)
  $later = $ref_creation_time.AddHours($AfterHours)
  echo ("[+] Using reference time: {0}" -f $ref_creation_time)
  echo ("[+] Searching between {0} and {1}" -f $earlier, $later)
  $results = dir $Path -Recurse -Force -ErrorAction SilentlyContinue |? {$_.CreationTimeUtc -ge $earlier -and $_.CreationTimeUtc -le $later} |sort -Property CreationTimeUtc
  $results |select creationtimeutc,fullname |ConvertTo-Csv -NoTypeInformation |% {$_ -replace '"', '' -replace ',', "`t"}
}

Search-FilesByReferenceFileOrTime -Path $Path -FileOrTimestamp $FileOrTimestamp -BeforeHours $BeforeHours -AfterHours $AfterHours

