/* ACE OF KATANAS - You the best swordsman !!!
-
Thanks Jelle For the TUT Begginers.
Thanks for part of Shade Script for the smoke	- I did not find the author of the script.
Thanks for part of LongJump Script for the dash - I did not find the author of the script.
-
*/
/* CVARS - copy and paste to shconfig.cfg

//Ace of Katanas
aceofkat_level 0 
aceofkat_knifemult 3.0		//Multiplier for knife damage (Default 3.0)
aceofkat_percent 0.40		//Percent for realize the dash and damage

aceofkat_knifespeed 500		//Speed of Ace of Katana in knife mode (Default 500)
*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new gHeroName[] = "Ace of Katanas"
new bool:gHasAceOfKatanas[SH_MAXSLOTS+1]
new pcvarPercent, pcvarDamage, smoke

// Models
new const model_v[] = "models/shmod/ace_v_knife.mdl"
// new const model_p[] = "models/shmod/ace_p_knife.mdl"

//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------ 
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Ace Katana", "1.2", " Lucas Cab 'Arje' ")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("aceofkat_level", "3")
	// new pcvarSpeed 	= register_cvar("aceofkat_knifespeed", "500")
	pcvarDamage 	= register_cvar("aceofkat_knifemult", "3.0")
	pcvarPercent 	= register_cvar("aceofkat_percent", "0.40")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Obtén Dual Katanas.", "Más daño y velocidad en la Faka, también tenes la posibilidad de hacer un dash y humo después de matar, tu dash inflige daño.")

	// EVENTOS
	// EXTRA KNIFE DAMAGE
	register_event("Damage", "aceofkat_damage", "b", "2!0")
	
	// EVENTO PARA CAMBIAR MODELOS DE FAKA
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Knife_Deploy", 1)	// For the change the weapons
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// sh_set_hero_speed(gHeroID, pcvarSpeed, {CSW_KNIFE}, 1)
	sh_set_hero_shield(gHeroID, true)
}

public plugin_precache()
{
	precache_model(model_v)
	// precache_model(model_p)
	smoke = precache_model("sprites/steam1.spr") 
}
//------------------------------------------------------------------------------------------------
//					INIT y SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	 
	switch(mode) {
		case SH_HERO_ADD: {
			gHasAceOfKatanas[id] = true
			switchmodel(id)	
		}
		case SH_HERO_DROP: {
			gHasAceOfKatanas[id] = false
		}
	}
	
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
} 
//------------------------------------------------------------------------------------------------
//				CAMBIO DE MODEL	 y Damage Faka					//
//------------------------------------------------------------------------------------------------
public Knife_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)
	
	if ( !is_user_alive(id) || !gHasAceOfKatanas[id] ) return HAM_IGNORED; 
	
	set_pev(id, pev_viewmodel2, model_v)
	// set_pev(id, pev_weaponmodel2, model_p)
	
	return HAM_IGNORED; 
}

switchmodel(id)
{
	if ( !is_user_alive(id) ) return
	if ( get_user_weapon(id) == CSW_KNIFE ) {
		set_pev(id, pev_viewmodel2, model_v)
		// set_pev(id, pev_weaponmodel2, model_p)
	}
}

public aceofkat_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	new damage = read_data(2)

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasAceOfKatanas[attacker] && weapon == CSW_KNIFE && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(pcvarDamage) - damage)
		if ( extraDamage > 0 ) shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	}
}
//----------------------------------------------------------------------------------------------
// 			AGREGADOS NUEVOS HUMO SHADE y DASH TOUCH
//----------------------------------------------------------------------------------------------
public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() || !sh_is_inround() ) return
	if ( victim == attacker || !is_user_alive(attacker) || !gHasAceOfKatanas[attacker] ) return
	
	new clip, ammo, wpnid = get_user_weapon(attacker, clip, ammo) 
	
	// if (wpnid == CSW_KNIFE && random_float(0.0, 2.0) <= get_pcvar_float(pcvarPercent)) {
	new percent = floatround(get_pcvar_float(pcvarPercent) * 100.0)
	if ( wpnid == CSW_KNIFE && percent >= random_num(0, 100) ) {
		
		make_fog(victim)
		dash(attacker) 
		  
		set_hudmessage(0, 100, 200, 0.02, 0.65, 0, 0.0, 2.0, 0.0, 0.0, 3)
		show_hudmessage(attacker, "[%s] Tiraste Humo Y Dash.", gHeroName)
	}
}
//------------------------------------------------------------------------------------------------
//				EVENTO DE DASH + DAMAGE						//
//------------------------------------------------------------------------------------------------
public dash(attacker)
{
	if (!(pev(attacker, pev_flags) & FL_ONGROUND)) return
	
	// This works so the higher the second term of vel_by_aim, the higher the dash it will give.
	static Float:velocity[3]
	velocity_by_aim(attacker, 1750, velocity)
        
	//velocity[0] = 1000.0		// x
	//velocity[1] = 1000.0   	// y
	velocity[2] = 100.0		// z
	set_pev(attacker, pev_velocity, velocity)
	
	// This is for the glow
	sh_set_rendering(attacker, 141, 143, 144, 16, kRenderFxGlowShell)
	set_task(0.7, "aceofkat_unglow", attacker)
}

public aceofkat_unglow(attacker) sh_set_rendering(attacker)
//------------------------------------------------------------------------------------------------
//				EVENTO DE HUMO CREA HUMO					//
//------------------------------------------------------------------------------------------------
public make_fog(victim)
{
	new origin[3]
	get_user_origin(victim,origin)
	fog_this_area(origin)
	fog_this_area(origin)
	fog_this_area(origin)
	fog_this_area(origin)
	fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)
	//fog_this_area(origin)

	return PLUGIN_HANDLED
}

public fog_this_area(origin[3])
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,origin )
	write_byte( 5 )
	write_coord( origin[0] + random_num( -100, 100 ))
	write_coord( origin[1] + random_num( -100, 100 ))
	write_coord( origin[2] + random_num( -75, 75 ))
	write_short( smoke )
	write_byte( 50 )
	write_byte( 5 )
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
