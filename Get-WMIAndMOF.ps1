# Prints WMI objects and greps .mof files for cmd or powershell.
# Author: Nathan Hoffman

function Get-LongestTermInString ($string) {
  $terms = $string.Split(',')
  # cut off the last term, as it won't affect tabulation
  $terms = $terms[0..($terms.Length - 2)]
  $max = ($terms |% {$_.Length} |Measure-Object -Maximum).Maximum
  return $max
}

function Invoke-Tabulation ($string, $width=$table_max) {
  $terms = $string -split ','
  $tabulated = ''
  foreach ($term in $terms[0..($terms.Length - 2)]) {
    $offset = $width - $term.Length
    $tabulated += $term + (' ' * $offset)
  }
  $tabulated += $terms[-1]
  return $tabulated
}

echo "[+] Querying WMI objects..."
$results = foreach ($class in $('__eventfilter', 'commandlineeventconsumer', '__filtertoconsumerbinding')) {gwmi -namespace root\subscription -class $class}
$csv = $results |select __class,name,query |ConvertTo-Csv -NoTypeInformation

# put in placeholders where there are multiple commas or a comma at the end of a row
$csv = $csv |% {[regex]::Replace($_, "(?<=,),", "<blank>,")}
$csv = $csv |% {[regex]::Replace($_, "(?<=,)$", "<blank>")}

# need this to tabulate correctly -- adding 2 to pad
$table_max = ($csv |% {Get-LongestTermInString $_} |Measure-Object -Maximum).Maximum + 2

echo "All WMI filters, consumers, and bindings.  Check for bad stuff."
echo "==============================================================="
$csv |% {Invoke-Tabulation $_}
echo ""
echo ""
echo ""

echo "[+] Grepping .mof files for bad stuff..."
$mof_hits = dir c:\windows\system32\*.mof -Recurse |sls "(cmd\.exe|powershell\.exe)"

if ($mof_hits) {
  echo "Possibly infected files:"
  echo "========================"
  echo $mof_hits
}
else {
  echo "No .mof files with references to cmd.exe or powershell.exe"
}
