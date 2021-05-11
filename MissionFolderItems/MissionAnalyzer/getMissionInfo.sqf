private[
    "_author",
    "_missionName",
    "_missionNameSource",
    "_missionDesc",
    // "_lobbyText",
    "_gameMode",
    "_defender",
    "_attacker",
    "_indepAlliedBlu",
    "_indepAlliedOpf",
    "_bluUniform",
    "_opfUniform",
    "_indUniform",
    "_bluWeapons",
    "_opfWeapons",
    "_indWeapons",
    "_bluAT",
    "_opfAT",
    "_indAT",
    "_magOptics",
    "_addNVG",
    "_fortifyEnabled",
    "_fortifyPoints",
    "_startVisible",
    "_maxViewDistance"
];

_missionName = getMissionConfigValue "onLoadName";
_missionNameSource = missionNameSource;
_missionDesc = getMissionConfigValue "onLoadMission";
_author = getMissionConfigValue "author";
// _lobbyText = gettext (missionconfigfile >> "missionsqm" >> "mission" >> "intel" >> "overviewtext");
_gameMode = phx_gameMode;
_defender = phx_defendingSide;
_attacker = phx_attackingSide;
_indepAlliedBlu = str([west, resistance] call BIS_fnc_sideIsFriendly) + str([resistance, west] call BIS_fnc_sideisFriendly);
_indepAlliedOpf = str([east, resistance] call BIS_fnc_sideIsFriendly) + str([resistance, east] call BIS_fnc_sideisFriendly);
_bluUniform = phx_bluforUniform;
_opfUniform = phx_opforUniform;
_indUniform = phx_indforUniform;
_bluWeapons = phx_bluforWeapons;
_opfWeapons = phx_opforWeapons;
_indWeapons = phx_indforWeapons;
_bluAT = phx_bluAT;
_opfAT = phx_redAT;
_indAT = phx_grnAT;
_magOptics = phx_magnifiedOptics;
_addNVG = phx_addNVG;
_fortifyEnabled = phx_allowFortify;
_fortifyPoints = phx_fortifyPoints;
_startVisible = phx_enemyStartVisible;
_maxViewDistance = phx_maxViewDistance;

private _output = [
    _missionNameSource,
    _missionName,
    _missionDesc,
    _author,
    // _lobbyText,
    _gameMode,
    _defender,
    _attacker,
    _indepAlliedBlu,
    _indepAlliedOpf,
    _bluUniform,
    _opfUniform,
    _indUniform,
    _bluWeapons,
    _opfWeapons,
    _indWeapons,
    _bluAT,
    _opfAT,
    _indAT,
    _magOptics,
    _addNVG,
    _fortifyEnabled,
    _fortifyPoints,
    _startVisible,
    _maxViewDistance
] joinString '|';
"debug_console"
callExtension(_output + "~0000");
"debug_console"
callExtension("X");