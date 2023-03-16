#include <superheromod>

new gKillStreak[SH_MAXSLOTS+1]
new pcvarStreak, pcvarXPToAdd

public plugin_init()
{
	//Credit geos to fr33m@n for fixing the code!
	register_plugin("SUPERHERO XP on killstreak", "1.2", "Jelle")
	
	pcvarStreak 	= register_cvar("killstreak_killsneed", "7")		//racha necesaria de kills?
	pcvarXPToAdd	= register_cvar("killstreak_xptoadd", "1024")	//xp agregada!
	
	register_clcmd("say /racha", "inforachas");
	register_clcmd("say /rachas", "inforachas");
}

public client_connect(id)
	gKillStreak[id] = 1

public sh_client_death(victim, attacker)
{
	if ( !sh_is_active() ) return
	
	if ( is_user_connected(attacker) && is_user_connected(victim) && victim != attacker ) {
		new iAttackerKillStreak = gKillStreak[attacker]	
		
		if ( iAttackerKillStreak < get_pcvar_num(pcvarStreak) ) {
			new iNewAttackerKillStreak = gKillStreak[attacker]++
			if ( iNewAttackerKillStreak > 4 ) {
				// %d is for integer (or %i), %s for string, dammit...
				sh_chat_message(attacker, -1, "%s Tenes Ahora %d Kills en Racha!", iNewAttackerKillStreak == 5 ? "" : "Sumaste una kill a tu Racha! ", iNewAttackerKillStreak)
			}
		}
		else	{
			gKillStreak[attacker] = 1
			new iXPToAdd = get_pcvar_num(pcvarXPToAdd)
			
			sh_chat_message(attacker, -1, "Ganaste %d XP por tener una Racha de %d Kills!", iXPToAdd, iAttackerKillStreak)
			sh_set_user_xp(attacker, iXPToAdd, true)
		}
		
		gKillStreak[victim] = 1
		
		if ( iAttackerKillStreak > 4 ) {
			sh_chat_message(victim, -1, "Tu Racha de Kills fue reiniciada porque te mataron.")
		}
	}
}
//-----------------------------------------------------------------
public inforachas(id)
{
	sh_chat_message(id, -1, "Para conseguir XP por Racha de Kills deberas matar a %d seguidos sin morir en una o más rondas.", get_pcvar_num(pcvarStreak) )
	sh_chat_message(id, -1, "Obtendrás %d de XP si logras conseguirla.", get_pcvar_num(pcvarXPToAdd) )
} 
//-----------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1030{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
