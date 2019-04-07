/*
* trigger_once_mp
* Point Entity
* Variable Hullsize and percentage of living people
*/

class trigger_once_mp : ScriptBaseEntity {
	private bool m_fActivated = false;
	private string p_master = "";
	private float m_flPercentage = 0.5f; //Percentage of living people to be inside trigger to trigger
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		if( szKey == "m_flPercentage" ) {
			m_flPercentage = atof( szValue );
			return true;
		} else if( szKey == "minhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} else if( szKey == "maxhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		} else if( szKey == "master" ) {
			p_master = szValue;
			return true;
		} else {
			return BaseClass.KeyValue( szKey, szValue );
		}
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_NOT;
		self.pev.framerate 		= 1.0f;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
		
		SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 5.0f;
		
		self.Precache();
	}
	
	void TriggerThink() {
		
		if (!m_fActivated) {
			if (p_master == "" || g_EntityFuncs.IsMasterTriggered( p_master, null )) {
				CBasePlayer@ pPlayer;
				float totalPlayers = 0.0f;
				float playersTrigger = 0.0f;
				float currentPercentage = 0.0f;
				
				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
					@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				   
					if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
						continue;
					
					bool a = true;
					a = a && pPlayer.pev.origin.x + pPlayer.pev.maxs.x >= self.pev.origin.x + self.pev.mins.x;
					a = a && pPlayer.pev.origin.y + pPlayer.pev.maxs.y >= self.pev.origin.y + self.pev.mins.y;
					a = a && pPlayer.pev.origin.z + pPlayer.pev.maxs.z >= self.pev.origin.z + self.pev.mins.z;
					a = a && pPlayer.pev.origin.x + pPlayer.pev.mins.x <= self.pev.origin.x + self.pev.maxs.x;
					a = a && pPlayer.pev.origin.y + pPlayer.pev.mins.y <= self.pev.origin.y + self.pev.maxs.y;
					a = a && pPlayer.pev.origin.z + pPlayer.pev.mins.z <= self.pev.origin.z + self.pev.maxs.z;
					
					if( a )
						playersTrigger = playersTrigger + 1.0f;
					totalPlayers = totalPlayers + 1.0f;
				}
				
				if (totalPlayers > 0.0f) {
					currentPercentage = playersTrigger / totalPlayers + 0.00001f;

					if( currentPercentage >= m_flPercentage ) {
						m_fActivated = true;
				
						self.SUB_UseTargets( @self, USE_TOGGLE, 0 );
					}
				}
			}
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
	}
}

void RegisterTriggerOnceMpEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_once_mp", "trigger_once_mp" );
}
