// WONDER WOMAN! from DC Comics.
/* CVARS - copy and paste to shconfig.cfg

//Wonder Woman
wonderwoman_level 0
wonderwoman_health 100		//Default 100
wonderwoman_armor 100		//Default 100
wonderwoman_cooldown 45		//How long between each time she can use it (def 45)
wonderwoman_searchtime 45	//How long time she seaches for a target (def 45)

*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

//WC3 Entangling Roots Ripoff :D
#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Wonder Woman"
new bool:gHasWonWomanPowers[SH_MAXSLOTS+1]

new bool:issearching[SH_MAXSLOTS+1]

new m_iTrail, iBeam4, pcvarSearch, gPcvarCooldown, pcvarAdmin

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1]  
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Wonder Woman", "1.0", "AssKicR")
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("wonderwoman_level", "0")
	gPcvarCooldown	= register_cvar("wonderwoman_cooldown", "45")
	pcvarSearch	= register_cvar("wonderwoman_searchtime", "40")
	pcvarAdmin	= register_cvar("wonderwoman_adminflag", "p")
	

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Látigo!! (Admin Only!).", "Captura enemigos con tu Látigo!" );
	sh_set_hero_bind(gHeroID); 

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
}

public plugin_precache()
{
	iBeam4 	= precache_model("sprites/zbeam4.spr")
	m_iTrail= precache_model("sprites/smoke.spr")
	precache_sound("turret/tu_ping.wav")
	precache_sound("weapons/cbar_hitbod3.wav")
	precache_sound("weapons/electro5.wav")
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			gPlayerInCooldown[id] = false
			gHasWonWomanPowers[id] = true
			
			issearching[id] = false
			wonder_admincheck(id)
		}
		case SH_HERO_DROP: {
			gHasWonWomanPowers[id] = false;
			issearching[id] = false
			
		}
	}
	
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return
	if ( !is_user_alive(id) || !gHasWonWomanPowers[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		
		if ( issearching[id] || gPlayerUltimateUsed[id] ) {
			sh_sound_deny(id)
			return
		}	
		
		// this is for effects
		new parm[2], time_sound_repeat
		parm[0] = id
		parm[1] = get_pcvar_num(pcvarSearch)
		searchtarget(parm)
		
		// this for emit sound each second and print the user is search  a enemy
		time_sound_repeat = parm[1] / 10
		set_task(1.0, "emit_sound_search", id, _, _, "a", time_sound_repeat)
		sh_chat_message(id, gHeroID, "Esta buscando un objetivo.")
		
		// set cooldown
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds 
		}
	}
}
#if SEND_COOLDOWN
public sendWonWomanCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id]) 
}
#endif
//------------------------------------------------------------------------------------------------
//				Spawn y death n cooldown					//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasWonWomanPowers[id] ) {
		wonder_admincheck(id) 
		
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
	gPcvarRealCD[id] = sh_get_cooldown(id)
} 
//------------------------------------------------------------------------------------------------
//				Wonder Power effects	 					//
//------------------------------------------------------------------------------------------------
public emit_sound_search(id) 
	if ( issearching[id] )
		emit_sound(id, CHAN_ITEM, "turret/tu_ping.wav", 0.7, ATTN_NORM, 0, PITCH_NORM)

public searchtarget(parm[2])
{
	new id = parm[0]
	
	if ( !is_user_alive(id) ) {
		issearching[id] = false
		return
	}
	
	new enemy, body
	get_user_aiming(id, enemy, body)

	// if ( 0 < enemy <= 32 && !stunned[enemy] && get_user_team(id) != get_user_team(enemy) && is_user_alive(enemy) ) {
	if ( get_user_team(id) != get_user_team(enemy) && is_user_alive(enemy) ) {

		issearching[id] = false

		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( 22 ); 	//TE_BEAMFOLLOW
		write_short(enemy);	// entity
		write_short(m_iTrail );	// model
		write_byte( 10 ); 	// life
		write_byte( 5 );  	// width
		write_byte( 230 );	// r, g, b
		write_byte( 125 );	// r, g, b
		write_byte( 0 );	// r, g, b
		write_byte( 255 );	// brightness
		message_end();  	// move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)

		emit_sound(id,CHAN_ITEM, "weapons/cbar_hitbod3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
		// effects on enemy
		entangle(enemy)
		
		new Float:time_stun = 1.5
		sh_set_stun(enemy, time_stun, 10.0)
		set_user_gravity(enemy, 1.0)
		
		set_task(time_stun, "reset_effects", enemy)
	}
	else 	{
		issearching[id] = true

		// va descontando el tiempo de busqueda
		--parm[1]
		if ( parm[1] > 0 ) {
			set_task(0.1, "searchtarget", _, parm, 2)
		}
		else 	{
			issearching[id] = false
		}
	}
}

public reset_effects(id)
{
	sh_reset_max_speed(id)
	sh_reset_min_gravity(id)
}
//----------------------------------------------------------------------------------------------
//			This is for effects de aros
//----------------------------------------------------------------------------------------------
// Entangle Roots (DOESN'T WORK ON BOTS)
// public entangle(parm[2])
public entangle(id)
{
	// new id = parm[0]
	// new life = parm[1]
	new life = 100
	new radius = 20
	new counter = 0
	new origin[3]
	new x1, x2, y1, y2
	
	get_user_origin(id, origin)
	emit_sound(id, CHAN_STATIC, "weapons/electro5.wav", 0.7, ATTN_NORM, 0, PITCH_NORM)

	while (counter <= 7){
		if (counter == 0 || counter == 8)
			x1 = -radius
		else if (counter == 1 || counter == 7)
			x1 = -radius*100/141
		else if (counter == 2 || counter == 6)
			x1 = 0
		else if (counter == 3 || counter == 5)
			x1 = radius*100/141
		else if (counter == 4)
			x1 = radius

		if (counter <= 4)
			y1 = sqrt(radius*radius-x1*x1)
		else
			y1 = -sqrt(radius*radius-x1*x1)

		++counter
		if (counter == 0 || counter == 8)
			x2 = -radius
		else if (counter == 1 || counter == 7)
			x2 = -radius*100/141
		else if (counter == 2 || counter == 6)
			x2 = 0
		else if (counter == 3 || counter == 5)
			x2 = radius*100/141
		else if (counter == 4)
			x2 = radius

		if (counter <= 4)
			y2 = sqrt(radius*radius-x2*x2)
		else
			y2 = -sqrt(radius*radius-x2*x2)

		new height = 16+2*counter
		while (height > -40){

			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( 0 )
			write_coord(origin[0]+x1)
			write_coord(origin[1]+y1)
			write_coord(origin[2]+height)
			write_coord(origin[0]+x2)
			write_coord(origin[1]+y2)
			write_coord(origin[2]+height+2)
			write_short(iBeam4)	// model
			write_byte( 0 ) // start frame
			write_byte( 0 ) // framerate
			write_byte( life ) // life
			write_byte( 10 )  // width
			write_byte( 5 )	// noise
			write_byte( 320 )	// r, g, b
			write_byte( 125 )	// r, g, b
			write_byte( 0 )	// r, g, b
			write_byte( 255 )	// brightness
			write_byte( 0 )		// speed
			message_end()

			height -= 16
		}
	}
}
//------------------------------------------------------------------------------------------------
//				Connect y AdminCheck						//
//------------------------------------------------------------------------------------------------
public client_connect(id)
	gHasWonWomanPowers[id] = false

public wonder_admincheck(id) 
{
	if ( !gHasWonWomanPowers[id] ) return
	
   	new accessLevel[10]
	get_pcvar_string(pcvarAdmin, accessLevel, 9)
	
	if ( equali(accessLevel, "0") ) return
   	
	// Para controlar si tiene admin
	if ( !(get_user_flags(id)&read_flags(accessLevel)) ) {
		sh_chat_message(id, gHeroID, "[Only Admin] Conseguite Admin Rata.")
      		client_cmd(id, "say drop %s", gHeroName)
		gHasWonWomanPowers[id] = false
   	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/