$StartDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# Get mission config, description, etc params
$FilePathSQM = "$StartDir\mission.sqm"
$FilePathConfig = "$StartDir\config.sqf"



# Get file contents
$FileContentSQM = (Get-Content $FilePathSQM).Trim()
$FileContentConfig = (Get-Content $FilePathConfig).Trim()

# Write as UTF8 No BOM
[System.IO.File]::WriteAllLines(
	$FilePathSQM,
	(Get-Content $FilePathSQM | Out-String))

	
# Remove prefix added by Mikero's derapping tools
$VersionLine = Get-Content $FilePathSQM | Select-String -Pattern '^version[\s]{0,1}=[\s]{0,1}[\d]{1,3};$' | Select-Object -ExpandProperty Line
if ($VersionLine) {
	$VersionLinePos = (Get-Content $FilePathSQM).IndexOf($VersionLine)
	if ($VersionLinePos -gt 0) {
		# Write as UTF8 No BOM
		[System.IO.File]::WriteAllLines(
			$FilePathSQM,
			((Get-Content $FilePathSQM)[$VersionLinePos..$FileContentSQM.Length] | Out-String))
	}
}

# Make sure python is installed
try {
	$PyVer = python -V
	$PyVer = [Regex]::Matches($PyVer, '(\d).(\d).(\d)')
	if ($PyVer.Groups[1].Value -lt 3 -or ($Pyver.Groups[1].Value -eq 3 -and $PyVer.Groups[2].Value -lt 4)) {
		Write-Warning "Python version is $(python -V), less than the required 3.4+."
		Pause
		exit
	}
} catch {
	Write-Warning "Python 3.4+ not installed, exiting..."
	Pause
	exit
}
# run python parser utility
if ($null -ne (pip show armaclass)) {
	Write-Debug "armaclass package already installed"
} else {
	pip install armaclass
}

python parseSqm.py $FilePathSQM
if ($LASTEXITCODE -ne 0) {
	Write-Warning "Failed to parse the SQM file. Please ensure it hasn't been manually modified and is unbinarized. You will not see the lobby text on the summary page until this is done."
	Pause
} else {
	$SQMJson = Get-Content ".\sqmjson.txt" | ConvertFrom-Json
	Start-Sleep 1
	Remove-Item ".\sqmjson.txt" -Force

	[String] $LobbyText = $SQMJson.Mission.Intel.overviewText
}


	















# Check if local App Data dir exists; create if not
if (!(Test-Path "$env:LOCALAPPDATA\FNFMissionAnalyzer")) {
	New-Item -Path "$env:LOCALAPPDATA\FNFMissionAnalyzer" -ItemType Directory | Out-Null
}
# Arma installation path, once found, is stored in Windows profile to save time on future runs
if (!(Test-Path "$env:LOCALAPPDATA\FNFMissionAnalyzer\ArmaPath.txt")) {
	Write-Progress -Activity "First run: Finding Arma 3 path. . ."

	$SearchLocations = @("${env:ProgramFiles}\Steam", "${env:ProgramFiles(x86)}\Steam")
	$SearchLocations += Get-PSDrive -PSProvider FileSystem | ForEach-Object Root | Get-ChildItem -Filter '*steam*' -Directory -EA SilentlyContinue | ForEach-Object FullName
	$ArmaInstallPath = ForEach ($Root in $SearchLocations) {
		Get-ChildItem $Root -Filter "Arma 3" -Directory -Recurse -EA SilentlyContinue | ForEach-Object FullName
	}
	$ArmaInstallPath > "$env:LOCALAPPDATA\FNFMissionAnalyzer\ArmaPath.txt"
} else {
	$ArmaInstallPath = Get-Content "$env:LOCALAPPDATA\FNFMissionAnalyzer\ArmaPath.txt" | Select-Object -First 1
}


# Change to the Arma root folder to process our debug log files
Set-Location $ArmaInstallPath

# Parse the file contents exported from in-game
[Array] $Files = Get-ChildItem -File -Filter "debug_console_x64_*.txt" | ForEach-Object Name


$MissionInfo = Get-Content $Files[0] | ConvertFrom-Csv -Delimiter '|' -Header @(
	"missionNameSource",
	"missionName",
	"missionDesc",
	"author",
	# "lobbyText",
	"gameMode",
	"defender",
	"attacker",
	"isIndFriendlywBlu?",
	"isIndFriendlywOpf",
	"bluUniform",
	"opfUniform",
	"indUniform",
	"bluWeapons",
	"opfWeapons",
	"indWeapons",
	"bluAT",
	"opfAT",
	"indAT",
	"magnifiedOptics",
	"NVGs",
	"fortifyEnabled",
	"fortifyPoints",
	"startVisible",
	"maxViewDistance"
)



$Weather = Get-Content $Files[1] | ConvertFrom-Csv -Delimiter '|' -Header @(
	"date",
	"time",
	"viewDistance",
	"overcast",
	"overcastForecast",
	"fog",
	"fogForecast",
	"rain",
	"humidity",
	"windDir",
	"windStr",
	"gusts"
)



$Soldiers = Get-Content $Files[2] | ConvertFrom-Csv -Delimiter '|' -Header @(
	"class",
	"displayName",
	"objType",
	"author",
	"category",
	"faction",
	"side",
	"dlc"
)
$SoldiersBySide = $Soldiers | Group-Object Side | Sort-Object name
$SoldiersByTypeBLU = $Soldiers | Where-Object { $_.Side -eq 'BLUFOR' } | Group-Object DisplayName | Sort-Object name
$SoldiersByTypeOPF = $Soldiers | Where-Object { $_.Side -eq 'OPFOR' } | Group-Object DisplayName | Sort-Object name
$SoldiersByTypeGUER = $Soldiers | Where-Object { $_.Side -eq 'Independent' } | Group-Object DisplayName | Sort-Object name
$SoldiersByTypeCIV = $Soldiers | Where-Object { $_.Side -eq 'Civilian' } | Group-Object DisplayName | Sort-Object name
$SoldiersByTypeLogic = $Soldiers | Where-Object { $_.Side -eq 'Game Logic' } | Group-Object DisplayName | Sort-Object name


$Vehicles = Get-Content $Files[3] | ConvertFrom-Csv -Delimiter '|' -Header @(
	"class",
	"dispName",
	"objType",
	"mod",
	"locked",
	"author",
	"cat",
	"fac",
	"side",
	"dlc",
	"vc",
	"init",
	"weapons",
	"ammo",
	"cargoWep",
	"cargoWepAcc",
	"cargoMag",
	"cargoItem",
	"cargoBackpack",
	"totalSeats",
	"crewSeats",
	"cargoSeats",
	"nonFFVcargoSeats",
	"ffvCargoSeats"
)

ForEach ($Vehicle in $Vehicles) {

	$Vehicle.weapons = ($Vehicle.weapons | ConvertFrom-Json) -join ' | '


	[Array] $AmmoRaw = $vehicle.ammo | ConvertFrom-Json | ForEach-Object SyncRoot
	[Array] $Ammo = @()
	if ($AmmoRaw.Count -ne 2) {
		ForEach ($Magazine in $AmmoRaw) {
			$Ammo += [PSCustomObject]@{
				"Type"       = $Magazine[0];
				"RoundCount" = $Magazine[1];
			}
		}
		$AmmoGrouped = $Ammo | Group-Object "Type", "RoundCount"
		[Array] $AmmoOut = @()
		ForEach ($Type in $AmmoGrouped) {
			$AmmoOut += ($Type.Name + " (x" + $Type.Count + ")")
		}
		$Vehicle.Ammo = [String]::join(' | ', $AmmoOut)
	} else {
		$Ammo += [PSCustomObject]@{
			"Type"       = $AmmoRaw[0];
			"RoundCount" = $AmmoRaw[1];
		}
		$AmmoGrouped = $Ammo | Group-Object "Type", "RoundCount"
		[Array] $AmmoOut = @()
		ForEach ($Type in $AmmoGrouped) {
			$AmmoOut += ($Type.Name + " (x" + $Type.Count + ")")
		}
		$Vehicle.Ammo = [String]::join(' | ', $AmmoOut)
	}
}

# Clear the log files
Get-ChildItem -File -Filter "debug_console_x64_*.txt" | ForEach-Object Name | Remove-Item





# Output to webpage

@"
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
				max-width: 90%;
				text-align: Center;
				margin: auto;
				padding: 18px 0px;
				display: none;
				overflow: auto;
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
			<h1 id="title">Mission Analysis for<br>$($MissionInfo.missionNameSource)</h1>

			<h2>Mission Description</h2>
			<h3 id=missiondesc style="font-family:monospace">$($LobbyText)</h3>
			<br><br>
			
			$(
				Write-Output "<h2 style='color:#FFA500;'>$($MissionInfo.gameMode.ToUpper())</h2>"
				if ($MissionInfo.gameMode -notin @("neutralSector","connection")) {
					Write-Output "<h2>$($MissionInfo.attacker) attacking $($MissionInfo.defender)</h2>"
				}
				Write-Output "<h3>Players participating:</h3>"
				$SoldiersBySide | Select-Object Name, Count | ConvertTo-Html -Fragment
			)
			
			<br><br>


			<!-- <h2>Issues to Fix</h2>
			<div style='width:50%;margin:auto'>
				<ul id=issuelist style='list-style-type:none;margin:0;line-height:1.5'>
					$(ForEach ($Error in $NeedtoFix) {
					Write-Output "<li>$Error</li>"
					})
				</ul>
			</div> -->

			<h2>Config Settings</h2>
			$($MissionInfo | ConvertTo-Html -Fragment -As List)


			<h2>Weather Settings</h2>
			$(
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
				$Weather.overcast = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.overcast * 100)
				$Weather.overcastForecast = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.overcastForecast * 100)
				$Weather.fog = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.fog * 100)
				$Weather.fogForecast = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.fogForecast * 100)
				$Weather.rain = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.rain * 100)
				$Weather.humidity = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.humidity * 100)
				$Weather.windDir = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.windDir * 100)
				$Weather.windStr = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.windStr * 100)
				$Weather.gusts = Show-ResultAsTextBar -ValueInPercent ([double]$Weather.gusts * 100)
				$Weather | ConvertTo-Html -Fragment -As List
			)

			<br><br>


			<h2>Name and Description</h2>

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



			<h2>Units and Assets</h2>

			$(<# if (!$AllVehiclesEmpty) {
					Write-Output '<button class="accordion issuebg">Vehicle Inventories Empty</button>'
					Write-Output '<div class="panel">
					<p>One or more vehicle inventories are not empty.</p><br>'
					$VehicleInvLinesNotEmpty | ConvertTo-Html -Fragment
					Write-Output '</div>'
				} else {
					Write-Output '<button class="accordion goodbg">Vehicle Inventories Empty</button>'
					Write-Output '<div class="panel">
						<p>All vehicle inventories are empty.</p>
					</div>'
			} #>)



			$(
				
				Write-Output "<button class='accordion'>Vehicles ($($Vehicles.Count))</button>"
			)
			<div class="panel">
				<h3>Vehicles</h3>
				<p style="font-style:italic;">Locked vehicles at the bottom, value 2 or higher</p>
				$($Vehicles | Group-Object dispName, side | ForEach-Object {
					[PSCustomObject]@{
						"Side"          = $PSItem.Group[0].side;
						"Faction"       = $PSItem.Group[0].fac;
						"DisplayName"   = $PSItem.Group[0].dispName;
						"ObjectType"    = $PSItem.Group[0].objType;
						"Count"         = $PSItem.Count;
						"Locked"        = $PSItem.Group[0].locked;
						"TotalSeats"    = $PSItem.Group[0].totalSeats;
						"Weapons"       = $PSItem.Group[0].weapons;
						"Ammo"          = $PSItem.Group[0].ammo;
						"Init" = $PSItem.Group[0].init;
						"cargoWep"      = $PSItem.Group[0].cargoWep;
						"CargoWepAcc"   = $PSItem.Group[0].cargoWepAcc;
						"CargoMag"      = $PSItem.Group[0].cargoMag;
						"CargoItem"     = $PSItem.Group[0].cargoItem;
						"CargoBackpack" = $PSItem.Group[0].cargoBackpack;
					}
				} | Sort-Object Locked, Side, ObjectType, Count, DisplayName | ConvertTo-Html  -Fragment)
				<br>
			</div>


			$(
				Write-Output "<button class='accordion'>Slots ($($Soldiers.Count))</button>"
			)
			<div class="panel">
				<h3>BLUFOR</h3>
				$($SoldiersByTypeBLU | Select-Object Name, Count | ConvertTo-Html -Fragment)
				<br>
				<h3>OPFOR</h3>
				$($SoldiersByTypeOPF | Select-Object Name, Count | ConvertTo-Html -Fragment)
				<br>
				<h3>INDFOR</h3>
				$($SoldiersByTypeGUER | Select-Object Name, Count | ConvertTo-Html -Fragment)
				<br>
				<h3>CIV</h3>
				$($SoldiersByTypeCIV | Select-Object Name, Count | ConvertTo-Html -Fragment)
				<br>
				<h3>LOGIC</h3>
				$($SoldiersByTypeLogic | Select-Object Name, Count | ConvertTo-Html -Fragment)


			</div>





			<h2>Logic / Triggers / Markers</h2>

			$(if ($MissingCoreMechanicsObjs.count -gt 0) {
			Write-Output "<button class='accordion issuebg'>Required Game Objects (Missing $($MissingCoreMechanicsObjs.count))</button>"
			Write-Output '<div class="panel">'
			Write-Output '<h3 class=issuetxt>Missing Game Objects</h3>'
			Write-Output '<h4>The following missing items can be ignored:</h4>'
			Write-Output '<p>Safe Start markers for non-playing factions</p>
				<p>Terminal 3 in 2-terminal game modes</p>
			'

				$($MissingCoreMechanicsObjs | ConvertTo-Html -Fragment)

			Write-Output '</div>'
			} else {
			Write-Output '<button class="accordion goodbg">Required Objects</button>'
			Write-Output '<div class="panel">'
			Write-Output '<h3>Missing Game Objects</h3>'
			Write-Output '<p>All required game objects present.</p>'
			Write-Output '</div>'
			})
			


			$(
				Write-Output "<button class='accordion'>Logic Objects ($(($LogicObjs).Count))</button>"
			)
			<div class="panel">

				$($LogicObjs | Select-Object type, name | ConvertTo-Html -Fragment)
			</div>

			$(
				Write-Output "<button class='accordion'>Trigger Objects ($(($TriggerObjs).Count))</button>"
			)
			<div class="panel">

				$($TriggerObjs | Select-Object name | ConvertTo-Html -Fragment)
			</div>

			$(
				Write-Output "<button class='accordion'>Marker Objects ($(($MarkerObjs).Count))</button>"
			)
			<div class="panel">

				$($MarkerObjs | Select-Object type, name | ConvertTo-Html -Fragment)
			</div>





			<h2>Other Information</h2>


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
				Write-Output "<button class='accordion'>Structures and Decorations ($($AllStructures.Count))</button>"
			)
			<div class="panel">

				$($AllStructuresGrouped | ConvertTo-Html -Fragment)
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
"@  | Out-File "$StartDir\$($MissionInfo.missionName).html" -Force

<# 
$(
	$MissionInfo | ConvertTo-Html -Fragment -As List
	$Weather | ConvertTo-Html -Fragment -As List
	$SoldiersBySide | Select-Object Name, Count | ConvertTo-Html -Fragment -As List
	# $SoldiersByTypeBLU | Select-Object Name, Count | ConvertTo-Html -Fragment
	# $SoldiersByTypeOPF | Select-Object Name, Count | ConvertTo-Html -Fragment
	# $SoldiersByTypeGUER | Select-Object Name, Count | ConvertTo-Html -Fragment
	# $SoldiersByTypeCIV | Select-Object Name, Count | ConvertTo-Html -Fragment
	$Vehicles | Group-Object dispName, side | ForEach-Object {
		[PSCustomObject]@{
			"Side"          = $PSItem.Group[0].side;
			"Faction"       = $PSItem.Group[0].fac;
			"DisplayName"   = $PSItem.Group[0].dispName;
			"ObjectType"    = $PSItem.Group[0].objType;
			"Count"         = $PSItem.Count;
			"Locked"        = $PSItem.Group[0].locked;
			"TotalSeats"    = $PSItem.Group[0].totalSeats;
			"Weapons"       = $PSItem.Group[0].weapons;
			"Ammo"          = $PSItem.Group[0].ammo;
			"cargoWep"      = $PSItem.Group[0].cargoWep;
			"CargoWepAcc"   = $PSItem.Group[0].cargoWepAcc;
			"CargoMag"      = $PSItem.Group[0].cargoMag;
			"CargoItem"     = $PSItem.Group[0].cargoItem;
			"CargoBackpack" = $PSItem.Group[0].cargoBackpack;
		}
	} | Sort-Object Locked, Side, ObjectType, Count, DisplayName | ConvertTo-Html  -Fragment
)
#>
