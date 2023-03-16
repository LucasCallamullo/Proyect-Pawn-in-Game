#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fvault>

#define PLUGIN "Registration System"
#define VERSION "1.3"
#define AUTHOR  "Biel-oGrande"

new const g_fvault[ ] = "superheroaccounts"

new const g_button1[] = "buttons/button9.wav"
new const g_button2[] = "buttons/button2.wav"
new const g_button3[] = "buttons/button3.wav"
new const g_button4[] = "buttons/button10.wav"

enum _:TOTAL_FORWARDS {
	
	FW_USER_REGISTER,
	FW_USER_LOGGED,
	FW_USER_LOGGED_INVITED,
	FW_USER_ACCOUNT_DELETED
}

new g_Forwards[TOTAL_FORWARDS]
new g_ForwardResult

new g_logged[33], g_registered[33], g_invited[33]

new g_password[33], g_password_again[33]

new g_attempts[33], g_unlock[33], g_deleted_account[33]

new cvar_attempts, cvar_bantime, cvar_logintime, cvar_screenfade, cvar_min_characters, cvar_max_characters, cvar_invited, cvar_delete, cvar_sounds

new cvar_hud_normal_r, cvar_hud_normal_g, cvar_hud_normal_b

new cvar_hud_success_r, cvar_hud_success_g, cvar_hud_success_b

new cvar_hud_fail_r, cvar_hud_fail_g, cvar_hud_fail_b

new cvar_hud_effect, cvar_hud_effect_time, cvar_hud_time

new cvar_hud_position_x, cvar_hud_position_y

new cvar_screenfade_r, cvar_screenfade_g, cvar_screenfade_b

new g_screenfade

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("registration_system", VERSION, FCVAR_SPONLY | FCVAR_SERVER)
	
	// register_clcmd("say /registro", "commands")
	
	register_clcmd("chooseteam", "message_team")
	register_clcmd("jointeam", "message_team")
	register_clcmd("joinclass", "message_team")
	
	register_clcmd("ENTER_YOUR_PASSWORD", "cmd_password")
	register_clcmd("ENTER_YOUR_PASSWORD_AGAIN", "cmd_password_again")
	register_clcmd("ENTER_YOUR_PASSWORD_CURRENT", "cmd_password_current")
	
	register_clcmd("say", "commands")
	register_clcmd("say_team", "commands")
	
	register_dictionary("registration_system.txt")
	
	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	
	cvar_min_characters = register_cvar("reg_min_characters", "3")
	cvar_max_characters = register_cvar("reg_max_characters", "20")
	cvar_attempts = register_cvar("reg_wrong_passowrd_limit", "3")
	cvar_bantime = register_cvar("reg_wrong_passowrd_ban_time", "7")
	
	cvar_logintime = register_cvar("reg_time_to_login", "120")
	
	cvar_screenfade = register_cvar("reg_screenfade", "1")
	cvar_invited = register_cvar("reg_invited", "0")
	cvar_delete = register_cvar("reg_delete", "1")
	cvar_sounds = register_cvar("reg_sounds", "1")
	
	cvar_hud_normal_r = register_cvar("reg_hud_normal_color_r", "0")
	cvar_hud_normal_g = register_cvar("reg_hud_normal_color_g", "255")
	cvar_hud_normal_b = register_cvar("reg_hud_normal_color_b", "0")
	
	cvar_hud_success_r = register_cvar("reg_hud_success_color_r", "0")
	cvar_hud_success_g = register_cvar("reg_hud_success_color_g", "0")
	cvar_hud_success_b = register_cvar("reg_hud_success_color_b", "255")
	
	cvar_hud_fail_r = register_cvar("reg_hud_fail_color_r", "255")
	cvar_hud_fail_g = register_cvar("reg_hud_fail_color_g", "0")
	cvar_hud_fail_b = register_cvar("reg_hud_fail_color_b", "0")
	
	cvar_hud_position_x = register_cvar("reg_hud_position_x", "0.02")
	cvar_hud_position_y = register_cvar("reg_hud_position_y", "0.20")
	
	cvar_hud_effect = register_cvar("reg_hud_effect", "0")
	cvar_hud_effect_time = register_cvar("reg_hud_effect_time", "1.0")   // aca iba 5.0
	
	cvar_hud_time = register_cvar("reg_hud_time", "1.0")   //  aca iba 10.0 
	
	cvar_screenfade_r = register_cvar("cvar_screenfade_color_r", "0")
	cvar_screenfade_g = register_cvar("cvar_screenfade_color_g", "0")
	cvar_screenfade_b = register_cvar("cvar_screenfade_color_b", "0")
	
	g_screenfade = get_user_msgid("ScreenFade")
	
	g_Forwards[FW_USER_REGISTER] = CreateMultiForward("reg_user_register", ET_IGNORE, FP_CELL)
	g_Forwards[FW_USER_LOGGED] = CreateMultiForward("reg_user_logged", ET_IGNORE, FP_CELL)
	g_Forwards[FW_USER_LOGGED_INVITED] = CreateMultiForward("reg_user_logged_invited", ET_IGNORE, FP_CELL)
	g_Forwards[FW_USER_ACCOUNT_DELETED] = CreateMultiForward("reg_user_account_deleted", ET_IGNORE, FP_CELL)
	
	new directory[64]
	get_configsdir(directory, charsmax(directory))
	server_cmd("exec %s/registration_system.cfg", directory)
}

public plugin_natives() {
	
	register_native("reg_is_user_logged", "native_is_user_logged", 1)
	register_native("reg_is_user_registered", "native_is_user_registered", 1)
	register_native("reg_is_user_invited", "native_is_user_invited", 1)
}

public plugin_precache() {
	
	precache_sound(g_button1)
	precache_sound(g_button2)
	precache_sound(g_button3)
	precache_sound(g_button4)
}

public client_connect(id) {
	
	client_cmd(id, "setinfo ^"_vgui_menus^" ^"1^"")
}

public client_putinserver(id) {
	
	static szName[32], szData[64]
	get_user_name(id, szName, charsmax(szName))
	set_task(get_pcvar_float(cvar_logintime), "login_time", id)
	
	g_unlock[id] = true
	
	if(fvault_get_data(g_fvault, szName, szData, charsmax(szData) ) ) {
		
		g_registered[id] = true
	}
	else {
		g_registered[id] = false
	}
}

public client_disconnected(id) {
	
	remove_task(id)
	g_logged[id] = false
	g_invited[id] = false
	g_unlock[id] = false
}

public message_team(id) {
	
	if(!g_logged[id] && !g_invited[id] && !is_user_bot(id) && !is_user_hltv(id)) {
		
		menu_account(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public ClientUserInfoChanged(id) { 
	
	static szOldName[32]
	pev(id, pev_netname, szOldName, charsmax(szOldName))
	
	if(szOldName[0]) {
		
		static const name[] = "name"
		static szNewName[32]
		get_user_info(id, name, szNewName, charsmax(szNewName))
		
		if(!equal(szOldName, szNewName)) {
			
			set_user_info(id, name, szOldName)
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}

public menu_account(id) {
	
	new szMenu[512], szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	formatex(szMenu, charsmax(szMenu), "\r%L^n^n\r%L\d: \w[\y%s\w]^n\r%L\d: \w[\y%L\w]", LANG_PLAYER, "MENU_ACCOUNT_TITLE", LANG_PLAYER, "MENU_ACCOUNT_NICK", szName, LANG_PLAYER, "MENU_ACCOUNT_STATUS", 
	LANG_PLAYER, g_invited[id] ? "MENU_ACCOUNT_INVITED" : g_logged[id] ? "MENU_ACCOUNT_LOGGED" : g_registered[id] ? "MENU_ACCOUNT_REGISTERED" : "MENU_ACCOUNT_NOT_REGISTERED")
	
	new Menu = menu_create(szMenu, "handler_menu_account")
	
	formatex(szMenu, charsmax(szMenu), "%s%L", g_logged[id] ? "\d" : g_registered[id] ? "\y" : "\d", LANG_PLAYER, "MENU_ACCOUNT_00")
	menu_additem(Menu, szMenu, "1", 0)
	
	formatex(szMenu, charsmax(szMenu), "%s%L^n", g_registered[id] ? "\d":"\r", LANG_PLAYER, "MENU_ACCOUNT_01")
	menu_additem(Menu, szMenu, "2", 0)
	
	formatex(szMenu, charsmax(szMenu), "%s%L", g_logged[id] ? "\w" : "\d", LANG_PLAYER, "MENU_ACCOUNT_02")
	menu_additem(Menu, szMenu, "3", 0)
	
	formatex(szMenu, charsmax(szMenu), "%s%L^n", !get_pcvar_num(cvar_delete) ? "\d" :g_logged[id] ? "\w" :  "\d", LANG_PLAYER, "MENU_ACCOUNT_03")
	menu_additem(Menu, szMenu, "4", 0)
	
	formatex(szMenu, charsmax(szMenu), "%s%L", g_registered[id] ? "\d" : !get_pcvar_num(cvar_invited) ? "\d" : g_invited[id] ? "\d" : "\y", LANG_PLAYER, "MENU_ACCOUNT_04")
	menu_additem(Menu, szMenu, "5", 0)
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_ACCOUNT_EXIT")
	menu_setprop(Menu, MPROP_EXITNAME, szMenu)
	menu_display(id, Menu, 0)
}

public handler_menu_account(id, menu, item) {
	
	if(item == MENU_EXIT) {
		
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item) {
		
		case 0: login(id)
			case 1: register(id)
			case 2: change(id)	
			case 3: delete_account(id) 
			case 4: invited(id)
		}
	return PLUGIN_HANDLED
}

public login(id) {
	
	if(g_logged[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_A")
		//client_print(id, "%L %L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_A")
		PlayEmitSound(id, g_button4)
	}
	else if(!g_registered[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_B")
		//client_print(id, "%L %L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_B")
		PlayEmitSound(id, g_button4)
	}
	else {
		
		client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_C")
		//client_print(id, "%L %L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_00_C")
		PlayEmitSound(id, g_button1)
		g_unlock[id] = false
	}
	return PLUGIN_HANDLED
}

public register(id) {
	
	if(g_registered[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_A")
		//client_print(id, "%L %L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_A")
		PlayEmitSound(id, g_button4)
	}
	else {
		
		client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_B")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_01_B")
		PlayEmitSound(id, g_button1)
		g_unlock[id] = false
	}
	return PLUGIN_HANDLED
}

public change(id) {
	
	if(!g_logged[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_A")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_A")
		PlayEmitSound(id, g_button4)
	}
	else {
		
		client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_CURRENT")
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_B")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_02_B")
		PlayEmitSound(id, g_button1)
		g_unlock[id] = false
	}
	return PLUGIN_HANDLED
}

public delete_account(id) {
	
	if(!g_logged[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_A")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_A")
		PlayEmitSound(id, g_button4)
	}
	else if(!get_pcvar_num(cvar_delete)) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_C")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_C")
		PlayEmitSound(id, g_button4)
	}
	else {
		
		client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_CURRENT")
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_B")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_03_B")
		PlayEmitSound(id, g_button1)
		g_unlock[id] = false
		g_deleted_account[id] = true
	}
	return PLUGIN_HANDLED
}

public invited(id) {
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	if(!get_pcvar_num(cvar_invited)) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_D")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_D")
		PlayEmitSound(id, g_button4)
	}	
	if(g_registered[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_A")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_A")
		PlayEmitSound(id, g_button4)
	}
	else if(g_invited[id]) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_B")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_B")
		PlayEmitSound(id, g_button4)
	}
	else {
		
		client_cmd(id, "jointeam")
		set_hudmessage(get_pcvar_num(cvar_hud_success_r), get_pcvar_num(cvar_hud_success_g), get_pcvar_num(cvar_hud_success_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_C")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_ACCOUNT_CASE_04_C")
		ExecuteForward(g_Forwards[FW_USER_LOGGED_INVITED], g_ForwardResult, id)
		PlayEmitSound(id, g_button1)
		g_invited[id] = true
	}
	return PLUGIN_HANDLED
}

public cmd_password(id) {
	
	if(g_unlock[id]) return PLUGIN_HANDLED
	
	new szName[32], szData[64]
	get_user_name(id, szName, charsmax(szName))
	fvault_get_data(g_fvault, szName, szData, charsmax(szData))		
	
	read_args(g_password[id], 50)
	remove_quotes(g_password[id])
	trim(g_password[id])
	
	g_unlock[id] = true
	
	if(!characters(g_password[id], strlen(g_password[id]))) {
		
		menu_account(id)		
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_00")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_00")
		PlayEmitSound(id, g_button2)
	}
	else if(strlen(g_password[id]) < get_pcvar_num(cvar_min_characters)) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_01", get_pcvar_num(cvar_min_characters))
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_01", get_pcvar_num(cvar_min_characters))
		PlayEmitSound(id, g_button2)
	}
	else if(strlen(g_password[id]) > get_pcvar_num(cvar_max_characters)) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_02", get_pcvar_num(cvar_max_characters))
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_02", get_pcvar_num(cvar_max_characters))
		PlayEmitSound(id, g_button2)
	}
	else if(equal(g_password[id], szName[id])) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_03")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_03")
		PlayEmitSound(id, g_button2)
	}
	else if(g_logged[id]) {
		
		if(!equal(szData, g_password[id])) {
			
			client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_AGAIN")
			set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
			show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_04")
			//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_04")
			PlayEmitSound(id, g_button3)
			g_unlock[id] = false
		}
		else {
			
			menu_account(id)
			set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
			show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_05")
			//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_05")
			PlayEmitSound(id, g_button2)
		}
	}
	else if(!g_registered[id]) {
		
		client_cmd(id,"messagemode ENTER_YOUR_PASSWORD_AGAIN")
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_06")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_06")
		PlayEmitSound(id, g_button3)
		g_unlock[id] = false
	}
	else {
		
		if(equal(szData, g_password[id])) {
			
			remove_task(id)
			client_cmd(id, "jointeam")
			set_hudmessage(get_pcvar_num(cvar_hud_success_r), get_pcvar_num(cvar_hud_success_g), get_pcvar_num(cvar_hud_success_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
			show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_07")
			//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_07")			
			ExecuteForward(g_Forwards[FW_USER_LOGGED], g_ForwardResult, id)
			PlayEmitSound(id, g_button3)
			g_logged[id] = true
			g_attempts[id] = 0
		}
		else {
			
			wrong_password(id)
		}
	}
	return PLUGIN_HANDLED
}

public cmd_password_again(id) {
	
	if(g_unlock[id]) return PLUGIN_HANDLED
	
	read_args(g_password_again[id], 50)
	remove_quotes(g_password_again[id])
	trim(g_password_again[id])
	
	g_unlock[id] = true
	
	if(!equal(g_password[id], g_password_again[id])) {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_00")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_00")
		PlayEmitSound(id, g_button2)
	}
	else if(!g_registered[id]) {
		
		menu_end_register(id)
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_01")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_01")
		PlayEmitSound(id, g_button3)
	}
	else {
		
		menu_change_password(id)
		set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_02")
		//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSOWORD_AGAIN_02")	
		PlayEmitSound(id, g_button3)
	}
	return PLUGIN_HANDLED
}

public cmd_password_current(id) {
	
	if(g_unlock[id]) return PLUGIN_HANDLED
	
	new szName[32], szData[64]
	get_user_name(id, szName, charsmax(szName))
	fvault_get_data(g_fvault, szName, szData, charsmax(szData))		
	
	read_args(g_password[id], 50)
	remove_quotes(g_password[id])
	trim(g_password[id])
	
	g_unlock[id] = true
	
	if(equal(szData, g_password[id])) {
		
		if(g_deleted_account[id]) {
			
			menu_delete_account(id)
			PlayEmitSound(id, g_button3)
			g_unlock[id] = false
			g_deleted_account[id] = false
		}
		else {
			
			client_cmd(id,"messagemode ENTER_YOUR_PASSWORD")
			set_hudmessage(get_pcvar_num(cvar_hud_normal_r), get_pcvar_num(cvar_hud_normal_g), get_pcvar_num(cvar_hud_normal_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
			show_hudmessage(id, "%L", LANG_PLAYER, "CMD_PASSWORD_CURRENT_00")
			//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "CMD_PASSWORD_CURRENT_00")	
			PlayEmitSound(id, g_button3)
			g_unlock[id] = false
		}
	}
	else {
		
		wrong_password(id)
	}
	return PLUGIN_HANDLED
}

public menu_end_register(id) {
	
	new szMenu[512], szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	formatex(szMenu, charsmax(szMenu), "\r%L^n^n\y%L: \r[\d%s\r]^n\y%L: \r[\d%s\r]", LANG_PLAYER, "MENU_END_REGISTER_TITLE", LANG_PLAYER, "MENU_END_REGISTER_NICK", szName, LANG_PLAYER, "MENU_END_REGISTER_PASSWORD", g_password_again[id])
	
	new Menu = menu_create(szMenu, "handler_menu_end_register")
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_END_REGISTER_00")
	menu_additem(Menu, szMenu, "1", 0)
	
	formatex(szMenu, charsmax(szMenu), "%L^n", LANG_PLAYER, "MENU_END_REGISTER_01")
	menu_additem(Menu, szMenu, "2", 0)
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_END_REGISTER_02")
	menu_additem(Menu, szMenu, "3", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
	menu_display(id, Menu, 0)
}

public handler_menu_end_register(id, menu, item) {
	
	if(item == MENU_EXIT) {
		
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item) {
		
		case 0: end_register(id)
			case 1: register(id)
			case 2: {
			
			menu_account(id)
			PlayEmitSound(id, g_button1)
		}
	}
	return PLUGIN_HANDLED
}

public end_register(id) {
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	fvault_set_data(g_fvault, szName, g_password_again[id])
	
	set_hudmessage(get_pcvar_num(cvar_hud_success_r), get_pcvar_num(cvar_hud_success_g), get_pcvar_num(cvar_hud_success_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
	show_hudmessage(id, "%L", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_A")
	//client_print(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_A")	
	//client_print(id, "!g%L !t%L: !y[!g %s !y] !t%L: !y[!g %s !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_END_REGISTER_CASE_00_B_NICK", szName, LANG_PLAYER, "MENU_END_REGISTER_CASE_00_B_PASSOWORD", g_password_again[id])
	remove_task(id)
	PlayEmitSound(id, g_button1)
	ExecuteForward(g_Forwards[FW_USER_REGISTER], g_ForwardResult, id)
	g_registered[id] = true
	
	if(g_invited[id]) {
		
		g_invited[id] = false; g_logged[id] = true
		ExecuteForward(g_Forwards[FW_USER_LOGGED], g_ForwardResult, id)
	}
	menu_account(id)
}

public menu_change_password(id) {
	
	new szMenu[512], szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	formatex(szMenu, 127, "\r%L^n^n\r%L: \d[\y%s\d]^n\r%L: \d[\y%s\d]", LANG_PLAYER, "MENU_CHANGE_PASSWORD_TITLE", LANG_PLAYER, "MENU_CHANGE_PASSWORD_NICK", szName, LANG_PLAYER, "MENU_CHANGE_PASSWORD_PASSWORD", g_password_again[id])
	
	new Menu = menu_create(szMenu,"handler_menu_change_password")
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_00")
	menu_additem(Menu, szMenu, "1", 0)
	
	formatex(szMenu, charsmax(szMenu), "%L^n", LANG_PLAYER, "MENU_CHANGE_PASSWORD_01")
	menu_additem(Menu, szMenu, "2", 0)
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_02")
	menu_additem(Menu, szMenu, "3", 0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
	menu_display(id, Menu, 0)
}

public handler_menu_change_password(id, menu, item) {
	
	if(item == MENU_EXIT) {
		
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item) {
		
		case 0: replaced_password(id)
			case 1: change(id)
			case 2: {
			
			menu_account(id)
			PlayEmitSound(id, g_button1)
		}
	}
	return PLUGIN_HANDLED
}

public replaced_password(id) {
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	fvault_set_data(g_fvault, szName, g_password_again[id])
	
	set_hudmessage(get_pcvar_num(cvar_hud_success_r), get_pcvar_num(cvar_hud_success_g), get_pcvar_num(cvar_hud_success_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
	show_hudmessage(id, "%L", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_A")
	//client_print_color(id, "!g%L !t%L", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_A")	
	//client_print_color(id, "!g%L !t%L: !y[!g %s !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "MENU_CHANGE_PASSWORD_CASE_00_B_PASSWORD", g_password_again[id])
	PlayEmitSound(id, g_button1)
	g_attempts[id] = 0
}

public menu_delete_account(id) {
	
	new szMenu[512]
	
	formatex(szMenu, 127, "\r%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_TITLE")
	
	new Menu = menu_create(szMenu,"handler_menu_delete_account")
	
	formatex(szMenu, charsmax(szMenu), "%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_00")
	menu_additem(Menu, szMenu, "1", 0)
	
	formatex(szMenu, charsmax(szMenu), "\y%L", LANG_PLAYER, "MENU_DELETED_ACCOUNT_01")
	menu_additem(Menu, szMenu, "2",0)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
	menu_display(id, Menu, 0)
}

public handler_menu_delete_account(id, menu, item) {
	
	if(item == MENU_EXIT) {
		
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item) {
		
		case 0: account_deleted(id)
			case 1: {
			
			menu_account(id)
			PlayEmitSound(id, g_button1)
		}
	}
	return PLUGIN_HANDLED
}

public account_deleted(id) {
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	fvault_remove_key(g_fvault, szName)
	
	ExecuteForward(g_Forwards[FW_USER_ACCOUNT_DELETED], g_ForwardResult, id)
	
	client_print(id, print_console, "----------------------------------------")
	client_print(id, print_console, "----- %L -------", LANG_PLAYER, "MENU_DELETED_ACCOUNT_CASE_00")
	client_print(id, print_console, "----------------------------------------")	
	client_cmd(id, "disconnect")
	client_cmd(id, "toggleconsole")	
}

public wrong_password(id) {
	
	g_attempts[id]++
	if(g_attempts[id] >= get_pcvar_num(cvar_attempts)) {
		
		server_cmd("amx_banip #%i %i ^"%L^"", get_user_userid(id), get_pcvar_num(cvar_bantime), LANG_PLAYER, "WRONG_PASSWORD_00", get_pcvar_num(cvar_bantime))
		remove_task(id)
		g_attempts[id] = 0
	}
	else {
		
		menu_account(id)
		set_hudmessage(get_pcvar_num(cvar_hud_fail_r), get_pcvar_num(cvar_hud_fail_g), get_pcvar_num(cvar_hud_fail_b), get_pcvar_float(cvar_hud_position_x), get_pcvar_float(cvar_hud_position_y), get_pcvar_num(cvar_hud_effect), get_pcvar_float(cvar_hud_effect_time), get_pcvar_float(cvar_hud_time))
		show_hudmessage(id,"%L [ %d / %d ]", LANG_PLAYER, "WRONG_PASSWORD_01", g_attempts[id], get_pcvar_num(cvar_attempts))
		//client_print_color(id, "!g%L !t%L !y[!g %d !y/!g %d !y]", LANG_PLAYER, "REG_PREFIX", LANG_PLAYER, "WRONG_PASSWORD_01", g_attempts[id], get_pcvar_num(cvar_attempts))
		PlayEmitSound(id, g_button2)
	}
}

public login_time(id) {
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	if(!g_logged[id] && !g_invited[id] && !is_user_hltv(id) && !is_user_bot(id)) {
		
		client_print(id, print_console, "----------------------------------------")
		client_print(id, print_console, "%L",LANG_PLAYER, "LOGIN_TIME_00", szName)
		client_print(id, print_console, "%L", LANG_PLAYER, "LOGIN_TIME_01")
		client_print(id, print_console, "%L", LANG_PLAYER, "LOGIN_TIME_02")
		client_print(id, print_console, "%L", LANG_PLAYER, "LOGIN_TIME_04", get_pcvar_num(cvar_logintime))
		client_print(id, print_console, "----------------------------------------")
		//client_print_color(0, "!g%L !y%s !t%L !t", LANG_PLAYER, "REG_PREFIX", szName, LANG_PLAYER, "LOGIN_TIME_04")
		client_cmd(id, "disconnect")
		client_cmd(id, "toggleconsole")
	}
}

public PlayerPreThink(id) {
	
	if(!g_logged[id] && !g_invited[id] && !is_user_bot(id) && !is_user_hltv(id) && get_pcvar_num(cvar_screenfade)) {
		
		message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
		write_short(1<<12)
		write_short(1<<12)
		write_short(0x0000)
		write_byte(get_pcvar_num(cvar_screenfade_r))
		write_byte(get_pcvar_num(cvar_screenfade_g))
		write_byte(get_pcvar_num(cvar_screenfade_b))
		write_byte(255)
		message_end()		
	}
}

public commands(id) {
	
	new text[70], arg1[32], arg2[32], arg3[6]
	read_args(text, sizeof(text) - 1)
	remove_quotes(text)
	arg1[0] = '^0'; arg2[0] = '^0'; arg3[0] = '^0'
	parse(text, arg1, sizeof(arg1) - 1, arg2, sizeof(arg2) - 1, arg3, sizeof(arg3) - 1)
	
	if(equali(arg1, "/", 1) || equali(arg1, ".", 1)) format(arg1, 31, arg1[1])
	
	if(arg3[0]) return PLUGIN_CONTINUE
	
	if(equali(arg1, "registro") || equali(arg1, "register") || equali(arg1, "conta") || equali(arg1, "account")) {
		
		menu_account(id)
	}
	return PLUGIN_CONTINUE
}

public native_is_user_logged(id) {
	
	if(!is_user_connected(id))
		return 0
	
	return g_logged[id]
}

public native_is_user_registered(id) {
	
	if(!is_user_connected(id))
		return 0
	
	return g_registered[id]
}

public native_is_user_invited(id) {
	
	if(!is_user_connected(id))
		return 0
	
	return g_invited[id]
}

PlayEmitSound(id, const sound[]) {
	
	if(get_pcvar_num(cvar_sounds)) {
		
		client_cmd(id, "spk %s", sound)
	}
}

bool:characters(const symbol[], len) {
	
	new const valid_chars[][] = {
		
		"0", "1", "2", "3", "4","5", "6", "7", "8", "9",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
		"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
		"u", "v", "w", "x", "y", "z"
	}
	static i, a, valids;
	valids = 0
	
	for(i = 0; i < len; i++) {
		
		for(a = 0; a < sizeof(valid_chars); a++) {
			
			if(symbol[i] == valid_chars[a][0]) {
				
				valids++
				break
			}
		}
	}
	if(valids != len)
		return false
	return true
}

/*stock client_print_color(const id, const input[], any:...) {
	
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!team2", "^0")
	
	if (id)
		players[0] = id
	else
		get_players(players, count, "ch")
	
	for (new i = 0; i < count; i++) {
		
		if (is_user_connected(players[i])) {
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
