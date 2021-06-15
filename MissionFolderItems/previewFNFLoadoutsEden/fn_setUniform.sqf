phx_loadout_lrRadio = "";
// "debug_console" callExtension (str ([_this] call BIS_fnc_objectSide) + "#1111");

if (isClass (configFile >> "CfgVehicles" >> "B_LIB_GER_Radio")) then {
  switch (([_this] call BIS_fnc_objectSide)) do {
    case east: {pUniform = phx_opforUniform; phx_loadout_lrRadio = "B_LIB_SOV_RA_Radio"};
    case west: {pUniform = phx_bluforUniform; phx_loadout_lrRadio = "B_LIB_GER_Radio"};
    case independent: {pUniform = phx_indforUniform; phx_loadout_lrRadio = "B_LIB_US_Radio"};
  };
};
if (isClass (configFile >> "CfgVehicles" >> "TFAR_rt1523g_black")) then {
  switch (([_this] call BIS_fnc_objectSide)) do {
    case east: {pUniform = phx_opforUniform; phx_loadout_lrRadio = "TFAR_mr3000_rhs"};
    case west: {pUniform = phx_bluforUniform; phx_loadout_lrRadio = "TFAR_rt1523g_black"};
    case independent: {pUniform = phx_indforUniform; phx_loadout_lrRadio = "TFAR_anprc155_coyote"};
  };
};


_incStr = "client\loadout\uniforms\" + pUniform + ".sqf";
call compile preprocessFileLineNumbers _incStr;

if (pRole in [ROLE_PL,ROLE_SL,ROLE_TL,ROLE_MGTL]) then {phx_loadout_backpack = phx_loadout_lrRadio};
if (pRole == ROLE_CR && ((leader group _this) == _this)) then {
  phx_loadout_backpack = phx_loadout_lrRadio;
};
