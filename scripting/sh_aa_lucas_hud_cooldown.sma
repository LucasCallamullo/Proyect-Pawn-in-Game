/* Plugin generated by AMXX-Studio */

#include <superheromod>

// Comentarios para un futuro yo, basicamente utilizo un enum como "indice" para poder atribuir correspondientemente,
// mediante arreglos paralelos una forma mas generica y simple de agregar heroes a esta lista sin tener que modificar todo el codigo.

enum _:PowerType {
	BlackHole,
	Blink,
	Casper,
	DanimothX,
	DarthVader,
	DrStrange,
	EmperadorPalpatine,
	Freezer,
	Goku_KaioKen,
	InvisibleWoman,
	LinternaVerde,
	Meteorix,
	MangekyouSharingan,
	NarutoUzumaki,
	Neo,
	Sandman,
	Scorpion,
	Shaco,
	Shadowcat,
	Sharknado,
	SubZero,
	SuperSaiyanGohan,
	Terminator,
	Tranza,
	Vegeta,
	WonderWoman,
	Yoda,
	Zeus
}


new gHeroNames[PowerType][] = {
	"Black Hole",
	"Blink",
	"Casper",
	"Danimoth X",
	"Darth Vader",
	"Dr. Strange",
	"Emperador Palpatine",
	"Freezer",
	"Goku's Kaio-Ken",
	"Invisible Woman",
	"Linterna Verde",
	"Meteorix",
	"Mangekyou Sharingan",
	"Naruto Uzumaki",
	"Neo",
	"Sandman",
	"Scorpion",
	"Shaco",
	"Shadowcat",
	"Sharknado",
	"Sub-Zero",
	"Super Saiyan Gohan",
	"Terminator",
	"Tranza",
	"Vegeta",
	"Wonder Woman",
	"Yoda",
	"Zeus"
}; 

new gHeroID[PowerType]; 
new bool:gHasPower[PowerType][SH_MAXSLOTS+1];		// En un futuro usar para interacciones entre heroes mas generico
new gCooldown[PowerType][SH_MAXSLOTS+1];
new gForward[PowerType]; 


// for the hud
new MonitorHudSync
new const TaskClassname[] = "monitorloop" 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
 	register_plugin("Plugin Cooldown SH", "4.0", "LucasCab Je :D")
	
	gForward[BlackHole] 	= CreateMultiForward("sendBHCooldown", ET_CONTINUE, FP_CELL)
	gForward[Blink] 	= CreateMultiForward("sendBlinkCooldown", ET_CONTINUE, FP_CELL)
	gForward[Casper] 	= CreateMultiForward("sendCasperCooldown", ET_CONTINUE, FP_CELL) 
	gForward[DanimothX] 	= CreateMultiForward("sendDanimothCooldown", ET_CONTINUE, FP_CELL)
	gForward[DarthVader] 	= CreateMultiForward("sendVaderCooldown", ET_CONTINUE, FP_CELL)
	gForward[DrStrange] 	= CreateMultiForward("sendDrStrangeCooldown", ET_CONTINUE, FP_CELL)
	gForward[EmperadorPalpatine]= CreateMultiForward("sendPalpatineCooldown", ET_CONTINUE, FP_CELL)
	gForward[Freezer] 	= CreateMultiForward("sendFriezaCooldown", ET_CONTINUE, FP_CELL) 
	gForward[Goku_KaioKen]	= CreateMultiForward("sendGokuKTCooldown", ET_CONTINUE, FP_CELL)
	gForward[InvisibleWoman]= CreateMultiForward("sendInvisWomanCooldown", ET_CONTINUE, FP_CELL)
	gForward[LinternaVerde] = CreateMultiForward("sendLanternCooldown", ET_CONTINUE, FP_CELL)
	gForward[Meteorix] 	= CreateMultiForward("sendMeteorixCooldown", ET_CONTINUE, FP_CELL)
	gForward[MangekyouSharingan]= CreateMultiForward("sendMSharinganCooldown", ET_CONTINUE, FP_CELL)
	gForward[NarutoUzumaki] = CreateMultiForward("sendNarutoscjCooldown", ET_CONTINUE, FP_CELL)
	gForward[Neo] 		= CreateMultiForward("sendNeoCooldown", ET_CONTINUE, FP_CELL) 
	gForward[Sandman] 	= CreateMultiForward("sendSandmanCooldown", ET_CONTINUE, FP_CELL)
	gForward[Scorpion] 	= CreateMultiForward("sendScorpionCooldown", ET_CONTINUE, FP_CELL)
	gForward[Shaco] 	= CreateMultiForward("sendShacoCooldown", ET_CONTINUE, FP_CELL)
	gForward[Shadowcat] 	= CreateMultiForward("sendShadowcatCooldown", ET_CONTINUE, FP_CELL)
	gForward[Sharknado] 	= CreateMultiForward("sendJawsCooldown", ET_CONTINUE, FP_CELL)
	gForward[SubZero]	= CreateMultiForward("sendSubZeroCooldown", ET_CONTINUE, FP_CELL)
	gForward[SuperSaiyanGohan] = CreateMultiForward("sendSSJGohanCooldown", ET_CONTINUE, FP_CELL) 
	gForward[Terminator] 	= CreateMultiForward("sendT800Cooldown", ET_CONTINUE, FP_CELL)
	gForward[Tranza] 	= CreateMultiForward("sendTranzaCooldown", ET_CONTINUE, FP_CELL)
	gForward[Vegeta] 	= CreateMultiForward("sendVegetaCooldown", ET_CONTINUE, FP_CELL)
	gForward[WonderWoman] 	= CreateMultiForward("sendWonWomanCooldown", ET_CONTINUE, FP_CELL)
	gForward[Yoda] 		= CreateMultiForward("sendYodaCooldown", ET_CONTINUE, FP_CELL)
	gForward[Zeus] 		= CreateMultiForward("sendZeusCooldown", ET_CONTINUE, FP_CELL)
	
	// Todo esto es del Hud
	new monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (monitor) {
		set_pev(monitor, pev_classname, TaskClassname)
		set_pev(monitor, pev_nextthink, get_gametime() + 0.1)
		register_forward(FM_Think, "monitor_thinkcooldown")
	}
	
	MonitorHudSync = CreateHudSyncObj()
	
	set_task(1.0, "loopMainCD", _, _, _, "b")	// Esta tarea es de los cooldowns
	set_task(0.2, "cache_idCD");   		// we need to let superhero cache all the heros to avoid issues
} 
 
public cache_idCD() 
{
	for (new i = 0; i < PowerType; i++) {
		gHeroID[i] = sh_get_hero_id(gHeroNames[i]);
	}
}

public sh_hero_init(id, heroID, mode)
{
	for (new i = 0; i < PowerType; i++) {
		if (gHeroID[i] == heroID) {
			gHasPower[i][id] = mode ? true : false;
		}
	}
}

public loopMainCD()
{	
	static players[SH_MAXSLOTS], playerCount, id, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		id = players[i]
		if ( !is_user_connected(id) || !is_user_alive(id) ) continue
		get_active_powers_info(id)
	}	
}

public get_active_powers_info(id)
{
	new bool:flag = false
	new functionReturn
	
	for (new i = 0; i < PowerType; i++) {
		ExecuteForward(gForward[i], functionReturn, id);
		if (gCooldown[i][id] != functionReturn) {
			gCooldown[i][id] = functionReturn;
			flag = true;
		}
	} 
	
	if (flag) {
		new ent = id
		monitor_thinkcooldown(ent)	
	}
}

public monitor_thinkcooldown(ent)		// showhud(id)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED

	static class[32]
	pev(ent, pev_classname, class, charsmax(class))
	if ( equal(class, TaskClassname) ) {
		static players[32], count, i, id
		static temp[128]
		get_players(players, count, "ch")

		for ( i = 0; i < count; i++ ) {
			id = players[i] 
			temp[0] = '^0'
	
			if ( !is_user_alive(id) ) continue 
			
			static len, powerT
			len = 0

			for ( powerT = 0; powerT < PowerType; powerT++ ) {
				
				if ( gHasPower[powerT][id] ) {
					
					if (gCooldown[powerT][id] > 0) 
						len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroNames[powerT], gCooldown[powerT][id]);
					
					// si el cooldown es == 0
					else 	{
						if ( powerT == Meteorix || powerT == DrStrange )
							len += formatex(temp[len], charsmax(temp) - len, "%s: OFF | ", gHeroNames[powerT])
						else 	// este era el original
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroNames[powerT])
					}
				}
			}
			
			set_hudmessage(0, 100, 200, 0.02, 0.70, 0, 0.0, 1.0, 0.0, 0.0)
			ShowSyncHudMsg(id, MonitorHudSync, "[CD]  %s", temp)	//agregado
		}
	}
	
	return FMRES_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/