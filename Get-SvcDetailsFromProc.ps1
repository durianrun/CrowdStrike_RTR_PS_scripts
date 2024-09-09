# Matches process names or PIDs with service names and prints service details.  Optionally filter by process name or PID (recommended).  Filter accepts partial matches on process names.
# Author: Nathan Hoffman

Param(
  [string]$Filter = '',
  [switch]$Help
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-SvcDetailsFromProc.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="[-Filter <partial_process_name_or_complete_PID>"')) |Out-Null
  $help.Add('  Example: list all services associated with PID 9001') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Filter 9001"')) |Out-Null
  $help.Add("  Example: list all services associated with any process named '*calc*'") |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Filter calc"')) |Out-Null
  echo $help
  exit
}

# display help?
$res = Get-Variable -Name 'Help'
if ($res.Value) {
  Print-Help
}

########################################

function Get-ColumnMaximums ($csv) {
  # find the max per column to calculate per-column offsets
  $column_count = ($csv[0] -split ',').count
  $column_maximums = @()
  foreach ($i in (0..($column_count - 1))) {
    $max = $csv |% {($_ -split ",")[$i]} |% {$_.length} |Measure-Object -Maximum
    $column_maximums += $max.Maximum  
  }

  return $column_maximums
}

function Invoke-Tabulation ($string, $column_maximums) {
  $terms = $string -split ','
  $tabulated = ''
  foreach ($i in (0..($terms.Length - 2))) {
    $term = $terms[$i]
    $offset = $column_maximums[$i] - $term.Length + 2
    $tabulated += $term + (' ' * $offset)
  }
  $tabulated += '  '
  $tabulated += $terms[-1]

  return $tabulated
}

function Edit-CSV ($csv) {
  ### fix text for better formatting
  # replace two double-quotes with one
  $csv = $csv |% {[regex]::Replace($_, '"{2}', '"')}
  
  # remove double quotes at the beginning
  $csv = $csv |% {[regex]::Replace($_, '^"', '')}
  
  # remove double quotes at the end
  $csv = $csv |% {[regex]::Replace($_, '"$', '')}
  
  # remove double quotes directly following or preceding a comma
  $csv = $csv |% {[regex]::Replace($_, '"?,"?', ',')}
  
  # put in placeholders where there are multiple commas or a comma at the end of a row
  $csv = $csv |% {[regex]::Replace($_, "(?<=,),", "<blank>,")}
  $csv = $csv |% {[regex]::Replace($_, "(?<=,)$", "<blank>")}

  return $csv
}

function Get-SvcDetailsFromProc ($proc) {
  if ($proc -match "^\d+$") {
    echo "[+] Input is a PID"
    $process_id = $proc
  }
  else {
    echo "[+] Assuming input is a process name"
    $process_name = $proc
  }

  if ($process_id) {
    $service = Get-WmiObject win32_service |? {$_.ProcessId -eq $process_id}
    $process_name = (Get-Process |? {$_.Id -eq $process_id}).ProcessName
    if (-not ($process_name)) {
      echo ("[!] PID {0} does not exist -- either the process is no longer running or incorrect input" -f $process_id)
      exit
    }
    if ($service) {
      return $service
    }
    else {
      echo ("[-] PID {0}/process {1} is not associated with a service" -f $process_id, $process_name)
      exit
    }
  }
  else {
    $procs = Get-Process |? {$_.ProcessName -like "*$process_name*"}
    $process_ids = $procs.Id
    $services = Get-WmiObject win32_service |? {$process_ids -contains $_.ProcessId}
    if ($services) {
      return $services
    }
    else {
      echo ("[-] No services running under a process named like '*{0}*'" -f $process_name)
      exit
    }
  }
}

$s = Get-SvcDetailsFromProc $Filter
$csv = $s |select name,pathname |ConvertTo-Csv -NoTypeInformation
$csv = Edit-CSV $csv
$column_maximums = Get-ColumnMaximums $csv
$csv |% {Invoke-Tabulation $_ $column_maximums}
echo ""
