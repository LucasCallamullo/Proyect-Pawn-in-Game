/* Plugin generated by AMXX-Studio */
#define ACTIVE_POWERS_INFO 1	// 1 - Enabled, 0 - Disabled

#include <superheromod> 

#if ACTIVE_POWERS_INFO
	new BHForward
	new BHCooldown[SH_MAXSLOTS+1]
	
	new DanimothForward
	new DanimothCooldown[SH_MAXSLOTS+1]
	
	new VaderForward
	new VaderCooldown[SH_MAXSLOTS+1]
	
	new PalpatineForward
	new PalpatineCooldown[SH_MAXSLOTS+1]
	
	new FriezaForward
	new FriezaCooldown[SH_MAXSLOTS+1]

	new GokuKTForward 
	new GokuKTCooldown[SH_MAXSLOTS+1]
	
	new InvisWomanForward 
	new InvisWomanCooldown[SH_MAXSLOTS+1]
	
	new LanternForward 
	new LanternCooldown[SH_MAXSLOTS+1]

	new MSharinganForward
	new MSharinganCooldown[SH_MAXSLOTS+1]
	
	//new NarutoscjForward
	//new NarutoscjCooldown[SH_MAXSLOTS+1]
	
	new SandmanForward
	new SandmanCooldown[SH_MAXSLOTS+1]
	
	new ShacoForward 
	new ShacoCooldown[SH_MAXSLOTS+1]
	
	new ShadowcatForward 
	new ShadowcatCooldown[SH_MAXSLOTS+1]
	// Sharknado
	new JawsForward
	new JawsCooldown[SH_MAXSLOTS+1]
	
	new SubZeroForward
	new SubZeroCooldown[SH_MAXSLOTS+1]
	
	new SSJGohanForward
	new SSJGohanCooldown[SH_MAXSLOTS+1]
	
	new T800Forward
	new T800Cooldown[SH_MAXSLOTS+1]
	
	new TranzaForward
	new TranzaCooldown[SH_MAXSLOTS+1]
	
	new VegetaForward
	new VegetaCooldown[SH_MAXSLOTS+1]
	
	new WonWomanForward
	new WonWomanCooldown[SH_MAXSLOTS+1]
	
	new YadratForward
	new YadratCooldown[SH_MAXSLOTS+1]
	
	new YodaForward
	new YodaCooldown[SH_MAXSLOTS+1]
	
	// new YodaWisForward
	// new YodaWisCooldown[SH_MAXSLOTS+1]
	
	new ZeusForward
	new ZeusCooldown[SH_MAXSLOTS+1]
	
	new DrStrangeForward
	new DrStrangeCooldown[SH_MAXSLOTS+1]
	
	new MeteorixForward
	new MeteorixCooldown[SH_MAXSLOTS+1]
	
	new NeoForward
	new NeoCooldown[SH_MAXSLOTS+1]
#endif

// para saber que heroes tiene
new bhID, danimothID, vaderID, palpatineID, friezaID
new bool:gHasBHPower[SH_MAXSLOTS+1]		// Black Hole
new bool:gHasDanimoth[SH_MAXSLOTS+1]		// Danimoth X
new bool:g_hasVader[SH_MAXSLOTS+1]		// Darth Vader
new bool:g_haspalpatinePowers[SH_MAXSLOTS+1]	// Emperador Palpatine
new bool:gHasFrieza[SH_MAXSLOTS+1]		// Freezer

new gokuKTid, inviswomanID, MsharinganID, narutoscjID, sandmanID 
new bool:HasGokuKT[SH_MAXSLOTS+1]		// GokuKT
new bool:gHasInvisWomanPower[SH_MAXSLOTS+1]	// Invis Woman
new bool:HasMsharingan[SH_MAXSLOTS+1]		// M Sharingan
new bool:gHasNaruto[SH_MAXSLOTS+1]		// Naruto SCJ
new bool:HasSandman[SH_MAXSLOTS+1]		// Sandman

new shadowID, jawsID, ssjGohanID, t800ID, vegetaID
new bool:gHasShadowcat[SH_MAXSLOTS+1]		// Shadowcat
new bool:g_hasJawsPower[SH_MAXSLOTS+1]		// Jaws - Sharknado
new bool:g_hasSSJGohan[SH_MAXSLOTS+1]		// SSJ Gohan
new bool:gHasT800Power[SH_MAXSLOTS+1]		// T-800
new bool:gHasVegetaPower[SH_MAXSLOTS+1]		// Vegeta

new wonwomanID, yadratID, yodaID, zeusID
new bool:gHasWonWomanPowers[SH_MAXSLOTS+1]	// Wonder Woman
new bool:g_hasFirestarterPower[SH_MAXSLOTS+1]	// Yadrat
new bool:gHasYodaPower[SH_MAXSLOTS+1]		// Yoda
// new bool:gHasYodaWisePower[SH_MAXSLOTS+1]	// Yoda Wisdow	/ yodawisID
new bool:gHasStormPower[SH_MAXSLOTS+1]		// Zeus

new lanternID, subzeroID, shacoID, tranzaID
new bool:gHasGreenPower[SH_MAXSLOTS+1]		// Linterna Verde
new bool:g_HasSubZeroPower[SH_MAXSLOTS+1]	// Sub-Zero
new bool:gHasShaco[SH_MAXSLOTS+1]		// Shaco
new bool:gHasWeedMan[SH_MAXSLOTS+1]		// Tranza 

new drstrangeID, meteorixID, neoID
new bool:gHasDrStrangePowers[SH_MAXSLOTS+1]	// Dr Strange
new bool:gHasMeteorixPower[SH_MAXSLOTS+1]	// Meteorix
new bool:gHasNeo[SH_MAXSLOTS+1]			// Neo

new MonitorHudSync
new const TaskClassname[] = "monitorloop" 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
 	register_plugin("plugin Cooldown", "1.0", "Lucas Cab Arje")
	
	#if ACTIVE_POWERS_INFO
		BHForward 		= CreateMultiForward("sendBHCooldown", ET_CONTINUE, FP_CELL)
		DanimothForward 	= CreateMultiForward("sendDanimothCooldown", ET_CONTINUE, FP_CELL)
		VaderForward 		= CreateMultiForward("sendVaderCooldown", ET_CONTINUE, FP_CELL)
		PalpatineForward	= CreateMultiForward("sendPalpatineCooldown", ET_CONTINUE, FP_CELL)
		FriezaForward		= CreateMultiForward("sendFriezaCooldown", ET_CONTINUE, FP_CELL)
		GokuKTForward		= CreateMultiForward("sendGokuKTCooldown", ET_CONTINUE, FP_CELL)
		InvisWomanForward	= CreateMultiForward("sendInvisWomanCooldown", ET_CONTINUE, FP_CELL)
		LanternForward		= CreateMultiForward("sendLanternCooldown", ET_CONTINUE, FP_CELL)
		MSharinganForward	= CreateMultiForward("sendMSharinganCooldown", ET_CONTINUE, FP_CELL)
		// NarutoscjForward	= CreateMultiForward("sendNarutoscjCooldown", ET_CONTINUE, FP_CELL)
		SandmanForward		= CreateMultiForward("sendSandmanCooldown", ET_CONTINUE, FP_CELL)
		ShacoForward 		= CreateMultiForward("sendShacoCooldown", ET_CONTINUE, FP_CELL)
		ShadowcatForward 	= CreateMultiForward("sendShadowcatCooldown", ET_CONTINUE, FP_CELL)
		JawsForward 		= CreateMultiForward("sendJawsCooldown", ET_CONTINUE, FP_CELL)		// Sharknado
		SubZeroForward 		= CreateMultiForward("sendSubZeroCooldown", ET_CONTINUE, FP_CELL)		// Sub Zero
		SSJGohanForward		= CreateMultiForward("sendSSJGohanCooldown", ET_CONTINUE, FP_CELL)
		T800Forward		= CreateMultiForward("sendT800Cooldown", ET_CONTINUE, FP_CELL)
		TranzaForward		= CreateMultiForward("sendTranzaCooldown", ET_CONTINUE, FP_CELL)
		VegetaForward		= CreateMultiForward("sendVegetaCooldown", ET_CONTINUE, FP_CELL)
		WonWomanForward		= CreateMultiForward("sendWonWomanCooldown", ET_CONTINUE, FP_CELL)
		YadratForward		= CreateMultiForward("sendYadratCooldown", ET_CONTINUE, FP_CELL)
		YodaForward 		= CreateMultiForward("sendYodaCooldown", ET_CONTINUE, FP_CELL)
		// YodaWisForward 		= CreateMultiForward("sendYodaWisCooldown", ET_CONTINUE, FP_CELL)
		ZeusForward 		= CreateMultiForward("sendZeusCooldown", ET_CONTINUE, FP_CELL)
		DrStrangeForward 	= CreateMultiForward("sendDrStrangeCooldown", ET_CONTINUE, FP_CELL)
		MeteorixForward 	= CreateMultiForward("sendMeteorixCooldown", ET_CONTINUE, FP_CELL)
		NeoForward 		= CreateMultiForward("sendNeoCooldown", ET_CONTINUE, FP_CELL)
	#endif
	
	// Todo esto es del Hud
	new monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (monitor) {
		set_pev(monitor, pev_classname, TaskClassname)
		set_pev(monitor, pev_nextthink, get_gametime() + 0.1)
		register_forward(FM_Think, "monitor_thinkcooldown")
	}
	
	MonitorHudSync = CreateHudSyncObj()
	
	set_task(1.0, "loopMainCD", _, _, _, "b")	// Esta tarea es de los cooldowns
	set_task(0.2, "cache_idCD");   		// we need to let superhero cache all the heros to avoid issues
}
//----------------------------------------------------------------------------------------------
public cache_idCD() 
{
	// Primera Pagin Menu
	bhID		= sh_get_hero_id("Black Hole");
	danimothID	= sh_get_hero_id("Danimoth X");
	vaderID		= sh_get_hero_id("Darth Vader");
	palpatineID	= sh_get_hero_id("Emperador Palpatine");
	friezaID	= sh_get_hero_id("Freezer");
	gokuKTid	= sh_get_hero_id("Goku's Kaio-Ken Technic");
	inviswomanID	= sh_get_hero_id("Invisible Woman");
	lanternID	= sh_get_hero_id("Linterna Verde");
	MsharinganID	= sh_get_hero_id("Mangekyou Sharingan");
	narutoscjID	= sh_get_hero_id("Naruto Uzumaki");
	sandmanID	= sh_get_hero_id("Sandman");
	shacoID 	= sh_get_hero_id("Shaco");
	shadowID 	= sh_get_hero_id("Shadowcat");
	jawsID	 	= sh_get_hero_id("Sharknado");
	subzeroID	= sh_get_hero_id("Sub-Zero");
	ssjGohanID	= sh_get_hero_id("Super Saiyan Gohan");
	t800ID		= sh_get_hero_id("T-800");
	tranzaID	= sh_get_hero_id("Tranza");
	vegetaID	= sh_get_hero_id("Vegeta");
	wonwomanID	= sh_get_hero_id("Wonder Woman");
	yadratID	= sh_get_hero_id("Yadrat");
	yodaID 		= sh_get_hero_id("Yoda");
	// yodawisID 	= sh_get_hero_id("Yoda's Wisdom");
	zeusID	 	= sh_get_hero_id("Zeus");
	
	drstrangeID	= sh_get_hero_id("Dr. Strange");
	meteorixID	= sh_get_hero_id("Meteorix");
	neoID		= sh_get_hero_id("Neo");
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	// Danimoth
	if ( bhID == heroID )
		gHasBHPower[id] = mode ? true : false
	// Danimoth
	else if ( danimothID == heroID )
		gHasDanimoth[id] = mode ? true : false
	// Darth Vader
	else if ( vaderID == heroID )
		g_hasVader[id] = mode ? true : false
	// Emperador Palpatine
	else if ( palpatineID == heroID )
		g_haspalpatinePowers[id] = mode ? true : false	
	// Freezer
	else if ( friezaID == heroID )
		gHasFrieza[id] = mode ? true : false	
	// Goku KT
	else if ( gokuKTid == heroID )
		HasGokuKT[id] = mode ? true : false	
	// Invisible Woman
	else if ( inviswomanID == heroID )
		gHasInvisWomanPower[id] = mode ? true : false	
	// Invisible Woman
	else if ( lanternID == heroID )
		gHasGreenPower[id] = mode ? true : false	
	// M Sharingan
	else if ( MsharinganID == heroID )
		HasMsharingan[id] = mode ? true : false
	// Naruto Uzumaki SCJ
	else if ( narutoscjID == heroID )
		gHasNaruto[id] = mode ? true : false
	// Sandman
	else if ( sandmanID == heroID )
		HasSandman[id] = mode ? true : false	
	// Shaco
	else if ( shacoID == heroID )
		gHasShaco[id] = mode ? true : false
	// Shadowcat
	else if ( shadowID == heroID )
		gHasShadowcat[id] = mode ? true : false
	// Sharknado - Jaws
	else if ( jawsID == heroID )
		g_hasJawsPower[id] = mode ? true : false
	// Sub-Zero
	else if ( subzeroID == heroID )
		g_HasSubZeroPower[id] = mode ? true : false
	// SSJ GOHAN
	else if ( ssjGohanID == heroID )
		g_hasSSJGohan[id] = mode ? true : false
	// T 800
	else if ( t800ID == heroID )
		gHasT800Power[id] = mode ? true : false	
	// Tranza
	else if ( tranzaID == heroID )
		gHasWeedMan[id] = mode ? true : false	
	// Vegeta
	else if ( vegetaID == heroID )
		gHasVegetaPower[id] = mode ? true : false	
	// Wonder Woman
	else if ( wonwomanID == heroID )
		gHasWonWomanPowers[id] = mode ? true : false		
	// Yadrat
	else if ( yadratID == heroID )
		g_hasFirestarterPower[id] = mode ? true : false		
	// Yoda
	else if ( yodaID == heroID )
		gHasYodaPower[id] = mode ? true : false
	/*/ Yoda Wisdow
	else if ( yodawisID == heroID )
		gHasYodaWisePower[id] = mode ? true : false */
	// Zeus
	else if ( zeusID == heroID )
		gHasStormPower[id] = mode ? true : false
	// Dr Strange
	else if ( drstrangeID == heroID )
		gHasDrStrangePowers[id] = mode ? true : false
	// Meteorix
	else if ( meteorixID == heroID )
		gHasMeteorixPower[id] = mode ? true : false
	// Neo
	else if ( neoID == heroID )
		gHasNeo[id] = mode ? true : false
}
//----------------------------------------------------------------------------------------------
public loopMainCD()
{	
	#if ACTIVE_POWERS_INFO
	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if ( !is_user_connected(id) || !is_user_alive(id) ) continue
		#if ACTIVE_POWERS_INFO
			get_active_powers_info(id)
		#endif
	}
	#endif
}
//---------------------------------------------------------------------------------------------
#if ACTIVE_POWERS_INFO
public get_active_powers_info(id)
{
	new bool:flag = false
	new functionReturn
	
	// Black Hole
	ExecuteForward(BHForward, functionReturn, id)
	if ( BHCooldown[id] != functionReturn ) {
		BHCooldown[id] = functionReturn
		flag = true
	}
	// Danimoth X
	ExecuteForward(DanimothForward, functionReturn, id)
	if ( DanimothCooldown[id] != functionReturn ) {
		DanimothCooldown[id] = functionReturn
		flag = true
	}
	// Darth Vader
	ExecuteForward(VaderForward, functionReturn, id)
	if ( VaderCooldown[id] != functionReturn ) {
		VaderCooldown[id] = functionReturn
		flag = true
	}
	// Emperador Palpatine
	ExecuteForward(PalpatineForward, functionReturn, id)
	if ( PalpatineCooldown[id] != functionReturn ) {
		PalpatineCooldown[id] = functionReturn
		flag = true
	}
	// Freezer
	ExecuteForward(FriezaForward, functionReturn, id)
	if ( FriezaCooldown[id] != functionReturn ) {
		FriezaCooldown[id] = functionReturn
		flag = true
	}
	// GokuKT
	ExecuteForward(GokuKTForward, functionReturn, id)
	if ( GokuKTCooldown[id] != functionReturn ) {
		GokuKTCooldown[id] = functionReturn
		flag = true
	}
	// Invisible Woman
	ExecuteForward(InvisWomanForward, functionReturn, id)
	if ( InvisWomanCooldown[id] != functionReturn ) {
		InvisWomanCooldown[id] = functionReturn
		flag = true
	}
	// Linterna Verde
	ExecuteForward(LanternForward, functionReturn, id)
	if ( LanternCooldown[id] != functionReturn ) {
		LanternCooldown[id] = functionReturn
		flag = true
	}
	// MSharingan
	ExecuteForward(MSharinganForward, functionReturn, id)
	if ( MSharinganCooldown[id] != functionReturn ) {
		MSharinganCooldown[id] = functionReturn
		flag = true
	}
	/*/ Naruto Uzumaki SCJ
	ExecuteForward(NarutoscjForward, functionReturn, id)
	if ( NarutoscjCooldown[id] != functionReturn ) {
		NarutoscjCooldown[id] = functionReturn
		flag = true
	} */
	// Sandman
	ExecuteForward(SandmanForward, functionReturn, id)
	if ( SandmanCooldown[id] != functionReturn ) {
		SandmanCooldown[id] = functionReturn
		flag = true
	}
	// Shaco
	ExecuteForward(ShacoForward, functionReturn, id)
	if ( ShacoCooldown[id] != functionReturn ) {
		ShacoCooldown[id] = functionReturn
		flag = true
	}
	// Shadowcat
	ExecuteForward(ShadowcatForward, functionReturn, id)
	if ( ShadowcatCooldown[id] != functionReturn ) {
		ShadowcatCooldown[id] = functionReturn
		flag = true
	}
	// Sharknado - Jaws
	ExecuteForward(JawsForward, functionReturn, id)
	if ( JawsCooldown[id] != functionReturn ) {
		JawsCooldown[id] = functionReturn
		flag = true
	}
	// Sub-Zero
	ExecuteForward(SubZeroForward, functionReturn, id)
	if ( SubZeroCooldown[id] != functionReturn ) {
		SubZeroCooldown[id] = functionReturn
		flag = true
	}
	// SSJ Gohan
	ExecuteForward(SSJGohanForward, functionReturn, id)
	if ( SSJGohanCooldown[id] != functionReturn ) {
		SSJGohanCooldown[id] = functionReturn
		flag = true
	}
	// T-800
	ExecuteForward(T800Forward, functionReturn, id)
	if ( T800Cooldown[id] != functionReturn ) {
		T800Cooldown[id] = functionReturn
		flag = true
	}
	// Tranza
	ExecuteForward(TranzaForward, functionReturn, id)
	if ( TranzaCooldown[id] != functionReturn ) {
		TranzaCooldown[id] = functionReturn
		flag = true
	}
	// Vegeta
	ExecuteForward(VegetaForward, functionReturn, id)
	if ( VegetaCooldown[id] != functionReturn ) {
		VegetaCooldown[id] = functionReturn
		flag = true
	}
	// Wonder Woman
	ExecuteForward(WonWomanForward, functionReturn, id)
	if ( WonWomanCooldown[id] != functionReturn ) {
		WonWomanCooldown[id] = functionReturn
		flag = true
	}
	// Yadrat
	ExecuteForward(YadratForward, functionReturn, id)
	if ( YadratCooldown[id] != functionReturn ) {
		YadratCooldown[id] = functionReturn
		flag = true
	}
	// Yoda
	ExecuteForward(YodaForward, functionReturn, id)
	if ( YodaCooldown[id] != functionReturn ) {
		YodaCooldown[id] = functionReturn
		flag = true
	}
	/*/ Yoda Wisdow
	ExecuteForward(YodaWisForward, functionReturn, id)
	if ( YodaWisCooldown[id] != functionReturn ) {
		YodaWisCooldown[id] = functionReturn
		flag = true
	} */
	// Zeus
	ExecuteForward(ZeusForward, functionReturn, id)
	if ( ZeusCooldown[id] != functionReturn ) {
		ZeusCooldown[id] = functionReturn
		flag = true
	}
	// Dr Strange
	ExecuteForward(DrStrangeForward, functionReturn, id)
	if ( DrStrangeCooldown[id] != functionReturn ) {
		DrStrangeCooldown[id] = functionReturn
		flag = true
	}
	// Meteorix
	ExecuteForward(MeteorixForward, functionReturn, id)
	if ( MeteorixCooldown[id] != functionReturn ) {
		MeteorixCooldown[id] = functionReturn
		flag = true
	}
	// Meteorix
	ExecuteForward(NeoForward, functionReturn, id)
	if ( NeoCooldown[id] != functionReturn ) {
		NeoCooldown[id] = functionReturn
		flag = true
	}
		
	if (flag) {
		new ent = id
		monitor_thinkcooldown(ent)	// showhud(id)	
	}
}
#endif
//----------------------------------------------------------------------------------------------
public monitor_thinkcooldown(ent)		// showhud(id)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED

	static class[32]
	pev(ent, pev_classname, class, charsmax(class))
	if ( equal(class, TaskClassname) ) {
		new len
		static players[32], count, i, id
		static temp[128]
		get_players(players, count, "ch")

		for ( i = 0; i < count; i++ ) {
			id = players[i]
			temp[0] = '^0'
	
			if ( is_user_alive(id) ) {
				len = 0
				#if ACTIVE_POWERS_INFO
					// Black Hole
					if ( gHasBHPower[id] ) {
						new const gHeroName[] = "Black Hole"
						if (BHCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, BHCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Danimoth
					if ( gHasDanimoth[id] ) {
						new const gHeroName[] = "Danimoth X"
						if (DanimothCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, DanimothCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Darth Vader
					if ( g_hasVader[id] ) {
						new const gHeroName[] = "Darth Vader"
						if (VaderCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, VaderCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// DrStrange
					if ( gHasDrStrangePowers[id] ) {
						new const gHeroName[] = "Dr. Strange"
						if (DrStrangeCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, DrStrangeCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: OFF | ", gHeroName )
						}
					}
					// Emperador Palpatine
					if ( g_haspalpatinePowers[id] ) {
						new const gHeroName[] = "Emp. Palpatine"
						if (PalpatineCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, PalpatineCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Freezer
					if ( gHasFrieza[id] ) {
						new const gHeroName[] = "Freezer"
						if (FriezaCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, FriezaCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Goku KT
					if ( HasGokuKT[id] ) {
						new const gHeroName[] = "Kaio-Ken"
						if (GokuKTCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, GokuKTCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Invisble Woman
					if ( gHasInvisWomanPower[id] ) {
						new const gHeroName[] = "Invis. Woman"
						if (InvisWomanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, InvisWomanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Linterna Verde
					if ( gHasGreenPower[id] ) {
						new const gHeroName[] = "Lint. Verde"
						if (LanternCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, LanternCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// M Sharingan
					if ( HasMsharingan[id] ) {
						new const gHeroName[] = "Mgkyo. Sharingan"
						if (MSharinganCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, MSharinganCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Meteorix
					if ( gHasMeteorixPower[id] ) {
						new const gHeroName[] = "Meteorix"
						if (MeteorixCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, MeteorixCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: OFF | ", gHeroName )
						}
					}
					// Neo
					if ( gHasNeo[id] ) {
						new const gHeroName[] = "Neo"
						if (NeoCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, NeoCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					/* // Naruto Uzumaki
					if ( HasMsharingan[id] ) {
						new const gHeroName[] = "Naruto SCJ"
						if (NarutoscjCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, NarutoscjCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					} */
					// Sandman
					if ( HasSandman[id] ) {
						new const gHeroName[] = "Sandman"
						if (SandmanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, SandmanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					// Shaco 
					if ( gHasShaco[id] ) {
						new const gHeroName[] = "Shaco"
						if (ShacoCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, ShacoCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					}
					// Shadowcat 
					if ( gHasShadowcat[id] ) {
						new const gHeroName[] = "Shadowcat"
						if (ShadowcatCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, ShadowcatCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					}
					// Sharknado - Jaws 
					if ( g_hasJawsPower[id] ) {
						new const gHeroName[] = "Sharknado"
						if (JawsCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, JawsCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Sub-Zero
					if ( g_HasSubZeroPower[id] ) {
						new const gHeroName[] = "Sub-Zero"
						if (SubZeroCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, SubZeroCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// SSJ Gohan
					if ( g_hasSSJGohan[id] ) {
						new const gHeroName[] = "SSJ Gohan"
						if (SSJGohanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, SSJGohanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					}
					// T 800
					if ( gHasT800Power[id] ) {
						new const gHeroName[] = "T-800"
						if (T800Cooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, T800Cooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Tranza
					if ( gHasWeedMan[id] ) {
						new const gHeroName[] = "Tranza"
						if (TranzaCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, TranzaCooldown[id] )
							} 
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Vegeta
					if ( gHasVegetaPower[id] ) {
						new const gHeroName[] = "Vegeta"
						if (VegetaCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, VegetaCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Wonder Woman
					if ( gHasWonWomanPowers[id] ) {
						new const gHeroName[] = "Won. Woman"
						if (WonWomanCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, WonWomanCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Yadrat
					if ( g_hasFirestarterPower[id] ) {
						new const gHeroName[] = "Yadrat"
						if (YadratCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, YadratCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName ) 
						}
					} 
					// Yoda
					if ( gHasYodaPower[id] ) {
						new const gHeroName[] = "Yoda"
						if (YodaCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, YodaCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					/*/ Yoda Wisdow
					if ( gHasYodaWisePower[id] ) {
						new const gHeroName[] = "Yoda Wis."
						if (YodaWisCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, YodaWisCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					} */
					// Zeus
					if ( gHasStormPower[id] ) {
						new const gHeroName[] = "Zeus"
						if (ZeusCooldown[id] > 0) {
							len += formatex(temp[len], charsmax(temp) - len, "%s: %i | ", gHeroName, ZeusCooldown[id] )
							}
						else 	{
							len += formatex(temp[len], charsmax(temp) - len, "%s: ON | ", gHeroName )
						}
					}
					
					set_hudmessage(0, 100, 200, 0.02, 0.70, 0, 0.0, 1.0, 0.0, 0.0)
					ShowSyncHudMsg(id, MonitorHudSync, "[CD]  %s", temp)	//agregado
				#endif
			}
		}
	}
	
	return FMRES_IGNORED
}
/*
Esto lo dejo aca para ver algun dia por si me pinta saber como arreglar los heroes o ponerlos segun un orden en especifico segun los keys o no se.
	if ( gHasShadowcat[id] ) {	// gHasPower[id]
		len += formatex(temp[len], charsmax(temp) - len, " | ")
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/