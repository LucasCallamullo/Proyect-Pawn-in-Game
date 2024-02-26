// Naruto Uzumaki (Shadow Clone Jutsu Version)

/* CVARS - copy and paste to shconfig.cfg

//Naruto Uzumaki
naruto_level 25
naruto_damage 6			//The amount of damage each bullet does
naruto_rdamage 300		//The Rasengan damage
naruto_activetime 40.0		//The maximum time the shadow clone is active
naruto_cooldown 20		//The time players have to wait to summon the shadow clone again
naruto_maxchakra 15		//The max chakra the player can use
naruto_rasengancost 7		//How much chakra the Rasengan uses
naruto_clonehealth 200 		//How much health the shadow clone has

*//*

	Change Log:
	------------------
	v 0.9.31 beta - May 9, 20123
		- better code scripts and recursivity of functions, add new form to set the shoots and put correctly the cooldown
		- in the future maybe change some functions for recrusivity and 

	v 0.9.30 beta - May 9, 2015
		- usability + stability update - edit by heliumdream for [db]Clan Superheroes Server
		- added reset events on respawn and disconnect to remove clone 
		- added check so only one player can use naruto at a time (multiple simultaneous users caused strange bot action, origin, and clip issues) - new var bot_userid
		- added timer by task and cvar to control how long the clone is active - new cvar naruto_activetime
		- added naruto_clonehealth cvar
		- 
		- future plans for 9.31:
		- we have changed how often and when the clone entities are drawn and removed; the result is redundant code which should be handled with a reset_event function that can be called in place of redundant blocks.
		- also consider where hooks can be used; death and spawn events and triggers. 
	v 0.9.29 beta - August 12 ,2010
		- modified where and how the shadow clone would spawn
	v 0.9.28 beta - August 11 ,2010
		- added another check to check if there is a shadow clone without an owner
		- added a return function on bot death
		- modified think function
		- removed a paradox that made no sense that was added in the last update
	v 0.9.2 beta - August 10 ,2010
		- removed all friction modifiers from the last update
		- added another check to see if players don't have Naruto but still have bot
	v 0.9.0 beta - August 10 ,2010
		- improved the showdow clone's move function
		- optimized various parts of the code
		- removed the need the modify the bots origin due to it getting stuck
	v 0.8.43 beta - August 7 ,2010
		- fixed a minor run time error
		- changed function so the weapon removes before the shadow clone
	v 0.8.42 beta - August 7 ,2010
		- fixed another minor bug
	v 0.8.41 beta - August 7 ,2010
		- fixed a minor bug that was accidentally added in the last version
	v 0.8.4 beta - August 7 ,2010
		- removed useless bools
		- using fm_remove_entity(index) instead of engfunc(EngFunc_RemoveEntity,index)
		- added new stock naruto_remove_entity(index) to set the entities to the right conditions before removing them
	v 0.8.3 beta - August 6, 2010
		- optimized code
		- weakened shadow clone
		- all known major and minor crash problems have been fixed
		- modified sprite
	v 0.8.2 beta - August 3, 2010
		- added more checks to prevent crashes
		- removed death animation function and replaced it with a sound, just like in the anime
		- fixed a minor disconnection error
	v 0.8.0 beta - August 2, 2010	
		- optimized code
		- added more checks
		- added new bools for better checking
		- added new sounds
	v 0.7.0 beta - August 1, 2010
		- resumed project
		- modified health function
		- rennamed to Naruto Uzumaki (Shadow Clone Jutsu Version) anything referencing a Puppet is
		  now referenced as a Shadow Clone
		- the shadow clone's walk function is smoother and more efficient
		- added rasengan function!
		- added a defect function to help reduce server crashes
	v 0.6.5 beta - July 24, 2009
		- fixed a small runtime error with the cs_get_user_team native by adding a small check
		  to see if the owner is in the server and is alive
	v 0.6.4 beta - July 22, 2009
		- fixed a problem that would cause a server crash when the puppet owner would
		  type 'kill' in his console by using a different method than sh_client_death
	v 0.6.31 beta - July 20, 2009
		- a minor message fix
	v 0.6.3 beta - July 20, 2009
		- now the puppet will successfully hit players at a given success rate via pcvar
		- removed a small bug where the puppet would still be alive after its owner has died
	v 0.6.2 beta - July 18, 2009
		- fixed a rare case where players would disconnect and crash the server
		- added an extra check to see if players have the puppet upon disconnection
	v 0.5.3 beta - July 10, 2009
		- cooldown now takes place after bot dies
		- fixed a case where the cooldown would not reset on spawn
	v 0.5.1 beta - July 8, 2009
		- fixed minor problem where bot would crouch and it's origin would be skewed 
		- added some movement function checks and fixes to help the bot run smoothly
	v 0.5 beta - July 6, 2009
		- slight changes to the movement function to make it more efficient
		- fixed some glitches in the bots origin while ducking and standing
	v 0.4.6 beta - July 4, 2009
		- fixed a problem which would cause the server to crash when players with
		  puppet master would disconnect while the bot is in the process of dying
	v 0.4.53 beta - July 4, 2009
		- updated some parts of the code to prevent some cases causing the server to crash
	v 0.4.5 beta - July 4, 2009
		- rolled back code to v 0.4.3 with some slight improvements
		- versions 0.4.4 till 0.4.5 has major problems where the bot would not function
		  properly most of the time after spawning a second time
	v 0.4.42 beta - July 4, 2009
		- a quickfix to the drophero function
		- fixed a slight code problem where, if players disconnect and doesn't have
		  a bot spawned, the plugin will try to remove an entity that is not there
	v 0.4.4 beta - July 4, 2009
		- added more checks in various functions to tell when bot is dying
		- fixed animation sequence bug where the puppet would show the wrong animation
	v 0.4.3 beta - July 4, 2009
		- fixed a big error when the puppet owner dies, and the bot is triggering the death 
		  fucntion and players kill the bot, which causes the death function to be
		  triggered twice, causing the server to crash
		- fixed problem where puppet would continue to attack players when the owner died
		- added comments on some confusing parts to describe their purpose and function
	v 0.4.2 beta - July 3, 2009
		- fixed a minor runtime error with removing the puppets weapon
	v 0.4.1 beta - July 3, 2009
		- moved onto beta testing
		- hero renamed to Puppet Master
		- added effects to player while summoning a puppet
		- puppet no longer attacks while its not a solid (or when user is inside entity)
		- added sounds to various functions
		- modified the method and function of the puppets death and added animation to it
		- fixed a minor bug where players disconnect and the bot entity is still registered
		- modified the puppets movement function
		- removed useless, repetitive, and ineffective strings
	v 0.3 alpha - July 3, 2009
		- bot now shoots one bullets per every second multiplied by the gun cooldown cvar
		  instead of just shooting bursts of bullets
		- cooldown functions changed
		- fixed more cases when player gets stuck on guardian
	v 0.2 alpha - July 1, 2009
		- guardian now only attacks the person he's aiming at
		- movement function more efficient
		- fixed problems where owner would get stuck within the guardian
		- fixed some cases where guardian would get stuck on the floor while walking
		- made it possible for owner to walk through guardian
		- changed gun model
		- cleaned up code
	v 0.1 alpha - June 30, 2009
		- alpha testing
		- created
*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 0

#include <superheromod>
#include <chr_engine>
#include <fakemeta_util>
 
// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Naruto Uzumaki"
new bool:gHasNaruto[SH_MAXSLOTS+1]


// This is for entitys
new botEnt[SH_MAXSLOTS+1]
new entWeapon[SH_MAXSLOTS+1]

// maybe i redcue this varaibles
// new DoOnce[SH_MAXSLOTS+1]
new bool:DoOnce[SH_MAXSLOTS+1]
new bool:aimtargetfound[SH_MAXSLOTS+1]
new bool:doingrasengan[SH_MAXSLOTS+1]
new bool:rasenganover[SH_MAXSLOTS+1]

// gPCVARS
new pCvarMaxChakra, pCvarRasenganCost, pCvarCloneHealth
new pCvardamage, pCvarDMG_Rasengan, pCvarActiveTime, pCvarCooldown
new pcvarAdmin, round_delay, gSpriteCircle, gSpriteSmoke 

// Constants models for the power
new const g_Sound_Rasengan1[] = "shmod/naruto/rasengan1.wav"
new const g_Sound_Rasengan2[] = "shmod/naruto/rasengan2.wav"
new const g_Sound_RasenganExp[] = "shmod/naruto/rasenganexp.wav"
new const g_Sound_RasenganCloneasd[] = "shmod/naruto/narutoclonesd.wav"
new const g_Sound_RasenganClone[] = "shmod/naruto/narutoclone.wav"

new const g_Model_Pclon[] = "models/shmod/darthmaul_p_knife.mdl"
new const g_Sprite_Rasengan[] = "sprites/shmod/esf_exp_blue.spr"

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

// this is for cooldown shots
new delay_shot[SH_MAXSLOTS+1]

// Chakra 
new player_chakra[SH_MAXSLOTS+1] = 0
//-----------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Naruto Uzumaki","0.9.30b","1sh0t2killz")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= 	register_cvar("naruto_level", "18")
	pCvardamage 		= 	register_cvar("naruto_damage", "6")
	pCvarDMG_Rasengan	= 	register_cvar("naruto_rdamage", "120")
	pCvarActiveTime 	=	register_cvar("naruto_activetime", "15.0")	
	pCvarCooldown 		= 	register_cvar("naruto_cooldown", "20")
	
	
	pCvarMaxChakra 		= 	register_cvar("naruto_maxchakra", "20")
	pCvarRasenganCost 	= 	register_cvar("naruto_rasengancost", "7")
	pCvarCloneHealth	=	register_cvar("naruto_clonehealth", "200")
	pcvarAdmin		= 	register_cvar("naruto_adminflag", "p")


	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Shadow Clone Jutsu.", "Invoca un clon de la sombra que te sigue y dispara a cualquier enemigo cercano con su arma, presiona nuevamente para usar el Rasengan en un enemigo.")
	sh_set_hero_bind(gHeroID)
	
	// EVENTS	
	// LOOP
	set_task(1.0, "naruto_loop", _, _, _, "b")
	
	// Register Thinks
	register_forward(FM_Think,"FM_Think_hook")
}

public plugin_precache()
{
	precache_model(g_Model_Pclon)
	precache_model(g_Sprite_Rasengan)

	precache_sound(g_Sound_Rasengan1)
	precache_sound(g_Sound_Rasengan2)
	precache_sound(g_Sound_RasenganExp)
	precache_sound(g_Sound_RasenganCloneasd)
	precache_sound(g_Sound_RasenganClone)
	precache_sound("weapons/m249-1.wav")
	
	gSpriteCircle 	= precache_model("sprites/shockwave.spr")
	gSpriteSmoke 	= precache_model("sprites/wall_puff4.spr")
}
//-----------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasNaruto[id] = true
			
			botEnt[id] = 0
			gPlayerInCooldown[id] = false

			naruto_admincheck(id)
			reset_bools_values(id)
			
			sh_chat_message(id, gHeroID, "Dattebayo!")
		}
		case SH_HERO_DROP: {
			gHasNaruto[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || !sh_is_inround() ) return
	if ( !is_user_alive(id) || !gHasNaruto[id] ) return

	if ( key == SH_KEYDOWN ) {
		
		new costo_chakra = get_pcvar_num(pCvarRasenganCost)
		
		if (round_delay) {
			sh_chat_message(id, gHeroID, "Tenes que esperar 5 segundos despues de que la ronda haya comenzado para invocar.")
			sh_sound_deny(id)
			return
		}
		
		else if ( gPlayerInCooldown ) {
			sh_chat_message(id, gHeroID, "Debes esperar un momento para invocar a otro clon de sombra.")
			sh_sound_deny(id)
			return
		}

		else if ( player_chakra[id] < costo_chakra ) {
			sh_chat_message(id, gHeroID, "Necesitas recargar chakra antes de usar tu Rasengan de nuevo.")
			sh_sound_deny(id)
			return
		}

		if ( botEnt[id] && !doingrasengan[id] && aimtargetfound[id] && player_chakra[id] >= costo_chakra ) {
			
			sh_chat_message(id, gHeroID, "Rasengan!")
			doingrasengan[id] = true
			player_chakra[id] -= costo_chakra
			
			if ( pev_valid(entWeapon[id]) ) {
				entity_set_model(entWeapon[id], g_Sprite_Rasengan)
				entity_set_int(entWeapon[id], EV_INT_rendermode, 5) 
				entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
			}
			
			emit_random_sound(id)
	
			set_task(2.0, "rasenganmissed", id)
			return
		} 
		
		// for dont two clone at the same time
		for( new i=0; i <= SH_MAXSLOTS; i++ ) {	
			if ( botEnt[id] ) {
				sh_chat_message(id, gHeroID, "Alguien ya ha invocado un clon de sombra, por favor espere.") 
				sh_sound_deny(id)
				return
			}
		}
		
		// create and invoke the clone
		shadowclone_pre_effects(id)
		
		// set_cooldown
		new Float:seconds = get_pcvar_float(pCvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
	}
}
#if SEND_COOLDOWN
public sendNarutoscjCooldown(id)
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
	if ( gHasNaruto[id] ) {
		// check admin
		naruto_admincheck(id)
		
		// remove n check aagin for sure
		remove_naruto_ent_wpn(id)
		
		reset_bools_values(id)
		
		
	
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
	if ( gHasNaruto[id] ) {
		gPcvarRealCD[id] = sh_get_cooldown(id)
		
		// remove n check aagin for sure
		remove_naruto_ent_wpn(id)
	}
}

reset_bools_values(id) {
	aimtargetfound[id] = false
	doingrasengan[id] = false
	rasenganover[id] = false
	DoOnce[id] = false
	player_chakra[id] = 0
	delay_shot[id] = false	
}
//-----------------------------------------------------------------------------------------
//		ADD SOME EFFECTS RANDOM SOUND AND LOOP RECOVER CHAKRA
//-----------------------------------------------------------------------------------------
public naruto_loop()
{
	if ( !sh_is_active() ) return

	static players[SH_MAXSLOTS], playerCount, player, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]
		if ( !gHasNaruto[player] ) continue
		if ( player_chakra[player] < get_pcvar_num(pCvarMaxChakra) )
			player_chakra[player] += 1
	}
}

public emit_random_sound(id)
{
	new rsound = random_num(1,2)
			
	switch(rsound) {
		case 1: {
			emit_sound(id, CHAN_ITEM, g_Sound_Rasengan1, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, g_Sound_Rasengan1, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(botEnt[id], CHAN_ITEM, g_Sound_Rasengan1, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(botEnt[id], CHAN_STATIC, g_Sound_Rasengan1, 0.5, ATTN_NORM, 0, PITCH_NORM)
		}
		case 2: {
			emit_sound(id, CHAN_ITEM, g_Sound_Rasengan2, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, g_Sound_Rasengan2, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(botEnt[id], CHAN_ITEM, g_Sound_Rasengan2, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(botEnt[id], CHAN_STATIC, g_Sound_Rasengan2, 0.5, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}
//----------------------------------------------------------------------------------------------
//			CREATE SHADOW CLONE WITH EFFECTS
//----------------------------------------------------------------------------------------------
public shadowclone_pre_effects(id)
{
	sh_chat_message(id, gHeroID, "Shadow Clone Jutsu!")
	set_task( 3.0, "shadowclone_create", id)
	
	summoning_ring_effects(id)
	set_task(0.2,"summoning_ring_effects",id)
	set_task(0.4,"summoning_ring_effects",id)
	set_task(0.6,"summoning_ring_effects",id)
	set_task(0.8,"summoning_ring_effects",id)
	set_task(1.0,"summoning_ring_effects",id)
	set_task(1.2,"summoning_ring_effects",id)
	set_task(1.4,"summoning_ring_effects",id)
	set_task(1.6,"summoning_ring_effects",id)
	set_task(1.8,"summoning_ring_effects",id)
	set_task(2.0,"summoning_ring_effects",id)
	set_task(2.2,"summoning_ring_effects",id)
	set_task(2.4,"summoning_ring_effects",id)
	set_task(2.6,"summoning_ring_effects",id)
	set_task(2.8,"summoning_ring_effects",id)
	
	emit_sound(id, CHAN_ITEM, g_Sound_RasenganClone, 0.5, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, g_Sound_RasenganClone, 0.5, ATTN_NORM, 0, PITCH_NORM)
}

public shadowclone_create(id)
{
	sh_chat_message(id, gHeroID, "Tu Shadow Clone ha sido invocado.")
	
	botEnt[id] = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(botEnt[id],pev_classname,"npc_shadowclone")
	
	// to get the actual skin and use
	new model[32],modelchange[128]
	get_user_info(id,"model",model,31)
	format(modelchange,127,"models/player/%s/%s.mdl",model,model)
	
	engfunc(EngFunc_SetModel, botEnt[id],modelchange)
	//This will make it so that the ent appears in front of the user	
	new Float:fl_Origin[3], Float:viewing_angles[3]
	new distance_from_user = 70
	entity_get_vector(id, EV_VEC_angles, viewing_angles)
	fl_Origin[0] += (floatcos(viewing_angles[1], degrees) * distance_from_user)
	fl_Origin[1] += (floatsin(viewing_angles[1], degrees) * distance_from_user)
	fl_Origin[2] += (floatsin(-viewing_angles[0], degrees) * distance_from_user)+70
	new Float:spawnorigin[3]
	pev(id,pev_origin,spawnorigin)
	
	new Float:tmpVec[3] 
	tmpVec[0] = 20.0
	tmpVec[1] = 20.0
	tmpVec[2] = 40.0
	set_pev(botEnt[id],pev_size,tmpVec)
	
	set_pev(botEnt[id],pev_health, get_pcvar_float(pCvarCloneHealth)+5000000.0)
	set_pev(botEnt[id],pev_takedamage, 1.0)
	set_pev(botEnt[id],pev_dmg_take, 1.0)

	give_weapon(botEnt[id],id)
	if ( is_user_crouching(id) ) spawnorigin[2] += 2.0
	else spawnorigin[2] += 2.0
	set_pev(botEnt[id],pev_origin,fl_Origin)
	set_pev(botEnt[id],pev_solid, SOLID_BBOX)
	// set_pev(botEnt[id],pev_solid, SOLID_NOT)
	set_pev(botEnt[id],pev_movetype,MOVETYPE_NOCLIP)
	set_pev(botEnt[id],pev_owner, 33)
	// set_pev(botEnt[id],pev_owner, id)
	set_pev(botEnt[id],pev_nextthink,get_gametime() + 0.1)
	set_pev(botEnt[id],pev_sequence,1)
	set_pev(botEnt[id],pev_gaitsequence,1)
	set_pev(botEnt[id],pev_framerate,1.0)

	emit_sound(id, CHAN_ITEM, g_Sound_RasenganCloneasd, 0.5, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, g_Sound_RasenganCloneasd, 0.5, ATTN_NORM, 0, PITCH_NORM)


	//timer event - remove clone after cvar activetime 
	new Float:tmpActiveTime = get_pcvar_float(pCvarActiveTime)
	set_task(tmpActiveTime, "remove_naruto_ent_wpn", id)
}

public summoning_ring_effects(id)
{
	new summonorigin[3]
	get_user_origin(id,summonorigin)
			
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, summonorigin )
	write_byte( TE_BEAMCYLINDER )
	write_coord( summonorigin[0])
	write_coord( summonorigin[1])
	write_coord( summonorigin[2] - 16)
	write_coord( summonorigin[0])
	write_coord( summonorigin[1])
	// write_coord( summonorigin[2] - 16 + 100 ) 
	write_coord( summonorigin[2] + 84 ) 
	write_short( gSpriteCircle )
	write_byte( 0 ) 		// startframe
	write_byte( 0 ) 		// framerate
	write_byte( 5 ) 		// life
	write_byte( 150 )  	// width
	write_byte( 0 )		// noise
	write_byte( 255 ) 	// r, g, b
	write_byte( 255 ) 	// r, g, b
	write_byte( 150 ) 	// r, g, b
	write_byte( 220 ) 	// brightness
	write_byte( 0 ) 		// speed
	message_end()
}

public give_weapon(ent,id)
{
	entWeapon[id] = create_entity("info_target")
	
	entity_set_string(entWeapon[id], EV_SZ_classname, "npc_weapon")
	
	entity_set_int(entWeapon[id], EV_INT_movetype, MOVETYPE_FOLLOW)
	entity_set_int(entWeapon[id], EV_INT_solid, SOLID_NOT)
	entity_set_edict(entWeapon[id], EV_ENT_aiment, ent)
	entity_set_model(entWeapon[id], g_Model_Pclon)
	entity_set_int(entWeapon[id], EV_INT_rendermode, kRenderFxNone) 
	entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
}
//----------------------------------------------------------------------------------------------
//				Remove Shadow Clone
//----------------------------------------------------------------------------------------------
public remove_naruto_ent_wpn(id) 
{
	if( botEnt[id] && pev_valid(botEnt[id]) ) {
		
		if( pev_valid(entWeapon[id]) ) 
			naruto_remove_entity(entWeapon[id])
	
		if( pev_valid(botEnt[id]) ) {
			naruto_remove_entity(botEnt[id])
			
			botEnt[id] = 0
			remove_task(id)
			
			emit_sound(id, CHAN_ITEM, g_Sound_RasenganCloneasd, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, g_Sound_RasenganCloneasd, 0.5, ATTN_NORM, 0, PITCH_NORM)
		}
		
		sh_chat_message(id, gHeroID, "Te quedaste sin chakra tu Shadow Clone desaparecera.")
	}
	reset_bools_values(id)
}

stock naruto_remove_entity(index) {	
	set_pev(index, pev_solid, SOLID_NOT)
	fm_remove_entity(index)
}

public rasenganmissed(id)
{
	if ( !doingrasengan[id] ) return
	rasenganover[id] = true
	sh_chat_message(id, gHeroID, "Tu Rasengan ha fallado!")
	
	if ( pev_valid(entWeapon[id]) ) {
		entity_set_model(entWeapon[id], g_Model_Pclon)
		entity_set_int(entWeapon[id], EV_INT_rendermode, kRenderFxNone) 
		entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
	}
}
//-----------------------------------------------------------------------------------------
//			Register for think entitys each second 0,01 calls?
//-----------------------------------------------------------------------------------------
public FM_Think_hook(ent)
{
	for( new i=0; i <= SH_MAXSLOTS; i++ ) {	
		if( !gHasNaruto[i] ) continue 
		
		if( ent==botEnt[i] )
		{
			if (pev_valid(botEnt[i]) && pev_valid(ent))
			{
				if ( round_delay ) 
				{
					if(pev_valid(ent) && ent==botEnt[i])
					{
						set_pev(botEnt[i],pev_health, get_pcvar_float(pCvarCloneHealth)+5000000.0)
					}
				}
				// maybe a check ?
				if ( !pev_valid(botEnt[i]) ) {
					remove_naruto_ent_wpn(i) 
					sh_chat_message(i, gHeroID, "Tu Shadow Clone deserto! Ahora desaparecera.")
					
					return FMRES_IGNORED
				}
				
				if ( pev_valid(ent) ) {
					
					static Float:origin[3]
					static Float:origin2[3]
					static Float:velocity[3]
					
					new Float: Naruto_Distance = get_distance_f(origin, origin2)
					
					pev(ent,pev_origin,origin2)
					get_offset_origin_body(i,Float:{0.0,0.0,0.0},origin)
					if(is_user_crouching(i)) origin[2] += 2.0
					else origin[2] += 2.0
					
					new MinBox[3], MaxBox[3];

					if (is_user_crouching(i)) {
						MinBox = {-20.0, -20.0, -20.0};
						MaxBox = {20.0, 20.0, 20.0}; 
					} else {
						MinBox = {-20.0, -20.0, -38.0};
						MaxBox = {20.0, 20.0, 40.0};
					}
					
					set_pev(ent,pev_mins, MinBox) 
					set_pev(ent,pev_maxs, MaxBox)
		
					//check health and remove entity with some effects       
					new health = pev(ent,pev_health) 
					
					if( health <= 5000000.0 ) {

						remove_naruto_ent_wpn(i)
						sh_chat_message(i, gHeroID, "¡Tu clon de sombra fue derrotado! Ahora desaparecera.")
						
						return FMRES_IGNORED
					}
					
					find_target(ent,i)
				
					if ( rasenganover[i] ) {
						
						doingrasengan[i] = false
						rasenganover[i] = false
						entity_set_model(entWeapon[i], g_Model_Pclon)
						entity_set_int(entWeapon[i], EV_INT_rendermode, kRenderFxNone) 
						entity_set_float(entWeapon[i], EV_FL_renderamt, 255.0)
					}
						
					if (doingrasengan[i] == false && pev_valid(ent) && botEnt[i]) {	
						
						if(get_user_button(i)&IN_DUCK && pev(ent,pev_solid) != SOLID_NOT)
						{
							if (DoOnce[i]) {
								origin2[2] -= 20
								set_pev(ent,pev_origin,origin2)
								DoOnce[i] = false
							}
							set_pev(ent,pev_sequence,5)
							set_pev(ent,pev_gaitsequence,5)
							set_pev(ent,pev_framerate,1.0)
						} 
						else if(get_user_button(i)&IN_DUCK && pev(ent,pev_solid) == SOLID_NOT)
						{
							if (DoOnce[i]) {
								origin2[2] -= 20
								set_pev(ent,pev_origin,origin2)
								DoOnce[i]=false
							}
							set_pev(ent,pev_sequence,2)
							set_pev(ent,pev_gaitsequence,2)
							set_pev(ent,pev_framerate,1.0)
						}
						else if (!DoOnce[i] && !is_user_crouching(i))
							{	
								origin2[2] += 20
								set_pev(ent,pev_origin,origin2)
								DoOnce[i] = true
				
							} 
						else if(get_user_button(i)&IN_JUMP)
						{
							set_pev(ent,pev_sequence,5)
							set_pev(ent,pev_gaitsequence,5)
							set_pev(ent,pev_framerate,1.0)
						} 
						else if(Naruto_Distance>=95.0)
						{
							set_pev(ent,pev_sequence,4)
							set_pev(ent,pev_gaitsequence,4)
							set_pev(ent,pev_framerate,1.0)
						} 
						else if(Naruto_Distance<95.0)
						{
							set_pev(ent,pev_sequence,1)
							set_pev(ent,pev_gaitsequence,1)
							set_pev(ent,pev_framerate,1.0)
						} 
						
						if(Naruto_Distance>450.0)
						{
							set_pev(ent,pev_origin,origin)
						}
						else if(Naruto_Distance>375.0)
						{ 
							get_speed_vector(origin2,origin,2000.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>350.0)
						{ 
							get_speed_vector(origin2,origin,get_user_maxspeed(i)*2.0,velocity)
							set_pev(ent,pev_velocity,velocity)
							
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>300.0)
						{ 
							get_speed_vector(origin2,origin,get_user_maxspeed(i)+200.0,velocity)
							set_pev(ent,pev_velocity,velocity)
							
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>250.0)
						{ 
							get_speed_vector(origin2,origin,get_user_maxspeed(i)+140.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>200.0)
						{ 
							get_speed_vector(origin2,origin,get_user_maxspeed(i)+75.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>140.0)
						{
							get_speed_vector(origin2,origin,get_user_maxspeed(i)+55.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>120.0)
						{
							get_speed_vector(origin2,origin,get_user_maxspeed(i)-20.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>=95.0)
						{
							get_speed_vector(origin2,origin,get_user_maxspeed(i)-20.0,velocity)
							set_pev(ent,pev_velocity,velocity)
			
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance>=75.0)
						{
							drop_to_floor(ent)
			
							set_pev(ent,pev_velocity,Float:{0.0,0.0,0.0})
							
							if(pev(ent,pev_solid) != SOLID_BBOX)
							{
								set_pev(ent,pev_solid, SOLID_BBOX)
							}
						}
						else if(Naruto_Distance<75.0)
						{
							drop_to_floor(ent)
			
							set_pev(ent,pev_velocity,Float:{0.0,0.0,0.0})
							
							if(pev(ent,pev_solid) != SOLID_NOT)
							{
								set_pev(ent,pev_solid, SOLID_NOT)
							}
						}

							
					}
					
					set_pev(botEnt[i],pev_nextthink, 0.1)
					return FMRES_IGNORED
				}
			}
		}
	}
	// maybe its not necesary
	// else if (botEnt[i]) remove_naruto_ent_wpn(i) 
	return FMRES_IGNORED
}
//-----------------------------------------------------------------------------------------
//			EFFECTS FIND TARGET N TARGET FOUND
//-----------------------------------------------------------------------------------------
public find_target(ent, i)
{
	if( pev_valid(ent) && ent==botEnt[i] ) {
		
		if ( !is_user_alive(i) || !is_user_connected(i) || !pev_valid(i) ) return FMRES_IGNORED

		if ( !aimtargetfound[i] ) {
			new Float:idorigin[3]
			pev(i, pev_origin, idorigin)
			entity_set_aim(ent, idorigin)
		}
		
		new Float:TargetOrigin[3], Float:entorigin[3]
		pev(ent,pev_origin,entorigin)
		
		new shortestDistance = 1000
		new nearestPlayer = 0
		new distance
		
		// Find the closest enemy
		for (new vic = 0; vic < SH_MAXSLOTS; vic++) {
			
			if ( !is_user_alive(vic) ) continue
			if ( get_user_team(i) == get_user_team(vic) ) continue

			distance =  get_entity_distance(vic, ent)

			if ( distance <= shortestDistance ) {
				shortestDistance = distance
				nearestPlayer = vic
			}

			if ( nearestPlayer > 0 ) {
				pev(nearestPlayer, pev_origin, TargetOrigin)
				TargetOrigin[2] = entorigin[2]
				entity_set_aim(ent, TargetOrigin)
				aimtargetfound[i] = true

				if ( fm_is_ent_visible(ent,nearestPlayer) && !delay_shot[i] ) {
					
					target_found(ent, i, nearestPlayer)
					delay_shot[i] = true
					set_task(0.1, "undelay_shot", i)
				}
				
				return FMRES_IGNORED
			} else {
				aimtargetfound[i] = false
			}
		}
	}
	
	return FMRES_IGNORED
}

public undelay_shot(id) delay_shot[id] = false
	
public target_found(ent, owner, target)
{
	if ( !pev_valid(ent) || !pev_valid(owner) || !pev_valid(target) || botEnt[owner] == 0 ) return PLUGIN_HANDLED
	
	new Float:entOrigin[3], Float:targetOrigin[3]
	new Float:entOriginR[3]
	pev(ent,pev_origin,entOrigin)
	pev(target,pev_origin,targetOrigin)
	
	// !doingrasengan	or 	doingrasengan
	if ( !doingrasengan[owner] ) {
		tracer(entOrigin, targetOrigin)

		sh_extra_damage(target, owner, get_pcvar_num(pCvardamage), "Shadow Clone")
		
		emit_sound(ent, CHAN_VOICE, "weapons/m249-1.wav", 0.2, ATTN_NORM, 0, PITCH_NORM)
	}
	
	if ( doingrasengan[owner] ) {
		static Float:velocityR[3]
		get_speed_vector(entOrigin, targetOrigin, get_user_maxspeed(owner)+395.0, velocityR)
		// get_speed_vector(entOrigin, targetOrigin, 800.0, velocityR)
		set_pev(ent,pev_velocity,velocityR)
		
		set_pev(ent,pev_sequence,8)
		set_pev(ent,pev_gaitsequence,8)
		set_pev(ent,pev_framerate,1.0)

		if ( pev(ent,pev_solid) != SOLID_NOT || pev(ent,pev_movetype) != MOVETYPE_NOCLIP) {
			set_pev(ent,pev_solid, SOLID_NOT) 
			set_pev(ent,pev_movetype,MOVETYPE_NOCLIP)
		}
		
		if ( get_distance_f(entOrigin, targetOrigin) < 60.0 ) {
			
			entity_get_vector(ent, EV_VEC_origin, entOriginR)
			
			new RasenganExp[3]
			RasenganExp[0] = floatround(entOriginR[0])
			RasenganExp[1] = floatround(entOriginR[1])
			RasenganExp[2] = floatround(entOriginR[2])
			
			// Explosion (smoke, sound/effects)
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(3)				//TE_EXPLOSION
			write_coord(RasenganExp[0])
			write_coord(RasenganExp[1])
			write_coord(RasenganExp[2])
			write_short(gSpriteSmoke)		// model
			write_byte(50)				// scale in 0.1's
			write_byte(20)				// framerate
			write_byte(10)				// flags
			message_end()
			
			emit_sound(owner, CHAN_STATIC, g_Sound_RasenganExp, 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(ent, CHAN_STATIC, g_Sound_RasenganExp, 0.5, ATTN_NORM, 0, PITCH_NORM)
			
			if ( pev_valid(entWeapon[owner]) ) {
				entity_set_model(entWeapon[owner], g_Model_Pclon)
				entity_set_int(entWeapon[owner], EV_INT_rendermode, kRenderFxNone) 
				entity_set_float(entWeapon[owner], EV_FL_renderamt, 255.0)
			}
			
			doingrasengan[owner] = false
			rasenganover[owner] = false
			
			// damage rasengan do it
			if(pev_valid(target)) {
				sh_extra_damage(target, owner, get_pcvar_num(pCvarDMG_Rasengan), "Rasengan")
				emit_sound(target, CHAN_STATIC, g_Sound_RasenganExp, 0.5, ATTN_NORM, 0, PITCH_NORM)
			}
		} 
	}
	
	return PLUGIN_HANDLED
}

public weapon_model_to_clon(id)
{
	if ( pev_valid(entWeapon[id]) ) {
		if ( !doingrasengan[id] ) entity_set_model(entWeapon[id], g_Model_Pclon)
		else entity_set_model(entWeapon[id], g_Sprite_Rasengan)
		
		entity_set_int(entWeapon[id], EV_INT_rendermode, kRenderFxNone) 
		entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
	}
} 

public tracer(Float:start[3], Float:end[3]) 
{
	new startx[3], endx[3]
	FVecIVec( start, startx )
	FVecIVec( end, endx )
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_TRACER )
	write_coord( startx[0] )
	write_coord( startx[1] )
	write_coord( startx[2] )
	write_coord( endx[0] )
	write_coord( endx[1] )
	write_coord( endx[2] )
	message_end()
}
//-----------------------------------------------------------------------------------------
//				ADMIN CHECK N SUTPIDS CHECKS
//-----------------------------------------------------------------------------------------
public naruto_admincheck(id) 
{
	if ( !gHasNaruto[id] ) return
	
   	new accessLevel[10]
	get_pcvar_string(pcvarAdmin, accessLevel, 9)
	
	if (equali(accessLevel, "0")) return
   	
	// Para controlar si tiene admin
	if ( !(get_user_flags(id)&read_flags(accessLevel)) ) {
		sh_chat_message(id, gHeroID, "[Only Admin] Conseguite Admin Rata.")
      		client_cmd(id, "say drop %s", gHeroName)
		gHasNaruto[id] = false
   	}
}

public client_connect(id)
	if( gHasNaruto[id]) remove_naruto_ent_wpn(id)

public client_disconnected(id) 
	if( gHasNaruto[id] ) remove_naruto_ent_wpn(id)
//-----------------------------------------------------------------------------------------
//			For delay tu use the power
//-----------------------------------------------------------------------------------------
public sh_round_end() {
	round_delay = 0
	for (new id=1; id <= SH_MAXSLOTS; id++) 
		if( gHasNaruto[id] ) remove_naruto_ent_wpn(id)
}

public sh_round_new()
{
	if ( !round_delay) {
		round_delay = 1
		set_task(5.0,"roundstart_delay")
	}
}

public roundstart_delay() round_delay = 0
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
