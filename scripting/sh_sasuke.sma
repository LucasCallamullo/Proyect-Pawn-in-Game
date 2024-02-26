/* Requested by GodLike29 */

#include <superheromod>

#define PLUGIN "SuperHero Sasuke"
#define VERSION "1.2"
#define AUTHOR "Spider / update Lucas"

//Global Variables
new gHeroID
new gHeroName[] = "Sasuke";
new bool:gHasPowers[SH_MAXSLOTS+1];
new gIsBurning[SH_MAXSLOTS+1];
new gSpriteSmoke, gSpriteFire, gSpriteBurning;
new gPcvarNumBurns, gPcvarBurnDmg, gPcvarCooldown, gPcvarRegenHP, gPcvarHealth

// conts models
new const gSound_Katon[] = "shmod/katun.wav"
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Cvars
	new pcvarLevel	= register_cvar("sasuke_level","20");
	gPcvarHealth	= register_cvar("sasuke_hp","1200");
	new pcvarSpeed	= register_cvar("sasuke_speed","750");
	gPcvarRegenHP	= register_cvar("sasuke_regenhp","20");
	
	gPcvarCooldown	= register_cvar("sasuke_cooldown","0.1");
	gPcvarBurnDmg	= register_cvar("sasuke_burndmg","75");
	gPcvarNumBurns	= register_cvar("sasuke_numburns","5");
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Katon: Gokakyu no Jutsu!", "Dispara Bolas de Fuego, y Obtén la Fuerza del Clan Uchiha.");
	sh_set_hero_bind(gHeroID); 
	
	// Eventos
	sh_set_hero_hpap(gHeroID, gPcvarHealth)
	sh_set_hero_speed(gHeroID, pcvarSpeed)
	
	// LOOP
	set_task(1.0,"sasuke_loop", 0, "", 0, "b");
}

public plugin_precache()
{
	gSpriteSmoke = precache_model("sprites/steam1.spr")
	gSpriteFire = precache_model("sprites/explode1.spr")
	gSpriteBurning = precache_model("sprites/xfire.spr")
	precache_sound("ambience/burning1.wav")
	precache_sound("ambience/flameburst1.wav")
	precache_sound("scientist/c1a0_sci_catscream.wav")
	precache_sound("vox/_period.wav")
	precache_sound(gSound_Katon)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			gHasPowers[id] = true
			gPlayerInCooldown[id] = false
			
		}
		case SH_HERO_DROP: {
			gHasPowers[id] = false
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID ) return
	if ( !is_user_alive(id) || !gHasPowers[id] ) return 
	
	if ( key == SH_KEYDOWN ) {
			
		if ( get_user_team(id) < 1 || get_user_team(id) > 2 ) return
	
		if ( entity_get_int( id, EV_INT_waterlevel ) == 3 ) {
			sh_chat_message(id, -1, "[%s] No podes usar tu Jutsu debajo del agua.", gHeroName)
			playSoundDenySelect(id)
			return;
		}
		
		if ( gPlayerUltimateUsed[id] ) {
			playSoundDenySelect(id)
			return;
		}
		
		emit_sound(id, CHAN_WEAPON, "ambience/flameburst1.wav", 0.5, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(id, CHAN_WEAPON, gSound_Katon, 0.5, ATTN_NORM, 0, PITCH_NORM)
		
		sasuke_shits_fire(id)
	}
		
}
//----------------------------------------------------------------------------------------------
//START AFTERBURN SCRIPT ---> ALL CREDITS TO AFTERBURN AUTHOR!!!
//----------------------------------------------------------------------------------------------
public sasuke_shits_fire(id)
{
	new vec[3]
	new aimvec[3]
	new velocityvec[3]
	new length
	new speed = 10
	get_user_origin(id,vec)
	get_user_origin(id,aimvec,2)
	new dist = get_distance(vec,aimvec)
	
	new speed1 = 160
	new speed2 = 350
	new radius = 100
	
	if (dist < 50) {
		radius = 0
		speed = 5
	}
	else if (dist < 150) {
		speed1 = speed2 = 1
		speed = 5
		radius = 50
	}
	else if (dist < 200) {
		speed1 = speed2 = 1
		speed = 5
		radius = 90
	}
	else if (dist < 250) {
		speed1 = speed2 = 90
		speed = 6
		radius = 90
	}
	else if (dist < 300) {
		speed1 = speed2 = 140
		speed = 7
	}
	else if (dist < 350) {
		speed1 = speed2 = 190
		speed = 7
	}
	else if (dist < 400) {
		speed1 = 150
		speed2 = 240
		speed = 8
	}
	else if (dist < 450) {
		speed1 = 150
		speed2 = 290
		speed = 8
	}
	else if (dist < 500) {
		speed1 = 180
		speed2 = 340
		speed = 9
	}
	//Edited
	else if (dist < 1000) {
		speed1 = 200
		speed2 = 400
		speed = 18
		radius = 150
	}
	else if (dist > 1000) {
		speed1 = 300
		speed2 = 500
		speed = 35
		radius = 150
	}
	
	velocityvec[0] = aimvec[0] - vec[0]
	velocityvec[1] = aimvec[1] - vec[1]
	velocityvec[2] = aimvec[2] - vec[2]
	length = sqrt(velocityvec[0]*velocityvec[0] + velocityvec[1]*velocityvec[1] + velocityvec[2]*velocityvec[2])
	if (!length) length = 1
	velocityvec[0] = velocityvec[0]*speed / length
	velocityvec[1] = velocityvec[1]*speed / length
	velocityvec[2] = velocityvec[2]*speed / length
	
	new args[6]
	args[0] = vec[0]
	args[1] = vec[1]
	args[2] = vec[2]
	args[3] = velocityvec[0]
	args[4] = velocityvec[1]
	args[5] = velocityvec[2]
	
	set_task(0.1, "te_spray", 0, args, 6, "a", 2)
	check_burnzone(id, vec, aimvec, speed1, speed2, radius)
	
	if (get_pcvar_float(gPcvarCooldown) > 0.0) ultimateTimer(id, get_pcvar_float(gPcvarCooldown))
	//return PLUGIN_HANDLED;
}
//----------------------------------------------------------------------------------------------
public te_spray(args[])
{
	//TE_SPRAY
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(120)		// Throws a shower of sprites or models
	write_coord(args[0])	// start pos
	write_coord(args[1])
	write_coord(args[2])
	write_coord(args[3])	// velocity
	write_coord(args[4])
	write_coord(args[5])
	write_short(gSpriteFire)	// spr
	write_byte(8)		// count
	write_byte(70)		// speed
	write_byte(100)	// (noise)
	write_byte(5)		// (rendermode)
	message_end()
}

check_burnzone(id, vec[], aimvec[], speed1, speed2, radius)
{
	new tbody, tid
	get_user_aiming(id, tid, tbody, 9999)

	if (tid <= 0 || tid > SH_MAXSLOTS) return

	if ( get_cvar_num("mp_friendlyfire") == 1 ) {
		burn_victim(tid, id)
	}
	else if ( get_user_team(id) != get_user_team(tid) ) {
		burn_victim(tid, id)
	}

	new burnvec1[3],burnvec2[3],length1

	burnvec1[0] = aimvec[0]-vec[0]
	burnvec1[1] = aimvec[1]-vec[1]
	burnvec1[2] = aimvec[2]-vec[2]

	length1 = sqrt(burnvec1[0]*burnvec1[0] + burnvec1[1]*burnvec1[1] + burnvec1[2]*burnvec1[2])
	if (!length1) length1 = 1
	burnvec2[0] = burnvec1[0]*speed2 / length1
	burnvec2[1] = burnvec1[1]*speed2 / length1
	burnvec2[2] = burnvec1[2]*speed2 / length1
	burnvec1[0] = burnvec1[0]*speed1 / length1
	burnvec1[1] = burnvec1[1]*speed1 / length1
	burnvec1[2] = burnvec1[2]*speed1 / length1
	burnvec1[0] += vec[0]
	burnvec1[1] += vec[1]
	burnvec1[2] += vec[2]
	burnvec2[0] += vec[0]
	burnvec2[1] += vec[1]
	burnvec2[2] += vec[2]

	new origin[3]
	for (new i = 1; i <= SH_MAXSLOTS; i++) {
		if ( is_user_alive(i) && i != id && ( get_cvar_num("mp_friendly_fire") || get_user_team(id) != get_user_team(i) ) ) {
			get_user_origin(i, origin)
			if ( get_distance(origin, burnvec1) < radius ) {
				burn_victim(i, id)
				}
			else if ( get_distance(origin, burnvec2) < radius ) {
				burn_victim(i, id)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public burn_victim(id, killer)
{
	if ( entity_get_int( id, EV_INT_waterlevel ) == 3 ) return
	if ( gIsBurning[id] ) return

	gIsBurning[id] = 1

	emit_sound(id, CHAN_ITEM, "ambience/burning1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	new args[3]
	args[0] = id
	args[1] = killer
	set_task(0.3, "on_fire", 451, args, 3, "a", get_pcvar_num(gPcvarNumBurns))
	set_task(0.7, "fire_scream", 0, args, 3)
	set_task(5.5, "stopFireSound", id)
}
//----------------------------------------------------------------------------------------------
public on_fire(args[])
{
	new id = args[0]
	new killer = args[1]

	if( !is_user_connected(id) || !is_user_alive(id) ) {
		gIsBurning[id] = 0
		return
	}
	
	if( entity_get_int( id, EV_INT_waterlevel ) == 3 ) {
		gIsBurning[id] = 0
		return
	}
	
	if (!gIsBurning[id]) return

	new rx, ry, rz, forigin[3]
	rx = random_num(-30, 30)
	ry = random_num(-30, 30)
	rz = random_num(-30, 30)
	get_user_origin(id, forigin)

	//TE_SPRITE - additive sprite, plays 1 cycle
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(17)
	write_coord(forigin[0]+rx)	// coord, coord, coord (position)
	write_coord(forigin[1]+ry)
	write_coord(forigin[2]+10+rz)
	write_short(gSpriteBurning)	// short (sprite index)
	write_byte(30)				// byte (scale in 0.1's)
	write_byte(200)			// byte (brightness)
	message_end()

	//Smoke
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5)
	write_coord(forigin[0]+(rx*2))	// coord, coord, coord (position)
	write_coord(forigin[1]+(ry*2))
	write_coord(forigin[2]+100+(rz*2))
	write_short(gSpriteSmoke)	// short (sprite index)
	write_byte(60)				// byte (scale in 0.1's)
	write_byte(15)				// byte (framerate)
	message_end()

	new health = get_user_health(id)
	new damage = get_pcvar_num(gPcvarBurnDmg)
	//Prevents the shExtraDamage from saying you attacked a teammate for every cycle of the loop
	new LevelVictim = sh_get_user_lvl(id)
				
	if ( LevelVictim <= 16 ) {
		new extradamage = (damage/5)
		sh_extra_damage(id, killer, extradamage, "Katon!")
		}
	else 	{
		if(health - damage  <= 0) {
			sh_extra_damage(id, killer, damage, "Katon!")
			}
		else 	{
			set_user_health(id, health - damage)
			//let them know who is hurting them with a flame
			set_user_maxspeed(id, 300.0)
			
			new attackerName[32]
			get_user_name(killer, attackerName, 31)
			sh_chat_message(id, gHeroID, "[%s] Te está quemando con su Bola de Fuego! (Katon!).", attackerName)
		}
	}
}
//----------------------------------------------------------------------------------------------
public fire_scream(args[])
{
	emit_sound(args[0], CHAN_AUTO, "scientist/c1a0_sci_catscream.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public stopFireSound(id)
{
	new sndStop = (1<<5)
	gIsBurning[id] = 0
	emit_sound(id, CHAN_ITEM, "ambience/burning1.wav", 1.0, ATTN_NORM, sndStop, PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
//END AFTERBURN SCRIPT
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id) 
{ 
	gIsBurning[id] = 0;
	stopFireSound(id);
	
	if (gHasPowers[id]) gPlayerUltimateUsed[id] = false;
}

public sh_client_death(victim) 
{
	if ( gHasPowers[victim] )  {
		gIsBurning[victim] = 0;
		stopFireSound(victim);
	}
}

public sasuke_loop() 
{
	static players[SH_MAXSLOTS],pnum,id;
	get_players(players,pnum,"a")
	for (new i=0;i < pnum;i++) {
		id=players[i];
		if (gHasPowers[id]) {
			shAddHPs(id, get_pcvar_num(gPcvarRegenHP), get_pcvar_num(gPcvarHealth) );
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
