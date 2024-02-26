/*
// Emperador Palpatine
palpatine_level
palpatine_cooldown 22   	//tiempo de cd
palpatine_time 4 		//tiempo que inflige daño aumentado
palpatine_decayradius 250  	//radio del daño pasivo
palpatine_decaydamage 40	//damage pasivo por segundo
palpatine_instantdamage 399	//daño instantaneo al usar el bind
palpatine_deathradius 500    	//radio al estar usando el palpatine_time tocando el key
palpatine_deathdamage 40   	//daño aumentado, en este caso 40+40=80 por segundo

*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

// VARIABLES
new gHeroID
new gHeroName[]="Emperador Palpatine"
new bool:g_haspalpatinePowers[SH_MAXSLOTS+1]

new g_palpatineTimer[SH_MAXSLOTS+1]

new gSpriteLightning, gMsgSync
new pcvarCooldown, pcvarTime, pcvarDecayradius, pcvarDecaydamage, pcvarInstanDamage

new const gEmpKnife_v[] = "models/shmod/darth_saber_red_v.mdl"
new const gEmpKnife_p[] = "models/shmod/darth_saber_red_p.mdl"

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob"
}
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Emperador Palpatine","1.0","FireWalker877")
 
	// DEFAULT THE CVARS
	new pcvar_lev		= register_cvar("palpatine_level", "10" )
	pcvarCooldown		= register_cvar("palpatine_cooldown", "22" )      	//tiempo de cd
	pcvarTime		= register_cvar("palpatine_time", "4" )			//tiempo que inflige daño aumentado
	pcvarDecayradius	= register_cvar("palpatine_decayradius", "250" )  	//radio del daño pasivo
	pcvarDecaydamage	= register_cvar("palpatine_decaydamage", "40" )		//damage pasivo por segundo
	pcvarInstanDamage	= register_cvar("palpatine_instantdamage", "399")	//daño instantaneo al usar el bind
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvar_lev);
	sh_set_hero_info(gHeroID, "Dark Lord Sid.", "Ataca a tus enemigos con rayos pasivamente en un aura! Activalo para causar aÃºn mÃ¡s daÃ±o en Ã¡rea");
	sh_set_hero_bind(gHeroID);
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// EVENTS
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Knife_Deploy", 1)
	sh_set_hero_shield(gHeroID, true);

	set_task(1.0, "palpatine_loop", 0, "", 0, "b") //forever loop
	
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
{
	gSpriteLightning = precache_model("sprites/lgtning.spr")
	precache_model(gEmpKnife_v)
	precache_model(gEmpKnife_p)
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return;
    
	switch(mode) {
		case SH_HERO_ADD: {
			g_haspalpatinePowers[id] = true;
			gPlayerInCooldown[id] = false
			switchmodel(id)
		}
		case SH_HERO_DROP: {
			g_haspalpatinePowers[id] = false
			palpatine_endmode(id)
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !g_haspalpatinePowers[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		 // Let them know they already used their ultimate if they have
		if ( gPlayerInCooldown[id] ) {
			playSoundDenySelect(id)
			return 
		}  
		
		// Make sure they're not in the middle of it already
		if ( g_palpatineTimer[id] > 0 ) return
		
		g_palpatineTimer[id] = get_pcvar_num(pcvarTime)
		
		palpatine_powerkey(id)
		
		// set cooldown
		new Float:seconds = get_pcvar_float(pcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
	}
}
#if SEND_COOLDOWN
public sendPalpatineCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id])  
}
#endif
//----------------------------------------------------------------------------------------------
//				SPAWN n DEATH for COOLDOWNS
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	// Para controlar si tiene el poder
	if ( g_haspalpatinePowers[id] ) {
		if ( g_palpatineTimer[id] > 0 ) palpatine_endmode(id)
		
		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		else gPlayerInCooldown[id] = false
	}
}

public sh_client_death(id) 
{
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( g_haspalpatinePowers[id] ) {
		gPcvarRealCD[id] = sh_get_cooldown(id)
		if ( g_palpatineTimer[id] > 0 ) palpatine_endmode(id)
	}
}
//------------------------------------------------------------------------------------------------
//				Poder de Palpatine Rayos					//
//------------------------------------------------------------------------------------------------
public palpatine_powerkey(id)
{	
	// This is for instant damage 
	new palpatineDeathRadius 	= get_pcvar_num(pcvarDecayradius) + get_pcvar_num(pcvarDecayradius) / 2
	new palpatineInstantDamage 	= get_pcvar_num(pcvarInstanDamage)
	
	new userOrigin[3], victimOrigin[3], distanceBetween
		
	new players[32], playerCount, player
	get_players(players, playerCount, "ah")
	new CsTeams:idTeam = cs_get_user_team(id) 

	get_user_origin(id, userOrigin)
	
	for ( new i = 0; i < playerCount; i++ ) {
		player = players[i]
		
		if( !is_user_alive(player) || idTeam == cs_get_user_team(player) ) continue
		
		// if ( idTeam != cs_get_user_team(player) ) {
		get_user_origin(player, victimOrigin)
		distanceBetween = get_distance(userOrigin, victimOrigin)
		
		if ( distanceBetween < palpatineDeathRadius ) {
		
			// this is for not affect de palpatine powers
			if ( !g_haspalpatinePowers[player] ) {
				
				sh_set_stun( player, 1.5, 300.0 )
				// Esto es para que no efecte el daño directo a los que tengan noob
				new player_has_noob = sh_get_hero_id(gOthers_Heros[0])
				if ( sh_user_has_hero(player, player_has_noob) ) continue
				
				// set_user_health(player, palpatineInstantDamage)
				sh_extra_damage(player, id, palpatineInstantDamage, "Emperor Palpatine Instant Damage" )
				
				new skywalker[32] 
				get_user_name(id, skywalker, 31)
				set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
				ShowSyncHudMsg( player, gMsgSync, "¡Si no eres convertido al Lado Oscuro, serÃ¡s destruido! ^nNo temas al Lado Oscuro, Joven %s!", skywalker)
			
				sh_set_rendering(player, 175, 0, 255, 20, kRenderFxGlowShell)
				// sh_set_rendering(player, 175, 0, 255)
				
				set_task(2.0, "palpatine_unset_rendering", player)
			}
			else 	{
				set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
				ShowSyncHudMsg(player, gMsgSync, "Eres Inmune al Lado Oscuro de la Fuerza!" )
			}
		}
	}
}

public palpatine_unset_rendering(id) sh_set_rendering(id)
//---------------------------------------------------------------------------------------------- 
//			LOOP and DAMAGE LOOP IN RADIUS
//---------------------------------------------------------------------------------------------- 
public palpatine_loop()
{	
	if ( !sh_is_active() || !sh_is_inround() ) return

	static players[32], playerCount, id, i
	get_players(players, playerCount, "ah")
	
	for ( i = 0; i < playerCount; i++ ) {
		id = players[i]
		if ( !g_haspalpatinePowers[id] || !is_user_alive(id)  ) continue 
		
		
		if ( g_palpatineTimer[id] > 0 ) {	
			g_palpatineTimer[id]--
			set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
			ShowSyncHudMsg(id, gMsgSync, "Tenes %d Segundos restantes ^nde la Fuerza de los Sith!", g_palpatineTimer[id] )     
			sh_set_rendering(id, 175, 0, 255, 16, kRenderFxGlowShell)
			
		} else if ( g_palpatineTimer[id] == 0 )  {
			g_palpatineTimer[id]--
			palpatine_endmode(id) 
		}
		
		// DECAY SETTINGS START HERE
		static palpatineDecayRadius 
		palpatineDecayRadius = get_pcvar_num(pcvarDecayradius)
		if ( g_palpatineTimer[id] > 0 ) palpatineDecayRadius = get_pcvar_num(pcvarDecayradius) + get_pcvar_num(pcvarDecayradius) / 2
			
		// origin from id palpatine
		new userOrigin[3], enemyOrigin[3], distance, player
		get_user_origin(id, userOrigin)
		
		new CsTeams:idTeam = cs_get_user_team(id)
		for ( new j = 0; j < playerCount; j++ ) { 
			player = players[j]
			
			if ( !is_user_alive(player) ) continue	
			if ( id == player || idTeam == cs_get_user_team(player) ) continue
			
			// origin and distance from enemy with id
			get_user_origin(player, enemyOrigin)
			distance = get_distance(userOrigin, enemyOrigin)
			
			if ( distance < palpatineDecayRadius ) {
				if ( !g_haspalpatinePowers[player] ) {
					palpatine_decay(player, id)
				}
			}
		}
	}
}
// All Palpatine Effects START HERE
//----------------------------------------------------------------------------------------------
public palpatine_decay(player, id)
{
	lightning_effect(id, player, 2)
	
	new palpatineDecayDamage
	if ( g_palpatineTimer[id] > 0 ) {
		palpatineDecayDamage = get_pcvar_num(pcvarDecaydamage) * 3
	}
	else {	
		palpatineDecayDamage = get_pcvar_num(pcvarDecaydamage)
	}
	
	sh_extra_damage(player, id, palpatineDecayDamage, "Palpatine Decay")
}
//----------------------------------------------------------------------------------------------
public lightning_effect(id, eid, linewidth)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(id)					// start entity
	write_short(eid)				// entity
	write_short(gSpriteLightning)			// model
	write_byte( 0 ) 					// starting frame
	write_byte( 15 )  				// frame rate
	write_byte( 15 )  	// life
	write_byte( linewidth )  // line width
	write_byte( 240 )  	// noise amplitude
	write_byte( 175 )				// r
	write_byte( 0 )					// g
	write_byte( 255 )				// b
	write_byte( 255 )				// brightness
	write_byte( 12 )	// scroll speed
	message_end()
	/*register_cvar("palpatine_life", "15")
	register_cvar("palpatine_noise", "240")
	register_cvar("palpatine_scroll", "12")*/
}
// ALL Palpatine Mage Effects END HERE
public palpatine_endmode(id)
{ 
	g_palpatineTimer[id] = -1
	sh_set_rendering(id)
}
//------------------------------------------------------------------------------------------------
//				Change weapons models						//
//------------------------------------------------------------------------------------------------
switchmodel(id)
{
	if ( !is_user_alive(id) ) return
	if ( get_user_weapon(id) == CSW_KNIFE ) {
		set_pev(id, pev_viewmodel2, gEmpKnife_v)
		set_pev(id, pev_weaponmodel2, gEmpKnife_p)
	}
}

public Knife_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !g_haspalpatinePowers[id] ) return HAM_IGNORED;  
	
	set_pev(id, pev_viewmodel2, gEmpKnife_v)
	set_pev(id, pev_weaponmodel2, gEmpKnife_p) 
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
