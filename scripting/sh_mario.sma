// Mario- Multiple Jumps

/* CVARS - copy and paste to shconfig.cfg

//Mario
mario_level 0		//What level is he avalible
mario_maxjumps 5	//How much jumps can he do

*/

#include <superheromod>

// VARIABLES
new gHeroID
new gHeroName[]="Mario"
new gHasMarioPower[SH_MAXSLOTS+1]
new bool:gCanJump[SH_MAXSLOTS+1]

//PCVARS
new mario_maxjumps
new jumpnum[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Mario","1.1","Bum_Boy16")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel	= register_cvar("mario_level", "0")
	mario_maxjumps 	= register_cvar("mario_maxjumps", "6")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Saltos Múlitples.", "Podes saltar varias veces en el aire! Te permite escapar de ciertos poderes con stun como Sub-Zero por ejemplo.")
}
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode) 
{ 
	if ( heroID != gHeroID ) return
    
	switch(mode) {
		case SH_HERO_ADD: {
			gHasMarioPower[id] = true
			jumpnum[id] = get_pcvar_num(mario_maxjumps)
		}
		case SH_HERO_DROP: {
			gHasMarioPower[id] = false
		}
	}
}

public sh_client_spawn(id)
	jumpnum[id] = get_pcvar_num(mario_maxjumps)
//----------------------------------------------------------------------------------------------
public client_PreThink(id)
{
	if ( !gHasMarioPower[id] ) return

	if ( entity_get_int(id,EV_INT_button)&IN_JUMP ) {

		if (entity_get_int(id,EV_INT_flags)&FL_ONGROUND)
			jumpnum[id] = get_pcvar_num(mario_maxjumps)

		else if ( !(entity_get_int(id,EV_INT_oldbuttons)&IN_JUMP) ) {
			if(jumpnum[id] > 0) 
				gCanJump[id] = true
			
		}
	}
}
//----------------------------------------------------------------------------------------------	
public client_PostThink(id)
{
	if ( gCanJump[id] ) {
		static Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] += 285.0
		entity_set_vector(id,EV_VEC_velocity,velocity)
		entity_set_int(id, EV_INT_gaitsequence, 6)  //Just a jump animation
		gCanJump[id] = false
		jumpnum[id]--
	}
}
//----------------------------------------------------------------------------------------------	
public client_connect(id)
	gHasMarioPower[id] = false
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/