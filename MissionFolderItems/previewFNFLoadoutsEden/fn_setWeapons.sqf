switch (([_this] call BIS_fnc_objectSide)) do {
  case east: {pWeapons = phx_opforWeapons};
  case west: {pWeapons = phx_bluforWeapons};
  case independent: {pWeapons = phx_indforWeapons};
};

_incStr = "client\loadout\weapons\" + pWeapons + ".sqf";
call compile preprocessFileLineNumbers _incStr;

if (!isNil "ROLE_AT" && !isNil "ROLE_AAT") then {
  if (pRole in [ROLE_AT,ROLE_AAT]) then {
    _this call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_setMAT.sqf";
  }; //set the MAT weapon and AAT ammo class
};
if (!isNil "phx_loadout_hasUGL") then {
  if (phx_loadout_hasUGL) then {
    call compile preprocessFileLineNumbers "previewFNFLoadoutsEden\fn_setUGLAmmo.sqf";
    }; //set which ugl ammo type is needed
}