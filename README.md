# CrowdStrike_RTR_PS_scripts
This is a miscellaneous collection of scripts intended for execution via CrowdStrike's Real-Time Response (RTR) tool on Windows hosts.

## Warning
This code has not been tested since ~Q4 2021.  Please review it before using any of it in your environment.  Some of the scripts in this repository were written to fill an obvious gap in functionality, such as the lack of "grep -R"-like functionality leading to Search-GrepRecursive.ps1.  Some of these gaps may be filled now by built-in functionality within RTR.

## Overview
Most of these scripts use a boilerplate code block in the "standard help template" section.  This sets up the script to return better error messages.  The actual code is in the bottom section of the script whenever this is present.

Feel free to use this same pattern in developing your own scripts if you find it useful.

## Usage
You can execute these scripts using the `runscript` command in an established RTR session, while passing any arguments required or optionally accepted by the script.  The boilerplate help section will help explain what is required.  Also, most scripts also support a `-help` parameter which will output 1+ example commands that should work.

Example:
```
runscript -CloudFile=Copy-FileRecursive.ps1 -Timeout=180 -CommandLine="-Path c:\users\c012345\AppData -FileMask *txt -Depth 2 -Destination c:\test" -Confirm
```

## Gotchas
Note the combination of single quotes (`'`) and double quotes (`"`).  This is because the RTR command processor requires the double quotes around arguments to `runscript` itself, while the Powershell execution context will accept either single or double quotes and treat them approximately equally.  All one has to do is us single quotes within the `-CommandLine` argument anywhere that double quotes might normally be used.  During testing, no workaround for this was found via escape characters.

Example:
```
runscript -CloudFile=myscript.ps1 -CommandLine="-argument1 'this is a literal term to pass to the underlying PS script processor' -argument2 'here is another one - your script has to handle these arguments in whatever way you want'" -MoreRTRParams -AfterTheClosedQuote
```
