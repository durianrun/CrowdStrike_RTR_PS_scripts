# Returns the computer's time zone and current time.
# https://gallery.technet.microsoft.com/scriptcenter/Get-DateTime-and-Time-Zone-b0f43d4c

$timeZone=Get-WmiObject -Class win32_timezone
$localTime = Get-WmiObject -Class win32_localtime
$output =[pscustomobject]@{
  'ComputerName' = $localTime.__SERVER
  'Time Zone' = $timeZone.Caption
  'Current Time' = (Get-Date -Day $localTime.Day -Month $localTime.Month); 
}
$output |Format-Table |Out-String