_this addWeapon phx_loadout_rifle_weapon;
_this addWeapon phx_loadout_sidearm_weapon;

switch (pRole) do {
  case ROLE_RAT: {_this addWeapon phx_loadout_antitank_weapon};
  case ROLE_AT: {
      _this addWeapon phx_loadout_mediumantitank_weapon;
      _this addSecondaryWeaponItem phx_loadout_mediumantitank_optic;
  };
  case ROLE_MK: {_this addPrimaryWeaponItem phx_loadout_rifle_optic};
};
