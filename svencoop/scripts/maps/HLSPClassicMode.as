/*
* This script implements HLSP specific Classic Mode features
*/

#include "hl_weapons/weapon_hl357"
#include "cubemath/item_healthkit2"

array<ItemMapping@> g_ItemMappings = {
	ItemMapping( "weapon_m16", "weapon_9mmAR" ),
	ItemMapping( "item_healthkit", "item_healthkit2" ),
	ItemMapping( "weapon_357", GetHLPYTHONName() )
};

bool ShouldRestartIfClassicModeChangesOn( const string& in szMapName )
{
	return  szMapName != "-sp_campaign_portal" &&
			szMapName != "hl_c00" &&
			szMapName != "hl_c01_a1" &&
			szMapName != "hl_c01_a2" &&
			szMapName != "hl_c18" &&
			szMapName != "ba_tram1" &&
			szMapName != "ba_tram2" &&
			szMapName != "ba_tram3" &&
			szMapName != "ba_security1" &&
			szMapName != "ba_security2" &&
			szMapName != "ba_maint" &&
			szMapName != "ba_elevator" &&
			szMapName != "ba_outro" &&
			szMapName != "of0a0" &&
			szMapName != "dynamic_mapvote";
}

void ClassicModeMapInit()
{
	// g_Game.PrecacheModel( "models/w_medkit.mdl" );
	// g_SoundSystem.PrecacheSound( "items/smallmedkit1.wav" );
	// g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );
	
	RegisterHLPYTHON();
	RegisterItemHealthkit2CustomEntity();
	g_ClassicMode.SetItemMappings( @g_ItemMappings );

	//We want classic mode voting to be enabled here
	g_ClassicMode.EnableMapSupport();
	
	if( !ShouldRestartIfClassicModeChangesOn( g_Engine.mapname ) )
		g_ClassicMode.SetShouldRestartOnChange( false );
}

void ClassicModeMapActivate()
{
	for( int i = 0; i < g_Engine.maxEntities; ++i ) {
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
		if( pEntity is null ) continue;
		if( pEntity.pev.classname != "item_healthkit" ) continue;
		
		g_EntityFuncs.Create( "item_healthkit2", pEntity.pev.origin, pEntity.pev.angles, false);
		g_EntityFuncs.Remove( pEntity );
	}
}

void MapActivate()
{
	ClassicModeMapActivate();
}

/*
* This is the function to use with trigger_script: triggering it will start classic mode. If the map is not hl_c00, the map is restarted
*/
void StartClassicModeVote( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	//Don't force the vote; only start if needed
	StartClassicModeVote( false );
}

void StartClassicModeVote( const bool bForce )
{
	if( !bForce && g_ClassicMode.IsStateDefined() )
		return;
		
	float flVoteTime = g_EngineFuncs.CVarGetFloat( "mp_votetimecheck" );
	
	if( flVoteTime <= 0 )
		flVoteTime = 16;
		
	float flPercentage = g_EngineFuncs.CVarGetFloat( "mp_voteclassicmoderequired" );
	
	if( flPercentage <= 0 )
		flPercentage = 51;
		
	Vote vote( "HLSP Classic Mode vote", ( g_ClassicMode.IsEnabled() ? "Disable" : "Enable" ) + " Classic Mode?", flVoteTime, flPercentage );
	
	vote.SetVoteBlockedCallback( @ClassicModeVoteBlocked );
	vote.SetVoteEndCallback( @ClassicModeVoteEnd );
	
	vote.Start();
}

void ClassicModeVoteBlocked( Vote@ pVote, float flTime )
{
	// Voting is blocked at the moment (another vote in progress...).
	// Try again later.
	
	// The 3rd argument will be passed to the scheduled function.
	g_Scheduler.SetTimeout( "StartClassicModeVote", flTime, false );
}

void ClassicModeVoteEnd( Vote@ pVote, bool bResult, int iVoters )
{
	if( !bResult )
	{
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "Vote for Classic Mode failed" );
		return;
	}
	
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "Vote to " + ( !g_ClassicMode.IsEnabled() ? "Enable" : "Disable" ) + " Classic mode passed\n" );
	
	g_ClassicMode.Toggle();
}

//Leave this out of release builds!
CConCommand g_ClassicModeVote( "debug_classicmodevote", "Debug only: starts the Classic Mode vote", @ClassicModeVoteCallback );

void ClassicModeVoteCallback( const CCommand@ pArgs )
{
	StartClassicModeVote( false );
}
