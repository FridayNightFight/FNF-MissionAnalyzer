# FNF-MissionAnalyzer
*HTML Summary for FNF missions*

## Requirements

3rd Party Utilities:
* [PSSQLite Powershell module](https://github.com/RamblingCookieMonster/PSSQLite)
* [Armaclass](https://github.com/overfl0/Armaclass)


This utility uses [Armaclass](https://github.com/overfl0/Armaclass), a Python 3.4+ Arma class definition parser. You must have Python 3.4+ installed on your machine. You can find the latest stable installer [here](https://www.python.org/downloads/).

This utility has been tested on Windows Powershell 5.1. Powershell Core 6 and 7 on Windows, Linux, and Mac machines may not behave correctly.

## Usage

Left-click to select the AnalyzeSQM script in Windows Explorer, then right-click and select "Run with Powershell".
* If a valid version of Python 3 is not detected, the script will notify you then exit.
* The script will prompt you to install the the PSSQLite module, if not present, from the default PSGallery repository. Hit "Y" when prompted to proceed.

`Single` mode will prompt you for the full path to the mission.sqm file of the mission you wish to analyze.
1. The mission should be in an unpacked folder format.
1. The mission should have the FNF framework files applied.
1. The mission file should be unbinarized. If it is binarized, you'll receive a warning and the script will exit.

`Multi` mode is used by the vetting team for playlist generation each week.
1. Missions used should all meet the conditions for `Single` mode.
1. Up to 6 mission folders should be placed in the Mission Analyzer directory.
1. The script will generate an index page.
1. You'll be prompted to choose a mission up to 6 times. Upon each selection, the `Single` mode will be run to analyze the mission, with cross-reference links added to each page to enable a browseable site. *To exit early, press Ctrl-C.*
1. The batch of generated .html files can be placed in a web directory for publication.


## Output

The result will be one or more .html files written to the project's directory which can be opened with any browser.