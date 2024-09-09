# Copies the Appx log to C:\.
# Author: Nathan Hoffman

$wevtutil = 'C:\Windows\System32\wevtutil.exe'
$evtx = "Microsoft-Windows-Store/Operational"
$output = "c:\Microsoft-Windows-Store_Operational.evtx"
$cmd = ("{0} epl {1} {2}" -f $wevtutil, $evtx, $output)

try {
  iex $cmd
  echo "[+] Output at $output"
}
catch {
  echo "[!] Got some kind of error :("
}
