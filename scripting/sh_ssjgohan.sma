// SUPER SAIYAN GOHAN! - from Dragon Ball, Z, GT series. Gohan is Goku and Chi-Chi's first son.

/* CVARS - copy and paste to shconfig.cfg

//Super Saiyan Gohan
ssjgohan_level 9
ssjgohan_damage 125			//Damage spread over radius of blast (Default 125)
ssjgohan_radius 300			//Radius of the damage (Default 300)
ssjgohan_cooldown 30		//Seconds til next available use from power explode (Default 30)
ssjgohan_powerspeed 1000		//Speed of Kamehameha, min-500 max-2000 (Default 1000)

*/

/*
* v1.0 - vittu - 12/2/05
*      - Fixed to ssjgohan_blast_decals cvar named incorrectly in code.
*          Thanks to Om3g[A] for pointing it out.
*
* v1.0 - vittu - 9/17/05
*
*   Entity creation partially based on Bazooka, which is based on Missiles Launcher 3.8.2 by Eric Lidman & jtp10181.
*   Extra sprites and sounds used from Earth's Special Forces a HL mod - http://www.esforces.com/
*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

// GLOBAL VARIBLES
new gHeroID
new gHeroName[] = "Super Saiyan Gohan"
new bool:g_hasSSJGohan[SH_MAXSLOTS+1]

// power bar progress and info entity
new bool:g_chargeOver[SH_MAXSLOTS+1], g_powerID[SH_MAXSLOTS+1]

new g_spriteSmoke, g_spriteTrail, g_spriteExplosion, g_msgBarTime
new gPcvarCooldown, gPcvarSpeed, gPcvarRadius, gPcvarDamage
new dmgRadius, maxDamage, blastSize

static const g_burnDecal[3] = {28, 29, 30}
static const g_burnDecalBig[3] = {46, 47, 48}

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

// this is a constant name of entity
new const gEnt_Name[] = "ssjgohan_kamehameha"		

// constants models 
new const gEnt_Spr_Trail[] 	= "sprites/shmod/esf_trail_blue.spr"
new const gEnt_Spr_Explo[] 	= "sprites/shmod/esf_exp_blue.spr"
new const gEnt_Spr_Model[] 	= "sprites/shmod/esf_kamehameha_blue.spr"

new const gEnt_Sound_ha[] 	= "shmod/ssjgohan_ha2.wav"
new const gEnt_Sound_Hame_ha[] 	= "shmod/ssjgohan_kamehame.wav"
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Super Saiyan Gohan", "2.0", "vittu/lucas arje")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("ssjgohan_level", "8")
	gPcvarDamage	= register_cvar("ssjgohan_damage", "385")
	gPcvarRadius	= register_cvar("ssjgohan_radius", "500")
	gPcvarCooldown 	= register_cvar("ssjgohan_cooldown", "10") 
	gPcvarSpeed	= register_cvar("ssjgohan_powerspeed", "1000")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Kame Hame Ha! Guiada.", "Cargas una Kame Hame Ha con buen daño dirigible. - Pone en say /bind para aprender a bindear.");
	sh_set_hero_bind(gHeroID);
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// touch
	register_touch(gEnt_Name,"*","hame_ha_touch")
	
	// Progress bar effects
	g_msgBarTime = get_user_msgid("BarTime")
	
	// Waits 4 seconds then loads cvars into variables
	set_task(4.0,"loadCVARS")
}

public plugin_precache()
{
	precache_sound(gEnt_Sound_Hame_ha)
	precache_sound(gEnt_Sound_ha)
	precache_model(gEnt_Spr_Model)
	g_spriteTrail 		= precache_model(gEnt_Spr_Trail)
	g_spriteExplosion 	= precache_model(gEnt_Spr_Explo)
	g_spriteSmoke 		= precache_model("sprites/wall_puff4.spr")
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			g_hasSSJGohan[id] = true
			gPlayerInCooldown[id] = false
			g_chargeOver[id] = false
		}
		case SH_HERO_DROP: {
			g_hasSSJGohan[id] = false;
			// remove the power if it was used and user dropped hero
			if ( g_powerID[id] > 0 ) {
				remove_power(id, g_powerID[id])
			}	
		}
	}
	
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !g_hasSSJGohan[id] ) return;
    
	switch(key) {
		case SH_KEYDOWN: {
			// Prevent too many entities, which would cause server problems
			if ( gPlayerInCooldown[id] || g_powerID[id] ) {
				sh_sound_deny(id)
				sh_chat_message(id, gHeroID, "No tenes suficiente KI, debes esperar más." )
				// sh_chat_message(id, gHeroID, "Ahora estás listo, podes usar tu Kamehameha!")
				return
			}
			
			if ( !g_chargeOver[id] ) {
				emit_sound(id, CHAN_STATIC, gEnt_Sound_Hame_ha, 0.7, ATTN_NORM, 0, PITCH_NORM)
				progressBar(id, 3) 			// Show a progress bar for time til charge is full
				return
			}
			else 	{
				charge_sound_create_ssj(id)
				// Set some variables
				g_chargeOver[id] = false
			}
		}
	 
		case SH_KEYUP: {
			if ( !g_chargeOver[id] ||  g_powerID[id]  ) return
			 
			if ( g_chargeOver[id] ) charge_sound_create_ssj(id)
			
			progressBar(id, 0)			// Remove progress bar
		} 
	}
}

charge_sound_create_ssj(id) 
{
	if ( !g_chargeOver[id] ||  g_powerID[id]  ) return
	
	// Stop the sound
	new sndStop=(1<<5)
	emit_sound(id, CHAN_STATIC, gEnt_Sound_Hame_ha, 0.7, ATTN_NORM, sndStop, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, gEnt_Sound_ha, 0.7, ATTN_NORM, 0, PITCH_NORM)
	create_power(id)	
} 

#if SEND_COOLDOWN
public sendSSJGohanCooldown(id) 
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
	if ( g_hasSSJGohan[id] ) {
		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		// if is a new round set cooldown in zero
		else gPlayerInCooldown[id] = false
	}
	
	
	if ( g_powerID[id] > 0 ) remove_power(id, g_powerID[id] )
}

public sh_client_death(id) {
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( g_hasSSJGohan[id] ) 
		gPcvarRealCD[id] = sh_get_cooldown(id)
		
		
	if ( g_powerID[id] > 0 ) remove_power(id, g_powerID[id])
}

public client_disconnected(id)
	if ( g_powerID[id] > 0 ) remove_power(id, g_powerID[id])
//----------------------------------------------------------------------------------------------
//				Progress bar effects
//----------------------------------------------------------------------------------------------
public powerCharged(id) 
	g_chargeOver[id] = true

progressBar(id, seconds)
{
	// set_task(3.0, "powerCharged", id)
	if ( seconds > 0 ) set_task((seconds * 1.0), "powerCharged", id)
		
	//powerCharged(id)
	message_begin(MSG_ONE, g_msgBarTime, {0,0,0}, id)
	write_byte(seconds)
	write_byte(0)
	message_end()
}
//----------------------------------------------------------------------------------------------
//				CREATE N REMOVE ENTITY HAME HA
//----------------------------------------------------------------------------------------------
public create_power(id)
{
	if ( !g_chargeOver[id] ||  g_powerID[id]  ) return
	
	// Seting entSpeed higher then 2000.0 will not go where you aim
	// Vec Mins/Maxes must be below +/- 5.0 to make a burndecal
	new Float:fl_Origin[3], Float:fl_Angles[3], Float:fl_vAngle[3]
	new Float:VecMins[3] = {-2.0,-2.0,-2.0}
	new Float:VecMaxs[3] = {2.0,2.0,2.0}

	// Get users postion and angles (angles are probably not needed in this case)
	entity_get_vector(id, EV_VEC_origin, fl_Origin)
	entity_get_vector(id, EV_VEC_angles, fl_Angles)
	entity_get_vector(id, EV_VEC_v_angle, fl_vAngle)

	new newEnt = create_entity("info_target")
	if ( newEnt == 0 ) {
		sh_chat_message(id, gHeroID, "No pudiste completar tu Kame Hame Ha!")
		return
	} 

	g_powerID[id] = newEnt

	entity_set_string(newEnt, EV_SZ_classname, gEnt_Name)
	entity_set_model(newEnt, gEnt_Spr_Model)

	// Set entity size
	entity_set_vector(newEnt, EV_VEC_mins, VecMins)
	entity_set_vector(newEnt, EV_VEC_maxs, VecMaxs)

	// Change height of entity origin to hands
	fl_Origin[2] += 6

	// Set entity postion and angles
	entity_set_origin(newEnt, fl_Origin) 
	entity_set_vector(newEnt, EV_VEC_angles, fl_Angles)
	entity_set_vector(newEnt, EV_VEC_v_angle, fl_vAngle)

	// Set properties of the entity
	entity_set_int(newEnt, EV_INT_solid, 2)
	entity_set_int(newEnt, EV_INT_movetype, 5)
	entity_set_int(newEnt, EV_INT_rendermode, 5)
	entity_set_float( newEnt, EV_FL_renderamt, 255.0)
	entity_set_float( newEnt, EV_FL_scale, 1.20)
	entity_set_edict(newEnt, EV_ENT_owner, id) 

	// Create a VelocityByAim() function, but instead of users
	// eyesight make it start from the entity's origin - vittu
	new Float:fl_Velocity[3], AimVec[3], entOrigin[3]
	new Float:entSpeed = get_pcvar_float(gPcvarSpeed)

	// Change cvar incase they set it too high or too low
	if ( entSpeed > 2000.0 ) {
		debugMessage("[SH](Super Saiyan Gohan) ssjgohan_powerspeed cvar must not be set higher then 2000, defaulting to 2000", 0, 0)
		entSpeed = 2000.0
		set_pcvar_float(gPcvarSpeed, entSpeed)
	}
	else if ( entSpeed < 500.0 ) {
		debugMessage("[SH](Super Saiyan Gohan) ssjgohan_powerspeed cvar must not be set lower then 500, defaulting to 500", 0, 0)
		entSpeed = 500.0
		set_pcvar_float(gPcvarSpeed, entSpeed)
	}

	entOrigin[0] = floatround(fl_Origin[0])
	entOrigin[1] = floatround(fl_Origin[1])
	entOrigin[2] = floatround(fl_Origin[2])

	get_user_origin(id, AimVec, 3)

	new distance = get_distance(entOrigin, AimVec)

	// Stupid Check but lets make sure you don't devide by 0
	if ( !distance ) distance = 1

	new Float:Speed = entSpeed / distance

	fl_Velocity[0] = (AimVec[0] - fl_Origin[0]) * Speed
	fl_Velocity[1] = (AimVec[1] - fl_Origin[1]) * Speed
	fl_Velocity[2] = (AimVec[2] - fl_Origin[2]) * Speed

	entity_set_vector(newEnt, EV_VEC_velocity, fl_Velocity)

	new iNewVelocity[3], args[6]
	iNewVelocity[0] = floatround(fl_Velocity[0])
	iNewVelocity[1] = floatround(fl_Velocity[1])
	iNewVelocity[2] = floatround(fl_Velocity[2])

	// Pass varibles used to guide entity with
	args[0] = id
	args[1] = newEnt
	args[2] = floatround(entSpeed)
	args[3] = iNewVelocity[0]
	args[4] = iNewVelocity[1]
	args[5] = iNewVelocity[2]

	set_task(0.1, "guide_kamehameha", newEnt, args, 6)

	// Trail on enity. It's flawed by not being removable, so make it last long.
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)		// TE_BEAMFOLLOW
	write_short(newEnt)	// entity:attachment to follow
	write_short(g_spriteTrail)	// sprite index
	write_byte(100)	// life in 0.1's
	write_byte(8)		// line width in 0.1's
	write_byte(255)	//r,g,b
	write_byte(255)
	write_byte(255)
	write_byte(255)	// brightness
	message_end() 
}

public remove_power(id, powerID)
{
	new Float:fl_vOrigin[3]
	entity_get_vector(powerID, EV_VEC_origin, fl_vOrigin)

	// Create an effect of kamehameha being removed
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(14)		//TE_IMPLOSION
	write_coord(floatround(fl_vOrigin[0]))
	write_coord(floatround(fl_vOrigin[1]))
	write_coord(floatround(fl_vOrigin[2]))
	write_byte(120)	// radius
	write_byte(40)		// count
	write_byte(45)		// life in 0.1's
	message_end()

	// Stop the sounds - maybe its not necesary
	new sndStop=(1<<5)
	emit_sound(id, CHAN_STATIC, gEnt_Sound_ha, 1.0, ATTN_NORM, sndStop, PITCH_NORM)
	
	// set cooldowns
	new Float:seconds = get_pcvar_float(gPcvarCooldown)
	if ( seconds > 0.0 && g_powerID[id] > 0 ) {
		sh_set_cooldown(id, seconds)
		gPcvarRealCD[id] = seconds
	}
	
	// Reset Variables
	g_powerID[id] = 0
	g_chargeOver[id] = false
	
	remove_entity(powerID)
}
//----------------------------------------------------------------------------------------------
//				GUIDE EFFECT ENITY HAME HA
//----------------------------------------------------------------------------------------------
public guide_kamehameha(args[])
{
	new id = args[0]
	new entID = args[1]
	new speed = args[2]

	if ( !is_valid_ent(entID) ) return

	new Float:fl_Origin[3], AimVec[3]

	get_user_origin(id, AimVec, 3)
	entity_get_vector(entID, EV_VEC_origin, fl_Origin)

	new iNewVelocity[3], Origin[3], velocityVec[3]
	new  avgFactor, length

	Origin[0] = floatround(fl_Origin[0])
	Origin[1] = floatround(fl_Origin[1])
	Origin[2] = floatround(fl_Origin[2])

	if ( speed < 1000 )
		avgFactor = 6
	else if ( speed < 1500 )
		avgFactor = 4
	else
		avgFactor = 2

	velocityVec[0] = AimVec[0] - Origin[0]
	velocityVec[1] = AimVec[1] - Origin[1]
	velocityVec[2] = AimVec[2] - Origin[2]

	length = sqroot(velocityVec[0]*velocityVec[0] + velocityVec[1]*velocityVec[1] + velocityVec[2]*velocityVec[2])
	// Stupid Check but lets make sure you don't devide by 0
	if ( !length ) length = 1

	velocityVec[0] = velocityVec[0]*speed / length
	velocityVec[1] = velocityVec[1]*speed / length
	velocityVec[2] = velocityVec[2]*speed / length

	iNewVelocity[0] = ( velocityVec[0] + (args[3]*(avgFactor-1)) ) / avgFactor
	iNewVelocity[1] = ( velocityVec[1] + (args[4]*(avgFactor-1)) ) / avgFactor
	iNewVelocity[2] = ( velocityVec[2] + (args[5]*(avgFactor-1)) ) / avgFactor

	new Float:fl_iNewVelocity[3]
	fl_iNewVelocity[0] = float(iNewVelocity[0])
	fl_iNewVelocity[1] = float(iNewVelocity[1])
	fl_iNewVelocity[2] = float(iNewVelocity[2])

	entity_set_vector(entID, EV_VEC_velocity, fl_iNewVelocity)

	args[3] = iNewVelocity[0]
	args[4] = iNewVelocity[1]
	args[5] = iNewVelocity[2]

	set_task(0.1, "guide_kamehameha", entID, args, 6)
}
//----------------------------------------------------------------------------------------------
//				Touch EFFECT ENITY HAME HA
//----------------------------------------------------------------------------------------------
public loadCVARS() 
{
	dmgRadius = get_pcvar_num(gPcvarRadius)
	maxDamage = get_pcvar_num(gPcvarDamage)
	blastSize = floatround(dmgRadius / 12.0)
}

public hame_ha_touch(pToucher, pTouched) 
{
	if ( pToucher <= 0 ) return
	if ( !is_valid_ent(pToucher) ) return

	static szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)

	if ( equal(szClassName, gEnt_Name) ) {
		static id
		id = entity_get_edict(pToucher, EV_ENT_owner) 
		
		static Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)

		static vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])

		// Cause the Damage
		static vicOrigin[3], Float:dRatio,  distance, damage, level
		static players[SH_MAXSLOTS], pnum, vic, i
		get_players(players, pnum, "a")

		for ( i = 0; i < pnum; i++ ) {
			vic = players[i]
			if ( !is_user_alive(vic) ||  id == vic ) continue
			if ( get_user_team(id) == get_user_team(vic) && !get_cvar_num("mp_friendlyfire") ) continue
	
			get_user_origin(vic, vicOrigin)
			distance = get_distance(vicOrigin, vExplodeAt)

			if ( distance < dmgRadius ) {

				dRatio = floatdiv(float(distance), float(dmgRadius))
				damage = maxDamage - floatround(maxDamage * dRatio)

				// Lessen damage taken by self by half
				// if( vic == id ) damage = floatround(damage / 2.0)

				// Need hurt sound and small screen shake
				level = sh_get_user_lvl(vic)
				if ( level >= 17 ) {
					sh_extra_damage(vic, id, damage, "Kamehameha")
					sh_set_stun(vic, 1.8, 300.0) 
				}
				else 	{
					static extradamage 
					extradamage = (damage/5) 
					sh_extra_damage(vic, id, extradamage, "Kamehameha")
					sh_set_stun(vic, 1.0, 300.0) 
				}
				sh_screen_shake(vic, 92.0, 3.0, 92.0)

				// Make them feel it
				static Float:fl_vicVelocity[3]
				fl_vicVelocity[0] = ((vicOrigin[0] - vExplodeAt[0]) / distance) * 300.0
				fl_vicVelocity[1] = ((vicOrigin[1] - vExplodeAt[1]) / distance) * 300.0
				fl_vicVelocity[1] = 150.0

				entity_set_vector(vic, EV_VEC_velocity, fl_vicVelocity)
			}
		}

		// Make some Effects

		// Explosion Sprite
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(23)			//TE_GLOWSPRITE
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(g_spriteExplosion)	// model
		write_byte(01)			// life 0.x sec
		write_byte(blastSize)	// size
		write_byte(255)		// brightness
		message_end()

		// Explosion (smoke, sound/effects)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(3)			//TE_EXPLOSION
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(g_spriteSmoke)		// model
		write_byte(blastSize+5)	// scale in 0.1's
		write_byte(20)			// framerate
		write_byte(10)			// flags
		message_end()

		// Create Burn Decals, if they are used
		// Change burn decal according to blast size
		static decal_id
		if (blastSize <= 18) {
			//radius ~< 216
			decal_id = g_burnDecal[random_num(0,2)]
		}
		else {
			decal_id = g_burnDecalBig[random_num(0,2)]
		}

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(109)		//TE_GUNSHOTDECAL
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(0)			//?
		write_byte(decal_id)	//decal
		message_end()

		// reset variables n power
		remove_power(id, g_powerID[id])
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
