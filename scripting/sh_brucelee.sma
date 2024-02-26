// SHANG-CHI! from Marvel Comics, aka The Master of Kung Fu.

/* CVARS - copy and paste to shconfig.cfg

//Bruce Lee
bruce_level 1
bruce_halfdamage 2	// Amount of damage to be divided def(damage / 2)
bruce_cooldown 20	// Cooldown entre pegar un contraataque
*/

/*
* v1.1 - vittu - 8/24/08
*      - Optimized, removed useless code, and made sh take care of damage caused.
*      - Updated to be SH 1.2.0 compliant.
*
*    Hero orginally created by AssKicR.
*/

#include <superheromod>

// GLOBAL VARIABLES
new HeroID
new const gHeroName[] = "Bruce Lee"
new bool:HasShangChi[SH_MAXSLOTS+1]
new gPcvarDamage, gPcvarCooldown

#define MAX_MOVES 11
// Set the amount Damage for the counter moves
new MoveDamage[MAX_MOVES] = {
	// low damage
	300, // "Roundhouse Kick", 	// Patada giratoria
	400, // "Front Kick",		// Patada frontal
	400, // "Front Kick",		// Patada frontal
	500, // "Side Kick", 		// Patada lateral
	500, // "Side Kick", 		// Patada lateral
	600, // "Cross", 		// Cruzado
	//  mid damage
	700, // "Kick to the Balls", 	// Patada giratoria
	750, // "Uppercut",		// Uppercut
	800, // "Sweep Kick", 		// Patada de barrido
	850, // "Elbow Strike", 	// Golpe de codo
	// KO damage
	1500 // "Counter-Strike",	// Contra ataque
}

new const MoveName[MAX_MOVES][] = {
	// low damage
	"Roundhouse Kick", 	// Patada giratoria
	"Front Kick",		// Patada frontal
	"Front Kick",		// Patada frontal
	"Side Kick", 		// Patada lateral
	"Side Kick", 		// Patada lateral
	"Cross", 		// Cruzado
	//  mid damage
	"Kick to the Balls", 	// Patada giratoria
	"Uppercut",		// Uppercut
	"Sweep Kick", 		// Patada de barrido
	"Elbow Strike", 	// Golpe de codo
	// KO damage
	"Counter-Strike",	// Contra ataque
}

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Shang-Chi", "1.1", "AssKicR")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("bruce_level", "1")
	gPcvarDamage 	= register_cvar("bruce_halfdamage", "2")
	gPcvarCooldown 	= register_cvar("bruce_cooldown", "15")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	HeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(HeroID, "Maestro del Kung Fu.", "Probabilidad de Contra-Atacar y posibilidad de recibir menos daño de un Fakaso.")
	
	// Evento Damage
	RegisterHam(Ham_TakeDamage, "player", "Fw_TakeDamage_Pre", 0)
}
//------------------------------------------------------------------------------------------------
//					INIT y SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( HeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				HasShangChi[id] = true
				gPlayerInCooldown[id] = false
			}
			case SH_HERO_DROP: {
				HasShangChi[id] = false
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}	
}

public sh_client_spawn(id) {
	if ( HasShangChi[id] ) {
		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		else gPlayerInCooldown[id] = false
	} 
}

public sh_client_death(id) {
	// Para obtener la cantidad real de cooldown que tiene el poder
	if ( HasShangChi[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}
//----------------------------------------------------------------------------------------------
//			Pre Take Damage.
//----------------------------------------------------------------------------------------------
public Fw_TakeDamage_Pre(iVictim, iInflictor, iAttacker, Float:fDamage) // , bitsDamageType
{
	// return ham_ignored es como el plugin_continue
	if ( ! (1 <= iAttacker <= SH_MAXSLOTS) ) return HAM_IGNORED;
	if ( ! (1 <= iVictim <= SH_MAXSLOTS) ) return HAM_IGNORED;
	
	if ( !HasShangChi[iVictim] || gPlayerInCooldown[iVictim] ) return HAM_IGNORED
	if ( !is_user_alive(iVictim) || !is_user_alive(iAttacker)) return HAM_IGNORED
	
	// obtengo el arma, y tambien verifico que el knife sea del atacante solo con el knife porque sino podria
	// bugearlo con las he grenade por eso la verificacion atacker== inflictor
	new randnum = random_num(1, 100)
	new prob = random_num(1, 20)
	
	if ( get_user_weapon(iAttacker) == CSW_KNIFE && iAttacker == iInflictor && prob >= randnum ) {
		
		SetHamParamFloat(4, fDamage / get_pcvar_float(gPcvarDamage))
		counter_attack(iVictim, iAttacker)
		
		return HAM_HANDLED
		// return HAM_IGNORED
	}
     
	return HAM_IGNORED
}

public counter_attack(id, victim)
{
	if ( !is_user_alive(victim) || !HasShangChi[id] ) return
	
	new moveNumber = random_num(0, 10)
	new damage = MoveDamage[moveNumber]

	sh_chat_message(id, HeroID, "Le pegaste a tu enemigo con %s y le hizo %i de daño.", MoveName[moveNumber], damage)
	sh_chat_message(victim, HeroID, "Te golpearon con %s y tomaste %i de daño.", MoveName[moveNumber], damage)
	sh_extra_damage(victim, id, damage, "Kung Fu")

	// Make sure he's still alive
	if ( !is_user_alive(victim) ) return

	// This makes the screen of the attacker flash
	sh_screen_fade(victim, 1.0, 2.0, 230, 10, 10, damage)

	// Make his Screen Shake a little
	sh_screen_shake(victim, 1.0, 1.0, 1.0)

	// Stun Him for 1 second
	sh_set_stun(victim, 1.0)
	
	new Float:seconds = get_pcvar_float(gPcvarCooldown)
	if ( seconds > 0.0 ) {
		sh_set_cooldown(id, seconds)
		gPcvarRealCD[id] = seconds
	}
}

public client_connect(id) HasShangChi[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/