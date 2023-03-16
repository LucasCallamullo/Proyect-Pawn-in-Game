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

new pcvarDeathRadius, pcvarDeathDamage, gSpriteLightning, gMsgSync
new pcvarCooldown, pcvarTime, pcvarDecayradius, pcvarDecaydamage, pcvarInstanDamage
#if SEND_COOLDOWN
	new Float:PalpatineUsedTime[SH_MAXSLOTS+1]
#endif
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
	pcvarDeathRadius	= register_cvar("palpatine_deathradius", "500" ) 	//radio al estar usando el palpatine_time tocando el key
	pcvarDeathDamage	= register_cvar("palpatine_deathdamage", "40" )  	//daño aumentado, en este caso 40+40=80 por segundo
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvar_lev);
	sh_set_hero_info(gHeroID, "Dark Lord Sid.", "Ataca a tus enemigos con rayos pasivamente en un aura! Activalo para causar aÃºn mÃ¡s daÃ±o en Ã¡rea");
	sh_set_hero_bind(gHeroID);
	sh_set_hero_shield(gHeroID, true);

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_event("CurWeapon", "weaponChange","be","1=1")

	// register_srvcmd("palpatine_loop", "palpatine_loop")
	// shRegLoop1P0(gHeroName, "palpatine_loop", "ac" ) 	// Alive palpatineHeros="ac"
	set_task(1.0, "palpatine_loop", 0, "", 0, "b") //forever loop
	
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
{
	gSpriteLightning = precache_model("sprites/lgtning.spr")
	precache_model("models/shmod/darth_saber_red_v.mdl")
	precache_model("models/shmod/darth_saber_red_p.mdl")
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
			g_haspalpatinePowers[id] = false;
			
			/* if ( is_user_alive(id) && g_palpatineTimer[id]>=0 ) {
				palpatine_endmode(id)
			} */
			// g_palpatineTimer[id] = -1  	// Make sure looop doesn't fire for em...
			// set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !g_haspalpatinePowers[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		 // Let them know they already used their ultimate if they have
		if ( gPlayerUltimateUsed[id] ) {
			playSoundDenySelect(id)
			return 
		}  
		// Make sure they're not in the middle of it already
		if ( g_palpatineTimer[id] > 0 ) return

		palpatine_powerkey(id)
		
		#if SEND_COOLDOWN
			PalpatineUsedTime[id] = get_gametime()
		#endif
		/*
		new Float:seconds = get_pcvar_float(pcvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			#if SEND_COOLDOWN
				PalpatineUsedTime[id] = get_gametime()
			#endif
		}*/
	}
}
#if SEND_COOLDOWN
public sendPalpatineCooldown(id)
{
	new cooldown
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(pcvarCooldown) + get_pcvar_num(pcvarTime) - get_gametime() + PalpatineUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
//------------------------------------------------------------------------------------------------
//				Poder de Palpatine Rayos					//
//------------------------------------------------------------------------------------------------
public palpatine_powerkey(id)
{
	g_palpatineTimer[id] 		= get_pcvar_num(pcvarTime)+1
	new palpatineDeathRadius 	= get_pcvar_num(pcvarDeathRadius)
	new palpatineInstantDamage 	= get_pcvar_num(pcvarInstanDamage)
	
	new userOrigin[3], victimOrigin[3], distanceBetween
		
	new players[SH_MAXSLOTS], pnum, player
	new CsTeams:idTeam = cs_get_user_team(id)

	get_user_origin(id, userOrigin)
	get_players(players, pnum, "ah") 
	
	for ( new x = 0; x < pnum; x++ ) {
	//for ( new x=1; x<=SH_MAXSLOTS; x++) {
		player = players[x]
		if ( idTeam != cs_get_user_team(player) ) {
		// if ( (is_user_alive(x) && get_user_team(id) != get_user_team(x)) || x!=id ) {
		
			if( !is_user_alive(player) ) continue
			// if ( !(x <= x <= SH_MAXSLOTS) || !is_user_alive(x) ) return 
			get_user_origin(player, victimOrigin)
			distanceBetween = get_distance(userOrigin, victimOrigin)
			if ( distanceBetween < palpatineDeathRadius ) {
		
				if (!g_haspalpatinePowers[player]) {
					
					// set_user_maxspeed( x, 200.0)
					// new enemyHealth = get_user_health(player)
					set_user_health(player, palpatineInstantDamage)
					// sh_extra_damage(player, id, palpatineInstantDamage, "Emperor Palpatine Instant Damage" )
					sh_set_stun( player, 1.5, 300.0)
					
					
					set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
					ShowSyncHudMsg(player, gMsgSync, "¡Si no eres convertido al Lado Oscuro, serÃ¡s destruido!" )
					
					set_task(1.0, "palpatine_loop_death", id, "", 0, "b") //forever loop
					}
				else 	{
					set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
					ShowSyncHudMsg(player, gMsgSync, "Eres Inmune al Lado Oscuro de la Fuerza!" )
				}
			}
		}
	}
}	
//----------------------------------------------------------------------------------------------   
public palpatine_loop_death(id)
{	
	new palpatineDeathRadius = get_pcvar_num(pcvarDeathRadius)
	
	if ( g_haspalpatinePowers[id] && is_user_alive(id) ) {
		// DEATH SETTINGS START HERE
		if ( g_palpatineTimer[id] > 0 ) {
			g_palpatineTimer[id]--
				
			set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
			ShowSyncHudMsg(id, gMsgSync, "Tenes %d Segundos restantes ^nde la Fuerza de los Sith!", g_palpatineTimer[id] )
			// set_user_rendering(id, kRenderFxGlowShell, 175, 0, 255, kRenderTransAlpha, 25)       
			sh_set_rendering(id, 175, 0, 255, 16, kRenderFxGlowShell)
	
			new uOrigin[3], vOrigin[3], dBetween
			new players[SH_MAXSLOTS], pnum, player
			new CsTeams:idTeam = cs_get_user_team(id)
			
			get_user_origin(id, uOrigin)
			get_players(players, pnum, "ah") 
			for ( new x = 0; x < pnum; x++ ) {
				player = players[x]
				if ( idTeam != cs_get_user_team(player) ) {
					if( !is_user_alive(player) ) continue
					
					get_user_origin(player, vOrigin)
					dBetween = get_distance(uOrigin, vOrigin)
					if ( dBetween < palpatineDeathRadius ) {
						if ( !g_haspalpatinePowers[player] ) {
							palpatine_death(player, id)
						}
					}
				}
			}
		}
		
		else if ( g_palpatineTimer[id] == 0 ) {
			g_palpatineTimer[id]--
			palpatine_endmode(id)
		}
	}
}		// DEATH SETTINGS STOP HERE
//----------------------------------------------------------------------------------------------   
public palpatine_loop()
{	
	if ( !shModActive() ) return

	/* for ( new id=1; id<=SH_MAXSLOTS; id++ ) {
		if ( g_haspalpatinePowers[id] && is_user_alive(id)  ) {
			// DEATH SETTINGS START HERE
			if ( g_palpatineTimer[id]>0 ) {
				g_palpatineTimer[id]--
				
				set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
				ShowSyncHudMsg(id, gMsgSync, "Tenes %d Segundos restantes ^nde la Fuerza de los Sith!", g_palpatineTimer[id] )
				set_user_rendering(id, kRenderFxGlowShell, 175, 0, 255, kRenderTransAlpha, 25)       
        
				new uOrigin[3], vOrigin[3], dBetween
				new palpatineDeathRadius = get_pcvar_num(pcvarDeathRadius)
				get_user_origin(id,uOrigin)
				for ( new x=1; x<=SH_MAXSLOTS; x++) {
					
					if ( !(x <= x <= SH_MAXSLOTS) || !is_user_alive(x) ) return 
					
					if ( (is_user_alive(x) && get_user_team(id)!=get_user_team(x)) && x!=id ) {
						get_user_origin(x,vOrigin)
						dBetween = get_distance(uOrigin, vOrigin)
						if ( dBetween < palpatineDeathRadius ) {
							if (!g_haspalpatinePowers[x]) {
								palpatine_death(x, id)
								}
							else 	{
								set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
								ShowSyncHudMsg(x, gMsgSync, "El poder de la Fuerza es fuerte en vos!" )
							}
						}
					}
				}
			}
			else 	{
				if ( g_palpatineTimer[id] == 0 ) {
					g_palpatineTimer[id]--
					palpatine_endmode(id)
				}
			}
			// DEATH SETTINGS STOP HERE   */
			
	for ( new id=1; id<=SH_MAXSLOTS; id++ ) {
		if ( g_haspalpatinePowers[id] && is_user_alive(id)  ) {
			// DECAY SETTINGS START HERE
			new palpatineDecayRadius = get_pcvar_num(pcvarDecayradius)
			
			new userOrigin[3], enemyOrigin[3], distance
			new players[SH_MAXSLOTS], pnum, player
			new CsTeams:idTeam = cs_get_user_team(id)
			
			get_user_origin(id, userOrigin)
			// for ( new eid=1; eid<=SH_MAXSLOTS; eid++) {
			get_players(players, pnum, "ah") 
			for ( new eid = 0; eid < pnum; eid++ ) {	
				player = players[eid]
				if ( idTeam != cs_get_user_team(player) ) {
					if( !is_user_alive(player) ) continue	
				// if ( ( is_user_alive(eid) && get_user_team(id) != get_user_team(eid) ) && eid!=id ) {
					get_user_origin(player, enemyOrigin)
					distance = get_distance(userOrigin, enemyOrigin)
					
					if ( distance < palpatineDecayRadius ) {
						if ( !g_haspalpatinePowers[player] ) {
							palpatine_decay(player, id)
						}
						/* else 	{
							new skywalker[32] 
							get_user_name(id, skywalker, 31) 
							set_hudmessage(175, 0, 255, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 4)
							ShowSyncHudMsg(player, gMsgSync, "No temas al Lado Oscuro, joven %s!", skywalker)
						} */
					}
				}
			}
		}	// DECAY SETTINGS STOP HERE
	}
}
// All Palpatine Effects START HERE
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
	write_byte( linewidth )  			// line width
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
//----------------------------------------------------------------------------------------------
public palpatine_death(player, id)
{
	new palpatineDeathDamage = get_pcvar_num(pcvarDeathDamage)
	new enemyHealth = get_user_health(player)
	new newHP = (enemyHealth - palpatineDeathDamage)
							
	if ( newHP < palpatineDeathDamage ) {
		sh_extra_damage(player, id, palpatineDeathDamage, "Palpatine Death")
		}
	else 	{
		set_user_health(player, newHP)
	}
	 
	//return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public palpatine_decay(player, id)
{
	new palpatineDecayDamage = get_pcvar_num(pcvarDecaydamage)
	new enemyHealth = get_user_health(player)
	new newHP = enemyHealth-palpatineDecayDamage
	lightning_effect(id, player, 2)
	
	if ( newHP < get_pcvar_num(pcvarDecaydamage) ) {
		sh_extra_damage(player, id, palpatineDecayDamage, "Palpatine Decay")
		}
	else 	{
		set_user_health(player, newHP)
	}
	//return PLUGIN_HANDLED
}
// ALL Palpatine Mage Effects END HERE
public palpatine_endmode(id)
{ 
	g_palpatineTimer[id] = -1
	sh_set_rendering(id)
	new Float:seconds = get_pcvar_float(pcvarCooldown)
	if ( seconds > 0.0 ) {
		sh_set_cooldown(id, seconds)
	}
}
//------------------------------------------------------------------------------------------------
//				Spawn and ChangeModels Faka					//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( g_haspalpatinePowers[id] ) {
		gPlayerInCooldown[id] = false
		g_palpatineTimer[id] = -1
	}
}

public weaponChange(id)
{
	if ( !is_user_alive(id) || !g_haspalpatinePowers[id] ) return
	
	// new wpnid = read_data(2)		
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ( wpnid == CSW_KNIFE ) switchmodel(id)
}

switchmodel(id)
{
	if ( !is_user_alive(id) ) return
    
	if (get_user_weapon(id) == CSW_KNIFE) {
		set_pev(id, pev_viewmodel2, "models/shmod/darth_saber_red_v.mdl")
		set_pev(id, pev_weaponmodel2, "models/shmod/darth_saber_red_p.mdl")
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
