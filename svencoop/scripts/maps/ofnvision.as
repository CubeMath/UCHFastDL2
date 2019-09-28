/*
* |=========================================================================|
* | O P P O S I N G  F O R C E   N I G H T  V I S I O N  [#include version] |
* | Author: Neo (SC, Discord),  Version V 1.21, September, 18th 2019        |
* |=========================================================================|
* |This map script enables the Opposing Force style NightVision             |
* |view mode, which can used with standard flash light key.                 |
* |=========================================================================|
* |Map script install instructions:                                         |
* |-------------------------------------------------------------------------|
* |1. Extract the map script 'scripts/maps/ofnvision.as'                    |
* |                       to 'svencoop_addon/scripts/maps'.                 |
* |-------------------------------------------------------------------------|
* |2. Add to main map script the following code:                            |
* |                                                                         |
* | (a) #include "ofnvision"                                                |
* |                                                                         |
* | (b) in function 'MapInit()':                                            |
* |     g_nv.MapInit();                                                     |
* |                                                                         |
* |=========================================================================|
* |Usage of OF NightVision:                                                 |
* |-------------------------------------------------------------------------|
* |Simply use standard flash light key to switch the                        |
* |OF NightVision view mode on and off                                      |
* |=========================================================================|
*/

NightVision@ g_nv = @NightVision();

HookReturnCode NVPlayerClient(CBasePlayer@ pPlayer)
{
	return g_nv.PlayerClient(pPlayer);
}

HookReturnCode NVPlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
{
	return g_nv.PlayerKilled(pPlayer, pAttacker, iGib);
}

void NVThink()
{
	g_nv.Think();
}



final class NightVision
{
	private string szSndHudNV  = "player/hud_nightvision.wav";
	private string szSndFLight = "items/flashlight2.wav";
	private string szNVThink = "NVThink";
	private Vector NV_COLOR( 0, 255, 0 );
	private float  fInterval = 0.05f;
	private float  flVolume = 0.8f;
	private int    iRadius = 42;
	private int    iLife	= 2;
	private int    iDecay = 1;
	private int    iBrightness = 64;
	private float  flFadeTime = 0.01f;
	private float  flFadeHold = 0.5f;
	private int    iFadeAlpha = 64;
	private CScheduledFunction@ pNVThinkFunc = null;
	private dictionary nvPlayer;

	NightVision()
	{
		g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @NVPlayerClient);
		g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect,  @NVPlayerClient);
		g_Hooks.RegisterHook(Hooks::Player::PlayerKilled,      @NVPlayerKilled);
	}

	void MapInit()
	{
		g_SoundSystem.PrecacheSound(szSndHudNV);
		g_SoundSystem.PrecacheSound(szSndFLight);
		@pNVThinkFunc = g_Scheduler.SetInterval(szNVThink, fInterval);
	}

	private void nvOn(CBasePlayer@ pPlayer)
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if(!nvPlayer.exists(szSteamId)) 
		{
			nvPlayer[szSteamId] = true;
			g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, flFadeTime, flFadeHold, iFadeAlpha, FFADE_OUT | FFADE_STAYOUT);
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, szSndHudNV, flVolume, ATTN_NORM, 0, PITCH_NORM );
		}

		Vector vecSrc = pPlayer.EyePosition();
		NetworkMessage netMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
		netMsg.WriteByte( TE_DLIGHT );
		netMsg.WriteCoord( vecSrc.x );
		netMsg.WriteCoord( vecSrc.y );
		netMsg.WriteCoord( vecSrc.z );
		netMsg.WriteByte( iRadius );
		netMsg.WriteByte( int(NV_COLOR.x) );
		netMsg.WriteByte( int(NV_COLOR.y) );
		netMsg.WriteByte( int(NV_COLOR.z) );
		netMsg.WriteByte( iLife );
		netMsg.WriteByte( iDecay );
		netMsg.End();
	}

	private void nvOff(CBasePlayer@ pPlayer)
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if(nvPlayer.exists(szSteamId))
		{
			g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, flFadeTime, flFadeHold, iFadeAlpha, FFADE_IN);
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, szSndFLight, flVolume, ATTN_NORM, 0, PITCH_NORM );
			nvPlayer.delete(szSteamId);
		}
	}

	HookReturnCode PlayerClient(CBasePlayer@ pPlayer)
	{
		if(pPlayer !is null)
			nvOff(pPlayer);

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
	{
		if(pPlayer !is null)
			nvOff(pPlayer);

		return HOOK_CONTINUE;
	}

	void Think()
	{
		for ( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if ( pPlayer !is null and pPlayer.IsConnected() and pPlayer.IsAlive())
			{
				if(pPlayer.FlashlightIsOn())
					nvOn(pPlayer);
				else
					nvOff(pPlayer);
			}
		}
	}
}
