// Use el yoda y mis propio script jeje
/* CVARS - COPY AND PASTE INTO SHCONFIG.CFG

// Obi Wan - WARNING - THE SLAPS SENDS YOU PRETTY HIGH FLYING, MAY EASILY DIE CAUSE OF SLAPS
obi_level 10 // What level should he be available at? default = 10
obi_cooldown 8 // How long between each use in seconds? default = 8
obi_damage 0 // How much damage should the slaps do? default = 0 (Damage is applied one time; setting this to 5 will deal 5 damage regardless if you are using four slaps or not)
obi_health 900
obi_speed 900
obi_adminflag a

*/
// IF YOU EDIT BELOW HERE YOU WILL HAVE TO RECOMPILE THE PLUGIN
//-----------------------------------------------------
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

// Global Variables
new gHeroID
new gHeroName[] = "Obi Wan Kenobi"
new bool:gHasObiPower[SH_MAXSLOTS+1]

// constantes
new const gObiWeapon[] = "models/shmod/obiwan_saber_blu_v.mdl"
new const gObiWeapon2[] = "models/shmod/obiwan_saber_blu_p.mdl"

new const gObiPlayer[] = "models/player/obiwan/obiwan.mdl"

new const gSoundObi[] = "shmod/yoda_forcepush.wav"

// pcvars
new gPcvarCooldown, pcvarAdmin, gPcvarRadiusXY, gPcvarDamage, gSpriteWhite

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob",
	"Casper"
}

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// PLUGIN INFORMATION
	register_plugin("SUPERHERO Obi Wan", "1.0", "Exploited/Fr33m@n")
	
	// DON'T USE THIS FILE TO CHANGE THE CVARS. USE THE SHCONFIG.CFG!
	new pcvarLevel 		= register_cvar("obi_level", "10")
	new pcvarHealth 	= register_cvar("obi_health", "900")
	new pcvarSpeed 		= register_cvar("obi_speed", "900")
	
	// Empuje de la fuerza
	gPcvarCooldown 		= register_cvar("obi_cooldown", "8")
	gPcvarRadiusXY		= register_cvar("obi_radiusxy", "250")
	gPcvarDamage		= register_cvar("obi_damagepush", "50")
	
	// Admin check 
	pcvarAdmin		= register_cvar("obi_adminflag", "p")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Obtén el Poder de la Fuerza. (Only Admin).", "Usa el Poder de la Fuerza para empujar a tus enemigos.")
	
	// Eventos 
	// ESP Rings Task - Daredevil N Yoda
	set_task(2.0, "obi_loop_effects", 0, "", 0, "b")
	
	// Evento de cambio de armas
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Knife_Deploy", 1)
	
	//Agregado por Lucas	// Let Server know about obiwan's Variables
	sh_set_hero_hpap(gHeroID, pcvarHealth)
	sh_set_hero_speed(gHeroID, pcvarSpeed, {CSW_KNIFE}, 1)
	sh_set_hero_shield(gHeroID, true)
}

public plugin_precache()
{
	gSpriteWhite = precache_model("sprites/white.spr")
	precache_sound("player/pl_pain2.wav")
	
	precache_model(gObiWeapon)
	precache_model(gObiWeapon2)
	precache_model(gObiPlayer)
	precache_sound(gSoundObi)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and COOLDAWN SEND					//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasObiPower[id] = true
				gPlayerInCooldown[id] = false
				switch_model(id)
				Obi_admincheck(id)
				obi_morph_unmorph(id)
				}
			case SH_HERO_DROP: {
				gHasObiPower[id] = false
				obi_morph_unmorph(id)
			}
		}
	}
}


#if SEND_COOLDOWN
public sendObiwanCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id])
} 
#endif
//------------------------------------------------------------------------------------------------
//				SPAWN N DEATH							//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasObiPower[id] && is_user_alive(id) ) {
		Obi_admincheck(id)
		obi_tasks(id)		//esto es para que use el model
		
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
	if ( gHasObiPower[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//------------------------------------------------------------------------------------------------
//				Change models 							//
//------------------------------------------------------------------------------------------------
public Knife_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !gHasObiPower[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, gObiWeapon)
	set_pev(id, pev_weaponmodel2, gObiWeapon2)
	
	return HAM_IGNORED; 
}

switch_model(id)
{
	if ( !is_user_alive(id) ) return
	
	if (get_user_weapon(id) == CSW_KNIFE) {
		set_pev(id, pev_viewmodel2, gObiWeapon)
		set_pev(id, pev_weaponmodel2, gObiWeapon2)
	}
} 

public obi_tasks(id) set_task(1.0, "obi_morph_unmorph", id)

public obi_morph_unmorph(id)
{
	if ( !is_user_alive(id) ) return
	
	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 3)
	if ( gHasObiPower[id] ) {
		cs_set_user_model(id, "obiwan")
		show_hudmessage(id, "Ahora sos Obiwan-Kenobi.")
	} else {
		cs_reset_user_model(id)
		show_hudmessage(id, "Ya no sos más Obiwan-Kenobi.")
	}
}
//------------------------------------------------------------------------------------------------
//				Evento de Empujar con la fuerza					//
//------------------------------------------------------------------------------------------------
public obi_loop_effects()
{
	static players[SH_MAXSLOTS], pnum, id, i, j, vic
	get_players(players, pnum, "ah")

	for ( i = 0; i < pnum; i++) {
		id = players[i]
		if ( !gHasObiPower[id] ) continue
		
		for( j = 0; j < pnum; j++) {
			vic = players[j]
			
			if ( !is_user_alive(vic) || vic == id ) continue
			if ( get_user_team(id) == get_user_team(vic) ) continue
			
			new origin[3], vorigin[3], parm[4], distance
	
			get_user_origin(id, origin)
			get_user_origin(vic, vorigin)
			distance = get_distance(origin, vorigin)
			
			// for effects
			ring_force_effects(vic, id, vorigin)
			
			if ( gPlayerInCooldown[id] ) continue
			
			new randnum = random_num(1, 100)
			if ( distance < get_pcvar_num(gPcvarRadiusXY) && randnum <= 40 ) {
				// Set cooldown/sound/self damage only once, if push is used
				new Float:seconds = get_pcvar_float(gPcvarCooldown)
				if ( seconds > 0.0 ) {
					sh_set_cooldown(id, seconds)
					gPcvarRealCD[id] = seconds
				}

				emit_sound(id, CHAN_ITEM, gSoundObi, 0.7, ATTN_NORM, 0, PITCH_NORM)
				sh_chat_message(id, gHeroID, "Empujaste a un enemigo con el poder de la fuerza!")
	
				parm[0] = ((vorigin[0] - origin[0]) / distance) * 800
				parm[1] = ((vorigin[1] - origin[1]) / distance) * 800
				parm[2] = vic
				parm[3] = id
	
				// Stun enemy makes them easier to push
				sh_set_stun(vic, 0.5, 10.0)
	
				// First lift them
				new Float:tempVelocity[3] = {0.0, 0.0, 200.0}
				entity_set_vector(vic, EV_VEC_velocity, tempVelocity)
	
				// Then push them back in x seconds after lift and do some damage
				set_task(0.1, "move_enemy", 0, parm, 4)
			}
		}
	}
}

public move_enemy(parm[])
{
	new victim = parm[2]
	new id = parm[3]
	
	if ( !is_user_alive(victim) ) return
	// check if has noob or casper
	for (new i= 0; i < sizeof( gOthers_Heros ); i++) {
		new hero_id = sh_get_hero_id( gOthers_Heros[i] )
		if ( sh_user_has_hero(victim, hero_id) ) return
	}

	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = 200.0

	entity_set_vector(victim, EV_VEC_velocity, fl_velocity)

	// do some damage	
	new extradamage = get_pcvar_num(gPcvarDamage)	
	emit_sound(victim, CHAN_BODY, "player/pl_pain2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	sh_extra_damage(victim, id, extradamage, "Force Push")
}

public ring_force_effects(vic, id, vec1[3])
{
	new rgb[3]	// vec1[3]
	
	// Set ring color
	// Terrorist
	if ( get_user_team(vic) == 1 ) {
		rgb = {255, 35, 35}
	}
	// Counter-Terrorist
	else 	{
		rgb = {35, 35, 255}
	}

	//TE_BEAMCYLINDER
	message_begin(MSG_ONE, SVC_TEMPENTITY, vec1, id)
	write_byte(21)
	write_coord(vec1[0])		// center position
	write_coord(vec1[1])
	write_coord(vec1[2] + 13)
	write_coord(vec1[0])		// axis and radius
	write_coord(vec1[1])
	write_coord(vec1[2] + 140)
	write_short(gSpriteWhite)	// sprite index
	write_byte(0)		// startframe
	write_byte(1)		// frame rate in 0.1's
	write_byte(6)		// life in 0.1's
	write_byte(8)		// line width in 0.1's
	write_byte(1)		// noise amplitude in 0.01's
	write_byte(rgb[0])	// r
	write_byte(rgb[1])	// g
	write_byte(rgb[2])	// b
	write_byte(130)	// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()
}
//------------------------------------------------------------------------------------------------
//				Admin Check Y Daredevil						//
//------------------------------------------------------------------------------------------------
public Obi_admincheck(id) 
{
	if ( !gHasObiPower[id] ) return
	
   	new accessLevel[10] 
	get_pcvar_string(pcvarAdmin, accessLevel, 9)
	
	if (equali(accessLevel, "0")) return
   	
	if ( !(get_user_flags(id)&read_flags(accessLevel)) ) {
		sh_chat_message(id, gHeroID, "[Only Admin] Conseguite Admin Rata.")
      		
      		client_cmd(id, "say drop %s", gHeroName)
		gHasObiPower[id] = false
   	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
