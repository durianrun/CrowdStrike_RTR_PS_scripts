# Copies all instances of a file mask in a file path to a directory. Accepts wildcards.
# Author: Nathan Hoffman

Param(
  [string]$Path,
  [string]$FileMask = "*",
  [int]$Depth = 100,
  [string]$Destination = "$env:windir\temp\RTR_archive",
  [switch]$Help,
  [switch]$Confirm
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Copy-FileRecursive.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path <file path> -FileMask <file name/wildcard> [-Depth <max depth> -Destination <destination directory>]"')) |Out-Null
  $help.Add("FileMask defaults to '*', Depth defaults to 100, and Destination defaults to C:\windows\temp\RTR_archive.") |Out-Null
  $help.Add('  Example: copy all CSV files in a user directory to c:\windows\temp\RTR_archive') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\users\jsmith -FileMask *csv"')) |Out-Null
  $help.Add("  Example: copy text files from a user's AppData directories for text files to c:\test, but limit at 2 directories deep, and override the 200MB limit") |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\users\jsmith\AppData -FileMask *txt -Depth 2 -Destination c:\test" -Confirm')) |Out-Null
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

# display help?
$res = Get-Variable -Name 'Help'
if ($res.Value) {
  Print-Help
} 


$ErrorActionPreference = $e
########################################

function Copy-FileRecursive ($Path=$Path, $FileMask=$FileMask, $Depth=$Depth, $Destination=$Destination, $Confirm=$Confirm) {
  $files = Get-ChildItem -Path $Path -Filter $FileMask -ErrorAction SilentlyContinue -Force -Depth $Depth
  if ($files) {
    echo ("[+] {0} matching files found!" -f $files.Count)
    $total_size = ($files |Measure-Object -Sum Length -Verbose).Sum
    
    # verify it's not too much data
    if ($total_size -gt 200MB -and (-not $Confirm)) {
      echo ("[-] More than 200MB of files.  Adjust the query to retry, or run with -Confirm option.")
      echo ("[-] Size: {0:n2}GB" -f ($total_size / 1GB))
      return
    }
    
    # print the size
    if ($total_size -lt 1KB) {
      echo ("[+] Total size: {0} bytes" -f $total_size)
    }
    elseif ($total_size -lt 1MB) {
      echo ("[+] Total size: {0} kilobytes" -f ([math]::Round($total_size / 1KB, 2)))
    }
    else {
      echo ("[+] Total size: {0} megabytes" -f ([math]::Round($total_size / 1MB, 2)))
    }

    # test if destination already exists, and create if it doesn't
    if (-not (Test-Path $Destination)) {
      echo "[-] Destination doesn't exist, creating"
      mkdir $Destination
    }

    # perform the copy
    try {
      Copy-Item $files.FullName $Destination -ErrorAction SilentlyContinue
      echo ("[+] Copied {0} files to {1}" -f $files.Count, $Destination)
    }
    catch {
      echo "[!] Got an error on copying files"
    }
  }
  else {
    echo "[!] Could not find matching files"
  }
}

Copy-FileRecursive -Path $Path -FileMask $FileMask -Depth $Depth -Destination $Destination
