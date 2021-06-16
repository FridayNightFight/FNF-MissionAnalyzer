BEGIN {
	# Starting path
	$StartPath = (Get-Location).Path

	# Check if local App Data dir exists; create if not
	if (!(Test-Path "$env:LOCALAPPDATA\FNFMissionAnalyzer")) {
		New-Item -Path "$env:LOCALAPPDATA\FNFMissionAnalyzer" -ItemType Directory | Out-Null
	}


	# Arma installation path, once found, is stored in Windows profile to save time on future runs

	$ArmaInstallPath = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -EQ "Arma 3" | Select-Object -ExpandProperty InstallLocation

	if (!$ArmaInstallPath -or !(Test-Path $ArmaInstallPath)) {

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
	}

	if (!(Test-Path $ArmaInstallPath)) {
		Write-Host "Failed to locate Arma 3 directory. Please update the file path in the opened file. . ."
		Start-Sleep 2
		Invoke-Item "$env:LOCALAPPDATA\FNFMissionAnalyzer\ArmaPath.txt"
		Pause
		exit
	}



	# Change to the Arma root folder to process our debug log files
	New-PSDrive -Name "A3InstallPath" -PSProvider FileSystem -Root $ArmaInstallPath
	# Set-Location $ArmaInstallPath



	# Parse the file contents exported from in-game
	[Array] $Files = Get-ChildItem -Path "A3InstallPath:" -File -Filter "debug_console_x64_*.txt" | ForEach-Object FullName
	if ($Files.Count -lt 4) {
		Write-Host "Less than 4 files located with exported data. Please try rerunning the process."
		Pause
		exit
	}
	if ($Files.count -gt 4) { $Files = $Files | Select-Object -Last 4 };



	[Array] $ExportedData = @()
}

PROCESS {
	$Files | ForEach-Object { $ExportedData += (Import-Csv $PSItem -Delimiter '^') }



	$MissionInfo = $ExportedData | Where-Object { $PSItem.gameMode }
	$Weather = $ExportedData | Where-Object { $PSItem.overcast }
	$Soldiers = $ExportedData | Where-Object { $PSItem.roleDescription }
	$Vehicles = $ExportedData | Where-Object { $PSItem.totalSeats }


	Set-Location $StartPath


	$Output = @{
		"Mission Info" = $MissionInfo;
		"Weather Info" = $Weather;
		"Soldier Info" = $Soldiers;
		"Vehicle Info" = $Vehicles;
	} | ConvertTo-Json -Depth 15

	$output > 'text.json'




	$PreContent = @"
<head>
<style>
	body {
		background-color: #262626;
		color: #ffffff;
		font-family: 'Open Sans', sans-serif;
	}

	h2 {
		text-align: center;
	}

	table {
		margin: auto;
		text-align: center;
		width: auto;
		border: 3px solid black;
		border-collapse: collapse;
		padding: 10px;
		max-width: 50%;
	}

	th {
		text-align: center;
		border: 3px solid black;
		background-color: #333333;
		padding: 5px;
	}

	td {
		text-align: left;
		font-family: monospace;
		border: 2px solid black;
		padding: 2px 10px;
	}
</style>
</head>
"@



	$Output = @"
	$($PreContent)
	<h2>Mission Info</h2>
	$($MissionInfo | ConvertTo-Html -Fragment -As List)
	<h2>Weather Info</h2>
	$($Weather | ConvertTo-Html -Fragment -As List)
	<h2>Soldier Info</h2>
	$($Soldiers | ConvertTo-Html -Fragment)
	<h2>Vehicle Info (Condensed)</h2>
	$($Vehicles | Group-Object dispName, side | ForEach-Object {
			[PSCustomObject]@{
				"Side"          = $PSItem.Group[0].side;
				"DisplayName"   = $PSItem.Group[0].dispName;
				"ObjectType"    = $PSItem.Group[0].objType;
				"Count"         = $PSItem.Count;
				"Locked"        = $PSItem.Group[0].locked;
				"TotalSeats"    = $PSItem.Group[0].totalSeats;
			}
		} | Sort-Object Locked, Side, ObjectType, Count, DisplayName | ConvertTo-Html  -Fragment)
	<h2>Vehicle Info</h2>
	$($Vehicles | ConvertTo-Html -Fragment)
"@
	$output > 'page.html'


} 

END {
	$Files | ForEach-Object { Remove-Item $PSItem }
	Remove-PSDrive "A3InstallPath"
}
