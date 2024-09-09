# Returns all instances of a file mask in a file path. Accepts wildcards.
# Author: Nathan Hoffman

Param(
  [string]$Path,
  [string]$FileMask = "*",
  [int]$Depth = 100,
  [switch]$OutputToFile = $false
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Search-FileRecursive.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path <file path> -FileMask <file name/wildcard> [-Depth <max depth>]"')) |Out-Null
  $help.Add("FileMask defaults to '*' and Depth defaults to 100.") |Out-Null
  $help.Add('  Example: search all user directories for CSV files') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\users\ -FileMask *csv"')) |Out-Null
  $help.Add("  Example: search a user's AppData directories for text files, but limit at 2 directories deep") |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\users\jsmith\ -FileMask *txt -Depth 2"')) |Out-Null
  $help.Add("  Example: output all files on an external drive to a CSV file (could be slow/timeout!)") |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=300 -CommandLine="-Path e:\ -FileMask * -OutputToFile"')) |Out-Null

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

function Search-FileRecursive ($Path=$Path, $FileMask=$FileMask, $Depth=$Depth, $OutputToFile=$OutputToFile) {
  $files = Get-ChildItem -Path $Path -Filter $FileMask -ErrorAction SilentlyContinue -Force -Depth $Depth

  if ($files) {
    echo $files.FullName
    echo ("_" * 50)
    echo ("[+] {0} matching files found!" -f $files.Count)
    $total_size = ($files |Measure-Object -Sum Length).Sum

    # optionally output
    if ($OutputToFile) {
      $root = (Get-Location).Drive.Root
      $output_path = Join-Path $root "windows\temp\RTR"
      $now = Get-Date -Format "yyyyMMdd_HHmm"
      $base_name = ("Search_FileRecursive_{0}.csv" -f $now)
      $output_file = Join-Path $output_path $base_name
      
      # create the directory if needed
      if (! (Test-Path $output_path)) {
        New-Item -ItemType directory -Path $output_path
      }
      $files |select FullName,CreationTimeUtc,LastAccessTimeUtc,LastWriteTimeUtc,Length |Export-Csv -Path $output_file -NoTypeInformation
      $msg = ("+ Output is at {0} +" -f $output_file)
      echo ("")
      echo ("+" * $msg.Length)
      echo $msg
      echo ("+" * $msg.Length)
      echo ("")
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

  }
  else {
    echo "[!] Could not find matching files"
  }

}

Search-FileRecursive -Path $Path -FileMask $FileMask -Depth $Depth $OutputToFile
