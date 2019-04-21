
final class PlayerData {
	private CBasePlayer@ m_pPlayer;
	
	bool m_voted = false;
	
	CBasePlayer@ Player{
		get const { return m_pPlayer; }
	}
	
	PlayerData( CBasePlayer@ pPlayer ){
		@m_pPlayer = pPlayer;
	}
}

array<PlayerData@> g_PlayerData;

const Cvar@ g_psv_gravity = null;
 
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	g_PlayerData.resize( g_Engine.maxClients );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	
	CBasePlayer@ pPlayer = null;
	
	//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;
		
		PlayerData data( pPlayer );
		@g_PlayerData[ pPlayer.entindex() - 1 ] = @data;
	}
}

void MapInit(){
	//maxplayers normally can't be changed at runtime, but if that ever changes, account for it.
	g_PlayerData.resize( g_Engine.maxClients );

	for( uint uiIndex = 0; uiIndex < g_PlayerData.length(); ++uiIndex ){
		@g_PlayerData[ uiIndex ] = null;
	}
}

void checkSuccess2(){
  g_EngineFuncs.ChangeLevel("dynamic_mapvote");
}

void checkSuccess(){
	string mapname = string(g_Engine.mapname);
	if(mapname.opEquals("dynamic_mapvote")) return;
  
  int total = 0;
  int voted = 0;
  
	CBasePlayer@ pPlayer = null;
  for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;
		
    PlayerData@ pData = g_PlayerData[ pPlayer.entindex() - 1 ];
    if(pData.m_voted)
      voted++;
    total++;
	}
  
  if(voted > 0 && total > 0 && voted * 4 >= total * 3){
    string aStr = "Mapvote: Voted to dynamic_mapvote successful.\n";
    g_Game.AlertMessage( at_logged, aStr );
    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
    
    if(total < 2){
      g_Scheduler.SetTimeout("checkSuccess2", 0.1f);
    }else{
      NetworkMessage message(MSG_ALL, NetworkMessages::SVC_INTERMISSION, null);
      message.End();
      g_Scheduler.SetTimeout("checkSuccess2", 4.0f);
    }
  }
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
	PlayerData data( pPlayer );
	@g_PlayerData[ pPlayer.entindex() - 1 ] = @data;
  checkSuccess();
  
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
	@g_PlayerData[ pPlayer.entindex() - 1 ] = null;
  checkSuccess();
  
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	string str = pParams.GetCommand();
	str.ToUppercase();
  CBasePlayer @ply = pParams.GetPlayer();
	
	if (
      ply !is null && (
          (str.Find("RTV") <= 1 && str.Length() < 5) ||
          (str.Find("MAPVOTE") <= 1 && str.Length() < 9) ||
          (str.Find("VOTEMAP") <= 1 && str.Length() < 9)
      )
  ) {
    string mapname = string(g_Engine.mapname);
    if(mapname.opEquals("dynamic_mapvote"))
      return HOOK_CONTINUE;
    
    PlayerData@ pData = g_PlayerData[ ply.entindex() - 1 ];
    
    if(pData.m_voted){
      string aStr = "Mapvote: You already voted to change to dynamic_mapvote.\n";
      g_PlayerFuncs.ClientPrint( ply, HUD_PRINTTALK, aStr );
    }else{
      string aStr = "Mapvote: " + ply.pev.netname + " voted to change to dynamic_mapvote.\n";
      g_Game.AlertMessage( at_logged, aStr );
      g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
      
      pData.m_voted = true;
      checkSuccess();
    }
  }
  
	return HOOK_CONTINUE;
}
