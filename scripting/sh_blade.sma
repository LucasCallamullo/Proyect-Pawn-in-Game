// BLADE! from Marvel Comics and the Movie series. "Daywalker" the half vampire half human that hunts vampires.
/* CVARS - copy and paste to shconfig.cfg

//Blade
blade_level 5
blade_speed 350		//How fast he runs with knife, usp, or mac10 (Default 350)
blade_knifeburns 8	//Amount of burns from a knife attack, set to -1 for continuous burn (Default 8)
blade_knifeburndmg 5	//Amount of damage per burn from knife burn (Default 5)
blade_gunburns 5 	//Amount of burns from a usp/mac10 attack (Default 5)
blade_gunburndmg 3	//Amount of damage per burn from gun burn (Default 3)

*/
/*
* v1.3 - vittu - 10/26/10
*       - Updated VampHeroName to be more dynamic and defined simpler. thx Emp`
*
* v1.2 - vittu - 11/5/09
*       - Updated to be SH 1.2.0 compliant.
*      - Changed Vampire detection, now all is done within Blade no longer required to edit other
*	    heroes. Use VAMP_HEROES and VampHeroName[][] to make additional heroes vampires.
*      - Changed defines to not use values but be commented and uncommented instead.
*      - Defaulted AMMO_MODE to use sh_reloadmode instead of using the normal cs setting.
*
* v1.1 - vittu - 5/3/06
*      - Cleaned up and recoded.
*      - Modified Dracula so Blade can actually work, included with download. (sh_dracula v1.18m)
*      - Changed glock to mac10 (since that's what he uses), with optional model. 
*      - Changed damage to be determined by number of burns.
*      - Changed scream sound.
*      - Fixed and changed speed to work with knife, usp, and mac10.
*      - Removed knife damage multiplier against non-dracula's.
*
*   Hero Created by TreDizzle and AssKicR (Burn code based on Human Torch)
*   Optional MAC10 weapon model reskinned by RCCSTEBB with DSFCHOOT's help (orginal by Ghost Ops Team, Strykerwolf, and Edisleado)
*/
//---------- User Changeable Defines --------//
// Note: If you change anything from default setting you must recompile the plugin
// Add the vampire hero names here. Put names in quotes and a comma after each except the last name. 
// **Hero names MUST be spelled correctly
new const VampHeroName[][] = {
	"Dracula",
	"Batman",
	"Catwoman",
	"Blackwidow",
	"Darth Maul",
	"Darth Vader",
	"Chucky",
	"Morpheus",
	"Neo",
	"Majin Buu",
	"Veronika"
}

//------- Do not edit below this point ------//
#include <superheromod>

// Number of Vampire Heros to check for based on number of names in VampHeroName
#define VAMP_HEROES sizeof VampHeroName

// Generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Morpheus",
	"Veronika"
}


// GLOBAL VARIABLES
new HeroID
new const HeroName[] = "Blade"
new bool:HasBlade[SH_MAXSLOTS+1]
new bool:InKnifeBurn[SH_MAXSLOTS+1]
new bool:InGunBurn[SH_MAXSLOTS+1]

// Vampire effects
new VampHeroID[VAMP_HEROES]
new IsVampire[SH_MAXSLOTS+1]
new bool:VampState[SH_MAXSLOTS+1][VAMP_HEROES]

new SpriteSmoke, SpriteFire
new blade_knifeburns, blade_knifeburndmg, blade_gunburns, blade_gunburndmg

new const SoundVampBurn[] = "ambience/burning1.wav"
new const SoundVampScream[] = "controller/con_die2.wav"

new const gBladeKnife[] = "models/shmod/blade_knife_v.mdl"
// new const gBladeKnife2[] = "models/shmod/blade_knife_p.mdl"

new const ModelMAC10[] = "models/shmod/blade_v_mac10.mdl"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Blade", "1.3", "TreDizzle/AssKicR/vittu") 

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= register_cvar("blade_level", "5")
	blade_knifeburns 	= register_cvar("blade_knifeburns", "8")
	blade_knifeburndmg 	= register_cvar("blade_knifeburndmg", "5")
	blade_gunburns 		= register_cvar("blade_gunburns", "5")
	blade_gunburndmg 	= register_cvar("blade_gunburndmg", "3")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	HeroID = sh_create_hero(HeroName, pcvarLevel)
	sh_set_hero_info(HeroID, "Caza Vampiros, Balas y Hacha de Plata.", "Quema a los Héroes Nocturnos(Dracula, Batman, Chucky, etc) con tus Balas y Hacha(knife).")
	sh_set_hero_shield(HeroID, true)

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	RegisterHam(Ham_Item_Deploy, "weapon_mac10", "Mac_Deploy", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Knife_Deploy", 1)
}

public plugin_precache() {
	precache_model(gBladeKnife)
	// precache_model(gBladeKnife2) // p_model
	SpriteSmoke = precache_model("sprites/steam1.spr")
	SpriteFire = precache_model("sprites/xfire.spr")
	precache_sound(SoundVampBurn)
	precache_sound(SoundVampScream)
	precache_model(ModelMAC10)
}
//----------------------------------------------------------------------------------------------
//				INIT
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	// This would be less complex if checking for only 1 hero
	for ( new x = 0; x < VAMP_HEROES; x++ ) {
		// Only check for changes if hero init'd was a vampire hero
		if ( VampHeroID[x] == heroID ) {
			//Create in here since this will only get called once
			new bool:isvamp
			VampState[id][x] = mode ? true : false
			for ( new i = 0; i < VAMP_HEROES; i++ ) {
				if ( VampState[id][i] == true ) {
					isvamp = true
					break
				}
			}
			IsVampire[id] = isvamp
			break
		}
	}

	if ( HeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				HasBlade[id] = true
				blade_weapons(id)
				switch_model(id)
			}
	
			case SH_HERO_DROP: {
				HasBlade[id] = false
				sh_drop_weapon(id, CSW_DEAGLE, true)
				sh_drop_weapon(id, CSW_MAC10, true)
			}
		}
		
		sh_debug_message(id, 1, "%s %s", HeroName, mode ? "ADDED" : "DROPPED")
	}
}
//----------------------------------------------------------------------------------------------
//			Changes Weapones
//----------------------------------------------------------------------------------------------
public Mac_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !HasBlade[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, ModelMAC10)
	return HAM_IGNORED; 
}
// ESto era del curweapon para controlar la cantidad de reload
	/* if (read_data(3) == 0) {
			//so if he is out of ammo just reload it
			sh_reload_ammo(id, 2)
			after the id I made a 1 number
			look at the superheromod.inc and you will see this
			0 - follow server sh_reloadmode CVAR
			1 - continuous shooting, no reload
			2 - fill the backpack (must reload)
			3 - drop the gun and get a new one with full clip
			That should explain it 
		} */

public Knife_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !HasBlade[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, gBladeKnife)
	return HAM_IGNORED;
}

switch_model(id)
{
	if ( !sh_is_active() || !is_user_alive(id) ) return

	if ( get_user_weapon(id) == CSW_MAC10 ) {
		set_pev(id, pev_viewmodel2, ModelMAC10)
	}
		
	if (get_user_weapon(id) == CSW_KNIFE) {
		set_pev(id, pev_viewmodel2, gBladeKnife)
		// set_pev(id, pev_weaponmodel2, gBladeKnife2)
	}	
}
//----------------------------------------------------------------------------------------------
//				Finish effects
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id) {
	blade_reset(id)
	if (HasBlade[id] ) blade_weapons(id)
}

blade_weapons(id)
{
	sh_give_weapon(id, CSW_DEAGLE)
	sh_give_weapon(id, CSW_MAC10)
	sh_give_item(id,"ammo_50ae")
	sh_give_item(id,"ammo_50ae")
	sh_give_item(id,"ammo_45acp")
	sh_give_item(id,"ammo_45acp")
	sh_give_item(id,"ammo_45acp")
	sh_give_item(id,"ammo_45acp")
	sh_give_item(id,"ammo_45acp")
} 

blade_reset(id) {
	remove_task(id)

	if ( InKnifeBurn[id] ) stop_knifeburn(id)

	if ( InGunBurn[id] ) stop_gunburn(id)
}

public stop_knifeburn(id) {
	// Check and seperate function prevents removing the burning sound if still in other burn type
	if ( !InGunBurn[id] && is_user_connected(id) )
		emit_sound(id, CHAN_STATIC, SoundVampBurn, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

	InKnifeBurn[id] = false
}

public stop_gunburn(id) {
	// Check and seperate function prevents removing the burning sound if still in other burn type
	if ( !InKnifeBurn[id] && is_user_connected(id) )
		emit_sound(id, CHAN_STATIC, SoundVampBurn, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

	InGunBurn[id] = false
}
//----------------------------------------------------------------------------------------------
//				Event Damage
//----------------------------------------------------------------------------------------------
public client_damage(attacker, victim, damage, wpnindex)
{
	if ( !is_user_alive(victim) || !is_user_connected(attacker) || !sh_is_active() ) return

	if ( HasBlade[attacker] && IsVampire[victim] ) {
		switch(wpnindex) {
			case CSW_KNIFE: {
				// Make sure user is not already in a knifeburn
				if ( InKnifeBurn[victim] ) return

				set_knifeburn(victim, attacker)
			}

			case CSW_MAC10, CSW_DEAGLE: {
				// Make sure user is not already in a gunburn
				if ( InGunBurn[victim] ) return

				new gunBurns = get_pcvar_num(blade_gunburns)

				if ( gunBurns <= 0 ) return

				InGunBurn[victim] = true

				new args[2]
				args[0] = victim
				args[1] = attacker

				new Float:burnStopTime = gunBurns * 0.3 + 0.6
				set_task(0.3, "gunburn", victim, args, 2, "a", gunBurns)
				set_task(burnStopTime, "stop_gunburn", victim)

				// If already burning no need to set sound again
				if ( !InKnifeBurn[victim] )
					emit_sound(victim, CHAN_STATIC, SoundVampBurn, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				vampire_scream(victim)
			}
			
			case CSW_MP5NAVY, CSW_AK47: {
				new morpheus = sh_get_hero_id(gOthers_Heros[0])
				new veronika = sh_get_hero_id(gOthers_Heros[1])
				if ( sh_user_has_hero(attacker, morpheus) || sh_user_has_hero(attacker, veronika) ) {
					// Make sure user is not already in a gunburn
					if ( InGunBurn[victim] ) return
					
					new gunBurns = get_pcvar_num(blade_gunburns)
	
					if ( gunBurns <= 0 ) return
					InGunBurn[victim] = true
	
					new args[2]
					args[0] = victim
					args[1] = attacker
	
					new Float:burnStopTime = gunBurns * 0.3 + 0.6
					set_task(0.3, "gunburn", victim, args, 2, "a", gunBurns)
					set_task(burnStopTime, "stop_gunburn", victim)
	
					// If already burning no need to set sound again
					if ( !InKnifeBurn[victim] )
						emit_sound(victim, CHAN_STATIC, SoundVampBurn, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
					vampire_scream(victim)
				}
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
//			Fire bullets effects
//----------------------------------------------------------------------------------------------
// Keep public for hero Longshot to call this
public set_knifeburn(id, attacker)
{
	if ( !sh_is_active() || !is_user_alive(id) || InKnifeBurn[id] ) return

	// Extra checks for use with hero Longshot
	if ( !HasBlade[attacker] || !IsVampire[id] ) return

	new knifeBurns = get_pcvar_num(blade_knifeburns)

	switch(knifeBurns) {
		case -1: {
			InKnifeBurn[id] = true

			new args[2]
			args[0] = id
			args[1] = attacker

			set_task(0.3, "knifeburn", id, args, 2, "b")
		}

		case 0:
			return

		default: {
			InKnifeBurn[id] = true

			new args[2]
			args[0] = id
			args[1] = attacker

			new Float:burnStopTime = knifeBurns * 0.3 + 0.6
			set_task(0.3, "knifeburn", id, args, 2, "a", knifeBurns)
			set_task(burnStopTime, "stop_knifeburn", id)	
		}
	}

	// If already burning no need to set sound again
	if ( !InGunBurn[id] )
		emit_sound(id, CHAN_STATIC, SoundVampBurn, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	vampire_scream(id)
}

public knifeburn(args[])
{
	new id = args[0]
	new attacker = args[1]

	if ( !sh_is_active() || !is_user_alive(id) ) {
		blade_reset(id)
		return
	}

	if ( InKnifeBurn[id] ) {
		burn_effect(id)

		new Float:idOrigin[3]
		pev(id, pev_origin, idOrigin)
		new level = sh_get_user_lvl(id)
		new extradamage = ( get_pcvar_num(blade_knifeburndmg) * level )
		//sh_extra_damage(id, attacker, get_pcvar_num(blade_knifeburndmg), "silver sword", _, SH_DMG_NORM, _, false, idOrigin)
		sh_extra_damage(id, attacker, extradamage, "Silver Sword", _, SH_DMG_NORM, _, false, idOrigin)
	}
}

public gunburn(args[])
{
	new id = args[0]
	new attacker = args[1]

	if ( !sh_is_active() || !is_user_alive(id) ) {
		blade_reset(id)
		return
	}

	if ( InGunBurn[id] ) {
		burn_effect(id)

		new Float:idOrigin[3]
		pev(id, pev_origin, idOrigin)
		new level = sh_get_user_lvl(id)
		new extradamage = ( get_pcvar_num(blade_gunburndmg) * level )
		//sh_extra_damage(id, attacker, get_pcvar_num(blade_gunburndmg), "silver bullet", _, SH_DMG_NORM, _, false, idOrigin)
		sh_extra_damage(id, attacker, extradamage, "Silver Bullet", _, SH_DMG_NORM, _, false, idOrigin)
	}
}

burn_effect(id)
{
	if ( !is_user_connected(id) ) return

	new rx, ry, rz, forigin[3]

	rx = random_num(-30, 30)
	ry = random_num(-30, 30)
	rz = random_num(-30, 30)

	get_user_origin(id, forigin)

	//TE_SPRITE - additive sprite, plays 1 cycle
	message_begin(MSG_PVS, SVC_TEMPENTITY, forigin)
	write_byte(17)
	write_coord(forigin[0]+rx)	// coord, coord, coord (position)
	write_coord(forigin[1]+ry)
	write_coord(forigin[2]+10+rz)
	write_short(SpriteFire)	// short (sprite index)
	write_byte(30)		// byte (scale in 0.1's)
	write_byte(200)		// byte (brightness)
	message_end()

	//Smoke
	message_begin(MSG_PVS, SVC_TEMPENTITY, forigin)
	write_byte(5)
	write_coord(forigin[0]+(rx*2))	// coord, coord, coord (position)
	write_coord(forigin[1]+(ry*2))
	write_coord(forigin[2]+100+(rz*2))
	write_short(SpriteSmoke)	// short (sprite index)
	write_byte(60)			// byte (scale in 0.1's)
	write_byte(15)			// byte (framerate)
	message_end()
}

vampire_scream(id)
{
	if ( is_user_connected(id) )
		emit_sound(id, CHAN_AUTO, SoundVampScream, VOL_NORM, ATTN_NORM, 0, PITCH_HIGH)
}
//----------------------------------------------------------------------------------------------
// 				Detect Vampires
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	// Check for Vampire heroes at this point since heroID's should all be registerd by now
	new vampid, bool:vampfound
	for ( new x = 0; x < VAMP_HEROES; x++ )
	{
		vampid = VampHeroID[x] = sh_get_hero_id(VampHeroName[x])

		if ( vampid == -1 ) {
			//Report all missing vamps
			sh_debug_message(0, 1, "(%s) No pudimos encontrar un Heroe Nocturno con ese nombre: %s", HeroName, VampHeroName[x])
		}
		else {
			vampfound = true
		}
	}

	// Hero is useless without Vampires to burn, disable hero if no matches found
	if ( !vampfound ) {
		sh_debug_message(0, 0, "Hero: ^"%s^" desactivado, No se encontro ningun Heroe Nocturno.", HeroName)
		set_fail_state("No se encontro ninguno Heroe Nocturno! Heroe fue desactivado. (plugin ^"sh_blade.amxx^")")
	}
}

//Unused but still here, I don't remeber why...
stock bool:is_user_vampire(id)
{
	if ( !sh_is_active() || !is_user_alive(id) )
		return false

	new bool:isVamp

	for ( new x = 0; x < VAMP_HEROES && !isVamp; x++ ) {
		isVamp = sh_user_has_hero(id, VampHeroID[x]) ? true : false
	}

	return isVamp
}

public client_connect(id) {
	HasBlade[id] = false

	IsVampire[id] = false
	for ( new x = 0; x < VAMP_HEROES; x++ )
		VampState[id][x] = false

	blade_reset(id)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
