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
const uint PENALTY_FREEZE = 100;

/**
*	Stores player data.
*/
final class PlayerData {
	private CBasePlayer@ m_pPlayer;
	
	/**
	*	Last time the player was on the ground.
	*/
	float m_flLastOnGroundTime;
	
	/**
	*	Last time the player was in the air.
	*/
	float m_flLastInAirTime;
	
	/**
	*	Was the player on ground during the last check time?
	*/
	bool m_bWasOnGround = true;
	
	/**
	*	Last time we checked this.
	*/
	float m_flLastCheckTime = 0;
	
	/**
	*	Last time we checked this.
	*/
	float m_flPositionZ = 0;
	
	/**
	*	Last position in the world.
	*/
	Vector m_vecPreviousOrigin;
	
	/**
	*	Last time the player moved.
	*/
	float m_flLastMoveTime = 0;
	
	/**
	*	Number of times this player had their speed clamped.
	*/
	uint m_uiNumClampedTimes = 0;
	
	/**
	*	Points that the Player need to get off before beingable to move.
	*/
	uint m_uiPenaltyPoints = 0;
	
	/**
	*   Velocity at jumpingPoint.
	*/
	float m_flVelocityStart = 0;
	
	/**
	*   Velocity at landingPoint.
	*/
	float m_flVelocityEnd = 0;
	
	/**
	*   Last 3 Speedaddition.
	*/
	array<float> m_flSpeedDifferences = {0,0,0};
	
	/**
	*   Last 3 Landingspeeds.
	*/
	array<float> m_flSpeedLandings = {0,0,0};
	
	/**
	*   Last 3 JumpZspeeds.
	*/
	array<float> m_flJumpZspeeds = {0,0,0};
	
	/**
	*   Last 3 GroundTimes.
	*/
	array<float> m_flGroundTimes = {0,0,0};
	
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
		m_flLastOnGroundTime = g_Engine.time;
		m_flLastInAirTime = g_Engine.time;
		m_flVelocityStart = 0;
		m_flVelocityEnd = 0;
		
		m_flLastMoveTime = g_Engine.time;
		
		m_bWasOnGround = true;
	}
}

/**
*	Player data array.
*/
array<PlayerData@> g_PlayerData;

CCVar@ g_pas_log_bhopping = null;

const Cvar@ g_psv_gravity = null;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sam \"Solokiller\" Vanheer" );
	//Made for ModRiot & friends.
	g_Module.ScriptInfo.SetContactInfo( "www.modriot.com" );
	
	@g_pas_log_bhopping = CCVar( "as_log_bhopping", "1", "Whether to log bunny hopping clamp events" );
	
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
	
	bool bBhopCheck = false;
	
	//The player last died before the previous check, so they haven't died since then. Nothing to reset.
	if( pPlayer.m_fDeadTime < pData.m_flLastCheckTime ){
		
		if( pData.m_vecPreviousOrigin != pPlayer.pev.origin )
			pData.m_flLastMoveTime = g_Engine.time;
	
		//Only check if the player is walking. If noclipping or on a ladder, this should be ignored.
		if( pPlayer.pev.movetype == MOVETYPE_WALK ){
			
			if( ( pPlayer.pev.flags & FL_ONGROUND ) != 0 ){
				//Only adjust total times if the player moved recently. Idle players won't be able to cheat by using their time spent idling.
				if( ( g_Engine.time - pData.m_flLastMoveTime ) <= MAX_IDLE_COUNTING_TIME ){
					if( !pData.m_bWasOnGround ){
						//pData.m_flTotalOnGroundTime += g_Engine.time - pData.m_flLastOnGroundTime;
						pData.m_flVelocityEnd = sqrt(pPlayer.pev.velocity.x*pPlayer.pev.velocity.x+pPlayer.pev.velocity.y*pPlayer.pev.velocity.y);
						
						for( int n = pData.m_flSpeedDifferences.length()-2; n >= 0; n-- ) {
							pData.m_flSpeedDifferences[n+1] = pData.m_flSpeedDifferences[n];
							pData.m_flSpeedLandings[n+1] = pData.m_flSpeedLandings[n];
						}
						pData.m_flSpeedDifferences[0] = (pData.m_flVelocityEnd - pData.m_flVelocityStart);
						pData.m_flSpeedLandings[0] = pData.m_flVelocityEnd;
						bBhopCheck = true;
					}
				}
					
				pData.m_flLastOnGroundTime = g_Engine.time;
				pData.m_bWasOnGround = true;
			}else{
				//Only adjust total times if the player moved recently. Idle players won't be able to cheat by using their time spent idling.
				if( ( g_Engine.time - pData.m_flLastMoveTime ) <= MAX_IDLE_COUNTING_TIME ){
					if( pData.m_bWasOnGround ){
						//pData.m_flTotalInAirTime += g_Engine.time - pData.m_flLastInAirTime;
						pData.m_flVelocityStart = sqrt(pPlayer.pev.velocity.x*pPlayer.pev.velocity.x+pPlayer.pev.velocity.y*pPlayer.pev.velocity.y);
						
						for( int n = pData.m_flGroundTimes.length()-2; n >= 0; n-- ) {
							pData.m_flGroundTimes[n+1] = pData.m_flGroundTimes[n];
							pData.m_flJumpZspeeds[n+1] = pData.m_flJumpZspeeds[n];
						}
						pData.m_flGroundTimes[0] = (g_Engine.time - pData.m_flLastInAirTime);
						pData.m_flJumpZspeeds[0] = pPlayer.pev.velocity.z;
						bBhopCheck = true;
					}
				}
					
				pData.m_flLastInAirTime = g_Engine.time;
				pData.m_bWasOnGround = false;
			}
		}
	}else{
		pData.ResetTrackingData();
	}

	// Set it to zero, because I am EVIL!
	// Also STUN the player!
	if(pData.m_uiPenaltyPoints > 0){
		pPlayer.pev.velocity.x = 0.0f;
		pPlayer.pev.velocity.y = 0.0f;
		if(abs(pData.m_vecPreviousOrigin.x-pPlayer.pev.origin.x)+abs(pData.m_vecPreviousOrigin.y-pPlayer.pev.origin.y) < 10.0f) {
			pPlayer.pev.origin.x = pData.m_vecPreviousOrigin.x;
			pPlayer.pev.origin.y = pData.m_vecPreviousOrigin.y;
		} else {
			pData.m_flPositionZ = pPlayer.pev.origin.z;
		}
		pData.m_uiPenaltyPoints--;
		
		if(pData.m_uiPenaltyPoints < 1){
			pPlayer.pev.origin.z = pData.m_flPositionZ;
			g_PlayerFuncs.SayText( pPlayer, "Anti-Bhop: You are no longer frozen.\n" );
		}
		
		for( uint n = 0; n < pData.m_flSpeedDifferences.length(); ++n ) {
			pData.m_flSpeedDifferences[n] = 0.0f;
		}
		
		bBhopCheck = false;
	}
	
	//check Bunnyhopping
	uint bIsBhop = 0;
	if(bBhopCheck){
		for( uint n = 0; n < pData.m_flSpeedDifferences.length(); ++n ) {
			if (pData.m_flSpeedDifferences[n] > 5.0f) bIsBhop++;
			if (pData.m_flSpeedLandings[n] > pPlayer.pev.maxspeed) bIsBhop++;
			if (pData.m_flGroundTimes[n] < 0.25f) bIsBhop++;
			if (pData.m_flJumpZspeeds[n] > 200.0f) bIsBhop++;
		}
	}
	
	if (bIsBhop > 10) {
		pData.m_flPositionZ = pPlayer.pev.origin.z;
		ClampVelocity( pPlayer, pData );
	}
	
	pData.m_vecPreviousOrigin = pPlayer.pev.origin;
	
	pData.m_flLastCheckTime = g_Engine.time;
}

/**
*	Clamps the given player's velocity.
*/
void ClampVelocity( CBasePlayer@ pPlayer, PlayerData@ pData )
{
	pData.m_uiPenaltyPoints = 200;
	++pData.m_uiNumClampedTimes;
	
	for( uint i = 1; i < pData.m_uiNumClampedTimes; ++i ){
		pData.m_uiPenaltyPoints = pData.m_uiPenaltyPoints * 3;
	}
	
	if( g_pas_log_bhopping.GetBool() ){
		g_Game.AlertMessage( at_logged, "Clamping velocity for player \"%1\" (%2) (clamped %3 times now)\n",
			pPlayer.pev.netname, g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ), pData.m_uiNumClampedTimes );
	}
	
	if(pData.m_uiNumClampedTimes == 1)
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Anti-Bhop: \"" + pPlayer.pev.netname +
				"\" (" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) +
				"), Bunnyhopping is NOT allowed! (Freeze-Time: 10 seconds)\n" );
	else if(pData.m_uiNumClampedTimes == 2)
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Anti-Bhop: \"" + pPlayer.pev.netname +
				"\" (" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) +
				"), You will be kicked if you Bunnyhop again! (Freeze-Time: 30 seconds)\n" );
	else {
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Player '" + pPlayer.pev.netname + "' was kicked for Bunnyhopping.\n" ); 
		g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"You were kicked for Bunnyhopping.\"\n");
		g_EngineFuncs.ServerExecute();
	}
}
