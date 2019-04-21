CCVar@ g_pMaxIdleTime;
CScheduledFunction@ g_pIdleTestFunc = null;

const string g_KeyIdleTime = "$i_idletime";

const string g_KeyIdleOrg = "$v_idleorg";

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("DeepBlueSea");
	g_Module.ScriptInfo.SetContactInfo("irc://irc.rizon.net/#/dev/null");

	@g_pMaxIdleTime = CCVar("maxidletime", 120, "maximum idle time before players get kicked for being afk (in seconds)", ConCommandFlag::AdminOnly);

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlayerInit );

	if (g_pIdleTestFunc !is null) 
		g_Scheduler.RemoveTimer(g_pIdleTestFunc);

	@g_pIdleTestFunc = g_Scheduler.SetInterval("idletestfunc", 1.0f);
}
//============================================================================//
HookReturnCode PlayerInit( CBasePlayer@ pPlayer )
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	pCustom.InitializeKeyvalueWithDefault(g_KeyIdleTime);

	pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );

	return HOOK_CONTINUE;
}
//============================================================================//
bool bPlayerMoved( CBasePlayer@ pPlayer )
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();

	bool bMoved = (pCustom.GetKeyvalue( g_KeyIdleOrg ).GetVector() != pPlayer.pev.origin);

	if (bMoved)
	{
		pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );
	}

	return bMoved;
}
//============================================================================//
void idletestfunc()
{ 
	string m_sMap = g_Engine.mapname;
	if(m_sMap == "of0a0") return;
	if(m_sMap == "th_ep1_00") return;
	if(m_sMap == "dy_outro") return;
	
	for( int i = 1; i <= g_Engine.maxClients; ++i )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

		//if (pPlayer !is null && pPlayer.IsConnected() && g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES)
		if (pPlayer !is null && pPlayer.IsConnected())
		{
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue valuePlayerIdle( pCustom.GetKeyvalue( g_KeyIdleTime ) );

			if (!bPlayerMoved(pPlayer) && pPlayer.IsAlive())
				pCustom.SetKeyvalue( g_KeyIdleTime, valuePlayerIdle.GetInteger() + 1);				
			else			
				pCustom.SetKeyvalue( g_KeyIdleTime, 0);

			
			if (valuePlayerIdle.GetInteger() >= g_pMaxIdleTime.GetInt() )
			{
				pCustom.SetKeyvalue( g_KeyIdleTime, 0);
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayer.pev.netname + "' was kicked for being AFK longer than " + g_pMaxIdleTime.GetInt() + " seconds.\n" ); 
				g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"You were kicked for being AFK longer than " + g_pMaxIdleTime.GetInt() + " seconds.\"\n");
				g_EngineFuncs.ServerExecute();
			} else {
				if ((valuePlayerIdle.GetInteger() >= g_pMaxIdleTime.GetInt()-10 )) {
					int timeRemaining = g_pMaxIdleTime.GetInt() - valuePlayerIdle.GetInteger();
					g_PlayerFuncs.SayText( pPlayer, "AFK-Kick: You will be kicked in: "+timeRemaining+"\n" );
				}
			}
		}
	}
}
