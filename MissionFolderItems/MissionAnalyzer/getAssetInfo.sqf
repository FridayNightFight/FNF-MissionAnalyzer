// Get asset info

_header = [
    "class",
    "dispName",
    "objType",
    // "mod",
    "locked",
    // "author",
    // "cat",
    // "fac",
    "side",
    "dlc",
    // "vc",
    "init",
    // "weapons",
    // "ammo",
    // "cargoWep",
    // "cargoWepAcc",
    // "cargoMag",
    // "cargoItem",
    // "cargoBackpack",
    "totalSeats",
    "crewSeats",
    "cargoSeats",
    "nonFFVcargoSeats",
    "ffvCargoSeats"
] joinString '^';
"debug_console"
        callExtension(_header + "~0000");



{
    if ((_x call BIS_fnc_objectType select 0) == "Vehicle") then {
        private[
            "_configName",
            "_class",
            "_dispName",
            "_objType",
            "_locked",
            "_init",
            "_mod",
            "_author",
            "_cat",
            "_fac",
            "_side",
            "_dlc",
            "_vc",
            "_weapons",
            "_ammo",
            "_cargoWep",
            "_cargoWepAcc",
            "_cargoMag",
            "_cargoItem",
            "_cargoBackpack",
            "_totalSeats",
            "_crewSeats",
            "_cargoSeats",
            "_nonFFVcargoSeats",
            "_ffvCargoSeats"
        ];
        _obj = _x;
        _configName = configOf _x;
        _class = configName _configName;
        _dispName = getText(_configName >> 'displayName');
        _objType = (_x call BIS_fnc_objectType) select 1;
        _locked = locked _x;


        _init = str((_x get3DENAttribute "Init") select 0);

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

        _init = [_init, '
        ', ''] call PX_fnc_stringReplace;



        _mod = configSourceMod _configName;
        _author = getText(_configName >> 'author');
        _cat = getText(_configName >> 'category');
        _fac = getText(_configName >> 'faction');
        _side = [getNumber(_configName >> 'side')] call BIS_fnc_sideName;
        _dlc = getText(_configName >> 'dlc');
        _vc = getText(_configName >> 'vehicleClass');
        _weapons = weapons _x;


// get mags, ammo, and count of each instance
_className = typeOf _x;
_outArr = [];

_turrets = [typeOf _obj] call BIS_fnc_allTurrets;
_turrets pushBack [-1];
_mags = [];

{
    _turretPath = _x;
    private _turretConfig = [_className, _turretPath] call BIS_fnc_turretConfig;
    private _turretDisplayName = [_turretConfig] call BIS_fnc_displayName;
    // private _weps = [_turretConfig, "weapons"] call BIS_fnc_returnConfigEntry;
    private _weps = _obj weaponsTurret _turretPath;
    _turretMags = _obj magazinesTurret _turretPath;
    _thisTurretWepsAmmo = [];
    {
        private _thisWepDetails = [];

        private _wepConfig = [configFile >> "CfgWeapons" >> _x] call BIS_fnc_getCfg;
        private _wepClassName = configName _wepConfig;
        private _wepDisplayName = [_wepConfig] call BIS_fnc_displayName;
        private _compatMags = [_wepConfig, true] call CBA_fnc_compatibleMagazines;

        {
            // "debug_console" callExtension (str _magCount + "#0100");
            _thisMag = _x;
            private _magConfig = (configFile >> "CfgMagazines" >> _thisMag);
            private _magName = [(_magConfig >> "displayName"), "STRING", "Magazine"] call CBA_fnc_getConfigEntry;
            private _magClass = configName _magConfig;
            private _magAmmo = _obj magazineTurretAmmo [_thisMag, _turretPath];

            if (_magName isEqualTo "") then {_magName = "Magazine"};
            
            _thisWepDetails pushBack [
                _magName,
                _magClass,
                _magAmmo
            ];
        } forEach _turretMags;

        _validMags = (_thisWepDetails select {(_x # 1) in _compatMags}) call BIS_fnc_consolidateArray;


        _validMagsJSON = [];
        {
            _validMagsJSON pushBack text format['"%2": {
                "magName": "%1",
                "magClass": "%2",
                "magAmmo": %3,
                "magCount": %4
            }',
                _x # 0 # 0,
                _x # 0 # 1,
                _x # 0 # 2,
                _x # 1
            ];
        } forEach _validMags;
        
        _thisTurretWepsAmmo pushBack text format['"%1" : {
            "displayName" : "%1",
            "className": "%2",
            "magazines": {%3}
            }',
            _wepDisplayName,
            _wepClassName,
            _validMagsJSON joinString ","
        ];

    } forEach _weps;
    

    _outArr pushBack text format['
        "Turret Path %1 ''%2''" : {
            %3
        }',
    _turretPath,
    _turretDisplayName,
    _thisTurretWepsAmmo joinString ","
    ];

} forEach _turrets;
_ammo = str ("{" + (_outArr joinString ",") + "}");


        // _ammo = (magazinesAllTurrets _x) apply {format ["%1,"]}) call BIS_fnc_consolidateArray;
        _cargoWep = (weaponCargo _x) call BIS_fnc_consolidateArray;
        _cargoWepAcc = (weaponsItemsCargo _x) call BIS_fnc_consolidateArray;
        _cargoMag = (magazineCargo _x) call BIS_fnc_consolidateArray;
        _cargoItem = (itemCargo _x) call BIS_fnc_consolidateArray;
        _cargoBackpack = (backpackCargo _x) call BIS_fnc_consolidateArray;
        _totalSeats = [configName _configName, true] call BIS_fnc_crewCount; // Number of total seats: crew + non-FFV cargo/passengers + FFV cargo/passengers
        _crewSeats = [configName _configName, false] call BIS_fnc_crewCount; // Number of crew seats only
        _cargoSeats = _totalSeats - _crewSeats; // Number of total cargo/passenger seats: non-FFV + FFV
        _nonFFVcargoSeats = getNumber(_configName >> "transportSoldier"); // Number of non-FFV cargo seats only
        _ffvCargoSeats = _cargoSeats - _nonFFVcargoSeats; // Number of FFV cargo seats only
        private _output = [
            _class,
            _dispName,
            _objType,
            // _mod,
            _locked,
            // _author,
            // _cat,
            // _fac,
            _side,
            _dlc,
            // _vc,
            _init,
            // _weapons,
            // _ammo,
            // _cargoWep,
            // _cargoWepAcc,
            // _cargoMag,
            // _cargoItem,
            // _cargoBackpack,
            _totalSeats,
            _crewSeats,
            _cargoSeats,
            _nonFFVcargoSeats,
            _ffvCargoSeats
        ] joinString '^';
        "debug_console"
        callExtension(_output + "~0000");
    };
}
forEach (all3DENEntities # 0);
"debug_console"
callExtension("X");