//////////////////////////////////////////////////////////////////////////////////
//
//	Anti bunny hopping script.
//	This script will check the velocities of every player and see if they spend most of their time bunny hopping.
//	If so, their speed is clamped.
//	The script is not perfect and can result in false positives if they spend a lot of time in the air for other reasons.
//
//////////////////////////////////////////////////////////////////////////////////

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
	*   Velocity at landingPoint.
	*/
	float m_flVelocityZ = 0;
	
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
	}
	
	void ResetTrackingData(){
		m_flVelocityZ = 0;
	}
}

/**
*	Player data array.
*/
array<PlayerData@> g_PlayerData;

const Cvar@ g_psv_gravity = null;
 
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sam \"Solokiller\" Vanheer" );
	//Made for ModRiot & friends.
	g_Module.ScriptInfo.SetContactInfo( "www.modriot.com" );
	
	//Cache the gravity pointer for performance reasons.
	@g_psv_gravity = g_EngineFuncs.CVarGetPointer( "sv_gravity" );
	
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
		
		//Only check if the player is walking. If noclipping or on a ladder, this should be ignored.
		if( pPlayer.pev.movetype == MOVETYPE_WALK ){
			
			if( pData.m_flVelocityZ < -150.0f ){
				if( pPlayer.pev.velocity.z > pData.m_flVelocityZ ){
					
					float speed = sqrt(pPlayer.pev.velocity.x*pPlayer.pev.velocity.x+pPlayer.pev.velocity.y*pPlayer.pev.velocity.y);
					
					if(speed > 270.0f){
						float slowDown = 270.0f / speed;
						slowDown *= slowDown;
						
						if(slowDown < 0.5f) slowDown = 0.5f;
						
						pPlayer.pev.velocity.x = pPlayer.pev.velocity.x * slowDown;
						pPlayer.pev.velocity.y = pPlayer.pev.velocity.y * slowDown;
					}
					
					//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Anti-Bhop: " + sqrt(pPlayer.pev.velocity.x*pPlayer.pev.velocity.x+pPlayer.pev.velocity.y*pPlayer.pev.velocity.y) + "\n" );
				}
			}
			
			pData.m_flVelocityZ = pPlayer.pev.velocity.z;
		}
	}else{
		pData.ResetTrackingData();
	}

	pData.m_flLastCheckTime = g_Engine.time;
}
