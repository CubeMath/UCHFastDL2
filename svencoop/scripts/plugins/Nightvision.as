//Version 1.3
CScheduledFunction@ g_pNVThinkFunc = null;
dictionary g_PlayerNV;
const Vector NV_COLOR( 0, 255, 0 );
const int g_iRadius = 40;
const int iDecay = 1;
const int iLife	= 2;
const int iBrightness = 64;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Nero" );
	g_Module.ScriptInfo.SetContactInfo( "Nero @ Svencoop forums" );
  
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  
	if( g_pNVThinkFunc !is null )
		g_Scheduler.RemoveTimer( g_pNVThinkFunc );

	@g_pNVThinkFunc = g_Scheduler.SetInterval( "nvThink", 0.1f );
}

CClientCommand nightvision( "nightvision", "Toggles night vision on/off", @ToggleNV );

void MapInit()
{
	g_SoundSystem.PrecacheSound( "player/hud_nightvision.wav" );
	g_SoundSystem.PrecacheSound( "items/flashlight2.wav" );
}

class PlayerNVData
{
  Vector nvColor;
}

void ToggleNV( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

	if( pPlayer.IsAlive() )	
	{
		if ( args.ArgC() == 1 )
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

			if ( g_PlayerNV.exists( szSteamId ) )
			{
				removeNV( pPlayer );
			}
			else
			{
				PlayerNVData data;
				data.nvColor = Vector(0, 255, 0);
				g_PlayerNV[szSteamId] = data;
				g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.5, iBrightness, FFADE_OUT | FFADE_STAYOUT);
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "player/hud_nightvision.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
			}
		}
	
	}
}

void nvMsg( CBasePlayer@ pPlayer, const string szSteamId )
{
	PlayerNVData@ data = cast<PlayerNVData@>( g_PlayerNV[szSteamId] );

	Vector vecSrc = pPlayer.EyePosition();

	NetworkMessage nvon( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
		nvon.WriteByte( TE_DLIGHT );
		nvon.WriteCoord( vecSrc.x );
		nvon.WriteCoord( vecSrc.y );
		nvon.WriteCoord( vecSrc.z );
		nvon.WriteByte( g_iRadius );
		nvon.WriteByte( int(NV_COLOR.x) );
		nvon.WriteByte( int(NV_COLOR.y) );
		nvon.WriteByte( int(NV_COLOR.z) );
		nvon.WriteByte( iLife );
		nvon.WriteByte( iDecay );
	nvon.End();
}

void removeNV( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.1, iBrightness, FFADE_IN);
	g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "items/flashlight2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
	
	if ( g_PlayerNV.exists(szSteamId) )
		g_PlayerNV.delete(szSteamId);
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

void nvThink()
{
	for ( int i = 1; i <= g_Engine.maxClients; ++i )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

			if ( g_PlayerNV.exists(szSteamId) )
				nvMsg( pPlayer, szSteamId );
		}
	}
}
