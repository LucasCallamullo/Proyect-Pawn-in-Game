// Neo! - Right out of the Matrix!

/* CVARS - Copy and paste in shconfig.cfg

//Neo
neo_level 10		//Def=10
neo_flyspeed 1000	//Def=1000
neo_toggle 0		//Def=0

*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new gHeroName[] = "Neo"
new bool:gHasNeoPowers[SH_MAXSLOTS+1]

//Flying Ability
new bool: flytoggle[SH_MAXSLOTS+1] 
new Float: Velocity[SH_MAXSLOTS+1][3] 

// new gPcvarCheckOnGround
new gMsgSync, gPcvarCooldown, gPcvarClipTime, gPcvarSpeed, gSpeedNeo, gPcvarToggle

new gNeoTimer[SH_MAXSLOTS+1]

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1]  

new const g_ModelNeo[] = "models/player/neo/neo.mdl"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Neo", "1.1", "thechosenone")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel		= register_cvar("neo_level", "9")
	gPcvarSpeed		= register_cvar("neo_flyspeed","750")
  	gPcvarToggle		= register_cvar("neo_toggle","0")
	gPcvarCooldown		= register_cvar("neo_cooldown", "20")
	gPcvarClipTime 		= register_cvar("neo_cliptime", "9")
	//gPcvarCheckOnGround 	= register_cvar("neo_checkonground", "1")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Podes Volar!", "Ahora Sos Neo. Podes Volar!");
	sh_set_hero_bind(gHeroID); 
	
	// NEO LOOP
	set_task(1.0, "neo_loop", _, _, _, "b")
	
	// Waits 4 seconds then loads cvars into variables
	set_task(4.0,"loadCVARS")
	
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
	precache_model(g_ModelNeo)
	
public loadCVARS() {
	gSpeedNeo 	= get_pcvar_num(gPcvarSpeed)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			gHasNeoPowers[id] = true
			gPlayerInCooldown[id] = false
			neo_morph_unmorph(id)
			
			// Make sure looop doesn't fire for them
			gNeoTimer[id] = -1
		}
		case SH_HERO_DROP: {
			gHasNeoPowers[id] = false
			neo_morph_unmorph(id)
			neo_endmode(id)
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID ) return
	if ( !is_user_alive(id) || !gHasNeoPowers[id] ) return 
	
	switch(key) {
		case SH_KEYDOWN: {
			// if ( get_pcvar_num(gPcvarCheckOnGround) && !(pev(id, pev_flags)&FL_ONGROUND) ) return
	
			if ( gPlayerInCooldown[id] || gNeoTimer[id] > 0 ) {
				sh_sound_deny(id)
				return
			}
		  
			// If in toggle mode change this to a keyup event
			if ( get_pcvar_num(gPcvarToggle) && flytoggle[id] ) {
				stop_fly(id)
				return
			}
			
			loadCVARS()
			gNeoTimer[id] = get_pcvar_num(gPcvarClipTime)
			
			make_fly(id)
			
			// set_cooldown
			new Float:seconds = get_pcvar_float(gPcvarCooldown) 
			if ( seconds > 0.0 ) {
				sh_set_cooldown(id, seconds)
				gPcvarRealCD[id] = seconds
			} 	
		}
		case SH_KEYUP: {
			// toggle mode - keyup doesn't do anything!
			if ( get_pcvar_num(gPcvarToggle) ) return
			
			stop_fly(id)
		}
	}
}
#if SEND_COOLDOWN
public sendNeoCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id]) 
}
#endif

public neo_loop()
{	
	static players[SH_MAXSLOTS], playerCount, id, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		id = players[i]
		if ( !gHasNeoPowers[id] || !is_user_alive(id) || gNeoTimer[id] < 0 ) continue
		
		if ( gNeoTimer[id] > 0 ) { 
			set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
			ShowSyncHudMsg(id, gMsgSync, "%d segundo%s para dejar el Modo %s.", gNeoTimer[id], gNeoTimer[id] == 1 ? "" : "s", gHeroName)
		}
		else	{
			neo_endmode(id)
		}
		
		gNeoTimer[id]--
	}
}

public neo_endmode(id)
{
	if ( !is_user_connected(id) ) return
	
	if ( gNeoTimer[id] == 0 ) {
		set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.0, 1.5, 0.0, 0.0, 7) 
		ShowSyncHudMsg(id, gMsgSync, "Saliste del Modo %s, Necesitas descansar.", gHeroName)
	}
	
	gNeoTimer[id] = -1
	stop_fly(id)
}
//------------------------------------------------------------------------------------------------
//					Spawn n Death 						//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasNeoPowers[id] ) {
		neo_endmode(id)
		neo_tasks(id)
	
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
	if ( gHasNeoPowers[id] ) { 
		gPcvarRealCD[id] = sh_get_cooldown(id)
		neo_endmode(id)
	}
}

public neo_tasks(id) set_task(1.0, "neo_morph_unmorph", id)
	
public neo_morph_unmorph(id)
{
	if ( !is_user_alive(id) ) return
	if ( gHasNeoPowers[id] )	cs_set_user_model(id, "neo")
	else cs_reset_user_model(id)
}
//----------------------------------------------------------------------------------------------
// 			MAKE FLY WITH NEO
//----------------------------------------------------------------------------------------------
public make_fly(id) 
{
	// Neo Messsage
	set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.25, 1.2, 0.0, 0.0, 7)
	ShowSyncHudMsg(id, gMsgSync, "Entraste en Modo %s ^nVolarás durante este tiempo!", gHeroName)
	
	if ( flytoggle[id] )  { 
		stop_fly(id) 
		return 
	}
    
	if ( get_pcvar_num(gPcvarToggle) == 1 ) flytoggle[id] = true
    
	new parm[1] 
	parm[0] = id 
    
	set_user_gravity(id, 0.001) 
    
	set_task(0.1,"user_fly", 5327+id, parm,1, "b")
} 

public stop_fly(id) 
{ 
	sh_reset_max_speed(id)
	sh_reset_min_gravity(id)
	flytoggle[id] = false
	remove_task(5327+id)
}
//----------------------------------------------------------------------------------------------
//				DO IT NEO FLY
//----------------------------------------------------------------------------------------------
public user_fly(parm[]) 
{  
	new id 
	id = parm[0] 
    
	if( !is_user_alive(id) ) { 
		stop_fly(id)
		return
	}
	
	// FORWARD + MOVERIGHT + JUMP
	if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 45.0, 0)
	} 
	
	// FORWARD + MOVERIGHT + DUCK 
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK) { 
		neo_fly_recursivity(id, 45.0, 45.0, 0)
	} 
	
	// FORWARD + MOVELEFT + JUMP 
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 45.0, 1)
	} 
	
	// FORWARD + MOVELEFT + DUCK 
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK) {   
		neo_fly_recursivity(id, 45.0, 45.0, 1) 
	} 
	
	// BACK + MOVERIGHT + JUMP 
	else if(get_user_button(id)&IN_JUMP && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_BACK) { 
		neo_fly_recursivity(id, -45.0, 135.0, 0) 
	} 
	
	 // BACK + MOVERIGHT + DUCK 
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK) { 
		neo_fly_recursivity(id, 45.0, 135.0, 0)
	} 
	
	 // BACK + MOVELEFT + JUMP 
	else if(get_user_button(id)&IN_JUMP && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_BACK) { 
		neo_fly_recursivity(id, -45.0, 135.0, 1) 
	} 
	
	// BACK + MOVELEFT + DUCK 
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK) {  
		neo_fly_recursivity(id, 45.0, 135.0, 1)
	} 
	
	//  MOVERIGHT  + FORWARD 
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_FORWARD) { 
		neo_fly_recursivity(id, 0.0, 45.0, 0)
	} 
	
	// MOVERIGHT + BACK
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_BACK) { 
		neo_fly_recursivity(id, 0.0, 135.0, 0)
	} 
	
	// MOVELEFT + FORWARD
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_FORWARD) { 
		neo_fly_recursivity(id, 0.0, 45.0, 1) 
	} 
	
	// MOVELEFT + BACK 
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_BACK) { 
		neo_fly_recursivity(id, 0.0, 135.0, 1)
	} 
	
	// FORWARD + JUMP 
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 0.0, 1)
	} 
	
	// FORWARD + DUCK 
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_DUCK) { 
		neo_fly_recursivity(id, 45.0, 0.0, 1)
	} 
	
	 // BACK + JUMP 
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 180.0, 1)
	} 
	
	// BACK + DUCK 
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_DUCK) { 
		neo_fly_recursivity(id, 45.0, 180.0, 1)
	} 
	
	// MOVERIGHT + JUMP 
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 90.0, 0) 
	} 
	
	// MOVERIGHT + DUCK 
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK) { 
		neo_fly_recursivity(id, 45.0, 90.0, 0)
	} 
	
	 // MOVELEFT + JUMP 
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_JUMP) { 
		neo_fly_recursivity(id, -45.0, 90.0, 1) 
	} 
	
	// MOVELEFT + DUCK 
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK) {
		neo_fly_recursivity(id, 45.0, 90.0, 1)
	} 
	
	 // FORWARD 
	else if(get_user_button(id)&IN_FORWARD)
		VelocityByAim(id, gSpeedNeo, Velocity[id]) 
	
	// BACK 
	else if(get_user_button(id)&IN_BACK) 
		VelocityByAim(id, -gSpeedNeo , Velocity[id])
		
	 // DUCK
	else if(get_user_button(id)&IN_DUCK) { 
		Velocity[id][0] = 0.0 
		Velocity[id][1] = 0.0 
		Velocity[id][2] = -gSpeedNeo * 1.0 
	} 
	
	// JUMP 
	else if(get_user_button(id)&IN_JUMP) { 
		Velocity[id][0] = 0.0 
		Velocity[id][1] = 0.0 
		Velocity[id][2] = gSpeedNeo * 1.0 
	} 
	
	// MOVERIGHT 
	else if(get_user_button(id)&IN_MOVERIGHT) { 
		neo_fly_recursivity(id, 0.0, 90.0, 0)
	} 
	
	// MOVELEFT
	else if(get_user_button(id)&IN_MOVELEFT) { 
		neo_fly_recursivity(id, 0.0, 90.0, 1)
	} 
	
	else { 
		Velocity[id][0] = 0.0 
		Velocity[id][1] = 0.0 
		Velocity[id][2] = 0.0 
	} 

	entity_set_vector(id, EV_VEC_velocity, Velocity[id]) 
    
	new Float: pOrigin[3] 
	new Float: zOrigin[3] 
	new Float: zResult[3] 
    
	entity_get_vector(id, EV_VEC_origin, pOrigin) 
    
	zOrigin[0] = pOrigin[0] 
	zOrigin[1] = pOrigin[1] 
	zOrigin[2] = pOrigin[2] - 1000 
    
	trace_line(id,pOrigin, zOrigin, zResult) 
	
	if ( !is_user_alive(id) ) return
	
	if ( entity_get_int(id, EV_INT_sequence) != 8 && (zResult[2] + 100) < pOrigin[2] && (Velocity[id][0] > 0.0 && Velocity[id][1] > 0.0 && Velocity[id][2] > 0.0) ) 
		entity_set_int(id, EV_INT_sequence, 8) 
} 

public neo_fly_recursivity(id, Float:v0_n, Float:v1_n, plus_or_min)
{
	new Float: xAngles[3] 
	new Float: xOrigin[3] 
	new xEnt
	
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin) 

	xEnt = create_entity("info_target") 
	if(xEnt == 0) {  
		return // PLUGIN_HANDLED_MAIN 
	} 
     
	xAngles[0] = v0_n
	
	if ( plus_or_min == 0 )
		xAngles[1] -= v1_n
	else
		xAngles[1] += v1_n
		
	entity_set_origin(xEnt, xOrigin) 
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, gSpeedNeo, Velocity[id]) 
	remove_entity(xEnt)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
