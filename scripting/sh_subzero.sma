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

#include <amxmodx>
#include <superheromod>
#include <Vexd_Utilities>

new gHeroID
new gHeroName[]="Sub-Zero"
new bool:g_HasSubZeroPower[SH_MAXSLOTS+1]
new gLastWeapon[SH_MAXSLOTS+1]
new blastring, gPcvarCooldown, gPcvarBlastSpeed, gPcvarFreezeTime, gPcvarRadius, gPcvarDamage
#if SEND_COOLDOWN
	new Float:SubZeroUsedTime[SH_MAXSLOTS+1]
#endif
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
	register_touch("ice_blast","*","frozen")
}

public plugin_precache()
{
	precache_model("sprites/shmod/iceball.spr")
	precache_sound("shmod/freezed.wav")
	precache_model("models/shmod/freezed.mdl")
	blastring = precache_model("sprites/white.spr")
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
		}
		case SH_HERO_DROP: {
			g_HasSubZeroPower[id] = false
		}
	}
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || sh_is_freezetime() ) return PLUGIN_HANDLED
	if ( !is_user_alive(id) || !g_HasSubZeroPower[id] ) return PLUGIN_HANDLED

	if ( key == SH_KEYDOWN ) {
	
		if ( gPlayerInCooldown[id] ) {
			sh_sound_deny(id)
			return PLUGIN_HANDLED
		}
		
		new clip,ammo,weaponID = get_user_weapon(id,clip,ammo)
		gLastWeapon[id] = weaponID
		
		make_iceblast(id)
		// Sey Cooldown
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			#if SEND_COOLDOWN
				SubZeroUsedTime[id] = get_gametime()
			#endif
		}
	}
	
	return PLUGIN_HANDLED
}
#if SEND_COOLDOWN
public sendSubZeroCooldown(id)
{
	new cooldown
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(gPcvarCooldown) - get_gametime() + SubZeroUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
public sh_client_spawn(id)
{
	RemoveByClass(id)
	gPlayerUltimateUsed[id] = false
}
//------------------------------------------------------------------------------------------------
//				Mak eIceblast and Remove Entity					//
//------------------------------------------------------------------------------------------------
public make_iceblast(id)
{
	new Float:Origin[3]
	new Float:Velocity[3]
	new Float:vAngle[3]

	new BlastSpeed = get_pcvar_num(gPcvarBlastSpeed)

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	new NewEnt = create_entity("info_target")

	entity_set_string(NewEnt, EV_SZ_classname, "ice_blast")

	entity_set_model(NewEnt, "sprites/shmod/iceball.spr")

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

	return PLUGIN_HANDLED
}

public frozen(pToucher, pTouched)
{
	new szClassName[32]
	new victim = pTouched
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)

	if(equal(szClassName, "ice_blast") )
	{
		new freezeradius = get_pcvar_num(gPcvarRadius)
		new freezedamage = get_pcvar_num(gPcvarDamage)

		new Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		new id = entity_get_edict(pToucher, EV_ENT_owner)
		
		new origin[3], Float:dRatio, dist, damage
		new players[SH_MAXSLOTS], pnum, vic
		get_players(players, pnum, "a")
		for (new i = 0; i < pnum; i++) {
			vic = players[i]
			if (!is_user_alive(vic)) continue
			if (get_user_team(id) == get_user_team(vic) && !get_cvar_num("mp_friendlyfire") && id != vic ) continue
			
			get_user_origin(vic,origin)
			dist = get_distance(origin,vExplodeAt)
			if (dist <= freezeradius)
				{ 	
				dRatio = floatdiv(float(dist),float(freezeradius))
				damage = freezedamage - floatround( freezedamage * dRatio)
				// aca iba una i en lugar del vic (i=vic
				shExtraDamage(vic, id, damage, "Ice Blast" )
				shStun(vic, get_pcvar_num(gPcvarFreezeTime))
				set_user_maxspeed(vic, 0.1)
				set_hudmessage(50, 100, 255, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 2)
				show_hudmessage(vic, "Te congelo Sub-Zero.")
				emit_sound(vic, CHAN_WEAPON, "shmod/freezed.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				freezed(victim)
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
	entity_set_string(frozenground, EV_SZ_classname, "freezed")
	entity_set_model(frozenground, "models/shmod/freezed.mdl")
	entity_set_size(frozenground, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5})
	entity_set_int(frozenground, EV_INT_solid, 0)
	entity_set_int(frozenground,EV_INT_movetype, MOVETYPE_NOCLIP)
	entity_set_vector(frozenground, EV_VEC_origin, vOrigin)
}

public RemoveByClass(id)
{
	new frozenground = 0
	do {
		frozenground = find_ent_by_class(frozenground, "freezed")
		if (frozenground > 0)
			remove_entity(frozenground)
	}
	while (frozenground)

	// agregado para eliminar los ice blast al final de la ron da
	new NewEnt = 0
	do {
		NewEnt = find_ent_by_class(NewEnt, "ice_blast")
		if (NewEnt > 0)
			remove_entity(NewEnt)
	}
	while (NewEnt)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
