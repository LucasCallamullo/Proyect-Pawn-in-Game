/* Firestarter 1.0 (by Corvae aka TheRaven)

I've worked on a new teleportation script for my mod
and after finishing it, I thought I could as well put
it to some use in a hero. The idea is simple. You
teleport to where you point your crosshair and there
you explode damaging you the ones around you.


CVARS - copy and paste to shconfig.cfg
--------------------------------------------------------------------------------------------------

// Blink
blink_level 6			// Character level to take this hero.
blink_cooldown 10		// Time to wait until you can use the special ability again.
blink_maxdamage 250		// Maximum damage the explosion does.
blink_radius 400		// Radius for the explosion

--------------------------------------------------------------------------------------------------*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

new gHeroID
new gHeroName[] = "Blink"
new bool:g_hasFirestarterPower[SH_MAXSLOTS+1]

new newLocation[SH_MAXSLOTS+1][3]
new gLastPosition[SH_MAXSLOTS+1][3]
new checkLocation[SH_MAXSLOTS+1][3]

new smoke, white, fire
new gPcvarCooldown, gPcvarMaxDmg, gPcvarRadius

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

new const gSound_Hero[] = "shmod/blink_teleport.wav" 

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob"
}
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Yadrat","1.0","TheRaven aka Corvae")

	new pcvarLevel	= register_cvar("blink_level", "6" )
	gPcvarCooldown	= register_cvar("blink_cooldown", "10")
	gPcvarMaxDmg	= register_cvar("blink_maxdamage", "250" )
	gPcvarRadius	= register_cvar("blink_radius", "10" )

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Teletransportación Yadrat", "Te teletrasportas al punto en tu Mira y Creas un Explosión. - Pone en say /bind para aprender a bindear.");
	sh_set_hero_bind(gHeroID); 
}

public plugin_precache()
{
	smoke 	= precache_model("sprites/steam1.spr")
	white 	= precache_model("sprites/white.spr")
	fire 	= precache_model("sprites/explode1.spr")
	precache_sound(gSound_Hero)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			g_hasFirestarterPower[id] = true
			gPlayerInCooldown[id] = false
		}
		case SH_HERO_DROP: {
			g_hasFirestarterPower[id] = false;
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !g_hasFirestarterPower[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		
		if ( gPlayerUltimateUsed[id] ) {
			playSoundDenySelect(id)
			return
		}
		// Set Cooldown
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
		
		Firestarter_go(id)
	}
}
#if SEND_COOLDOWN
public sendBlinkCooldown(id)
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
	if ( g_hasFirestarterPower[id] ) {
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
	if ( g_hasFirestarterPower[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//------------------------------------------------------------------------------------------------
//				Efectos de Teletransportaci�n					//
//------------------------------------------------------------------------------------------------
public Firestarter_go(id)
{
	emit_sound(id, CHAN_AUTO, gSound_Hero, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	new oldLocation[3]
	get_user_origin(id, oldLocation)
	
	oldLocation[2] += 30
	checkLocation[id][0] = oldLocation[0]
	checkLocation[id][1] = oldLocation[1]
	checkLocation[id][2] = oldLocation[2]
	
	// aca obtengo el origen del aim vec
	get_user_origin(id, newLocation[id], 3)	
	
	if((newLocation[id][0] - oldLocation[0]) > 0)
		newLocation[id][0] -= 50
	else
		newLocation[id][0] += 50
	
	if((newLocation[id][1] - oldLocation[1]) > 0)
		newLocation[id][1] -= 50
	else
		newLocation[id][1] += 50
	
	newLocation[id][2] += 40
	
	set_user_origin(id, newLocation[id])
	set_task(0.1,"NewTeleportCheck",id)
}

public NewTeleportCheck(id)
{
	new origin[3]
	new velocity[3]

	// if ( !is_user_alive(id) ) return

	get_user_origin(id, origin, 0)
	gLastPosition[id][0] = origin[0]
	gLastPosition[id][1] = origin[1]
	gLastPosition[id][2] = origin[2]

	new Float:vector[3]
	entity_get_vector(id, EV_VEC_velocity, vector)
	FVecIVec(vector, velocity)
	
	if ( velocity[0]==0 && velocity[1]==0 && velocity[2] ) {
		velocity[0]=50
		velocity[1]=50

		IVecFVec(velocity, vector)
		entity_set_vector(id, EV_VEC_velocity, vector)
	}

	set_task(0.1,"NewPositionCheck",id+25487)
}

public NewPositionCheck(id)
{
	id -= 25487
	if ( !is_user_alive(id) ) return
	
	new origin[3]
	get_user_origin(id, origin, 0)
	if ( gLastPosition[id][0] == origin[0] && gLastPosition[id][1] == origin[1] && gLastPosition[id][2] == origin[2] ) {
		set_user_origin(id, checkLocation[id])
	} 
	else 	{
		setScreenFlash(id, 222, 76, 138, 10, 200 )
		BlowItUp(id)
	}
}
//------------------------------------------------------------------------------------------------
//				Efectos de Explosion, Damage					//
//------------------------------------------------------------------------------------------------
public BlowItUp(id)
{
	static max_damage, FFOn, damage_radius, id_noob
	max_damage 	= get_pcvar_num(gPcvarMaxDmg)
	damage_radius 	= get_pcvar_num(gPcvarRadius) 
	FFOn 		= get_cvar_num("mp_friendlyfire")
	id_noob 	= sh_get_hero_id(gOthers_Heros[0])
	
	new origin_id[3], damage, distanceBetween, Float:dRatio
	get_user_origin(id, origin_id)
	
	explode(origin_id)

	for(new vic = 1; vic <= SH_MAXSLOTS; vic++) {
		if ( !is_user_alive(vic) || vic == id ) continue
		
		if ( get_user_team(id) != get_user_team(vic) || FFOn ) {
			new origin_vic[3]
			get_user_origin(vic, origin_vic)

			distanceBetween = get_distance(origin_id, origin_vic )
			if ( distanceBetween < damage_radius ) {
				
				dRatio = float(distanceBetween) / float(damage_radius)
				damage = max_damage - floatround(max_damage * dRatio)
				
				if ( sh_user_has_hero(vic, id_noob) ) { 
					new noobdamage = ( damage / 3 )
					sh_extra_damage(vic, id, noobdamage, "Blink Explosion")
					sh_set_stun(vic, 0.5, 300.0) 
				}
				else 	{
					sh_extra_damage(vic, id, damage, "Blink Explosion")
					sh_set_stun(vic, 1.2, 300.0) 
				}
			}
		}
	}
}

public explode( vec1[3] )
{
	// blast circles
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 21 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1936)
	write_short( white )
	write_byte( 0 ) // startframe
	write_byte( 0 ) // framerate
	write_byte( 2 ) // life 2
	write_byte( 20 ) // width 16
	write_byte( 0 ) // noise
	write_byte( 188 ) // r
	write_byte( 220 ) // g
	write_byte( 255 ) // b
	write_byte( 255 ) //brightness
	write_byte( 0 ) // speed
	message_end()

	//Explosion2
	/* message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 12 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte( 188 ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	message_end()

	//TE_Explosion
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 3 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short( fire )
	write_byte( 60 ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	write_byte( 0 ) // byte flags
	message_end() */

	//Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 5 ) // 5
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short( smoke )
	write_byte( 10 )  // 2
	write_byte( 10 )  // 10
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
