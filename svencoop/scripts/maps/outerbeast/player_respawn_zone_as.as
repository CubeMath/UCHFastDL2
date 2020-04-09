class player_respawn_zone_as : ScriptBaseEntity
{
	int respawnDeadPlayers = 0;
	int moveLivingPlayers = 0;
	int moveDeadPlayers = 0;
	int szRemoveOnFire = 1;

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "minhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		}
		else if( szKey == "maxhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else if( szKey == "respawndeadplayers" ) {
			respawnDeadPlayers = atoi( szValue );
			return true;
		}
		else if( szKey == "movelivingplayers" ) {
			moveLivingPlayers = atoi( szValue );
			return true;
		}
		else if( szKey == "movedeadplayers" ) {
			moveDeadPlayers = atoi( szValue );
			return true;
		}
		else if( szKey == "removeonfire" ) {
			szRemoveOnFire = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	
	void Spawn()
	{
		self.pev.movetype 	= MOVETYPE_NONE;
		self.pev.solid 		= SOLID_NOT;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
	}
	
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		for(int playerID = 0; playerID <= g_Engine.maxClients; playerID++ )
		{
			CBaseEntity@ ePlayer = g_PlayerFuncs.FindPlayerByIndex( playerID );
			CBasePlayer@ pPlayer = cast<CBasePlayer@>( ePlayer );
			
			bool respawnDead = false;
			bool moveLiving = false;
			
			if( respawnDeadPlayers == 1 ){ respawnDead = true; }
			if( moveLivingPlayers == 1 ){ moveLiving = true; }
			
			if( pPlayer !is null )
			{
				if( !playerInBox( pPlayer, self.pev.absmin, self.pev.absmax ) )
				{
					if( moveDeadPlayers == 1 || pPlayer.IsAlive() )
					{
						g_PlayerFuncs.RespawnPlayer( pPlayer, moveLiving, respawnDead );
						pPlayer.pev.origin = self.pev.absmin + ( (self.pev.absmax - self.pev.absmin) / 2 );
					}
				}
			}
		}
		
		if( szRemoveOnFire == 1 ){ g_EntityFuncs.Remove( self ); }
	}
	
}


bool playerInBox ( CBasePlayer@ pPlayer, Vector vMin, Vector vMax )
{
	if ( pPlayer.pev.origin.x >= vMin.x && pPlayer.pev.origin.x <= vMax.x )
	{
		if ( pPlayer.pev.origin.y >= vMin.y && pPlayer.pev.origin.y <= vMax.y )
		{
			if ( pPlayer.pev.origin.z >= vMin.z && pPlayer.pev.origin.z <= vMax.z )
			{
				return true;
			}
		}
	}
	
	return false;
}


void RegisterPlayerRespawnZoneASEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "player_respawn_zone_as", "player_respawn_zone_as" );
}