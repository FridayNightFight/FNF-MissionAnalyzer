// Get asset info
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
        _configName = configOf _x;
        _class = configName _configName;
        _dispName = getText(_configName >> 'displayName');
        _objType = (_x call BIS_fnc_objectType) select 1;
        _locked = locked _x;
        _init = [_configName >> "EventHandlers", "init", ""] call BIS_fnc_returnConfigEntry;
        _mod = configSourceMod _configName;
        _author = getText(_configName >> 'author');
        _cat = getText(_configName >> 'category');
        _fac = getText(_configName >> 'faction');
        _side = [getNumber(_configName >> 'side')] call BIS_fnc_sideName;
        _dlc = getText(_configName >> 'dlc');
        _vc = getText(_configName >> 'vehicleClass');
        _weapons = weapons _x;
        _ammo = magazinesAmmo _x;
        _cargoWep = weaponCargo _x;
        _cargoWepAcc = weaponsItemsCargo _x;
        _cargoMag = magazineCargo _x;
        _cargoItem = itemCargo _x;
        _cargoBackpack = backpackCargo _x;
        _totalSeats = [configName _configName, true] call BIS_fnc_crewCount; // Number of total seats: crew + non-FFV cargo/passengers + FFV cargo/passengers
        _crewSeats = [configName _configName, false] call BIS_fnc_crewCount; // Number of crew seats only
        _cargoSeats = _totalSeats - _crewSeats; // Number of total cargo/passenger seats: non-FFV + FFV
        _nonFFVcargoSeats = getNumber(_configName >> "transportSoldier"); // Number of non-FFV cargo seats only
        _ffvCargoSeats = _cargoSeats - _nonFFVcargoSeats; // Number of FFV cargo seats only
        private _output = format["%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|%12|%13|%14|%15|%16|%17|%18|%19|%20|%21|%22",
            _class,
            _dispName,
            _objType,
            _mod,
            _locked,
            _author,
            _cat,
            _fac,
            _side,
            _dlc,
            _vc,
            _weapons,
            _ammo,
            _cargoWep,
            _cargoWepAcc,
            _cargoMag,
            _cargoItem,
            _cargoBackpack,
            _totalSeats,
            _crewSeats,
            _cargoSeats,
            _nonFFVcargoSeats,
            _ffvCargoSeats
        ];
        "debug_console"
        callExtension(_output + "~0000");
    };
}
forEach allMissionObjects "";
"debug_console"
callExtension("X");