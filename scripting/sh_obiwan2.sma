// Use el yoda y mis propio script jeje
/* CVARS - COPY AND PASTE INTO SHCONFIG.CFG

// Obi Wan - WARNING - THE SLAPS SENDS YOU PRETTY HIGH FLYING, MAY EASILY DIE CAUSE OF SLAPS
obi_level 10 // What level should he be available at? default = 10
obi_cooldown 8 // How long between each use in seconds? default = 8
obi_percentage 3 // How big chance each shot? default = 3
obi_damage 0 // How much damage should the slaps do? default = 0 (Damage is applied one time; setting this to 5 will deal 5 damage regardless if you are using four slaps or not)
obi_health 900
obi_armor 900
obi_speed 900
obi_gravity 0.4
obi_adminflag a
obi_radius 1024   //tama�o del aro
obi_bright 192
obi_teamcolored 0
obi_enemyonly 0

*/
// IF YOU EDIT BELOW HERE YOU WILL HAVE TO RECOMPILE THE PLUGIN
//-----------------------------------------------------
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <amxmod>
#include <superheromod>
#include <Vexd_Utilities>

// Global Variables
new gHeroID
new gHeroName[] = "Obi Wan Kenobi"
new bool:gHasObiPower[SH_MAXSLOTS+1]
new bool:gObiSelected[SH_MAXSLOTS+1]
new bool:gmorphed[SH_MAXSLOTS+1]
// constantes
new const gObiWeapon[] = "models/shmod/obiwan_saber_blu_v.mdl"
new const gObiWeapon2[] = "models/shmod/obiwan_saber_blu_p.mdl"
new const gObiPlayer[] = "models/player/obiwan/obiwan.mdl"
// pcvars
new gPcvarCooldown, gPcvarPercentage, pcvarAdmin, gPcvarRadiusXY, gPcvarPower, gPcvarDamage, gPcvarStun
new pcvarTeamColored, pcvarEnemyOnly, pcvarBright, pcvarRadius, gSpriteWhite, gRadius, gBright

new noobID, casperID
new bool:gHasNoob[SH_MAXSLOTS+1]
new bool:gHasCasper[SH_MAXSLOTS+1]

#if SEND_COOLDOWN
	new Float:ObiwanUsedTime[SH_MAXSLOTS+1]
#endif
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
	gPcvarPercentage 	= register_cvar("obi_percentage", "0.50")
	gPcvarRadiusXY		= register_cvar("obi_radiusxy", "250")
	gPcvarPower		= register_cvar("obi_power", "700")
	gPcvarDamage		= register_cvar("obi_damagepush", "50")
	gPcvarStun		= register_cvar("obi_timestun", "1.5")
	// Daredevil + Admin check 
	pcvarRadius		= register_cvar("obi_radius", "1024")
	pcvarBright		= register_cvar("obi_bright", "192")
	pcvarTeamColored	= register_cvar("obi_teamcolored", "0")
	pcvarEnemyOnly		= register_cvar("obi_enemyonly", "0")
	pcvarAdmin		= register_cvar("obi_adminflag", "p")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Obtén el Poder de la Fuerza. (Only Admin).", "Usa el Poder de la Fuerza para empujar a tus enemigos.")
	
	// Eventos 
	// ESP Rings Task - Daredevil
	set_task(2.0, "Obi_senseloop", 0, "", 0, "b")
	// Evento de cambio de armas
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	
	//Agregado por Lucas	// Let Server know about obiwan's Variables
	sh_set_hero_hpap(gHeroID, pcvarHealth)
	sh_set_hero_speed(gHeroID, pcvarSpeed, {CSW_KNIFE}, 1)
	sh_set_hero_shield(gHeroID, true)
	
	set_task(0.2, "cache_idObi");   		// we need to let superhero cache all the heros to avoid issues
}

public cache_idObi() 
{
	noobID	= sh_get_hero_id("Noob");
	casperID= sh_get_hero_id("Casper");
}

public plugin_precache()
{
	precache_model("models/shmod/obiwan_saber_blu_v.mdl")
	precache_model("models/shmod/obiwan_saber_blu_p.mdl")
	gSpriteWhite = precache_model("sprites/white.spr")
	precache_model(gObiPlayer)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and SPAWN y REMOVE ENTITYS				//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasObiPower[id] = true
				gPlayerInCooldown[id] = false
				obi_tasks(id)
				switch_model(id)
				gObiSelected[id] = gHasObiPower[id]
				Obi_admincheck(id)
				}
			case SH_HERO_DROP: {
				gHasObiPower[id] = false
				obi_unmorph(id)
			}
		}
	}
	// Noob
	else if ( heroID == noobID ) {
		gHasNoob[id] = mode ? true : false
	}
	// Casper
	else if ( heroID == casperID ) {
		gHasCasper[id] = mode ? true : false
	}
}

public sh_client_spawn(id)
{
	if ( gHasObiPower[id] && is_user_alive(id) ) {
		Obi_admincheck(id)
		obi_tasks(id)						//esto es para que use el model
		gPlayerInCooldown[id] = false
		set_task( 1.0, "force_push_loop", id, _, _, "b")
	}
}
#if SEND_COOLDOWN
public sendObiwanCooldown(id)
{
	new cooldown
	
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(gPcvarCooldown) - get_gametime() + ObiwanUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
//------------------------------------------------------------------------------------------------
//				Cambio de models y Damage Extra Knife				//
//------------------------------------------------------------------------------------------------
public weapon_change(id)
{
	if ( !gHasObiPower[id] || !is_user_alive(id) ) return
    
	new weaponID = read_data(2)
	if (weaponID !=CSW_KNIFE) return
	switch_model(id)
}

switch_model(id)
{
	if ( !gHasObiPower[id] || !is_user_alive(id) ) return
	
	if (get_user_weapon(id) == CSW_KNIFE) {
		set_pev(id, pev_viewmodel2, gObiWeapon)
		set_pev(id, pev_weaponmodel2, gObiWeapon2)
	}
} 

public obi_tasks(id)
	set_task(1.0, "obi_morph", id)

public obi_morph(id)
{
	if ( gmorphed[id] || !is_user_alive(id) ) return
	
	cs_set_user_model(id, "obiwan")
	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 3)
	show_hudmessage(id, "Ahora sos Obiwan-Kenobi.")
	gmorphed[id] = true
}

public obi_unmorph(id)
{
	if ( gmorphed[id] ) {
		// Message
		set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 3)
		show_hudmessage(id, "Ya no sos más Obiwan-Kenobi.")

		cs_reset_user_model(id)
		gmorphed[id] = false
	}
}

public sh_client_death(victim)
{
	if ( !is_user_alive(victim) && gHasObiPower[victim] ) 
		cs_set_user_model(victim, "obiwan")
}
//------------------------------------------------------------------------------------------------
//				Evento de Empujar con la fuerza					//
//------------------------------------------------------------------------------------------------
public force_push_loop(id)
{	
	if ( !sh_is_active() || !sh_is_inround() ) return
	if ( !gHasObiPower[id] || !is_user_alive(id) ) return
	
	// Nuevo AGREGADO PARA VER SI FUNCIONA EN AREA
	
	new randnum = random_num(0, 100)
	new percentage = floatround(get_pcvar_float(gPcvarPercentage) * 100)

	if ( gHasObiPower[id] && !gPlayerUltimateUsed[id] && randnum >= percentage ) {
		force_push(id)
	}
}

public force_push(id)
{
	if ( !is_user_alive(id) || !gHasObiPower[id] ) return

	/* Codigo originial del yoda
	new team[33], 
	new players[SH_MAXSLOTS], pnum
	new origin[3], vorigin[3], parm[4], distance
	new Float:tempVelocity[3] = {0.0, 0.0, 200.0}
	new bool:enemyPushed = false

	
	get_user_team(id, team, 32)

	// Find all alive enemies
	if ( equali(team, "CT") ) {
		get_players(players, pnum, "a", "TERRORIST")	//def ae --> a ; en ambos
		}
	else 	{
		get_players(players, pnum, "a", "CT")
	} 

	get_user_origin(id, origin)
	for ( new vic = 0; vic < pnum; vic++ ) {
	*/
			
	new players[SH_MAXSLOTS], pnum
	new origin[3], vorigin[3], parm[4], distance
	new Float:tempVelocity[3] = {0.0, 0.0, 200.0}
	new bool:enemyPushed = false
	new CsTeams:idTeam = cs_get_user_team(id)
	
	get_user_origin(id, origin)
	get_players(players, pnum, "ah") 
	
	for ( new vic = 0; vic < pnum; vic++ ) {
		// player = players[vic]
		if ( idTeam != cs_get_user_team(players[vic]) ) {
		
		
			if( !is_user_alive(players[vic]) ) continue
	
			get_user_origin(players[vic], vorigin)
			distance = get_distance(origin, vorigin)
	
			if ( distance < get_pcvar_num(gPcvarRadiusXY) ) {
				// Set cooldown/sound/self damage only once, if push is used
				if ( !enemyPushed ) {
					new Float:seconds = get_pcvar_float(gPcvarCooldown)
					if ( seconds > 0.0 ) {
						sh_set_cooldown(id, seconds)		
						#if SEND_COOLDOWN
							ObiwanUsedTime[id] = get_gametime()
						#endif
					}
	
					emit_sound(id, CHAN_ITEM, "shmod/yoda_forcepush.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					enemyPushed = true
					sh_chat_message(id, gHeroID, "Empujaste a un enemigo con el poder de la fuerza!")
				}
	
				parm[0] = ((vorigin[0] - origin[0]) / distance) * get_pcvar_num(gPcvarPower)
				parm[1] = ((vorigin[1] - origin[1]) / distance) * get_pcvar_num(gPcvarPower)
				parm[2] = players[vic]
				parm[3] = id
	
				// Stun enemy makes them easier to push
				sh_set_stun(players[vic], get_pcvar_float(gPcvarStun), 1.0)
	
				// First lift them
				Entvars_Set_Vector(players[vic], EV_VEC_velocity, tempVelocity)
	
				// Then push them back in x seconds after lift and do some damage
				set_task(0.1, "move_enemy", 0, parm, 4)
			}
		}
	}
	
	// Quitado para que no haga spam en chat ni ruido si no se activa
	/* if ( !enemyPushed && is_user_alive(id) ) {
		sh_chat_message(id, gHeroID, "No hay enemigos para empujar dentro del alcance!")
		playSoundDenySelect(id)
	} */
}

public move_enemy(parm[])
{
	new victim = parm[2]
	new id = parm[3]

	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = 200.0

	Entvars_Set_Vector(victim, EV_VEC_velocity, fl_velocity)

	// do some damage
	if ( get_pcvar_num(gPcvarDamage) > 0 ) {
		if ( !is_user_alive(victim) || gHasNoob[victim] || gHasCasper[victim] ) return
		
		emit_sound(victim, CHAN_BODY, "player/pl_pain2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		shExtraDamage(victim, id, get_pcvar_num(gPcvarDamage), "Force Push")
	}
}
//------------------------------------------------------------------------------------------------
//				Admin Check Y Daredevil						//
//------------------------------------------------------------------------------------------------
public Obi_admincheck(id) 
{
   	new accessLevel[10] 
	get_pcvar_string(pcvarAdmin, accessLevel, 9)
   	
	if ( gObiSelected[id] &&  !(get_user_flags(id)&read_flags(accessLevel)) ) {
		sh_chat_message(id, gHeroID, "[Only Admin] Conseguite Admin Rata.")
      		gHasObiPower[id] = false
      		client_cmd(id, "say drop %s", gHeroName)
   	}
}

public Obi_senseloop()
{
	if ( !shModActive() ) return

	new players[SH_MAXSLOTS], pnum
	new idring, id, vec1[3], rgb[3]

	gRadius = get_pcvar_num(pcvarRadius)
	gBright = get_pcvar_num(pcvarBright)
	get_players(players, pnum, "a")

	for (new i = 0; i < pnum; i++) {
		id = players[i]
		if ( !gHasObiPower[id] || !is_user_alive(id) ) continue
		
		
		/*/ Nuevo AGREGADO PARA VER SI FUNCIONA EN AREA
		new Float:cooldown = get_pcvar_float(gPcvarCooldown)
		new randnum = random_num(0, 100)
		new percentage = floatround(get_pcvar_float(gPcvarPercentage) * 100)

		if ( gHasObiPower[id] && !gPlayerUltimateUsed[id] && randnum >= percentage ) {
			force_push(id)
	
			if ( cooldown > 0.0 ) sh_set_cooldown(id, cooldown)
			sh_chat_message(id, gHeroID, "Empujaste a un enemigo con el poder de la fuerza!")
		}
		/ */
		
		for(new r = 0; r < pnum; r++) {
			idring = players[r]
			if ( !is_user_alive(idring) || idring == id ) continue

			if ( get_pcvar_num(pcvarEnemyOnly) ) {
				if ( get_user_team(id) == get_user_team(idring) ) continue
			}

			if ( !get_user_origin(idring, vec1) ) continue

			// Set ring color
			if ( !get_pcvar_num(pcvarTeamColored) ) {
				rgb = {100, 100, 255} //default same color as daredevil
				}
			// Terrorist
			else if ( get_user_team(idring) == 1 ) {
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
			write_coord(vec1[2] + gRadius)
			write_short(gSpriteWhite)	// sprite index
			write_byte(0)		// startframe
			write_byte(1)		// frame rate in 0.1's
			write_byte(6)		// life in 0.1's
			write_byte(8)		// line width in 0.1's
			write_byte(1)		// noise amplitude in 0.01's
			write_byte(rgb[0])	// r
			write_byte(rgb[1])	// g
			write_byte(rgb[2])	// b
			write_byte(gBright)	// brightness
			write_byte(0)		// scroll speed in 0.1's
			message_end()
		}
	}
}

public client_connect(id)
{
	gmorphed[id] = false
	gHasObiPower[id] = false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
