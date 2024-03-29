// GAMBIT! - from the X-men. Can convert any inorganic object's potential energy into kinetic energy on contact.

/* CVARS - copy and paste to shconfig.cfg

//Gambit
gambit_level 0
gambit_grenademult 60.9		//Damage multiplyer from orginal damage amount (def 60.9)
gambit_grenadetimer 30.0		//How many seconds delay for new grenade after nade is thrown (def 30.0)
gambit_cooldown 120.0		//How many seconds until extra grenade damage can be used again (def 120.0)

*/

/*
* v1.3 - vittu - 9/27/05
*      - Fixed up cooldown to only be set once.
*      - Removed some useless checks.
*
* v1.2 - vittu - 6/19/05
*      - Minor code clean up.
*
* v1.1 - vittu - 5/10/05
*      - Fixed giving new grenades using a more reliable event.
*      - Fixed grenade timer to only be set if you have no nades,
*          avoids timer exploiting.
*      - Added cooldown cvar, sets only if someone is hurt by gambit.
*      - Added grenade glow and trail only for gambit nades.
*
*   Hero Created by Vectren
*/

#include <superheromod>

#define AMMOX_HEGRENADE 12

// GLOBAL VARIABLES
new gHeroID
new gHeroName[] = "Gambit"
new bool:gHasGambitPower[SH_MAXSLOTS+1]
new gGrenTrail
new const HEGRENADE_MODEL[] = "models/w_hegrenade.mdl"

new gPcvarMult, gPcvarCooldown

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Gambit", "1.3", "Vectren / vittu")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("gambit_level", "6")
	gPcvarMult	= register_cvar("gambit_grenademult", "70.0")
	gPcvarCooldown	= register_cvar("gambit_cooldown", "25.0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Granadas con Carga Cinética.", "Cambia tus granadas comunes, por unas recargadas con mucho más daño.")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// EXTRA NADE DAMAGE
	register_event("Damage", "gambit_damage", "b", "2!0")

	// FIND THROWN GRENADES
	register_event("AmmoX", "on_AmmoX", "b")
}

public plugin_precache() 
	gGrenTrail = precache_model("sprites/zbeam5.spr")
//------------------------------------------------------------------------------------------------
//				Hero INIT 							//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			gHasGambitPower[id] = true
			gPlayerInCooldown[id] = false
			gambit_weapons(id)
		}
		case SH_HERO_DROP: {
			gHasGambitPower[id] = false
		}
	}
}
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasGambitPower[id] ) {
		gPlayerUltimateUsed[id] = false
		set_task(0.1, "gambit_weapons", id)
	}
}

public gambit_weapons(id)
	sh_give_weapon(id, CSW_HEGRENADE)
//----------------------------------------------------------------------------------------------
public gambit_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasGambitPower[attacker] && weapon == CSW_HEGRENADE && is_user_alive(id) && !gPlayerUltimateUsed[attacker] ) {
		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(gPcvarMult) - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "grenade", headshot)

		if ( attacker != id ) {
			// Set the cooldown in x seconds because nades can hurt more then one person
			// only when damaging others
			new parm[1]
			parm[0] = attacker
			set_task(0.2, "gambit_setcooldown", 0, parm,1)
		}
	}
}
//----------------------------------------------------------------------------------------------
public on_AmmoX(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new iAmmoType = read_data(1)
	new iAmmoCount = read_data(2)

	if ( iAmmoType == AMMOX_HEGRENADE && gHasGambitPower[id] ) {

		if (iAmmoCount == 0) {
			set_task(get_pcvar_float(gPcvarCooldown), "gambit_weapons", id)

			if ( !gPlayerUltimateUsed[id] ) {
				// Have to Find the current HE grenade
				new iCurrent = -1
				while ( ( iCurrent = find_ent_by_class(iCurrent, "grenade") ) > 0 ) {
					new string[32]
					entity_get_string(iCurrent, EV_SZ_model, string, 31);

					if ( id == entity_get_edict(iCurrent, EV_ENT_owner) && equali(HEGRENADE_MODEL, string) ) {

						new Float:glowColor[3] = {225.0, 0.0, 20.0}

						// Make the nade glow
						entity_set_int(iCurrent, EV_INT_renderfx, kRenderFxGlowShell)
						entity_set_vector(iCurrent, EV_VEC_rendercolor, glowColor)

						// Make the nade a bit invisible to make glow look better
						entity_set_int(iCurrent, EV_INT_rendermode, kRenderTransAlpha)
						entity_set_float(iCurrent, EV_FL_renderamt, 100.0 )

						// Make a trail
						message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
						write_byte(22)			//TE_BEAMFOLLOW
						write_short(iCurrent)	// entity:attachment to follow
						write_short(gGrenTrail)	// sprite index
						write_byte(10)		// life in 0.1's
						write_byte(10)		// line width in 0.1's
						write_byte(225)	// colour
						write_byte(90)
						write_byte(102)
						write_byte(255)	// brightness
						message_end()
					}
				}
			}
		}
		else if (iAmmoCount > 0) {
			// Got a new nade remove the timer
			remove_task(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public gambit_setcooldown(parm[])
{
	new id = parm[0]

	if ( !is_user_alive(id) || gPlayerUltimateUsed[id] ) return

	// Cooldown will only be set if user hurts someone with a gambit nade
	new Float:seconds = get_pcvar_float(gPcvarCooldown)
	if (seconds > 0.0) ultimateTimer(id, seconds) 
}
//----------------------------------------------------------------------------------------------
//			Checks necesarys
//----------------------------------------------------------------------------------------------
public client_connect(id)
	gHasGambitPower[id] = false
	
public client_disconnected(id)
{
	// stupid check but lets see
	if ( id <=0 || id > SH_MAXSLOTS ) return

	// Yeah don't want any left over residuals
	remove_task(id)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
