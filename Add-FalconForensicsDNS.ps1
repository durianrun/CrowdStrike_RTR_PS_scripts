# Adds CrowdStrike Falcon Forensics Collector IPs to the machine's host file.
# Author: Nathan Hoffman

Param(
  [string]$FileName = "C:\Windows\System32\drivers\etc\hosts",
  [switch]$Remove
)

function Get-BackupFiles {
  # check for any cleanup
  $hosts_cleanup = dir 'c:\hosts*' -ErrorAction SilentlyContinue
  if ($hosts_cleanup) {
    echo 'Removing these backup files:'
    $hosts_cleanup |% {echo $_.FullName}
    $hosts_cleanup |Remove-Item

  }
}

function Add-FalconForensicsDNS ($FileName='C:\Windows\System32\drivers\etc\hosts', $Remove) {
  # from 'nslookup ffc.us-1.crowdstrike.com'
  $ip1 = '54.193.196.61'
  $ip2 = '52.52.60.244'

  # just making sure we have a full path
  $FileName = (Get-ChildItem $FileName -ErrorAction Stop).FullName

  # check read permissions
  try {
    echo 'Reading hosts file'
    $contents = Get-Content $FileName -ErrorAction Stop
  }
  catch {
    echo "[!] Couldn't read file. Verify filename and permissions."
    Get-BackupFiles
    return
  }

  # make backup of file
  try {
    echo 'Copying hosts file to c:\hosts.bak'
    Copy-Item $FileName 'c:\hosts.bak' -ErrorAction Stop
  }
  catch {
    echo "[!] Couldn't create backup at C:\hosts.bak, bailing"
    Get-BackupFiles
    return
  }

  # remove entries?
  if ($Remove) {
    if ($contents -match 'CrowdStrike Falcon Forensics') {
      echo "Found FFC DNS entries, removing"
      $contents -match 'CrowdStrike Falcon Forensics' |% {echo $_}
      # will save output later
      $contents = $contents -notmatch 'CrowdStrike Falcon Forensics'
    }
    else {
      echo "No FFC DNS entries present, exiting"
      Get-BackupFiles
      return
    }
  }
  # not removing
  else {
    # test if entries already here
    if ($contents -match 'CrowdStrike Falcon Forensics') {
      echo 'Falcon Forensics entries already entered!'
      echo 'Use -Remove switch to clean'
      echo ''
      echo 'Existing entries:'
      $contents -match 'CrowdStrike Falcon Forensics'
      Get-BackupFiles
      return
    }

    # entries not here yet, so add them
    $contents += "`n"
    foreach ($ip in @($ip1, $ip2)) {
      if ((Get-Content $filename) -match $ip) {
        echo ("[!] {0} already has an entry in {1}, skipping" -f $ip, $filename)
        continue
      }
      $length = 20 - $ip.Length
      $padding = (' ' * $length)
      $line = ("{0}{1}ffc.us-1.crowdstrike.com  # CrowdStrike Falcon Forensics" -f $ip, $padding)
      $contents += $line
      echo ("Added {0} to buffer" -f $ip)
    }
  }
  
  # write buffer to temp file
  $temp = 'c:\hosts.tmp'
   try {
    echo "Saving to temporary file..."
    Set-Content $temp $contents -ErrorAction Stop
  }
  catch {
    echo "[!] Couldn't save changes to temp file, bailing"
    Get-BackupFiles
    return
  }
  
  # copy to original location
  try {
    echo 'Copying modified file to original file'
    Copy-Item $temp $FileName -ErrorAction Stop
  }
  catch {
    echo "[!] Got error on copy! Check file for bad entries:"
    Get-Content $FileName
    return
    Get-BackupFiles
  }
  echo "Save succeeded! Use cat to verify."
  Get-BackupFiles
}

Add-FalconForensicsDNS $FileName $Remove
