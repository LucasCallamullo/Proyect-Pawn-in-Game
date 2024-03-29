//UNCLE SAM! a character that is the personification of the United States.
/************************************************************************
* 	ADMIN ONLY							*
* 	Uncle Sam has a BIG NUKE that he can blow everyone away with	*
* 	Do Not Use If You Are Not Admin!!!!!!!				*
*************************************************************************/

/* CVARS - copy and paste to shconfig.cfg

//Uncle Sam
unclesam_level 10
unclesam_adminflag a		// Admin flag required to use this hero (Default a = ADMIN_IMMUNITY)
unclesam_timer 15			// Number of seconds before the nuke goes off (Default 15)
unclesam_admins_immune 0		// Admins with immuinity are immune to Nukes: 0=no 1=yes (Default 0)
unclesam_loguse 0			// Log use of Nuke, both fake and real are logged: 0=no 1=yes (Default 0)

*/

/*
* v1.2 - vittu - 12/8/08
*      - Temp fix for sh 1.20, inserted logKill stock into hero.
*          (A full update will be done some other time.)
* v1.1 - vittu - 7/12/05
*      - Cleaned up code, made timer more efficient, and used
*          more reliable messages for round events.
*      - Changed how Admin was checked, now made into a cvar.
*      - Created menu and made Fake Nuke available for use.
*      - Added options for Admin immunity from Nukes and able to
*          log use of Nukes.
*      - Added and changed sounds.
*
*   Hero originally created by AssKicR.
*   Based on Nukem 0.9 (amx_ejl_nukem.sma) by Eric Lidman (aka Ludwig van)
*/

#include <superheromod>
#include <Vexd_Utilities>

new gHeroName[]="Uncle Sam"
new bool:gHasUncleSamPower[SH_MAXSLOTS+1]
new bool:gUncleSamSelected[SH_MAXSLOTS+1]
new bool:gBetweenRounds
new bool:gCountStarted
new bool:gInNuke
new bool:gIsLethal
new gNuker, gNukeTimer, gConstTimer
new gmsgShake, gmsgFade, gmsgDeathMsg, gmsgScoreInfo
new white, Explode, mushroom_exp, fire
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Uncle Sam", "1.2", "AssKicR / vittu")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("unclesam_level", "10")
	register_cvar("unclesam_adminflag", "p")
	register_cvar("unclesam_timer", "15")
	register_cvar("unclesam_admins_immune", "0")
	register_cvar("unclesam_loguse", "0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Bombas Nucleares. (Only Admin).", "Lanza un Ataque Nuclear y Mata a Todos. (No Ganas/Perdes XP al asesinarlos a todos)", true, "unclesam_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("unclesam_init", "unclesam_init")
	shRegHeroInit(gHeroName, "unclesam_init")

	// KEYDOWN
	register_srvcmd("unclesam_kd", "unclesam_kd")
	shRegKeyDown(gHeroName, "unclesam_kd")

	// MENU
	register_menucmd(register_menuid("Nuke Launch Menu"), 1023, "main_menu_action")

	// NEW SPAWN
	register_event("ResetHUD", "newSpawn", "b")

	// DEATH
	register_event("DeathMsg", "unclesam_death", "a")

	// ROUND EVENTS
	register_logevent("round_start", 2, "1=Round_Start")
	register_logevent("round_end", 2, "1=Round_End")
	register_logevent("round_end", 2, "1&Restart_Round_")

	// Loop for timer
	set_task(1.0, "nuke_timer", 0, "", 0, "b")

	// Set some variables
	gmsgShake = get_user_msgid("ScreenShake")
	gmsgFade = get_user_msgid("ScreenFade")
	gmsgScoreInfo = get_user_msgid("ScoreInfo")
	gmsgDeathMsg = get_user_msgid("DeathMsg")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	white = precache_model("sprites/white.spr")
	Explode = precache_model("sprites/explode1.spr")
	mushroom_exp = precache_model("sprites/hexplo.spr")
	fire = precache_model("sprites/fire.spr")
}
//----------------------------------------------------------------------------------------------
public unclesam_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	gHasUncleSamPower[id] = (hasPowers != 0)
	gUncleSamSelected[id] = gHasUncleSamPower[id]

	if ( gHasUncleSamPower[id] && is_user_connected(id) ) {
		unclesam_admincheck(id)
	}
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if ( gUncleSamSelected[id] && is_user_alive(id) && shModActive() ) {
		set_task(0.1, "unclesam_admincheck", id)
	}
}
//----------------------------------------------------------------------------------------------
public unclesam_kd()
{
	if ( !shModActive() || gBetweenRounds ) return

	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	if ( !gHasUncleSamPower[id] || !is_user_alive(id) ) return

	if ( gInNuke ) {
		sh_chat_message(id, -1, "[%s] Ya hay una Bomba Nuclear en progreso." , gHeroName)
		playSoundDenySelect(id)
		return
	}

	show_main_menu(id)
}
//----------------------------------------------------------------------------------------------
show_main_menu(id)
{
	new menu_body[320]
	new n = 0
	new len = 319

	if ( !gHasUncleSamPower[id] || !is_user_alive(id) ) return

	n += format(menu_body[n], len-n, "\yNuke Launch Menu%-3s\r(No XP Gain/Loss)^n", " ")
	n += format(menu_body[n], len-n, "^n\w1. Real Nuke - in %d seconds", get_cvar_num("unclesam_timer"))
	if (get_cvar_num("unclesam_admins_immune")) n += format(menu_body[n], len-n, "%-2s\r[Admins are Immune]\w", " ")
	n += format(menu_body[n], len-n, "^n2. Fake Nuke - in %d seconds^n^n", get_cvar_num("unclesam_timer"))
	n += format(menu_body[n], len-n, "0. Exit")

	new keys = (1<<0)|(1<<1)|(1<<9)

	show_menu(id, keys, menu_body)
}
//----------------------------------------------------------------------------------------------
public main_menu_action(id, key)
{
	key++

	if ( !shModActive() || !gHasUncleSamPower[id] || !is_user_alive(id) ) return

	// Blocks from using nuke on round end with menu open
	if ( gBetweenRounds && key != 10 ) {
		show_main_menu(id)
		return
	}

	switch(key){
		case 1: {
			gIsLethal = true
			unclesam_nuke(id)
		}
		case 2: {
			gIsLethal = false
			unclesam_nuke(id)
		}
		case 10: return
		default: show_main_menu(id)
	}
}
//----------------------------------------------------------------------------------------------
unclesam_nuke(id)
{
	if ( gInNuke ) {
		sh_chat_message(id, -1, "[%s] Ya hay una bomba ahora mismo en progreso." , gHeroName)
		return
	}

	new name[32]
	get_user_name(id, name, 31)
	//client_cmd(0, "spk ^"ambience/siren^"") // Add this in later, loops so if used need a stopsound after real nuke
	client_cmd(0, "spk ^"vox/danger _comma atomic weapon activated^"")
	
	sh_chat_message(id, -1, "[%s] %s ha lanzado la Bomba Nuclear, Todos Moriremos!!!" , gHeroName, name)
	gNuker = id

	if ( get_cvar_num("unclesam_loguse") ) {
		new authid[35], message[256]
		get_user_authid(id, authid, 34)
		if( gIsLethal ) {
			format(message,255,"[SH](Uncle Sam) ^"%s<%d><%s><>^" lanzo una Bomba Nuclear.", name, get_user_userid(id), authid)
		}
		else {
			format(message,255,"[SH](Uncle Sam) ^"%s<%d><%s><>^" lanzo una Bomba Nuclear Fake.", name, get_user_userid(id), authid)
		}

		#if defined AMXX_VERSION
			log_amx(message)
		#else
			new g_logFile[16]
			get_logfile(g_logFile, 15)
			log_to_file(g_logFile, message)
		#endif
	}

	// Increase timer for Nuke
	gNukeTimer = get_cvar_num("unclesam_timer") + 6

	// Allow time for announcement, before counting down
	gConstTimer = gNukeTimer - 3

	gInNuke = true
}
//----------------------------------------------------------------------------------------------
public nuke_timer()
{
	if ( !gInNuke || !shModActive() ) return

	if ( !is_user_connected(gNuker) ) {
		new name[32]
		get_user_name(gNuker, name, 31)
		sh_chat_message(0, -1, "[%s] %s se fue, la Bomba Nuclear se cancelo." , gHeroName, name)
		client_cmd(0, "stopsound")
		gInNuke = false
		gCountStarted = false
		gNukeTimer = 0
		return
	}

	if ( !gHasUncleSamPower[gNuker] ) return

	new players[32], inum
	gNukeTimer--

	if ( gNukeTimer > 0 ) {

		/* Add this in later for if nuke timer gets set really high
		// NOTE: Not completed
		if ( gNukeTimer >= 30 ) {
			set_hudmessage(255, 0, 0, -1.0, 0.20, 0, 0.02, 1.0, 0.01, 0.1, 2)
			show_hudmessage(0, "Uncle Sam NUKE^n%d seconds", gNukeTimer-5)
		}*/

		if ( (gNukeTimer > 5) && (gNukeTimer <= 16) && (gNukeTimer < gConstTimer) ) {
			if ( gNukeTimer == 12 ) {
				client_cmd(0, "spk ^"ambience/jetflyby1^"")
			}

			if ( gNukeTimer == 7 ) {
				client_cmd(0, "spk ^"weapons/mortar^"")
			}

			if ( (gNukeTimer > 10) && !gCountStarted ) {
				client_cmd(0,"spk ^"fvox/remaining^"")
				gCountStarted = true
				return
			}

			new temp[48]
			num_to_word(gNukeTimer-5, temp, 48)
			client_cmd(0,"spk ^"fvox/%s^"",temp)
			client_print(0, print_center, "%d", gNukeTimer-5)
		}
		else if ( gNukeTimer == 5 ) {

			client_cmd(0, "spk ^"ambience/the_horror1^"")

			// Alive Non-Bots
			get_players(players, inum, "ac")

			for ( new i = 0 ; i < inum; i++ ) {
				// Screen Fade, white like a nuke just hit
				message_begin(MSG_ONE, gmsgFade, {0,0,0}, players[i])
				write_short(1<<11)	// fade lasts this long furation
				write_short(1<<11)	// fade lasts this long hold time
				write_short(1<<12)	// fade type (in / out)
				write_byte(250)	// fade red
				write_byte(250)	// fade green
				write_byte(250)	// fade blue
				write_byte(225)	// fade alpha
				message_end()
			}

			// Explodes at {0,0,0}
			new origin[3]
			explode_all(origin)
		}
		else if ( gNukeTimer < 5 ) {

			client_cmd(0, "spk ^"ambience/the_horror%d^"", gNukeTimer)

			// Alive Non-Bots
			get_players(players, inum, "ac")

			if ( inum < 1 ) {
				// If no alive players, kill bots off quickly
				blowem_up()
				return
			}
			else {

				new origin[3]

				if ( gNukeTimer == 4 ) {

					// Non-Bots
					get_players(players, inum, "c")

					for ( new i = 0; i < inum; i++ ) {
						// Screen Shake
						message_begin(MSG_ONE, gmsgShake, {0,0,0}, players[i])
						write_short(1<<14)	// shake amount
						write_short(1<<14)	// shake lasts this long
						write_short(1<<14)	// shake noise frequency
						message_end()
					}

					// Explodes at {0,0,0}
					explode_all(origin)
				}
				else {
					new rOrigin[3], randomNum
					for ( new i = 1; i < 50; i++ ) {
						// Random vectors for explosion
						rOrigin[0] = random(3000)
						rOrigin[1] = random(3000)
						rOrigin[2] = random(2000)

						// Randomly set a negative coordinate
						randomNum = random(2)
						if (randomNum == 0) rOrigin[0] = rOrigin[0] * -1
						randomNum = random(2)
						if (randomNum == 0) rOrigin[1] = rOrigin[1] * -1
						randomNum = random(2)
						if (randomNum == 0) rOrigin[2] = rOrigin[2] * -1

						explode_all(rOrigin)
					}

					if ( gNukeTimer == 2 ) {
						// Non-Bots
						get_players(players, inum, "c")

						for ( new i = 0 ; i < inum; i++ ) {
							// Screen Shake
							message_begin(MSG_ONE, gmsgShake, {0,0,0}, players[i])
							write_short(1<<14)	// shake amount
							write_short(1<<14)	// shake lasts this long
							write_short(1<<14)	// shake noise frequency
							message_end()
						}
					}
				}

				// All ALive
				get_players(players, inum, "a")

				for ( new i = 0 ; i < inum; i++ ) {
					// Randomly kill a player
					new randomKill = random(9)

					if ( randomKill == 0 ) {
						get_user_origin(players[i], origin)
						origin[2] = origin[2] - 26
						explode(origin)

						if ( gIsLethal ) {
							if ( !is_user_alive(players[i]) || players[i] == gNuker ) continue
							if ( get_cvar_num("unclesam_admins_immune") && (get_user_flags(players[i])&ADMIN_IMMUNITY) ) continue

							
							kill_user(players[i], gNuker)
						}
					}
				}
			}
		}
	}
	else {
		blowem_up()
		return
	}
}
//----------------------------------------------------------------------------------------------
blowem_up()
{
	set_hudmessage(255, 50, 50, -1.0, 0.20, 2, 0.02, 4.0, 0.01, 0.1, 2)

	if ( gIsLethal ) {
		show_hudmessage(0, "El Mundo ha sido Destruido. Gracias al Tio Sam.")

		new players[32], inum, origin[3]

		// All ALive
		get_players(players, inum, "a")

		for ( new i = 0 ; i < inum; i++ ) {
			if ( !is_user_alive(players[i]) || players[i] == gNuker ) continue
			if ( get_cvar_num("unclesam_admins_immune") && (get_user_flags(players[i])&ADMIN_IMMUNITY) ) continue

			get_user_origin(players[i], origin)
			origin[2] = origin[2] - 26
			explode(origin)

			kill_user(players[i], gNuker)
		}
	}
	else {
		show_hudmessage(0, "JAJAJA - Era joda. Esa no fue la real Bomba Nuclear.")

		client_cmd(0, "stopsound")
		client_cmd(0, "spk ^"vox/_comma woop^"")
	}

	gInNuke = false
	gCountStarted = false
	gNukeTimer = 0
}
//----------------------------------------------------------------------------------------------
kill_user(victim, attacker)
{
	if ( !is_user_alive(victim) || !is_user_connected(attacker) ) return

	// Log the Kill
	unclesam_logKill(attacker, victim, "Uncle Sam Nuke")

	// Kill the victim and block the messages
	MessageBlock(gmsgDeathMsg, BLOCK_ONCE)
	MessageBlock(gmsgScoreInfo, BLOCK_ONCE)
	user_kill(victim)

	// user_kill removes a frag, this gives it back
	set_user_frags(victim, get_user_frags(victim) + 1)

	// Replaced HUD death message
	message_begin(MSG_BROADCAST, gmsgDeathMsg, {0,0,0}, 0)
	write_byte(attacker)
	write_byte(victim)
	write_byte(0)
	write_string("Uncle Sam Nuke")
	message_end()

	// Update victims scoreboard with correct info
	message_begin(MSG_BROADCAST, gmsgScoreInfo)
	write_byte(victim)
	write_short(get_user_frags(victim))
	write_short(get_user_deaths(victim))
	write_short(0)
	write_short(get_user_team(victim))
	message_end()
}
//----------------------------------------------------------------------------------------------
explode(vec1[3])
{
	//Blast circles white
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(21)		//TE_BEAMCYLINDER
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1936)
	write_short(white)
	write_byte(0)		// startframe
	write_byte(0)		// framerate
	write_byte(2)		// life 2
	write_byte(128)	// width 16
	write_byte(0)		// noise
	write_byte(255)	// r
	write_byte(255)	// g
	write_byte(255)	// b
	write_byte(255)	// brightness
	write_byte(0)		// speed
	message_end()

	//Explosion2
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(12)		//TE_EXPLOSION2
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte(188)	// byte (scale in 0.1's)
	write_byte(10)		// byte (framerate)
	message_end()

	//Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(3)		//TE_EXPLOSION
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(Explode)
	write_byte(188)	// byte (scale in 0.1's)
	write_byte(10)		// byte (framerate)
	write_byte(0)		// byte flags
	message_end()
}
//----------------------------------------------------------------------------------------------
explode_all(vec1[3])
{
	//Blast circles fire
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(21)		//TE_BEAMCYLINDER
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1936)
	write_short(fire)
	write_byte(0)		// startframe
	write_byte(0)		// framerate
	write_byte(24)		// life 2
	write_byte(128)	// width 16
	write_byte(0)		// noise
	write_byte(188)	// r
	write_byte(220)	// g
	write_byte(255)	// b
	write_byte(255)	// brightness
	write_byte(0)		// speed
	message_end()

	//Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(3)		//TE_EXPLOSION
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(mushroom_exp)
	write_byte(188)	// byte (scale in 0.1's) 188
	write_byte(10)		// byte (framerate)
	write_byte(0)		// byte flags
	message_end()
}
//----------------------------------------------------------------------------------------------
public round_end()
{
	gBetweenRounds = true

	if ( gInNuke ) blowem_up()
}
//----------------------------------------------------------------------------------------------
public round_start()
{
	gBetweenRounds = false
}
//----------------------------------------------------------------------------------------------
public unclesam_death()
{
	new id = read_data(2)

	// In case server does not allow drop alive check on death
	unclesam_admincheck(id)
}
//----------------------------------------------------------------------------------------------
public unclesam_admincheck(id)
{
	new accessLevel[10]

	get_cvar_string("unclesam_adminflag", accessLevel, 9)

	if ( gUncleSamSelected[id] &&  !(get_user_flags(id)&read_flags(accessLevel)) ) {
		sh_chat_message(id, -1, "[%s][Only Adimn] No estas autorizado para usar este Héroe." , gHeroName)
		gHasUncleSamPower[id] = false
		client_cmd(id, "say drop %s", gHeroName)
	}
}
//----------------------------------------------------------------------------------------------
unclesam_logKill(id, victim, const weaponDescription[32])
{
	new namea[32], namev[32], authida[32], authidv[32], teama[16], teamv[16]

	//Info On Attacker
	get_user_name(id, namea, 31)
	get_user_team(id, teama, 15)
	get_user_authid(id, authida, 31)
	new auserid = get_user_userid(id)

	//Info On Victim
	get_user_name(victim, namev, 31)
	get_user_team(victim, teamv, 15)
	get_user_authid(victim, authidv, 31)

	//Log This Kill
	if ( id != victim ) {
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"",
			namea, auserid, authida, teama, namev, get_user_userid(victim), authidv, teamv, weaponDescription)
	}
	else {
		log_message("^"%s<%d><%s><%s>^" committed suicide with ^"%s^"",
			namea, auserid, authida, teama, weaponDescription)
	}
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
