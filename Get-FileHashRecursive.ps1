# Finds all instances of a file mask in a file path, then returns the hash and full path of the file. Accepts wildcards.
# Author: Nathan Hoffman

Param(
  [string]$Path,
  [string]$FileMask,
  [int]$Depth = 100,
  [ValidateSet("MACTripleDES", "MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")]
  [string]$HashType = "SHA256",
  [switch]$Help
)

######## STANDARD HELP TEMPLATE ########
# !!! Make sure to update $ScriptName, $Cmd, and the example for each new script !!!
function Print-Help ($ScriptName='Get-FileHashRecursive.ps1') {
  $help = New-Object System.Collections.Arraylist
  $help.Add(-join ('Usage: runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path <file path> -FileMask <file name/wildcard> [-Depth <max depth>]"')) |Out-Null
  $help.Add("FileMask defaults to '*', Depth defaults to 100, and HashType defaults to SHA256.") |Out-Null
  $help.Add("Hash algorithm choices: MACTripleDES, MD5, RIPEMD160, SHA1, SHA256, SHA384, SHA512")
  $help.Add('  Example: search all user directories for .exe files and return the hash') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\users\ -FileMask *exe"')) |Out-Null
  $help.Add('  Example: return the hash for utilman.exe in any subdirectory of c:\windows') |Out-Null
  $help.Add(-join ('  runscript -CloudFile="', $ScriptName, '" -Timeout=180 -CommandLine="-Path c:\windows\ -FileMask utilman.exe"')) |Out-Null
  echo $help
  exit
}

# !!! Make sure to update the required args here, too.
$required_args = @('Path', 'FileMask')
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

function Get-FileHashRecursive ($Path=$Path, $FileMask=$FileMask, $Depth=$Depth, $HashType=$HashType) {
  [array]$files = Get-ChildItem -Path $Path -Filter $FileMask -ErrorAction SilentlyContinue -Force -Depth $Depth

  if ($files) {
    $hashes = $files |Get-FileHash -Algorithm $HashType
    foreach ($hash in $hashes) {
      echo ("{0}: {1}" -f $hash.Hash, $hash.Path)
    }
      
  }
  else {
    echo "[!] Could not find matching files"
  }

}

Get-FileHashRecursive -Path $Path -FileMask $FileMask -Depth $Depth -HashType $HashType
