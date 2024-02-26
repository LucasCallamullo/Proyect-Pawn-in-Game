// Rattler - Use Rattler's tail to create shockwave to deflect weapon damages

/* CVARS

//Rattler
rattler_level 0
rattler_dmgreturn 0.02 //Try to keep it between 0.09 and 0.02 otherwise it will either be too high or too low.

*/

/*

Version History:

1.0 - First version

2.0 - Removed key down, now it is constant.

2.1 - Fixed minor bugs, polished code thanks to vittu.

*/

#include <superheromod>

//Global Variables
new gHeroID
new gHeroName[]="Rattler"
new bool:gHasRattlerPower[SH_MAXSLOTS+1]
new gPlayerLevels[SH_MAXSLOTS+1]
new gSpriteLightning, gPcvarDamage

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob"
}

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Rattler","2.1","DuPeR/Rockell")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("rattler_level", "4" )
	gPcvarDamage	= register_cvar("rattler_dmgreturn", "0.04" )

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Escudo Eléctrico.", "Obtén un Escudo Eléctrico, que descargará daño en tus enemigos según tu nivel.")
 
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_event("Damage", "rattler_damage", "b", "2!0")

	// LEVELS
	register_srvcmd("rattler_levels", "rattler_levels")
	shRegLevels(gHeroName,"rattler_levels")

}

public plugin_precache()
	gSpriteLightning = precache_model("sprites/lgtning.spr")
//------------------------------------------------------------------------------------------------
//					INIT y SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasRattlerPower[id] = true
			}
			case SH_HERO_DROP: {
				gHasRattlerPower[id] = false
			}
		} 
	
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
}

public rattler_levels()
{
	new id[5]
	new lev[5]

	read_argv(1,id,4)
	read_argv(2,lev,4)

	gPlayerLevels[str_to_num(id)] = str_to_num(lev)
}

public rattler_damage(id)
{
	if ( !shModActive() || !is_user_connected(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return
	
	// For check if has the other power
	static hero_id = sh_get_hero_id(gOthers_Heros[0])
	if ( sh_user_has_hero(id, hero_id) ) return
	
	if ( gHasRattlerPower[id] && is_user_alive(attacker) && id != attacker ) {
		// do extra damage
		new returnDamage = floatround( ( gPlayerLevels[id] * get_pcvar_float(gPcvarDamage) ) * damage )
		if (returnDamage > 0)
		{
			sh_extra_damage(attacker, id, returnDamage, "Rattler shockwave force field")

			new iRed,iGreen,iBlue,iWidth,iNoise
			iRed = random_num(0,100)
			iGreen = random_num(0,100)
			iBlue = random_num(100,255)
			iWidth = random_num(10,40)
			iNoise = random_num(10,40)

			if(iRed > iBlue) iBlue = (iRed + 10)
			if(iGreen > iBlue) iBlue = (iGreen + 10)
			if(iBlue > 255) iBlue = 255

			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( 8 )
			write_short(id)	// start entity
			write_short(attacker)	// entity
			write_short(gSpriteLightning )	// model
			write_byte( 0 ) // starting frame
			write_byte( 15 )  // frame rate
			write_byte( 10 )  // life
			write_byte( iWidth )  // line width
			write_byte( iNoise )  // noise amplitude
			write_byte( iRed )	// r, g, b
			write_byte( iGreen )	// r, g, b
			write_byte( iBlue )	// r, g, b
			write_byte( 255 )	// brightness
			write_byte( 0 )	// scroll speed
			message_end()
		}

	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/