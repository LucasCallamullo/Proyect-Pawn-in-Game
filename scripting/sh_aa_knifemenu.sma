/* Plugin generated by AMXX-Studio */
#include <amxmisc>
#include <superheromod> 
#include <nvault>

#define DATA_FLAG "t"

#define VAULT_KN_NAME "knife_vaultL1"
 
const NoKnifeSet = -1;
	 
new const g_ModelData[][][] = 
{	
	// Hero/Item Name	// Condition	// Precache for item v_model		// Precache for item p_model
	{ "Ace of Katanas" ,	"Level 3",	"models/shmod/ace_v_knife.mdl" },   
	{ "Batman" 	,  	"Level 6",	"models/shmod/batman_knife_v.mdl" },
	{ "Blade" 	,  	"Level 6",	"models/shmod/blade_knife_v.mdl" },
	{ "Chucky" 	,  	"Level 6",	"models/shmod/chucky_knife.mdl" },
	{ "Darth Maul" 	,  	"Level 6",	"models/shmod/darthmaul_knife.mdl" },
	{ "Darth Vader" ,  	"Level 6",	"models/shmod/darth_saber_red_v.mdl" },
	{ "Emperador Palpatine","Level 6",	"models/shmod/darth_saber_red_v.mdl" },
	{ "Obi Wan Kenobi",	"Level 6",	"models/shmod/obiwan_saber_blu_v.mdl" },
	{ "Wolverine",		"Level 6",	"models/shmod/wolv_knife.mdl" },
	{ "Yoda",		"Level 6",	"models/shmod/yoda_v.mdl" }
}

enum _:PowerType {
	AceKatanas,
	Batman,
	Blade,
	Chucky,
	DarthMaul,
	DarthVader,
	EmperadorPalpatine,
	Obiwan,
	Wolverine,
	Yoda
}


new gHeroID[PowerType]; 
new bool:gHasPower[PowerType][SH_MAXSLOTS+1];		// En un futuro usar para interacciones entre heroes mas generico


new g_knife_model[SH_MAXSLOTS+1];

new g_iVaultID, g_MenuCallback, g_pExpireDays; 	//gVault	//Create a global variable to hold our callback  	//CVar pointer for expiredays cvar
new gMemoryTableNames[64][32]		// Stores players name for a key
//----------------------------------------------------------------------------------------------
public plugin_init()
{
 	register_plugin("plugin KnifeMenuSH", "1.0", "Lucas Cab Arje")
	
	register_clcmd("say knife", "KnifeMenu")		// Para llamar al menu de fakas
	register_clcmd("say /knife", "KnifeMenu")		// For call knife menu in game
	register_clcmd("say /cuchi", "KnifeMenu")		// For call knife menu in game
	
	
	g_pExpireDays = register_cvar( "fakamenu_expiredays" , "15" );	// Cvar para borrar las fakas guardadas del nvault en X dias, recomiendo 15 o menos
	
	//Create our callback and save it to our variable
	g_MenuCallback = menu_makecallback("menuitem_callback"); //The first parameter is the public function to be called when a menu item is being shown.
	
	// Eventos
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Knife_Deploy", 1)	// For the change the weapons
	
	set_task(0.2, "cache_idKnife");   		// we need to let superhero cache all the heros to avoid issues
}
//------------------------------------------------------------------------------------------------
//			For Check if has the hero						//
//------------------------------------------------------------------------------------------------
public cache_idKnife() 
{
	for (new i = 0; i < PowerType; i++) {
		gHeroID[i] = sh_get_hero_id(g_ModelData[i][0]);
	}
}

public sh_hero_init(id, heroID, mode)
{
	for (new i = 0; i < PowerType; i++) {
		if (gHeroID[i] == heroID) {
			gHasPower[i][id] = mode ? true : false;
		}
	}
}
//------------------------------------------------------------------------------------------------
//			For Menu Item								//
//------------------------------------------------------------------------------------------------	
public KnifeMenu(id)
{
	new menu = menu_create( "\rKnife Menu Skin!:", "menu_handler" );

	new itemText[64] 
	
	// this is for menu to so easy manipulate with first array
	for (new i = 0; i < sizeof(g_ModelData); i++) {
		formatex( itemText, sizeof(itemText), "\w%s.", g_ModelData[i][0] );
		menu_additem(menu, itemText, "", 0, g_MenuCallback);
	}
	
	// El Key 8 reservado para Back Menu -- Y el Key 9 Para el More Menu -- esto es automatico no lo controlo
	menu_display(id, menu, 0); 
}

public menu_handler(id, menu, item)
{
	if ( item == MENU_EXIT ) {
		menu_destroy( menu );
		sh_chat_message(id, -1, "You Didn't Select Any Knife Skin.");
		return PLUGIN_HANDLED;
	}
	
	new szData[6], szName[64];
	new item_access, item_callback;
	menu_item_getinfo( menu, item, item_access, szData, charsmax(szData), szName,charsmax(szName), item_callback );
	
	for (new i= 0; i < sizeof( g_ModelData ); i++) {
		if ( i == item ) {
			sh_chat_message(id, -1, "You selected %s Knife Skin's.", g_ModelData[item][0])
			SetKnife(id, item)
			break;
		}
	}
	
	SaveData(id);
	//lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
// This is our callback function. Return ITEM_ENABLED, ITEM_DISABLED, or ITEM_IGNORE.
public menuitem_callback(id, menu, item)
{
	static Level, requiredLevel, itemText[64]
	Level = sh_get_user_lvl(id)
	
	 
	for (new i= 0; i < sizeof( g_ModelData ); i++) {
		// requiredLevel = convertir_str_to_num(item)
		
		// crear el nombre disabled del menu
		formatex(itemText, sizeof(itemText), "\d%s. \r(%s)", g_ModelData[i][0],  g_ModelData[i][1]);
		
		if ( item == i && !gHasPower[i][id] ) {
			menu_item_setname(menu, item, itemText)
			return ITEM_DISABLED;
		}
	}
	//Otherwise we can just ignore the return value
	return ITEM_IGNORE;	 //Note that returning ITEM_ENABLED will override the admin flag check from menu_additem	
}
	/*
	/ Ejemplo de aDmin
	if (  item == 5 && ( !has_flag(id, DATA_FLAG) || Level < 38 ) ) { 
		menu_item_setname(menu, item, "\dDarth Vader. \r(Only Vip!)(Nivel 38)");
		return ITEM_DISABLED;
	}*/
convertir_str_to_num(item)
{
	new szData[32], g_price
	new tempValue[8];	// esto significa que puede tener hasta 8 cifras 1.000.0000
	
	formatex(szData, charsmax(szData), "%s", g_ModelData[item][1]);
	
	new tempIdx = 0;	//  �ndice temporal para construir tempValue	// se pone en 0 cada vez que se llama la funcion
	new realIdx = 0;	//  En este caso empiezo desde el indice 0 porque ya se que estos valores no son numeros
	
	while ( realIdx < strlen(szData) ) {
		if ('0' <= szData[realIdx] && szData[realIdx] <= '9') {	// Verificar si el car�cter es un d�gito (0-9)
			tempValue[tempIdx] = szData[realIdx];
			tempIdx++;
		}
		
		realIdx++;
	}
	
	g_price =  str_to_num(tempValue);
	return g_price
}
//------------------------------------------------------------------------------------------------
//			For the changes of weapones						//
//------------------------------------------------------------------------------------------------	
public SetKnife(id, item)  
{  
	if ( !(id <= id <= SH_MAXSLOTS) || !is_user_alive(id) ) return PLUGIN_HANDLED;
	
	g_knife_model[id] = item; 

	if ( get_user_weapon(id) == CSW_KNIFE )
		set_pev(id, pev_viewmodel2, g_ModelData[g_knife_model[id]][2])
	
	return PLUGIN_HANDLED;	
}

public Knife_Deploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, 41, 4)
	// This is for take de value to use from the vault
	// new iModelIndex = g_knife_model[id];
	
	if ( g_knife_model[id] != NoKnifeSet ) {
		// set_pev(id, pev_viewmodel2, g_ModelData[iModelIndex][2])
		set_pev(id, pev_viewmodel2, g_ModelData[g_knife_model[id]][2])
	}
	
	return HAM_IGNORED; 
}
//------------------------------------------------------------------------------------------------
//				This is about the vault initialize				//
//------------------------------------------------------------------------------------------------
public plugin_end( ) {
	nvault_close( g_iVaultID )
}

public plugin_cfg( )
{
	g_iVaultID = nvault_open( VAULT_KN_NAME )
    
	if( g_iVaultID == INVALID_HANDLE ) set_fail_state( "Error opening Knife Nvault" )
	
	//This will remove all entries in the vault that are 5+ (or cvar+) days old at server-start or map-change
	nvault_prune( g_iVaultID , 0 , get_systime() - ( 86400 * get_pcvar_num( g_pExpireDays ) ) );
}

//public client_authorized(Player)  
public client_putinserver(Player)
{
	get_user_name(Player, gMemoryTableNames[Player], charsmax(gMemoryTableNames[]) )
	// get_user_authid( Player, g_szSteamID[Player], charsmax(g_szSteamID[ ]) )
	Load_Stuff(Player)
}
//------------------------------------------------------------------------------------------------
//				SAVE n LOAD data from vault					//
//------------------------------------------------------------------------------------------------
public SaveData(id)
{  
	new szKey[ 40 ] , szData[ 6 ]; 
	//formatex( szKey , charsmax( szKey ) , "%s_knife" ,  g_szSteamID[id] );
	formatex( szKey , charsmax(szKey) , "%s_knife" ,  gMemoryTableNames[id] );
	
	num_to_str( _:g_knife_model[id] , szData , charsmax(szData) ); 
     
	nvault_set( g_iVaultID, szKey, szData );
} 

public Load_Stuff(id)  
{  
	new szKey[40] , szData[6] , iTS;  
	// formatex( szKey , charsmax( szKey ) , "%s_m4a1" , g_szSteamID[id] ); 
	formatex( szKey , charsmax( szKey ) , "%s_knife" , gMemoryTableNames[id] ); 
	
	if ( nvault_lookup( g_iVaultID , szKey , szData , charsmax( szData ) , iTS ) ) { 
		g_knife_model[ id ] = str_to_num( szData ); 
	} 
	else 	{
		g_knife_model[ id ] = NoKnifeSet;
	}
}

public plugin_precache() {
	for ( new iModelIndex = 0 ; iModelIndex < sizeof( g_ModelData ) ; iModelIndex++ )
		precache_model( g_ModelData[iModelIndex][2] )	// the warning is nothing works okey
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
