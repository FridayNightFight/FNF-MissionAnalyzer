// Get soldier info
// roleDescription can't be gathered in SP, but AI aren't present in MP
// focusing SP

private _output = [
            "className",
            "displayName",
            "objectType",
            "roleDescription",
            "faction",
            "side",
            "init"
        ] joinString '^';
"debug_console"
callExtension(_output + "~0000");

{
    if ((_x call BIS_fnc_objectType select 0) == "Soldier") then {
        private["_configName", "_class", "_dispName", "_mod", "_maxLift", "_author", "_cat", "_fac", "_side", "_dlc", "_vc", "_totalSeats", "_crewSeats", "_cargoSeats", "_nonFFVcargoSeats", "_ffvCargoSeats"];
        _configName = configOf _x;
        _class = configName _configName;
        _dispName = getText(_configName >> 'displayName');
        _objType = (_x call BIS_fnc_objectType) select 1;
        _roleDescription = (_x get3DENAttribute "description") select 0;
        // _author = getText(_configName >> 'author');
        // _cat = getText(_configName >> 'category');
        _fac = getText(_configName >> 'faction');
        _side = [getNumber(_configName >> 'side')] call BIS_fnc_sideName;
        // _dlc = getText(_configName >> 'dlc');
        _init = (_x get3DENAttribute "Init") select 0;
        private _output = [
            _class,
            _dispName,
            _objType,
            _roleDescription,
            // _author,
            // _cat,
            _fac,
            _side,
            // _dlc
            _init
        ] joinString '^';
        "debug_console"
        callExtension(_output + "~0000");
    }
}
forEach (all3DENEntities # 0);
"debug_console"
callExtension("X");