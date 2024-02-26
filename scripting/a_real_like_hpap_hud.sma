
#include <superheromod>

#define IsPlayer(%1) (1 <= %1 <= g_players)
new const PLUGIN_VERSION[]  = "1.0";
// new gRed, gBlue;
new g_players; 

new MonitorHudSync
new const TaskClassname[] = "monitorloop"
//----------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin("Aim Health", PLUGIN_VERSION,  "MaNiax");
	// RegisterHam(Ham_Player_PreThink, "player", "Player_PreThink");
	g_players = get_maxplayers();
	
	// Todo esto es del Hud
	new monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (monitor) {
		set_pev(monitor, pev_classname, TaskClassname)
		set_pev(monitor, pev_nextthink, get_gametime() + 0.1)
		register_forward(FM_Think, "monitor_think15")
	}
	
	MonitorHudSync = CreateHudSyncObj()
}
//----------------------------------------------------------------------------------------------
/* public Player_PreThink(id)
{
	new iPlr, iBody;
	get_user_aiming(id, iPlr, iBody);
 
	if( IsPlayer(iPlr) && is_user_alive(iPlr) ) {
		switch( cs_get_user_team(iPlr) ) {
			case CS_TEAM_T: {
				gRed = 255;
				gBlue = 0;
			}
			case CS_TEAM_CT: {
				gRed = 0;
				gBlue = 255;
			}
		}
  
		new EnemyHealth = get_user_health(iPlr);
		new EnemyName[33];
		new EnemyArmor = get_user_armor(iPlr);
		new level = sh_get_user_lvl(iPlr)
		get_user_name(iPlr, EnemyName, charsmax(EnemyName));
		set_hudmessage(gRed, gBlue, 0, -1.0, 0.65, 0, 6.0, 1.6, 0.1, 0.2, -1); 
		ShowSyncHudMsg( id, byakuganhud,"[Byakugan] %s: HP[%d], AP[%d]^nXP:[%d/%d] LVL:%d/%d", EnemyName, EnemyHealth, EnemyArmor, 
		sh_get_user_xp(iPlr), sh_get_lvl_xp(level + 1), sh_get_user_lvl(iPlr), sh_get_num_lvls() ) 
		
		// show_hudmessage(id, "Name: %s | Health: %i | Armor: %i", EnemyName, EnemyHealth, EnemyArmor);

	}
} */
//----------------------------------------------------------------------------------------------
public monitor_think15(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED

	static class[32]
	pev(ent, pev_classname, class, charsmax(class))

	if ( equal(class, TaskClassname) ) {
		new len
		static players[32], count, i, id
		static temp[128]
		
		get_players(players, count, "ch")
		for ( i = 0; i < count; i++ ) {
			id = players[i]
			temp[0] = '^0'

			new iPlr, iBody;
			get_user_aiming(id, iPlr, iBody);
			if( IsPlayer(iPlr) && is_user_alive(iPlr) ) {
				len = 0
				
				new EnemyHealth = get_user_health(iPlr);
				new EnemyName[33];
				new EnemyArmor = get_user_armor(iPlr);
				new level = sh_get_user_lvl(iPlr)
				get_user_name(iPlr, EnemyName, charsmax(EnemyName));
				
				len += formatex( temp, charsmax(temp), "[Byakugan] %s: HP[%d], AP[%d]^nXP:[%d/%d] LVL:%d/%d", EnemyName, EnemyHealth, EnemyArmor, 
				sh_get_user_xp(iPlr), sh_get_lvl_xp(level + 1), sh_get_user_lvl(iPlr), sh_get_num_lvls() )  
				
				set_hudmessage(0, 100, 200, -1.0, 0.65, 0, 0.0, 0.3, 0.0, 0.0) 
				ShowSyncHudMsg(id, MonitorHudSync, "%s", temp)	//agregado
			}
		}
	}

	return FMRES_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
