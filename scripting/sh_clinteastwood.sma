 // Dirty Harry 
 
 //Credits go to Sputnik and sharky / vittu.

 /* CVARS - copy and paste to shconfig.cfg

 //Dirty Harry
 Dirty_level 4
 dirty_knock 200           //How Strong Teh Knock back Effect Is for you
 Dirty_deaglemult 2.5		//Damage multiplyer for his Deagle
 dirty_gravity 0.5	//gravedad default=1
 */
 
  /*
 *   Version1.3
 *   Removed teh Cvar for The Knock Back effect for your enemys coz it didnt work as i espected eheh
 */
 
  /*
  *   Version1.2
  *   Cleaned Teh Code
  *   Addet A little Knock Back effect for Teh user of diry harry it make it look more realistic
  *   made a Cvar for Teh Knock Back for Teh enemy 
  */

  /*
  *   Version1.1
  *   Clean The code
  *   Renamed to Dirty Harry Coz everyone wanted so -_-
  *   Addet a damage mult coz he didnt have a 1 hit kill deagle shot
  *   Removed Gravity coz he aint superman LOL
  */

#include <superheromod>
 
#define BACK_FLY    10000

 // GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Clint Eastwood"
new bool:gHasDirtyPower[SH_MAXSLOTS+1]
 
new dougID
new bool:gHasDougPower[SH_MAXSLOTS+1]
 //----------------------------------------------------------------------------------------------
 public plugin_init()
 {
	// Plugin Info
	register_plugin("SUPERHERO Clint Eastwood", "1.2", "Om3gA")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("dirty_level", "4")
	register_cvar("dirty_knock","200")
	register_cvar("dirty_deaglemult", "2.5")
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "DK-Deagle con Retroceso.", "Obtén una Deagle, con Retroceso para vos y tus enemigos. Posibilidad de evadir balas.")
	sh_set_hero_shield(gHeroID, true)
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// EVENTS
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	register_event("CurWeapon","Dirty_knock","be","1=1")
	register_event("Damage", "Dirty_damage", "b", "2!0")
	
	// HITZONE CHANGING LOOP
	set_task(1.0, "dirty_hitzones", 0, "", 0, "b")
	
	set_task(0.3, "cache_idClint");   		// we need to let superhero cache all the heros to avoid issues
}

public cache_idClint() 
	dougID	= sh_get_hero_id("Doug Headshot!");

public plugin_precache()
	precache_model("models/shmod/dirty_deagle.mdl")
//------------------------------------------------------------------------------------------------
//				Init / Spawn and Death						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	// if ( gHeroID != heroID ) return
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasDirtyPower[id] = true
				Dirty_weapons(id)
				switchmodel(id)
				}
			case SH_HERO_DROP: {
				gHasDirtyPower[id] = false
				engclient_cmd(id, "drop", "weapon_deagle")
				set_user_hitzones(0, id, 255)
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
	// Doug
	else if ( heroID == dougID ) {
		gHasDougPower[id] = mode ? true : false
	}
}

public sh_client_spawn(id)
{
	if ( gHasDirtyPower[id] && is_user_alive(id) )
		set_task(0.1, "Dirty_weapons", id)
}

public Dirty_weapons(id)
{
	if ( shModActive() && is_user_alive(id) ) {
		shGiveWeapon(id, "weapon_deagle")
		shGiveWeapon(id, "ammo_50ae")
		shGiveWeapon(id, "ammo_50ae")
	}
}

public weaponChange(id)
{
	if ( !gHasDirtyPower[id] || !is_user_alive(id) ) return

	new wpnid = read_data(2)
	if ( wpnid != CSW_DEAGLE ) return

	switchmodel(id)
	
	if ( gHasDougPower[id] ) {
		if (read_data(3) == 0) {
			//so if he is out of ammo just reload it
			sh_reload_ammo(id, 2)
			/*after the id I made a 1 number
			look at the superheromod.inc and you will see this
			0 - follow server sh_reloadmode CVAR
			1 - continuous shooting, no reload
			2 - fill the backpack (must reload)
			3 - drop the gun and get a new one with full clip
			That should explain it*/
		}
	}
}
 
switchmodel(id)
{
	if ( !is_user_alive(id) || !gHasDirtyPower[id] ) return 
	
	new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)
	
	if ( wpnid == CSW_DEAGLE ) set_pev(id, pev_viewmodel2, "models/shmod/dirty_deagle.mdl")
}
//----------------------------------------------------------------------------------------------
public Dirty_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasDirtyPower[attacker] && weapon == CSW_DEAGLE && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_cvar_float("dirty_deaglemult") - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "deagle", headshot)


		new Float:Origin[3]
		entity_get_vector(id,EV_VEC_origin,Origin)

		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		new Float:avelocity[3]

		VelocityByAim(attacker,BACK_FLY,avelocity)

		velocity[0] += avelocity[0]
		velocity[1] += avelocity[1]
		velocity[2] += avelocity[2]+random_float(200.0,225.0)

		entity_set_vector(id, EV_VEC_velocity, velocity)
	}
}
 
public Dirty_knock(id) {

	new temp[2]
	new usersweapon = get_user_weapon(id, temp[0], temp[1])
   
	if(usersweapon == CSW_DEAGLE && is_user_alive(id) && gHasDirtyPower[id]) {

	if(get_user_button(id)&IN_ATTACK) {

		new Float:PlayerVelocity[3]
       		VelocityByAim(id, -get_cvar_num("dirty_knock"), PlayerVelocity)
		entity_set_vector(id, EV_VEC_velocity, PlayerVelocity)

		}
	}
	return PLUGIN_CONTINUE
}

public dirty_hitzones()
{
	if ( !shModActive() || !hasRoundStarted() ) return

	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( gHasDirtyPower[id] && is_user_alive(id) ) {
			new hitZone
			hitZone = random_num(1, 7)
			switch(hitZone) {
				case 1: set_user_hitzones(0, id, 127)	//remove right leg hitzone
				case 2: set_user_hitzones(0, id, 191)	//remove left leg hitzone
				case 3: set_user_hitzones(0, id, 223)	//remove right arm hitzone
				case 4: set_user_hitzones(0, id, 239)	//remove left arm hitzone
				case 5: set_user_hitzones(0, id, 247)	//remove stomach hitzone
				case 6: set_user_hitzones(0, id, 251)	//remove chest hitzone
				case 7: set_user_hitzones(0, id, 253)	//remove head hitzone
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
