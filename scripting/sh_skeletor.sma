// SKELETOR! from HE-MAN, The evil sorcerer.
// REQUIRES Monster Mod (Botman version 3.00.00 or above)
// Created 5/17/2003

/* CVARS - copy and paste to shconfig.cfg

//Skeletor
skeletor_level 0
skeletor_cooldown 30			// # of seconds for skeletor cooldown
skeletor_camptime 10			// # of seconds player considered camping w/o x/y movement
skeletor_movedist 10			// minimum amount of dist player has to move b4 considered not camping
skeletor_maxsnarks 10			// maximum amount of snarks to spawn on a player

*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Skeletor"
new bool:gHasSkeletor[SH_MAXSLOTS+1]
new gPlayerPosition[SH_MAXSLOTS+1][3]  // keeps track of last known origin
new gMoveTimer[SH_MAXSLOTS+1]          // incremented if player didn't move far enough
new const gSoundSummon[] = "ambience/port_suckin1.wav"
new pCvarCooldown, pCvarCampTime, pCvarMoveDist, pCvarMaxSnarks
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Skeletor", SH_VERSION_STR, "{HOJ} Batman")

	// Make sure monster mod is loaded, otherwise this hero is useless
	if ( !cvar_exists("monster_spawn") ) {
		set_fail_state("Monster Mod not loaded, Skeletor requires the monster ^"snark^"")
	}

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("skeletor_level", "0")
	pCvarCooldown = register_cvar("skeletor_cooldown", "30")
	pCvarCampTime = register_cvar("skeletor_camptime", "10")
	pCvarMoveDist = register_cvar("skeletor_movedist", "10")
	pCvarMaxSnarks = register_cvar("skeletor_maxsnarks", "10")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Invoca Mounstros a los Campers.", "Invoca Mounstros en la ubicación de los campers.")

	set_task(1.0, "skeletor_campcheck", _, _, _, "b")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound(gSoundSummon)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	gHasSkeletor[id] = mode ? true : false

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	remove_task(id)
	gMoveTimer[id] = 0
	gPlayerInCooldown[id] = false

	get_user_origin(id, gPlayerPosition[id])
}
//----------------------------------------------------------------------------------------------
public skeletor_campcheck()
{
	if ( !sh_is_active() || sh_is_freezetime() ) return

	// Check all players to see if they've moved...
	static origin[3]
	static dx, dy, dz, distance

	static players[SH_MAXSLOTS], playerCount, player, i
	get_players(players, playerCount, "a")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]

		if ( pev(player, pev_flags) & FL_NOTARGET ) continue

		get_user_origin(player, origin)

		dx = gPlayerPosition[player][0] - origin[0]
		dy = gPlayerPosition[player][1] - origin[1]
		dz = gPlayerPosition[player][2] - origin[2]

		distance = sqroot(dx*dx + dy*dy + dz*dz)

		if ( distance <= get_pcvar_num(pCvarMoveDist) ) {
			gMoveTimer[player]++

			if ( gMoveTimer[player] > get_pcvar_num(pCvarCampTime) ) {
				gMoveTimer[player] = 0

				skeletor_summon(player)
			}
		}
		else {
			gMoveTimer[player] = 0
		}

		gPlayerPosition[player][0] = origin[0]
		gPlayerPosition[player][1] = origin[1]
		gPlayerPosition[player][2] = origin[2]
	}
}
//----------------------------------------------------------------------------------------------
skeletor_summon(victim)
{
	// Go through a list of skeletor looking for
	// 1) ultimate available
	// 2) opposite team than (id)
	// 3) skeletor powers...

	if ( !is_user_connected(victim) ) return

	new CsTeams:victimTeam = cs_get_user_team(victim)

	new players[SH_MAXSLOTS], playerCount, player
	get_players(players, playerCount, "a")

	for ( new i = 0; i < playerCount; i++ ) {
		player = players[i]
		if ( gHasSkeletor[player] && victimTeam != cs_get_user_team(player) && !gPlayerInCooldown[player] ) {
			// COOL WE HAVE A SKELETOR TO STICK SNARKS ON Player id!
			new Float:cooldown = get_pcvar_float(pCvarCooldown)
			if ( cooldown > 0.0 ) sh_set_cooldown(player, cooldown)

			// SUMMON THE MONSTERS USING MONSTOR MOD
			new name[32]
			new victimName[32]
			get_user_name(victim, victimName, charsmax(victimName))
			get_user_name(player, name, charsmax(name))
			sh_chat_message(0, gHeroID, "%s Ha invocado Mounstros al campers puto de: %s", name, victimName)
			emit_sound(victim, CHAN_STATIC, gSoundSummon, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(player, CHAN_STATIC, gSoundSummon, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			// The Higher the Level - The more Snarks!
			new numSnarks = min(get_pcvar_num(pCvarMaxSnarks), sh_get_user_lvl(player)/2 + 1)
			for ( new m = 1; m <= numSnarks ; m++ ) {
				set_task(m * 0.2, "summon_monster", victim)
			}

			break // ok no more poeple need to syc this guy
		}
	}
}
//----------------------------------------------------------------------------------------------
public summon_monster(victim)
{
	if ( is_user_alive(victim) && sh_is_inround() ) {
		server_cmd("monster snark #%d", victim)
	}
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
