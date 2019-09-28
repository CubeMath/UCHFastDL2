/*
* |======================================================================|
* | CROUCH SPAWN SCRIPT Version V1.21, September, 18th 2019              |
* | Author: H2 (V1.00), Neo (V1.10/V1.20/V1.21) [standalone / #include]  |
* |======================================================================|
* | The CROUCH SPAWN map script addition allows players to spawn         |
* | inside areas where you must be crouched where they would             |
* | otherwise be stuck clipping the walls.                               |
* |                                                                      |
* | The script is enabled by default and forces the player to            |
* | crouch when spawned inside the area and prevents being stuck.        |
* |======================================================================|
* |Map script install instructions:                                      |
* |----------------------------------------------------------------------|
* |1. Extract the map script 'scripts/maps/crouch_spawn.as' to           |
* |                           'svencoop_addon/scripts/maps'.             |
* |----------------------------------------------------------------------|
* |2. Use script file with following options:                            |
* |                                                                      |
* | (a) Standalone use:                                                  |
* |     Use this script as the main map script file for your maps and    |
* |     add to your map config (maps/<your-map>.cfg) the following line: |
* |                                                                      |
* |     map_script crouch_spawn                                          |
* |                                                                      |
* | (b) #include use:                                                    |
* |     Include this script in your map script with the following code:  |
* |                                                                      |
* |     #include "crouch_spawn"                                          |
* |                                                                      |
* |     The crouch spawn functionality is enabled by default.            |
* |     For check/disable/enable it from Angelscript                     |
* |     use the following sample code:                                   |
* |                                                                      |
* |        Check enable status:    i(g_crspawn.IsEnable()) { ... }       |
* |        Disable:                g_crspawn.Disable();                  |
* |        Enable:                 g_crspawn.Enable();                   |
* |======================================================================|
* | Usage of CROUCH SPAWN addition in your map                           |
* | ---------------------------------------------------------------------|                              |
* | 1st: Locate your spawn area and measure the origin.                  |
* | 2nd: Then, subtract 16 units from the z-axis measurement.            |
* | 3rd: Save the origin keyvalue.                                       |
* |======================================================================|
*/


CrouchSpawn@ g_crspawn = @CrouchSpawn();

HookReturnCode CRSPOnPlayerSpawn(CBasePlayer@ pPlayer)
{
	return g_crspawn.OnPlayerSpawn(pPlayer);
}

final class CrouchSpawn
{
	private float fPlayerZoffset = 36.0f;
	private float fPlayerZheight = 72.0f;
	private bool  bEnabled = false;

	CrouchSpawn()
	{
		Enable();
	}

	bool IsEnabled()
	{
		return bEnabled;
	}

	void Enable() // Init this on Demand
	{
		if(!bEnabled)
		{
			g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @CRSPOnPlayerSpawn);
			bEnabled = true;
		}
	}

	void Disable()
	{
		if(bEnabled)
		{
			g_Hooks.RemoveHook(Hooks::Player::PlayerSpawn);
			bEnabled = false;
		}
	}

    HookReturnCode OnPlayerSpawn( CBasePlayer@ pPlayer )
    {
        if(pPlayer is null)
			return HOOK_CONTINUE;
        
        TraceResult trPlayer;
        Vector vecOrigin;
        Vector vecEnd;

        // Start from the player's feet and trace 72 units upwards. Ugly as hell but it's good 'nuff.
		vecOrigin    = pPlayer.pev.origin;
		vecOrigin.z -= fPlayerZoffset;
		vecEnd       = vecOrigin;
		vecEnd.z    += fPlayerZheight;

        // Perform the trace and check the trace fraction, we need to crouch if it's below 1.
        g_Utility.TraceLine( vecOrigin, vecEnd, ignore_monsters, pPlayer.edict(), trPlayer );
        if( trPlayer.flFraction < 1.0f )
        {
            // Do the magic trick!
            pPlayer.pev.flags |= FL_DUCKING;
            pPlayer.pev.view_ofs.z -= 15;
        }

        return HOOK_CONTINUE;
    }
}