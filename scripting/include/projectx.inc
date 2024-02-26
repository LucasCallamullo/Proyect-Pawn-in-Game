#if defined _projectx_included
  #endinput
#endif
#define _projectx_included

//Change dmg amount taken on player
native projectx_change_dmgtaken(index, Float:dmg = 2.0);

//Returns 1 if is using dmgtaken
native projectx_is_using_dmgtaken(index);

//Change dmg doing by a player
native projectx_changedmg(index, Float:dmg = 2.0);

//Returns 1 if used changedmg
native projectx_is_using_changedmg(index);
