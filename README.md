# CrowdStrike_RTR_PS_scripts
This is a miscellaneous collection of scripts intended for execution via CrowdStrike's Real-Time Response (RTR) tool on Windows hosts.

## Warning
This code has not been tested in several years.  Please review it before using any of it in your environment.  Some of the scripts in this repository were written to fill an obvious gap in functionality, such as the lack of "grep -R"-like functionality leading to Search-GrepRecursive.ps1.  Some of these gaps may be filled now by built-in functionality.

## Overview
Most of these scripts use a boilerplate code block in the "standard help template" section.  This sets up the script to return better error messages.  The actual code is in the bottom section of the script whenever this is present.

Feel free to use this same pattern in developing your own scripts if you find it useful.
