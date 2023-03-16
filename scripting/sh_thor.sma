// THOR! from Marvel Comics. Asgardian god, son of Odin, wielder of the enchanted uru hammer Mjolnir.

/* CVARS - copy and paste to shconfig.cfg

//Thor
thor_level 8
thor_pctofdmg 75		//Percent of Damage Taken that is dealt back at your attacker (def 75%)
thor_cooldown 45		//Amount of time before next available use (def 45)

*/

/*
* v1.2 - vittu - 12/31/05
*      - Cleaned up code.
*      - Changed damage cvar to a percent of damage taken.
*      - Changed sounds.
*      - Changed look of effects.
*
*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new g_heroName[]="Thor"
new bool:g_hasThor[SH_MAXSLOTS+1]
new g_spriteLightning

new noobID
new bool:gHasNoob[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Thor", "1.1", "TreDizzle")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("thor_level", "12")
	register_cvar("thor_pctofdmg", "90")
	register_cvar("thor_cooldown", "25")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(g_heroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Descargas Eléctricas", "Descarga a quién te ataque con un Mighty Lightning Bolt directo del martillo de Thor's uru Mjolnir.")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// EVENTS
	register_event("Damage", "thor_damage", "b", "2!0")
	
	set_task(0.3, "cache_idThor");   		// we need to let superhero cache all the heros to avoid issues
}

public cache_idThor() 
	noobID		= sh_get_hero_id("Noob");

public plugin_precache()
{
	precache_sound("ambience/thunder_clap.wav")
	precache_sound("buttons/spark5.wav")
	g_spriteLightning = precache_model("sprites/lgtning.spr")
}
//------------------------------------------------------------------------------------------------
//					INIT y SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	// if ( gHeroID != heroID ) return
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				g_hasThor[id] = true
				gPlayerInCooldown[id] = false
			}
			case SH_HERO_DROP: {
				g_hasThor[id] = false
			}
		}
		
		sh_debug_message(id, 1, "%s %s", g_heroName, mode ? "ADDED" : "DROPPED")
	}
	// Noob
	else if ( heroID == noobID ) {
		gHasNoob[id] = mode ? true : false
	}
}

public sh_client_spawn(id)
	gPlayerUltimateUsed[id] = false

public thor_damage(id)
{
	if ( !shModActive() || !is_user_connected(id) ) return
	if ( !g_hasThor[id] || gPlayerUltimateUsed[id] ) return

	new damage = read_data(2)
	new attacker = get_user_attacker(id)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return
	if ( gHasNoob[attacker] ) return

	// Thor still attacks if Thor user dies from attackers damage
	if ( is_user_alive(attacker) && !get_user_godmode(attacker) && id != attacker ) {
		emit_sound(id, CHAN_STATIC, "ambience/thunder_clap.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(attacker, CHAN_STATIC, "buttons/spark5.wav", 0.4, ATTN_NORM, 0, PITCH_NORM)

		// Deal a % of the damage back at them
		new extraDamage = floatround(damage * get_cvar_num("thor_pctofdmg") * 0.01 )
		if (extraDamage == 0) extraDamage = 1
		shExtraDamage(attacker, id, extraDamage, "thunder bolt")

		// create some effects
		if ( extraDamage > 70 ) extraDamage = 70
		else if ( extraDamage < 20 ) extraDamage = 20
		lightning_effect(id, attacker, extraDamage)

		// make attacker feel it
		new alphanum = damage * 2
		if ( alphanum > 200 ) alphanum = 200
		else if ( alphanum < 40 ) alphanum = 40
		setScreenFlash(attacker, 255, 255, 224, 10, alphanum)
		sh_screenShake(attacker, 12, 10, 14)

		if ( is_user_alive(id) ) {
			// Set cooldown if Thor is still alive
			new thorCooldown = get_cvar_num("thor_cooldown")
			if (thorCooldown > 0) ultimateTimer(id, thorCooldown * 1.0)
		}
	}
}
//----------------------------------------------------------------------------------------------
public lightning_effect(id, targetid, lineWidth)
{
	// Main Lightning
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(8)				//TE_BEAMENTS
	write_short(id)			// start entity
	write_short(targetid)		// entity
	write_short(g_spriteLightning)	// model
	write_byte(0)			// starting frame
	write_byte(200)		// frame rate
	write_byte(15)			// life
	write_byte(lineWidth)	// line width
	write_byte(6)			// noise amplitude
	write_byte(255)		// r, g, b
	write_byte(255)		// r, g, b
	write_byte(224)		// r, g, b
	write_byte(125)		// brightness
	write_byte(0)			// scroll speed
	message_end()

	// Extra Lightning
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(8)				//TE_BEAMENTS
	write_short(id)			// start entity
	write_short(targetid)		// entity
	write_short(g_spriteLightning)	// model
	write_byte(10)			// starting frame
	write_byte(200)		// frame rate
	write_byte(15)			// life
	write_byte(floatround(lineWidth/2.5))	// line width
	write_byte(18)			// noise amplitude
	write_byte(255)		// r, g, b
	write_byte(255)		// r, g, b
	write_byte(224)		// r, g, b
	write_byte(125)		// brightness
	write_byte(0)			// scroll speed
	message_end()
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
