CScheduledFunction@ g_pIdleTestFunc = null;

const string g_KeyIdleTime = "$i_idletime";
const string g_KeyIdleAFKSign = "$i_afk_sign";
const string g_KeyIdleOrg = "$v_idleorg";
const int g_maxplayersAFK = 29;
const int g_maxTotalKick = 499;


final class PlayerData {
	private int total;
	private string steamID;
	private edict_t@ pPlayerEdict;
	private int lifeTime;
	
	PlayerData( string newsteamID, edict_t@ ply ){
		total = 0;
    steamID = newsteamID;
		@pPlayerEdict = @ply;
		lifeTime = 300;
	}
	
	string getSteamID(){
		return steamID;
	}
	
	int getTotal(){
		return total;
	}
	
	void setTotal(int newTotal){
		total = newTotal;
	}
	
	edict_t@ getPlayerEdict(){
		return pPlayerEdict;
	}
	
	bool shouldGiveUpEntry(){
		CBasePlayer@ pPlayer = null;
		
		//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() || @pPlayer.edict() != @pPlayerEdict)
				continue;
			
			lifeTime = 300;
			return false;
		}
		
		lifeTime--;
		
		if(lifeTime < 1) return true;
		
		return false;
	}
}

array<PlayerData@> g_PlayerData;
int plyDataSize;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("DeepBlueSea");
	g_Module.ScriptInfo.SetContactInfo("irc://irc.rizon.net/#/dev/null");
  
	plyDataSize = 0;
	g_PlayerData.resize( plyDataSize );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlayerInit );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );

	if (g_pIdleTestFunc !is null)
		g_Scheduler.RemoveTimer(g_pIdleTestFunc);

	@g_pIdleTestFunc = g_Scheduler.SetInterval("idletestfunc", 1.0f);
}

bool arrayContainsSteamID(string steamID){
	for(int i = 0; i < plyDataSize; i++){
		if(g_PlayerData[i].getSteamID() == steamID){
			return true;
		}
	}
	return false;
}

CBasePlayer@ GetPlayerBySteamId( const string& in szTargetSteamId ) {
	CBasePlayer@ pTarget;
	
	for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex ) {
		@pTarget = g_PlayerFuncs.FindPlayerByIndex( iIndex );
		
		if( pTarget !is null ) {
			const string szSteamId = g_EngineFuncs.GetPlayerAuthId( pTarget.edict() );
			
			if( szSteamId == szTargetSteamId )
				return pTarget;
		}
	}
	
	return null;
}

void addOneToArray(string steamID, edict_t@ ply){
	plyDataSize++;
	g_PlayerData.resize( plyDataSize );
	
	PlayerData data( steamID, ply );
	@g_PlayerData[ plyDataSize-1 ] = @data;
}

HookReturnCode PlayerInit( CBasePlayer@ pPlayer ){
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	pCustom.InitializeKeyvalueWithDefault(g_KeyIdleTime);
	pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );
  
  
	string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
  
	//AppendEntry, but first check if Entry already exists.
	if(!arrayContainsSteamID(steamID)){
		addOneToArray(steamID, pPlayer.edict());
	}
	
	return HOOK_CONTINUE;
}

int getArrayIdxUsingPlyEdict(edict_t@ ply){
	for(int i = 0; i < plyDataSize; i++){
		if(@g_PlayerData[i].getPlayerEdict() == @ply){
			return i;
		}
	}
	return -1;
}

bool bPlayerMoved( CBasePlayer@ pPlayer ){
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();

	bool bMoved = (pCustom.GetKeyvalue( g_KeyIdleOrg ).GetVector() != pPlayer.pev.origin);

	if (bMoved){
		pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );
    
    int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
    if(idx == -1){
      string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
      addOneToArray(steamID, pPlayer.edict());
    }else{
      if(g_PlayerData[idx].getTotal() > 0){
        g_PlayerData[idx].setTotal(g_PlayerData[idx].getTotal()-1);
      }
    }
	}
  
	return bMoved;
}

void delOneToArray(int idx){
	plyDataSize--;
	for(int i = idx; i < plyDataSize; i++){
		@g_PlayerData[ i ] = @g_PlayerData[ i+1 ];
	}
	g_PlayerData.resize( plyDataSize );
}

void idletestfunc(){ 
	string m_sMap = g_Engine.mapname;
	if(m_sMap == "of0a0") return;
	if(m_sMap == "th_ep1_00") return;
	if(m_sMap == "dy_outro") return;
	
  int plyCnt = 0;
  int g_maxplayersAFK = 29;
  
	for( int i = 1; i <= g_Engine.maxClients; ++i )	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		if (pPlayer !is null && pPlayer.IsConnected()) ++plyCnt;
  }
  
	for( int i = 1; i <= g_Engine.maxClients; ++i )	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
    
		if (pPlayer !is null && pPlayer.IsConnected()){
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue valuePlayerIdle( pCustom.GetKeyvalue( g_KeyIdleTime ) );
      
      int plyIdle = valuePlayerIdle.GetInteger();
      bool alive = pPlayer.IsAlive();
      
			if (!bPlayerMoved(pPlayer)){
        if(alive) {
          ++plyIdle;
        }
			}else{
        plyIdle = 0;
        pCustom.SetKeyvalue( g_KeyIdleAFKSign, 0);
      }
      
      pCustom.SetKeyvalue( g_KeyIdleTime, plyIdle);
      
      int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
      if(idx == -1){
        string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        addOneToArray(steamID, pPlayer.edict());
        idx = plyDataSize - 1;
      }
      
      int totalVal = g_PlayerData[idx].getTotal();
      int maxIdle = 100;
      if(totalVal > 0) maxIdle = 30;
      
      if(
          m_sMap == "hl_c08_a2" &&
          pPlayer.pev.origin.x > -3174 && pPlayer.pev.origin.x < -2788 &&
          pPlayer.pev.origin.y > 384 && pPlayer.pev.origin.y < 960 &&
          pPlayer.pev.origin.z > -1400 && pPlayer.pev.origin.z < -1000
      ) maxIdle = 3;
      
			if (valuePlayerIdle.GetInteger() >= maxIdle ){
				pCustom.SetKeyvalue( g_KeyIdleTime, 0);
        if(totalVal > g_maxTotalKick){
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayer.pev.netname + "' was kicked for being AFK.\n" ); 
          g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"You were kicked for being AFK.\"\n");
          g_EngineFuncs.ServerExecute();
        }else if(plyCnt > g_maxplayersAFK){
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayer.pev.netname + "' was kicked for being AFK on a full server.\n" ); 
          g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"You were kicked for being AFK on a full server.\"\n");
          g_EngineFuncs.ServerExecute();
        }else{
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayer.pev.netname + "' was slayed for being AFK longer than " + maxIdle + " seconds.\n" );
          entvars_t@ world = g_EntityFuncs.Instance(0).pev;
          pPlayer.TakeDamage(world, world, 2048.0f, DMG_ALWAYSGIB|DMG_CRUSH);
          
          g_PlayerData[idx].setTotal(g_PlayerData[idx].getTotal() + maxIdle);
          pCustom.SetKeyvalue( g_KeyIdleAFKSign, 1);
        }
			} else {
				if (plyIdle > 0 && (valuePlayerIdle.GetInteger() >= maxIdle - 10 )) {
					int timeRemaining = maxIdle - valuePlayerIdle.GetInteger();
          if(totalVal > g_maxTotalKick || plyCnt > g_maxplayersAFK)
            g_PlayerFuncs.SayText( pPlayer, "AFK-Kick: You will be kicked in: "+timeRemaining+"\n" );
          else
            g_PlayerFuncs.SayText( pPlayer, "AFK-Kick: You will be slayed in: "+timeRemaining+"\n" );
				}
			}
		}
	}
  
  if(plyCnt > g_maxplayersAFK){
    CBasePlayer@ pPlayerAFK = null;
    int afkTotal = 99;
    
    for( int i = 1; i <= g_Engine.maxClients; ++i )	{
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
      
      if (pPlayer !is null && pPlayer.IsConnected() && !pPlayer.IsAlive()){
        CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue valuePlayerAFKSign( pCustom.GetKeyvalue( g_KeyIdleTime ) );
        int afkSign = valuePlayerAFKSign.GetInteger();
        if(afkSign == 1) {
          int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
          if(idx == -1){
            string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
            addOneToArray(steamID, pPlayer.edict());
          }else{
            int plyIdle = g_PlayerData[idx].getTotal();
            
            if(plyIdle > afkTotal){
              @pPlayerAFK = @pPlayer;
              afkTotal = plyIdle;
            }
          }
        }
      }
    }
    
    if(pPlayerAFK !is null){
      g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayerAFK.pev.netname + "' was kicked for being AFK on a full server.\n" ); 
      g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayerAFK.edict()) + "\" \"You were kicked for being AFK on a full server.\"\n");
      g_EngineFuncs.ServerExecute();
    }
  }
  
	for(int i = 0; i < plyDataSize; i++){
		if(g_PlayerData[i].shouldGiveUpEntry()){
			delOneToArray(i);
			i--;
		}
	}
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
	
	//Find and Delete Entry
	int targetIndex = getArrayIdxUsingPlyEdict(pPlayer.edict());
	if(targetIndex != -1){
		delOneToArray(targetIndex);
	}
	
	//SOLVED: People might disconnect while on a MapChange and avoid calling this Hook.
	
	return HOOK_CONTINUE;
}
