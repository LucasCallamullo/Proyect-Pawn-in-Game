/// SHADOWCAT! from the X-men, Kitty Pryde can walk thu walls.
// Hero Originally named NightCrawler, changed since powers did not fit.

/* CVARS - copy and paste to shconfig.cfg
//Shadowcat
shadowcat_level 0
shadowcat_cooldown 30		//# of seconds before Shadowcat can NoClip Again
shadowcat_cliptime 6		//# of seconds Shadowcat has in noclip mode.
*/

// 23 dec 2018 - Evileye - sendShadowcatCooldown() added to tell another plugins information about cooldown
//---------- User Changeable Defines --------//
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1
//------- Do not edit below this point ------//

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Shadowcat"
new bool:gHasShadowcat[SH_MAXSLOTS+1]
new gShadowcatTimer[SH_MAXSLOTS+1]
new const gSoundShadowcat[] = "ambience/alien_zonerator.wav"
new gPcvarCooldown, gPcvarClipTime, gMsgSync

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Shadowcat", SH_VERSION_STR, "{HOJ} Batman")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("shadowcat_level", "0")
	gPcvarCooldown = register_cvar("shadowcat_cooldown", "30")
	gPcvarClipTime = register_cvar("shadowcat_cliptime", "6")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Atraviesa las paredes.", "Podes volar y atravesar las paredes, No clip - No te quedes atorado o vas a morir! - pone /bind en say para aprender a bindear")
	sh_set_hero_bind(gHeroID)
 
	// LOOP
	set_task(1.0, "shadowcat_loop", _, _, _, "b")
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
	precache_sound(gSoundShadowcat)
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasShadowcat[id] = true

			// Make sure looop doesn't fire for them
			gShadowcatTimer[id] = -1
		}

		case SH_HERO_DROP: {
			gHasShadowcat[id] = false

			if ( gShadowcatTimer[id] >= 0 ) shadowcat_endnoclip(id)
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || sh_is_freezetime() || !is_user_alive(id) ) return

	if ( key == SH_KEYDOWN ) {
		// Make sure they're not in the middle of clip already
		// Let them know they already used their ultimate if they have
		if ( gPlayerInCooldown[id] ) {
			sh_sound_deny(id)
			return
		}
		//If the user already has noclip (prob from another hero) cancel this keydown
		if ( get_user_noclip(id) ) {
			sh_chat_message(id, gHeroID, "Ahora estas usando tu No Clip.")
			sh_sound_deny(id)
			return
		}
		
		gShadowcatTimer[id] = get_pcvar_num(gPcvarClipTime)
		set_user_noclip(id, 1)
		// Shadowcat Messsage
		set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.25, 1.2, 0.0, 0.0, 4)
		ShowSyncHudMsg(id, gMsgSync, "Entraste en Modo %s ^nNo te quedes Atrapado en la pared, o Morirás!", gHeroName)
		emit_sound(id, CHAN_STATIC, gSoundShadowcat, 0.2, ATTN_NORM, 0, PITCH_LOW)
		
		
		// set cooldowns
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
	}
}	
#if SEND_COOLDOWN
public sendShadowcatCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id])
}
#endif
//------------------------------------------------------------------------------------------------
//					Spawn n Death 						//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasShadowcat[id] ) {
		shadowcat_endnoclip(id)
	
		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		// if is a new round set cooldown in zero
		else gPlayerInCooldown[id] = false
	}
}

public sh_client_death(id) {
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( gHasShadowcat[id] ) {
		gPcvarRealCD[id] = sh_get_cooldown(id)
		shadowcat_endnoclip(id)
	} 
}

public shadowcat_loop()
{
	static players[SH_MAXSLOTS], playerCount, player, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]

		if ( !gHasShadowcat[player] || !is_user_alive(player) || gShadowcatTimer[player] < 0 ) continue
		
		if ( gShadowcatTimer[player] > 0 ) {
			set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
			ShowSyncHudMsg(player, gMsgSync, "%d segundos%s para dejar el %s Modo^nNo te quedes Atrapado en la pared o Morirás.", gShadowcatTimer[player], gShadowcatTimer[player] == 1 ? "" : "s", gHeroName)
		}
		else if ( gShadowcatTimer[player] == 0 ) {
			shadowcat_endnoclip(player)
		}
		
		gShadowcatTimer[player]--
	}
}

shadowcat_endnoclip(id)
{
	if ( !is_user_connected(id) ) return

	gShadowcatTimer[id] = -1

	// Stop noclip sound
	emit_sound(id, CHAN_STATIC, gSoundShadowcat, 0.0, ATTN_NORM, SND_STOP, PITCH_LOW)

	if ( !is_user_alive(id) ) return

	if ( get_user_noclip(id) ) {
		// Turn off no-clipping and kill user if stuck
		set_user_noclip(id, 0)

		// If player is stuck kill them
		new Float:origin[3], hulltype
		pev(id, pev_origin, origin)
		hulltype = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
		if ( !sh_hull_vacant(id, origin, hulltype) ) {
			user_kill(id)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/