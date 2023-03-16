// MajinBuu - Eat the shit out of your enemy aite!??!!? Cuz Rockell is here, so do not fear ^_^
/* CVARS - copy and paste to shconfig.cfg
	
 //MajinnBuu
buu_level 0
buu_chocolatehealth 100	// HP For eat Chocolate
buu_respawnpct	20  	// probability of respawn def=(20/100) like Dr. Strange
buu_hpmax 2000		// This is for control max hp, if u dont want raise more than that amount
buu_prcntchocolate 0.75	// probability of appear chocolate after to kill someone
*/

#include <amxmod>
#include <superheromod>
#include <Vexd_Utilities>
	 	
// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Majin Buu"
new bool:gHasBuuPower[SH_MAXSLOTS+1]
new bool:gBuuReviveUsed[SH_MAXSLOTS+1]

new gUserTeam[SH_MAXSLOTS+1]
new PcvarBuuHpMax, pcvarChoPercent, pcvarChoHealth, pcvarRespawnpct, pcvarCooldown
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------ 
public plugin_init()
{
	// Plugin Info
	register_plugin("MajinBuu","1.0","duper/Rockell")
	 
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("buu_level", "2" )	
	pcvarChoHealth 	= register_cvar("buu_chocolatehealth", "200")
	pcvarRespawnpct	= register_cvar("buu_respawnpct", "20")
	pcvarCooldown	= register_cvar("buu_respawncooldown", "0.0")
	PcvarBuuHpMax 	= register_cvar("buu_hpmax", "2000")
	pcvarChoPercent	= register_cvar("buu_prcntchocolate", "0.75")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Come Chocolate por Salud!", "Convierte a tus enemigos en chocolate al matarlos para recuperar salud al comerlos, posibilidad de revivir.")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	//test eventois
	register_logevent("round_end", 2, "1=Round_End")
	register_logevent("round_end", 2, "1&Restart_Round_")

}

public plugin_precache() 
{
	precache_model("models/shmod/chocolate.mdl")
	precache_sound("doors/aliendoor3.wav")
	precache_sound("ambience/port_suckin1.wav")
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and SPAWN y REMOVE ENTITYS				//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	gHasBuuPower[id] = mode ? true : false
}

public sh_client_spawn(id)
{
	if ( gHasBuuPower[id] ) 
		remove_chocolates()
}
public remove_chocolates()
{
	new chocolate = find_ent_by_class(-1, "chocolate")
	while(chocolate) {
		remove_entity(chocolate)
		chocolate = find_ent_by_class(chocolate, "chocolate")
	}
}
//------------------------------------------------------------------------------------------------
//				Death Y Creacion de Entidad Y Touch				//
//------------------------------------------------------------------------------------------------
public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() || !sh_is_inround() ) return
	if ( victim == attacker ) return
	 
	new randnum = random_num(0, 100)
	new chocolatechance = floatround(get_pcvar_float(pcvarChoPercent) * 100) 
	
	if ( chocolatechance >= randnum && is_user_alive(attacker) && gHasBuuPower[attacker] ) {
			new dead = victim
			new parm[1]
			parm[0] = dead
			createChocolate(parm)
	}
	
	if ( victim <= 0 || victim > SH_MAXSLOTS ) return
	if ( !is_user_connected(victim) ) return
	
	remove_task(victim)
	
	new randNum = random_num(0, 100)
	new pctChance = get_pcvar_num(pcvarRespawnpct)
	if ( pctChance < randNum ) return

	gUserTeam[victim] = get_user_team(victim)

	// Look for self to raise from dead
	if ( !is_user_alive(victim) && gHasBuuPower[victim] ) {
		// Zombie will raise self from dead
		new parm[1]
		parm[0] = victim
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
		set_task(1.0, "buu_respawn", 0, parm, 1)
	}
}

public createChocolate(parm[])
{
		new victim = parm[0]
	
		new Float:vAim[3], Float:vOrigin[3]
		entity_get_vector(victim, EV_VEC_origin, vOrigin)
		VelocityByAim(victim, random_num(2, 4), vAim)
	
		vOrigin[0] += vAim[0]
		vOrigin[1] += vAim[1]
		vOrigin[2] += 30.0
	
		new chocolate = create_entity("info_target")
		entity_set_string(chocolate, EV_SZ_classname, "chocolate")
		entity_set_model(chocolate, "models/shmod/chocolate.mdl")	
		entity_set_size(chocolate, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5})
		entity_set_int(chocolate, EV_INT_solid, SOLID_TRIGGER)
		entity_set_int(chocolate, EV_INT_movetype, 6) 
		entity_set_vector(chocolate, EV_VEC_origin, vOrigin)
}

public pfn_touch(ptr, ptd) 
{
	if(!is_valid_ent(ptd) || !is_valid_ent(ptr)) return PLUGIN_CONTINUE
	if(!is_user_connected(ptd) || !is_user_alive(ptd)) return PLUGIN_CONTINUE
	
	new classname[32]
	entity_get_string(ptr, EV_SZ_classname, classname, 31)
	if(equal(classname, "chocolate")) 
	{
		if( gHasBuuPower[ptd] ) {
			new gOrigHealth = get_user_health(ptd)
			new health = gOrigHealth + get_pcvar_num(pcvarChoHealth)
			if ( health <= get_pcvar_num(PcvarBuuHpMax) ) {		// HP Max def = 2000
				set_user_health(ptd, health)
				}
			else  	{ 
				set_user_health(ptd, get_pcvar_num(PcvarBuuHpMax) )
			}
			remove_entity(ptr)
		}
	}
	
	return PLUGIN_CONTINUE
}
//------------------------------------------------------------------------------------------------
//				Buu Respawn						//
//------------------------------------------------------------------------------------------------
public buu_respawn(parm[])
{
	new id = parm[0]

	if ( !is_user_connected(id) || is_user_alive(id) ) return
	if ( gBuuReviveUsed[id] || !sh_is_inround() ) return
	if ( gUserTeam[id] != get_user_team(id) ) return 	//prevents respawning spectators

	emit_sound(id, CHAN_STATIC, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	sh_chat_message(id, gHeroID, "Volviste a la vida con el poder de %s!", gHeroName)

	// Double spawn prevents the no HUD glitch
	user_spawn(id)
	user_spawn(id)

	// Respawned by Dr. Strange, it's ok to set cooldown now.
	new Float:BuuCooldown = get_pcvar_float(pcvarCooldown)
	if( BuuCooldown > 0.0 ) {
		set_task(BuuCooldown, "enableBuu", 177+id)
		gBuuReviveUsed[id] = true
	}

	emit_sound(id, CHAN_STATIC, "doors/aliendoor3.wav", 0.6, ATTN_NORM, 0, PITCH_LOW)

	sh_set_rendering(id, 245, 0, 135, 16, kRenderFxGlowShell)
	set_task(3.0, "buu_unglow", id)
	set_task(1.0, "buu_teamcheck", 0, parm, 1)
}

public buu_unglow(id)
	sh_set_rendering(id)
	
public buu_teamcheck(parm[])
{
	new id = parm[0]

	if ( gUserTeam[id] != get_user_team(id) ) {
		sh_chat_message(id, gHeroID, "Cambiaste de equipo y no puedes revivir como %s, ahora moriras!", gHeroName)
		user_kill(id, 1)

		// Stop Zombie from respawning until round ends
		remove_task(177+id)
	}
}

public enableBuu(id)
{
	id -= 177
	gBuuReviveUsed[id] = false
}

public round_end()
{
	if ( !shModActive() ) return
	// Reset the cooldown on round end, to start fresh for a new round
	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( gHasBuuPower[id] ) {
			remove_task(177+id)
			gBuuReviveUsed[id] = false
		}
	}
}

public client_disconnected(id)
{
	// stupid check but lets see
	if ( id <= 0 || id > SH_MAXSLOTS ) return
	// Yeah don't want any left over residuals
	remove_task(id)
	gHasBuuPower[id] = false
}

public client_connect(id)
	gHasBuuPower[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
