# FNF-MissionAnalyzer

## Requirements

3rd Party Utilities:
* [KillzoneKid Arma Debug Console extension](http://killzonekid.com/arma-console-extension-debug_console-dll-v3-0/)

> Note that the Python dependencies have been removed and mission.sqm is no longer directly parsed thanks to the added functionality of gathering data while in the EDEN Editor.

This utility has been tested on Windows Powershell 5.1. Powershell Core 6 and 7 on Windows, Linux, and Mac machines may not behave correctly.

## Usage

Copy the .dll files in the `debug_console extension` folder to your Arma 3 installation directory. This is used to export information from the game to a file.

Once you've done this, unless the directory is wiped or moved, you won't need to do it again.

---

Copy everything in the `MissionFolderItems` folder directly to the mission folder to analyze.

Load the mission in EDEN Editor.

Press `CTRL+D` to open the debug console.
Enter the desired command (reference below), then press `LOCAL EXEC`.

---

**++Previewing Loadouts++**

To apply loadouts as configured in config.sqf on all infantry units:
`[true] execVM 'previewFNFLoadoutsEden.sqf';`

To remove loadouts and strip characters before saving mission again:
`[false] execVM 'previewFNFLoadoutsEden.sqf';`


**++Exporting Mission Data to HTML & JSON++**

`execVM 'getMissionData.sqf';`

The process will open a debug console as the process works. When finished, you'll see white text stating so.

Next, return to the mission folder in Windows Explorer and right-click `processExportedData.ps1`. Select "Run with Powershell". The first run may take a moment, as it's autolocating your Arma 3 directory. It will save this info to your user profile so future instances will run faster.

---

## Output

The Powershell script will output HTML and JSON files to the mission folder then close. You can review the details of the mission there using a browser (HTML) or text editor (JSON).

For better viewing of JSON content, check out [this Chrome/Chromium extension](https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa?hl=en).
