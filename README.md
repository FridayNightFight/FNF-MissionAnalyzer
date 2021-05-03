# FNF-MissionAnalyzer
*HTML Summary for FNF missions*

## Requirements

3rd Party Utilities:
* [Armaclass Python parser](https://github.com/overfl0/Armaclass)
* [KillzoneKid Arma Debug Console extension](http://killzonekid.com/arma-console-extension-debug_console-dll-v3-0/)


This utility uses [Armaclass](https://github.com/overfl0/Armaclass), a Python 3.4+ Arma class definition parser. You must have Python 3.4+ installed on your machine. You can find the latest stable installer [here](https://www.python.org/downloads/).

This utility has been tested on Windows Powershell 5.1. Powershell Core 6 and 7 on Windows, Linux, and Mac machines may not behave correctly.

## Usage

**Copy the .dll files in the "debug_console extension" folder to your Arma 3 installation directory. This is used to export information from the game to a file.**
Once you've done this, unless the directory is wiped or moved, you won't need to do it again.

### To Process a Mission
Copy everything in the "Contents" folder directly to the mission folder to analyze.

Load the mission in EDEN Editor, and launch as Single Player. _It's ok to be in the Splendid Camera._

Press Escape to open the debug console.

Open "RunThisFirst.sqf" and paste the contents into the debug console in-game. Then press `LOCAL EXEC`.

The process will open a debug console as the process works. When finished, you'll see white text stating so.

Next, return to the mission folder in Windows Explorer and right-click "runThisNext.ps1". Select "Run with Powershell". The first run may take a moment, as it's autolocating your Arma 3 directory. It will save this so future instances will run faster.

## Output

The Powershell script will output an HTML file to the mission folder then close. You can review the details of the mission there.