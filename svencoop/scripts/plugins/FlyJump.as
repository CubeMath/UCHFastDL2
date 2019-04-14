//////////////////////////////////////////////////////////////////////////////////
//
//	Anti bunny hopping script.
//	This script will check the velocities of every player and see if they spend most of their time bunny hopping.
//	If so, their speed is clamped.
//	The script is not perfect and can result in false positives if they spend a lot of time in the air for other reasons.
//
//////////////////////////////////////////////////////////////////////////////////

/**
*	How long idle players have their time counted for. Helps prevent cheating.
*	TODO: tune this.
*/
const float MAX_IDLE_COUNTING_TIME = 5.0f;

/**
*	Time the player can be in the air before the bunny hopping check kicks in.
*	TODO: tune this.
*/
//const float MAX_INAIR_TIME = 0.50;

/**
*	If the player spends this much percent of the time spent on the ground in the air, clamp velocity to block bunny hopping.
*	In other words, if the time spent in the air is 2/3rds of the total time spent on the server, clamp velocity.
*	TODO: tune this.
*/
//const float AIR_GROUND_FACTOR = 1.5;

/**
*	Only allow bunny jumping up to 1.7x server / player maxspeed setting
*	Github Half-Life SDK setting.
*/
//const float BUNNYJUMP_MAX_SPEED_FACTOR = 1.7f;

/**
*	Gravity to consider the default. Used to determine how current player gravity affects calculations.
*/
//const float DEFAULT_GRAVITY = 800;

/**
*	Penaltypoints
*/
//const uint PENALTY_FREEZE = 100;

/**
*	Stores player data.
*/
final class PlayerData {
	private CBasePlayer@ m_pPlayer;
	
	/**
	*	Last time we checked this.
	*/
	float m_flLastCheckTime = 0;
	
	/**
	*	Last position in the world.
	*/
	Vector m_vecPreviousOrigin;
	
	/**
	*	Last time the player moved.
	*/
	float m_flLastMoveTime = 0;
	
	/**
	*	@return The player associated with this data.
	*/
	CBasePlayer@ Player
	{
		get const { return m_pPlayer; }
	}
	
	PlayerData( CBasePlayer@ pPlayer ){
		@m_pPlayer = pPlayer;
		
		ResetTrackingData();
		
		m_vecPreviousOrigin = pPlayer.pev.origin;
	}
	
	void ResetTrackingData(){
		m_flLastMoveTime = g_Engine.time;
	}
}

/**
*	Player data array.
*/
array<PlayerData@> g_PlayerData;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sam \"Solokiller\" Vanheer" );
	//Made for ModRiot & friends.
	g_Module.ScriptInfo.SetContactInfo( "www.modriot.com" );
	
	//Cache the gravity pointer for performance reasons.
	//Check for velocity every 0.1 seconds.
	g_Scheduler.SetInterval( "ClampVelocities", 0.05 );
	
	g_PlayerData.resize( g_Engine.maxClients );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	
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

void MapInit()
{
	//maxplayers normally can't be changed at runtime, but if that ever changes, account for it.
	g_PlayerData.resize( g_Engine.maxClients );

	for( uint uiIndex = 0; uiIndex < g_PlayerData.length(); ++uiIndex ){
		@g_PlayerData[ uiIndex ] = null;
	}
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	PlayerData data( pPlayer );
	@g_PlayerData[ pPlayer.entindex() - 1 ] = @data;

	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	@g_PlayerData[ pPlayer.entindex() - 1 ] = null;

	return HOOK_CONTINUE;
}
 
 /**
 *	Checks all players on the server and clamps their velocity if they appear to be bunny hopping.
 */
void ClampVelocities()
{
	CBasePlayer@ pPlayer = null;
	
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;
		
		HandlePlayer( pPlayer );
	}
}

/**
*	Checks if the given player should have their velocity clamped for bunny hopping.
*/
void HandlePlayer( CBasePlayer@ pPlayer )
{
	PlayerData@ pData = g_PlayerData[ pPlayer.entindex() - 1 ];
	
	//The player last died before the previous check, so they haven't died since then. Nothing to reset.
	if( pPlayer.m_fDeadTime < pData.m_flLastCheckTime ){
		
		if( pData.m_vecPreviousOrigin != pPlayer.pev.origin )
			pData.m_flLastMoveTime = g_Engine.time;
	
		//Only check if the player is walking. If noclipping or on a ladder, this should be ignored.
		if( pPlayer.pev.movetype == MOVETYPE_WALK ){
			
			if( ( pPlayer.pev.flags & FL_ONGROUND ) != 0 ){
			}else{
				//Only adjust total times if the player moved recently. Idle players won't be able to cheat by using their time spent idling.
				if( ( g_Engine.time - pData.m_flLastMoveTime ) <= MAX_IDLE_COUNTING_TIME ){
					pPlayer.pev.velocity.x = cos(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 512.0f;
					pPlayer.pev.velocity.y = sin(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 512.0f;
					pPlayer.pev.velocity.z = sin(pPlayer.pev.angles.x/60.0f*3.1415927f) * 512.0f ;
				}
			}
		}
	}else{
		pData.ResetTrackingData();
	}
	
	pData.m_vecPreviousOrigin = pPlayer.pev.origin;
	
	pData.m_flLastCheckTime = g_Engine.time;
}
