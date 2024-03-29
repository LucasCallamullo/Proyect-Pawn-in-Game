// Veronika

/* CVARS - copy and paste to shconfig.cfg

//Veronika
veronika_level 13
veronika_akmulti 3.1			//Damage multiplyer for his ak47
veronika_grenades 25				//Grenades given
veronika_m203rad 210
veronika_m203dmg 90

*/

// Thanx to the original code of MP5+203 Mod by PaintLancer
#define ICON_HIDE 0
#define ICON_SHOW 1
#define TE_BEAMFOLLOW 22

#include <superheromod> 

// VARIABLES
new gHeroID
new gHeroName[] = "Veronika"
new bool:gHasVeronikaPower[SH_MAXSLOTS+1]

new g_ammo[SH_MAXSLOTS+1]
new bool:g_use_grenade[SH_MAXSLOTS+1]



//sprites
new m_iTrail, xplode, gMsgID
new gPcvarDamage, gPcvarKnock, gPcvarRadius, gPcvarDamageG, gPCvarAmmo

new const gEnt_Grenade_Name[] = "m203_nade"

// models for the hero
new const gSound_V1[] 	= "shmod/glauncher.wav"
new const gSound_V2[] 	= "shmod/a_exm2.wav"

new const gSprite_V1[] 	= "sprites/shmod/zerogxplode2.spr"

new const gModel_V1[] 	= "models/shmod/ak47grenade.mdl"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Veronika","1.3","DuPeR/Yang")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 	= register_cvar("veronika_level", "13")
	gPcvarDamage	= register_cvar("veronika_akmulti", "3.1")
	gPcvarKnock	= register_cvar("veronika_m203conc","30.0")  //force of knockback
	gPcvarRadius	= register_cvar("veronika_m203rad","210")  //radius of dmg
	gPcvarDamageG	= register_cvar("veronika_m203dmg","90")  //dmg
	gPCvarAmmo	= register_cvar("veronika_grenades","25")  //ammo


	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Resident Evil. (AK-47)", "AK Lanzador de Granadas, Usalo con el click secundario. Evita daño de Caidas")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_event("CurWeapon", "weaponChange","be","1=1")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ak47_Deploy", 1)
	
	register_event("Damage", "veronika_damage","b","2!0")

	//handle when player presses attack2
	register_forward(FM_PlayerPreThink, "forward_playerprethink")
	
	// handle world model
	register_forward(FM_SetModel, "forward_setmodel")

	// Let Server know about Lara's Variable
	gMsgID = get_user_msgid("StatusIcon")
	
	// TOUCH EVENT
	register_touch(gEnt_Grenade_Name,"*","veronika_touch")
}



public plugin_precache()
{
	precache_model(gModel_V1)
	precache_model("models/p_9mmar.mdl")
	precache_model("models/w_9mmar.mdl")
	precache_model("models/grenade.mdl")
	precache_sound(gSound_V1)
	precache_sound(gSound_V2)
	m_iTrail= precache_model("sprites/smoke.spr")
	xplode 	= precache_model(gSprite_V1)
}
//------------------------------------------------------------------------------------------------
//					INIT y SPAWN						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasVeronikaPower[id] = true
				
				g_ammo[id] = get_pcvar_num(gPCvarAmmo)
				veronika_weapons(id)
				switchmodel(id)
			}
			case SH_HERO_DROP: {
				gHasVeronikaPower[id] = false
				if ( is_user_alive(id) )
					sh_drop_weapon(id, CSW_AK47, true)
			}
		}
			
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
}
//----------------------------------------------------------------------------------------------
//			SPAWN N DEATH
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasVeronikaPower[id] ) {
		set_task(0.1, "veronika_weapons", id)
		g_ammo[id] = get_pcvar_num(gPCvarAmmo)
		g_use_grenade[id] = false
	}
	
	new grenada = find_ent_by_class(-1, gEnt_Grenade_Name)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, gEnt_Grenade_Name)
	}
}

public sh_client_death(id)
	if ( gHasVeronikaPower[id] ) ammo_hud(id,0)

public veronika_weapons(id)
{
	if ( is_user_alive(id) ) {
		sh_give_weapon(id, CSW_AK47)
		sh_give_item(id,"ammo_762nato")
		sh_give_item(id,"ammo_762nato")
	}
}
//----------------------------------------------------------------------------------------------
//			CHANGE MODELS
//----------------------------------------------------------------------------------------------
public Ak47_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)	// 41 y 4 son constantes van siempre
	if ( !is_user_alive(id) || !gHasVeronikaPower[id] ) return HAM_IGNORED; 
	 
	set_pev(id, pev_viewmodel2, gModel_V1)
	return HAM_IGNORED; 
} 

public weaponChange(id)
{
	if ( !gHasVeronikaPower[id] || !is_user_alive(id) ) return

	new wpnid = read_data(2)
	if ( wpnid != CSW_AK47 ) {
		ammo_hud(id, 0)
		return
	}

	// Never Run Out of Ammo! new clip = read_data(3)
	/* if ( clip == 0 ) {
		shReloadAmmo(id)
	} */
}

switchmodel(id) {
	if (get_user_weapon(id) == CSW_AK47) 
		set_pev(id, pev_viewmodel2, gModel_V1)
}
//----------------------------------------------------------------------------------------------
//				DAMAGE EVENT
//----------------------------------------------------------------------------------------------
public veronika_damage(id)
{
	if ( !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasVeronikaPower[attacker] && weapon == CSW_AK47 ) {
		// do extra damage
		new extraDamage = floatround(damage * get_pcvar_float(gPcvarDamage) - damage)
		if (extraDamage > 0) shExtraDamage( id, attacker, extraDamage, "AK47+M203", headshot )
	}
}
//----------------------------------------------------------------------------------------------
//				EFFECT GRANADE
//----------------------------------------------------------------------------------------------
public forward_playerprethink(id)
{
	if ( !is_user_alive(id) ) return FMRES_IGNORED
	
	static wpnid 
	wpnid = get_user_weapon(id)
	// new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ( entity_get_int(id, EV_INT_button) & IN_ATTACK2 && wpnid == CSW_AK47 && gHasVeronikaPower[id] ) {
		launch_nade(id)
		return FMRES_IGNORED
	}

	return FMRES_IGNORED
}

public launch_nade(id)
{
	if ( !gHasVeronikaPower[id] || !is_user_alive(id) || g_use_grenade[id] ) {
		return PLUGIN_CONTINUE
	}

	if ( g_ammo[id] == 0 ) {
		ammo_hud(id, 0)
		g_use_grenade[id] = true
		sh_chat_message(id, gHeroID, "Te quedaste sin m203 granadas!")
		return PLUGIN_CONTINUE
	}

	entity_set_int(id, EV_INT_weaponanim, 3)

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	//client_print(id, print_center, "Origin: %f-%f-%f", Origin[0], Origin[1], Origin[2])
	//client_print(id, print_center, "vAngle: %f-%f-%f", vAngle[0], vAngle[1], vAngle[2])

	Origin[2] = Origin[2] + 10

	Ent = create_entity("info_target")

	if ( !Ent ) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, gEnt_Grenade_Name)
	entity_set_model(Ent, "models/grenade.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, 2000 , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	emit_sound(id, CHAN_VOICE, gSound_V1, 0.7, ATTN_NORM, 0, PITCH_NORM)
	
	// this is for the count
	ammo_hud(id, 0)
	g_ammo[id]--
	ammo_hud(id, 1)

	new parm[1]
	parm[0] = Ent
	
	// for block the grenades
	g_use_grenade[id] = true
	set_task(0.5, "active_g_use", id)

	set_task(0.2, "grentrail", id, parm, 1)

	return PLUGIN_CONTINUE
}

public active_g_use(id) 
{
	g_use_grenade[id] = false
}

public veronika_touch(pToucher, pTouched)
{
	if ( !is_valid_ent(pToucher) ) return
	
	static szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if ( equal(szClassName, gEnt_Grenade_Name) ) {
		
		static damradius, maxdamage
		damradius = get_pcvar_num(gPcvarRadius)		//200
		maxdamage = get_pcvar_num(gPcvarDamageG)	//70

		new Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		
		static origin[3], dist, Float:dRatio, damage
	
		static players[SH_MAXSLOTS], pnum, vic, i, id
		get_players(players, pnum, "a")
		
		id = entity_get_edict(pToucher, EV_ENT_owner)

		for ( i = 0; i < pnum; i++ ) {
			vic = players[i]
			
			if ( !is_user_alive(vic) || id == vic ) continue
			if ( get_user_team(id) == get_user_team(vic) && !get_cvar_num("mp_friendlyfire") ) continue

			get_user_origin(vic, origin)
			dist = get_distance(origin,vExplodeAt)
			if ( dist <= damradius ) {
				
				dRatio = floatdiv(float(dist),float(damradius))
				damage = maxdamage - floatround(floatmul(float(maxdamage),dRatio))

				set_velocity_from_origin( vic, fl_vExplodeAt, get_pcvar_float(gPcvarKnock) * damage ) // ThantiK's he-conc function - tried getting it to recognize m203 nades but failed so imported function

				sh_extra_damage(vic, id, damage, "grenade veronika")
			}
			
		}

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(17)
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2] + 60)
		write_short(xplode)
		write_byte(20)
		write_byte(200)
		message_end()

		emit_sound(pToucher, CHAN_WEAPON, gSound_V2, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		remove_entity(pToucher)
	}
}

ammo_hud(id, sw)
{ 
	// this is for sprite hud granede
	static s_sprite[33] 
	format( s_sprite, 32, "number_%d", g_ammo[id] )

	if (sw)	{
		message_begin( MSG_ONE, gMsgID, {0,0,0}, id )
		write_byte( ICON_SHOW ) // status
		write_string( s_sprite ) // sprite name
		write_byte( 0 ) // red
		write_byte( 160 ) // green
		write_byte( 0 ) // blue
		message_end()
	}
	else 	{
		message_begin( MSG_ONE, gMsgID, {0,0,0}, id )
		write_byte( ICON_HIDE ) // status
		write_string( s_sprite ) // sprite name
		write_byte( 0 ) // red
		write_byte( 160 ) // green
		write_byte( 0 ) // blue
		message_end()
	}
}
/////////////////////
//Thantik's he-conc functions
stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

	// Velocity = Distance / Time

	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}
// Sets velocity of an entity (ent) away from origin with speed (speed)
stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
	new Float:fVelocity[3];
	get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

	entity_set_vector( ent, EV_VEC_velocity, fVelocity );

	return ( 1 );
}

public grentrail(parm[])
{
	new gid = parm[0]

	if (gid) {
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(gid) // entity
		write_short(m_iTrail)  // model
		write_byte( 10 )       // life
		write_byte( 5 )        // width
		write_byte( 255 )      // r, g, b
		write_byte( 255 )    // r, g, b
		write_byte( 255 )      // r, g, b
		write_byte( 100 ) // brightness

		message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
	}
}

public forward_setmodel(entity, model[])
{
	if ( !is_valid_ent(entity) ) return FMRES_IGNORED

	if ( equal(model, gModel_V1) ) {
		static classname[11]
		entity_get_string(entity, EV_SZ_classname, classname, 10)
		if (equal(classname, "weaponbox")) {
			entity_set_model(entity, "models/w_9mmar.mdl")
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
