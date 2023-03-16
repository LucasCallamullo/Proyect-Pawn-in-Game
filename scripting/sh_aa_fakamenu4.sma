/* Plugin generated by AMXX-Studio */

#include <superheromod> 

//Include the nvault file
#include <nvault>

// para saber que heroes tiene
new bool:gHasAceOfKatanas[SH_MAXSLOTS+1]
new bool:gHasBatman[SH_MAXSLOTS+1]
new bool:HasBlade[SH_MAXSLOTS+1]
new bool:HasChucky[SH_MAXSLOTS+1]
new bool:gHasDarthMaulPowers[SH_MAXSLOTS+1]
new bool:g_hasVader[SH_MAXSLOTS+1]
new bool:g_haspalpatinePowers[SH_MAXSLOTS+1]
new bool:gHasObiPower[SH_MAXSLOTS+1]
new bool:ghasRiddickPowers[SH_MAXSLOTS+1]
new bool:ghasWolvPowers[SH_MAXSLOTS+1]
new bool:gHasYodaPower[SH_MAXSLOTS+1]
new bool:gHasPower[SH_MAXSLOTS+1]

new aceID, batmanID, bladeID , chuckyID, darthmaulID
new vaderID, palpatineID, obiwanID, riddickID, wolvID, yodaID

enum Knives 
{ 
	NoKnifeSet = -1, 
	Ace, 
	Batman, 
	Blade, 
	Chucky, 
	DarthMaul,
	Vader,
	Palpatine,
	Obiwan, 
	Riddick,
	Wolv,
	Yoda
}

enum KnifeModels 
{ 
	ModelName[ 64 ],
	ViewModel[ 64 ] 
}

new const g_ModelData[Knives][KnifeModels] =  
{ 
	// { "default" 	,   	"models/v_knife.mdl" },
	{ "Ace" 	,   	"models/shmod/ace_v_knife.mdl" },  
	{ "Batman" 	,  	"models/shmod/batmanknife_v.mdl" },  
	{ "Blade" 	,    	"models/shmod/blade_knife_v.mdl" },  
	{ "Chucky" 	,  	"models/shmod/chucky_knife.mdl" },
	{ "DarthMaul"	, 	"models/shmod/darthmaul_knife.mdl" },
	{ "Vader" 	,	"models/shmod/darth_saber_red_v.mdl" },
	{ "Palpatine"	,	"models/shmod/darth_saber_red_v.mdl" },
	{ "Obiwan" 	,	"models/shmod/obiwan_saber_blu_v.mdl" },  
	{ "Riddick" 	, 	"models/shmod/riddick_knife.mdl" },
	{ "Wolv" 	,	"models/shmod/wolv_knife.mdl" },
	{ "Yoda" 	,    	"models/shmod/yoda_v.mdl" }
}

new Knives:knife_model[SH_MAXSLOTS+1];
new g_MenuCallback;				//Create a global variable to hold our callback

new g_iVaultID
// new g_szSteamID[MAX_PLAYERS+1][34]; 	// steam ID
new gMemoryTableNames[64][32]			// Stores players name for a key

new g_pExpireDays;         //CVar pointer for expiredays cvar
//----------------------------------------------------------------------------------------------
public plugin_init()
{
 	register_plugin("plugin KnifeMenuSH", "1.0", "Lucas Cab Arje")

	register_clcmd("say /knife", "KnifeMenu")		// Para llamar al menu de fakas
	register_clcmd("say /cuchi", "KnifeMenu")		// Para llamar al menu de fakas
	register_clcmd("say /faka", "KnifeMenu")		// Para llamar al menu de fakas
	register_clcmd("say /menufakas", "KnifeMenu")		// Para llamar al menu de fakas
	
	g_pExpireDays = register_cvar( "fakamenu_expiredays" , "15" );
	
	//Create our callback and save it to our variable
	g_MenuCallback = menu_makecallback("menuitem_callback");	//The first parameter is the public function to be called when a menu item is being shown.
	
	// Eventos
	register_event("CurWeapon","CurWeapon","be","1=1") 	// Para cambiar las fakas models
	set_task(0.2, "cache_id");   				//we need to let superhero cache all the heros to avoid issues
}

public plugin_end( )
{
	nvault_close( g_iVaultID )
}

public plugin_cfg( )
{
	g_iVaultID = nvault_open( "knife_vault22" )
    
	if( g_iVaultID == INVALID_HANDLE ) {
		set_fail_state( "Error opening Knife Nvault" )
	}
	
	//This will remove all entries in the vault that are 5+ (or cvar+) days old at server-start
	//or map-change
	nvault_prune( g_iVaultID , 0 , get_systime() - ( 86400 * get_pcvar_num( g_pExpireDays ) ) );
}

//public client_authorized(Player)  
public client_putinserver(Player)
{
	set_task(0.1, "cache_id"); 
	get_user_name(Player, gMemoryTableNames[Player], charsmax(gMemoryTableNames[]) )
	//get_user_authid( Player, g_szSteamID[Player], charsmax(g_szSteamID[ ]) )
	Load_Stuff(Player)
}
//----------------------------------------------------------------------------------------------
public cache_id() 
{
	// Primera Pagin Menu
	aceID 		= sh_get_hero_id("Ace of Katanas");
	batmanID 	= sh_get_hero_id("Batman");
	bladeID 	= sh_get_hero_id("Blade");
	chuckyID 	= sh_get_hero_id("Chucky");
	darthmaulID 	= sh_get_hero_id("Darth Maul");
	palpatineID 	= sh_get_hero_id("Emperador Palpatine");
	vaderID 	= sh_get_hero_id("Darth Vader");
	// Segunda Pagina Menu 
	obiwanID 	= sh_get_hero_id("Obi Wan Kenobi");
	riddickID 	= sh_get_hero_id("Riddick");
	wolvID	 	= sh_get_hero_id("Wolverine");
	yodaID 		= sh_get_hero_id("Yoda");
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	// Ace Of Katanas
	if ( aceID == heroID )
		gHasAceOfKatanas[id] = mode ? true : false
	// Batman
	else if ( batmanID == heroID )
		gHasBatman[id] = mode ? true : false 
	// Blade
	else if ( bladeID == heroID )
		HasBlade[id] = mode ? true : false
	// Chucky
	else if ( chuckyID == heroID )
		HasChucky[id] = mode ? true : false
	// Darth Maul	
	else if ( darthmaulID == heroID )
		gHasDarthMaulPowers[id] = mode ? true : false
	// Darth Vader	
	else if ( vaderID == heroID )
		g_hasVader[id] = mode ? true : false
	// Emperador Palpatine
	else if ( palpatineID == heroID )
		g_haspalpatinePowers[id] = mode ? true : false
	// Obi wan Kenobi
	else if ( obiwanID == heroID )
		gHasObiPower[id] = mode ? true : false
	// Riddick	
	else if ( riddickID == heroID )
		ghasRiddickPowers[id] = mode ? true : false
	// Wolverine	
	else if ( wolvID == heroID )
		ghasWolvPowers[id] = mode ? true : false
	// Yoda	
	else if ( yodaID == heroID )
		gHasYodaPower[id] = mode ? true : false
}
//----------------------------------------------------------------------------------------------
public KnifeMenu(id)
{
	new menu = menu_create( "\rRevive Player Menu!:", "menu_handler" );

	// Esto son de la Primera pagina del menu					//	Item	Key
	menu_additem( menu, "\wAce Katanas.", "", 0, g_MenuCallback );			//	0	1
	menu_additem( menu, "\wBatman.", "", 0, g_MenuCallback );			//	1	2
	menu_additem( menu, "\wBlade.", "", 0, g_MenuCallback );				//	2	3
	menu_additem( menu, "\wChucky.", "", 0, g_MenuCallback );			//	3	4
	menu_additem( menu, "\wDarth Maul.", "", 0, g_MenuCallback );			//	4	5
	menu_additem( menu, "\wDarth Vader.", "", 0, g_MenuCallback );			//	5	6
	menu_additem( menu, "\wEmperador Palpatine.", "", 0, g_MenuCallback );		//	6	7
	
	// Esto son de la Segunda pagina del menu	
	menu_additem( menu, "\wObi Wan Kenobi.", "", 0, g_MenuCallback );		//	7	1	
	menu_additem( menu, "\wRiddick.", "", 0, g_MenuCallback );			//	8	2
	menu_additem( menu, "\wWolverine.", "", 0, g_MenuCallback );			//	9	3
	menu_additem( menu, "\wYoda.", "", 0, g_MenuCallback );				//	10	4
	
	// El Key 8 reservado para Back Menu -- Y el Key 9 Para el More Menu -- esto es automatico no lo controlo
	menu_display(id, menu, 0);
}

public menu_handler(id, menu, item)
{
	if ( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new szData[6], szName[64];
	new item_access, item_callback;
	menu_item_getinfo( menu, item, item_access, szData, charsmax(szData), szName,charsmax(szName), item_callback );
	
	switch(item) {
		// Estas Fakas van a partir de la Primera Pagina del Menu
		//-----------	Ace Of Katanas
		case 0: {
			SetKnife( id, Knives:Ace);
			sh_chat_message(id, -1, "Seleccionaste las Katanas Dobles de Ace of Katana.")
		}
		//-----------	Batman
		case 1: {
			SetKnife( id, Knives:Batman);
			sh_chat_message(id, -1, "Seleccionaste la Faka de Batman.")
		}
		//-----------	Blade
		case 2: {
			SetKnife( id, Knives:Blade);
			sh_chat_message(id, -1, "Seleccionaste el Hacha de Blade.")
		}
		//-----------	Chucky
		case 3: {
			SetKnife( id, Knives:Chucky);
			sh_chat_message(id, -1, "Seleccionaste la Faka de Chucky.")	
		}
		//-----------	Darth Maul
		case 4: {
			SetKnife( id, Knives:DarthMaul);
			sh_chat_message(id, -1, "Seleccionaste el Sable de Luz Doble de Darth Maul.")
		}
		//-----------	Darth Vader
		case 5: {
			SetKnife( id, Knives:Vader);
			sh_chat_message(id, -1, "Seleccionaste el Sable de Luz de Darth Vader.")
		}
		//-----------	Emperador Palpatine
		case 6: {
			SetKnife( id, Knives:Palpatine);
			sh_chat_message(id, -1, "Seleccionaste el Sable de Luz del Emperador Palpatine.")
		}
		// Estas Fakas van a partir de la Segunda Pagina del Menu
		//-----------	Obi wan
		case 7: {
			SetKnife( id, Knives:Obiwan);
			sh_chat_message(id, -1, "Seleccionaste el Sable de Luz de Obi Wan Kenobi.")
		}
		//-----------	Ridicck
		case 8: {
			SetKnife( id, Knives:Riddick);
			sh_chat_message(id, -1, "Seleccionaste la Faka de Riddick.")
		}
		//-----------	Wolverine
		case 9: {
			SetKnife( id, Knives:Wolv);
			sh_chat_message(id, -1, "Seleccionaste las Garras de Wolverine.")
		}
		//-----------	Yoda - Yoda Wisdom's
		case 10: {
			SetKnife( id, Knives:Yoda);
			sh_chat_message(id, -1, "Seleccionaste el Sable de Luz de Yoda.")
		}
		case MENU_EXIT: {
			sh_chat_message(id, -1, "No Seleccionaste Ninguna Faka.")
		}
	}
	
	SaveData(id);
	//lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public SetKnife(id , Knives:Knife)  
{ 
	if (!sh_is_active() || !is_user_alive(id) ) return PLUGIN_HANDLED;
	
	new Knives:iModelIndex = NoKnifeSet;

	iModelIndex = Knife;
	// knife_model[id] = iModelIndex;
	
	switch(Knife) {
		// Estas Fakas van a partir de la primera Pagina
		//-----------	Ace Of Katanas
		case 0: {
			if ( gHasAceOfKatanas[id] ) {
				// gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Batman
		case 1: {
			if ( gHasBatman[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else {
				knife_model[id] = NoKnifeSet
			} 
		}
		//-----------	Blade
		case 2: {
			if ( HasBlade[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else {
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Chucky
		case 3: {
			if ( HasChucky[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else {
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Darth Maul
		case 4: {
			if ( gHasDarthMaulPowers[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}	
		}
		//-----------	Darth Vader 
		case 5: {
			if ( g_hasVader[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}	
		}
		//----------- 	Emperador Palpatine
		case 6: {
			if ( g_haspalpatinePowers[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}	
		}
		// Estas Fakas van a partir de la segunda Pagina
		//-----------	Obiwan
		case 7: {
			if ( gHasObiPower[id] ) {
				//gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Riddick
		case 8: {
			if ( ghasRiddickPowers[id] ) {
				// gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Wolverine
		case 9: {
			if ( ghasWolvPowers[id] ) {
				// gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}
		}
		//-----------	Yoda - Yoda Wisdowm
		case 10: {
			if ( gHasYodaPower[id] ) {
				// gHasPower[id] = true 
				knife_model[id] = iModelIndex;
			}
			else 	{
				knife_model[id] = NoKnifeSet
			}
		}
	}
	
	
	if ( !(id <= id <= SH_MAXSLOTS) || !is_user_alive(id) ) return PLUGIN_HANDLED;
	
	if ( get_user_weapon(id) == CSW_KNIFE ) { 
		entity_set_string( id , EV_SZ_viewmodel , g_ModelData[iModelIndex][ViewModel] );
	}
	
	return PLUGIN_HANDLED;	
}

public CurWeapon(id) 
{ 
	if ( !(id <= id <= SH_MAXSLOTS) || !is_user_alive(id) ) return PLUGIN_HANDLED;
	
	if ( knife_model[ id ] != Knives:NoKnifeSet ) {
		SetKnife(id, knife_model[id] )
	}
		
	return PLUGIN_HANDLED    
} 

public SaveData(id)
{  
	new szKey[ 40 ] , szData[ 4 ]; 
     
	formatex( szKey , charsmax(szKey) , "%s_knife" ,  gMemoryTableNames[id] );
	//formatex( szKey , charsmax( szKey ) , "%s_knife" ,  g_szSteamID[id] );

	num_to_str( _:knife_model[id] , szData , charsmax(szData) ); 
     
	nvault_set( g_iVaultID, szKey, szData );
} 

public Load_Stuff(id)  
{  
	new szKey[40] , szData[4] , iTS;  
	
	formatex( szKey , charsmax( szKey ) , "%s_knife" , gMemoryTableNames[id] ); 
	// formatex( szKey , charsmax( szKey ) , "%s_knife" , g_szSteamID[id] ); 
     
	if ( nvault_lookup( g_iVaultID , szKey , szData , charsmax( szData ) , iTS ) ) { 
		knife_model[ id ] = Knives:str_to_num( szData ); 
	}
	else 	{
		knife_model[ id ] = Knives:NoKnifeSet; 
		// SetKnife(id, Knives:NoKnifeSet) 
	}
}

// This is our callback function. Return ITEM_ENABLED, ITEM_DISABLED, or ITEM_IGNORE.
public menuitem_callback(id, menu, item)
{
	// Ace Katanas
	if ( item == 0 && !gHasAceOfKatanas[id] ) {
		menu_item_setname(menu, item, "\dAce Katanas.");
		return ITEM_DISABLED;
	}
	// Batman
	if ( item == 1 && !gHasBatman[id] ) {
		menu_item_setname(menu, item, "\dBatman.");
		return ITEM_DISABLED;
	}
	// Blade
	if ( item == 2 && !HasBlade[id]) {
		menu_item_setname(menu, item, "\dBlade.");
		return ITEM_DISABLED;
	}
	// Chucky
	if ( item == 3 && !HasChucky[id] ) {
		menu_item_setname(menu, item, "\dChucky.");
		return ITEM_DISABLED;
	}
	// Darth Maul
	if ( item == 4 && !gHasDarthMaulPowers[id] ) {
		menu_item_setname(menu, item, "\dDarth Maul.");
		return ITEM_DISABLED;
	}
	// Darth Vader
	if ( item == 5 && !g_hasVader[id] ) {
		menu_item_setname(menu, item, "\dDarth Vader.");
		return ITEM_DISABLED;
	}
	// Emperador Palpatine
	if ( item == 6 && !g_haspalpatinePowers[id] ) {
		menu_item_setname(menu, item, "\dEmperador Palpatine.");
		return ITEM_DISABLED;
	}
	// Obi Wan Kenobi
	if ( item == 7 && !gHasObiPower[id] ) {
		menu_item_setname(menu, item, "\dObi Wan Kenobi.");
		return ITEM_DISABLED;
	}
	// Riddick
	if ( item == 8 && !ghasRiddickPowers[id] )
	{
		menu_item_setname(menu, item, "\dRiddick.");
		return ITEM_DISABLED;
	}
	// Wolverine
	if ( item == 9 && !ghasWolvPowers[id] ) {
		menu_item_setname(menu, item, "\dWolverine.");
		return ITEM_DISABLED;
	}
	// Yoda - Yoda wisdow's
	if ( item == 10 && !gHasYodaPower[id] ) {
		menu_item_setname(menu, item, "\dYoda.");
		return ITEM_DISABLED; 
	}
	
	//Otherwise we can just ignore the return value
	return ITEM_IGNORE;	 //Note that returning ITEM_ENABLED will override the admin flag check from menu_additem	
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
