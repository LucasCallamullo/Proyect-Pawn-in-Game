// FPS Doug!

/* CVARS - copy and paste to shconfig.cfg

//FPS Doug
doug_level 6
doug_knivespeed 400	//Speed of FPS Doug when holding knife
doug_extradamage 0	// 0 =  instand kill, any other value is added damage.
doug_blood_effects 1	// Blood sprite effects

*/

/*
* v1.3 - K-OS - Default release
*      - Made with some peaking into the source of sh_greenarrow,
*        miscstats, amx_gore_ultimate and wolverine
*
* v1.4 - Fr33m@n - 4/5/09
*      - Updated to be SH 1.2.0 compliant, removed amx compatibility (runtime error fixed)
*      - Cleaned up code
*      - Fixed minor mistake who made the 8th sound  never played ingame
*
* v1.5 - Fr33m@n - 4/11/09
*      - Made sounds constant
*      - Minor changes
*
* v1.6 - Fr33m@n - 5/20/09
*      - Replace user_kill stuff by sh_extra_damage
*      - Remove useless stuff, minor changes
*
* v1.7 - Fr33m@n - 6/6/09
*      - Add some blood effects (cvar)
*      - Minor fix about friendlyfire
*        Thanks to JTP10181 for blood effects (Ultimate Gore)
*        http://forums.alliedmods.net/showthread.php?p=19346
*
* v1.8 - Fr33m@n - 11/13/09
*      - Use of SH_DMG_KILL param instead of use damage = get_user_health(victim)
*      - Use of sh_get_weapon_slot instead of wpncheck
*/

//---------- User Changeable Defines --------//

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Doug Headshot!"
new bool:gHasDoug[SH_MAXSLOTS+1]
new gSpriteBoom, gSpriteBloodDrop, gSpriteBloodSpray
new gPcvarExtraDmg, gPcvarBloodEffects, gPcvarCooldown

new const gBoomSound[3][] = {
	"shmod/fpsdoug/boomhs.wav",
	"shmod/fpsdoug/hohohoyeah.wav",
	"shmod/fpsdoug/takethatbitch.wav"
}

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

new const doug_deagle_v [] = "models/shmod/doug_deagle_v.mdl"
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO FPS Doug", "1.8", "K-OS / Fr33m@n")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= register_cvar("doug_level", "0")
	gPcvarExtraDmg 		= register_cvar("doug_extradamage", "4.0")
	gPcvarBloodEffects 	= register_cvar("doug_blood_effects", "1")
	gPcvarCooldown	 	= register_cvar("doug_cooldown", "30")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "BOOM HEADSHOT!", "Mata de un tiro en la cabeza con DK.")

	// EVENTS
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Deagle_Deploy", 1)
	sh_set_hero_shield(gHeroID, true)
	
	// esto es oara que use solo una bala
	// register_forward(FM_CmdStart, "fwdPlayerCmdStart", 1)	//def 1
}

public plugin_precache()
{
	gSpriteBloodDrop = precache_model("sprites/blood.spr")
	gSpriteBloodSpray = precache_model("sprites/bloodspray.spr")
	gSpriteBoom = precache_model("sprites/fexplo1.spr")
	
	precache_model(doug_deagle_v) 

	for ( new x = 0; x < sizeof (gBoomSound); x++ ) {
		precache_sound(gBoomSound[x])
	}
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasDoug[id] = true
			gPlayerInCooldown[id] = false
			switchmodel(id)
		}
		case SH_HERO_DROP: {
			gHasDoug[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
//				SPAWN n DEATH for COOLDOWNS
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	// Para controlar si tiene el poder
	if ( gHasDoug[id] ) {
		// para dropear y borrar el item en el respawn
		sh_drop_weapon(id, CSW_USP, true)
		sh_drop_weapon(id, CSW_GLOCK18, true) 
		sh_give_weapon(id, CSW_DEAGLE) 
		sh_give_item(id,"ammo_50ae")
		sh_give_item(id,"ammo_50ae")
		
		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		else gPlayerInCooldown[id] = false
	}
}

public sh_client_death(id) {
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( gHasDoug[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//------------------------------------------------------------------------------------------------
//				Change weapons models						//
//------------------------------------------------------------------------------------------------
switchmodel(id)
{
	if ( !is_user_alive(id) ) return
	new wpnid = read_data(2)
	if (wpnid == CSW_DEAGLE) {
		set_pev(id, pev_viewmodel2, doug_deagle_v)
	}
}

public Deagle_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !gHasDoug[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, doug_deagle_v)
	
	return HAM_IGNORED; 
}

/* public fwdPlayerCmdStart(id, iUc, iRandom)
{        
	// Agregado
	if ( !(id <= id <= SH_MAXSLOTS) || !is_user_alive(id) ) return
	if ( !gHasDoug[id] ) return
	
	cs_set_user_bpammo(id, CSW_DEAGLE, 3) 
	new iEntDeagle = find_ent_by_owner(-1, "weapon_deagle", id)

	if(is_user_alive(id) && get_user_weapon(id) == CSW_DEAGLE && cs_get_weapon_ammo(iEntDeagle) > 3) {
		cs_set_weapon_ammo(iEntDeagle, 3)
	}
}  */

public client_damage(attacker, victim, damage, wpnindex, hitplace)
{
	if ( !sh_is_active() ) return
	if ( !is_user_connected(victim) || !is_user_alive(attacker) ) return
	if ( cs_get_user_team(victim) == cs_get_user_team(attacker) ) return
	
	if ( gPlayerInCooldown[attacker] ) return
	
	new randnum = random_num(1, 100)
	new prob = random_num(1, 35)
 
	if ( gHasDoug[attacker] && sh_get_weapon_slot(wpnindex) == 2 && hitplace == 1 && prob >= randnum ) {
		static weaponName[32]
		get_weaponname(wpnindex, weaponName, charsmax(weaponName))
		replace(weaponName, charsmax(weaponName), "weapon_", "")

		new extraDamage = get_pcvar_num(gPcvarExtraDmg)
		if ( extraDamage > 0) {
			sh_extra_damage(victim, attacker, extraDamage, weaponName, 1)
			if ( is_user_alive(victim) ) return
		}
		else 	{
			sh_extra_damage(victim, attacker, damage, weaponName, 1, SH_DMG_KILL)
		}
		
		boom_effects(attacker, victim)
	}
}
/* / Este es un stock creado por mi para utilizar un probabliidad random 
stock bool:probabilty_random(prob, maximo = 100, minimo = 0) {
	new prob_random = random_num(minimo, maximo);
	return (prob_random <= prob); 
} */
//----------------------------------------------------------------------------------------------
boom_effects(attacker, victim)
{
	emit_sound(attacker, CHAN_AUTO, gBoomSound[random(3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	new Float:seconds = get_pcvar_float(gPcvarCooldown)
	if ( seconds > 0.0 ) {
		sh_set_cooldown(attacker, seconds)
		gPcvarRealCD[attacker] = seconds
	} 

	new origin[3]
	get_user_origin(victim, origin)

	// Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)	// 3
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + 20)
	write_short(gSpriteBoom)	// sprite index
	write_byte(10)	// scale in 0.1's
	write_byte(15)	// framerate
	write_byte(0)	// flags
	message_end()

	if ( get_pcvar_num(gPcvarBloodEffects) ) {
		// Falling blood spray
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BLOODSPRITE)	// 115
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2] + 40)
		write_short(gSpriteBloodSpray)	// sprite1 index
		write_short(gSpriteBloodDrop)		// sprite2 index
		write_byte(247)	// color
		write_byte(15)	// scale in 0.1's
		message_end()

		// Blood particule spray
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)	// 101
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2] + 40)
		engfunc(EngFunc_WriteCoord, random_float(-30.0, 30.0))	// spray vector
		engfunc(EngFunc_WriteCoord, random_float(-30.0, 30.0))
		engfunc(EngFunc_WriteCoord, random_float(80.0, 300.0))
		write_byte(70)	// color
		write_byte(random_num(100, 200))	//speed
		message_end()
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/