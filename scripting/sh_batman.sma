//BATMAN! - Yeah - well not all of his powers or it'd be unfair...
/* CVARS - copy and paste to shconfig.cfg

//Batman
batman_level 0
batman_health 125		//default 125
batman_armor 125		//defualt 125
batman_count 15000		//default 15000	cuanta guita tiene	
batman_speeditaca 250
batman_itacamult 2
batman_knifemult 2
batman_grenadetimer 8.0		// cada cuanto me da la sg teleport

*/
/*
* v1.17 - JTP10181 - 07/23/04
*       - Fixed issue where you could get zoomed in on other primaries if combined with punisher
*
* 5/17 - Took out ammo give to test for a bug
*        + Punisher gets unlimited ammo - so this is desired not to make
*        batman so powerful.  Batman is split between Batman and Punisher
*
*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

#define SMOKE_SCALE 30
#define SMOKE_FRAMERATE 12
#define SMOKE_GROUND_OFFSET 6

#define AMMOX_SMOKEGRENADE 13

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Batman"
new bool:gHasBatman[SH_MAXSLOTS+1]
// Task para entregar las granadas
new bool:gBlockGiveTask[SH_MAXSLOTS+1]
new gPcvarGrenadeTimer, gPcvarDamageKnife, gPcvarDamageItaca

// Const de Models para ponerse
new const gBatItaca[] = "models/shmod/bat_itaca_v.mdl"
new const gBatItaca2[] = "models/shmod/bat_itaca_p.mdl"
new const gBatKnife[] = "models/shmod/batmanknife_v.mdl"
new const gBatGranade[] = "models/shmod/batmang_v.mdl"

// Sg teleport
new const g_sound_explosion[] = "weapons/sg_explode.wav"
new const g_classname_grenade[] = "grenade"
new const Float:g_sign[4][2] = {{1.0, 1.0}, {1.0, -1.0}, {-1.0, -1.0}, {-1.0, 1.0}}
new g_spriteid_steam1, g_eventid_createsmoke

new tirapedoID
new bool:HasFartman[SH_MAXSLOTS+1]
new bool:gBatmanSelected[SH_MAXSLOTS+1] 

#if SEND_COOLDOWN
	new Float:BatmanUsedTime[SH_MAXSLOTS+1]
#endif
//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Batman", SH_VERSION_STR, "{HOJ} Batman/JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= register_cvar("batman_level", "0")
	new pcvarHealth		= register_cvar("batman_health", "125")
	new pcvarArmor 		= register_cvar("batman_armor", "125")
	gPcvarGrenadeTimer 	= register_cvar("batman_grenadetimer", "10")
	gPcvarDamageItaca	= register_cvar("batman_itacamult", "2")
	gPcvarDamageKnife	= register_cvar("batman_knifemult", "2")
	
	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Bati-Cinturón.", "Obtén Armas Especiales como SG Teleport/XM1014/FAKA, además de HP/AP/daño.")
	sh_set_hero_hpap(gHeroID, pcvarHealth, pcvarArmor)
	sh_set_hero_shield(gHeroID, true)
	
	// Agregados por mi // DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	//eventos
	register_event("Damage", "batman_damage", "b", "2!0")
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	// Si queres dos cambios de armas en el mismo plugin tenes que crear otro evento.
	// sin embargo si podes usar el mismo evento de damage para ambos.
	register_event("CurWeapon", "weapon_change2", "be", "1=1")
	register_event("CurWeapon", "weapon_change3", "be", "1=1")
	
	// eventos del tp smoke
	register_forward(FM_EmitSound, "forward_emitsound")
	register_forward(FM_PlaybackEvent, "forward_playbackevent", false)
	// we do not precaching, but retrieving the indexes
	g_spriteid_steam1 = engfunc(EngFunc_PrecacheModel, "sprites/steam1.spr")
	g_eventid_createsmoke = engfunc(EngFunc_PrecacheEvent, 1, "events/createsmoke.sc")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! - //evento para dar smoke cada cierto tiempo en un define
	register_event("AmmoX", "on_ammox", "b")
	
	set_task(0.3, "cache_idBAT");   		// we need to let superhero cache all the heros to avoid issues
}

public cache_idBAT() 
	tirapedoID	= sh_get_hero_id("TiraPedos");
	
public plugin_precache()
{
	precache_model("models/shmod/batmanknife_v.mdl")
	precache_model("models/shmod/bat_itaca_v.mdl")
	precache_model("models/shmod/bat_itaca_p.mdl")
	precache_model("models/shmod/batmang_v.mdl")
	precache_model("models/shmod/w_batmang.mdl")
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
				gHasBatman[id] = true
				gPlayerInCooldown[id] = false
				batman_giveweapons(id)
				switch_model(id)
				gBatmanSelected[id] = gHasBatman[id]
				Batman_heroscheck(id)
			}
			case SH_HERO_DROP: {
				gHasBatman[id] = false
				if (is_user_alive(id))
					sh_drop_weapon(id, CSW_XM1014, true)
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
	// TiraPedos
	else if ( heroID == tirapedoID ) {
		HasFartman[id] = mode ? true : false
	}
}

public sh_client_spawn(id)
{
	if ( gHasBatman[id] && is_user_alive(id) ) {
		
		gBlockGiveTask[id] = true
		gPlayerInCooldown[id] = false
		batman_giveweapons(id)
		give_grenade(id)
	}
}
#if SEND_COOLDOWN
public sendBatmanCooldown(id)
{
	new cooldown
	
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(gPcvarGrenadeTimer) - get_gametime() + BatmanUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
//------------------------------------------------------------------------------------------------
//				Recargar Smokes Grenades					//
//------------------------------------------------------------------------------------------------
public give_grenade(id)
	if ( is_user_alive(id) && gHasBatman[id] ) sh_give_weapon(id, CSW_SMOKEGRENADE)

public on_ammox(id)
{
	//Ammox is used in case other heroes give nades so the task can be removed when nade is refilled.
	if ( !sh_is_active() || !is_user_alive(id) || !gHasBatman[id] ) return

	if ( read_data(1) == AMMOX_SMOKEGRENADE ) {
		new iAmmoCount = read_data(2)

		if ( iAmmoCount == 0 && !gBlockGiveTask[id] ) {
			
			if ( !gPlayerInCooldown[id] ) {
				new iGrenade = -1
				while ( (iGrenade = find_ent_by_class(iGrenade, "grenade")) > 0 ) {
					new model[32]
					entity_get_string(iGrenade, EV_SZ_model, model, 31)
					if ( id == entity_get_edict(iGrenade, EV_ENT_owner) && equal(model, "models/w_smokegrenade.mdl") ) {
						entity_set_model(iGrenade, "models/shmod/w_batmang.mdl")
					}
				}
			}
			
			new Float:seconds = get_pcvar_float(gPcvarGrenadeTimer)
			if ( seconds > 0.0 ) {
				// Proof From Hud			
				#if SEND_COOLDOWN
					BatmanUsedTime[id] = get_gametime()
				#endif	
				//This will be called on spawn as well as when nade is thrown, block this on spawn.
				//Nade was thrown set task to give another.
				set_task(get_pcvar_float(gPcvarGrenadeTimer), "give_grenade", id)
				
				sh_set_cooldown(id, seconds)
			}
		}
				
		else if ( iAmmoCount > 0 ) {
			gBlockGiveTask[id] = false
			remove_task(id)
		}
	}
}
//------------------------------------------------------------------------------------------------
//				Entrega de armas y damage					//
//------------------------------------------------------------------------------------------------
batman_giveweapons(id)
{
	if (sh_is_active() && is_user_alive(id) && gHasBatman[id] ) {
		sh_give_weapon(id, CSW_XM1014);
		// sh_give_weapon(id, CSW_AWP);
		sh_give_weapon(id, CSW_SMOKEGRENADE);
		sh_give_item(id, "ammo_buckshot");
		sh_give_item(id, "ammo_buckshot");
		sh_give_item(id, "ammo_buckshot");
		sh_give_item(id, "ammo_buckshot");
		sh_give_item(id,"ammo_556nato");
		sh_give_item(id,"ammo_556nato");
		// sh_give_item(id,"ammo_338magnum")
		// Give CTs a Defuse Kit
		if ( cs_get_user_team(id) == CS_TEAM_CT ) sh_give_item(id, "item_thighpack")
	}
}

public weapon_change(id)
{
	if ( !gHasBatman[id] || !is_user_alive(id) ) return	
	
	new clip, ammo, weaponID = get_user_weapon(id,clip,ammo)
	// new weaponID = read_data(2)
	if (weaponID !=CSW_XM1014) return
	switch_model(id)	
}

switch_model(id)
{
	if ( !is_user_alive(id) ) return
    
	if (get_user_weapon(id) == CSW_XM1014) {
		set_pev(id, pev_viewmodel2, gBatItaca)
		set_pev(id, pev_weaponmodel2, gBatItaca2)
	}

	if (get_user_weapon(id) == CSW_KNIFE) {
		set_pev(id, pev_viewmodel2, gBatKnife)
	}
		
	if (get_user_weapon(id) == CSW_SMOKEGRENADE) {
		set_pev(id, pev_viewmodel2, gBatGranade)
	}
} 

public weapon_change2(id)
{
	if ( !is_user_alive(id) || !gHasBatman[id] ) return	
	
	new clip, ammo, kweaponID = get_user_weapon(id,clip,ammo)
	// new kweaponID = read_data(2)
	if (kweaponID !=CSW_KNIFE) return
	switch_model(id)	
}

public weapon_change3(id)
{
	if ( !is_user_alive(id) || !gHasBatman[id] ) return
   
	new clip, ammo, weaponID = get_user_weapon(id,clip,ammo)
	// new weaponID = read_data(2)
	if (weaponID != CSW_SMOKEGRENADE) return
	switch_model(id)
}
 
public batman_damage(id)
{
	if ( !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasBatman[attacker] && weapon == CSW_XM1014 && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(gPcvarDamageItaca) - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "xm1014", headshot)
	}
	
	
	if ( gHasBatman[attacker] && weapon == CSW_KNIFE && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(gPcvarDamageKnife) - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	}
}

public client_connect(id)
	gHasBatman[id] = false
//------------------------------------------------------------------------------------------------
//				SG Teleport							//
//------------------------------------------------------------------------------------------------
public forward_emitsound(ent, channel, const sound[]) 
{	
	//if (!equal(sound, g_sound_explosion) || !is_grenade(ent))
	//	return FMRES_IGNORED

	static id, Float:origin[3]
	id = pev(ent, pev_owner)
	
	if ( !(id <= id <= SH_MAXSLOTS) || !is_user_alive(id) ) 
		return FMRES_IGNORED 
	
	if ( !sh_is_inround() || !gHasBatman[id] ) 
		return FMRES_IGNORED
	 
	if (!equal(sound, g_sound_explosion) || !is_grenade(ent))
		return FMRES_IGNORED
	
	pev(ent, pev_origin, origin)
	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, g_sound_explosion, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_SetOrigin, ent, Float:{8191.0, 8191.0, 8191.0}) 
	// engfunc(EngFunc_RemoveEntity, ent)
	origin[2] += SMOKE_GROUND_OFFSET
	create_smoke(origin)
	
	if (is_user_alive(id) ) {	// && gHasBatman[id]
		static Float:mins[3], hull
		pev(id, pev_mins, mins)
		origin[2] -= mins[2] + SMOKE_GROUND_OFFSET
		hull = pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
		if (is_hull_vacant(origin, hull))
			engfunc(EngFunc_SetOrigin, id, origin)
		else 	{ // close to a solid object, trying to find a vacant spot
			static Float:vec[3]
			vec[2] = origin[2]
			for (new i; i < sizeof g_sign; ++i) {
				vec[0] = origin[0] - mins[0] * g_sign[i][0]
				vec[1] = origin[1] - mins[1] * g_sign[i][1]
				if (is_hull_vacant(vec, hull)) {
					engfunc(EngFunc_SetOrigin, id, vec)
					break
				}
			}
		}
	}

	return FMRES_SUPERCEDE
}

public forward_playbackevent(flags, invoker, eventindex) 
{	
	// if ( !( 1 <= invoker <= 32 ) || !is_user_alive(invoker) ) return FMRES_IGNORED 
	if ( !(invoker <= invoker <= SH_MAXSLOTS) || !is_user_alive(invoker) ) return FMRES_IGNORED 
	if ( !gHasBatman[invoker] ) return FMRES_IGNORED 
	
	// we do not need a large amount of smoke 
	if( eventindex == g_eventid_createsmoke)
		return FMRES_SUPERCEDE

	return FMRES_IGNORED 	// FMRES_IGNORED 
}

bool:is_grenade(ent) 
{
	if (!pev_valid(ent)) 
		return false

	static classname[sizeof g_classname_grenade + 1]
	pev(ent, pev_classname, classname, sizeof g_classname_grenade)
	if (equal(classname, g_classname_grenade))
		return true

	return false
}

create_smoke(const Float:origin[3]) 
{
	// engfunc because origin are float
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SMOKE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(g_spriteid_steam1)
	write_byte(SMOKE_SCALE) 
	write_byte(SMOKE_FRAMERATE)
	message_end()
}

stock bool:is_hull_vacant(const Float:origin[3], hull) 
{
	new tr = 0
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr)
	if (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true
	
	return false
}

public Batman_heroscheck(id) 
{
	if ( HasFartman[id] && gBatmanSelected[id] ) {
		new heronametodrop[]= "TiraPedos"
		sh_chat_message(id, gHeroID, " Para usar este Héroe tenes que quitarte el %s primero.", heronametodrop)
      		gHasBatman[id] = false
      		client_cmd(id, "say drop %s", gHeroName)
   	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/