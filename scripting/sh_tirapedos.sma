// FARTMAN! - superhero from The Howard Stern show.

/* CVARS - copy and paste to shconfig.cfg

//Fartman
fartman_level 7
fartman_gasdmg 10		//Amount of damage caused (Default 10)
fartman_gasradius 200		//Damage radius from smoke grenade to player, 200-250 is the normal smoke radius (Default 200)
fartman_gasfreq 2.0		//Every # of seconds gas damage is caused again (Default 2.0)
fartman_grenadetimer 10.0	//# of seconds until new smoke grenade is given (Default 10.0)

*/

/*
* v1.5 - vittu - 9/26/06
*      - Updated to amxmodx only, requires fakemeta and amxx 1.70 or higher.
*      - Changed sound of smoke nade going off.
*      - Seperated out gasing by nade starting from smoke release.
*      - Changed timer cvar name to represent frequencey and default lowered.
*      - Improved fart sound a little.
*
* v1.4 - vittu - 7/3/05
*      - Fixed crash to AMX caused by the previous update, since
*          AMX can't register a MSG_ONE_UNRELIABLE message.
*
* v1.3 - vittu - 6/27/05
*      - Minor update for FF servers, prevents the shExtraDamage
*          from saying you attacked a teammate for every cycle.
*
* v1.2 - vittu - 6/19/05
*      - Minor code clean up.
*      - Stopped sound from playing on a ResetHud event.
*      - Fixed give grenade timer to only set when nade is thrown.
*
* v1.1 - vittu - 3/28/05
*      - Fixed giving new genades using more reliable event.
*      - Changed how smoke grenade ids are found, actually finds all gas nades now.
*      - Added radius cvar for gas.
*      - Added fart sound to gas grenade throw.
*      - Added gas mask hud icon when damaged by a gas grenade.
*
*   Hero Created by RichoDemus & AssKicR
*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

#define AMMOX_SMOKEGRENADE 13

// GLOBAL VARIABLES
new gHeroID
new HeroName[]="TiraPedos"
new bool:HasFartman[SH_MAXSLOTS+1]
new bool:gBlockGiveTask[SH_MAXSLOTS+1]

new MsgIcon, MsgDamage
new CvarGasDmg, CvarGasRadius, CvarGasFreq, CvarGrenadeReset

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1] 

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Batman"
}

new const gTiraGranade[] = "models/shmod/axesg_v.mdl"
new const gTiraGranade_w[] = "models/shmod/w_axesg.mdl"
new const gSoundFart[] = "shmod/fartman_smokegrenade.wav"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Tira Pedos", "1.5", "RichoDemus / AssKicR / vittu")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("fartman_level", "0")
	CvarGasDmg 	= register_cvar("fartman_gasdmg", "180")
	CvarGasRadius 	= register_cvar("fartman_gasradius", "200")
	CvarGasFreq 	= register_cvar("fartman_gasfreq", "2.0")
	CvarGrenadeReset= register_cvar("fartman_grenadetimer", "8.0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(HeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Tiras pedos de gordo.", "Tus pedos son tóxicos como lo de los gordos.")

	// EVENTS
	register_event("AmmoX", "on_ammox", "b")
	//models
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "Smoke_Deploy", 1)

	// FORWARD
	register_forward(FM_EmitSound, "sound_emitted")

	MsgIcon = get_user_msgid("StatusIcon")
	MsgDamage = get_user_msgid("Damage")
}

public plugin_precache()
{
	precache_sound("player/gasp1.wav")
	precache_sound("player/gasp2.wav")
	precache_sound(gSoundFart)
	precache_model(gTiraGranade_w)
	precache_model(gTiraGranade)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				// For check if has the other power
				if ( !sh_user_has_hero(id, sh_get_hero_id(gOthers_Heros[0])) ) {
					HasFartman[id] = true
					gPlayerInCooldown[id] = false
					fartman_weapon(id)
					switch_model(id)
				}
				
				TiraPedos_heroscheck(id)
			}
			case SH_HERO_DROP: {
				HasFartman[id] = false
			}
		}
		
		sh_debug_message(id, 1, "%s %s", HeroName, mode ? "ADDED" : "DROPPED")
	}
}
#if SEND_COOLDOWN
public sendFartmanCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id]) 
}
#endif
//----------------------------------------------------------------------------------------------
//				SPAWN n DEATH for COOLDOWNS
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	// Para controlar si tiene el poder
	if ( HasFartman[id] ) {
		// Block Ammox nade give task on spawn, if respawned without smoke nade,
		// since you are given one on spawn.
		gBlockGiveTask[id] = true
		fartman_weapon(id)
		TiraPedos_heroscheck(id)
		
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
	if ( HasFartman[id] ) gPcvarRealCD[id] = sh_get_cooldown(id)
}

public fartman_weapon(id)
	if ( HasFartman[id] ) sh_give_weapon(id, CSW_SMOKEGRENADE)
//----------------------------------------------------------------------------------------------
//		WEAPON MODELS SMOKE
//----------------------------------------------------------------------------------------------
public Smoke_Deploy(iEnt) 
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !HasFartman[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, gTiraGranade)	
	return HAM_IGNORED; 
}

switch_model(id)
{
	if ( !is_user_alive(id) || !HasFartman[id] ) return
    
	if (get_user_weapon(id) == CSW_SMOKEGRENADE) {
		//now he has all the requirements to have the weapon model so we also need to give it to him
		set_pev(id, pev_viewmodel2, gTiraGranade)
	}
}
//----------------------------------------------------------------------------------------------
public on_ammox(id)
{
	if ( !is_user_alive(id) || !HasFartman[id] ) return

	new iAmmoType = read_data(1)
	new iAmmoCount = read_data(2)
	
	if ( iAmmoType == AMMOX_SMOKEGRENADE ) {
		
		if ( iAmmoCount == 0 && !gBlockGiveTask[id] ) {
			
			if ( !gPlayerInCooldown[id] ) {
				new iGrenade = -1
				while ( (iGrenade = find_ent_by_class(iGrenade, "grenade")) > 0 ) {
					static model[32]
					entity_get_string(iGrenade, EV_SZ_model, model, 31)
					if ( id == entity_get_edict(iGrenade, EV_ENT_owner) && equal(model, "models/w_smokegrenade.mdl") ) {
						entity_set_model(iGrenade, gTiraGranade_w)
					}
				}
			}
				
			new Float:seconds = get_pcvar_float(CvarGrenadeReset)
			if ( seconds > 0.0 ) {
				//This will be called on spawn as well as when nade is thrown, block this on spawn.
				//Nade was thrown set task to give another.
				// set_task(get_pcvar_float(CvarGrenadeReset), "fartman_weapon", id)
				set_task(seconds, "fartman_weapon", id)
				
				sh_set_cooldown(id, seconds)
				gPcvarRealCD[id] = seconds
			}
		}
		
		else if ( iAmmoCount > 0 ) {
			// Either has a smoke nade or was given one on spawn, ok to allow sound and task now
			gBlockGiveTask[id] = false
			// Got a new smoke nade remove the timer
			remove_task(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public sound_emitted(entity, channel, const sample[])
{
	// For debugging purposes
	//client_print(0, print_chat, "entity: %d, channel: %d, sample: %s", entity, channel, sample)
	if(!pev_valid(entity)) 
		return FMRES_IGNORED;
	
	if ( equal(sample, "weapons/sg_explode.wav") ) {
		new id = pev(entity, pev_owner)
		if ( is_user_connected(id) && HasFartman[id] ) {
			// Smoke nade went off, change to fart gas
			emit_sound(entity, CHAN_WEAPON, gSoundFart, 1.0, ATTN_NORM, 0, PITCH_NORM)

			new parm[2]
			parm[0] = id
			parm[1] = entity
			fartman_gas(parm)
	
			return FMRES_SUPERCEDE
		}
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public fartman_gas(parm[])
{
	new id = parm[0]
	new grenadeid = parm[1]

	if ( !pev_valid(grenadeid) || !is_user_connected(id) || !HasFartman[id] ) {
		remove_task(grenadeid+923)
		return
	}

	new Float:grOrigin[3], Float:vicOrigin[3]
	new FFOn = get_cvar_num("mp_friendlyfire")
	new Float:gasRadius = get_pcvar_float(CvarGasRadius)
	new Float:gasTimer = get_pcvar_float(CvarGasFreq)
	new gasDamage = get_pcvar_num(CvarGasDmg)
	new CsTeams:idTeam = cs_get_user_team(id)

	// Find origin of smoke grenade
	pev(grenadeid, pev_origin, grOrigin)

	new players[SH_MAXSLOTS], pnum, vic
	get_players(players, pnum, "a")

	for ( new i = 0; i < pnum; i++ )
	{
		vic = players[i]

		if ( is_user_alive(vic) && !get_user_godmode(vic) && vic != id && (idTeam != cs_get_user_team(vic) || FFOn) )
		{
			pev(vic, pev_origin, vicOrigin)

			if ( vector_distance(grOrigin, vicOrigin) < gasRadius )
			{
				new bool:playSound = true

				// If gas check is less then 1.0 sec, don't flood the server with gasp sounds
				if ( gasTimer < 1.0 )
				{
					if ( random_num(1, 5) > 3 )
						playSound = false
				}

				if ( playSound )
				{
					new number = random_num(1, 2)
					switch(number)
					{
						case 1: emit_sound(vic, CHAN_VOICE, "player/gasp1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
						case 2: emit_sound(vic, CHAN_VOICE, "player/gasp2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
				}

				new lessHealth = get_user_health(vic) - gasDamage

				// Prevents the shExtraDamage from saying you attacked a teammate for every cycle of the loop
				if ( lessHealth  <= 0 )
					shExtraDamage(vic, id, gasDamage, "fart gas grenade")
				else
					set_user_health(vic, lessHealth)

				// Gas Mask HUD Icon, Flash to show being gased
				message_begin(MSG_ONE_UNRELIABLE, MsgIcon, {0,0,0}, vic)
				write_byte(1)			// status (0=hide, 1=show, 2=flash)
				write_string("dmg_gas")		// sprite name
				write_byte(0)			// red
				write_byte(125)			// green
				write_byte(0)			// blue
				message_end()

				// Remove gasmask icon
				new parm2[1]
				parm2[0] = vic
				set_task(0.3, "remove_gasicon", 0, parm2, 1)

				// Show damage origin as self, so extradamage doesn't show it from attacker origin
				message_begin(MSG_ONE_UNRELIABLE, MsgDamage, {0,0,0}, vic)
				write_byte(100)			// dmg_save
				write_byte(100)			// dmg_take
				write_long(1<<16)		// visibleDamageBits
				write_coord(floatround(vicOrigin[0]))	// damageOrigin.x
				write_coord(floatround(vicOrigin[1]))	// damageOrigin.y
				write_coord(floatround(vicOrigin[2]))	// damageOrigin.z
				message_end()
			}
		}
	}

	// If the smoke grenade still exists gas them again.
	if ( pev_valid(grenadeid) && gasTimer > 0.0 )
		set_task(gasTimer, "fartman_gas", grenadeid+923, parm, 2)
}
//----------------------------------------------------------------------------------------------
public remove_gasicon(parm2[])
{
	new vic = parm2[0]

	if ( !is_user_connected(vic) )
		return

	// Gas Mask HUD Icon, reset to none
	message_begin(MSG_ONE, MsgIcon, {0,0,0}, vic)
	write_byte(0)			// status (0=hide, 1=show, 2=flash)
	write_string("dmg_gas")		// sprite name
	write_byte(0)			// red
	write_byte(125)			// green
	write_byte(0)			// blue
	message_end()
}
//------------------------------------------------------------------------------------------------
//				Batman Checks							//
//------------------------------------------------------------------------------------------------
public TiraPedos_heroscheck(id) 
{
	if ( sh_user_has_hero(id, sh_get_hero_id(gOthers_Heros[0])) ) {
		
		sh_chat_message(id, gHeroID, "Para usar este Héroe tenes que quitarte el %s primero.", gOthers_Heros[0])
      		client_cmd(id, "say drop %s", HeroName)
		HasFartman[id] = false
   	}
}

public client_connect(id)
	HasFartman[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
