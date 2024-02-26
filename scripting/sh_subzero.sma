//Sub-Zero From Mortal Kombat

//Credits go to SRGety for forge

/*
//Subzero
subzero_level 0 //At what level is this hero available
subzero_cooldown  2.0 //cooldown for his ice balst
subzero_blastspeed 600 //Speed of SubZero's ice blast
subzero_freezetime 5 //for How long is the player Freezed
subzero_freezeradius 50 //radius for the ice blast
subzero_freezedamage 35 //how much damage the ice blast does

*/
/*
* Version 1.0 Posted
* Version 1.1 Better Freeze Effect + a Freeze Sound
* Version 1.1 Fully converted to amxmodx
*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

new gHeroID
new gHeroName[] = "Sub-Zero"
new bool:g_HasSubZeroPower[SH_MAXSLOTS+1]

new blastring, gPcvarCooldown, gPcvarBlastSpeed, gPcvarFreezeTime, gPcvarRadius, gPcvarDamage

new freezeradius, freezedamage, Float: seconds

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1]  

// models for the hero
new const gEnt_Blast_Name[] = "ice_blast"
new const gEnt_Blast_Model[] = "sprites/shmod/iceball.spr"

new const gEnt_Freezed_Model[] = "models/shmod/freezed.mdl"
new const gEnt_Freezed_Name[] = "freezed"

new const gSound_Blast[] = "shmod/freezed.wav"
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Sub-Zero","1.2","Om3gA/Yang")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	new pcvarLevel 		= register_cvar("subzero_level", "7" )
	gPcvarCooldown		= register_cvar("subzero_cooldown", "2.0")
	gPcvarBlastSpeed	= register_cvar("subzero_blastspeed", "600")
	gPcvarFreezeTime	= register_cvar("subzero_freezetime", "5" )
	gPcvarRadius		= register_cvar("subzero_freezeradius", "50")
	gPcvarDamage		= register_cvar("subzero_freezedamage", "35")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Ice Blast!", "Dispara una Bola de Hielo para Congelar a tus Enemigos.")
	sh_set_hero_bind(gHeroID)

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// TOUCH EVENT
	register_touch(gEnt_Blast_Name,"*","frozen")
	
	// Waits 4 seconds then loads cvars into variables
	set_task(4.0,"loadCVARS")
}

public plugin_precache()
{
	precache_model(gEnt_Blast_Model)
	precache_sound(gSound_Blast)
	precache_model(gEnt_Freezed_Model)
	blastring = precache_model("sprites/white.spr")
}

public loadCVARS() 
{
	freezeradius = get_pcvar_num(gPcvarRadius)
	freezedamage = get_pcvar_num(gPcvarDamage)
	seconds = get_pcvar_float(gPcvarFreezeTime)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			g_HasSubZeroPower[id] = true
			gPlayerInCooldown[id] = false
		}
		case SH_HERO_DROP: {
			g_HasSubZeroPower[id] = false
			RemoveByClass()
		}
	}
	
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || sh_is_freezetime() ) return
	if ( !is_user_alive(id) || !g_HasSubZeroPower[id] ) return

	if ( key == SH_KEYDOWN ) {
	
		if ( gPlayerInCooldown[id] ) {
			sh_sound_deny(id)
			return
		}
		
		make_iceblast(id)
		
		// Set Cooldown
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
	}
}
#if SEND_COOLDOWN
public sendSubZeroCooldown(id)
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
	if ( g_HasSubZeroPower[id] ) {
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

public sh_client_death(id) 
{
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( g_HasSubZeroPower[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//------------------------------------------------------------------------------------------------
//				Mak eIceblast and Remove Entity					//
//------------------------------------------------------------------------------------------------
public make_iceblast(id)
{
	new Float:Origin[3], Float:Velocity[3], Float:vAngle[3]

	static BlastSpeed
	BlastSpeed = get_pcvar_num(gPcvarBlastSpeed)

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	new NewEnt = create_entity("info_target")

	entity_set_string(NewEnt, EV_SZ_classname, gEnt_Blast_Name)

	entity_set_model(NewEnt, gEnt_Blast_Model)

	entity_set_size(NewEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5})

	entity_set_origin(NewEnt, Origin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle)
	entity_set_int(NewEnt, EV_INT_solid, 2)

	//thanx to vittu for this part.
	entity_set_int(NewEnt, EV_INT_rendermode, 5)
	entity_set_float(NewEnt, EV_FL_renderamt, 200.0)
	entity_set_float(NewEnt, EV_FL_scale, 1.00)

	entity_set_int(NewEnt, EV_INT_movetype, 5)
	entity_set_edict(NewEnt, EV_ENT_owner, id)

	velocity_by_aim(id, BlastSpeed , Velocity)
	entity_set_vector(NewEnt, EV_VEC_velocity ,Velocity)
}

public RemoveByClass()
{
	new frozenground = 0
	do {
		frozenground = find_ent_by_class(frozenground, gEnt_Freezed_Name)
		if (frozenground > 0)
			remove_entity(frozenground)
	}
	while (frozenground)

	// agregado para eliminar los ice blast al final de la ron da
	new NewEnt = 0
	do {
		NewEnt = find_ent_by_class(NewEnt, gEnt_Blast_Name)
		if (NewEnt > 0)
			remove_entity(NewEnt)
	}
	while (NewEnt)
}

public sh_round_end()
	RemoveByClass()
//------------------------------------------------------------------------------------------------
//				TOUCH EVENT ENTITY				//
//------------------------------------------------------------------------------------------------
public frozen(pToucher, pTouched)
{
	if ( !is_valid_ent(pToucher) ) return
	
	static szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if ( equal(szClassName, gEnt_Blast_Name) ) {
		
		// idk why this two arrays
		static Float:fl_vExplodeAt[3], vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		
		// this is for loop for to ptouched
		static origin[3], Float:dRatio, dist, damage, id
		static players[SH_MAXSLOTS], pnum, vic, i
		get_players(players, pnum, "a")
		
		id = entity_get_edict(pToucher, EV_ENT_owner)
		for ( i = 0; i < pnum; i++ ) {
			
			vic = players[i]
			if ( !is_user_alive(vic) || id == vic ) continue
			if ( get_user_team(id) == get_user_team(vic) && !get_cvar_num("mp_friendlyfire") ) continue
			
			get_user_origin(vic, origin)
			dist = get_distance(origin, vExplodeAt)
			
			if (dist <= freezeradius) { 	
				dRatio = floatdiv(float(dist), float(freezeradius))
				damage = freezedamage - floatround(freezedamage * dRatio)

				sh_extra_damage(vic, id, damage, "Ice Blast")
				sh_set_stun(vic, seconds, 0.1)
				
				set_hudmessage(50, 100, 255, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
				show_hudmessage(vic, "Te congelo Sub-Zero.")
				
				emit_sound(vic, CHAN_WEAPON, gSound_Blast, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				freezed(pTouched)
			}
		}
			
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte( 21 )
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2] + freezeradius )
		write_short( blastring )
		write_byte( 0 ) // startframe
		write_byte( 1 ) // framerate
		write_byte( 6 ) // 3 life 2
		write_byte( 2 ) // width 16
		write_byte( 1 ) // noise
		write_byte( 50 ) // r
		write_byte( 50 ) // g
		write_byte( 255 ) // b
		write_byte( 200 ) //brightness
		write_byte( 0 ) // speed
		message_end()

		remove_entity(pToucher)
	}
}

public freezed(victim)
{
	new Float:vOrigin[3]
	entity_get_vector(victim, EV_VEC_origin, vOrigin)
	vOrigin[2] -= 25
	
	new frozenground = create_entity("info_target")
	entity_set_string(frozenground, EV_SZ_classname, gEnt_Freezed_Name)
	entity_set_model(frozenground, gEnt_Freezed_Model)
	entity_set_size(frozenground, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5})
	entity_set_int(frozenground, EV_INT_solid, 0)
	entity_set_int(frozenground,EV_INT_movetype, MOVETYPE_NOCLIP)
	entity_set_vector(frozenground, EV_VEC_origin, vOrigin)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
