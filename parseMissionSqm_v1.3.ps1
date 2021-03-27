<#

.SYNOPSIS

This script parses the mission.sqm and config.sqf files from a mission folder using the Friday Night Framework and summarizes the mission and its contents in an HTML page with conditional checking for the standardized requirements of its submission.

.DESCRIPTION

3rd Party Tools Used: 
	- PSSQLite Powershell Module (https://www.powershellgallery.com/packages/PSSQLite/1.1.0)

This script allows both the mission review team of Friday Night Fight staff and the mission creator to vet a mission and see if it meets the standards for submission and further review.

It will prompt for the path to an sqm file, then:
1. Check the mission name and description against a regex pattern
2. Gather some additional settings stored in the .sqm file
2. Parse out 'name' and 'type' properties of every class
3. Compare these against the included SQLite database containing all 'vehicle' classes in vanilla Arma and FNF modsets
4. Parse the config.sqf file for the mission
5. Output everything into a summary .html page in the script directory

__How to Use:__

	1. Left-click the script to select it, then Right-click it and select Run with Powershell.
	_If you don't see the Run with Powershell option, check your default file associations for .ps1 files_

	2. Paste in the absolute/literal path to the mission.sqm that should be analyzed. If the .sqm is binarized, it will notify you. In that case, you'll need to debinarize it first and point the script to the unbinarized version.

.NOTES

Author: IndigoFox
Website: indifox.info
Email: indifox926@gmail.com
Discord: IndigoFox#6290

#>


##### INFO #####

# Mission Name
# $MissionName

# Mission Description / Lobby Text
# $MissionDescription

# Weather settings
# $Weather


# List of all units (playable  + spectator) present in the mission
# $AllUnits

# List of C2/Golf role descriptions that have been changed
# $LabeledSpecialUnits



# List of every object in the mission
# $AllObjects

# Counts of every object type in the mission
# $AllObjectsCounts


# Count of Zeus modules present
# $ZeusCount
# Count of Spectator modules present
# $SpectatorCount


# List of all objects that couldn't be identified
# $UnidentifiedObjects

##### ISSUES #####
# Checklist of items that need adjustment before approval



[CmdletBinding()]
param (
	[Parameter()]
	[Switch]
	$MultiProcess = $false
)




##############################################################################################################
#                                         FUNCTIONS
##############################################################################################################

Function New-Menu {
	#Start-Transcript "C:\_RRC\MenuLog.txt"
	Param (
		[Parameter(Mandatory = $True)][String]$MenuTitle,
		[Parameter(Mandatory = $True)][array]$MenuOptions,
		[Parameter(Mandatory = $True)][String]$Columns = "Auto",
		[Parameter(Mandatory = $False)][int]$MaximumColumnWidth = 20,
		[Parameter(Mandatory = $False)][bool]$ShowCurrentSelection = $False
	)

	$MaxValue = $MenuOptions.count - 1
	$Selection = 0
	$EnterPressed = $False

	If ($Columns -eq "Auto") {
		$WindowWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
		$Columns = [Math]::Floor($WindowWidth / ($MaximumColumnWidth + 2))
	}

	If ([int]$Columns -gt $MenuOptions.count) {
		$Columns = $MenuOptions.count
	}

	$RowQty = ([Math]::Ceiling(($MaxValue + 1) / $Columns))
        
	$MenuListing = @()

	For ($i = 0; $i -lt $Columns; $i++) {
            
		$ScratchArray = @()

		For ($j = ($RowQty * $i); $j -lt ($RowQty * ($i + 1)); $j++) {

			$ScratchArray += $MenuOptions[$j]
		}

		$ColWidth = ($ScratchArray | Measure-Object -Maximum -Property length).Maximum

		If ($ColWidth -gt $MaximumColumnWidth) {
			$ColWidth = $MaximumColumnWidth - 1
		}

		For ($j = 0; $j -lt $ScratchArray.count; $j++) {
            
			If (($ScratchArray[$j]).length -gt $($MaximumColumnWidth - 2)) {
				$ScratchArray[$j] = $($ScratchArray[$j]).Substring(0, $($MaximumColumnWidth - 4))
				$ScratchArray[$j] = "$($ScratchArray[$j])..."
			} Else {
            
				For ($k = $ScratchArray[$j].length; $k -lt $ColWidth; $k++) {
					$ScratchArray[$j] = "$($ScratchArray[$j]) "
				}

			}
            
			$ScratchArray[$j] = " $($ScratchArray[$j]) "
		}
		$MenuListing += $ScratchArray
	}
    
	Clear-Host

	While ($EnterPressed -eq $False) {
        
		# $LongestItemLength = ($MenuOptions | Measure-Object -Maximum -Property Length).Maximum + 16

		$MenuTitle = $MenuTitle.PadLeft((((($MaximumColumnWidth * $Columns) + 2) - $MenuTitle.Length) / 2) + $MenuTitle.Length)
		$MenuTitle = $MenuTitle.PadRight((($MaximumColumnWidth * $Columns) + 2))
		$StartBorder = ""
		$StartBorder = $StartBorder.PadRight((($MaximumColumnWidth * $Columns) + 2), "═")
		$StartBorder = "╔$StartBorder╗"
		$HeaderBorder = ""
		$HeaderBorder = $HeaderBorder.PadRight((($MaximumColumnWidth * $Columns) + 2), "═")
		$HeaderBorder = "╟$HeaderBorder╢"
		$EndBorder = ""
		$EndBorder = $EndBorder.PadLeft((($MaximumColumnWidth * $Columns) + 2), "═")
		$EndBorder = "╚$EndBorder╝"
		Write-Host -ForegroundColor Gray -BackgroundColor Black $StartBorder
		Write-Host -ForegroundColor Gray -BackgroundColor Black "║$MenuTitle║"
		Write-Host -ForegroundColor Gray -BackgroundColor Black $EndBorder
		Write-Host

        
		If ($ShowCurrentSelection -eq $True) {
			# $Host.UI.RawUI.WindowTitle = "CURRENT SELECTION: $($MenuOptions[$Selection])"
		}

		For ($i = 0; $i -lt $RowQty; $i++) {

			For ($j = 0; $j -le (($Columns - 1) * $RowQty); $j += $RowQty) {

				If ($j -eq (($Columns - 1) * $RowQty)) {
					If (($i + $j) -eq $Selection) {
						# Write-Host -BackgroundColor cyan -ForegroundColor Black "$($MenuListing[$i+$j])"
						Write-Host " >$($MenuListing[$i+$j])"
					} Else {
						Write-Host "  $($MenuListing[$i+$j])"
					}
				} Else {

					If (($i + $j) -eq $Selection) {
						# Write-Host -BackgroundColor Cyan -ForegroundColor Black "$($MenuListing[$i+$j])" -NoNewline
						Write-Host " >$($MenuListing[$i+$j])" -NoNewline
					} Else {
						Write-Host "  $($MenuListing[$i+$j])" -NoNewline
					}
				}
                
			}

		}

		#Uncomment the below line if you need to do live debugging of the current index selection. It will put it in green below the selection listing.
		#Write-Host -ForegroundColor Green "$Selection"

		$KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode

		Switch ($KeyInput) {
			13 {
				$EnterPressed = $True
				Return $Selection
				Clear-Host
				break
			}

			37 {
				#Left
				If ($Selection -ge $RowQty) {
					$Selection -= $RowQty
				} Else {
					$Selection += ($Columns - 1) * $RowQty
				}
				Clear-Host
				break
			}

			38 {
				#Up
				If ((($Selection + $RowQty) % $RowQty) -eq 0) {
					$Selection += $RowQty - 1
				} Else {
					$Selection -= 1
				}
				Clear-Host
				break
			}

			39 {
				#Right
				If ([Math]::Ceiling($Selection / $RowQty) -eq $Columns -or ($Selection / $RowQty) + 1 -eq $Columns) {
					$Selection -= ($Columns - 1) * $RowQty
				} Else {
					$Selection += $RowQty
				}
				Clear-Host
				break
			}

			40 {
				#Down
				If ((($Selection + 1) % $RowQty) -eq 0 -or $Selection -eq $MaxValue) {
					$Selection = ([Math]::Floor(($Selection) / $RowQty)) * $RowQty
                    
				} Else {
					$Selection += 1
				}
				Clear-Host
				break
			}
			Default {
				Clear-Host
			}
		}
	}
}



function Out-Mission {

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True)]
		[String]
		$SQMPathToParse,
		[Parameter(Mandatory = $False)]
		[Int]
		$MissionNumber
	)


	$FilePathSQM = $SQMPathToParse

	# Make sure valid path was provided
	if (!(Test-Path $FilePathSQM)) {
		Write-Error "Failed to verify path exists: ""$FilePathSQM"""
		Pause
		exit
	}

	function Test-IfBinary ([String] $Content) {
		for ([int] $i = 0; $i -lt $Content.Length; $i++) {
			if ($Content[$i] -gt 127) {
				return $true
			}
		}
		return $false;
	}

	# Get file contents
	if (Test-IfBinary (Get-Content $FilePathSQM -Raw)) {
		Write-Host -ForegroundColor Red "Mission is binarized and cannot be read."
		Pause
		exit
	}

	# Get mission folder path
	$FilePathMission = Split-Path $FilePathSQM -Parent

	# Make sure config.sqf is present
	if (!(Test-Path "$FilePathMission\config.sqf")) {
		Write-Error "Failed to find mission\config.sqf"
		Pause
		exit
	}

	

	# Get config.sqf path
	$FilePathConfig = "$FilePathMission\config.sqf"


	$FileContentSQM = (Get-Content $FilePathSQM).Trim()
	$FileContentConfig = (Get-Content $FilePathConfig).Trim()

	
	. ".\dist\parseSqm.exe" $filePathSqm | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Host -ForegroundColor Red "Failed to parse the SQM file. Please ensure it hasn't been manually modified and is unbinarized."
		Pause
		exit
	}


	$SQMJson = Get-Content ".\sqmjson.txt" | ConvertFrom-Json
	Start-Sleep 1
	Remove-Item ".\sqmjson.txt" -Force

	[Hashtable] $SQMEntitiesHash = @{}
	foreach ( $property in $SQMJson.Mission.Entities.psobject.properties.name ) {
		$SQMEntitiesHash[$property] = $SQMJson.Mission.Entities.$property
	}

	[Array] $GroupObjs = @()
	[Array] $UnitObjs = @()
	[Array] $ObjectObjs = @()
	[Array] $LayerObjs = @()
	[Array] $MarkerObjs = @()
	[Array] $LogicObjs = @()
	[Array] $TriggerObjs = @()
	[Array] $CommentObjs = @()
	ForEach ($Item in $SQMEntitiesHash.GetEnumerator()) {
		switch ($Item.value.dataType) {
			"Group" {$GroupObjs += $Item.value}
			"Object" { $ObjectObjs += $Item.value }
			"Layer" { $LayerObjs += $Item.value }
			"Marker" { $MarkerObjs += $Item.value }
			"Logic" { $LogicObjs += $Item.value }
			"Trigger" { $TriggerObjs += $Item.value }
			"Comment" { $CommentObjs += $Item.value }
		}
	}
	# ! FIX
	[Hashtable] $UnitObjsHash = @{}
	foreach ( $property in $GroupObjs.Entities.psobject.properties.name ) {
		$UnitObjsHash[$property] = $GroupObjs.Entities.$property
	}
	ForEach ($Unit in $GroupObjs.Entities) {
					$UnitObjs += $Unit
				}
	$GroupObjs | Select-Object dataType, side, entities | Out-GridView
	$ObjectObjs | Select-Object @(
		"dataType",
		"type",
		@{n="name";e={$_.Attributes.name}},
		@{n="lock";e={$_.Attributes.lock}},
		@{n="fuel";e={$_.Attributes.fuel}},
		@{n="ammo";e={$_.Attributes.ammo}},
		@{n="init";e={$_.Attributes.init}},
		@{n="textures";e={$_.Attributes.textures}}
	) | Out-GridView
	$LayerObjs | Select-Object dataType, name, entities | Out-GridView
	$MarkerObjs | Select-Object dataType, name, markerType | Out-GridView
	$LogicObjs | Select-Object dataType, name, presenceCondition, type | Out-GridView
	$TriggerObjs | Select-Object dataType, @{n="name";e={$_.Attributes.name}} | Out-GridView
	$CommentObjs | Select-Object dataType, description | Out-GridView



	# $MissionName = ($FilePathMission -split '\\')[-1]
	[String] $MissionName = $SQMJson.sourceName






	# Mission Description
	<# 
	[String] $MissionDescription = $FileContentSQM | Select-String -Pattern 'overviewText[\s]*=' | Select-Object -ExpandProperty Line
	$Desc = $MissionDescription.Trim()
	$DescValue = ($Desc -split '=')[1]
	$MissionDescription = $DescValue.Substring(1, $DescValue.Length - 2).Trim() -replace '"', ''
	#>
	[String] $MissionDescription = $SQMJson.Mission.Intel.overviewText



	###### CONFIG.SQF PARSING ######

	[System.Collections.ArrayList] $ConfigSettings = @{}
	$ConfigSettingsRaw = ($FileContentConfig | Select-String -Pattern '^phx_' | Select-Object -ExpandProperty Line)
	ForEach ($Line in $ConfigSettingsRaw) {
		$t = $Line.Trim() -replace '"', '' -split '='
		[void] $ConfigSettings.Add([PSCustomObject]@{"Name" = ($t[0].Trim() -replace 'phx_', ''); "Value" = ($t[1] -split ';')[0].Trim() })
	}






	###### MISSION DATA PARSING ######

	# Mission Name
	$MissionNamePattern = '^FNF_[A-z0-9]+_[A-z0-9\-]+_[A-z0-9]+_v[0-9]{1,2}_(EU|NA|ANY)'
	if (!($MissionName -match $MissionNamePattern)) {
		Write-Host -ForegroundColor Yellow "Mission name validation failed - please double check it's formatted correctly"
		# [void] $NeedToFix.Add("Mission name validation failed - please double check it's formatted correctly")
		$MissionNameNeedsFixed = $True
	}

	# Mission Description
	$MissionDescriptionPattern = '^[A-Z]+\(\d{1}\) \/\/ ATK: ([A-Z]{3} [\d]{1,2}% adv - DEF: [A-Z]{3}|[A-Z]{3} [A-Z]{3}|[A-Z]{3} [A-Z]{3} [A-Z]{3}) \/\/ ([A-Z]{3}: (.+) \/\/ [A-Z]{3}: (.+)|[A-Z]{3}: (.+) \/\/ [A-Z]{3}: (.+) \/\/ [A-Z]{3}: (.+))'
	# RUSH(2) // ATK: BLU 15% adv - DEF: OPF // BLU: lkjahdsf9843() // OPF: akwejfaw4jt0295/x, fjasdl4
	# NSECTOR(3) // ATK: BLU OPF IND // BLU: j098jr32/,sadfj( // OPF: 02395jfdsax,35/ // IND: fwj30952,/
	# NSECTOR(3) // ATK: BLU OPF // BLU: jdafls98x)9350()fj, // OPF: /35898gjdkfgx
	if (!($MissionDescription -match $MissionDescriptionPattern)) {
		Write-Host -ForegroundColor Yellow "Mission description validation failed - please double check it's formatted correctly"
		# [void] $NeedToFix.Add("Mission description validation failed - please double check that it's formatted correctly")
		$MissionDescriptionNeedsFixed = $True
	}








	###### WEATHER PARSING ######
	function Show-ResultAsTextBar ([Single] $ValueInPercent) {
		switch ($ValueInPercent) {
			{ $_ -in 0..10 } { return "#---------" }
			{ $_ -in 10..20 } { return "##--------" }
			{ $_ -in 20..30 } { return "###-------" }
			{ $_ -in 30..40 } { return "####------" }
			{ $_ -in 40..50 } { return "#####-----" }
			{ $_ -in 50..60 } { return "######----" }
			{ $_ -in 60..70 } { return "#######---" }
			{ $_ -in 70..80 } { return "########--" }
			{ $_ -in 80..90 } { return "#########-" }
			{ $_ -in 90..100 } { return "##########" }
		}
	}
	<# 
	function Get-WeatherSetting ([String] $SettingName, [String] $Pattern) {
		$t = $FileContentSQM | Select-String -Pattern $Pattern | Select-Object -ExpandProperty Line
		if (!$t) {
			return [PSCustomObject]@{
				"Setting"  = $SettingName -replace '=', '';
				"Severity" = "Not set"
			}
		}
		[String] $t = $t.Trim()
		[Single] $t = ($t -split '=')[1] -replace ';', ''
		$t = [Math]::Floor($t * 100)
		return [PSCustomObject]@{
			"Setting"  = $SettingName -replace '=', '';
			"Severity" = Show-ResultAsTextBar $t
		}
	}
 #>
	function Get-WeatherSetting ([String] $SettingName, [String] $SettingNameRaw) {
		
		$value = [Math]::Floor($SQMJson.Mission.Intel.$SettingNameRaw * 100)
		return [PSCustomObject]@{
			"Setting"  = $SettingName;
			"Severity" = Show-ResultAsTextBar $value;
		}
	}

	[System.Collections.ArrayList] $WeatherStart = @()
	[System.Collections.ArrayList] $WeatherForecast = @()

	# Weather/Overcast Start
	# startWeather
	# [void] $Weather.Add((Get-WeatherSetting 'Weather Start' 'startWeather[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Weather Start' 'startWeather'))

	# Fog Start
	# startFog
	# [void] $Weather.Add((Get-WeatherSetting 'Fog Start' 'startFog[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Fog Start' 'startFog'))
	# Fog Decay Start
	# startFogDecay
	# [void] $Weather.Add((Get-WeatherSetting 'Fog Start' 'startFogDecay[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Fog Decay Start' 'startFogDecay'))
	# Fog Base Start
	# startFogBase
	# [void] $Weather.Add((Get-WeatherSetting 'Fog Base Start' 'startFogBase[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Fog Base Start' 'startFogBase'))
	
	# Wind Start
	# startWind
	# [void] $Weather.Add((Get-WeatherSetting 'Wind Start' 'startWind[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Wind Start' 'startWind'))

	# Rain Start
	# startRain
	# [void] $Weather.Add((Get-WeatherSetting 'Rain Start' 'startRain[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Rain Start' 'startRain'))

	# Rain Start
	# startRain
	# [void] $Weather.Add((Get-WeatherSetting 'Rain Start' 'startRain[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Rain Forced?' 'rainForced'))
	
	# Waves Start
	# startWaves
	# [void] $Weather.Add((Get-WeatherSetting 'Waves Start' 'startWaves[\s]*='))
	[void] $WeatherStart.Add((Get-WeatherSetting 'Waves Start' 'startWaves'))
	

	

	# Weather/Overcast Forecast
	# forecastWeather
	# [void] $Weather.Add((Get-WeatherSetting 'Weather Forecast' 'forecastWeather[\s]*='))
	[void] $WeatherForecast.Add((Get-WeatherSetting 'Weather Forecast' 'forecastWeather'))

	# Fog Forecast
	# forecastFogDecay
	# [void] $Weather.Add((Get-WeatherSetting 'Fog Forecast' 'forecastFogDecay[\s]*='))
	[void] $WeatherForecast.Add((Get-WeatherSetting 'Fog Forecast' 'forecastFogDecay'))

	# Wind Forecast
	# forecastWind
	# [void] $Weather.Add((Get-WeatherSetting 'Wind Forecast' 'forecastWind[\s]*='))
	[void] $WeatherForecast.Add((Get-WeatherSetting 'Wind Forecast' 'forecastWind'))

	# Waves Forecast
	# forecastWaves
	# [void] $Weather.Add((Get-WeatherSetting 'Waves Forecast' 'forecastWaves[\s]*='))
	[void] $WeatherForecast.Add((Get-WeatherSetting 'Waves Forecast' 'forecastWaves'))

	# Lightning Forecast
	# forecastLightnings
	# [void] $Weather.Add((Get-WeatherSetting 'Lightning Forecast' 'forecastLightnings[\s]*='))
	[void] $WeatherForecast.Add((Get-WeatherSetting 'Lightning Forecast' 'forecastLightnings'))









	# Time of mission
	# year
	# month
	# day
	# hour
	# minute



	# Safe Start Zones
	# name="opforSafeMarker";
	# name="bluforSafeMarker";
	# name="indforSafeMarker";


	# neutralSector Zones
	# name="phx_sector1";
	# name="phx_sector2";
	# name="phx_sector3";






	###### UNIT PARSING ######

	$CharlieGolfStdNames = @(
		'MAT Team Leader',
		'Team Leader',
		'Missile Specialist',
		'Asst. Missile Specialist',
		'Rifleman',
		'Vehicle Platoon Leader',
		'Vehicle Commander',
		'Vehicle Driver',
		'Vehicle Gunner',
		'Vehicle Platoon Medic',
		'Vehicle Crewman'
	)
	$CharlieGolfSpecialNames = @(
		'Missile Specialist',
		'Vehicle Platoon Leader',
		'Vehicle Commander'
	)
	$CharlieGolfGroupNames = @(
		'Charlie 2',
		'Golf',
		'Golf 1',
		'Golf 2',
		'Golf 3',
		'Golf 4'
	)

	# Get all units present in the mission & format in role/group (or Spectator)
	[System.Collections.ArrayList] $AllUnits = @()
	[String[]] $AllUnitsRaw = $FileContentSQM | Select-String -Pattern 'description[\s]*=' | Select-Object -ExpandProperty Line
	ForEach ($Unit in $AllUnitsRaw) {
		[String] $Unit = $Unit.Trim()
		$Unit = ($Unit -split '=')[1]
		$Unit = $Unit.Substring(1, $Unit.Length - 2).Trim() -replace '"', ''
		if ($Unit -match '@') {
			$UnitParsed = $Unit -split '@'
			$AllUnits += [PSCustomObject]@{
				"UnitDesc" = $UnitParsed[0];
				"Group"    = $UnitParsed[1];
			}
		} else {
			$AllUnits += [PSCustomObject]@{
				"UnitDesc" = $Unit;
				"Group"    = "";
			}
		}
	}

	# Check to make sure non-default unit descriptions exist in C2 and G groups and if they exist, make sure all are completed
	[System.Collections.ArrayList] $LabeledSpecialUnits = $AllUnits | Where-Object { $_.UnitDesc -notin $CharlieGolfStdNames -and $_.Group -in $CharlieGolfGroupNames } | Sort-Object Group, UnitDesc | Select-Object Group, UnitDesc

	[System.Collections.ArrayList] $NonLabeledSpecialUnits = @()
	ForEach ($Name in $CharlieGolfSpecialNames) {
		[Array] $t = $AllUnits | Where-Object { $_.UnitDesc -match $Name -and $_.UnitDesc -notmatch 'Asst.' -and $_.Group -in $CharlieGolfGroupNames } | Select-Object Group, UnitDesc
		[PSCustomObject] $unit = @{}
		ForEach ($unit in $t) {
			if (!($LabeledSpecialUnits | Where-Object { $_.UnitDesc -eq $unit.UnitDesc })) {
				[void] $NonLabeledSpecialUnits.Add($unit)
			}
		}
	}
	if ($NonLabeledSpecialUnits.Count -gt 1) {
		$NonLabeledSpecialUnits = $NonLabeledSpecialUnits | Sort-Object Group, UnitDesc
	}




	# See if any unit descriptions have been changed.
	# If not, skip other unit processing/messaging.
	# If at least one has been done, check all in case something's missing.
	$NoNamedUnits = $false
	if (!$LabeledSpecialUnits) {
		Write-Host -ForegroundColor Red "No properly-named C2 or GOLF units found!"
		[void] $NeedToFix.Add("No properly-named C2 or GOLF units found!")
		$NoNamedUnits = $true
	}


	if (($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Charlie 2' }).Count -lt 2 -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Missile Specialist in C2 needs role description set"
		# [void] $NeedToFix.Add("Missile Specialist in C2 needs role description set")
	}

	if (!($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Golf' }) -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Vehicle Platoon Leader in Golf Actual needs role description set if being used"
		# [void] $NeedToFix.Add("Vehicle Platoon Leader in Golf Actual needs role description set if being used")
	}
	if (!($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Golf 1' }) -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Vehicle Commander in Golf 1 needs role description set if being used"
		# [void] $NeedToFix.Add("Vehicle Commander in Golf 1 needs role description set if being used")
	}
	if (!($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Golf 2' }) -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Vehicle Commander in Golf 2 needs role description set if being used"
		# [void] $NeedToFix.Add("Vehicle Commander in Golf 2 needs role description set if being used")
	}
	if (!($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Golf 3' }) -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Vehicle Commander in Golf 3 needs role description set if being used"
		# [void] $NeedToFix.Add("Vehicle Commander in Golf 3 needs role description set if being used")
	}
	if (!($LabeledSpecialUnits | Where-Object { $_.Group -eq 'Golf 4' }) -and !$NoNamedUnits) {
		Write-Host -ForegroundColor Yellow "Vehicle Commander in Golf 4 needs role description set if being used"
		# [void] $NeedToFix.Add("Vehicle Commander in Golf 4 needs role description set if being used")
	}









	###### OBJECT NAME PARSING ######
	$FrameworkObjNames = @(
		@('Logic', '^ZoneTrigger'),
		@('Objective', 'Term1'),
		@('Objective', 'Term2'),
		@('Objective', 'Term3'),
		@('Objective', 'phx_sector'),
		@('Objective', 'destroy_obj'),
		@('Objective', 'ctf_flagPole'),
		@('Objective', 'ctf_attackTrig'),
		@('SafeStartZone', 'SafeMarker')
	)


	[System.Collections.ArrayList] $CoreMechanicObjects = @()
	[String[]] $CoreMechanicObjectsRaw = $FileContentSQM | Select-String -Pattern 'name[\s]*=' | Select-Object -ExpandProperty Line
	ForEach ($LineName in $CoreMechanicObjectsRaw) {
		[String] $Line = $LineName.Trim()
		$Line = ($Line -split '=')[1]
		$Line = $Line.Trim() -replace '"', '' -replace ';', ''
		ForEach ($SearchObj in $FrameworkObjNames) {
			if ($Line -match $SearchObj[1]) {
				[void] $CoreMechanicObjects.Add([PSCustomObject]@{
						"Type" = $SearchObj[0];
						"Name" = $Line;
					})
			}
		}
	}

	$CoreMechanicObjects = $CoreMechanicObjects | Sort-Object Type, Name










	###### OBJECT TYPE PARSING ######
	<#
$AllTypes = @(
	@('Structure', '^Land_'),
	@('Structure', 'TK_'),
	@('Structure', '^RoadBarrier'),
	@('Structure', 'CUP'),
	@('Structure', 'Shed'),
	@('Decoration', '^Misc_'),
	@('OpforSoldier', '^O_'),
	@('BluforSoldier', '^B_'),
	@('IndforSoldier', '^I_'),
	@('Logic', '^Module'),
	@('Spectator', '^ace_spectator_virtual'),
	@('MapMarker', '^loc_'),
	@('RHSVehicleUS', '^rhsusf_'),
	@('RHSVehicleRU', '^rhs_'),
	@('RHSVehicleIND', '^rhsgref_'),
	@('RHSVehicleSAF', '^rhssaf_')
)

# Get all "Type" entries and try to match patterns of known object types. Save to AllObjectsRaw
# Send non-matches to AllUnknowns for unique sorting (in case object types exist that haven't been specified)
[System.Collections.ArrayList] $AllObjectsRaw = @()
[System.Collections.ArrayList] $AllUnknowns = @()
$FileContentSQM | Select-String -Pattern '^type[\s]*=' | Select-Object -ExpandProperty Line | ForEach-Object {
	[String] $ThisType = $PSItem.Trim()
	$ThisType = ($ThisType -split '=')[1]
	$ThisType = $ThisType.Substring(1, $ThisType.Length - 2).Trim() -replace '"', ''
	ForEach ($Type in $AllTypes) {
		if ($ThisType -match $Type[1]) {
			[void] $AllObjectsRaw.Add([PSCustomObject]@{
					"Type" = $Type[0];
					"Name" = $ThisType;
				})
		} else {
			[void] $AllUnknowns.Add([PSCustomObject]@{
					"Type" = "Unknown";
					"Name" = $ThisType;
				})
		}
	}
}


# For every one match, there will be 11 other non-matches (since the cycle will check all from $AllTypes).
# Get only unique values from $AllUnknowns so we can look at each instance of item individually.
if ($AllUnknowns.count -gt 1) {
	[System.Collections.ArrayList] $AllUnknowns = $AllUnknowns | Sort-Object -Property Name -Unique
	# Compare unknowns against positive matches. This will eliminate results that were actually matched successfully.
	# We're left with only the objects that truly didn't match any known types, for further improvement of IDing.
	[System.Collections.ArrayList] $UnidentifiedObjects = Compare-Object -ReferenceObject $AllObjectsRaw -DifferenceObject $AllUnknowns -Property Name -PassThru | Where-Object { $_.SideIndicator -eq '=>' }
}



# Get count of how many of each object is the mission for later parsing
[System.Collections.ArrayList] $AllObjectsCounts = $AllObjectsRaw | Group-Object Name | Select-Object -Property @{n = "ObjectType"; e = { $_.Group.Type | Select-Object -First 1 } }, Name, Count | Sort-Object -Property ObjectType, @{e = "Count"; Descending = $True }, Name
#>

	[System.Collections.ArrayList] $AllObjectsRaw = @()
	$FileContentSQM | Select-String -Pattern '^type[\s]*=' | Select-Object -ExpandProperty Line | ForEach-Object {
		[String] $ThisType = $PSItem.Trim()
		$ThisType = ($ThisType -split '=')[1]
		$ThisType = $ThisType.Substring(1, $ThisType.Length - 2).Trim() -replace '"', ''
		[void] $AllObjectsRaw.Add([PSCustomObject]@{
				"ClassName" = $ThisType;
			})
	}


	###### CHECK AGAINST DB ######

	$VehicleSubcategories = @(
		'Anti-Air',
		'APC',
		'APCs',
		'Artillery',
		'Boat',
		'Boats',
		'Car',
		'Cars',
		'Drones',
		'Helicopter',
		'Helicopters',
		'IFV',
		'MRAP',
		'Planes',
		'Submersibles'
		'Tank',
		'Tanks',
		'Truck',
		'Turrets'
	)

	$InfantrySubcategories = @(
		'Infantry',
		'Infantry (Airborne)',
		'Infantry (Airforce)',
		'Infantry (D)',
		'Infantry (Desert)',
		'Infantry (Digital)',
		'Infantry (EMR)',
		'Infantry (EMR-Desert)',
		'Infantry (Flora)',
		'Infantry (LAR)',
		'Infantry (M. Flora)',
		'Infantry (MARSOC)',
		'Infantry (Militia)',
		'Infantry (OEF-CP)',
		'Infantry (OEF-CP/ARB)',
		'Infantry (OSN)',
		'Infantry (Oakleaf)',
		'Infantry (Para)',
		'Infantry (Paramilitary)',
		'Infantry (Recon)',
		'Infantry (SWCC)',
		'Infantry (UCP)',
		'Infantry (UCP/ARB)',
		'Infantry (USASOC)',
		'Infantry (W)',
		'Men',
		'Men (Bandits)',
		'Men (Combat Patrol)',
		'Men (Pacific)',
		'Men (Paramilitary)',
		'Men (Special Forces)',
		'Men (Story)',
		'Men (Urban)',
		'Men (Viper)',
		'Men (Virtual Reality)'
	)


	[System.Collections.ArrayList] $AllVehicles = @()
	[System.Collections.ArrayList] $AllInfantry = @()
	[System.Collections.ArrayList] $AllObjects = @()
	[System.Collections.ArrayList] $AllUnknowns = @()
	ForEach ($Unit in $AllObjectsRaw) {
		# $sqlTest = Invoke-SqliteQuery -DataSource "$($PSCommandPath | Split-Path -Parent)\fnfCfgExportDB.db" -Query "SELECT * from assets where assets.ClassName='$($PSItem.Name) '"
		$assetsDbCheck = Invoke-SqliteQuery -DataSource ".\fnfCfgExportDB.db" -Query "SELECT Classname, Side, Category, Subcategory, Displayname, Weapons from assets where assets.ClassName='$($Unit.ClassName) '"
		ForEach ($Row in $assetsDbCheck) {
			if ($Row.Subcategory.Trim() -in $VehicleSubcategories -and $Row.Category.Trim() -ne 'Wrecks') {
				[void] $AllVehicles.Add($Row)
			} elseif ($Row.Subcategory.Trim() -in $InfantrySubcategories -and $Row.Side.Trim() -ne 'Modules') {
				[void] $AllInfantry.Add($Row)
			} else {
				[void] $AllObjects.Add($Row)
			}
		}
		$emptyDbCheck = Invoke-SqliteQuery -DataSource ".\fnfCfgExportDB.db" -Query "SELECT Classname, Side, Category, Subcategory, Displayname from cfgVehiclesEmpty where ClassName='$($Unit.ClassName) '"
		ForEach ($Row in $emptyDbCheck) {
			if ($Row.Subcategory.Trim() -in $VehicleSubcategories -and $Row.Category.Trim() -ne 'Wrecks') {
				[void] $AllVehicles.Add($Row)
			} elseif ($Row.Subcategory.Trim() -in $InfantrySubcategories -and $Row.Side.Trim() -ne 'Modules') {
				[void] $AllInfantry.Add($Row)
			} else {
				[void] $AllObjects.Add($Row)
			}
		}


		# Put any non matches into own category
		$ErrorActionPreference = "SilentlyContinue"
		if (!($assetsDbCheck -or $emptyDbCheck)) {
			[void] $AllUnknowns.Add($Unit)
		}
		$ErrorActionPreference = "Inquire"
	
	}

	$AllVehiclesGroupedRaw = $AllVehicles | Group-Object -Property Classname
	[System.Collections.ArrayList] $AllVehiclesGrouped = @()
	ForEach ($GroupObj in $AllVehiclesGroupedRaw) {
		[void] $AllVehiclesGrouped.Add((
				[PSCustomObject]@{
					Category    = $GroupObj.Group[0].Category;
					Side        = $GroupObj.Group[0].Side;
					Displayname = $GroupObj.Group[0].DisplayName;
					Count       = $GroupObj.Count
					Subcategory = $GroupObj.Group[0].Subcategory;
					Weapons     = ($GroupObj.Group[0].Weapons -split "`n" | Where-Object { $_ -notmatch 'dummy' -and $_ -notmatch 'fake' }) -join "; ";
				}
			))
	}

	if ($AllVehiclesGrouped.Count -gt 1) {
		$AllVehiclesGrouped = $AllVehiclesGrouped | Sort-Object Side, DisplayName
	}
	$AllVehiclesGroupedBLUFOR = $AllVehiclesGrouped | Where-Object { $_.Side -eq 'BLUFOR ' } | Select-Object Category, DisplayName, Count, Subcategory, Weapons
	$AllVehiclesGroupedOPFOR = $AllVehiclesGrouped | Where-Object { $_.Side -eq 'OPFOR ' } | Select-Object Category, DisplayName, Count, Subcategory, Weapons
	$AllVehiclesGroupedIndependent = $AllVehiclesGrouped | Where-Object { $_.Side -eq 'Independent ' } | Select-Object Category, DisplayName, Count, Subcategory, Weapons
	$AllVehiclesGroupedCivilian = $AllVehiclesGrouped | Where-Object { $_.Side -eq 'Civilian ' } | Select-Object Category, DisplayName, Count, Subcategory, Weapons



	$AllInfantryGroupedRaw = $AllInfantry | Group-Object -Property Classname
	[System.Collections.ArrayList] $AllInfantryGrouped = @()
	ForEach ($GroupObj in $AllInfantryGroupedRaw) {
		[void] $AllInfantryGrouped.Add((
				[PSCustomObject]@{
					Side        = $GroupObj.Group[0].Side;
					Category    = $GroupObj.Group[0].Category;
					Subcategory = $GroupObj.Group[0].Subcategory;
					Displayname = $GroupObj.Group[0].DisplayName;
					Count       = $GroupObj.Count
					# Weapons     = ($GroupObj.Group[0].Weapons -split "`n" | Where-Object { $_ -notmatch 'dummy' }) -join "; ";
				}
			))
	}

	$AllInfantryGrouped = $AllInfantryGrouped | Sort-Object Side, Count, Category, Subcategory




	$AllObjectsGroupedRaw = $AllObjects | Group-Object -Property Classname
	[System.Collections.ArrayList] $AllObjectsGrouped = @()
	ForEach ($GroupObj in $AllObjectsGroupedRaw) {
		[void] $AllObjectsGrouped.Add((
				[PSCustomObject]@{
					Side        = $GroupObj.Group[0].Side;
					Subcategory = $GroupObj.Group[0].Subcategory;
					Category    = $GroupObj.Group[0].Category;
					Displayname = $GroupObj.Group[0].DisplayName;
					Count       = $GroupObj.Count
					# Weapons     = ($GroupObj.Group[0].Weapons -split "`n" | Where-Object { $_ -notmatch 'dummy' }) -join "; ";
				}
			))
	}

	if ($AllObjectsGrouped.Count -gt 1) {
		$AllObjectsGrouped = $AllObjectsGrouped | Sort-Object Subcategory, Category, @{e = 'Count'; Descending = $true }, DisplayName
	}



	$AllUnknownsGroupedRaw = $AllUnknowns | Group-Object -Property Classname
	[System.Collections.ArrayList] $AllUnknownsGrouped = @()
	ForEach ($GroupObj in $AllUnknownsGroupedRaw) {
		[void] $AllUnknownsGrouped.Add((
				[PSCustomObject]@{
					ClassName = $GroupObj.Group[0].ClassName;
					Count     = $GroupObj.Count
					# Weapons     = ($GroupObj.Group[0].Weapons -split "`n" | Where-Object { $_ -notmatch 'dummy' }) -join "; ";
				}
			))
	}

	if ($AllUnknownsGrouped.Count -gt 1) {
		$AllUnknownsGrouped = $AllUnknownsGrouped | Sort-Object Subcategory, @{e = 'Count'; Descending = $true }, DisplayName
	}



	##### MINIMUM OBJECTS REQUIRED #####
	# Check minimum counts for certain objects

	# Check for at least one Zeus module
	[Int] $ZeusCount = ($AllObjects | Where-Object { $_.DisplayName -eq 'Game Master ' } | Measure-Object).Count
	if ($ZeusCount -lt 1) {
		Write-Host -ForegroundColor Yellow "Missing Zeus module -- has it been removed?"
		[void] $NeedToFix.Add("Missing Zeus module -- has it been removed?")
	}

	# Check for at least six spectator slots
	[Int] $SpectatorCount = ($AllObjects | Where-Object { $_.DisplayName -eq 'ACE Spectator ' } | Measure-Object).Count
	if ($SpectatorCount -lt 6) {
		Write-Host -ForegroundColor Yellow "$SpectatorCount Spectator slots present -- less than required 6"
		[void] $NeedToFix.Add("$SpectatorCount Spectator slots present -- less than required 6")
	}





	##### VEHICLE INVENTORY PARSING #####
	[System.Collections.ArrayList] $VehicleInvLinesNotEmpty = @()
	$VehicleInvLines = $FileContentSQM | Select-String -Pattern '^value="\[\[\[\[' | Select-Object -ExpandProperty Line
	$EmptyInvLine = 'value="[[[[],[]],[[],[]],[[],[]],[[],[]]],false]";'
	$AllVehiclesInvEmpty = $true
	[String] $Line = ""
	ForEach ($Line in $VehicleInvLines | Where-Object { $_ -ne $EmptyInvLine }) {
		$AllVehiclesInvEmpty = $false
		[void] $VehicleInvLinesNotEmpty.Add([PSCustomObject]@{"Inventory Init" = $Line })
	}


	##### INIT SCRIPTS PARSING #####
	$NonEmptyInits = $FileContentSQM | Select-String -Pattern '^init[\s]*=[\s]*"(.+)";' | Select-Object @{n = "Init"; e = { $_.Matches.Groups[1] } } | Where-Object { $_ -notmatch '= group this' } | ForEach-Object {
		return [PSCustomObject]@{"InitScript" = ($_.Init -replace '""', '"' -split ';') }
	}
	 







	##### HTML OUTPUT #####
	$HTMLOut = @"
<!DOCTYPE html>
<html>

	<head>
		<style>

			/* The sidenav */
			.sidenav {
				height: 100%;
				width: 220px;
				position: fixed;
				z-index: 1;
				top: 0;
				left: 0;
				background-color: #111;
				overflow-x: hidden;
				padding-top: 20px;

			}

			.sidenav h1 {
				padding: 6px 8px 6px 16px;
				font-weight: bolder;
				text-decoration: none;
				font-size: 30px;
				color: #f1f1f1;
				display: block;
				font-family: 'Open Sans', sans-serif;
			}

			.sidenav a {
				padding: 6px 8px 6px 16px;
				text-decoration: none;
				font-size: 25px;
				color: #818181;
				display: block;
				font-family: 'Open Sans', sans-serif;
			}

			.sidenav a:hover {
				color: #f1f1f1;
			}


			/* Style the buttons that are used to open and close the accordion panel */
			.accordion {
				background-color: #404040;
				color: #ffffff;
				cursor: pointer;
				padding: 18px;
				width: 70%;
				text-align: Center;
				border: 3px solid black;
				outline: none;
				transition: 0.4s;
			}

			/* Add a background color to the button if it is clicked on (add the .active class with JS), and when you move the mouse over it (hover) */
			.active,
			.accordion:hover {
				background-color: #666666;
			}

			/* Style the accordion panel. Note: hidden by default */
			.panel {
				background-color: #404040;
				color: #ffffff;
				cursor: pointer;
				width: 70%;
				text-align: Center;
				margin: auto;
				padding: 18px 0px;
				display: none;
				overflow: hidden;
			}

			body {
				background-color: #262626;
				color: #ffffff;
				font-family: 'Open Sans', sans-serif;
			}

			.centercontent {
				margin-left: 220px;
			}

			.main {
				margin: auto;
				text-align: center;
				width: 90%;
				padding: 0px 10px;
				font-family: 'Open Sans', sans-serif;
			}



			.main h1,
			#missiondesc {
				line-height: 1.5;
				display: inline-block;
				vertical-align: middle;
				background-color: #333333;
				padding: 20px;
				width: 100%;
			}

			.main table {
				margin: auto;
				text-align: center;
				width: auto;
				border: 3px solid black;
				border-collapse: collapse;
				padding: 10px;
			}

			.main th {
				text-align: center;
				border: 3px solid black;
				background-color: #333333;
				padding: 5px;
			}

			.main td {
				text-align: left;
				font-family: monospace;
				border: 2px solid black;
				padding: 2px 10px;
			}

			#initscripts table {
				max-width: 70%;
			}
			
			#initscripts td {
				padding: 10px
			}

			.issuetxt,
			#issuelist li {
				color: #ffa31a;
			}

			.issuebg {
				background-color: #995c00;
			}

			.goodbg {
				background-color: #006600;
			}


			.footer {
				position: fixed;
				left: 0;
				bottom: 0;
				width: 100%;
				background-color: #333333;
				color: white;
				text-align: center;
			}
		</style>
	</head>

	<body>

		$(if ($PSBoundParameters.ContainsKey("MissionNumber")) {
			Write-Output '<div class="sidenav">
			<h1>FNF PLAYLIST</h1>
			<a href="Mission_1.html">EU Mission 1</a>
			<a href="Mission_2.html">EU Mission 2</a>
			<a href="Mission_3.html">EU Mission 3</a>
			<a href="Mission_4.html">NA Mission 1</a>
			<a href="Mission_5.html">NA Mission 2</a>
			<a href="Mission_6.html">NA Mission 3</a>
		</div>'
			Write-Output '<div class="centercontent">'
		})
		

		
			<div class="main">
			<h1 id="title">Mission Analysis for<br>$($MissionName)</h1>

			<h2>Mission Description</h2>
			<h3 id=missiondesc style="font-family:monospace">$MissionDescription</h3>


			<!-- <h2>Issues to Fix</h2>
			<div style='width:50%;margin:auto'>
				<ul id=issuelist style='list-style-type:none;margin:0;line-height:1.5'>
					$(ForEach ($Error in $NeedtoFix) {
					Write-Output "<li>$Error</li>"
					})
				</ul>
			</div> -->



			<h2>Config Settings</h2>
			$($ConfigSettings | ConvertTo-Html -Fragment)


			<h2>Weather Settings</h2>
			$($WeatherStart | ConvertTo-Html -Fragment)
			$($WeatherForecast | ConvertTo-Html -Fragment)

			<br><br>


			$(if ($MissionNameNeedsFixed) {
				Write-Output '<button class="accordion issuebg">Mission Name</button>'
				'<div class="panel">
				<p class=issuetxt>Mission Name requires adjustment to match the standard format.</p>
				<p>Examples</p>
				<p>FNF_JohnDoe_9LivestoLive_destroy_v2_ANY.Altis</p>
				<p>FNF_Johnny_25minutes-to-wait_nsector_v1_EU.Malden</p>
			</div>'
			} else {
				Write-Output '<button class="accordion goodbg">Mission Name</button>'
				Write-Output '<div class="panel">
				<p>Mission Name appears to match the standard format.</p>
			</div>'
			})


			$(if ($MissionDescriptionNeedsFixed) {
				Write-Output '<button class="accordion issuebg">Mission Description</button>'
				'<div class="panel">
				<p class=issuetxt>Mission Description requires adjustment to match the standard format.</p>
				<p>Examples</p>
				<p>Gamemode(x) // ATK: Faction1 X% advantage - DEF: Faction2 // Faction1 assets: // Faction2 assets</p>
				<p>UPLINK(3) // ATK: BLUE 15% advantage - DEF: OPFOR // BLUE: 5x M1151(1xM240, 2xLRAS/M2) 2x Quads, transport // OPFOR: 4x GAZ(2xPKP), 2x Quads, Transport</p>
			</div>'
			} else {
				Write-Output '<button class="accordion goodbg">Mission Description</button>'
				Write-Output '<div class="panel">
				<p>Mission Description appears to match the standard format.</p>
			</div>'
			})


			$(if ($NoNamedUnits) {
			Write-Output '<button class="accordion" style="background-color:#990000">Charlie / Golf Unit Role
				Descriptions</button>'
			} elseif ($NonLabeledSpecialUnits) {
			Write-Output '<button class="accordion issuebg">Charlie / Golf Unit Role
				Descriptions</button>'
			} else {
			Write-Output '<button class="accordion goodbg">Charlie / Golf Unit Role
				Descriptions</button>'
			})
			<div class="panel">
				<h3>Labeled Special Units</h3>
				$($LabeledSpecialUnits | ConvertTo-Html -Fragment)

				$(if ($NonLabeledSpecialUnits) {
				Write-Output "<h3 class=issuetxt>Unlabeled Special Units</h3>"
				Write-Output "<table>"
					Write-Output "<tr>
						<th>Group</th>
						<th>UnitDesc</th>
					</tr>"
					ForEach ($Row in $NonLabeledSpecialUnits) {
					Write-Output "<tr class=issuebg>
						<td>$($Row.Group)</td>
						<td>$($Row.UnitDesc)</td>"
						}
						Write-Output "</table>"
				})

			</div>

			$(if ($ZeusCount -lt 1 -or $SpectatorCount -lt 6) {
			Write-Output '<button class="accordion issuebg">Required Objects</button>'
			} else {
			Write-Output '<button class="accordion goodbg">Required Objects</button>'
			})
			<div class="panel">

				<table>
					<tr>
						<th>Name</th>
						<th>Needed</th>
						<th>Found</th>
					</tr>
					$(if ($SpectatorCount -lt 6) {
					Write-Output '<tr class=issuebg>'
						} else {
						Write-Output '
					<tr class=goodbg>'
						})
						<td>Spectators</td>
						<td>6</td>
						<td>$($SpectatorCount)</td>
					</tr>
					$(if ($ZeusCount -lt 1) {
					Write-Output '<tr class=issuebg>'
						} else {
						Write-Output '
					<tr class=goodbg>'
						})
						<td>Game Master/Zeus Module</td>
						<td>1</td>
						<td>$($ZeusCount)</td>
					</tr>
				</table>

			</div>



			$(if ($CoreMechanicObjects.Count -lt 15) {
			Write-Output '<button class="accordion issuebg">Core Mechanics Objects</button>'
			Write-Output "<div class='panel'>
				<p>Some of the framework's objective objects have been deleted.</p><br>"
				$CoreMechanicObjects | ConvertTo-Html -Fragment
				Write-Output '
			</div>'
			} else {
			Write-Output '<button class="accordion goodbg">Core Mechanics Objects</button>'
			Write-Output "<div class='panel'>
				<p>All framework objective objects are intact.</p><br>"
				$CoreMechanicObjects | ConvertTo-Html -Fragment
				Write-Output '
			</div>'
			})




			$(if ($AllVehiclesEmpty) {
			Write-Output '<button class="accordion issuebg">Vehicle Inventories Empty</button>'
			Write-Output '<div class="panel">
				<p>One or more vehicle inventories are not empty.</p><br>'
				$VehicleInvLinesNotEmpty | Select-Object "Inventory Init" | ConvertTo-Html -Fragment
				Write-Output '
			</div>'
			} else {
			Write-Output '<button class="accordion goodbg">Vehicle Inventories Empty</button>'
			Write-Output '<div class="panel">
				<p>All vehicle inventories are empty.</p>
			</div>'
			})



			$(if ($NonEmptyInits) {
			Write-Output '<button class="accordion">Init Scripts</button>'
			Write-Output '<div class="panel" id=initscripts>'
			Write-Output '<table>'
			ForEach ($script in $NonEmptyInits) {
					Write-Output "<tr><td>$($script.InitScript -join ";<br>")</td></tr>"
				}
			Write-Output '</table>'
			Write-Output '</div>'
			})




			$(
				
				Write-Output "<button class='accordion'>Vehicles ($($AllVehicles.Count))</button>"
			)
			<div class="panel">
				<h3>BLUFOR</h3>
				$($AllVehiclesGroupedBLUFOR | ConvertTo-Html -Fragment)
				<h3>OPFOR</h3>
				$($AllVehiclesGroupedOPFOR | ConvertTo-Html -Fragment)
				<h3>Independent</h3>
				$($AllVehiclesGroupedIndependent | ConvertTo-Html -Fragment)
				<h3>Civilian</h3>
				$($AllVehiclesGroupedCivilian | ConvertTo-Html -Fragment)

			</div>


			$(
				Write-Output "<button class='accordion'>Soldiers ($($AllInfantry.Count))</button>"
			)
			<div class="panel">

				$($AllInfantryGrouped | ConvertTo-Html -Fragment)


			</div>




			$(
				Write-Output "<button class='accordion'>Logic Objects ($(($AllObjects | Where-Object {$_.Side -eq 'Modules '}).Count))</button>"
			)
			<div class="panel">

				$($AllObjectsGrouped | Where-Object {$_.Side -eq 'Modules '} | ConvertTo-Html -Fragment)
			</div>


			$(
				Write-Output "<button class='accordion'>Map Markers ($(($AllUnknowns  | Where-Object {$_.ClassName -match '^loc_'}).Count))</button>"
			)
			<div class="panel">

				$($AllUnknowns  | Where-Object {$_.ClassName -match '^loc_'} |
				ConvertTo-Html -Fragment)


			</div>



			$(
				Write-Output "<button class='accordion'>Structures and Decorations ($(($AllObjects  | Where-Object {$_.Side -ne 'Modules '}).Count))</button>"
			)
			<div class="panel">

				$($AllObjectsGrouped | Where-Object {$_.Side -ne 'Modules '} | ConvertTo-Html -Fragment)
			</div>



			<button class="accordion">Unknown Objects</button>
			<div class="panel">
				$($AllUnknownsGrouped | ConvertTo-Html -Fragment)
			</div>

		</div>
		$(if ($PSBoundParameters.ContainsKey("MissionNumber")) {
			Write-Output '</div>'
		})

		<br>
		<br>
		<br>
		<br>

		<div class="footer">
			<p>Content generated using Powershell and SQLite. Contact Indigo#6290 on Discord for more.</p>
		</div>
		


		<script>
			var acc = document.getElementsByClassName("accordion");
			var i;

			for (i = 0; i < acc.length; i++) {
				acc[i].addEventListener("click", function () {
					/* Toggle between adding and removing the "active" class,
					to highlight the button that controls the panel */
					this.classList.toggle("active");

					/* Toggle between hiding and showing the active panel */
					var panel = this.nextElementSibling;
					if (panel.style.display === "block") {
						panel.style.display = "none";
					} else {
						panel.style.display = "block";
					}
				});
			}
		</script>
	</body>

</html>
"@

	if ($PSBoundParameters.ContainsKey("MissionNumber")) {
		$HTMLOut | Out-File ".\Mission_$($MissionNumber).html"
	} else {
		$HTMLOut | Out-File ".\Summary_$($MissionName).html"
	}

}


function Out-IndexFile {
	$IndexHTMLOut = @"

<!DOCTYPE html>
<html>

	<head>
		<style>

			/* The sidenav */
			.sidenav {
				height: 100%;
				width: 220px;
				position: fixed;
				z-index: 1;
				top: 0;
				left: 0;
				background-color: #111;
				overflow-x: hidden;
				padding-top: 20px;

			}

			.sidenav h1 {
				padding: 6px 8px 6px 16px;
				font-weight: bolder;
				text-decoration: none;
				font-size: 30px;
				color: #f1f1f1;
				display: block;
				font-family: 'Open Sans', sans-serif;
			}

			.sidenav a {
				padding: 6px 8px 6px 16px;
				text-decoration: none;
				font-size: 25px;
				color: #818181;
				display: block;
				font-family: 'Open Sans', sans-serif;
			}

			.sidenav a:hover {
				color: #f1f1f1;
			}


			/* Style the buttons that are used to open and close the accordion panel */
			.accordion {
				background-color: #404040;
				color: #ffffff;
				cursor: pointer;
				padding: 18px;
				width: 70%;
				text-align: Center;
				border: 3px solid black;
				outline: none;
				transition: 0.4s;
			}

			/* Add a background color to the button if it is clicked on (add the .active class with JS), and when you move the mouse over it (hover) */
			.active,
			.accordion:hover {
				background-color: #666666;
			}

			/* Style the accordion panel. Note: hidden by default */
			.panel {
				background-color: #404040;
				color: #ffffff;
				cursor: pointer;
				width: 70%;
				text-align: Center;
				margin: auto;
				padding: 18px 0px;
				display: none;
				overflow: hidden;
			}

			body {
				background-color: #262626;
				color: #ffffff;
				font-family: 'Open Sans', sans-serif;
			}

			.centercontent {
				margin-left: 220px;
			}

			.main {
				margin: auto;
				text-align: center;
				width: 90%;
				padding: 0px 10px;
				font-family: 'Open Sans', sans-serif;
			}



			.main h1,
			#missiondesc {
				line-height: 1.5;
				display: inline-block;
				vertical-align: middle;
				background-color: #333333;
				padding: 20px;
				width: 100%;
			}

			.main table {
				margin: auto;
				text-align: center;
				width: auto;
				border: 3px solid black;
				border-collapse: collapse;
				padding: 10px;
			}

			.main th {
				text-align: center;
				border: 3px solid black;
				background-color: #333333;
				padding: 5px;
			}

			.main td {
				text-align: left;
				font-family: monospace;
				border: 2px solid black;
				padding: 2px 10px;
			}

			.issuetxt,
			#issuelist li {
				color: #ffa31a;
			}

			.issuebg {
				background-color: #995c00;
			}

			.goodbg {
				background-color: #006600;
			}


			.footer {
				position: fixed;
				left: 0;
				bottom: 0;
				width: 100%;
				background-color: #333333;
				color: white;
				text-align: center;
			}
		</style>
	</head>

	<body>


		<div class="sidenav">
			<h1>FNF PLAYLIST</h1>
			<a href="Mission_1.html">EU Mission 1</a>
			<a href="Mission_2.html">EU Mission 2</a>
			<a href="Mission_3.html">EU Mission 3</a>
			<a href="Mission_4.html">NA Mission 1</a>
			<a href="Mission_5.html">NA Mission 2</a>
			<a href="Mission_6.html">NA Mission 3</a>
		</div>

		<div class="centercontent">
		<div class=main>
			<h1 id="title">Playlist Generated $(Get-Date)</h1>

			<p>Use the navbar on the left to view mission details.</p>

		</div>
		</div>

		<div class="footer">
			<p>Script populated by parseMissionSqm.ps1. Contact Indigo#6290 on Discord for more.</p>
		</div>

	</body>

</html>
"@

	$IndexHTMLOut | Out-File ".\index.html" -Force
}


#####################################################################
#                            PROCESS
#####################################################################


[System.Collections.ArrayList] $NeedToFix = @()

$ErrorActionPreference = "Inquire"

$Version = ($PSCommandPath -split 'v')[-1] -replace '.ps1', ''

$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Gray"
$Host.UI.RawUI.WindowTitle = "FNF Mission Analyzer v$Version"
Clear-Host


Install-Module PSSQLite -Scope CurrentUser
Import-Module PSSQLite


#####################################################################

$ProcessingChoice = $Host.UI.PromptForChoice(
	"SINGLE OR MULTI PROCESS",
	"You can place this file and the .db into a directory containing multiple missions to process.
You'll be prompted to select missions, in order, up to 6.
This is useful for generating a playlist of browseable summaries.

Would you like to process one mission or multiple missions?

",
	@("&Single", "&Multi", "&Exit"),
	-1
)


switch ($ProcessingChoice) {
	0 {
		Write-Host
		$FilePathSQM = (Read-Host -Prompt "Path of mission.sqm to analyze") -replace '"', ''
		Clear-Host

		Out-Mission -SQMPathToParse $FilePathSQM

		exit
	}

	1 {
		Out-IndexFile
		$MultiSQMPathsRaw = Get-ChildItem -Recurse -File -Filter '*.sqm' | Select-Object -ExpandProperty FullName

		$MultiSQMPaths = ForEach ($SQMPath in $MultiSQMPathsRaw) {
			((Get-Item $sqmpath).DirectoryName -split '\\')[-1]
		}

		for ($i = 1; $i -lt 7; $i++) {

			$Choice = New-Menu -MenuTitle "Select mission $i" -MenuOptions $MultiSQMPaths -Columns 1 -MaximumColumnWidth 80
		
			Out-Mission -SQMPathToParse $MultiSQMPathsRaw[($Choice)] -MissionNumber $i
		}

		exit
	}


	2 { exit }
}


#####################################################################






# SIG # Begin signature block
# MIIR5QYJKoZIhvcNAQcCoIIR1jCCEdICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5hEW7jxz6MJRIdqCt8l0AZzf
# 64Kggg1QMIIDFTCCAf2gAwIBAgIQarNwqALG/45HOA0xJfnsbTANBgkqhkiG9w0B
# AQsFADAWMRQwEgYDVQQDDAtJbmRpZ28jNjI5MDAeFw0yMTAzMTIxMDM4MThaFw0y
# MjAzMTIxMDU4MThaMBYxFDASBgNVBAMMC0luZGlnbyM2MjkwMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2qAtyT1uulJIAYesEd816AT3/QQb/J5rxx9m
# ZWrrFXZNWDPCk887fgSRerI6pBwuq5oA7IP7llwEOZjkEo3EiZu1iqztNOwbV4MJ
# v/Nd0MpqWHOOAATimBawUAhF+cKoKWQ7teLEEaVT4LQsNVR7WKptSv5xfTjXKbej
# Dv94XALj9T4CMlpyFsFNG9F4WyQ1dXOrNVcqZipjT2CmEuIQKTUUkPtOxgpfKWwu
# t7VgDdUwH7+A98Rju3Mtdvjcvv3WCc8OI17/0o0BYuVHhFAidD+aS7qXFFY5dHT+
# WXqa6zEcv7ZnxqEoBan/I05dJ8UG70NW56rce5nW1u4AgayHPQIDAQABo18wXTAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwFwYDVR0RBBAwDoIM
# aW5kaWZveC5pbmZvMB0GA1UdDgQWBBTFGaHldHGIj5xmmUwhJRWZ+eJ+tzANBgkq
# hkiG9w0BAQsFAAOCAQEA1Het5C1AOE8jsiOD2QPsGS0ajsizu1oAE1tadRj57ePA
# fTa0odJZXqSF+3Ch79ccPIHDq3BqFMOluiPTo0lR0iqPRXH5gdnfsQVuLZZvbjaq
# STtP6fQKj1cNAF+QatEieqG/QudW7k8nEG23sg1r+swvTjsSe+dKncnHNesXWdg3
# uwe7yeulrqG/q8tilDzNyJIOHpxOmcEURBp+14VQTVnAxloib/wC8g1YT5t9RJUy
# Qh6PoiBSnW4oPwhvw5LhSaKFXCGcIrY2CSl0NJtRmnzX+VG+S84Qlij6t0u61K/c
# TAzfbBODVKEpQeS+LSq6yMymTX2M9xxsDZj0qfgECjCCBP4wggPmoAMCAQICEA1C
# SuC+Ooj/YEAhzhQA8N0wDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
# MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBD
# QTAeFw0yMTAxMDEwMDAwMDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGlt
# ZXN0YW1wIDIwMjEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGE
# Z8WK9Q0IpEXKY2tR1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0V
# kWJauP9nC5xj/TZqgfop+N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTG
# dnY6U9HR01o2j8aj4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm
# 3dOPL1e1hyDrDo4s1SPa9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYj
# U/aNY+gaq1uxHTDCm2mCtNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6f
# egFz+BnW/g1JhL0BAgMBAAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0T
# AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCG
# SAGG/WwHATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9D
# UFMwHwYDVR0jBBgwFoAU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZE
# ho6kurBmvrwoLR1ENt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUH
# AQEEeTB3MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYI
# KwYBBQUHMAKGQ2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNI
# QTJBc3N1cmVkSURUaW1lc3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEB
# AEgc3LXpmiO85xrnIA6OZ0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDR
# BMOG2Tu9/kQCZk3taaQP9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuH
# okYDTvz0/rdkd2NfI1Jpg4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1
# Yfx1CAB2vIEO+MDhXM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7Lf
# ySmoc0NR2r1j1h9bm/cuG08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+
# p7SOZ3j5NpjhyyjaW4emii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IV
# MA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lD
# ZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcx
# MjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIg
# QXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC90DLuS82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2
# oPSNs4jkl79jIZCYvxO8V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYa
# VX4LJ37AovWg4N4iPw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvg
# zyIQD3XPcXJOCq3fQDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5W
# YScpiYRR5oLnRlD9lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3W
# Te8GQv2iUypPhR3EHTyvz9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4E
# FgQU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGL
# p6chnfNtyA8wEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEG
# A1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4Bgpg
# hkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNv
# bS9DUFMwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v
# 3dp8qmN6s3jPBjdAhO9LhL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+Cei
# Zr8JqmDfdqQ6kw/4stHYfBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8
# ZOUfSBAYX4k4YU1iRiSHY4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nh
# iaj1a5bA9FhpDXzIAbG5KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCb
# ugwtK22ixH67xCUrRwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JK
# ldj1po5SMYID/zCCA/sCAQEwKjAWMRQwEgYDVQQDDAtJbmRpZ28jNjI5MAIQarNw
# qALG/45HOA0xJfnsbTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAA
# oQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4w
# DAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUA2MNcrXFywWTHZyTJAFgvehO
# JsUwDQYJKoZIhvcNAQEBBQAEggEAMVHqb1IZdb2kzLwbiaW/iIqhgPtaskcNx5BH
# lhDs1gsQ9MxNFRv1NjxmcEIzbBDM6l+Ps79kAPr+Ro+v5qtMVcRkxmtOLevjn7Dl
# 6ZCNrY+OfLGe6zNVZ0fYRwXUySJ7FleVucvuH2senmnwFbLLUzLLHYur+gxiBE20
# 1I5+FnFjschqFFtP0rDpBYMzBoSmv+QRorzBny0ar9zC64GBninzUhxWNm4SgW4H
# /X0iJGkg4mP8OqKH72XBYqOjNm6DW+H+NskcjNNdSXxRF7w2j8SC2GRfU+zQDG9h
# IzouJUWBbbLeyCZMknaRNpVJiLBlAP5fP82m2FSS3Cpzs+Dv2qGCAjAwggIsBgkq
# hkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBAhANQkrg
# vjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqG
# SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEwMzI2MDIzNjQ5WjAvBgkqhkiG9w0B
# CQQxIgQgJZooB6c3pKEdJM4iirsIZPwwAR0biVE4y9GvM0Z2pO8wDQYJKoZIhvcN
# AQEBBQAEggEAcPwIiB3NFQeyW00IaYxTVtHzg/89/BzFCkErcHD8xKy3nlGyK5B0
# NYHEnltk1JkZosn/blqLCqGpThxSeetBQoEjlxjrXUhCnNY2YP7JkLQ8zdENcd8b
# oJC+v8upS4rGYraWRYPcJtxdoPO+/pwL9+mSbr/LlYszSEKmuo5U6uNFrus9XuEm
# 0zkWwS7XyIaaKZgByNejqGUswF0T1jfr/EvCcGHVrWjKSc0VEsb7wArP3QsRJ1gs
# pf7Yu1R0LBIrv36HChDYEEjUmA3/zcnWAWmeoReOmLKnX5MVJbh07t/NM9mHrbB/
# WQWxaPX2pSL4W+75LJLPy1qIMx6rcWWF2g==
# SIG # End signature block
