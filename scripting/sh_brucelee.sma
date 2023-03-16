// SHANG-CHI! from Marvel Comics, aka The Master of Kung Fu.

/* CVARS - copy and paste to shconfig.cfg

//Bruce Lee
shangchi_level 1
shangchi_armor 130		//Starting Armor (Default 130)
shangchi_health 80		//Max HP Shang-Chi will reduce knife damage to (Default 80)

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
new const gHeroName[] = "Shang-Chi"
new bool:HasShangChi[SH_MAXSLOTS+1]
new pCvarHealth

#define MAX_MOVES 19

// Set the amount Damage for the counter moves
new MoveDamage[MAX_MOVES] = {
	100,	//Right Hook		(def=10)
	100,	//Left Hook		(def=10)
	70,	//Right Jab		(def=7)
	70,	//Left Jab		(def=7)
	120,	//Forward Jab		(def=12)
	120,	//Uppercut		(def=12)
	150,	//Right Cross		(def=15)
	150,	//Left Cross		(def=15)
	200,	//Front Kick		(def=20)
	150,	//Side Kick		(def=15)
	350,	//Round Kick		(def=35)
	400,	//Axe Kick		(def=40)
	250,	//Turn Back Kick	(def=25)
	170,	//Heel Kick		(def=17)
	300,	//Turn Heel Kick	(def=30)
	350,	//Roadhouse Kick	(def=35)
	450,	//Kick to the Balls	(def=45)
	200,	//Knee Strike		(def=20)
	1000	//Elbow Strike		(def=1000=KO)
}

new const MoveName[MAX_MOVES][] = {
	"Right Hook",
	"Left Hook",
	"Right Jab",
	"Left Jab",
	"Forward Jab",
	"Uppercut",
	"Right Cross",
	"Left Cross",
	"Front Kick",
	"Side Kick",
	"Round Kick",
	"Axe Kick",
	"Turn Back Kick",
	"Heel Kick",
	"Turn Heel Kick",
	"Roadhouse Kick",
	"Kick to the Balls",
	"Knee Strike",
	"Elbow Strike"
}
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Shang-Chi", "1.1", "AssKicR")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("shangchi_level", "1")
	pCvarHealth = register_cvar("shangchi_health", "900")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	HeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(HeroID, "Maestro del Kung Fu.", "Probabilidad de Contra-Atacar y posibilidad de recibir menos daño de un Fakaso.")
	sh_set_hero_hpap(HeroID, pCvarHealth)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( HeroID != heroID ) return

	HasShangChi[id] = mode ? true : false
}
//----------------------------------------------------------------------------------------------
public client_damage(attacker, victim, damage, wpnindex, hitplace)
{
	if ( !sh_is_active() ) return
	if ( !is_user_alive(victim) ) return

	if ( HasShangChi[attacker] && wpnindex == CSW_KNIFE ) {
		// Give him back 50% of the lost life
		sh_add_hp(victim, (damage/2), get_pcvar_num(pCvarHealth))

		if ( !is_user_alive(attacker) )
			return

		new randomMove = random_num(0, 30)
		if ( randomMove < MAX_MOVES ) {
			counter_attack(attacker, victim, randomMove)
		}
		else {
			sh_chat_message(victim, HeroID, "Le erraste a tu enemigo.")
		}
	}
}
//----------------------------------------------------------------------------------------------
public counter_attack(victim, id, moveNumber)
{
	if ( !shModActive() || !is_user_alive(victim) || !HasShangChi[id] )
		return

	new counterMove[32]
	new damage = MoveDamage[moveNumber]
	//Move numbers [16], [17], and [18] do not have Sloppy options
	if ( moveNumber < 16 && random_num(0, 1) ) {
		damage /= 2
		formatex(counterMove, 31, "Sloppy %s", MoveName[moveNumber])	 
	}
	else {
		copy(counterMove, 31, MoveName[moveNumber])
	}

	sh_chat_message(id, HeroID, "Le pegaste a tu enemigo con %s y le hizo %i de daño.", counterMove, damage)
	sh_chat_message(victim, HeroID, "Te golpearon con %s y tomaste %i de daño.", counterMove, damage)

	// Stupidity check
	if ( !damage ) ++damage

	sh_extra_damage(victim, id, damage, "kick boxing")

	// Make sure he's still alive
	if ( !is_user_alive(victim) )
		return

	// This makes the screen of the attacker flash
	sh_screen_fade(victim, 1.0, 2.0, 230, 10, 10, damage)

	// Make his Screen Shake a little
	sh_screen_shake(victim, 1.0, 1.0, 1.0)

	// Stun Him for 1 second
	sh_set_stun(victim, 1.0)
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
	HasShangChi[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
