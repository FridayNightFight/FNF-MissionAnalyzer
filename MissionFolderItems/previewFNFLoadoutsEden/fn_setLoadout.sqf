// if (pRole == ROLE_CIV) exitWith {phx_loadoutAssigned = true};

_this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_addUniform.sqf"; 
// _this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_addItems.sqf"; 
// _this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_addMagazines.sqf"; 
_this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_addWeapons.sqf"; 
//call phx_fnc_giveNVG;
_this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_setAttributes.sqf"; 

//player linkItem "ItemRadio";
//player linkItem "ItemGPS";
_this linkItem "ItemCompass";
_this linkItem "ItemWatch";
//player linkItem "TFAR_microdagr";

if (phx_loadout_unitLevel > 0) then {
  //player addItem "ACE_microDAGR";
};

// missionNamespace setVariable ["phx_loadoutAssigned",true];
