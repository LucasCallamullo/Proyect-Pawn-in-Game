// Based on Static Shock - and Based from Iron Man, with modifications by Lucas "Arje" Je :D

/* CVARS - copy and paste to shconfig.cfg

// Frozono

frozono_level 0
frozono_timer_loop 0.1		//How often (seconds) to run the loop
frozono_maxspeed 930		//Max Speed(def=930)
frozono_refill 1		//Armor Refill each second(def=1)
frozono_fuelcost 2		//Armor Used (def=2) ( = 0 its free armor )

*/

#include <superheromod> 

// GLOBAL VARIABLES
new gHeroID
new gHeroName[] = "Frozono"
new bool:gHasFrozono[SH_MAXSLOTS+1] 

new g_Run_Frozono_Disk[SH_MAXSLOTS+1]
new g_endLocation[SH_MAXSLOTS+1][3]
new ice[32]

// BECAUSE THIS LOOP IS CALLED SO MUCH - INSTEAD OF READING CVARS OVER AND OVER
// I'LL KEEP IN GLOBAL - FOR ANTI-LAG HOPEFULLY
new Float:gMaxSpeed, gFuelCost, gRefill, gPcvarTimer, g_spriteFire
new gPcvarFuelCost, gPcvarRefill, gPcvarSpeed

// models for hero
new const g_Frozono_Model[] = "models/shmod/frozono_disk.mdl" 
new const g_Frozono_Trail[] = "sprites/bubble.spr"
new const g_Sound[] = "roach/rch_smash.wav"
 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Frozono", "3.0", "Lucas ArJe :D")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new gPcvarLevel	= register_cvar("frozono_level", "0" )
	gPcvarRefill	= register_cvar("frozono_refill","1")
	gPcvarFuelCost	= register_cvar("frozono_fuelcost","1")
	gPcvarSpeed	= register_cvar("frozono_maxspeed", "980")
	gPcvarTimer	= register_cvar("frozono_timer_loop", "0.1")

	//THIS LINE MAKES THE HERO SELECTABLE 
	gHeroID = sh_create_hero(gHeroName, gPcvarLevel);
	sh_set_hero_info(gHeroID, "Movete rápido con hielo.", "Dónde está mi super traje mujer? - Pone en say /bind para aprender a bindear.");
	sh_set_hero_bind(gHeroID);
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// Waits 4 seconds then loads cvars into variables
	set_task(4.0,"loadCVARS")
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------ 
public sh_hero_init(id, heroID, mode) 
{ 
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasFrozono[id] = true;
				
				// remove residuals?
				remove_task(id+36485)
				g_Run_Frozono_Disk[id] = false
				
				set_task(get_pcvar_float(gPcvarTimer), "frozono_loop", id+36485, "", 0, "b")
			}
			case SH_HERO_DROP: {
				gHasFrozono[id] = false
				
				// remove residuals?
				remove_task(id+36485)
				g_Run_Frozono_Disk[id] = false
				
				remove_frozono_disk(id)
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
}

public sh_hero_key(id, heroid, key) 
{ 
	if ( heroid != gHeroID ) return;
	if ( !is_user_alive(id) || !gHasFrozono[id] ) return;
    
	switch(key) {
		case SH_KEYDOWN: {
			//Reload CVARS to make sure the variables are current
			loadCVARS()
			
			g_Run_Frozono_Disk[id] = true
			frozono_make_disk(id) 
		}
		case SH_KEYUP: {
			g_Run_Frozono_Disk[id] = false
			remove_frozono_disk(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
//				LOOP ONLY WITH THE HERO
//----------------------------------------------------------------------------------------------
public frozono_loop(id)
{
	id -= 36485
	
	if ( !is_user_alive(id) || !gHasFrozono[id] ) return PLUGIN_HANDLED
	
	new Float:velocity[3], Float:b_orig[3] 
	new origin[3], user_origin[3], aimvec[3]
	new userArmor

	// Increase armor for this guy
	userArmor = get_user_armor(id)
	if ( userArmor <= sh_get_max_ap(id) && !g_Run_Frozono_Disk[id] ) {
		set_user_armor(id, userArmor + gRefill)
		return PLUGIN_HANDLED
	} 

	// OK - We'll make this armor based - but also add armor
	// So you can run out of fuel, but get it back too
	if ( gFuelCost > userArmor && g_Run_Frozono_Disk[id] ) {
		sh_sound_deny(id)
		g_Run_Frozono_Disk[id] = false
		sh_chat_message(id, gHeroID, "Te deshidrataste! - Toma un poco de agua y espera a recuperar energia/armor.")
		
		remove_frozono_disk(id)
		return PLUGIN_HANDLED
	}
	
	get_user_origin(id, g_endLocation[id],3)
	if ( g_Run_Frozono_Disk[id] ) {

		// Decrement Fuel
		set_user_armor(id, userArmor - gFuelCost )
		emit_sound(id,CHAN_STATIC, g_Sound, 0.1, ATTN_NORM, 0, PITCH_LOW)
		
		get_user_origin(id, user_origin)

		entity_get_vector(id, EV_VEC_velocity, velocity)

		new distance
		distance = get_distance( g_endLocation[id], user_origin )
		velocity[0] = (g_endLocation[id][0] - user_origin[0]) * ( 1.0 * gMaxSpeed / distance)
		velocity[1] = (g_endLocation[id][1] - user_origin[1]) * ( 1.0 * gMaxSpeed / distance)
		velocity[2] = (g_endLocation[id][2] - user_origin[2]) * ( 1.0 * gMaxSpeed / distance)

		entity_set_vector(id, EV_VEC_velocity, velocity) 

  		new distance2[2]
		distance2[0] = g_endLocation[id][0] - user_origin[0] 
		distance2[1] = g_endLocation[id][1] - user_origin[1] 
   
		// stupid check for not division for 0
		new divisor_calculo = sqrt(distance2[0] * distance2[0] + distance2[1] * distance2[1])
		if ( divisor_calculo == 0 ) return PLUGIN_CONTINUE
		
		aimvec[0] = user_origin[0] + distance2[0] / divisor_calculo 
		aimvec[1] = user_origin[1] + distance2[1] / divisor_calculo  
		aimvec[2] = user_origin[2] - 34
		
		
		b_orig[0] = float(aimvec[0]); 
		b_orig[1] = float(aimvec[1]); 
		b_orig[2] = float(aimvec[2]); 
		
		if( !is_valid_ent(ice[id]) ) return PLUGIN_CONTINUE
		entity_set_origin(ice[id],  b_orig)

		get_user_origin(id, origin, 1)
		frozono_disk_effect(origin)
	}
	
	return PLUGIN_CONTINUE
}

public frozono_disk_effect(origin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(11)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]-34)
	message_end()
}
//----------------------------------------------------------------------------------------------
// 				MAKE ENTITY AND TRAIL IN ENTITY
//----------------------------------------------------------------------------------------------
public frozono_make_disk(id)
{
	new origin[3]
	get_user_origin(id, origin, 1)
	make_trail_n_disk(id, origin)

	get_user_origin(id, g_endLocation[id], 3)
}

public make_trail_n_disk(id, origin2[3])
{
	//Spawning ice below player    
  	new Float: Origin[3], Float: vAngle[3], Float: Velocity[3]
  	
	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	ice[id] = create_entity("info_target")
	entity_set_string(ice[id] , EV_SZ_classname, "ice_sheet") 	
	entity_set_model(ice[id] , g_Frozono_Model )
	
	new Float:MinBox[] = {-3.0, -1.0, -2.0};
	new Float:MaxBox[] = {1.0, 1.0, 3.0};
	entity_set_vector(ice[id], EV_VEC_mins, MinBox) 
	entity_set_vector(ice[id], EV_VEC_maxs, MaxBox)
	
	entity_set_vector(ice[id] , EV_VEC_origin, Origin)
	entity_set_vector(ice[id] , EV_VEC_angles, vAngle)
	
	entity_set_int(ice[id] , EV_INT_solid, 0)
	entity_set_int(ice[id] , EV_INT_movetype, 5)	
	entity_set_edict(ice[id] , EV_ENT_owner, id)
	
	VelocityByAim(id, 0 , Velocity)
	entity_set_vector(ice[id] , EV_VEC_velocity ,Velocity)
	
	if ( !is_user_alive(id) ) return 
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(22) 
	write_short(ice[id]) 
	write_short(g_spriteFire) 
	write_byte(40)    //life in 0.1 seconds
	write_byte(25)    //width of sprite
	write_byte(29)  //red
	write_byte(59)  //greem
	write_byte(82)  //blue
	write_byte(3000) //brightness
	message_end()
	
	sh_set_rendering(id, 57, 218, 255, 20, kRenderFxGlowShell)
}
//----------------------------------------------------------------------------------------------
// 			REMOVE ENTITY
//----------------------------------------------------------------------------------------------
public remove_frozono_disk(id)
{
	if ( !is_valid_ent(ice[id]) ) return
	
	if ( ice[id] ) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, {0,0,0}, ice[id])
		write_byte(99)
		write_short(ice[id])
		message_end()
		
		remove_entity(ice[id])
		ice[id] = 0
		
		sh_set_rendering(id)
	}
}

public sh_client_death(id) 
{
	if ( gHasFrozono[id] ) {
		remove_frozono_disk(id)
		g_Run_Frozono_Disk[id] = false
	}
}
//----------------------------------------------------------------------------------------------
//			Checks necesarys and precache
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
	// stupid check but lets see
	if ( id <=0 || id > SH_MAXSLOTS ) return

	// Yeah don't want any left over residuals
	remove_frozono_disk(id)
	remove_task(id+36485)
}

public plugin_precache()
{
	g_spriteFire = precache_model(g_Frozono_Trail) 
	precache_sound(g_Sound)
	precache_model(g_Frozono_Model)
}

public loadCVARS()
{
	gFuelCost 	= get_pcvar_num(gPcvarFuelCost)
	gRefill 	= get_pcvar_num(gPcvarRefill)
	gMaxSpeed 	= get_pcvar_float(gPcvarSpeed)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
