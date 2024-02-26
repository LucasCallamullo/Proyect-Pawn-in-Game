/* CVARS - copy and paste to shconfig.cfg

// Achilles
achilles_level 8     - level at which he becomes available
achilles_dmgmult 3.0 - multiplier of the damage he takes in the left leg; set to 100 for instant death

//All credit must go to Mydas for dreaming him up and creating the hero
*
* V2.1 - Mydas 4/29/2008, revisiting old heroes
*   Changed the way users are informed of certain things ** most important - Achilles' death (from "Achilles' Heel" to the name of attacker's weapon)
*	The users are no longer informed each round but each time a player gets or drops Achilles
*   Removed CVAR achilles_inform, it's useless

* V2.0 - Burcyril10 12/8/2005
*	Fixed a logic bug: the hitzones MUST be set AFTER the round has started (hence the timer) - don't ask why, no idea pure fluke i caught the bug
*	Cleaned up code, commented it
*	Inserted the 'inform' cvar - not being told your opponent was very unfair especialy if you don't have anubis.
*		- Note: It only tells you at the start of the round their name it doesn't say it over their head or anything overly lame
*	Tested for about 3 weeks, found optimal cvar settings.
*	Note: Achilles's body is only bullet proof - nades, knives and powers work exactly the same (I left it that way because Achilles is balanced enough)

* V1.0 - Mydas 2005
*	THE HERO IS BORN...
*/

#include <superheromod>

// VARIABLES 
new gHeroID
new const gHeroName[] = "Achilles" 
new bool:gHasAchillesPower[SH_MAXSLOTS + 1] 
new gPcvarDamage
//------------------------------------------------------------------------------------------------
//					INIT's							//
//------------------------------------------------------------------------------------------------
public plugin_init() 
{
	// Plugin Info
	register_plugin("SUPERHERO Achilles", "2.1", "Mydas/Burcyril10") 

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("achilles_level", "8" )
	gPcvarDamage	= register_cvar("achilles_dmgmult", "3.0") 
  
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Inmortalidad Parcial.", "La destreza de un gran guerrero, las balas solo podrán impactarte en la pierna izq./cabeza pero causan más daño!")
  
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	debugMessage("Intentando crear el H�roe de Aquiles")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS) INIT 
	register_event("Damage", "achilles_damage", "b","2!0")
} 

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	switch(mode) {
		case SH_HERO_ADD: {
			gHasAchillesPower[id] = true
			//Since they have the power make it so that they only have left leg hitzone active (THIS DOES NOT INCLUDE KNIVES OR NADES)
			set_user_hitzones(0, id, 64)
			set_user_hitzones(0, id, 2)
			set_user_hitzones(0, id, 128)
			set_user_info(id, "ACHI", "1")
		}
		case SH_HERO_DROP: {
			gHasAchillesPower[id] = false
			//they don't have achilles, let them be hit everywhere
			set_user_hitzones(0, id, 255)
			set_user_info(id,"ACHI","0")
		}
	}
}
//------------------------------------------------------------------------------------------------
//				DMAGE  AND SPAWN						//
//------------------------------------------------------------------------------------------------
public achilles_damage(id) 
{
	if ( !shModActive() || !is_user_alive(id) ) return
	
	//Get all the required information
	new damage = read_data(2)
  	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	
	// Agregado
	if ( !(attacker <= attacker <= SH_MAXSLOTS) || !is_user_alive(attacker) ) return 

	//Calcuate extra damage - inflict it
	if ( gHasAchillesPower[id] ) {
	
		new extradamage = floatround(damage * get_pcvar_float(gPcvarDamage) - damage)
		new wpnid, clip, ammo, wpn[32] = "fall/explosion"	// default the weapon name to an neutral source of damage
	
		wpnid = get_user_weapon(attacker, clip, ammo)
		if (wpnid > 0) get_weaponname(wpnid,wpn,31) 		// if a weapon was used, the weapon name is used
	
		replace(wpn, 31, "weapon_", "" )
		sh_extra_damage( id, attacker, extradamage, wpn) 
	}
}

public sh_client_spawn(id)
{
	if ( gHasAchillesPower[id] ) {
		set_user_hitzones(0, id, 128)
	   	set_user_hitzones(0, id, 64);
		set_user_hitzones(0, id, 2)
		}
	else	{
		set_user_hitzones(0, id, 255)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
