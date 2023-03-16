/* Plugin generated by AMXX-Studio */
#define ACTIVE_POWERS_INFO 1	// 1 - Enabled, 0 - Disabled

#include <superheromod> 

#if ACTIVE_POWERS_INFO
	// Kills
	new DarthMaulForward
	new DarthMaulCooldown[SH_MAXSLOTS+1]
	// Cooldowns
	new ObiwanForward
	new ObiwanCooldown[SH_MAXSLOTS+1]
	// Granadas
	new BatmanForward
	new BatmanCooldown[SH_MAXSLOTS+1]
	
	new ColaLoverForward
	new ColaLoverCooldown[SH_MAXSLOTS+1]
	
	new PenguinForward
	new PenguinCooldown[SH_MAXSLOTS+1]
	
	new TiraPedosForward
	new TiraPedosCooldown[SH_MAXSLOTS+1]
	// Uchiha's
	new UchihaForward
	new UchihaLevel[SH_MAXSLOTS+1]
	
	new UchihaForward2
	new UchihaChidori[SH_MAXSLOTS+1]
	
	new UchihaForward3
	new UchihaAmaterasu[SH_MAXSLOTS+1]
#endif

// Darth Maul
new darthID
new bool:gHasDarthMaulPowers[SH_MAXSLOTS+1]
// new KillCountDarth[SH_MAXSLOTS+1]
// new dashkillsreq     

// Uchiha Revenge 
new uchihaID
new bool:gHasUchihaPower[SH_MAXSLOTS+1]
new KillCountUchiha[SH_MAXSLOTS+1]
new uchihakillsreq

// Granada Heroes
new batmanID, colaloverID, penguinID, tirapedoID
new bool:gHasBatman[SH_MAXSLOTS+1]
new bool:gHasColaLoverPower[SH_MAXSLOTS+1]
new bool:gHasPenguinPower[SH_MAXSLOTS+1]
new bool:HasFartman[SH_MAXSLOTS+1]		// Tira pedos

new obiwanID
new bool:gHasObiPower[SH_MAXSLOTS+1]



new MonitorHudSync
new const TaskClassname[] = "monitorloop"
//----------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin("plugin CooldownPasivas", "1.0", "Lucas Cab Arje")
	
	#if ACTIVE_POWERS_INFO
		BatmanForward 		= CreateMultiForward("sendBatmanCooldown", ET_CONTINUE, FP_CELL);
		ColaLoverForward 	= CreateMultiForward("sendColaLoverCooldown", ET_CONTINUE, FP_CELL);
		PenguinForward 		= CreateMultiForward("sendPenguinCooldown", ET_CONTINUE, FP_CELL);
		TiraPedosForward 	= CreateMultiForward("sendFartmanCooldown", ET_CONTINUE, FP_CELL);
		
		DarthMaulForward 	= CreateMultiForward("sendDarthMaulCooldown", ET_CONTINUE, FP_CELL);
		ObiwanForward		= CreateMultiForward("sendObiwanCooldown", ET_CONTINUE, FP_CELL);
		// Uchiha's revenge
		UchihaForward 		= CreateMultiForward("sendUchihaLevel", ET_CONTINUE, FP_CELL);
		UchihaForward2 		= CreateMultiForward("sendUchihaChidori", ET_CONTINUE, FP_CELL);
		UchihaForward3 		= CreateMultiForward("sendUchihaAmaterasu", ET_CONTINUE, FP_CELL);
	#endif
	
	// Todo esto es del Hud
	new monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (monitor) {
		set_pev(monitor, pev_classname, TaskClassname)
		set_pev(monitor, pev_nextthink, get_gametime() + 0.1)
		register_forward(FM_Think, "monitor_think2")
	}
	
	MonitorHudSync = CreateHudSyncObj()
	set_task(1.0, "loopMain2", _, _, _, "b")	// Esta tarea es de los cooldowns
	set_task(0.1, "cache_id2");   		// we need to let superhero cache all the heros to avoid issues
}
//----------------------------------------------------------------------------------------------
public cache_id2() 
{
	// Primera Pagin Menu
	darthID		= sh_get_hero_id("Darth Maul");
	obiwanID	= sh_get_hero_id("Obi Wan Kenobi");
	
	batmanID	= sh_get_hero_id("Batman");
	colaloverID	= sh_get_hero_id("Cola Lover");
	penguinID	= sh_get_hero_id("Penguin");
	tirapedoID	= sh_get_hero_id("TiraPedos");
	
	uchihaID	= sh_get_hero_id("Uchiha's Revenge");
}
public plugin_cfg()  
{
	// dashkillsreq 	= get_cvar_num("darth_kills")		// kill resquest - Darth Maul
	uchihakillsreq	= get_cvar_num("Uchiha_killsreq")	// kill resquest - Uchiha's
}
		
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{	
	// Darth Maul
	if ( darthID == heroID )
		gHasDarthMaulPowers[id] = mode ? true : false
		
	// Obi wan
	else if ( obiwanID == heroID )
		gHasObiPower[id] = mode ? true : false
		
	// Batman
	else if ( batmanID == heroID )
		gHasBatman[id] = mode ? true : false
		
	// Cola Lover
	else if ( colaloverID == heroID )
		gHasColaLoverPower[id] = mode ? true : false
		
	// Penguin
	else if ( penguinID == heroID )
		gHasPenguinPower[id] = mode ? true : false
		
	// Penguin
	else if ( tirapedoID == heroID )
		HasFartman[id] = mode ? true : false
		
	// Uchiha's Revenge
	else if ( uchihaID == heroID )
		gHasUchihaPower[id] = mode ? true : false
}
public sh_client_spawn(id)
{
	if ( gHasUchihaPower[id] ) 
		KillCountUchiha[id] = 0
}
//----------------------------------------------------------------------------------------------
public loopMain2()
{	
	#if ACTIVE_POWERS_INFO
	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( !is_user_connected(id) || !is_user_alive(id) ) continue
		#if ACTIVE_POWERS_INFO
			get_active_powers_info(id)
		#endif
	}
	#endif
}
//----------------------------------------------------------------------------------------------
#if ACTIVE_POWERS_INFO
public get_active_powers_info(id)
{
	new bool:flag = false
	new functionReturn
	
	// Darth Maul	
	ExecuteForward(DarthMaulForward, functionReturn, id)
	if ( DarthMaulCooldown[id] != functionReturn ) {
		DarthMaulCooldown[id] = functionReturn
		flag = true
	}
	
	// Obiwan	
	ExecuteForward(ObiwanForward, functionReturn, id)
	if ( ObiwanCooldown[id] != functionReturn ) {
		ObiwanCooldown[id] = functionReturn
		flag = true
	}
	
	// Batman
	ExecuteForward(BatmanForward, functionReturn, id)
	if ( BatmanCooldown[id] != functionReturn ) {
		BatmanCooldown[id] = functionReturn
		flag = true
	}
	// Cola Lover
	ExecuteForward(ColaLoverForward, functionReturn, id)
	if ( ColaLoverCooldown[id] != functionReturn ) {
		ColaLoverCooldown[id] = functionReturn
		flag = true
	}
	// Penguin
	ExecuteForward(PenguinForward, functionReturn, id)
	if ( PenguinCooldown[id] != functionReturn ) {
		PenguinCooldown[id] = functionReturn
		flag = true
	}
	// FartMan - TiraPedos
	ExecuteForward(TiraPedosForward, functionReturn, id)
	if ( TiraPedosCooldown[id] != functionReturn ) {
		TiraPedosCooldown[id] = functionReturn
		flag = true
	}
	
	
	// Uchiha's Revenge
	ExecuteForward(UchihaForward, functionReturn, id)
	if ( UchihaLevel[id] != functionReturn ) {
		UchihaLevel[id] = functionReturn
		flag = true
	}
	ExecuteForward(UchihaForward2, functionReturn, id)
	if ( UchihaChidori[id] != functionReturn ) {
		UchihaChidori[id] = functionReturn
		flag = true
	}
	ExecuteForward(UchihaForward3, functionReturn, id)
	if ( UchihaAmaterasu[id] != functionReturn ) {
		UchihaAmaterasu[id] = functionReturn
		flag = true
	}
		
	if (flag) {
		new ent = id
		monitor_think2(ent)	// showhud(id)	
	}
}
#endif
//----------------------------------------------------------------------------------------------
public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() || !sh_is_inround() ) return
	if ( victim == attacker || !is_user_alive(attacker) ) return
	 
	// if ( gHasDarthMaulPowers[attacker] && !is_user_alive(victim) )
	//	KillCountDarth[attacker]++
		
	if ( gHasUchihaPower[attacker] && !is_user_alive(victim) )
		KillCountUchiha[attacker]++
}
//----------------------------------------------------------------------------------------------
public monitor_think2(ent)		// showhud(id)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED

	static class[32]
	pev(ent, pev_classname, class, charsmax(class))
	if ( equal(class, TaskClassname) ) {
		new len
		static players[32], count, i, id
		static temp[256]	//def
		get_players(players, count, "ch")

		for ( i = 0; i < count; i++ ) {
			id = players[i]
			temp[0] = '^0'
	
			if ( is_user_alive(id) ) {
				len = 0
				#if ACTIVE_POWERS_INFO
					if ( gHasUchihaPower[id] ) {
						len += formatex(temp[len], charsmax(temp) - len, "Nivel: [x] | Kills: [x/x]^n")
						}
					else if ( gHasDarthMaulPowers[id] ) {
						len += formatex(temp[len], charsmax(temp) - len, "Kills: [x/x]^n")
						}
					else 	{
						len += formatex(temp[len], charsmax(temp) - len, "")
					}
					
					// Uchiha's revenge
					if ( gHasUchihaPower[id] ) {
						new const gHeroName[] = "Uchiha's"
						if ( UchihaLevel[id] == 0 ) {
							len += formatex( temp[len], charsmax(temp) - len, "[%i] %s: [%i/%d] Chidori: %i | Amaterasu: %i^n", UchihaLevel[id], gHeroName, 
							KillCountUchiha[id], uchihakillsreq, UchihaChidori[id], UchihaAmaterasu[id] )
							}
						else if ( UchihaLevel[id] == 1 ) {
							len += formatex( temp[len], charsmax(temp) - len, "[%i] %s: [%i/%d] Chidori: %i | Amaterasu: %i^n", UchihaLevel[id], gHeroName, 
							KillCountUchiha[id], uchihakillsreq*2, UchihaChidori[id], UchihaAmaterasu[id] )
							}
						else if ( UchihaLevel[id] == 2 ) {
							len += formatex( temp[len], charsmax(temp) - len, "[%i] %s: [%i/%d] Chidori: %i | Amaterasu: %i^n", UchihaLevel[id], gHeroName, 
							KillCountUchiha[id], uchihakillsreq*3, UchihaChidori[id], UchihaAmaterasu[id])
							}
						else if ( UchihaLevel[id] == 3 ) {
							len += formatex( temp[len], charsmax(temp) - len, "[%i] %s: [%i/%d] Chidori: %i | Amaterasu: %i^n", UchihaLevel[id], gHeroName, 
							KillCountUchiha[id], uchihakillsreq*4, UchihaChidori[id], UchihaAmaterasu[id] )
							}	
						else 	{ 
							if ( UchihaLevel[id] == 4 ) {
								len += formatex( temp[len], charsmax(temp) - len, "[%i] %s: [%i/%d] Chidori: %i | Amaterasu: %i^n", UchihaLevel[id], gHeroName, 
								KillCountUchiha[id], uchihakillsreq*4, UchihaChidori[id], UchihaAmaterasu[id] )
							}
						}
					}
					
					// Darth Maul
					if ( gHasDarthMaulPowers[id] ) {
						// new const gHeroName[] = "Darth Maul"
						if (DarthMaulCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "Force Jump: %i", DarthMaulCooldown[id] )
							//len += formatex(temp[len], charsmax(temp) - len, "%s: %i Force Jump", gHeroName, DarthMaulCooldown[id] )
							//KillCountDarth[id] = 0
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "Force Jump: ON")
							//len += formatex(temp[len], charsmax(temp) - len, "%s: OFF [%i/%d]", gHeroName, KillCountDarth[id], dashkillsreq)
						}
						
						if ( !gHasObiPower[id] ) len += formatex(temp[len], charsmax(temp) - len, "^n")
					} 
					
					// Obi Wan
					if ( gHasObiPower[id] ) {
						new const gHeroName[] = "Obi Wan"
						if (ObiwanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, " | %s: %i^n", gHeroName, ObiwanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, " | %s: ON^n", gHeroName )
						}
					} 
					
					// Granadas Guion GRanadas Powers
					// Penguin
					if ( gHasPenguinPower[id] ) {
						new const gHeroName[] = "P"
						if (PenguinCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "[HE] %s: %i | ", gHeroName, PenguinCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "[HE] %s: ON | ", gHeroName )
						}
					} 
					
					// Cola Lover
					if ( gHasColaLoverPower[id] ) {
						new const gHeroName[] = "CL"
						if (ColaLoverCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "[FB] %s: %i | ", gHeroName, ColaLoverCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "[FB] %s: ON | ", gHeroName )
						}
					} 
					
					// BAtman
					if ( gHasBatman[id] ) {
						new const gHeroName[] = "B"
						if (BatmanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "[SG] %s: %i", gHeroName, BatmanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "[SG] %s: ON", gHeroName )
						}
					} 
					
					// BAtman
					if ( HasFartman[id] ) {
						new const gHeroName[] = "T"
						if (TiraPedosCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "[SG] %s: %i", gHeroName, TiraPedosCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "[SG] %s: ON", gHeroName )
						}
					} 
					
					set_hudmessage(61, 0, 205, -0.01, 0.65, 0, 0.0, 1.0, 0.0, 0.0)
					ShowSyncHudMsg(id, MonitorHudSync, "%s", temp)	//agregado
				#endif
			}
		}
	}
	
	return FMRES_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
