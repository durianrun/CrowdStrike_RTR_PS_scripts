# Lists TCP and UDP records.  Optional wildcard grep (ports, IPs, processes).
# Author: Nathan Hoffman

Param(
  [string]$Filter = $null,
  [switch]$Help
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-NetstatWithProcs.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="[-Filter <filter_term>]"')) |Out-Null
  $help.Add('  Example: list all TCP and UDP records') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine=""')) |Out-Null
  $help.Add("  Example: list all TCP listeners") |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Filter listen"')) |Out-Null
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

# main logic
$tcp = Get-NetTCPConnection
$udp = Get-NetUDPEndpoint
$procs = Get-Process

$tcp_res = for ($tcp_idx = 0; $tcp_idx -lt $tcp.Count; $tcp_idx++) {
  $conn = $tcp[$tcp_idx]
  for ($proc_idx = 0; $proc_idx -lt $procs.Count; $proc_idx++) {
    $proc = $procs[$proc_idx]
    if ($proc.Id -eq $conn.OwningProcess) {
      $process_name = $proc.ProcessName
      break
    }
  }
  [pscustomobject]@{
    'Proto' = 'TCP'
    'LocalAddress' = ("{0}:{1}" -f $conn.LocalAddress,$conn.LocalPort)
    'RemoteAddress' = ("{0}:{1}" -f $conn.RemoteAddress,$conn.RemotePort)
    'ProcessName' = $process_name
    'PID' = $conn.OwningProcess
    'State' = $conn.State
  }
}

$udp_res = for ($udp_idx = 0; $udp_idx -lt $udp.Count; $udp_idx++) {
  $conn = $udp[$udp_idx]
  for ($proc_idx = 0; $proc_idx -lt $procs.Count; $proc_idx++) {
    $proc = $procs[$proc_idx]
    if ($proc.Id -eq $conn.OwningProcess) {
      $process_name = $proc.ProcessName
      break
    }
  }
  [pscustomobject]@{
    'Proto' = 'UDP'
    'LocalAddress' = ("{0}:{1}" -f $conn.LocalAddress,$conn.LocalPort)
    'RemoteAddress' = ' '
    'ProcessName' = $process_name
    'PID' = $conn.OwningProcess
    'State' = ' '
  }
}

$csv = $tcp_res + $udp_res |ConvertTo-Csv -NoTypeInformation
$csv = Edit-CSV $csv
if ($filter) {
  $header = $csv[0]
  $csv = $csv |? {$_ -like "*$filter*"}
  $csv = @($header) + $csv
}
$column_maximums = Get-ColumnMaximums $csv
$csv |% {Invoke-Tabulation $_ $column_maximums}
echo ""
