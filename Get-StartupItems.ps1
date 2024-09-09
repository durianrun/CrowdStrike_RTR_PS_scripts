# Author: Nathan Hoffman

Param(
  [switch]$Help
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-StartupItems.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine=""')) |Out-Null
  $help.Add('  Example: list startup items') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine=""')) |Out-Null
  echo $help
  exit
}

# display help?
$res = Get-Variable -Name 'Help'
if ($res.Value) {
  Print-Help
}

########################################

# okay, so:
#   - WMI startup
#   - driverquery
#   - user startup folders
#   - all users startup folder

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

# registered startup programs
echo "[+] Checking startup programs..."
echo "================================"
$csv = gwmi -ea 0 Win32_StartupCommand | select name,command,user,caption |ConvertTo-Csv -NoTypeInformation
if ($csv.Length -eq 0) {
  echo "No results"
}
else {
  $csv = Edit-CSV $csv
  $column_maximums = Get-ColumnMaximums $csv
  $csv |% {Invoke-Tabulation $_ $column_maximums}
}
echo ""
echo ""

# Drivers running, Startup mode and Path - Sorted by Path
# TODO: convert to CSV and print with tabulation
echo "[+] Checking drivers that don't run out of system32..."
echo "======================================================"
$csv = driverquery.exe /v /FO CSV | ConvertFrom-CSV | Select 'Display Name','Start Mode',Path | sort Path |? {$_.path -notlike "*system32*"}
if ($csv.Length -eq 0) {
  echo "No results"
}
else {
  $csv = $csv |ConvertTo-Csv -NoTypeInformation
  $csv = Edit-CSV $csv
  $column_maximums = Get-ColumnMaximums $csv
  $csv |% {Invoke-Tabulation $_ $column_maximums}
}
echo ""
echo ""

# user startup folders
# TODO: check if this is already covered by the WMI command -- my machine has no hits so not sure
echo "[+] Checking user startup folders..."
echo "===================================="
$result = Get-ChildItem "C:\users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*" -ea 0
$result = $result |select CreationTimeUtc,LastWriteTimeUtc,PSIsContainer,FullName
$csv = $result |ConvertTo-Csv -NoTypeInformation
if ($csv.Length -eq 0) {
  echo "No results"
}
else {
  $csv = Edit-CSV $csv
  $column_maximums = Get-ColumnMaximums $csv
  $csv |% {Invoke-Tabulation $_ $column_maximums}
}
echo ""
echo ""

# all users startup folder
# TODO: check if this is already covered by the WMI command -- my machine has no hits so not sure
echo "[+] Checking other startup folder..."
echo "===================================="
$result = Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\*"
$result = $result |select CreationTimeUtc,LastWriteTimeUtc,PSIsContainer,FullName
$csv = $result |ConvertTo-Csv -NoTypeInformation
if ($csv.Length -eq 0) {
  echo "No results"
}
else {
  $csv = Edit-CSV $csv
  $column_maximums = Get-ColumnMaximums $csv
  $csv |% {Invoke-Tabulation $_ $column_maximums}
}
