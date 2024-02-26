/* * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * AMX (Superhero Mod) Hero: broly
 * 
 *This hero is made by The Art of War, one of the clan leaders of Red Doom [RD]
 *
 *Edited - Remade - Improved by [Red-Doom]
 * Last Update: 7th April 2010
 * 
 * -Contact-
 * RD's website - http://www.reddoom.com/
 * Superhero Mods forum - http://forums.alliedmods.net/forumdisplay.php?f=30
 * 
 * -Updates-
 * v0.1 - Changed Sprites/Sounds
 * v0.2 - Changed CVars and permanent name
 * v1.0 - Fixed a CVar bug
 * v1.1 - Additional sprite changes, added custom sounds and new HUD messages
 * v1.2 - Modified the hero to play a sound and show a HUD message before any level is gained by AP.
 * 
 * -Credits-
 * Credits go to the original authors of Goku and to Mr.V (another [RD] owner) for fixing the cvars and names so it works together with Goku.
 * This is a ripp.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* CVARS - Copy/Paste into shconfig.cfg
//broly
broly_level 10			//Level required to use (Default 10)
broly_aps 100			//The amount of AP gained per second (Default 5)
broly_ap_mult 500		//AP amount multiplied by ssjlevel = AP required for each ssjlevel and cost of ssjlevel power use (Default 250)

broly_hp_mult 150		//HP amount multiplied by ssjlevel, ex. 30*ssj2 = +60HP (Default 30)
broly_hp_max 2000		//Max HP that can be gained (Default 500)

broly_speed_base 450		//Initial Speed boost for ssjlevel 1, only sets if you are slower (Default 300)
broly_speed_add 50		//Speed added to vegetto_speedbase every next ssjlevel (Default 25)

broly_max_power 300	//for ssjlevel 1 Max DMG (Default 300)
//for ssjlevel 2 Max Damage * 2 	(Default 600)
//for ssjlevel 3 Max Damage * 3		(Default 1025)
//for ssjlevel 4 Max Damage * 5 	(Default 1500)

broly_max_radius 200	//Max Radius of DMG for ssjlevel 1th power (Default 200)
//for ssjlevel 2th power Max Radius of DMG * 2 (Default 300)
//for ssjlevel 3th power Max Radius of DMG * 3,5 (Default 700)
//for ssjlevel 4th power Max Radius of DMG * 5 (Default 1500)
 

broly_decals 1		    //Show the burn decals on the walls (0-no 1-yes) (Default 1)
*/ 

#include <superheromod>

// GLOBAL VARIBLES
new gHeroID
new g_heroName[] = "Broly"
new bool:g_hasbroly[SH_MAXSLOTS+1]

// This is for control of kame hame ha
new g_isSaiyanLevel[SH_MAXSLOTS+1]
new g_powerNum[SH_MAXSLOTS+1]
new g_powerID[SH_MAXSLOTS+1]
new g_ssjLevel[4]
new Float:g_ssjSpeed[4]

// This is for the boost Hp, AP, Speed
new g_speed_add, g_speed_base, g_HP_add, g_HP_max
new g_prevWeapon[SH_MAXSLOTS+1]

static const g_burnDecal[3] = {28, 29, 30}
static const g_burnDecalBig[3] = {46, 47, 48}

// Broly player model
new const model_name[] = "broly"
new const gEnt_Blast_Name[] = "vexd_broly_power"

new const model_precache[] = "models/player/broly/broly.mdl"
new const sprite_trail_precache[] = "sprites/shmod/finalflashtrailbro.spr"
new const sprite_smoke_precache[] = "sprites/wall_puff4.spr"

new gMaxDamage, gMaxRadius
new g_maxDamage[SH_MAXSLOTS+1]
new g_maxRadius[SH_MAXSLOTS+1]
 
new gAps_For_Second, gAp_mult, g_maxarmorPts
new g_armorPts, g_spriteSmoke, g_spriteTrail, g_spritePowerUp 

new g_sprite_Epxlosion[4]
new const g_sprite_explo[][] = { 
	"sprites/shmod/gallitguna2bro.spr",	// verde chiquito
	"sprites/shmod/gallitguna2bro.spr",	// 
	"sprites/shmod/gallitguna2bro.spr",	// verde chiquito
	"sprites/shmod/deathball2bro.spr"
}

new const g_sprite_ent[][] = {
	"sprites/shmod/gallitguna2bro.spr",
	"sprites/shmod/gallitguna2bro.spr",
	"sprites/shmod/bigbangbro.spr",
	"sprites/shmod/deathball2bro.spr"
}

new const g_power_name[][] = {
	"Galitgun",
	"Final Flash",
	"Big Bang",
	"Death-Ball"
}

new const g_sound_wav[][] = {
	"shmod/broly_bigbang.wav",	// this sound is for the power in ssj 1 2 3
	"shmod/broly_deathball.wav",	// this sound is for the power in ssj 4
	"shmod/broly_powerup2.wav",	// this sound is for the transformation in ssj 1 2 3
	"shmod/broly_powerup4.wav",	// this sound is for the transformation in ssj 4
	"player/pl_pain2.wav"
}  

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Broly", "3.0", "vittu / Lucas Cab Arje")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("broly_level", "10")
	gAps_For_Second	= register_cvar("broly_aps", "50")		// for ap generation
	gAp_mult	= register_cvar("broly_ap_mult", "250")		// for armor cost
	
	g_HP_add	= register_cvar("broly_hp_mult", "100")
	g_HP_max	= register_cvar("broly_hp_max", "2000")
	
	g_speed_base	= register_cvar("broly_speed_base", "300")
	g_speed_add	= register_cvar("broly_speed_add", "25")
	
	gMaxDamage	= register_cvar("broly_max_power", "300")
	gMaxRadius	= register_cvar("broly_max_radius", "200")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(g_heroName, pcvarLevel);
	sh_set_hero_info(gHeroID, "Convertite en Broly el SSJ Legendario.", "Recarga Ki/Armor para tener cada vez nuevos Niveles de SSJ y poderes por Nivel!");
	sh_set_hero_bind(gHeroID);

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_event("CurWeapon", "curweapon", "be", "1=1")

	// LOOP
	set_task(1.0, "broly_loop", _, _, _, "b")
	
	// TOUCH EVENT
	register_touch(gEnt_Blast_Name,"*","broly_touch")
}

public plugin_precache()
{
	// precache player model
	precache_model(model_precache)
	g_spritePowerUp	= precache_model(g_sprite_ent[3])
	g_spriteTrail 	= precache_model(sprite_trail_precache)
	g_spriteSmoke 	= precache_model(sprite_smoke_precache)

	// precache sounds
	for ( new iSound = 0 ; iSound < sizeof( g_sound_wav ) ; iSound++ )
		precache_sound( g_sound_wav[iSound] )
	
	// precache models
	for ( new iSpritePower = 0 ; iSpritePower < sizeof( g_sprite_explo ) ; iSpritePower++ )
		g_sprite_Epxlosion[iSpritePower] = precache_model( g_sprite_explo[iSpritePower] )
	
	// precache models
	for ( new iSpriteEnt = 0 ; iSpriteEnt < sizeof( g_sprite_ent ) ; iSpriteEnt++ )
		precache_model( g_sprite_ent[iSpriteEnt] )
}

public plugin_cfg()
	loadCVARS()

public loadCVARS()
{
	// These cvars are checked very often
	g_maxarmorPts 	= get_pcvar_num(gAp_mult) * 5
	g_armorPts 	= get_pcvar_num(gAps_For_Second)
	g_ssjLevel[0]	= get_pcvar_num(gAp_mult)
	g_ssjLevel[1] 	= g_ssjLevel[0] * 2
	g_ssjLevel[2] 	= g_ssjLevel[0] * 3
	g_ssjLevel[3] 	= g_ssjLevel[0] * 4
	g_ssjSpeed[0] 	= get_pcvar_float(g_speed_base)
	g_ssjSpeed[1] 	= g_ssjSpeed[0] + get_pcvar_float(g_speed_add)
	g_ssjSpeed[2] 	= g_ssjSpeed[1] + get_pcvar_float(g_speed_add)
	g_ssjSpeed[3] 	= g_ssjSpeed[2] + get_pcvar_float(g_speed_add)
	
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			g_hasbroly[id] = true
			broly_tasks(id)
		}
		case SH_HERO_DROP: {
			g_hasbroly[id] = false
			broly_morph_unmorph(id)
			// remove the power if it was used and user dropped hero
			if ( g_powerID[id] > 0 ) remove_power(id, g_powerID[id])
		}
	}
}
// RESPOND TO KEYDOWN
public sh_hero_key(id, heroID, key) 
{ 
	if ( heroID != gHeroID || !sh_is_inround() ) return
	if ( !is_user_alive(id) || !g_hasbroly[id] ) return 
	
	if ( key == SH_KEYDOWN ) {
		// Reload CVARS to make sure the variables are current
		loadCVARS()
		
		new userArmor = get_user_armor(id)

		if ( userArmor < g_ssjLevel[0] ) {
			playSoundDenySelect(id)
			sh_chat_message(id, gHeroID, "No tenes suficiente Ki, Recarga Armor/Ki.")
			return
		}
	
		// Prevent too many entities, which would cause server problems
		if( g_powerID[id] ) {
			playSoundDenySelect(id)
			sh_chat_message(id, gHeroID, "No podes usar más de un poder a la vez.")
			return
		}
		
		for ( new iLevel = 0 ; iLevel < sizeof( g_ssjLevel ) ; iLevel++ ) {
			if ( iLevel == 3 ) {
				// LEVEL 4
				if ( g_ssjLevel[iLevel] <= userArmor ) {
					// Remove Users glowing since he was ssjlevel 4
					set_user_rendering(id)
					
					sh_chat_message(id, gHeroID, "%s!!!", g_power_name[iLevel])
					
					emit_sound(id, CHAN_STATIC, g_sound_wav[1], 0.8, ATTN_NORM, 0, PITCH_NORM)
					set_user_armor(id, userArmor-g_ssjLevel[iLevel])
					
					new for_mult = iLevel + 2
					g_maxDamage[id] = ( get_pcvar_num(gMaxDamage) * for_mult )
					g_maxRadius[id] = ( get_pcvar_num(gMaxRadius) * for_mult )
					g_powerNum[id] = iLevel + 1
					break;
				}
			} else {
				// LEVEL 1	// LEVEL 2	// LEVEL 3
				if ( g_ssjLevel[iLevel] <= userArmor && userArmor < g_ssjLevel[iLevel+1] ) {
					sh_chat_message(id, gHeroID, "%s!", g_power_name[iLevel]) 
			 
					// Wish this sound was shorter
					emit_sound(id, CHAN_STATIC, g_sound_wav[0], 0.7, ATTN_NORM, 0, PITCH_NORM)
					set_user_armor(id, userArmor-g_ssjLevel[iLevel])
					
					new for_mult = iLevel+1
					g_maxDamage[id] = ( get_pcvar_num(gMaxDamage) * for_mult )
					g_maxRadius[id] = ( get_pcvar_num(gMaxRadius) * for_mult )
					g_powerNum[id] = iLevel + 1
					break;
				}		
			}
		}
		
		create_power(id)	
	}
}
//------------------------------------------------------------------------------------------------
//					Spawn and DEath						//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( g_hasbroly[id] ) {	
		broly_tasks(id)
		g_isSaiyanLevel[id] = 0
	}
}
//------------------------------------------------------------------------------------------------
//				Broly Tasks Morph and Unmorph					//
//------------------------------------------------------------------------------------------------
public broly_tasks(id) {
	set_task(1.0, "broly_morph_unmorph", id)
	// Set armor in x seconds to avoid breaking max ap settings in other heroes
	set_task(1.0, "broly_setarmor", id) 
}

public broly_morph_unmorph(id) {
	// For morph or unmorph in each case
	if ( g_hasbroly[id] ) cs_set_user_model(id, model_name)
	else cs_reset_user_model(id) 
}

public broly_setarmor(id) {
	// Start a broly off with 100 AP, even if user has more from other heroes
	give_item(id, "item_assaultsuit")
	set_user_armor(id, 100)
}
//----------------------------------------------------------------------------------------------
//			Create N Remove entity
//----------------------------------------------------------------------------------------------
public create_power(id)
{
	new Float:vOrigin[3], Float:vAngles[3], Float:vAngle[3], entModel[40]
	new Float:entScale, Float:entSpeed, trailModel, trailLength, trailWidth
	new Float:VecMins[3] = {-1.0,-1.0,-1.0}
	new Float:VecMaxs[3] = {1.0,1.0,1.0}

	// Seting entSpeed higher then 2000.0 will not go where you aim
	// Vec Mins/Maxes must be below +-5.0 to make a burndecal
	// g_powerNum[id] adopta valores de 1 2 3 4
	formatex(entModel, sizeof(entModel), "%s", g_sprite_ent[g_powerNum[id]-1])
	entScale = 0.5 * g_powerNum[id]
	entSpeed = 1900.0 - ( g_powerNum[id] * 300.0 )
	trailModel = g_spriteTrail
	trailLength = 35 * g_powerNum[id]
	trailWidth = 5 * g_powerNum[id] 
	VecMins[0] = VecMins[0] * -1 * g_powerNum[id]
	VecMins[1] = VecMins[1] * -1 * g_powerNum[id]
	VecMins[2] = VecMins[2] * -1 * g_powerNum[id]
	VecMaxs[0] = VecMins[0] * g_powerNum[id]
	VecMaxs[1] = VecMins[1] * g_powerNum[id]
	VecMaxs[2] = VecMins[2] * g_powerNum[id]

	// Get users postion and angles
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_angles, vAngles)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	// Change height for entity origin
	if (g_powerNum[id] == 4) vOrigin[2] += 110
	else vOrigin[2] += 6

	new newEnt = create_entity("info_target")
	if( newEnt == 0 ) {
		sh_chat_message(id, gHeroID, "Power Creation Failure")
		return
	}

	g_powerID[id] = newEnt

	entity_set_string(newEnt, EV_SZ_classname, gEnt_Blast_Name)
	entity_set_model(newEnt, entModel)

	entity_set_vector(newEnt, EV_VEC_mins, VecMins)
	entity_set_vector(newEnt, EV_VEC_maxs, VecMaxs)

	entity_set_origin(newEnt, vOrigin)
	entity_set_vector(newEnt, EV_VEC_angles, vAngles)
	entity_set_vector(newEnt, EV_VEC_v_angle, vAngle)

	entity_set_int(newEnt, EV_INT_solid, 2)
	entity_set_int(newEnt, EV_INT_movetype, 5)
	entity_set_int(newEnt, EV_INT_rendermode, 5)
	entity_set_float(newEnt, EV_FL_renderamt, 255.0)
	entity_set_float(newEnt, EV_FL_scale, entScale)
	entity_set_edict(newEnt, EV_ENT_owner, id)


	// Create a VelocityByAim() function, but instead of users
	// eyesight make it start from the entity's origin - vittu
	new Float:fl_Velocity[3], AimVec[3], velOrigin[3]

	velOrigin[0] = floatround(vOrigin[0])
	velOrigin[1] = floatround(vOrigin[1])
	velOrigin[2] = floatround(vOrigin[2])

	get_user_origin(id, AimVec, 3)

	new distance = get_distance(velOrigin, AimVec)

	// Stupid Check but lets make sure you don't devide by 0
	if (!distance) distance = 1

	new Float:invTime = entSpeed / distance

	fl_Velocity[0] = (AimVec[0] - vOrigin[0]) * invTime
	fl_Velocity[1] = (AimVec[1] - vOrigin[1]) * invTime
	fl_Velocity[2] = (AimVec[2] - vOrigin[2]) * invTime

	entity_set_vector(newEnt, EV_VEC_velocity, fl_Velocity)

	// No trail on Spirit Bomb
	if ( g_powerNum[id] == 4 ) return

	// Set Trail on entity
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)			// TE_BEAMFOLLOW
	write_short(newEnt)		// entity:attachment to follow
	write_short(trailModel)	// sprite index
	write_byte(trailLength)	// life in 0.1's
	write_byte(trailWidth)	// line width in 0.1's
	write_byte(255)	//colour
	write_byte(255)
	write_byte(255)
	write_byte(255)	// brightness
	message_end()

	if ( g_powerNum[id] == 2 || g_powerNum[id] == 3 ) {
		new iNewVelocity[3], args[6]
		iNewVelocity[0] = floatround(fl_Velocity[0])
		iNewVelocity[1] = floatround(fl_Velocity[1])
		iNewVelocity[2] = floatround(fl_Velocity[2])

		// Pass varibles used to guide entity with
		args[0] = id
		args[1] = newEnt
		args[2] = floatround(entSpeed)
		args[3] = iNewVelocity[0]
		args[4] = iNewVelocity[1]
		args[5] = iNewVelocity[2]

		set_task(0.1, "guide_kamehameha", newEnt, args, 6)
	}
}

public remove_power(id, powerID)
{
	new Float:fl_vOrigin[3]

	entity_get_vector(powerID, EV_VEC_origin, fl_vOrigin)

	// Create an effect of kamehameha being removed
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(14)		//TE_IMPLOSION
	write_coord(floatround(fl_vOrigin[0]))
	write_coord(floatround(fl_vOrigin[1]))
	write_coord(floatround(fl_vOrigin[2]))
	write_byte(200)	// radius
	write_byte(40)		// count
	write_byte(45)		// life in 0.1's
	message_end()

	g_powerNum[id] = 0
	g_powerID[id] = 0

	remove_entity(powerID)
} 
//----------------------------------------------------------------------------------------------
//			Effects Broly Hame Ha
//----------------------------------------------------------------------------------------------
public guide_kamehameha(args[])
{
	new AimVec[3], avgFactor
	new Float:fl_origin[3]
	new id = args[0]
	new ent = args[1]
	new speed = args[2]

	if ( !is_valid_ent(ent) ) return

	get_user_origin(id, AimVec, 3)

	entity_get_vector(ent, EV_VEC_origin, fl_origin)

	new iNewVelocity[3]
	new origin[3]

	origin[0] = floatround(fl_origin[0])
	origin[1] = floatround(fl_origin[1])
	origin[2] = floatround(fl_origin[2])

	if ( g_powerNum[id] == 2 )
		avgFactor = 3
	else if ( g_powerNum[id] == 3 )
		avgFactor = 6
	// stupid check but why not
	else
		avgFactor = 8

	new velocityVec[3], length

	velocityVec[0] = AimVec[0]-origin[0]
	velocityVec[1] = AimVec[1]-origin[1]
	velocityVec[2] = AimVec[2]-origin[2]

	length = sqroot(velocityVec[0]*velocityVec[0] + velocityVec[1]*velocityVec[1] + velocityVec[2]*velocityVec[2])
	// Stupid Check but lets make sure you don't devide by 0
	if ( !length ) length = 1

	velocityVec[0] = velocityVec[0]*speed/length
	velocityVec[1] = velocityVec[1]*speed/length
	velocityVec[2] = velocityVec[2]*speed/length

	iNewVelocity[0] = (velocityVec[0] + (args[3] * (avgFactor-1))) / avgFactor
	iNewVelocity[1] = (velocityVec[1] + (args[4] * (avgFactor-1))) / avgFactor
	iNewVelocity[2] = (velocityVec[2] + (args[5] * (avgFactor-1))) / avgFactor

	new Float:fl_iNewVelocity[3]
	fl_iNewVelocity[0] = float(iNewVelocity[0])
	fl_iNewVelocity[1] = float(iNewVelocity[1])
	fl_iNewVelocity[2] = float(iNewVelocity[2])

	entity_set_vector(ent, EV_VEC_velocity, fl_iNewVelocity)

	args[3] = iNewVelocity[0]
	args[4] = iNewVelocity[1]
	args[5] = iNewVelocity[2]

	set_task(0.1, "guide_kamehameha", ent, args, 6)
}
//----------------------------------------------------------------------------------------------
//			Touch hame ha N explosion Effect
//----------------------------------------------------------------------------------------------
public broly_touch(pToucher, pTouched)
{
	if ( !is_valid_ent(pToucher) ) return

	static szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)

	if ( equal(szClassName, gEnt_Blast_Name) ) {
		// owner y radius
		static dmgRadius, maxDamage, id
		id = entity_get_edict(pToucher, EV_ENT_owner)
		dmgRadius = g_maxRadius[id]
		maxDamage = g_maxDamage[id]
		
		// TEngo que crear variables para que las cree antes de usarlas
		static spriteExp, damage_text[20]
		formatex(damage_text, sizeof(damage_text), "%s.", g_power_name[g_powerNum[id]-1])
		spriteExp = g_sprite_Epxlosion[g_powerNum[id]-1]	
	
		new Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)

		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])

		// Cause the Damage
		new vicOrigin[3], Float:dRatio,  distance, damage
		static players[SH_MAXSLOTS], pnum, vic, i
		get_players(players, pnum, "a")

		for ( i = 0; i < pnum; i++) {
			vic = players[i]
			if( !is_user_alive(vic) || vic == id ) continue
			if ( get_user_team(id) == get_user_team(vic) && !get_cvar_num("mp_friendlyfire") ) continue

			get_user_origin(vic, vicOrigin)
			distance = get_distance(vExplodeAt, vicOrigin)

			if ( distance < dmgRadius ) {

				dRatio = floatdiv(float(distance), float(dmgRadius))
				damage = maxDamage - floatround(maxDamage * dRatio)

				// Lessen damage taken by self by half
				// if ( vic == id ) damage = floatround(damage / 2.0)
				// Need hurt sound and small screen shake
				sh_extra_damage(vic, id, damage, damage_text)
				sh_set_stun(vic, 1.0, 300.0) 
				
				sh_screen_shake(vic, 92.0, 3.0, 92.0)

				// Make them feel it
				emit_sound(vic, CHAN_BODY, g_sound_wav[4], 0.8, ATTN_NORM, 0, PITCH_NORM)

				new Float:fl_Time = distance / 125.0
				new Float:fl_vicVelocity[3]
				fl_vicVelocity[0] = (vicOrigin[0] - vExplodeAt[0]) / fl_Time
				fl_vicVelocity[1] = (vicOrigin[1] - vExplodeAt[1]) / fl_Time
				fl_vicVelocity[2] = (vicOrigin[2] - vExplodeAt[2]) / fl_Time
				entity_set_vector(vic, EV_VEC_velocity, fl_vicVelocity)
			}
		}

		// Make some Effects
		static blastSize 
		blastSize = floatround(dmgRadius / 8.0)

		// Explosion Sprite
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(23)			//TE_GLOWSPRITE
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(spriteExp)	// model
		write_byte(01)			// life 0.x sec
		write_byte(blastSize)	// size
		write_byte(255)		// brightness
		message_end()

		// Explosion (smoke, sound/effects)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(3)			//TE_EXPLOSION
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(g_spriteSmoke)		// model
		write_byte(blastSize+5)	// scale in 0.1's
		write_byte(20)			// framerate
		write_byte(10)			// flags
		message_end()

		// Create Burn Decals, if they are used
		// Change burn decal according to blast size
		static decal_id
		if ( blastSize <= 18 ) {
			//radius ~< 216
			decal_id = g_burnDecal[random_num(0,2)]
		}
		else {
			decal_id = g_burnDecalBig[random_num(0,2)]
		}

		// Create the burn decal
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(109)		//TE_GUNSHOTDECAL
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(0)			//?
		write_byte(decal_id)	//decal
		message_end()
		
		remove_entity(pToucher)

		// Reset the Varibles
		g_powerNum[id] = 0
		g_powerID[id] = 0
	}
}
//----------------------------------------------------------------------------------------------
//			BROLY loop for set armor and boost hp n speed
//----------------------------------------------------------------------------------------------
public broly_loop()
{
	static players[SH_MAXSLOTS], pnum, id, i
	get_players(players, pnum, "a")

	for ( i = 0; i < pnum; i++) {
		id = players[i]

		if ( !g_hasbroly[id] || !is_user_alive(id) ) continue
 
		new userArmor = get_user_armor(id)

		// Give him armor
		if ( userArmor < g_maxarmorPts ) {
			if ( userArmor + g_armorPts > g_maxarmorPts ) {
				set_user_armor(id, g_maxarmorPts)
			} else 	{
				// Give the armor item if armor is 0 so CS knows the player has armor
				if ( userArmor <= 0 ) give_item(id, "item_assaultsuit")
				set_user_armor(id, userArmor + g_armorPts)
			}
		}

		// Check armor again after it's been set
		userArmor = get_user_armor(id)
		if ( userArmor < g_ssjLevel[0] ) {
			g_isSaiyanLevel[id] = 0
			continue
		}
		
		for ( new iLevel = 0 ; iLevel < sizeof( g_ssjLevel ) ; iLevel++ ) {
			if ( iLevel == 3 ) {
				// LEVEL 4
				if ( g_ssjLevel[iLevel] <= userArmor && g_isSaiyanLevel[id] < iLevel+1 ) {
					// SSJ4 glows red
					sh_set_rendering(id, 43, 202, 3, 220)  
					// shGlow(id, 43, 202, 3)
					new parm[2]
					parm[0] = id
					parm[1] = 5 + ( iLevel * 2 )
					powerup_effect(parm)
					
					new repeat = 20 * ( iLevel+1 )
					set_task(0.1, "powerup_effect", 0, parm, 2, "a", repeat)

					set_hudmessage(0, 255, 255, -1.0, 0.25, 0, 0.25, 2.5, 0.0, 0.0, 4)
					show_hudmessage(id, "[%s] - Te Trasformaste en el Legendario Broly SSJ %d.", g_heroName, iLevel+1)
					emit_sound(id, CHAN_STATIC, g_sound_wav[3], 0.6, ATTN_NORM, 0, PITCH_NORM)         
	
					g_isSaiyanLevel[id] = iLevel + 1
					shake_n_stun(id)
					// ssj_boost(id)
					break;
				}
			} else {
				// LEVEL 1	// LEVEL 2	// LEVEL 3
				if ( g_ssjLevel[iLevel] <= userArmor && userArmor < g_ssjLevel[iLevel+1] && g_isSaiyanLevel[id] < iLevel+1 ) {
					new parm[2]
					parm[0] = id
					parm[1] = 5 + ( iLevel * 2 )  
					powerup_effect(parm)
					
					new repeat = 20 * ( iLevel+1 )
					set_task(0.1, "powerup_effect", 0, parm, 2, "a", repeat)

					set_hudmessage(0, 255, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 4)
					show_hudmessage(id, "[%s] - Te Trasformaste en Broly SSJ %d.", g_heroName, iLevel+1)
					emit_sound(id, CHAN_STATIC, g_sound_wav[2], 0.5, ATTN_NORM, 0, PITCH_NORM)

					g_isSaiyanLevel[id] = iLevel + 1
					// ssj_boost(id)
					break;
				}
			}
		}
		
		ssj_boost(id)
	}
}

public curweapon(id)
{
	if ( !g_hasbroly[id] || !is_user_alive(id) ) return
	if ( !g_isSaiyanLevel[id] ) return
	
	new wpnid = read_data(2) 
 
	if ( wpnid != g_prevWeapon[id] ) {
		switch(g_isSaiyanLevel[id]) {
			case 1: if ( get_user_maxspeed(id) < g_ssjSpeed[0] ) set_user_maxspeed(id, g_ssjSpeed[0])
			case 2: if ( get_user_maxspeed(id) < g_ssjSpeed[1] ) set_user_maxspeed(id, g_ssjSpeed[1])
			case 3: if ( get_user_maxspeed(id) < g_ssjSpeed[2] ) set_user_maxspeed(id, g_ssjSpeed[2])
			case 4: if ( get_user_maxspeed(id) < g_ssjSpeed[3] ) set_user_maxspeed(id, g_ssjSpeed[3])
		}
		g_prevWeapon[id] = wpnid
	}
}
//----------------------------------------------------------------------------------------------
public ssj_boost(id)
{
	if ( !g_hasbroly[id] || !is_user_alive(id) ) return
	if ( !g_isSaiyanLevel[id] ) return
	
	// Speed Boost
	new speedNum = g_isSaiyanLevel[id] - 1
	
	if ( get_user_maxspeed(id) < g_ssjSpeed[speedNum]) {
		set_user_maxspeed(id, g_ssjSpeed[speedNum])
	}

	// HP boost
	new userHealth = get_user_health(id)
	new maxHP = get_pcvar_num(g_HP_max)
	if ( userHealth < maxHP ) {
		new addHP = get_pcvar_num(g_HP_add) * g_isSaiyanLevel[id]
		
		if ( userHealth + addHP > maxHP ) set_user_health(id, maxHP)
		else set_user_health(id, userHealth + addHP)
		
	}
}
//----------------------------------------------------------------------------------------------
public shake_n_stun(id)
{
	new idOrigin[3], vicOrigin[3]
	new players[SH_MAXSLOTS], pnum, vic

	get_user_origin(id, idOrigin)
	get_players(players, pnum, "a")

	// Shake and Stun all alive users in radius inluding self
	for (new i = 0; i < pnum; i++) {
		vic = players[i]
		if ( !is_user_alive(vic) ) continue
		
		get_user_origin(vic, vicOrigin)
		new distance = get_distance(idOrigin, vicOrigin)
		if ( distance <= get_pcvar_num(gMaxRadius) ) {
			// esto ser�a para que no le afecte al id
			if ( vic != id ) {	
				sh_screen_shake(vic, 14.0, 14.0, 14.0)
				sh_set_stun(vic, 1.5, 250.0)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
//			Power UP effect en Broly SSJ4
//----------------------------------------------------------------------------------------------
public powerup_effect(parm[])
{
	if ( !sh_is_inround() ) return

	new id = parm[0]

	if ( !is_user_alive(id) ) return

	new Size = parm[1]
	new players[SH_MAXSLOTS], pnum
	new idOthers, Origin[3]

	get_players(players, pnum, "a")

	// Show a powerup to all alive players except the one being powered up.
	for (new i = 0; i < pnum; i++) {
		idOthers = players[i]
		if ( !is_user_alive(idOthers) || idOthers == id ) continue
		//if ( !is_user_alive(idOthers)) continue

		get_user_origin(id, Origin) 

		// power up sprite - additive sprite, plays 1 cycle
		message_begin(MSG_ONE, SVC_TEMPENTITY, Origin, idOthers)
		write_byte(17)			// TE_SPRITE
		write_coord(Origin[0])	// center position
		write_coord(Origin[1])
		write_coord(Origin[2]+20)
		write_short(g_spritePowerUp)	// sprite index
		write_byte(Size)		// scale in 0.1's
		write_byte(50)			// brightness
		message_end()

		// power up sprite - additive sprite, plays 1 cycle
		message_begin(MSG_ONE, SVC_TEMPENTITY, Origin, idOthers)
		write_byte(17)			// TE_SPRITE
		write_coord(Origin[0]+5) // center position
		write_coord(Origin[1])
		write_coord(Origin[2]+20)
		write_short(g_spritePowerUp)	// sprite index
		write_byte(Size)		// scale in 0.1's
		write_byte(50)			// brightness
		message_end()

		// power up sprite - additive sprite, plays 1 cycle
		message_begin(MSG_ONE, SVC_TEMPENTITY, Origin, idOthers)
		write_byte(17)			// TE_SPRITE
		write_coord(Origin[0]-5)	// center position
		write_coord(Origin[1])
		write_coord(Origin[2]+20)
		write_short(g_spritePowerUp)	// sprite index
		write_byte(Size)		// scale in 0.1's
		write_byte(50)			// brightness
		message_end()

		// power up sprite - additive sprite, plays 1 cycle
		message_begin(MSG_ONE, SVC_TEMPENTITY, Origin, idOthers)
		write_byte(17)			// TE_SPRITE
		write_coord(Origin[0])	// center position
		write_coord(Origin[1]+5)
		write_coord(Origin[2]+10)
		write_short(g_spritePowerUp)	// sprite index
		write_byte(Size)		// scale in 0.1's
		write_byte(50)			// brightness
		message_end()

		// power up sprite - additive sprite, plays 1 cycle
		message_begin(MSG_ONE, SVC_TEMPENTITY, Origin, idOthers)
		write_byte(17)			// TE_SPRITE
		write_coord(Origin[0])	// center position
		write_coord(Origin[1]-5)
		write_coord(Origin[2]+10)
		write_short(g_spritePowerUp)	// sprite index
		write_byte(Size)		// scale in 0.1's
		write_byte(50)			// brightness
		message_end()
	}
} 
//----------------------------------------------------------------------------------------
//	Finalizar y remover Entidad al final de la ronda o cuando se desconecta		//
//----------------------------------------------------------------------------------------
public sh_round_end() {
	for (new id=1; id <= SH_MAXSLOTS; id++) {
		if ( g_hasbroly[id] && g_powerID[id] > 0 ) remove_power(id, g_powerID[id])
	}
}

public client_disconnected(id) {
	// stupid check but lets see
	if ( id <= 0 || id > SH_MAXSLOTS ) return
	
	if( g_hasbroly[id] && g_powerID[id] > 0 ) remove_power(id, g_powerID[id])
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
