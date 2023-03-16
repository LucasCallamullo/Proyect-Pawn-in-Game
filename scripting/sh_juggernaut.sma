// JUGGERNAUT (Non-Stop Version)

/* CVARS - copy and paste to shconfig.cfg

//Juggernaut
juggernaut_level 2	//level del poder
juggernaut_knife_percent 0.05	//probabilidad de bloackear un fakaso max 1.00

*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Juggernaut"
new bool:gHasJuggernaut[SH_MAXSLOTS+1]
new bool:gRestoreVel
new Float:vecVel[3]
new fm_PreThink
new fm_PreThink_Post

new gPcvarPctPerLev

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Juggernaut (Non-Stop)", "1.0", "1sh0t2killz AKA Subtlety")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("juggernaut_level", "2")
	gPcvarPctPerLev	= register_cvar("juggernaut_knife_percent", "0.05")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Imparable!", "El retroceso de las balas te afecta poco, y podes llegar a blockear Fakasos! se activa cuanto más nivel tengas.")

	// PRE-THINK AND POST-THINK
	fm_PreThink = register_forward(FM_PlayerPreThink, "Player_PreThink")
	fm_PreThink_Post = register_forward(FM_PlayerPreThink, "Player_PreThink_Post", 1)
	
	//cosas de la roca para que no te peguen fakasos, onda si te podes salvar te salva gg
	register_event("Damage", "Juggernaut_damage", "b", "2!0")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	gHasJuggernaut[id] = mode ? true : false

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public plugin_end()
{
	if(fm_PreThink) {
		unregister_forward(FM_PlayerPreThink, fm_PreThink)
	}
	if(fm_PreThink_Post) {
		unregister_forward(FM_PlayerPreThink, fm_PreThink_Post, 1)
	}
}
//----------------------------------------------------------------------------------------------
public Player_PreThink(id)
{
	if(gHasJuggernaut[id]) {
		if(pev_valid(id) && is_user_alive(id) && (FL_ONGROUND & pev(id, pev_flags))) {
			pev(id, pev_velocity, vecVel)
			gRestoreVel = true
		}
		
		return FMRES_HANDLED
	}
	
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public Player_PreThink_Post(id)
{
	if(gRestoreVel && gHasJuggernaut[id]) {
		gRestoreVel = false

		if(!(FL_ONTRAIN & pev(id, pev_flags))) {
			static iGEnt
			
			iGEnt = pev(id, pev_groundentity)
			if(pev_valid(iGEnt) && (FL_CONVEYOR & pev(iGEnt, pev_flags))) {
				static Float:vecTemp[3]
				
				pev(id, pev_basevelocity, vecTemp)
				
				vecVel[0] += vecTemp[0]
				vecVel[1] += vecTemp[1]
				vecVel[2] += vecTemp[2]
			}				

			set_pev(id, pev_velocity, vecVel)
			
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public Juggernaut_damage(id)
{
	if ( !shModActive() || !gHasJuggernaut[id] || !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id,weapon,bodypart)
	
	static Float:pctperlev
	pctperlev = get_pcvar_float(gPcvarPctPerLev)
	new ThingLevel = floatround(pctperlev * sh_get_user_lvl(id)) 
	
	if ( ThingLevel >= random_num(0, 100) && id != attacker && weapon==CSW_KNIFE && bodypart!=HIT_HEAD ) {
		
		new u_health = get_user_health(id)
		new newlife = u_health + damage + 1
		
		shAddHPs(id, damage, newlife) 
		set_hudmessage(0, 100, 200, 0.05, 0.63, 1, 0.1, 2.0, 0.1, 0.1, 3)
		show_hudmessage(id, "[%s] Blockeo un Fakaso!", gHeroName)
	} 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/