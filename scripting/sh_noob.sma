// Noob! - Exploding Arrows (Bullets from Desert Eagle)

/* CVARS - copy and paste to shconfig.cfg

//Noob
noob_level 1
noob_arrows 2	//How many arrows does he get each round
noob_maxlevel 7	//Max level allowed to use this power

*/

/*
*   Noob hero with a max level cvar.
*
*   Hero created by AssKicR.
*   Thanks to JTP10181 for the max level part.
*/

//---------- User Changeable Defines --------//
// Note: If you change anything here from default setting you must recompile the plugin

//------- Do not edit below this point ------//

#include <superheromod>
 
// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Noob"
new bool:gHasNoob[SH_MAXSLOTS+1]

new gArrows[SH_MAXSLOTS+1]

new gSpriteLaser, gSpriteMushroom, gPcvarArrows, gPcvarMaxLvl, gMsgSync

new const gNoob_Model[] = "models/shmod/noob_dk_v.mdl" 
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Noob", "2.2", "AssKicR / Fr33m@n")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("noob_level", "1")
	gPcvarArrows	= register_cvar("noob_arrows", "2")
	gPcvarMaxLvl 	= register_cvar("noob_maxlevel", "7")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Balas Explosivas en la DK.", "Obtén una Deagle con las primeras 3 Balas Explosivas que matan de un tiro.")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	
	// EVENTS
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Deagle_Deploy", 1)
	
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
{
	gSpriteLaser	= precache_model("sprites/laserbeam.spr")
	gSpriteMushroom	= precache_model("sprites/mushroom.spr")
	precache_model(gNoob_Model) 
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasNoob[id] = true
			noob_checklevel(id)
			noob_weapons(id)
			switchmodel(id)
			gArrows[id] = get_pcvar_num(gPcvarArrows)
		}

		case SH_HERO_DROP: {
			gHasNoob[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_client_spawn(id)
{
	if ( gHasNoob[id] ) {
		noob_checklevel(id)
		noob_weapons(id)
		gArrows[id] = get_pcvar_num(gPcvarArrows) 
	}
}
//------------------------------------------------------------------------------------------------
//				Give Weapon - strip 						//
//------------------------------------------------------------------------------------------------
noob_weapons(id)
{
	if ( is_user_alive(id) ) {
		// para dropear y borrar el item en el respawn
		sh_drop_weapon(id, CSW_USP, true)
		sh_drop_weapon(id, CSW_GLOCK18, true) 
		
		sh_give_weapon(id, CSW_DEAGLE)
		sh_give_item(id, "ammo_50ae")
		sh_give_item(id, "ammo_50ae")
		sh_give_item(id, "ammo_50ae")
	}
}

public Deagle_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !gHasNoob[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, gNoob_Model)

	return HAM_IGNORED; 
}

switchmodel(id)
{
	if ( !is_user_alive(id) ) return
	if ( get_user_weapon(id) == CSW_DEAGLE ) {
		set_pev(id, pev_viewmodel2, gNoob_Model)
	}
}

public weapon_change(id)
{
	if ( !gHasNoob[id] ) return

	if ( read_data(2) != CSW_DEAGLE || gArrows[id] < 0 ) return

	if ( (pev(id, pev_button) & IN_ATTACK) ) {
		new hitvec[3]

		get_user_origin(id, hitvec, 4)
		create_tracer(id, hitvec)
		
		if ( gArrows[id] > 0  ) {
			set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 3)
			ShowSyncHudMsg(id, gMsgSync, "Te quedan %d Balas Explosivas%s.", gArrows[id], gArrows[id] == 1 ? "" : "s")
		}
		gArrows[id]--
	}
}
//------------------------------------------------------------------------------------------------
//				Evento Damage Kill						//
//------------------------------------------------------------------------------------------------
public client_damage(attacker, victim, damage, wpnindex, hitplace)
{
	// if ( !sh_is_active() || !sh_is_inround() ) return
	if ( !is_user_alive(victim) || !is_user_connected(attacker) || victim == attacker ) return
	else if ( cs_get_user_team(victim) == cs_get_user_team(attacker) ) return

	if ( gHasNoob[attacker] && wpnindex == CSW_DEAGLE && gArrows[attacker] > 0 ) {
		explode_effect(victim)
		new headshot = hitplace == 1 ? 1 : 0

		// do extra damage
		sh_extra_damage(victim, attacker, damage, "For Noob Powers", headshot, SH_DMG_KILL)
	}
}

create_tracer(id, hitvec[3])
{
	new origin[3]
	get_user_origin(id, origin, 1)

	// Tracer beam
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)	// 0
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(hitvec[0])
	write_coord(hitvec[1])
	write_coord(hitvec[2])
	write_short(gSpriteLaser)
	write_byte(0)		// framestart
	write_byte(10) 		// framerate
	write_byte(2)		// life
	write_byte(4)		// width
	write_byte(1)		// noise
	write_byte(153)		// r, g, b
	write_byte(0)		// r, g, b
	write_byte(0)		// r, g, b
	write_byte(80)		// brightness
	write_byte(100)		// speed
	message_end()
}

explode_effect(victim)
{
	sh_set_rendering(victim, 0, 0, 0, 0, kRenderFxGlowShell, kRenderTransAlpha)

	new origin[3]
	get_user_origin(victim, origin)

	// Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)	// 3
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-22)
	write_short(gSpriteMushroom)
	write_byte(40)	// scale in 0.1's
	write_byte(12)	// framerate
	write_byte(0)	// flags
	message_end()

	// Blood spurt
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_LAVASPLASH)	// 10
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-26)
	message_end()
}
//------------------------------------------------------------------------------------------------
//					Check Level y Stock					//
//------------------------------------------------------------------------------------------------
public noob_checklevel(id)
{
	// if ( !gHasNoob[id] ) return
	new gMaxLvl = get_pcvar_num(gPcvarMaxLvl)
	if ( sh_get_user_lvl(id) >= gMaxLvl  ) {
		gHasNoob[id] = false
		sh_chat_message(id, gHeroID, "Tenes que ser nivel %d o menos para usar este Héroe.", gMaxLvl)
		client_cmd(id, "say drop %s", gHeroName)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
