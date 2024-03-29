// Magneto!

/* CVARS - copy and paste to shconfig.cfg

//Magneto
magneto_level 10
magneto_cooldown 45				//Time delay bewtween automatic uses
magneto_boost 125				//How much of an upward throw to give weapons
magneto_giveglock 1				//Give the poor victim a glock?

*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Magneto"
new bool:gHasMagneto[SH_MAXSLOTS+1]

new gSpriteLightning, pCvarCooldown, pCvarBoost, pCvarGiveGlock

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob",
	"T-800"
}

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

new const gSoundDisarm[] = "ambience/deadsignal1.wav"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Magneto", SH_VERSION_STR, "AssKicR / JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("magneto_level", "10")
	pCvarCooldown = register_cvar("magneto_cooldown", "45")
	// pCvarBoost = register_cvar("magneto_boost", "125")
	pCvarGiveGlock = register_cvar("magneto_giveglock", "1")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Maestro del Magnetismo.", "Sacale las armas a tus enemigos cuando te disparan!")
	sh_set_hero_shield(gHeroID, true)
}

public plugin_precache()
{
	precache_sound(gSoundDisarm)
	gSpriteLightning = precache_model("sprites/lgtning.spr")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasMagneto[id] = true
				gPlayerInCooldown[id] = false
			}
			case SH_HERO_DROP: {
				gHasMagneto[id] = false
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
}
//----------------------------------------------------------------------------------------------
//				SPAWN n DEATH for COOLDOWNS
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	// Para controlar si tiene el poder
	if ( gHasMagneto[id] ) {	
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
	if ( gHasMagneto[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//----------------------------------------------------------------------------------------------
public client_damage(attacker, victim, damage, wpnindex)
{
	if ( damage <= 0 || victim == attacker ) return
	if ( !is_user_alive(victim) || !is_user_alive(attacker) ) return
	if ( !gHasMagneto[victim] || gPlayerInCooldown[victim] ) return
	
	// check if has noob or magneto
	for (new i= 0; i < sizeof( gOthers_Heros ); i++) {
		new hero_id = sh_get_hero_id( gOthers_Heros[i] )
		if ( sh_user_has_hero(attacker, hero_id) ) return
	}
		
	new slot = sh_get_weapon_slot(wpnindex)

	if ( slot == 1 || slot == 2 ) {

		new Float:cooldown = get_pcvar_float(pCvarCooldown)
		if ( cooldown > 0.0 ) sh_set_cooldown(victim, cooldown)

		// Disarm enemy and get their gun!
		play_sound(victim)
		play_sound(attacker)
		magneto_disarm(victim, attacker)

		//Screen Flash
		new alphanum = clamp((damage * 2), 40, 200)
		sh_screen_fade(attacker, 1.0, 0.5, 100, 100, 100, alphanum)
	}
}
//----------------------------------------------------------------------------------------------
magneto_disarm(id, victim)
{
	new Float:velocity[3]

	pev(victim, pev_velocity, velocity)
	velocity[2] += 125.0

	// Give em an upwards Jolt
	set_pev(victim, pev_velocity, velocity)

	new iweapons[32], inum, i, weaponID

	get_user_weapons(victim, iweapons, inum)

	for ( i = 0; i < inum; i++ ) {
		weaponID = iweapons[i]
		sh_drop_weapon(victim, weaponID, true)
		//Don't give c4, do not need more of them out there
		if ( weaponID == CSW_C4 ) continue 
		sh_give_weapon(id, weaponID)
	}

	if ( get_pcvar_num(pCvarGiveGlock) ) {
		sh_give_weapon(victim, CSW_GLOCK, true) 
		/* new randomMagneto
		randomMagneto = random_num(1, 7)
		
		switch(randomMagneto) {
			case 1: sh_give_weapon(victim, CSW_DEAGLE, true)
			case 2: sh_give_weapon(victim, CSW_MP5NAVY, true)
			case 3: sh_give_weapon(victim, CSW_P90, true)
			case 4: sh_give_weapon(victim, CSW_AK47, true)
			case 5: sh_give_weapon(victim, CSW_AWP, true)
			//case 6: sh_give_weapon(victim, CSW_GLOCK, true)	
		} */
	}
	else 	{
		sh_switch_weapon(victim, CSW_KNIFE)
	}

	lightning_effect(id, victim)

	new name[32]
	get_user_name(id, name, charsmax(name))

	sh_chat_message(victim, gHeroID, "%s Te ha sacado tus armas.", name)
}
//----------------------------------------------------------------------------------------------
lightning_effect(id, victim)
{
	// Lightning effect
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)		// 8
	write_short(id)			// start entity
	write_short(victim)		// entity
	write_short(gSpriteLightning)	// model
	write_byte(0)		// starting frame
	write_byte(15)		// frame rate
	write_byte(10)		// life
	write_byte(10)		// line width
	write_byte(10)		// noise amplitude
	write_byte(255)		// r, g, b
	write_byte(255)		// r, g, b
	write_byte(255)		// r, g, b
	write_byte(255)		// brightness
	write_byte(0)		// scroll speed
	message_end()
}
//----------------------------------------------------------------------------------------------
play_sound(id)
{
	emit_sound(id, CHAN_AUTO, gSoundDisarm, VOL_NORM, ATTN_NORM, 0, PITCH_HIGH)
	set_task(1.5, "stop_sound", id)
}

public stop_sound(id)
	emit_sound(id, CHAN_AUTO, gSoundDisarm, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
