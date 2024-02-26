#include amxmodx
#include csx
#include <cstrike>

new msg,sec
new Float:c4cd,Float:c4max
new Float:temp,Float:r,Float:g
new bool:c4pl=false

public plugin_init()
{
	register_plugin("C4-Bomb Countdown HUD Timer","0.4","SAMURAI; Midnight Kid; Lucas Je :D")
	msg	=	CreateHudSyncObj()
	sec	=	get_cvar_pointer("mp_c4timer")
	register_logevent("nr",2,"1=Round_Start")
	register_logevent("er",2,"1=Round_End")
	register_logevent("er",2,"1&Restart_Round_")
}

public plugin_cfg()
{
    if(is_plugin_loaded("Pause Plugins") > -1)
        server_cmd("amx_pausecfg add ^"C4-Bomb Countdown HUD Timer^"");
} 

public nr()
{
	c4cd=-1.0
	remove_task(652450)
	c4pl=false
}

public er()
{
	c4cd=-1.0
	remove_task(652450)
}

public bomb_planted()
{
	c4pl=true
	c4max=get_pcvar_float(sec)
	c4cd=c4max
	show()
	set_task(1.0,"show",652450,"",0,"b")
}

public bomb_defused()
{
	if(c4pl)
	{
		remove_task(652450)
		c4pl=false
	}
}

public bomb_explode()
{
	if(c4pl)
	{
		remove_task(652450)
		c4pl=false
	}
}

public show()
{
	if(!c4pl)
	{
		remove_task(652450)
		return
	}
	if(c4cd>=0.0)
	{
		temp=c4cd/c4max
		if(temp>=0.5)
		{
			r=510*(1.0-temp)
			g=255.0
		}
		if(temp<0.5)
		{
			r=255.0
			g=510*temp
		}
	
	
	for ( new i = 1 ; i <= get_maxplayers ( ) ; i ++ ) 
		if ( is_user_connected ( i )) {
			set_hudmessage ( floatround ( r ) , floatround ( g ) , 0 , -1.0 , 0.80 , 0 , _, 1.0 , _, _, 4 )
			ShowSyncHudMsg ( i, msg, "Tiempo de la c4: %d segundos^nantes de que explote." , floatround ( c4cd ) ) 
			}
		c4cd-=1.0
		
		
	// ESTO ES PARA CUANDO QUIERO QUE SOLO SEA VISIBLE PARA LOS ESPECTADORES	
	/*for ( new i = 1 ; i <= get_maxplayers ( ) ; i ++ ) 
		{
	if ( is_user_connected ( i ) && cs_get_user_team ( i ) == CS_TEAM_SPECTATOR) 
			{
            set_hudmessage ( floatround ( r ) , floatround ( g ) , 0 , -1.0 , 0.80 , 0 , _, 1.0 , _, _, 4 )
            ShowSyncHudMsg ( i, msg, "Tiempo de la c4: %d segundos antes de que explote." , floatround ( c4cd ) ) 
	   c4cd-=1.0
			}
		}
	}*/
	}
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
