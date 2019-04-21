final class PlayerChatData {

	/**
	*	Last 5 Chatmessages
	*/
	array<string> m_messages = { "", "", "", "", "" };
	
	/**
	*	Last 5 TimeStamps Chatmessages
	*/
	array<double> m_timestamps = { -1, -1, -1, -1, -1 };
	
	/**
	*	Muted until TimeStamp
	*/
	double m_muteTime = -1.0;
	
	/**
	*	Warning-Time
	*/
	double m_warnTime = -1.0;

	PlayerChatData(){
		for( int i = 0; i < 5; ++i ){
			m_messages[i] = "";
			m_timestamps[i] = -1.0;
		}
		m_muteTime = -1.0;
		m_warnTime = -1.0;
	}
}

array<PlayerChatData@> g_PlayerChatData;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSaySpamo );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnectSpamo );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServerSpamo );
	
	g_PlayerChatData.resize( g_Engine.maxClients );
	
	//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		PlayerChatData data();
		@g_PlayerChatData[ iPlayer ] = @data;
	}
}

void MapInit(){

	//maxplayers normally can't be changed at runtime, but if that ever changes, we are fucked.
	g_PlayerChatData.resize( g_Engine.maxClients );

	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		PlayerChatData data();
		@g_PlayerChatData[ iPlayer ] = @data;
	}
	
}

HookReturnCode ClientPutInServerSpamo( CBasePlayer@ pPlayer ){
	PlayerChatData data();
	@g_PlayerChatData[ pPlayer.entindex() - 1 ] = @data;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientSaySpamo(SayParameters@ pParams){
	if(pParams.ShouldHide) return HOOK_CONTINUE;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	string str = pParams.GetCommand();
  string str2 = str;
  str2.ToUppercase();
	PlayerChatData@ pData = g_PlayerChatData[ pPlayer.entindex() - 1 ];
	
	if (str.Length() < 1){
		return HOOK_CONTINUE;
	}
	
	if (pData.m_muteTime > g_Engine.time){
		pParams.ShouldHide = true;
		
		double timeLeft = pData.m_muteTime - g_Engine.time;
		int seconds = int(timeLeft);
		int secDiv10 = int(timeLeft*10.0) % 10;
		
		string aStr = "AntiSpam: Your Mute will end in: "+seconds+"."+secDiv10+"s.\n";
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, aStr );
		return HOOK_CONTINUE;
	}
	
	if (pParams.ShouldHide){
		return HOOK_CONTINUE;
	}
	
  if (
    g_PlayerFuncs.AdminLevel(pPlayer) >= ADMIN_YES && (
      str2 == "!ARROW" ||
      str2 == "!ARROW_DELETE" ||
      str2 == "!ARROW_REMOVE" ||
      str2 == "!ARROW_CLEAR" ||
      str2 == "!ARROW_CLEAN"
    )
  ){
		return HOOK_CONTINUE;
  }
  
	for(int i = 4; i > 0; --i ){
		pData.m_messages[i] = pData.m_messages[i-1];
		pData.m_timestamps[i] = pData.m_timestamps[i-1];
	}
	
	pData.m_messages[0] = str;
	pData.m_timestamps[0] = g_Engine.time;
	
	double muteScore = 0.0;
	
	for(int i = 0; i < 5; ++i ){
		string str3 = pData.m_messages[i];
		
		muteScore += str3.Length() * 0.1;
	}
	
	for(int j = 1; j < 5; ++j ){
		for(int i = 0; i < j; ++i ){
			if (pData.m_timestamps[i] != -1 && pData.m_messages[i] == pData.m_messages[j]) {
				double timeDif = pData.m_timestamps[i] - pData.m_timestamps[j];
				
				timeDif = (60.0 - timeDif)/60.0;
				if(timeDif < 0.0) timeDif = 0.0;
				
				//g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "AntiSpam: timeDif is "+timeDif+"\n" );
				
				muteScore += 25.0*timeDif;
			}
		}
	}
	
	if(pData.m_timestamps[1] != -1){
		double timeDif = pData.m_timestamps[0] - pData.m_timestamps[1];
		if(timeDif < 0.4) muteScore += 10.0;
		if(timeDif < 0.8) muteScore += 5.0;
		if(timeDif < 1.5) muteScore += 3.0;
		if(timeDif < 5.0) muteScore += 2.0;
		if(timeDif < 30.0) muteScore += 1.0;
	}
	
	if(pData.m_timestamps[2] != -1){
		double timeDif = pData.m_timestamps[0] - pData.m_timestamps[2];
		if(timeDif < 0.5) muteScore += 20.0;
		if(timeDif < 1.5) muteScore += 10.0;
		if(timeDif < 3.0) muteScore += 5.0;
		if(timeDif < 10.0) muteScore += 3.0;
		if(timeDif < 60.0) muteScore += 1.0;
	}
	
	if(pData.m_timestamps[3] != -1){
		double timeDif = pData.m_timestamps[0] - pData.m_timestamps[3];
		if(timeDif < 0.6) muteScore += 50.0;
		if(timeDif < 2.5) muteScore += 20.0;
		if(timeDif < 5.0) muteScore += 10.0;
		if(timeDif < 17.5) muteScore += 5.0;
		if(timeDif < 120.0) muteScore += 1.0;
	}
	
	if(pData.m_timestamps[4] != -1){
		double timeDif = pData.m_timestamps[0] - pData.m_timestamps[4];
		if(timeDif < 0.75) muteScore += 100.0;
		if(timeDif < 3.5) muteScore += 50.0;
		if(timeDif < 7.5) muteScore += 20.0;
		if(timeDif < 25.0) muteScore += 10.0;
		if(timeDif < 300.0) muteScore += 1.0;
	}
	
	if(muteScore>250.0){
		pParams.ShouldHide = true;
		
		for( int i = 0; i < 5; ++i ){
			pData.m_messages[i] = "";
			pData.m_timestamps[i] = -1.0;
		}
		pData.m_muteTime = g_Engine.time+60.0;
		pData.m_warnTime = -1.0;
		
		string msg = "AntiSpam: "+pPlayer.pev.netname+" is muted for 1 minute.\n";
		g_Game.AlertMessage( at_logged, msg );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, msg );
		
	} else if(muteScore>100.0){
		if (pData.m_warnTime == -1.0){
			pData.m_warnTime = g_Engine.time+3.0;
			
			string msg = "AntiSpam: Please do NOT spam the Server.\n";
			g_Game.AlertMessage( at_logged, msg );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, msg );
			
		} else if (pData.m_warnTime < g_Engine.time) {
			pParams.ShouldHide = true;
			
			for( int i = 0; i < 5; ++i ){
				pData.m_messages[i] = "";
				pData.m_timestamps[i] = -1.0;
			}
			pData.m_muteTime = g_Engine.time+30.0;
			pData.m_warnTime = -1.0;
			
			string msg = "AntiSpam: "+pPlayer.pev.netname+" is muted for 30 seconds.\n";
			g_Game.AlertMessage( at_logged, msg );
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, msg );

		}
	} else if(muteScore<75.0){
		pData.m_warnTime = -1.0;
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnectSpamo(CBasePlayer@ pPlayer){
	PlayerChatData data();
	@g_PlayerChatData[ pPlayer.entindex() - 1 ] = @data;
	
	return HOOK_CONTINUE;
}
