/*
// Soraka
soraka_level 5		//nivel de heroe
soraka_hptoadd 500	//Cantidad que cura
soraka_hpmax 2000	//Max Hp que puede llegar a curar no pasara este limtie
soraka_addforK 50

*/

#include <superheromod>

new gHeroID
new const gHeroName[] = "Soraka"
new bool:gHasSoraka[SH_MAXSLOTS+1]
new pcvarHPToAdd, pcvarHPMax, pcvarHPToAddForK, PcvarKillsReqSor, pcvarHPDeseo, pcvarXPToAddSor
new KillCountSoraka = 0
//------------------------------------------------------------------------------------------------
//					INIT's	+ Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SUPERHERO Ally Push", "1.4", "Jelle")
	
	new pcvarLevel 		= register_cvar("soraka_level", "5")
	pcvarHPToAdd 		= register_cvar("soraka_hptoadd", "500")	// Hp que otorga al morir
	pcvarHPMax 		= register_cvar("soraka_hpmax", "2000")		// Hp Max no pueden ganar mas vida que esta
	pcvarHPToAddForK 	= register_cvar("soraka_addforK", "100")	// gananncia por matar a alguien //def 15
	PcvarKillsReqSor	= register_cvar("soraka_reqkills", "2")
	pcvarHPDeseo		= register_cvar("soraka_hpdeseo", "500")
	pcvarXPToAddSor		= register_cvar("soraka_xptoadd", "500")
	
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Recupera HP y Otorga HP.", "Cada vez que moris curas a todo tu equipo y al matar recuperas HP por encima de tu MaxHP.")
}

public plugin_precache() 
	precache_model("models/shmod/sorakahealth.mdl")

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	gHasSoraka[id] = mode ? true : false
}

public sh_client_spawn(id)
{
	remove_sorakahealth()
	if ( gHasSoraka[id] ) KillCountSoraka = 0	
}
//------------------------------------------------------------------------------------------------
//					Client Death + Heals					//
//------------------------------------------------------------------------------------------------
public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() || !sh_is_inround() || victim == attacker ) return
	
	if ( gHasSoraka[victim] && !is_user_alive(victim) ) {
		
		new CsTeams:victimTeam = cs_get_user_team(victim)
		new players[32], playerCount, player		//aca iba el ,i
		get_players(players, playerCount, "a")	//"a" - do not include dead clients // "b" - do not include alive clients
		
		for ( new i = 0; i < playerCount; i++) {
			
			player = players[i]
			if ( cs_get_user_team(player) == victimTeam) {
				// HP boost
				new userHealth = get_user_health(player)
				if (userHealth < get_pcvar_num(pcvarHPMax)) {
					// HP boost
					new newHP = get_pcvar_num(pcvarHPToAdd)
					new gsorakaName[32], playerName[32]
					get_user_name(victim, gsorakaName, charsmax(gsorakaName))
					get_user_name(player, playerName, charsmax(playerName))
					
					if (userHealth + newHP > get_pcvar_num(pcvarHPMax)) {
						set_user_health(player, get_pcvar_num(pcvarHPMax))
						sh_chat_message(victim, gHeroID, "Curaste a tu aliado: %s por %d y esta en su maximo HP", playerName, newHP) 
						sh_chat_message(player, -1, "[%s] Uso su poder de Soraka y Te Curo por %d de HP", gsorakaName, newHP) 
					}
						
					else {
						set_user_health(player, userHealth + newHP)
						//sh_chat_message(victim, gHeroID, "Curaste a tu aliado: %s por %d", playerName, newHP) 
						sh_chat_message(player, -1, "%s Te Curo por %d de HP", gsorakaName, newHP) 
					}
					
				}
			}
		}
		
		remove_sorakahealth()
	}
	
	if ( gHasSoraka[attacker] && is_user_alive(attacker) && attacker != victim ) {
		new attackerhealth = get_user_health(attacker)
		if (attackerhealth < get_pcvar_num(pcvarHPMax)) {
			
			new GainHpFk = get_pcvar_num(pcvarHPToAddForK) 
			if (attackerhealth + GainHpFk > get_pcvar_num(pcvarHPMax)) {
				set_user_health(attacker, pcvarHPMax)
				}
			else 	{
				set_user_health(attacker, attackerhealth + GainHpFk) 	
			}
		}
		KillCountSoraka = KillCountSoraka + 1
		Soraka_Heatlh(attacker)
	}
}

public Soraka_Heatlh(attacker)
{
	new id = attacker
	new CsTeams:attackerTeam = cs_get_user_team(id)
	
	if (KillCountSoraka == get_pcvar_num(PcvarKillsReqSor) ) {
		new players[32], playerCount, player		//aca iba el ,i
		get_players(players, playerCount, "a")		//"a" - do not include dead clients // "b" - do not include alive clients
		for ( new i = 0; i < playerCount; i++) {
			player = players[i]
			if ( cs_get_user_team(player) == attackerTeam ) {
				// HP boost
				new userHealth = get_user_health(player)
				new newHP = get_pcvar_num(pcvarHPDeseo)
				if (userHealth < get_pcvar_num(pcvarHPMax)) {
					// Obtener Names
					new gsorakaName[32], playerName[32]
					get_user_name(id, gsorakaName, charsmax(gsorakaName))
					get_user_name(player, playerName, charsmax(playerName))
					
					if (userHealth + newHP > get_pcvar_num(pcvarHPMax) ) {
						set_user_health(player, get_pcvar_num(pcvarHPMax) )
						}	
					else 	{
						set_user_health(player, userHealth + newHP)
						sh_chat_message(id, gHeroID, "Concediste un Deseo curaste a todos tus Aliados por: %d", newHP) 
						sh_chat_message(player, -1, "%s Logro un Deseo y te curo por %d de HP", gsorakaName, newHP) 
					}
				}
			}
		}
		set_task(2.0, "createsorakatask", id)
	}
}
//----------------------------------------------------------------------------------------------
public createsorakatask(id)
{
	if ( gHasSoraka[id] && is_user_alive(id) && KillCountSoraka == get_pcvar_num(PcvarKillsReqSor) ) {
		new aimvec[3]			// Get position from eyes
		get_user_origin(id, aimvec, 3)	// Get position from eyes
		create_sorakahealth(id, aimvec)
		KillCountSoraka = 0	
	}
}

public create_sorakahealth(id, aimvec[3])
{ 
	new Float:vOrigin[3]
	vOrigin[0] += aimvec[0]
	vOrigin[1] += aimvec[1] 
	vOrigin[2] += aimvec[2] + 40
	
	new sorakah = create_entity("info_target")
	entity_set_string(sorakah, EV_SZ_classname, "sorakah")
	entity_set_model(sorakah, "models/shmod/sorakahealth.mdl")	
	entity_set_size(sorakah, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5})
	entity_set_edict(sorakah, EV_ENT_owner, id)
	entity_set_int(sorakah, EV_INT_solid, SOLID_TRIGGER)
	entity_set_int(sorakah, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_vector(sorakah, EV_VEC_origin, vOrigin)
}
//----------------------------------------------------------------------------------------------
public pfn_touch(ptr, ptd) 
{
	if(!is_valid_ent(ptd) || !is_valid_ent(ptr)) return PLUGIN_CONTINUE		
	if(!is_user_connected(ptd) || !is_user_alive(ptd)) return PLUGIN_CONTINUE	
	
	new classname[32]
	entity_get_string(ptr, EV_SZ_classname, classname, 31)
	if(equal(classname, "sorakah")) {
		
		new iOwner;
		iOwner = entity_get_edict(ptr, EV_ENT_owner);
		if( is_user_connected(iOwner) && get_user_team(iOwner) == get_user_team(ptd) && iOwner != ptd ) {
			
			new gOrigHealth = get_user_health(ptd)
			new newHP = get_pcvar_num(pcvarHPDeseo)
			new health = gOrigHealth + newHP
			new iXPToAdd = get_pcvar_num(pcvarXPToAddSor)
			
			new gsorakaName[32]
			get_user_name(iOwner, gsorakaName, charsmax(gsorakaName))
			
			if (health > get_pcvar_num(pcvarHPMax) ) {
				set_user_health(ptd, get_pcvar_num(pcvarHPMax))
				sh_set_user_xp(ptd, iXPToAdd, true)
				sh_chat_message(ptd, -1, "Agarraste el Regalo de %s obtuviste: %d de XP.", gsorakaName, iXPToAdd)
				}
			else  	{
				set_user_health(ptd, health)
				sh_set_user_xp(ptd, iXPToAdd, true)
				sh_chat_message(ptd, -1, "Agarraste el Regalo de %s obtuviste: %d HP y %d XP.", gsorakaName, newHP, iXPToAdd)
			}
				 
			remove_entity(ptr);
		}
	}  
	
	return PLUGIN_CONTINUE
}

public remove_sorakahealth()
{
	new sorakah = find_ent_by_class(-1, "sorakah")
	while(sorakah) {
		remove_entity(sorakah)
		sorakah = find_ent_by_class(sorakah, "sorakah")
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
