
/*

// ACE OF KATANAS
aceofkat_level 49	// level
aceofkat_knifespeed 500	// knife speed
aceofkat_hp 3000	// how mount hp give the hero
k_slash_damage 500.0
k_slash_distance 500.0
k_slash_knockback 0.0
k_stab_damage 1200.0
k_stab_distance 500.0
k_stab_knockback 0.0
k_damage_ball 500.0
k_damage_shield 500.0

*/




/**			SETTINGS SECTION  			**/



new g_iCvar[10];

#define  WEAPON_SLASH_DAMAGE 		get_pcvar_float(g_iCvar[0])	
#define  WEAPON_SLASH_DISTANCE 		get_pcvar_float(g_iCvar[1])	
#define  WEAPON_SLASH_KNOCKBACK 	get_pcvar_float(g_iCvar[2])	
#define  WEAPON_STAB_DAMAGE 		get_pcvar_float(g_iCvar[3])	
#define  WEAPON_STAB_DISTANCE 		get_pcvar_float(g_iCvar[4])	
#define  WEAPON_STAB_KNOCKBACK 		get_pcvar_float(g_iCvar[5])	

#define  DAMAGE_BALL			get_pcvar_float(g_iCvar[6])	
#define  KNOCKBACK_SHIELD		 get_pcvar_float(g_iCvar[7])	




 

//#include <amxmodx>
//#include <fakemeta>
//#include <hamsandwich>
//#include <cstrike>
//#include <engine>


#include <superheromod>

#include <xs>


/* ~ [ Weapon Settings ] ~ */
new const WEAPON_REFERENCE[] = "weapon_knife";

new const WEAPON_ANIMATION[] = "knife";
new const WEAPON_MODEL_VIEW[] = "models/ace_v_knife.mdl";
new const WEAPON_MODEL_PLAYER[] = "models/ace_p_knife.mdl";
new const SHIELDMODEL[] = "models/ef_pianogunwave_b.mdl";
new const CANNONMODEL[] = "models/ef_holysword_chargecannon_new.mdl";
new const S_CANNON[] = "holysword_cannon.wav";
new const S_BLAST[] = "holysword_cannon_exp.wav";
new const S_WAVE[] = "holysword_parryattack.wav";

new const WEAPON_SOUNDS[][] =
{
	"weapons/katana_draw.wav", // 0
	"weapons/katana_midslash1.wav", // 1
	"weapons/katana_midslash2.wav", // 2
	"weapons/katana_stap.wav", // 3
	"weapons/katana_stapmiss.wav", // 4
	"weapons/mastercombat_hit1.wav", // 5
	"weapons/mastercombat_wall.wav" // 6
};



#define WEAPON_SLASH_NEXT_ATTACK_HIT 0.4
#define WEAPON_SLASH_NEXT_ATTACK_MISS 0.2



#define WEAPON_STAB_NEXT_ATTACK 32/30.0
#define WEAPON_STAB_HIT_TIME 16/30.0

/* ~ [ TraceLine: Attack Angles ] ~ */
new Float: flAngles_Forward[] =
{ 
	0.0, 
	2.5, -2.5, 5.0, -5.0, 7.5, -7.5, 10.0, -10.0, 12.5, -12.5, 
	15.0, -15.0, 17.5, -17.5, 20.0, -20.0, 22.5, -22.5, 25.0, -25.0
};

/* ~ [ Weapon Animations ] ~ */
#define WEAPON_ANIM_IDLE_TIME 120/15.0
#define WEAPON_ANIM_DRAW_TIME 46/30.0
#define WEAPON_ANIM_STAB_TIME 51/30.0
#define WEAPON_ANIM_SLASH_TIME 46/30.0

#define WEAPON_ANIM_IDLE 0
#define WEAPON_ANIM_DRAW 3
#define WEAPON_ANIM_STAB 4
#define WEAPON_ANIM_SLASH 6

/* ~ [ Params ] ~ */
new gl_iszAllocString_KnifeUID;
new gl_iszModelIndex_BloodSpray,
	gl_iszModelIndex_BloodDrop;


/* ~ [ Macroses ] ~ */
#define DONT_BLEED -1
#define PDATA_SAFE 2
#define ACT_RANGE_ATTACK1 28

#define IsValidEntity(%1) (pev_valid(%1) == PDATA_SAFE)
#define get_WeaponState(%1) (get_pdata_int(%1, m_iWeaponState, linux_diff_weapon))
#define set_WeaponState(%1,%2) (set_pdata_int(%1, m_iWeaponState, %2, linux_diff_weapon))

enum _: eWeaponState
{
	WPNSTATE_NONE = 0,
	WPNSTATE_STAB_HIT
};

/* ~ [ Offsets ] ~ */
// Linux extra offsets
#define linux_diff_animating 4
#define linux_diff_weapon 4
#define linux_diff_player 5

// CBaseAnimating
#define m_flFrameRate 36
#define m_flGroundSpeed 37
#define m_flLastEventCheck 38
#define m_fSequenceFinished 39
#define m_fSequenceLoops 40

// CBasePlayerItem
#define m_pPlayer 41
#define m_iId 43

// CBasePlayerWeapon
#define m_flNextPrimaryAttack 46
#define m_flNextSecondaryAttack 47
#define m_flTimeWeaponIdle 48
#define m_iWeaponState 74

// CBaseMonster
#define m_Activity 73
#define m_IdealActivity 74
#define m_LastHitGroup 75
#define m_flNextAttack 83

// CBasePlayer
#define m_flPainShock 108
#define m_flLastAttackTime 220
#define m_rpgPlayerItems 367
#define m_pActiveItem 373
#define m_szAnimExtention 492

new Float:g_iTime[33],g_Exp;
new Float:g_iTime2[33];

new gHeroID
new gHeroName[] = "Ace of Katanas"
new bool:gHasAceKatana[SH_MAXSLOTS+1]

// new g_iHaveKata[33];

/* ~ [ AMX Mod X ] ~ */
public plugin_init()
{
	register_plugin("Knife: Katana", "1.1", "xUnicorn");

	g_iCvar[0] = register_cvar("k_slash_damage","500.0");
	g_iCvar[1] = register_cvar("k_slash_distance","500.0");
	g_iCvar[2] = register_cvar("k_slash_knockback","0.0");
	g_iCvar[3] = register_cvar("k_stab_damage","1200.0");
	g_iCvar[4] = register_cvar("k_stab_distance","500.0");
	g_iCvar[5] = register_cvar("k_stab_knockback","0.0");
	g_iCvar[6] = register_cvar("k_damage_ball","500.0");
	g_iCvar[7] = register_cvar("k_damage_shield","500.0");

	new pcvarLevel 	= register_cvar("aceofkat_level", "49")
	new pcvarSpeed 	= register_cvar("aceofkat_knifespeed", "500")
	new pcvarHealth	= register_cvar("aceofkat_hp", "3000")
	
	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Get Dual Katanas.", "Katana Knife")
	sh_set_hero_speed(gHeroID, pcvarSpeed, {CSW_KNIFE}, 1)
	sh_set_hero_hpap(gHeroID, pcvarHealth)
	
	// Events
	register_event("CurWeapon", "EV_CurWeapon", "be", "1=1");

	// Forwards
	register_forward(FM_UpdateClientData, 	"FM_Hook_UpdateClientData_Post", true);
	register_forward(FM_CmdStart,"fw_CmdStart");
	register_touch("nv_holy_cannon", "*", "Fw_Holy_Touch");
	
	
	// Weapon
	RegisterHam(Ham_Weapon_WeaponIdle, 		WEAPON_REFERENCE, 	"CKnife__Idle_Pre", false);
	RegisterHam(Ham_Item_Deploy, 			WEAPON_REFERENCE, 	"CKnife__Deploy_Post", true);
	RegisterHam(Ham_Item_Holster, 			WEAPON_REFERENCE, 	"CKnife__Holster_Post", true);
	RegisterHam(Ham_Item_PostFrame, 		WEAPON_REFERENCE, 	"CKnife__PostFrame_Pre", false);
	RegisterHam(Ham_Weapon_PrimaryAttack, 	WEAPON_REFERENCE, 	"CKnife__PrimaryAttack_Pre", false);
	RegisterHam(Ham_Weapon_SecondaryAttack,	WEAPON_REFERENCE, 	"CKnife__SecondaryAttack_Pre", false);
	
	//register_clcmd("say /kata","_give_user_katana");
}

public plugin_precache()
{
	new i;

	
	// Precache models
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_VIEW);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_PLAYER);
	engfunc(EngFunc_PrecacheModel, SHIELDMODEL);
	engfunc(EngFunc_PrecacheModel, CANNONMODEL);

	precache_sound(S_CANNON);
	precache_sound(S_BLAST);
	precache_sound(S_WAVE);
	// Precache sounds
	for(i = 0; i < sizeof WEAPON_SOUNDS; i++)
		engfunc(EngFunc_PrecacheSound, WEAPON_SOUNDS[i]);

	// Alloc String
	gl_iszAllocString_KnifeUID = engfunc(EngFunc_AllocString, "knife_katana");
	
	// Model Index
	g_Exp = engfunc(EngFunc_PrecacheModel, "sprites/ef_junkgun_green.spr");
	gl_iszModelIndex_BloodSpray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr");
	gl_iszModelIndex_BloodDrop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr");
}
/*
public plugin_natives()
{
	register_native("zp_get_user_katana", "_get_user_katana", 1);
	register_native("zp_give_user_katana", "_give_user_katana", 1);
	register_native("zp_delete_user_katana", "_delete_user_katana", 1);
}
*/

public sh_hero_init(id, heroID, mode)
{
	if ( heroID == gHeroID )
	{
		// log_amx("Debug - Player Has Katana Knife in nvault");
		
		switch(mode) {
			case SH_HERO_ADD: 
			{
				gHasAceKatana[id] = true
				// _give_user_katana(id);
				CKnife__SwitchModel(id)
				// log_amx("Debug - Katana Added");

			}
			case SH_HERO_DROP: {
				// _delete_user_katana(id);
				gHasAceKatana[id] = false
				// log_amx("Debug - Katana Removed");
			}
		}
		
		sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
	}
}
/*
public _get_user_katana(const pPlayer)
{
	
	return (g_iHaveKata[pPlayer]) ? true : false;
}

public _give_user_katana(const pPlayer)
{
	if(!is_user_alive(pPlayer)) return false;

	g_iHaveKata[pPlayer] = 1;
	
	EV_CurWeapon(pPlayer);
	
	return true;
}

public _delete_user_katana(const pPlayer)
{
	g_iHaveKata[pPlayer] = 0;
}
*/

public fw_CmdStart(id,uc_handle,seed)
{
	if(is_user_alive(id))
	{
		new iButtons = get_uc(uc_handle,UC_Buttons);
		new oldbuttons = pev(id, pev_oldbuttons);
		
		
		// if(get_user_weapon(id) == CSW_KNIFE && _get_user_katana(id))
		if(get_user_weapon(id) == CSW_KNIFE && gHasAceKatana[id])
		{
				if(iButtons & IN_ATTACK)
				{
					if (!g_iTime[id] )
					{
						g_iTime[id] = get_gametime();
					}
					
				}
				if(oldbuttons & IN_ATTACK && !(iButtons & IN_ATTACK))
				{
					if(get_gametime() - g_iTime[id] >= 1.0 )
					{
						
						Create_Holy(id);
						UTIL_SendWeaponAnim(id,4);
					}
					g_iTime[id] = 0.0;
				}
				
				if(oldbuttons & IN_ATTACK2 && !(iButtons & IN_ATTACK2) && g_iTime2[id] < get_gametime())
				{
					g_iTime2[id] = get_gametime() + 5.0;
					
					new i;
					for(i = 0; i<= get_maxplayers();i++)
					{
						if(is_user_in_sphere(id,i,200.0))
						{
							
							ExecuteHamB(Ham_TakeDamage, i, id, id, KNOCKBACK_SHIELD, DMG_ALWAYSGIB);
							//Do_KnockBack(id,i,KNOCKBACK_SHIELD);
						}
					}
					
					Effect_Shield(id);
				}
			}
		}
}

public Fw_Holy_Touch(ent,Touch)
{
	if(is_valid_ent(ent))
	{
		static Float:Origin[3];
		new id = pev(ent,pev_iuser1);
		pev(ent, pev_origin, Origin);
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, Origin[0]);
		engfunc(EngFunc_WriteCoord, Origin[1]);
		engfunc(EngFunc_WriteCoord, Origin[2]);
		write_short(g_Exp) ;
		write_byte(9);
		write_byte(15);
		write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);
		message_end();
	
		emit_sound(ent, CHAN_WEAPON, S_BLAST, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		new i = -1;
		while((i = find_ent_in_sphere(i, Origin, 200.0)) != 0) 
		{	
			if(is_user_alive(i))
			{
				if(cs_get_user_team(i) != cs_get_user_team(id))
				{
					ExecuteHamB(Ham_TakeDamage, i, ent, id, DAMAGE_BALL, DMG_ALWAYSGIB);
				}
			}	
		}
		remove_entity(ent);
	}
}

/* ~ [ Events ] ~ */
public EV_CurWeapon(const pPlayer)
{
	if(!is_user_alive(pPlayer)) return;
	
	// && _get_user_katana(id))
	if(get_user_weapon(pPlayer) == CSW_KNIFE && gHasAceKatana[pPlayer])
		CKnife__SwitchModel(pPlayer);
}

/* ~ [ Fakemeta ] ~ */
public FM_Hook_UpdateClientData_Post(const pPlayer, const iSendWeapons, const CD_Handle)
{
	if(!is_user_alive(pPlayer)) return;
	
	// && _get_user_katana(id))
	if(get_user_weapon(pPlayer) == CSW_KNIFE && gHasAceKatana[pPlayer])
		set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001);
}

/* ~ [ HamSandwich ] ~ */
public CKnife__Idle_Pre(const pItem)
{
	if(!pev_valid(pItem)) return HAM_IGNORED;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	// && !_get_user_katana(id))
	if(!gHasAceKatana[pPlayer]) return HAM_IGNORED;
	
	if(get_pdata_float(pItem, m_flTimeWeaponIdle, linux_diff_weapon) > 0.0) return HAM_IGNORED;


	UTIL_SendWeaponAnim(pPlayer, WEAPON_ANIM_IDLE);
	set_pdata_float(pItem, m_flTimeWeaponIdle, WEAPON_ANIM_IDLE_TIME, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

public CKnife__Deploy_Post(const pItem)
{
	if(!pev_valid(pItem)) return;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	if(!gHasAceKatana[pPlayer]) return;

	CKnife__SwitchModel(pPlayer);
	UTIL_SendWeaponAnim(pPlayer, WEAPON_ANIM_DRAW);
	emit_sound(pPlayer, CHAN_WEAPON, WEAPON_SOUNDS[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	set_task(0.5,"DelaySwitchAgain",pPlayer+7777);
	
	set_pdata_float(pItem, m_flTimeWeaponIdle, WEAPON_ANIM_DRAW_TIME, linux_diff_weapon);
	set_pdata_float(pItem, m_flNextPrimaryAttack, 0.8, linux_diff_weapon);
	set_pdata_float(pItem, m_flNextSecondaryAttack, 0.8, linux_diff_weapon);
}


public DelaySwitchAgain(id)
{
	id -= 7777;
	if(is_user_alive(id))
		CKnife__SwitchModel(id);
}
public CKnife__Holster_Post(const pItem)
{
	if(!pev_valid(pItem)) return;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	if(!gHasAceKatana[pPlayer]) return;

	set_pdata_float(pItem, m_flNextPrimaryAttack, 0.0, linux_diff_weapon);
	set_pdata_float(pItem, m_flNextSecondaryAttack, 0.0, linux_diff_weapon);
	set_pdata_float(pItem, m_flTimeWeaponIdle, 0.0, linux_diff_weapon);
	set_pdata_float(pPlayer, m_flNextAttack, 0.0, linux_diff_player);
}

public CKnife__PostFrame_Pre(const pItem)
{
	if(!pev_valid(pItem)) return HAM_IGNORED;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	if(!gHasAceKatana[pPlayer]) return HAM_IGNORED;

	switch(get_WeaponState(pItem))
	{
		case WPNSTATE_NONE: return HAM_IGNORED;
		case WPNSTATE_STAB_HIT:
		{
			static Float: flNextAttackTime; flNextAttackTime = (WEAPON_STAB_NEXT_ATTACK - WEAPON_STAB_HIT_TIME);
			UTIL_FakeTraceLine(pPlayer, pItem, WEAPON_STAB_DISTANCE, WEAPON_STAB_DAMAGE, WEAPON_STAB_KNOCKBACK, flAngles_Forward, sizeof flAngles_Forward, true);

			set_WeaponState(pItem, WPNSTATE_NONE);
			set_pdata_float(pPlayer, m_flNextAttack, flNextAttackTime, linux_diff_player);
			set_pdata_float(pItem, m_flNextPrimaryAttack, flNextAttackTime, linux_diff_weapon);
			set_pdata_float(pItem, m_flNextSecondaryAttack, flNextAttackTime, linux_diff_weapon);
		}
	}

	return HAM_IGNORED;
}

public CKnife__PrimaryAttack_Pre(const pItem)
{
	if(!pev_valid(pItem)) return HAM_IGNORED;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	if(!gHasAceKatana[pPlayer]) return HAM_IGNORED;
	
	new Float: flNextAttackTime, Float: flIdleTime, iSound, iHit;
	iHit = UTIL_FakeTraceLine(pPlayer, pItem, WEAPON_SLASH_DISTANCE, WEAPON_SLASH_DAMAGE, WEAPON_SLASH_KNOCKBACK, flAngles_Forward, 7, true);
	static iAnim; iAnim = !iAnim;
	iSound = iAnim ? 2 : 1;
	flNextAttackTime = iHit ? WEAPON_SLASH_NEXT_ATTACK_HIT : WEAPON_SLASH_NEXT_ATTACK_MISS;
	flIdleTime = WEAPON_ANIM_SLASH_TIME;

	UTIL_SendWeaponAnim(pPlayer, WEAPON_ANIM_SLASH + iAnim);
	emit_sound(pPlayer, CHAN_WEAPON, WEAPON_SOUNDS[iSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	// Player animation
	static szAnimation[64];
	formatex(szAnimation, charsmax(szAnimation), pev(pPlayer, pev_flags) & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", WEAPON_ANIMATION);
	UTIL_PlayerAnimation(pPlayer, szAnimation);

	set_pdata_float(pPlayer, m_flNextAttack, flNextAttackTime, linux_diff_player);
	set_pdata_float(pItem, m_flNextPrimaryAttack, flNextAttackTime, linux_diff_weapon);
	set_pdata_float(pItem, m_flNextSecondaryAttack, flNextAttackTime, linux_diff_weapon);
	set_pdata_float(pItem, m_flTimeWeaponIdle, flIdleTime, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

public CKnife__SecondaryAttack_Pre(const pItem)
{
	if(!pev_valid(pItem)) return HAM_IGNORED;
	
	static pPlayer; pPlayer = get_pdata_cbase(pItem, m_pPlayer, linux_diff_weapon);
	
	if(!gHasAceKatana[pPlayer]) return HAM_IGNORED;
	
	new Float: flNextAttackTime, Float: flIdleTime, iAnim, iSound;
	iAnim = WEAPON_ANIM_STAB;
	iSound = 4;
	flNextAttackTime = WEAPON_STAB_HIT_TIME;
	flIdleTime = WEAPON_ANIM_STAB_TIME;

	set_WeaponState(pItem, WPNSTATE_STAB_HIT);

	UTIL_SendWeaponAnim(pPlayer, iAnim);
	emit_sound(pPlayer, CHAN_WEAPON, WEAPON_SOUNDS[iSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	// Player animation
	static szAnimation[64];
	formatex(szAnimation, charsmax(szAnimation), pev(pPlayer, pev_flags) & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", WEAPON_ANIMATION);
	UTIL_PlayerAnimation(pPlayer, szAnimation);

	set_pdata_float(pPlayer, m_flNextAttack, flNextAttackTime, linux_diff_player);
	set_pdata_float(pItem, m_flNextPrimaryAttack, flNextAttackTime, linux_diff_weapon);
	set_pdata_float(pItem, m_flNextSecondaryAttack, flNextAttackTime, linux_diff_weapon);
	set_pdata_float(pItem, m_flTimeWeaponIdle, flIdleTime, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

/* ~ [ Other ] ~ */
public CKnife__SwitchModel(const pPlayer)
{
	set_pev(pPlayer, pev_viewmodel2, WEAPON_MODEL_VIEW);
	set_pev(pPlayer, pev_weaponmodel2, WEAPON_MODEL_PLAYER);

	set_pdata_string(pPlayer, m_szAnimExtention * 4, WEAPON_ANIMATION, -1, linux_diff_player * linux_diff_animating);
}

/* ~ [ Stock's ] ~ */
stock UTIL_SendWeaponAnim(const pPlayer, const iAnim)
{
	set_pev(pPlayer, pev_weaponanim, iAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, pPlayer);
	write_byte(iAnim);
	write_byte(0);
	message_end();
}

stock UTIL_PlayerAnimation(const pPlayer, const szAnim[], const Float: flFrame = 1.0)
{
	new iAnimDesired, Float: flFrameRate, Float: flGroundSpeed, bool: bLoops;
	if((iAnimDesired = lookup_sequence(pPlayer, szAnim, flFrameRate, bLoops, flGroundSpeed)) == -1)
		iAnimDesired = 0;

	set_entity_anim(pPlayer, iAnimDesired, flFrame);
	
	set_pdata_int(pPlayer, m_fSequenceLoops, bLoops, linux_diff_animating);
	set_pdata_int(pPlayer, m_fSequenceFinished, 0, linux_diff_animating);
	
	set_pdata_float(pPlayer, m_flFrameRate, flFrameRate, linux_diff_animating);
	set_pdata_float(pPlayer, m_flGroundSpeed, flGroundSpeed, linux_diff_animating);
	set_pdata_float(pPlayer, m_flLastEventCheck, get_gametime(), linux_diff_animating);
	
	set_pdata_int(pPlayer, m_Activity, ACT_RANGE_ATTACK1, linux_diff_player);
	set_pdata_int(pPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, linux_diff_player);
	set_pdata_float(pPlayer, m_flLastAttackTime, get_gametime(), linux_diff_player);
}

stock set_entity_anim(const iEntity, const iSequence, const Float: flFrame)
{
	set_pev(iEntity, pev_frame, flFrame);
	set_pev(iEntity, pev_framerate, 1.0);
	set_pev(iEntity, pev_animtime, get_gametime());
	set_pev(iEntity, pev_sequence, iSequence);
}

stock UTIL_FakeTraceLine(const pAttacker, const pInflictor, const Float: flDistance, const Float: flDamage, const Float: flKnockBack, const Float: flSendAngles[], const iSendAngles, const bool: bDoDamage)
{
	enum
	{
		SLASH_HIT_NONE = 0,
		SLASH_HIT_WORLD,
		SLASH_HIT_ENTITY
	};

	new Float: vecOrigin[3]; pev(pAttacker, pev_origin, vecOrigin);
	new Float: vecAngles[3]; pev(pAttacker, pev_v_angle, vecAngles);
	new Float: vecViewOfs[3]; pev(pAttacker, pev_view_ofs, vecViewOfs);

	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);

	new Float: vecForward[3], Float: vecRight[3], Float: vecUp[3];
	engfunc(EngFunc_AngleVectors, vecAngles, vecForward, vecRight, vecUp);
		
	new iTrace = create_tr2();

	new Float: flTan, Float: flMul;
	new iHitList[10], iHitCount = 0;

	new Float: vecEnd[3];
	new Float: flFraction;
	new pHit, pHitEntity = SLASH_HIT_NONE;
	new iHitResult = SLASH_HIT_NONE;

	for(new i; i < iSendAngles; i++)
	{
		flTan = floattan(flSendAngles[i], degrees);

		vecEnd[0] = (vecForward[0] * flDistance) + (vecRight[0] * flTan * flDistance) + vecUp[0];
		vecEnd[1] = (vecForward[1] * flDistance) + (vecRight[1] * flTan * flDistance) + vecUp[1];
		vecEnd[2] = (vecForward[2] * flDistance) + (vecRight[2] * flTan * flDistance) + vecUp[2];
			
		flMul = (flDistance/vector_length(vecEnd));
		xs_vec_mul_scalar(vecEnd, flMul, vecEnd);
		xs_vec_add(vecEnd, vecOrigin, vecEnd);

		engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, DONT_IGNORE_MONSTERS, pAttacker, iTrace);
		get_tr2(iTrace, TR_flFraction, flFraction);

		if(flFraction == 1.0)
		{
			engfunc(EngFunc_TraceHull, vecOrigin, vecEnd, HULL_HEAD, pAttacker, iTrace);
			get_tr2(iTrace, TR_flFraction, flFraction);
		
			engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, DONT_IGNORE_MONSTERS, pAttacker, iTrace);
			pHit = get_tr2(iTrace, TR_pHit);
		}
		else pHit = get_tr2(iTrace, TR_pHit);

		if(pHit == pAttacker) continue;

		static bool: bStop; bStop = false;
		for(new iHit = 0; iHit < iHitCount; iHit++)
		{
			if(iHitList[iHit] == pHit)
			{
				bStop = true;
				break;
			}
		}
		if(bStop == true) continue;

		iHitList[iHitCount] = pHit;
		iHitCount++;

		if(flFraction != 1.0)
			if(!iHitResult) iHitResult = SLASH_HIT_WORLD;

		static Float: vecEndPos[3]; get_tr2(iTrace, TR_vecEndPos, vecEndPos);
		if(pHit > 0 && pHitEntity != pHit)
		{
			if(bDoDamage)
			{
				if(pev(pHit, pev_solid) == SOLID_BSP && !(pev(pHit, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY))
				{
					ExecuteHamB(Ham_TakeDamage, pHit, pInflictor, pAttacker, flDamage, DMG_NEVERGIB|DMG_CLUB);
				}
				else
				{
					UTIL_FakeTraceAttack(pHit, pInflictor, pAttacker, flDamage, vecForward, iTrace, DMG_NEVERGIB|DMG_CLUB);
					if(flKnockBack > 0.0) UTIL_FakeKnockBack(pHit, vecForward, flKnockBack);
				}
			}

			iHitResult = SLASH_HIT_ENTITY;
			pHitEntity = pHit;
		}
	}

	free_tr2(iTrace);

	static iSound; iSound = -1;
	switch(iHitResult)
	{
		case SLASH_HIT_WORLD: iSound = 6;
		case SLASH_HIT_ENTITY: iSound = 5;
	}

	if(bDoDamage && iSound != -1)
		emit_sound(pAttacker, CHAN_ITEM, WEAPON_SOUNDS[iSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return iHitResult == SLASH_HIT_NONE ? false : true;
}

stock UTIL_FakeTraceAttack(const pVictim, const pInflictor, const pAttacker, Float: flDamage, const Float: vecDirection[3], const pTrace, iBitsDamageType)
{
	if(pev(pVictim, pev_takedamage) == DAMAGE_NO) return;
	if(is_user_alive(pVictim))
	{
		if(cs_get_user_team(pVictim) == cs_get_user_team(pAttacker))
			return;
	}

	static Float: vecEndPos[3]; get_tr2(pTrace, TR_vecEndPos, vecEndPos);
	static iHitGroup; iHitGroup = get_tr2(pTrace, TR_iHitgroup);
	static Float: vecPunchAngle[3];
	switch(iHitGroup)
	{
		case HIT_HEAD:
		{
			flDamage *= 4.0;
			vecPunchAngle[0] = flDamage * -0.5;
			if(vecPunchAngle[0] < -12.0) vecPunchAngle[0] = -12.0;

			vecPunchAngle[2] = flDamage * random_float(-1.0, 1.0);
			if(vecPunchAngle[2] < -9.0) vecPunchAngle[2] = -9.0;
			else if(vecPunchAngle[2] > 9.0) vecPunchAngle[2] = 9.0;

			set_pev(pVictim, pev_punchangle, vecPunchAngle);
		}
		case HIT_CHEST:
		{
			flDamage *= 1.0;
			vecPunchAngle[0] = flDamage * -0.1;
			if(vecPunchAngle[0] < -4.0) vecPunchAngle[0] = -4.0;

			set_pev(pVictim, pev_punchangle, vecPunchAngle);
		}
		case HIT_STOMACH:
		{
			flDamage *= 1.25;
			vecPunchAngle[0] = flDamage * -0.1;
			if(vecPunchAngle[0] < -4.0) vecPunchAngle[0] = -4.0;

			set_pev(pVictim, pev_punchangle, vecPunchAngle);
		}
		case HIT_LEFTLEG, HIT_RIGHTLEG: flDamage *= 0.75;
	}

	set_pdata_int(pVictim, m_LastHitGroup, iHitGroup, linux_diff_player);
	ExecuteHamB(Ham_TakeDamage, pVictim, pInflictor, pAttacker, flDamage, iBitsDamageType);

	static iBloodColor;
	if((iBloodColor = ExecuteHamB(Ham_BloodColor, pVictim)) != DONT_BLEED)
	{
		xs_vec_sub_scaled(vecEndPos, vecDirection, 4.0, vecEndPos);
		UTIL_BloodDrips(vecEndPos, iBloodColor, floatround(flDamage));
		ExecuteHamB(Ham_TraceBleed, pVictim, flDamage, vecDirection, pTrace, iBitsDamageType);
	}
}

public Create_Holy(id)
{
	new ent, Float:Origin[3], Float:Angles[3], Float:Velocity[3];
	
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	Stock_Get_Postion(id, 40.0, 10.0, -10.0, Origin);
	pev(id, pev_v_angle, Angles);
	
	Angles[0] *= -1.0;
	
	set_pev(ent, pev_origin, Origin);
	set_pev(ent, pev_angles, Angles);
	set_pev(ent, pev_v_angle, Angles);
	set_pev(ent, pev_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	set_pev(ent, pev_classname, "nv_holy_cannon");
	set_pev(ent, pev_iuser1, id);
	set_pev(ent, pev_light_level, 180);
	set_pev(ent, pev_rendermode, kRenderTransAdd);
	set_pev(ent, pev_renderamt, 255.0);
	engfunc(EngFunc_SetModel, ent, CANNONMODEL);
	engfunc(EngFunc_SetSize,  ent, {2.0,2.0,2.0}, {2.0,2.0,2.0});
	
	emit_sound(ent, CHAN_WEAPON, S_CANNON, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	velocity_by_aim(id, 1000, Velocity);
	set_pev(ent, pev_velocity, Velocity);
	set_anim(ent,0);
}

public Effect_Shield(id)
{
	new Float:origin[3];
	pev(id, pev_origin, origin);

	if(pev(id, pev_flags) & FL_DUCKING) 
		Stock_Get_Postion(id, 15.0, 5.0, -30.0, origin);
	else 
		Stock_Get_Postion(id, 15.0, 5.0, -40.0, origin);

	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	set_pev(iEnt, pev_classname, "effect_shield_holy");
	set_pev(iEnt, pev_origin, origin);
	set_pev(iEnt, pev_movetype, MOVETYPE_NONE);
	
	set_pev(iEnt, pev_solid, SOLID_NOT);
	set_pev(iEnt, pev_light_level, 180);
	set_pev(iEnt, pev_rendermode, kRenderTransAdd);
	set_pev(iEnt, pev_renderamt, 255.0);
	engfunc(EngFunc_SetModel, iEnt, SHIELDMODEL);
	engfunc(EngFunc_SetSize, iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	dllfunc(DLLFunc_Spawn, iEnt);
	set_pev(iEnt, pev_iuser1, id);
	set_pev(iEnt, pev_sequence, 0);
	set_pev(iEnt, pev_animtime, halflife_time());
	set_pev(iEnt, pev_framerate, 0.3);
	emit_sound(iEnt, CHAN_WEAPON, S_WAVE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	set_task(1.5,"Remove_Valid",iEnt);
	
}

public Remove_Valid(ent)
{
	if(is_valid_ent(ent))	
		remove_entity(ent);
}

stock Stock_Get_Postion(id, Float:depan, Float:kanan, Float:atas, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3];
	pev(id, pev_origin, vOrigin);
	pev(id, pev_view_ofs,vUp);
	xs_vec_add(vOrigin,vUp,vOrigin);
	pev(id, pev_v_angle, vAngle);
	
	engfunc(EngFunc_AngleVectors, vAngle, vForward, vRight, vUp);
	
	vStart[0] = vOrigin[0] + vForward[0] * depan + vRight[0] * kanan + vUp[0] * atas;
	vStart[1] = vOrigin[1] + vForward[1] * depan + vRight[1] * kanan + vUp[1] * atas;
	vStart[2] = vOrigin[2] + vForward[2] * depan + vRight[2] * kanan + vUp[2] * atas;
}


stock set_anim(ent, sequence) 
{
	if(is_valid_ent(ent))
	{
		set_pev(ent, pev_sequence, sequence);
		set_pev(ent, pev_animtime, halflife_time());
		set_pev(ent, pev_framerate, 1.0);
	}
}
stock UTIL_FakeKnockBack(const pVictim, const Float: vecDirection[3], Float: flKnockBack) 
{
	if(!is_user_alive(pVictim)) return false;

	set_pdata_float(pVictim, m_flPainShock, 1.0, linux_diff_player);

	static Float: vecVelocity[3]; pev(pVictim, pev_velocity, vecVelocity);
	if(pev(pVictim, pev_flags) & FL_DUCKING) flKnockBack *= 0.7;

	vecVelocity[0] = vecDirection[0] * flKnockBack;
	vecVelocity[1] = vecDirection[1] * flKnockBack;
	vecVelocity[2] = 200.0;

	set_pev(pVictim, pev_velocity, vecVelocity);
	return true;
}


stock Do_KnockBack(id, iVic, Float:ikb)
{
	if(iVic > 32) return;
	
	new Float:vAttacker[3], Float:vVictim[3], Float:vVelocity[3], flags;
	pev(id, pev_origin, vAttacker);
	pev(iVic, pev_origin, vVictim);
	vAttacker[2] = vVictim[2] = 0.0;
	flags = pev(id, pev_flags);
	
	xs_vec_sub(vVictim, vAttacker, vVictim);
	new Float:fDistance;
	fDistance = xs_vec_len(vVictim);
	xs_vec_mul_scalar(vVictim, 1 / fDistance, vVictim);
	
	pev(iVic, pev_velocity, vVelocity);
	xs_vec_mul_scalar(vVictim, ikb, vVictim);
	xs_vec_mul_scalar(vVictim, 50.0, vVictim);
	vVictim[2] = xs_vec_len(vVictim) * 0.15;
	
	if(flags &~ FL_ONGROUND)
	{
		xs_vec_mul_scalar(vVictim, 1.2, vVictim);
		vVictim[2] *= 0.4;
	}
	if(xs_vec_len(vVictim) > xs_vec_len(vVelocity)) set_pev(iVic, pev_velocity, vVictim);
}
public is_user_in_sphere(id,enemy,Float:radius)
{
	if(is_user_alive(id) && is_user_alive(enemy) && id != enemy)
	{
		new Float:Distance;
		Distance = entity_range(id, enemy);
	
		if(Distance <= radius)
			return true;
	}
	return false;
	
}
public UTIL_BloodDrips(const Float: vecOrigin[3], const iColor, iAmount)
{
	if(iAmount > 255) iAmount = 255;
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(gl_iszModelIndex_BloodSpray);
	write_short(gl_iszModelIndex_BloodDrop);
	write_byte(iColor);
	write_byte(min(max(3, iAmount / 10), 16));
	message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2057\\ f0\\ fs16 \n\\ par }
*/
