private [
    "_author",
    "_missionName",
    "_missionNameSource",
    "_missionDesc",
    "_lobbyText",
    "_gameMode",
    "_defender",
    "_attacker",
    "_independentAllegiance",
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

call compile preprocessFileLineNumbers 'config.sqf';


_header = [
    "missionNameSource",
    "missionName",
    "missionDesc",
    "author",
    "lobbyText",
    "gameMode",
    "defender",
    "attacker",
    "independentAllegiance",
    "bluUniform",
    "opfUniform",
    "indUniform",
    "bluWeapons",
    "opfWeapons",
    "indWeapons",
    "bluAT",
    "opfAT",
    "indAT",
    "magOptics",
    "addNVG",
    "fortifyEnabled",
    "fortifyPoints",
    "startVisible",
    "maxViewDistance"
] joinString '^';
"debug_console"
callExtension(_header + "~0000");



_missionName = getMissionConfigValue "onLoadName";
_missionNameSource = missionNameSource;
_missionDesc = getMissionConfigValue "onLoadMission";
_author = getMissionConfigValue "author";
_lobbyText = "Multiplayer" get3DENMissionAttribute "IntelOverviewText";
_gameMode = phx_gameMode;
_defender = phx_defendingSide;
_attacker = phx_attackingSide;
_independentAllegiance = "Scenario" get3DENMissionAttribute "IntelIndepAllegiance";
_bluUniform = phx_bluforUniform;
_opfUniform = phx_opforUniform;
_indUniform = phx_indforUniform;
_bluWeapons = phx_bluforWeapons;
_opfWeapons = phx_opforWeapons;
_indWeapons = phx_indforWeapons;
if (
    !isNil "phx_bluAT" &&
    !isNil "phx_redAT" &&
    !isNil "phx_grnAT" &&
    !isNil "phx_magnifiedOptics" &&
    !isNil "phx_addNVG"
) then {
    _bluAT = phx_bluAT;
    _opfAT = phx_redAT;
    _indAT = phx_grnAT;
    _magOptics = phx_magnifiedOptics;
    _addNVG = phx_addNVG;
} else {
    _bluAT = "n/a";
    _opfAT = "n/a";
    _indAT = "n/a";
    _magOptics = "n/a";
    _addNVG = "n/a";
};
_fortifyEnabled = phx_allowFortify;
_fortifyPoints = phx_fortifyPoints;
_startVisible = phx_enemyStartVisible;
_maxViewDistance = phx_maxViewDistance;

private _output = [
    _missionNameSource,
    _missionName,
    _missionDesc,
    _author,
    _lobbyText,
    _gameMode,
    _defender,
    _attacker,
    _independentAllegiance,
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
] joinString '^';

PX_fnc_stringReplace = {
	params["_str", "_find", "_replace"];
	
	private _return = "";
	private _len = count _find;	
	private _pos = _str find _find;

	while {(_pos != -1) && (count _str > 0)} do {
		_return = _return + (_str select [0, _pos]) + _replace;
		
		_str = (_str select [_pos+_len]);
		_pos = _str find _find;
	};	
	_return + _str;
};

_endOut = [_output, '%', 'PCT'] call PX_fnc_stringReplace;

"debug_console"
callExtension(_endOut + "~0000");
"debug_console"
callExtension("X");