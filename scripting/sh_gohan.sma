// GOHAN! - from Dragon Ball Z, Goku and Chi Chi's first son.

/* CVARS - copy and paste to shconfig.cfg

//Gohan
gohan_level 10
gohan_health 150		//default 150
gohan_gravity 0.40		//default 0.40 = low gravity
gohan_speed 800		//How fast he is with all weapons
gohan_healpoints 10		//The # of HP healed per second
gohan_healmax 400		//Max # HP gohan can heal to

*/

/*
* v1.2 - vittu - 6/19/05
*      - Minor code clean up.
*
* v1.1 - vittu - 3/13/05
*      - recoded from ArtofDrowning07 cleaned up code
*      - new cvar from ArtofDrowning07, gohan_healmax, you
*         can choose how much goten will heal to now
*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Gohan"
new bool:ghasGohanPowers[SH_MAXSLOTS+1]
new gHealPoints, gHealAmount
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Gohan", "1.2", "sharky")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("gohan_level", "10")
	new pcvarHealth	= register_cvar("gohan_health", "250")
	new pcvarSpeed	= register_cvar("gohan_speed", "800")
	register_cvar("gohan_healpoints", "20")
	register_cvar("gohan_healmax", "500")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Super Power-Up.", "Obtén HP y suma más a cada segundo. También, obtén Super Velocidad!")
	sh_set_hero_hpap(gHeroID, pcvarHealth)
	sh_set_hero_speed(gHeroID, pcvarSpeed)

	//Set Varibles when plugin loads
	gHealPoints = get_cvar_num("gohan_healpoints")
	gHealAmount = get_cvar_num("gohan_healmax")
	
	// HEAL LOOP
	set_task(1.0, "gohan_loop", 0, "", 0, "b")
}

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	 
	switch(mode) {
		case SH_HERO_ADD: {
			ghasGohanPowers[id] = true
		}
		case SH_HERO_DROP: {
			ghasGohanPowers[id] = false
		}
	}
}

public gohan_loop()
{
	if ( !shModActive() || !hasRoundStarted() ) return

	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( ghasGohanPowers[id] && is_user_alive(id) ) {
			// Let the server add the hps back since the # of max hps is controlled by it
			// I.E. Superman has more than 100 hps etc.
			shAddHPs(id, gHealPoints, gHealAmount)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/