// Mangekyou SHARINGAN! 

/* CVARS - copy and paste to shconfig.cfg

// Mangekyou SHARINGAN
msharingan_level 8
msharingan_slowmotime 7	//Amount of time before next available respawn (Default 120)
msharingan_cooldown 20	// cooldown
msharingan_respawn 1	// How many times can you revive your enemy after tsukuyomi activates and u are alive?
msharingan_radius 500	// Radius effects for the tsukuyomi?

*/

// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID 
new HeroName[] = "Mangekyou Sharingan"
new bool:HasMsharingan[SH_MAXSLOTS+1]

new MsharinganTimer[SH_MAXSLOTS+1]
new CvarSlowMoTime, CvarCooldown, gMsgSync

// tsukuyomi
new KillCountMangekyou[SH_MAXSLOTS+1]
new pcvarMangekyouRespawns, gPcvarDeathRadius

// this for unstuck
new Float:gFVecOrigin[SH_MAXSLOTS+1][3]
new Float:gFVecAngles[SH_MAXSLOTS+1][3]

new const Float:VEC_DUCK_HULL_MIN[3]	= {-16.0, -16.0, -18.0 }
new const Float:VEC_DUCK_HULL_MAX[3]	= { 16.0,  16.0,  32.0 }
new const Float:VEC_DUCK_VIEW[3]	= {  0.0,   0.0,  12.0 }
new const Float:VEC_NULL[3]		= {  0.0,   0.0,   0.0 }

new const gSound[] = "shmod/mangsharingan.wav" 

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Mangekyou Sharingan", "1.5", "Lucas Arje Je :D")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= register_cvar("msharingan_level", "12")
	CvarSlowMoTime		= register_cvar("msharingan_slowmotime", "7")		// tiempo del sharingan
	CvarCooldown 		= register_cvar("msharingan_cooldown", "20")		// cooldown
	pcvarMangekyouRespawns	= register_cvar("msharingan_respawn", "1")		// How many times can you revive your enemy after tsukuyomi activates and u are alive?
	gPcvarDeathRadius	= register_cvar("msharingan_radius", "500")		// How many times can you revive your enemy after tsukuyomi activates and u are alive?
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(HeroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Mangekyou Sharingan.", "Mete a tus enemigos en tu Genjutsu.");
	sh_set_hero_bind(gHeroID); 

	// LOOP
	set_task(1.0, "msharingan_loop", 0, "", 0, "b")
	 
	gMsgSync = CreateHudSyncObj()
}

public plugin_precache()
	precache_sound(gSound)
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			HasMsharingan[id] = true
			gPlayerInCooldown[id] = false
			MsharinganTimer[id] = -1
			KillCountMangekyou[id] = 0 
		}
		case SH_HERO_DROP: {
			HasMsharingan[id] = false
		}
	}
}

public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !HasMsharingan[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		
		if ( gPlayerUltimateUsed[id] || MsharinganTimer[id] > 0 ) {
			playSoundDenySelect(id)
			return
		}
		
		MsharinganTimer[id] = get_pcvar_num(CvarSlowMoTime) + 1
		
		sharingan_keypower(id) 
		
		// set_cooldown
		new Float:seconds = get_pcvar_float(CvarCooldown)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		}
	}
}
#if SEND_COOLDOWN
public sendMSharinganCooldown(id)
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
	if ( HasMsharingan[id] ) {
		MsharinganTimer[id] = -1
	
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
//------------------------------------------------------------------------------------------------
//				Evento de keypower y Loop					//
//------------------------------------------------------------------------------------------------
public sharingan_keypower(id)
{
	new Float:taskglow	= get_pcvar_float(CvarSlowMoTime)
	new sharinganradius	= get_pcvar_num(gPcvarDeathRadius)
	
	emit_sound(id, CHAN_STATIC, gSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// set_user_maxspeed(id, msharinganSpeed)
	new Float:speed_mangekyou = get_user_maxspeed(id) + 50.0
	set_user_maxspeed(id, speed_mangekyou)	
	
	//make screen gray or black
	sh_screen_fade( id, taskglow, taskglow, 0, 0, 0, 140) 		
	sh_set_rendering(id, 116, 2, 192, 16, kRenderFxGlowShell)
	
	// show hud with effects
	set_hudmessage(145, 0, 174, -1.0, 0.30, 0, 0.0, 1.0, 0.0, 0.0, 7)
	ShowSyncHudMsg(id, gMsgSync, "%s!", HeroName)
	
	// for make the radius effect
	new uOrigin[3], vOrigin[3], dBetween
	new players[SH_MAXSLOTS], player_num, player
	
	new CsTeams:idTeam = cs_get_user_team(id)
	get_user_origin(id, uOrigin)
	
	get_players(players, player_num, "ah") 	// a=no incluir dead clients; h=hltv proxy 
	for ( new i = 0; i < player_num; i++ ) {
		player = players[i]
		// if is the same team dont take effects
		if ( idTeam == cs_get_user_team(player) ) continue
		
		// if has the sharingan dont take effects
		if ( HasMsharingan[player] ) continue
		
		get_user_origin(player, vOrigin)
		dBetween = get_distance(uOrigin, vOrigin)
		
		if ( dBetween < sharinganradius ) {
			// reduce the speed in mangekyoue radius
			sh_set_stun(player, 1.0, 100.0)
			
			//make screen gray or black
			sh_screen_fade( player, taskglow, taskglow, 0, 0, 0, 180)		
			
			// show hud with effects
			set_hudmessage(145, 0, 174, -1.0, 0.30, 0, 0.0, 1.0, 0.0, 0.0, 5)
			ShowSyncHudMsg(player, gMsgSync, "%s!", HeroName)
		}
	}
}

public msharingan_loop()
{
	// if ( !sh_is_inround() ) return;
	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		
		if ( !HasMsharingan[id] || !is_user_alive(id) || MsharinganTimer[id] < 0 ) continue
		
		if ( MsharinganTimer[id] > 0 ) {
			set_hudmessage(145, 0, 174, -1.0, 0.3, 0, 0.0, 1.0, 0.0, 0.0, 7)
			ShowSyncHudMsg(id, gMsgSync, "Te quedan %d segundos de Mangekyou.", MsharinganTimer[id])
		}
		else {
			end_mangekyou(id)
		}
		
		MsharinganTimer[id]--
	}
}

public end_mangekyou(id)
{
	if ( !is_user_connected(id) ) return
	
	if ( MsharinganTimer[id] == 0 ) {
		set_hudmessage(145, 0, 174, -1.0, 0.3, 0, 0.0, 2.0, 0.0, 0.0, 7) 
		ShowSyncHudMsg(id, gMsgSync, "Usaste todo tu Chakra, Necesita descansar.")
		sh_set_rendering(id)
	}
	
	// sh_chat_message(id, gHeroID, "estoy en end mangekyou")
	MsharinganTimer[id] = -1
}
//------------------------------------------------------------------------------------------------
//				Efectos Tsukuyomi revivis al que matas				//
//------------------------------------------------------------------------------------------------
public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() || !sh_is_inround() ) return
	// if ( victim == attacker ) return 	
	 
	 // Para obtener la cantidad real de cooldown que tiene el poder
	if ( HasMsharingan[victim] ) {
		gPcvarRealCD[victim] = sh_get_cooldown(victim)
		end_mangekyou(victim)
	} 
	 
	 // This is from Phoenix Ty
	 // Save users origin on death
	pev(victim, pev_origin, gFVecOrigin[victim])
	pev(victim, pev_v_angle, gFVecAngles[victim])
	 
	// get_user_origin(victim, g_savedOrigin2[victim])	// Save users origin on death
	// g_savedOrigin2[victim][2] += 8			// Save users origin on death
	 
	// Look for self to raise from dead
	if ( !is_user_alive(victim) && HasMsharingan[attacker] && MsharinganTimer[attacker] > 0 ) {
		new parm[2] 
		parm[0] = victim
		parm[1] = attacker
		// Respawn him faster then Zues, let this power be used before Zues's
		// never set higher then 1.9 or lower then 0.5
		/* el task esta puesto en 0.x porque segun el mas chico se activa primero ese heroe.
		mangekyou = 0,5
		chucky = 0.6
		phoenix = 0.7
		shaman = 0.8
		dr.strange = 0.9
		majin buu = 1.0
		grandmaster = 1.1 // pero esta se superpone porque es la primera en usarse 
		uchiha revenge = 1.2
		torneo = 1.5 */
		set_task(0.5, "mangekyou_respawn", 0, parm, 2)
	} 
}

public mangekyou_respawn(parm[])
{
	new victim = parm[0]
	new attacker = parm[1]
	if ( !is_user_connected(victim) || is_user_alive(victim) || !sh_is_inround() ) return
	if ( KillCountMangekyou[victim] == get_pcvar_num(pcvarMangekyouRespawns) || MsharinganTimer[attacker] == -1  ) return
	
	emit_sound(victim, CHAN_STATIC, gSound, 0.6, ATTN_NORM, 0, PITCH_NORM)
	
	sh_chat_message(victim, -1, "El %s te revivió para matarte otra vez en su Genjutsu.", HeroName)
	
	// Double spawn prevents the no HUD glitch
	// This should eventually be changed to use a better method
	spawn(victim)
	spawn(victim) 
	//ExecuteHamB(Ham_CS_RoundRespawn, id)		// Use this no for bots
	KillCountMangekyou[victim]++
	
	// Set HP after respawn
	set_user_health(victim, 900)					
	sh_set_godmode(victim, 0.3)
	
	mangekyou_teleport(victim)

	// If player is stuck, try to unstuck him
	new hulltype = (pev(victim, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	if ( !sh_hull_vacant(victim, gFVecOrigin[victim], hulltype) ) {
		unstuck(victim, hulltype)
	} 
}
//----------------------------------------------------------------------------------------------
//				TELEPORT EFFECTS N UNSTUCK
//----------------------------------------------------------------------------------------------
mangekyou_teleport(id)
{
	new Float: timeglow = get_pcvar_float(CvarSlowMoTime)
	sh_screen_fade(id, timeglow, timeglow, 0, 0, 0, 140 )	//make screen gray
	
	sh_set_rendering(id, 141, 143, 144, 16, kRenderFxGlowShell)	// Glow
	set_task(3.0, "mangekyou_unglow", id) 			// Unglow 
 
	// Thanks to Connor for duck and angles part
	if ( is_user_alive(id) && gFVecOrigin[id][0] ) {
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_DUCKING)
		engfunc(EngFunc_SetSize, id, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX)
		engfunc(EngFunc_SetOrigin, id, gFVecOrigin[id])
		set_pev(id, pev_view_ofs, VEC_DUCK_VIEW)

		set_pev(id, pev_angles, gFVecAngles[id])
		set_pev(id, pev_v_angle, VEC_NULL)
		set_pev(id, pev_fixangle, 1)
	}

	// Teleport Effects
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_TELEPORT)						// 11
	engfunc(EngFunc_WriteCoord, gFVecOrigin[id][0])		// start position
	engfunc(EngFunc_WriteCoord, gFVecOrigin[id][1])
	engfunc(EngFunc_WriteCoord, gFVecOrigin[id][2])
	message_end()
}

public mangekyou_unglow(victim) sh_set_rendering(victim)
//----------------------------------------------------------------------------------------------
//Thank you from AMXX NS unstuck plugin
unstuck(id, hulltype)
{
	new Float:new_origin[3], distance, i
	distance = 32

	while ( distance < 1000 ) {	// 1000 is just incase, should never get anywhere near that
		for ( i = 0; i < 128; i++ ) {
			new_origin[0] = random_float(gFVecOrigin[id][0] - distance, gFVecOrigin[id][0] + distance)
			new_origin[1] = random_float(gFVecOrigin[id][1] - distance, gFVecOrigin[id][1] + distance)
			new_origin[2] = random_float(gFVecOrigin[id][2] - distance, gFVecOrigin[id][2] + distance)

			if ( fm_trace_hull(new_origin, hulltype, id) == 0 ) {
				engfunc(EngFunc_SetOrigin, id, new_origin)
				return
			}
		}
		distance += 32
	}
}

//Stock from fakemeta_util.inc
stock fm_trace_hull(const Float:origin[3], hull, ignoredent = 0, ignoremonsters = 0) {
	new result = 0;
	engfunc(EngFunc_TraceHull, origin, origin, ignoremonsters, hull, ignoredent > 0 ? ignoredent : 0, 0);

	if (get_tr2(0, TR_StartSolid))
		result += 1;
	if (get_tr2(0, TR_AllSolid))
		result += 2;
	if (!get_tr2(0, TR_InOpen))
		result += 4;

	return result;
}
//------------------------------------------------------------------------------------------------
//				Disconected y round end						//
//------------------------------------------------------------------------------------------------
public client_disconnected(id)
{
	gPlayerUltimateUsed[id] = false
	remove_task(id)
}

public sh_round_end()
{
	for (new id=0; id <= SH_MAXSLOTS; id++) {	
		KillCountMangekyou[id] = 0
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
