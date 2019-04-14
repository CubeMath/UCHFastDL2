void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Josh \"JPolito\" Polito & Sam \"Solokiller\" Vanheer" );
	g_Module.ScriptInfo.SetContactInfo( "JPolito@svencoop.com" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
}

void MapInit()
{
	g_PlayerLocations.deleteAll();
	
	g_SoundSystem.PrecacheSound("items/r_item1.wav");
	g_SoundSystem.PrecacheSound("items/r_item2.wav");
}

class PlayerLocationData
{
	Vector origin;
	float pitch, yaw;
}

dictionary g_PlayerLocations;

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	if( pArguments.ArgC() >= 1 )
	{
		if( pArguments[ 0 ] == "/s" )
		{
			pParams.ShouldHide = true; // Do not show this command in player chat
			
			if( ( pPlayer.pev.flags & FL_DUCKING ) != 0 )
			{
				// Tell the player he can't save
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Cannot save while ducking!\n" );
			}
			else
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ); // Assigns the player their SteamID
				PlayerLocationData data;
				data.origin = pPlayer.pev.origin; // Saves the player origin
				// Saves the player angles
				data.pitch = pPlayer.pev.v_angle.x;
				data.yaw = pPlayer.pev.angles.y;
				g_PlayerLocations[ szSteamId ] = data;
				g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item2.wav", 1.0f, 1.0f, 0, 100); // Play "Position saved" sound
				g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Your saved position has been set to: " + data.origin.x + ' ' + data.origin.y + ' ' + data.origin.z + '\n'); // Shows the player's coordinates in console
			}
			
			return HOOK_HANDLED;
		}
		else if( pArguments[ 0 ] == "/p" )
		{
			pParams.ShouldHide = true; // Do not show this command in player chat
			
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

			if( g_PlayerLocations.exists( szSteamId ) )
			{
				PlayerLocationData@ data = cast<PlayerLocationData@>( g_PlayerLocations[ szSteamId ] );
				pPlayer.SetOrigin( data.origin ); // Sets the player origin
				// Sets the player angles
				pPlayer.pev.angles.x = data.pitch;
				pPlayer.pev.angles.y = data.yaw;
				pPlayer.pev.angles.z = 0; //Do a barrel roll, not
				pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES; // Applies the player angles
				NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY ); // Begin "swirling cloud of particles" effect
				message.WriteByte( TE_TELEPORT );
				message.WriteCoord( data.origin.x );
				message.WriteCoord( data.origin.y );
				message.WriteCoord( data.origin.z );
				message.End(); // End "swirling cloud of particles" effect
				g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100); // Play "Position loaded" sound
				g_Game.AlertMessage( at_console, "Sending Player \"%1\" to: " + data.origin.x + ' ' + data.origin.y + ' ' + data.origin.z + "\n", pPlayer.pev.netname ); // Shows the player's coordinates in console
			}
			
			return HOOK_HANDLED;
		}
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	g_Game.AlertMessage( at_console, "Player \"%1\" has left. Deleting saved teleport data.\n", pPlayer.pev.netname ); // Shows which player's shit is getting deleted
	g_PlayerLocations.delete( szSteamId ); // Deletes location data from the dictionary for the player who disconnects
	
	return HOOK_CONTINUE;
}