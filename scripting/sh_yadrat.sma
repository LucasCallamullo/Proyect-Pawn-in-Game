/* Firestarter 1.0 (by Corvae aka TheRaven)

I've worked on a new teleportation script for my mod
and after finishing it, I thought I could as well put
it to some use in a hero. The idea is simple. You
teleport to where you point your crosshair and there
you explode damaging you the ones around you.


CVARS - copy and paste to shconfig.cfg
--------------------------------------------------------------------------------------------------
//Firestarter
Firestarter_level 6				// Character level to take this hero.
Firestarter_cooldown 10			// Time to wait until you can use the special ability again.
Firestarter_delay 0.6			// The delay between keypress and teleport. You are frozen as well.
Firestarter_mindamage 100		// Minimum damage the explosion does.
Firestarter_maxdamage 250		// Maximum damage the explosion does.
Firestarter_reducedamage 25		// The firestarter himself takes this less damage.
Firestarter_radius 400			// Radius for the explosion
--------------------------------------------------------------------------------------------------*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <amxmod>
#include <Vexd_Utilities>
#include <superheromod>

new gHeroID
new gHeroName[]="Yadrat"
new bool:g_hasFirestarterPower[SH_MAXSLOTS+1]
new newLocation[SH_MAXSLOTS+1][3]
new gLastPosition[SH_MAXSLOTS+1][3]
new checkLocation[SH_MAXSLOTS+1][3]

new smoke, white, fire, gPcvarReduceDmg, gPcvarDelay
new gPcvarCooldown, gPcvarMinDmg, gPcvarMaxDmg, gPcvarRadius
#if SEND_COOLDOWN
	new Float:YadratUsedTime[SH_MAXSLOTS+1]
#endif
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Yadrat","1.0","TheRaven aka Corvae")

	new pcvarLevel	= register_cvar("Firestarter_level", "6" )
	gPcvarCooldown	= register_cvar("Firestarter_cooldown", "10")
	gPcvarDelay	= register_cvar("Firestarter_delay", "0.6" )
	gPcvarMinDmg	= register_cvar("Firestarter_mindamage", "100" )
	gPcvarMaxDmg	= register_cvar("Firestarter_maxdamage", "250" )
	gPcvarReduceDmg	= register_cvar("Firestarter_reducedamage", "25" )
	gPcvarRadius	= register_cvar("Firestarter_radius", "10" )

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Teletransportación Yadrat", "Te teletrasportas al punto en tu Mira y Creas un Explosión. - Pone en say /bind para aprender a bindear.");
	sh_set_hero_bind(gHeroID); 
}

public plugin_precache()
{
	smoke = precache_model("sprites/steam1.spr")
	white = precache_model("sprites/white.spr")
	fire = precache_model("sprites/explode1.spr")
	precache_sound( "buttons/blip2.wav")
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
	if ( heroID != gHeroID || !sh_is_inround() ) return PLUGIN_HANDLED;
	if ( !is_user_alive(id) || !g_hasFirestarterPower[id] ) return PLUGIN_HANDLED;
    
	if ( key == SH_KEYDOWN ) {
		
		if ( gPlayerUltimateUsed[id] ) {
			playSoundDenySelect(id)
			return PLUGIN_HANDLED
		}
		
		new Float:seconds = get_pcvar_float(gPcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			#if SEND_COOLDOWN
				YadratUsedTime[id] = get_gametime()
			#endif
		}
		
		Firestarter_go(id)
	}
	
	return PLUGIN_HANDLED
}
#if SEND_COOLDOWN
public sendYadratCooldown(id)
{
	new cooldown
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(gPcvarCooldown) - get_gametime() + YadratUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif

public sh_client_spawn(id)
	gPlayerUltimateUsed[id] = false
//------------------------------------------------------------------------------------------------
//				Efectos de Teletransportaci�n					//
//------------------------------------------------------------------------------------------------
public Firestarter_go(id)
{
	new oldLocation[3]

	get_user_origin(id, oldLocation)
	oldLocation[2] += 30
	checkLocation[id][0] = oldLocation[0]
	checkLocation[id][1] = oldLocation[1]
	checkLocation[id][2] = oldLocation[2]
	
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
	
	new Float:Firestarterdelay = get_pcvar_float(gPcvarDelay)
	if (Firestarterdelay < 0.0) Firestarterdelay = 0.0
	
	shStun(id, get_pcvar_num(gPcvarDelay))
	set_user_maxspeed(id, -1.0)

	set_task(Firestarterdelay,"NewTeleport", id+25487)
	return PLUGIN_HANDLED
}

public NewTeleport(id)
{	
	id -= 25487
	set_user_origin(id, newLocation[id])
	set_task(0.1,"NewTeleportCheck",id)
	return PLUGIN_HANDLED
}

public NewTeleportCheck(id)
{
	new origin[3]
	new velocity[3]

	if ( !is_user_alive(id) ) return

	get_user_origin(id, origin, 0)
	gLastPosition[id][0]=origin[0]
	gLastPosition[id][1]=origin[1]
	gLastPosition[id][2]=origin[2]

	new Float:vector[3]
	Entvars_Get_Vector(id, EV_VEC_velocity, vector)
	FVecIVec(vector, velocity)

	if ( velocity[0]==0 && velocity[1]==0 && velocity[2] ) {
		velocity[0]=50
		velocity[1]=50

		IVecFVec(velocity, vector)
		Entvars_Set_Vector(id, EV_VEC_velocity, vector)
	}

	set_task(0.5,"NewPositionCheck",id+25487)
}

public NewPositionCheck(id)
{
	id -= 25487
	new origin[3]

	if (!is_user_alive(id) ) return
	get_user_origin(id, origin, 0)
	if ( gLastPosition[id][0] == origin[0] && gLastPosition[id][1] == origin[1] && gLastPosition[id][2] == origin[2] && is_user_alive(id) ) {
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
	new damage, distanceBetween, name[32]
	
	new Xmindamage = get_pcvar_num(gPcvarMinDmg)
	new Xmaxdamage = get_pcvar_num(gPcvarMaxDmg)
	new Xreducedamage = get_pcvar_num(gPcvarReduceDmg)
	if ( Xmindamage>Xmaxdamage ) Xmindamage = 75
	if ( Xmindamage>Xmaxdamage ) Xmaxdamage = 125
	if ( Xreducedamage>Xmindamage ) Xreducedamage = Xmindamage
	
	get_user_name(id,name,31)
	new FFOn = get_cvar_num("mp_friendlyfire")
	new origin[3]
	get_user_origin(id,origin)
	explode(origin)

	for(new a = 1; a <= SH_MAXSLOTS; a++) {
		if( is_user_alive(a) && ( get_user_team(id) != get_user_team(a) || FFOn != 0 || a == id ) ) {
			new origin1[3]
			get_user_origin(a,origin1)

			distanceBetween = get_distance(origin, origin1 )
			if( distanceBetween < get_pcvar_num(gPcvarRadius) ) {
				new mindamage = Xmindamage - Xreducedamage
				new maxdamage = Xmaxdamage - Xreducedamage
				damage = random_num(mindamage, maxdamage)
				
				if( a!=id ) {
					sh_set_stun(a, 1.3, 300.0)
					sh_extra_damage(a, id, damage, "Firestarter")
				}
				//set_user_maxspeed(a, 300.0)
				//if( a!=id ) shExtraDamage(a, id, Xreducedamage, "Firestarter")
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
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
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
	message_end()

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
