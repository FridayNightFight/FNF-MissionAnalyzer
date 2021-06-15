_this forceAddUniform phx_loadout_uniform;
_this addVest phx_loadout_vest;
_this addBackpack phx_loadout_backpack;
_this addHeadgear phx_loadout_headgear;
removeGoggles _this;

//Remove the radio that is created in some backpacks
[{"ItemRadio" in items _this},{_this removeItem "ItemRadio"}, [], 5] call CBA_fnc_waitUntilAndExecute;
