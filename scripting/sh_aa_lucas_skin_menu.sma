/* 	Considerations for doing this:

	This TT / CT skin model must to match the location in models/player/skin/skin.mdl

	Currently you only have to move the elements in the order you want, the rest is done by the program itself.
	IMPORTANT: Leave skin from Hero's separately from Buy Skins.
	
	If you want to add skins to the menu you must add them to the end of both lists BuySkinsNames[][]
	The names in BuySkinsNames[][] must match the names in the HeroName column in g_SkinData[][][]

*/
#include <amxmisc>
#include <superheromod>
#include <nvault>

#define DATA_FLAG "t" 			// This is for put a flag for premiums/admins

// ======================================================== 
const NoModelSet = -1;
const level_for_buy = 30;	// This for a minimum level to buy skins, anyways only can buy if the user have the XP necessary.

new const g_SkinData[][][] =   
{
// 	This is from hero's
//	TT Model, 	CT Model		HeroName		Condition 		
	{"blackwidow" , "blackwidow", 		"Blackwidow",		"Level 8" },	// 0
	{"broly",	"broly", 		"Broly",		"Level 13"},	// 1
	{"masterchief_t","masterchief_ct", 	"Master Chief",		"Level 13"},	// 1
	{"obiwan",	"obiwan", 		"Obi Wan Kenobi",	"Level 13"},	// 1
	{"sonic", 	"sonic2",  		"Sonic",		"Level 13"},	// 19
	{"spiderman_eg","spiderman_eg",		"Spider Man",		"Level 13"},	// 19
	{"terminator",	"terminator",		"T-800",		"Level 13"},	// 19
	
	{"deadpool", 	"deadpool",  		"Deadpool", 		"250.000 XP"},
	{"friezagolden","friezagolden", 	"Golden Frieza",	"250.000 XP"}
	
}

	// This is for buy skins
/*/	TT Model, 	CT Model		HeroName		Condition 		
	{"darthvader" , "darthvader",  		"Darth Vader", 		"100.000 XP"},	// 8
	{"harley",	"harley",  		"Harley Quinn",		"100.000 XP"},	
	{"wonderwoman", "wonderwoman",  		"Wonder Woman", 	"100.000 XP"},	// 10
	
	{"broly", 	"broly",  		"Broly", 		"250.000 XP"},	// 11
	
	{"wizard_jawa", "wizard_jawa",  		"Wizard Jawa", 		"250.000 XP"},
	
	{"gokussj3", 	"gokussj3" ,  		"Goku", 		"250.000 XP"}, 	// 15
	
	{"jack_sparrow","jack_sparrow", 	"Jack Sparrow", 	"500.000 XP"},	// 16
	{"naruto", 	"naruto",  		"Naruto", 		"500.000 XP"},	
	{"turtle_red", 	"turtle_red",  		"Turtle Ninja", 	"500.000 XP"}, 	// 18
	
	{"dark_sonic", 	"dark_sonic",  		"Dark Sonic",		"1.000.000 XP"},// 19
	{"mario64", 	"mario64",  		"Mario64", 		"1.000.000 XP"}, 
	{"orcthing", 	"orcthing",  		"Orcthing", 		"1.000.000 XP"},
	{"cat_shrek", 	"cat_shrek",  		"Puss in Boots", 	"1.000.000 XP"},// 22
	
	{"miku_vest", 	"miku_vest",  		"Miku",			"1.500.000 XP"},// 23
	{"thanos", 	"thanos",  		"Thanos",		"5.000.000 XP"},// 24
	{"kratos", 	"kratos",  		"Kratos",		"20.000.000 XP"} // 25
}; 	// actually 25 skins   */

/* 
	I created this to match so if I want to move the menu I don't need to worry about this 
	
	If you want to add skins to the menu you must add them to the end of both lists
	The names in BuySkinsNames[][] must match the names in the HeroName column in g_SkinData[][][]
*/

enum _:gTypeHero {
	Blackwidow, 
	Broly,
	MasterChief,
	Obiwan,
	Sonic,
	SpiderMan,
	Terminator
}

new const BuySkinsNames[][][] = {
	("Deadpool", 		"200.000 XP"),
	("Golden Frieza",	"200.000 XP")	
};

enum _:BuySkins {
	Deadpool,
	GoldenFrieza
};

// for know if has the hero or not
new gHeroID[gTypeHero]; 
new bool:gHasPower[gTypeHero][SH_MAXSLOTS+1];

new g_PlayerBuySkin[BuySkins][SH_MAXSLOTS+1]
new g_Model[SH_MAXSLOTS+1];
new CsTeams:g_csTeam[SH_MAXSLOTS+1];		// esto se para seleccionar los teams corerctamente

// new g_szAuthID[ MAX_PLAYERS + 1 ][ 34 ];     // steam ID
new gMemoryTableNames[64][32]		// Stores players name for a key

new g_pExpireDays;                    		 //CVar pointer for expiredays cvar
new g_iVaultID;                   	 		//Global variable from File Name vault

  //Create a global variable to hold our callback
new g_MenuCallback
new g_MenuCallback_sell
new g_buy_selected[SH_MAXSLOTS+1]     

//------------------------------------------------------------------------------------------------
//                Plugint Init n Precache                				        //
//------------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin( "Skins Models" , "1.4" , "Lucas Arje Je :D" );

	register_event( "ResetHUD" , "resetModel" , "b" ); 
	register_event( "TeamInfo" , "teamInfo" , "a" , "2=TERRORIST" , "2=CT" ); 
		
	register_clcmd("say /skin", "SkinMenu");    // for call the skin menu in sv
	register_clcmd("say /skins", "SkinMenu");    // for call the skin menu in sv
	register_clcmd("say /menuskin", "SkinMenu");    // for call the skin menu in sv
	
	g_pExpireDays = register_cvar( "skinmenu_expiredays" , "90" );    // For clear nvault?
 
	//Create our callback and save it to our variable
	g_MenuCallback = menu_makecallback("menuitem_callback");    //The first parameter is the public function to be called when a menu item is being shown.
	
	g_MenuCallback_sell = menu_makecallback("menuitem_callback_sell");
	
	set_task(0.2, "cache_skins");   		// we need to let superhero cache all the heros to avoid issues
}

public plugin_precache() {	
	// this point precache all skins in the first array, that is because we need to put the correct name.
	// If you put the wrong name.mdl the server does not load and will throw an error
	new tempfile[ 128 ];
    
	// for ( new iModelIndex = 0 ; iModelIndex < sizeof( g_ModelFiles ) ; iModelIndex++ ) {
	for ( new iModelIndex = 0 ; iModelIndex < sizeof( g_SkinData ) ; iModelIndex++ ) {
		formatex( tempfile , charsmax( tempfile ) , "models/player/%s/%s.mdl" , g_SkinData[ iModelIndex ][ 0 ] , g_SkinData[ iModelIndex ][ 0 ] );
		precache_model( tempfile );
        
		formatex( tempfile , charsmax( tempfile ) , "models/player/%s/%s.mdl" , g_SkinData[ iModelIndex ][ 1 ] , g_SkinData[ iModelIndex ][ 1 ] );
		precache_model( tempfile );
	}
}

public cache_skins() 
{
	for (new i = 0; i < gTypeHero; i++) {
		gHeroID[i] = sh_get_hero_id(g_SkinData[i][2]);
	}
}

public sh_hero_init(id, heroID, mode)
{
	for (new i = 0; i < gTypeHero; i++) {
		if (gHeroID[i] == heroID) {
			gHasPower[i][id] = mode ? true : false;
		}
	}
}
//------------------------------------------------------------------------------------------------
//                    Nvault Open n Init                  					  //
//------------------------------------------------------------------------------------------------
public plugin_end( ) {
	nvault_close( g_iVaultID );
}

public plugin_cfg( )
{
	// Maybe we need to change the name of this option "g_model2" for "another_name" like "g_model3"
	// this is the name where our selections will be saved, so if we add more skins and move the order of the list we should create a new one
	g_iVaultID = nvault_open( "g_Model_skin" );
    
	if( g_iVaultID == INVALID_HANDLE ) {
		set_fail_state( "Error opening Skin Nvault" );
	}
    
	// This will remove all entries in the vault that are 5+ (or cvar+) days old at server-start or map-change
	nvault_prune( g_iVaultID , 0 , get_systime() - ( 86400 * get_pcvar_num( g_pExpireDays ) ) );
}

// public client_authorized(Player) 
public client_putinserver(Player) 
{
	get_user_name(Player, gMemoryTableNames[Player], charsmax(gMemoryTableNames[]) )
	// get_user_authid( Player , g_szAuthID[ Player ] , charsmax( g_szAuthID[] ) );
	g_Model[Player] = NoModelSet;
	LoadData( Player );
}
//------------------------------------------------------------------------------------------------
//                   		 Create Menu            			            //
//------------------------------------------------------------------------------------------------
public SkinMenu(id)     // SkinMenu    //modelvip
{
	new menu = menu_create( "\yModel Player Skin Menu:", "menu_handler" );

	new itemText[64] 
	
	// this is for menu to so easy manipulate with first array
	for (new i = 0; i < sizeof(g_SkinData); i++) {
		if ( 7 <= i && i <= sizeof(g_SkinData) ) {
			for (new j = 0; j < sizeof(BuySkinsNames); j++) { 
				if ( equali( BuySkinsNames[j][0], g_SkinData[i][2] ) ) { 	// comparación insensible a mayúsculas y minúsculas
					if ( g_PlayerBuySkin[j][id] == 0 ) {
						formatex( itemText, sizeof(itemText), "\w%s. \r(Cost %s)", g_SkinData[i][2], g_SkinData[i][3] );	// esto muestra name ( cost xp )
						menu_additem(menu, itemText, "", 0, g_MenuCallback);
					}
					else {
						formatex( itemText, sizeof(itemText), "\w%s.", g_SkinData[i][2] );	// esto solo muestra el name
						menu_additem(menu, itemText, "", 0, g_MenuCallback);
					}
					break;
				}
			}	
		}
		else {
			formatex( itemText, sizeof(itemText), "\w%s.", g_SkinData[i][2] );
			menu_additem(menu, itemText, "", 0, g_MenuCallback);
		}
	}
	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public menu_handler( id , menu , item )
{
	if ( item == MENU_EXIT ) {
		menu_destroy(menu);
		sh_chat_message(id, -1, "You Didn't Select Any Skin.")
		return PLUGIN_HANDLED;
	}
    
	new szData[6], szName[64];
	new item_access, item_callback, g_price;
	menu_item_getinfo( menu, item, item_access, szData, charsmax(szData), szName,charsmax(szName), item_callback );
    
	g_Model[id] = item;
	
	switch(item) {
		// If you add new skins(actually 17(0 - 16) skins) you must put ,17 , 18 etc 
		case 0, 1, 2, 3, 4, 5, 6: {
			sh_chat_message(id, -1, "You selected the %s Skin.", g_SkinData[item][2])
			resetModel(id)
			SaveData(id);
		}
		// remembers the hero's correspondence with his item number
		case 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22: {	
			// En setos ciclos busco encontrar el nombre de la buyskin para que corresponda g_PlayerBuySkin
			for (new j = 0; j < sizeof(BuySkinsNames); j++) { 
				
				if ( equali( BuySkinsNames[j][0], g_SkinData[item][2] ) ) { 	// comparación insensible a mayúsculas y minúsculas

					if ( g_PlayerBuySkin[j][id] == 0 ) {
						g_buy_selected[id] = j
						ChoiceMenu(id)
					}
					else 	{ 	 
						sh_chat_message(id, -1, "You selected the %s Skin.", BuySkinsNames[j][0])
						resetModel(id)
						SaveData(id);
					}
					
					break;
				}
			}
		}
	}

	//lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

convertir_str_to_num(item)
{
	new szData[64], g_price
	new tempValue[9];	// esto significa que puede tener hasta 8 cifras 10.000.0000
	
	formatex(szData, charsmax(szData), "%s", g_SkinData[item][3]);
	
	new tempIdx = 0;	//  Índice temporal para construir tempValue	// se pone en 0 cada vez que se llama la funcion
	new realIdx = 0;	//  En este caso empiezo desde el indice 0 porque ya se que estos valores no son numeros
	
	while ( realIdx < strlen(szData) ) {
		
		if ('0' <= szData[realIdx] && szData[realIdx] <= '9') {	// Verificar si el carácter es un dígito (0-9)
			tempValue[tempIdx] = szData[realIdx];
			tempIdx++;	 	 
		}
		
		realIdx++;
	}
	g_price =  str_to_num(tempValue);
	return g_price
}
//------------------------------------------------------------------------------------------------
//                    MENU DISABLE THINGS                    //
//------------------------------------------------------------------------------------------------
public menuitem_callback(id, menu, item)        // This is our callback function. Return ITEM_ENABLED, ITEM_DISABLED, or ITEM_IGNORE.
{
	// This function is some like if the level of user is MORE that value, the user/player can use that option.
	new requiredLevel, requiredXP, level, user_xp
	level = sh_get_user_lvl(id);
	user_xp = sh_get_user_xp(id);

	new itemText[64]
	 
	for (new i= 0; i < sizeof( g_SkinData ); i++) {
		// Skins que se compran
		if ( 7 <= i && i <= sizeof(g_SkinData) ) {
			requiredXP = convertir_str_to_num(i)		// para obtener la xp necesaria que pide cada uno
			formatex(itemText, sizeof(itemText), "\d%s. \r(Buy %s)", g_SkinData[i][2],  g_SkinData[i][3]);	// Esto es para las skins buy
			
			for ( new j = 0; j < sizeof(BuySkinsNames); j++ ) { 
				if ( equali( BuySkinsNames[j][0], g_SkinData[item][2] ) ) { 	// comparación insensible a mayúsculas y minúsculas
					if ( item == i && g_PlayerBuySkin[j][id] == 0 && ( level < level_for_buy || user_xp < requiredXP ) ) {
						menu_item_setname(menu, item, itemText)
						return ITEM_DISABLED; 
					}
					break;
				}
			}
		}
		// Las skins que necesitan tener al heroe
		else 	{
			// requiredLevel = convertir_str_to_num(i)		// para obtener el nivel neceasrio que pide cada uno
			if ( item == i && !gHasPower[i][id] ) {
				formatex(itemText, sizeof(itemText), "\d%s. \r(%s)", g_SkinData[i][2],  g_SkinData[i][3]);
				menu_item_setname(menu, item, itemText)
				return ITEM_DISABLED;
			}
		}
		// if ( item == i && level[id] < requiredLevel && !has_flag(id, DATA_FLAG) ) { 
		// voy a guardar esta linea solo por si en un futuro queres skins por premium
	}
	return ITEM_IGNORE;     //Note that returning ITEM_ENABLED will override the admin flag check from menu_additem    
} 
//------------------------------------------------------------------------------------------------
//                    CHOICE MENU         						        //
//------------------------------------------------------------------------------------------------
public ChoiceMenu(id)
{
	static itemText[128]
	
	if ( g_PlayerBuySkin[g_buy_selected[id]][id] == 0 )
		formatex( itemText, sizeof(itemText), "\yQueres comprar la skin? ^n\w%s. \r(Cost %s)", g_SkinData[g_Model[id]][2], g_SkinData[g_Model[id]][3] )
	else
		formatex( itemText, sizeof(itemText), "\yQueres comprar la skin? ^n\w%s. \r(Cost %s)", g_SkinData[g_Model[id]][2], g_SkinData[g_Model[id]][3] )
		
	new menu = menu_create( itemText, "menu_handler_choice" );

	menu_additem(menu, "Si.");
	menu_additem(menu, "No.");
	
	// menu_setprop(menu, MPROP_BACKNAME, "Mas Skins")
	// menu_setprop(menu, MPROP_NEXTNAME, "Atras")
	menu_setprop(menu, MPROP_EXITNAME, "Volver")

	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public menu_handler_choice(id, menu, item)
{
	if ( item == MENU_EXIT ) {
		menu_destroy(menu);
		sh_chat_message(id, -1, "You Didn't Select Any Skin.")
		return PLUGIN_HANDLED;
	}  
    
	new szData[6], szName[64];
	new item_access, item_callback, g_price;
	menu_item_getinfo( menu, item, item_access, szData, charsmax(szData), szName,charsmax(szName), item_callback );
	
	switch(item) {
		case 0: {
			g_price = convertir_str_to_num(g_Model[id]) 	// para convertir la cadena en un precio
			sh_set_user_xp( id, (-1 * g_price), true );	// quitarle la experiencia con la que compro
			sh_chat_message(id, -1, "You buy The %s skin. For the price of %d XP", BuySkinsNames[g_buy_selected[id]][0], g_price )	// mensaje al cliente para que sepa el gasto
			g_PlayerBuySkin[g_buy_selected[id]][id] = 1	 
			sh_chat_message(id, -1, "You selected the %s Skin.", BuySkinsNames[g_buy_selected[id]][0])
			
			resetModel(id)
			SaveData(id);
			
			menu_destroy(menu);
		}
		
		
		case 1: {
			sh_chat_message(id, -1, "You Didn't Select Any Skin.")	
			g_Model[id] = NoModelSet;
			
			menu_destroy(menu);
			SkinMenu(id)
		}
		
	}
	
	//lets finish up this function by destroying the menu with menu_destroy, and a return
	// menu_destroy(menu);
	return PLUGIN_CONTINUE;
}
	
/*
public g_MenuCallback_sell(id, menu, item)        // This is our callback function. Return ITEM_ENABLED, ITEM_DISABLED, or ITEM_IGNORE.
{
	return ITEM_IGNORE;     //Note that returning ITEM_ENABLED will override the admin flag check from menu_additem
} */
new const BuySkinsNames[][] = {
	"Deadpool",
	"Golden Frieza"
};

enum _:BuySkins {
	Deadpool,
	GoldenFrieza
};
public SellMenu(id)     // SkinMenu    //modelvip
{
	new menu = menu_create( "\yVender Player Skin Menu:", "menu_handler_sell" );

	static itemText[64], j 
	
	// this is for menu to so easy manipulate with first array
	for ( j = 0; j < BuySkins; j++ ) { 
		if ( g_PlayerBuySkin[j][id] == 1 ) {
			formatex( itemText, sizeof(itemText), "\w%s. \r(Vender por %s)", BuySkinsNames[j][0], BuySkinsNames[j][1]);	// esto muestra name ( cost xp )
			menu_additem(menu, itemText, "", 0, g_MenuCallback_sell);
		}
		else {
			formatex( itemText, sizeof(itemText), "\w%s. \d(No lo tenes)", BuySkinsNames[j][0] );	// esto solo muestra el name
			menu_additem(menu, itemText, "", 0, g_MenuCallback_sell);
		}
	}
	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public menu_handler_sell(id, menu, item)
{
	if ( item == MENU_EXIT ) {
		menu_destroy(menu);
		sh_chat_message(id, -1, "No seleccionaste nada.")
		return PLUGIN_HANDLED;
	}  
    
	new szData[6], szName[64];
	new item_access, item_callback;
	menu_item_getinfo( menu, item, item_access, szData, charsmax(szData), szName,charsmax(szName), item_callback );
	
	g_Model[id] = item + sizeof(g_SkinData) - sizeof(BuySkinsNames)
	
	ChoiceMenu(id)
	//lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}
//------------------------------------------------------------------------------------------------
//                Save and Load Data from Nvault.                    //
//------------------------------------------------------------------------------------------------
public SaveData(id)
{ 
	new szData[128]; // Ajusta el tamaño según tus necesidades
	// 0 1 2 3 4 5 6 7 8 9 = 10 valores, el 11 ya es el 10
	if ( g_Model[id] <= 9 ) {
		formatex(szData, charsmax(szData), "%i ", g_Model[id]);
	} else {
		formatex(szData, charsmax(szData), "%i", g_Model[id]);
	}
	
	 // Añade la información de compra para cada elemento de BuySkins
	for (new i = 0; i < BuySkins; i++) {
		formatex( szData[strlen(szData)], charsmax(szData) - strlen(szData), "%d ", g_PlayerBuySkin[i][id] );
	}

	// sh_chat_message(id, -1, "Esta info es de save szdata %s", szData); // Esto es para mi y ver como se mueve todo
	nvault_set(g_iVaultID, gMemoryTableNames[id], szData);
} 

public LoadData(id) 
{ 
	new szData[128], iTS;
	nvault_get(g_iVaultID, gMemoryTableNames[id], szData, charsmax(szData));

	// esto rellena en caso de agregar posteriormente mas skins esto es necesario en este orden
	for (new i = 0; i < BuySkins; i++) {
		g_PlayerBuySkin[i][id] = 0
	}
	
	// voy a usar esto para verificar que el jugador existe en el vault y si no existe se le asignan 0 y la skin nomodelset
	if ( nvault_lookup( g_iVaultID , gMemoryTableNames[id] , szData , charsmax( szData ) , iTS ) ) {
		
		new tempValue[2];
		tempValue[0] = szData[0];
		tempValue[1] = szData[1];
		g_Model[id] = str_to_num(tempValue);
		
		new tempIdx = 0;	 // Índice temporal para construir tempValue
		new realIdx = 2;	// obtener mi ubicacion real en este caso tengo que empezar en 2 porque ya asigne los dos valores antes en gmodel
	
		for (new i = 0; i < BuySkins; i++) {
			
			// Reiniciar valores
			tempIdx = 0
			
			while ( tempIdx < 2 ) {
				// Agregar el carácter actual a tempValue esto siempre renombrara a [0][1]
				tempValue[tempIdx] = szData[realIdx];	
				tempIdx++;	 
				realIdx++;	 
			} 
 
			g_PlayerBuySkin[i][id] =  str_to_num(tempValue);

			if ( realIdx == strlen(szData) ) break;
		}
		
		// esto es para checkear correctamente si la skin es correcta y la tiene
		// esto habilita a poder mover el menu como quisieramos en caso de agregar mas
		if ( g_Model[id] >= 7 ) {
			for (new j = 0; j < BuySkins; j++) {
				if ( equali( BuySkinsNames[j][0], g_SkinData[g_Model[id]][2] ) ) {
					if ( g_PlayerBuySkin[j][id] == 0 ) {
						g_Model[id] = NoModelSet;
						break;
					}
				}
			}
		}

	} else  { 
		g_Model[id] = NoModelSet;
	}
}
//------------------------------------------------------------------------------------------------
//            Team Info Event    (idk about this function)                //
//------------------------------------------------------------------------------------------------
public teamInfo()
{
	new id = read_data( 1 );
	new szTeam[ 2 ];
	new CsTeams:csNewTeam;

	read_data( 2 , szTeam , charsmax( szTeam ) );
    
	csNewTeam = ( szTeam[ 0 ] == 'T' ) ? CS_TEAM_T : CS_TEAM_CT;

	if ( g_csTeam[ id ] != csNewTeam ) {
		if ( g_Model[ id ] != NoModelSet ) {
			resetModel( id );    // resetModel( id );
		}
		g_csTeam[ id ] = csNewTeam;
	}    
}
//------------------------------------------------------------------------------------------------
//                New Spawn Event    "ResetHUD"                    //
//------------------------------------------------------------------------------------------------
 public sh_client_spawn(id) {
	if ( is_user_alive(id) ) {
		menu_spawn_tasks(id) 
	}
}

public menu_spawn_tasks(id) {
	set_task(1.0, "resetModel", id)
}

public resetModel(id)
{
	if ( g_Model[ id ] == NoModelSet ) return
	
	new CsTeams:userTeam;
	
	if ( CS_TEAM_T <= (userTeam = cs_get_user_team( id )) <= CS_TEAM_CT )
		cs_set_user_model( id , g_SkinData[ g_Model[id] ][ _:userTeam - 1 ]); 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
