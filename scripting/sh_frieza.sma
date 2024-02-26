// Registros de Frieza
/*	
Version 1.0:  	The hero is born.
Version 1.1:  	Made the disk position right in front of user, and added
		0.2 seconds of immunity. Since many people have IMed me complaining
		about when they fire the disk at an incline it kills them.  So 
		this version will fix that problem up.
Version 1.2:  	Made compliant to new superhero 1.2.0 methods, added a delay between touches
		to avoid issues.
*/
/*			THE CVARS TO COPY AND PASTE IN SHCONFIG.CFG
//Frieza
frieza_level 10
frieza_damage 200
frieza_cooldown 50
frieza_diskspeed 750
frieza_disklife 50

*/
// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

#include <superheromod>

new const mdisk[] = "models/shmod/frieza_friezadisc.mdl";
new const sdisk[] = "shmod/frieza_destructodisc.wav";

new const sprite_frieza[] = "sprites/shmod/freezer_trail.spr";
new const disk_ent_name[] = "disk";

// GLOBAL VARIABLES
new gHeroID;
new const gHeroName[] = "Freezer"
new bool:gHasFrieza[SH_MAXSLOTS+1], bool:blocknexttouch[SH_MAXSLOTS+1];
new diskTimer[SH_MAXSLOTS+1]; 
new disk[SH_MAXSLOTS+1];
new sprite_flash
new pcvar_dmg, pcvar_cool, pcvar_speed, pcvar_life;

// This is for cooldowns
new Float:gPcvarRealCD[SH_MAXSLOTS+1]

// generic for interactiones with other heros
new const gOthers_Heros[][] = {
	"Noob"
}

//------------------------------------------------------------------------------------------------
//				Plugin Init and Precache					//
//------------------------------------------------------------------------------------------------ 
public plugin_init() 
{ 
	//Special thanks to avalanche for helping me to debug my hero.
	register_plugin("SUPERHERO Frieza", "1.2", "Gorlag/Batman  /  XxAvalanchexX") 

	//THE CVARS 
	new pcvar_lev 		= register_cvar("frieza_level", "10") 
	pcvar_dmg 		= register_cvar("frieza_damage", "200")  
	pcvar_cool 		= register_cvar("frieza_cooldown", "50") 
	pcvar_speed 		= register_cvar("frieza_diskspeed", "750") 
	pcvar_life 		= register_cvar("frieza_disklife", "50") 

	//THIS LINE MAKES THE HERO SELECTABLE 
	gHeroID = sh_create_hero(gHeroName, pcvar_lev);
	sh_set_hero_info(gHeroID, "El Emperador del Universo.", "Crea La Bola de La Muerte, Podes Redirigirla con la mira!");
	sh_set_hero_bind(gHeroID);

	// Eventos
	 // SET THE LIFE OF THE DISK 
	set_task(0.1, "frieza_disklife", _, _, _, "b");

	//REGISTERS A TOUCH EVENT, WHEN TWO THINGS TOUCH
	register_touch(disk_ent_name, "player", "disk_touch")
}

public plugin_precache() 
{ 
	precache_model(mdisk);
	precache_sound(sdisk); 
	sprite_flash = precache_model(sprite_frieza);
} 
//------------------------------------------------------------------------------------------------
//				Hero INIT and KEY						//
//------------------------------------------------------------------------------------------------ 
public sh_hero_init(id, heroID, mode) 
{ 
	if ( gHeroID == heroID ) {
		switch(mode) {
			case SH_HERO_ADD: {
				gHasFrieza[id] = true;
				gPlayerInCooldown[id] = false
				diskTimer[id] = -1;
				disk[id] = 0;
			}
			case SH_HERO_DROP: {
				gHasFrieza[id] = false
				if ( diskTimer[id] > 0 ) {
					diskTimer[id] = -1
					if( pev_valid(disk[id]) ) 
						decay_effects( disk[id] )
				}
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
} 
 
public sh_hero_key(id, heroid, key) 
{ 
	if ( heroid != gHeroID || !sh_is_inround() ) return;
	if ( !is_user_alive(id) || !gHasFrieza[id] ) return;
    
	if ( key == SH_KEYDOWN ) {
		if( gPlayerInCooldown[id] ) { 
			sh_sound_deny(id) ;
			// frieza_disklife()
			return;
		} 
		
		diskTimer[id] = get_pcvar_num(pcvar_life); //How long the disk can fly
		fire_disk(id); 
		
		new Float:seconds = get_pcvar_float(pcvar_cool)
		if ( seconds > 0.0 ) {
			sh_set_cooldown(id, seconds)
			gPcvarRealCD[id] = seconds
		} 
	}
} 
#if SEND_COOLDOWN
public sendFriezaCooldown(id)
{
	gPcvarRealCD[id] = sh_get_cooldown(id)
	return floatround(gPcvarRealCD[id])
}
#endif
//------------------------------------------------------------------------------------------------
//				Spawn n Death n Admincheck					//
//------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasFrieza[id] ) {
		blocknexttouch[id] 	= false;

		// Para controlar si esta en ronda y tener el cooldown real.
		if ( sh_is_inround() ) {
			if ( gPcvarRealCD[id] > 0.0 ) sh_set_cooldown(id, gPcvarRealCD[id])
			// False = Nace sin cooldowsn, True = Nace con cooldown.
			else gPlayerInCooldown[id] = false
		}
		// if is a new round set cooldown in zero
		else gPlayerInCooldown[id] = false
	}
}
 
public sh_client_death(id) 
{
	if ( gHasFrieza[id] && diskTimer[id] > 0 ) {
		// Para obtener la cantidad real de cooldown que tiene el poder
		gPcvarRealCD[id] = sh_get_cooldown(id)
		diskTimer[id] = -1
		if( pev_valid(disk[id]) ) decay_effects(disk[id])
	}
}
//------------------------------------------------------------------------------------------------
//				Efectos de Frieza Disk						//
//------------------------------------------------------------------------------------------------ 
public frieza_disklife()
{ 
	if ( !sh_is_active() ) return;
	
	for(new id = 1; id <= SH_MAXSLOTS; id++)
	{
		if ( !is_user_alive(id) || is_user_bot(id) ) continue;
		
		if( gHasFrieza[id] )
		{
			if( diskTimer[id] > 0 && pev_valid( disk[id] ) )
			{ 
				new Float: fVelocity[3];
				velocity_by_aim(id, get_pcvar_num(pcvar_speed), fVelocity);
				set_pev(disk[id], pev_velocity, fVelocity);
			} 
			else if( diskTimer[id] == 0 && pev_valid(disk[id]) )
				decay_effects(disk[id])
				
			diskTimer[id]--; 
		} 
	} 
} 

fire_disk(id) 
{
	new Float:fOrigin[3], Float:fVelocity[3];
	pev(id, pev_origin, fOrigin);
	new Float: minBound[3] = {-50.0, -50.0, 0.0};  //sets the minimum bound of entity
	new Float: maxBound[3] = {50.0, 50.0, 0.0};    //sets the maximum bound of entity

	//This will make it so that the disk appears in front of the user
	new Float:viewing_angles[3]
	new distance_from_user = 70
	pev(id, pev_angles, viewing_angles)
	fOrigin[0] += floatcos(viewing_angles[1], degrees) * distance_from_user
	fOrigin[1] += floatsin(viewing_angles[1], degrees) * distance_from_user
	fOrigin[2] += floatsin(-viewing_angles[0], degrees) * distance_from_user

	new NewEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if ( !pev_valid(NewEnt) ) {
		sh_chat_message(id, gHeroID, "Error al crear la bola de la muerte.");
		return;
	}
	set_pev(NewEnt, pev_classname, disk_ent_name); //sets the classname of the entity 
	disk[id] = NewEnt;

	//This tells what the object will look like
	engfunc(EngFunc_SetModel, NewEnt, mdisk); 

	//This will set the origin of the entity 
	engfunc(EngFunc_SetOrigin, NewEnt, fOrigin);
	
	//This will set the movetype of the entity 
	set_pev( NewEnt, pev_movetype, MOVETYPE_NOCLIP); 

	//This makes the entity touchable
	set_pev( NewEnt, pev_solid, SOLID_TRIGGER);

	//This will get the velocity of the entity 
	velocity_by_aim(id, get_pcvar_num(pcvar_speed), fVelocity);

	//Sets the size of the entity
	set_pev( NewEnt, pev_mins, minBound);
	set_pev( NewEnt, pev_maxs, maxBound);

	//Sets who the owner of the entity is
	set_pev( NewEnt, pev_owner, id);

	//This will set the entity in motion 
	set_pev( NewEnt, pev_velocity, fVelocity);

	//This will make the entity have sound.
	emit_sound(NewEnt, CHAN_VOICE, sdisk, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	new lifetime = get_pcvar_num(pcvar_life);

	//This is the trail effects, to learn more about animation effects go to this link
	//http://shero.rocks-hideout.com/forums/viewtopic.php?t=1941
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(22);       //TE_BEAMFOLLOW
	write_short(NewEnt);  //The entity to attach the sprite to
	write_short(sprite_flash);  //sprite's model
	write_byte(lifetime);   //life in 0.1 seconds
	write_byte(20);   //width of sprite
	write_byte(255);  //red
	write_byte(0);    //green
	write_byte(255);  //blue
	write_byte(255);  //brightness
	message_end();
} 

//------------------------------------------------------------------------------------------------
//				Register Touch							//
//------------------------------------------------------------------------------------------------ 
public disk_touch(ent, id) 
{
	if ( !pev_valid(ent) || !pev_valid(id) || !is_user_alive(id) ) return
	
	static classname[32]
	entity_get_string(ent, EV_SZ_classname, classname, 31)
	if(equal(classname, disk_ent_name)) {
		
		static iOwner
		iOwner = entity_get_edict(ent, EV_ENT_owner);
		
		//This is the position where the disk collides 
		static aimvec[3], Float:fAimvec[3];  
		pev(id, pev_origin, fAimvec);
		FVecIVec(fAimvec, aimvec); 
		
		if( is_user_connected(iOwner) && get_user_team(iOwner) != get_user_team(id) ) {
			
			if( blocknexttouch[id] ) return 
			blocknexttouch[id] = true;
			set_task(2.0, "reset_touch", id);
			special_effects(ent, id, aimvec);
		}
	}
}

public reset_touch(id) blocknexttouch[id] = false;
	
special_effects(ent, id, aimvec[3]) //effects for when disk touch
{
	new Float:fVelocity[3], velocity[3];
	pev(ent, pev_velocity, fVelocity);
	FVecIVec(fVelocity, velocity);

	if( is_user_alive(id) ) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(101);  //BLOODSTREAM
		write_coord(aimvec[0]);
		write_coord(aimvec[1]);
		write_coord(aimvec[2]);
		write_coord(velocity[0]);
		write_coord(velocity[1]);
		write_coord(velocity[2]);
		write_byte(95);
		write_byte(100);
		message_end();

		new killer = pev(ent, pev_owner);
		new extradamage
		
		// For check if has the other power
		new noob_id = sh_get_hero_id(gOthers_Heros[0])
		if ( sh_user_has_hero(id, noob_id) ) extradamage = 350;
		else extradamage = get_pcvar_num(pcvar_dmg);
		
		sh_extra_damage(id, killer, extradamage, "Frieza's Energy Disk"); 
		
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(9);  //SPARKS
	write_coord(aimvec[0]);
	write_coord(aimvec[1]);
	write_coord(aimvec[2]);
	message_end();
}

decay_effects(NewEnt)  //removes the entity plus adds a decaying effect
{
	if( pev_valid(NewEnt) ) {
		new Float:origin[3];
		pev(NewEnt, pev_origin, origin);
		
		new ent = SH_MAXSLOTS+1;
		while( (ent = find_ent_by_owner(ent, disk_ent_name, NewEnt)) > 0) { 
			set_pev(ent, pev_flags, FL_KILLME);
			dllfunc(DLLFunc_Think, ent);
		} 
		// engfunc(EngFunc_RemoveEntity, NewEnt);

		//To learn more about animation effects go to this link
		//http://shero.rocks-hideout.com/forums/viewtopic.php?t=1941
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(14) //IMPLOSION
		write_coord(floatround(origin[0]))
		write_coord(floatround(origin[1]))
		write_coord(floatround(origin[2]))
		write_byte(50)
		write_byte(10)
		write_byte(10)
		message_end()
	}
}

/*
	new ent = SH_MAXSLOTS+1;
	while( (ent = find_ent_by_owner(ent, disk_ent_name, NewEnt)) > 0) { 
		set_pev(ent, pev_flags, FL_KILLME);
		dllfunc(DLLFunc_Think, ent);
	}
*/
//------------------------------------------------------------------------------------------------
//				Disconected and Round New					//
//------------------------------------------------------------------------------------------------ 
public client_disconnected(id)
{
	if(gHasFrieza[id] && diskTimer[id] > 0)
		if ( pev_valid(disk[id]) ) decay_effects(disk[id]);
}

public sh_round_end() {
	for (new id=1; id <= SH_MAXSLOTS; id++) 
		if(gHasFrieza[id] && diskTimer[id] > 0)
			if ( pev_valid(disk[id]) ) decay_effects(disk[id]);
}
/*
public sh_round_new()
{
	new ent = engfunc(EngFunc_FindEntityByString, -1, "classname", "disk");
	while( ent ) {
		engfunc(EngFunc_RemoveEntity, ent);
		ent = engfunc(EngFunc_FindEntityByString, -1, "classname", "disk");
	}
}
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
