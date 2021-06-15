params ["_action"];

_applyConfigLoadouts = {
	// apply loadouts defined in config
	{
		if (_x isKindOf "CAManBase") then 
		{
			_x call compile preprocessFileLineNumbers "config.sqf"; 
			_x call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_initLoadout.sqf"; 
			_x call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_setLoadout.sqf";  

			save3DENInventory [_x]; 
		};
	} forEach all3DENEntities # 0;
};

_cleanGroundObjs = {
	// delete any backpacks or items that were dropped during loadout changes
	{
		if ( 
			_x isKindOf "ThingX" || 
			_x isKindOf "WeaponHolder" || 
			_x isKindOf "groundWeaponHolder" 
		) then {deleteVehicle _x}; 
	} forEach allMissionObjects "";
};

_stripUnits = {
	{ // strip all units
		if (_x isKindOf "CAManBase") then 
		{
			removeAllItems _x;
			removeAllWeapons _x;
			removeUniform _x;
			removeVest _x;
			removeBackpack _x;
			removeHeadgear _x;
			removeGoggles _x;

			save3DENInventory [_x]; 
		};
	} forEach all3DENEntities # 0;
};

_previewLoadouts = {
	call _applyConfigLoadouts;
	call _cleanGroundObjs;
};

_removeLoadouts = {
	call _stripUnits;
	call _cleanGroundObjs;
};

if (_action) then {
	call _previewLoadouts;
} else {
	call _removeLoadouts;
};