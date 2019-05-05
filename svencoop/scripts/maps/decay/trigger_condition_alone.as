
class trigger_condition_alone : ScriptBaseEntity {
	private float m_flPercentage = 0.5f; //Percentage of living people to be inside trigger to trigger
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		if( szKey == "message" ) {
			self.pev.message = szValue;
			return true;
		} else if( szKey == "netname" ) {
			self.pev.netname = szValue;
			return true;
		} else {
			return BaseClass.KeyValue( szKey, szValue );
		}
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
    
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_NOT;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
    CBasePlayer@ pPlayer;
    int totalPlayers = 0;
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
      @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
       
      if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
        continue;
      
      ++totalPlayers;
    }
    
    if (totalPlayers < 2) {
			g_EntityFuncs.FireTargets(self.pev.message, null, null, USE_TOGGLE, 0.0f, 0.0f);
    }else{
			g_EntityFuncs.FireTargets(self.pev.netname, null, null, USE_TOGGLE, 0.0f, 0.0f);
    }
	}
}

void RegisterTriggerAloneCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_condition_alone", "trigger_condition_alone" );
}
