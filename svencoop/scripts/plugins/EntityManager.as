#include "../ChatCommandManager"

ChatCommandSystem::ChatCommandManager@ g_ChatCommands = null;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sven Co-op Development Team" );
	g_Module.ScriptInfo.SetContactInfo( "www.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	
	@g_ChatCommands = ChatCommandSystem::ChatCommandManager();
	
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!hurtclass", @HurtClass, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!killclass", @KillClass, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!killtarget", @KillTarget, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!listentityinfo", @ListEntityInfo, false, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!killinsphere", @KillInSphere, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!setscale", @SetScale, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!speed", @Speed, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!triggerinsphere", @TriggerInSphere, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!listentities", @ListEntities, false ) );
	//g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!bug", @Bug, false ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!listweapons", @ListWeapons, false ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!setview", @SetView, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!sethealth", @SetHealth, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!settargethealth", @SetTargetHealth, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!setarmor", @SetArmor, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!triggerahead", @TriggerAhead, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!renametarget", @RenameTarget, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!flags", @Flags, true, 1 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!removetarget", @RemoveTarget, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!killallplayers", @KillAllPlayers, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!killallbutme", @KillAllButMe, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!makeplayersnonsolid", @MakePlayersNonSolid, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!makeplayerssolid", @MakePlayersSolid, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!respawnallplayers", @RespawnAllPlayers, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!setkeyvalue", @SetKeyvalue, true, 3 ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!entindex", @EntIndex, true ) );
	g_ChatCommands.AddCommand( ChatCommandSystem::ChatCommand( "!myhullsize", @MyHullSize, false ) );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{		
	if( g_ChatCommands.ExecuteCommand( pParams ) )
		return HOOK_HANDLED;

	return HOOK_CONTINUE;
}

void HurtClass( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	const string szClassname = pArguments[ 1 ];
	
	const float flDamage = pArguments.ArgC() >= 3 ? atof( pArguments[ 2 ] ) : 5000;
		
	CBaseEntity@ ent = null;
	int counter = 0;
	
	// FindEntityByClassname is case sensitive. Make a workaround later.
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, szClassname ) ) !is null )
	{
		ent.TakeDamage( pPlayer.pev, pPlayer.pev, flDamage, DMG_BLAST );
		counter++;
	}
	
	if( counter > 0 )
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "You hurt " + counter + " \"" + szClassname + "\" entities.\n" );
	else
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "No \"" + szClassname + "\" entities were found.\n" );
}
			
void KillClass( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	uint counter = 0;
	CBaseEntity@ ent = null;
	
	// FindEntityByClassname is case sensitive. Make a workaround later.
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, pArguments[ 1 ] ) ) !is null )
	{
		g_EntityFuncs.Remove( ent );
		counter++;
	}
	
	if( counter > 0 )
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "You removed " + counter + " \"" + pArguments[ 1 ] + "\" entities.\n" );
	else
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "No \"" + pArguments[ 1 ] + "\" entities were found.\n" );
}

void KillTarget( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	uint counter = 0;
	CBaseEntity@ ent = null;
	
	while( ( @ent = g_EntityFuncs.FindEntityByTargetname( ent, pArguments[ 1 ] ) ) !is null )
	{
		g_EntityFuncs.Remove( ent );
		counter++;
	}
	
	if( counter > 0 )
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "You removed " + counter + " \"" + pArguments[ 1 ] + "\" entities.\n" );
	else
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "No \"" + pArguments[ 1 ] + "\" entities were found.\n" );
}

void ListEntityInfo( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	CBaseEntity@ ent = null;
	
	string className = pArguments[ 1 ];
	g_EngineFuncs.ClientPrintf( pPlayer, print_console, "Searching for instances of entity \"" + className + "\"\n" );
	
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, className ) ) !is null )
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "targetname: " + ent.GetTargetname() + ", target: " + ent.pev.target + "\n" );
	}
}

void KillInSphere( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	string className = pArguments[ 1 ];
				
	float flRadius = atof( pArguments[ 2 ] );
	
	flRadius = abs( flRadius );
	
	Vector vecCenter = pPlayer.pev.origin;
	
	g_PlayerFuncs.SayTextAll( pPlayer, "Killing \"" + className + "\" in radius \"" + flRadius + "\"\n" );
	
	CBaseEntity@ ent = null;
	
	while( ( @ent = g_EntityFuncs.FindEntityInSphere( ent, vecCenter, flRadius, className, "classname" ) ) !is null )
	{
		ent.TakeDamage( pPlayer.pev, pPlayer.pev, 5000, DMG_GENERIC | DMG_NEVERGIB );
	}
}
			
void SetScale( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	TraceResult tr;
	Vector vecStart = pPlayer.GetGunPosition();

	Math.MakeVectors( pPlayer.pev.v_angle );
	g_Utility.TraceLine( vecStart, vecStart + g_Engine.v_forward * 8192, dont_ignore_monsters, pPlayer.edict(), tr );

	if( tr.pHit !is null )
	{
		tr.pHit.vars.scale = atof( pArguments[ 1 ] );
	}
}
			
void Speed( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	edict_t@ pTrainEdict = @pPlayer.pev.groundentity;
				
	if( pTrainEdict !is null )
	{
		CBaseEntity@ pTrain = @g_EntityFuncs.Instance( pTrainEdict );
		
		if( pTrain !is null )
		{
			float flSpeed = atof( pArguments[ 1 ] );
			
			pTrain.pev.speed = flSpeed;
			
			g_Game.AlertMessage( at_console, "changing speed to %1\n", flSpeed );
		}
	}
}
			
void TriggerInSphere( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	const float flRadius = abs( atof( pArguments[ 1 ] ) );
				
	USE_TYPE useType = USE_TOGGLE;
	
	if( pArguments.ArgC() >= 3 )
	{
		const int iType = atoi( pArguments[ 2 ] );
		
		switch( iType )
		{
		case 0:	useType = USE_OFF; break;
		case 1: useType = USE_ON; break;
		case 3: useType = USE_TOGGLE; break;
		default: break;
		}
	}
	
	CBaseEntity@ pEntity = null;
	
	uint uiCount = 0;
	
	while( ( @pEntity = g_EntityFuncs.FindEntityInSphere( pEntity, pPlayer.pev.origin, flRadius, "*", "classname" ) ) !is null )
	{
		++uiCount;
		pEntity.Use( pPlayer, pPlayer, useType, 0 );
	}
	
	string szText;
	
	snprintf( szText, "Triggered %1 entities\n", uiCount );
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szText );
}
			
void ListEntities( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	g_EngineFuncs.ClientPrintf( pPlayer, print_console, "Generating list of entities...\n" );
	dictionary entcounts;
	
	edict_t@ edict = null;
	
	CBaseEntity@ entity = null;
	
	for( int index = 0; index < g_Engine.maxEntities; ++index )
	{
		@edict = @g_EntityFuncs.IndexEnt( index );
		
		@entity = g_EntityFuncs.Instance( edict );
		
		if( entity !is null )
		{
			string classname = entity.GetClassname();
			
			int count = 0;
			
			if( entcounts.exists( classname ) )
			{
				count = int(entcounts[ classname ]);
			}
			
			entcounts[ classname ] = count + 1;
		}
	}
	
	array<string>@ keys = entcounts.getKeys();
	
	for( uint index = 0; index < keys.length(); ++index )
	{
		string classname = keys[ index ];
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "Class \"" + classname + "\" has " + int( entcounts[ classname ] ) + " instances\n" );
	}
}

/*
void Bug( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	//Strip the "!bug " part
	string szReport = pParams.GetCommand().substr( 5 );
				
	string szOutPath;
	
	if( g_PlayerFuncs.ReportBug( pPlayer, szReport, szOutPath ) )
	{
		pParams.ShouldHide = true;
		
		const size_t maxLength = 40;
		
		if( szReport.Length() > maxLength )
			szReport = szReport.substr( 0, maxLength - 3 ) + "...";
			
		
		g_PlayerFuncs.SayTextAll( pPlayer, "Player \"" + pPlayer.pev.netname + "\" reported bug \"" + szReport + "\" to file \"" + szOutPath + "\"\n" );
	}
	else
		g_PlayerFuncs.SayText( pPlayer, "Could not report bug\n" );
}
*/

void ListWeapons( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();

	string szWeapons = "Player has weapons:";
				
	CBasePlayerItem@ pEnt = null;
	
	for( size_t uiIndex = 0; uiIndex < MAX_ITEM_TYPES; ++uiIndex )
	{
		@pEnt = pPlayer.m_rgpPlayerItems( uiIndex );
		
		if( pEnt !is null )
		{
			do
			{
				szWeapons += pEnt.GetClassname() + ";";
			}
			while( ( @pEnt = cast<CBasePlayerItem@>( pEnt.m_hNextItem.GetEntity() ) ) !is null );
		}
	}
	
	g_EngineFuncs.ClientPrintf( pPlayer, print_console, szWeapons + "\n" );
}
			
void SetView( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	CBaseEntity@ pTarget = pPlayer; //Reset to player view by default
				
	if( pArguments.ArgC() >= 3 )
	{
		if( pArguments[ 1 ] == "player" )
			@pTarget = @g_PlayerFuncs.FindPlayerByName( pArguments[ 2 ] );
		else if( pArguments[ 1 ] == "targetname" )
			@pTarget = @g_EntityFuncs.FindEntityByTargetname( null, pArguments[ 2 ] );
		else if( pArguments[ 1 ] == "classname" )
			@pTarget = @g_EntityFuncs.FindEntityByClassname( null, pArguments[ 2 ] );
	}
	
	if( pTarget !is null )
		g_EngineFuncs.SetView( pPlayer.edict(), pTarget.edict() );
}

/*
* Very specific function that sets health and armor in a way that doesn't break anything
*/
void SetStateFloatValue( CBasePlayer@ pPlayer, const float flNewSetting, const float flOldSetting, float& out flValue, const string& in szName, const bool fAllowZero )
{
	//Necessary to ensure no garbage value is set
	flValue = flOldSetting;
	
	if( fAllowZero )
	{
		//Don't allow negative or 0
		if( flNewSetting < 0 || flNewSetting + 1 < 0 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Cannot set " + szName + ": new value is negative!\n" );
			return;
		}
	}
	else
	{
		//Don't allow negative or 0
		if( flNewSetting <= 0 || flNewSetting + 1 <= 0 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Cannot set " + szName + ": new value is negative or zero!\n" );
			return;
		}
	}
	
	flValue = flNewSetting;
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szName + " is now " + flValue + "\n" );
}

void SetHealth( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	const float flNewHealth = atof( pParams.GetArguments()[ 1 ] );
	
	SetStateFloatValue( @pPlayer, flNewHealth, pPlayer.pev.health, pPlayer.pev.health, "health", false );
}

void SetTargetHealth( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	const float flNewHealth = atof( pParams.GetArguments()[ 1 ] );
	
	//Max range is 4096, but can easily increase it
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
	{
		SetStateFloatValue( @pPlayer, flNewHealth, pEntity.pev.health, pEntity.pev.health, "health", false );
	}
}

void SetArmor( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	const float flNewArmor = atof( pParams.GetArguments()[ 1 ] );
	
	SetStateFloatValue( @pPlayer, flNewArmor, pPlayer.pev.armorvalue, pPlayer.pev.armorvalue, "armor", true );
}

void TriggerAhead( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
	{
		//Fire all entities with this entity's name if it has one
		if( pEntity.GetTargetname().IsEmpty() )
			pEntity.Use( pPlayer, pPlayer, USE_TOGGLE, 0 );
		else
			g_EntityFuncs.FireTargets( pEntity.pev.targetname, pPlayer, pPlayer, USE_TOGGLE );
	}
}

void RenameTarget( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
	{
		const string szOldName = pEntity.pev.targetname;
		pEntity.pev.targetname = pParams.GetArguments()[ 1 ];
		
		g_EngineFuncs.ClientPrintf( pParams.GetPlayer(), print_center, "Renamed \"" + szOldName + "\" to \"" + pEntity.pev.targetname + "\"" );
	}
}

/*
* Can add more actions if needed
*/
enum SetFlagAction
{
	FlagAction_None,
	FlagAction_Display,
	FlagAction_Add,
	FlagAction_Clear
}

/*
* On the entity you're currently looking at:
* Displays flags;
* sets or clears the Nth flag
*
* Usage:
*	!flags #: display flags
*	!flags + 3: Sets the 3th flag
*	!flags - 3: Clears the 3th flag
*/
void Flags( SayParameters@ pParams )
{
	const CCommand@ pArguments = @pParams.GetArguments();
	
	const string szAction = pArguments[ 1 ];
	
	SetFlagAction action = FlagAction_None;
	
	if( szAction == "#" )
		action = FlagAction_Display;
	if( szAction == "+" )
		action = FlagAction_Add;
	else if( szAction == "-" )
		action = FlagAction_Clear;
		
	if( action == FlagAction_None )
	{
		g_EngineFuncs.ClientPrintf( pParams.GetPlayer(), print_center, "Invalid action\n" );
		return;
	}
	
	const int iIndex = pArguments.ArgC() >= 3 ? atoi( pArguments[ 2 ] ) - 1 : 0; //1st flag is 0, etc
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	//Max range is 4096, but can easily increase it
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
	{
		switch( action )
		{
		case FlagAction_Display: break;
		case FlagAction_Add:	pEntity.pev.flags |= 1 << iIndex; break;
		case FlagAction_Clear:	pEntity.pev.flags &= ~( 1 << iIndex ); break;
		default: break;
		}
			
		g_EngineFuncs.ClientPrintf( pParams.GetPlayer(), print_center, "Flags are: " + pEntity.pev.flags + "\n" );
	}
}

void RemoveTarget( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
		g_EntityFuncs.Remove( pEntity );
}

void KillAllPlayers( SayParameters@ pParams )
{
	for( int i = 1; i <= g_Engine.maxClients; ++i )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if( pPlayer !is null )
		{
			pPlayer.TakeDamage( g_EntityFuncs.Instance(0).pev, g_EntityFuncs.Instance(0).pev, 10000, DMG_GENERIC);
		}
	}
}

void KillAllButMe( SayParameters@ pParams )
{
	for( int i = 1; i <= g_Engine.maxClients; ++i )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if( pPlayer !is null && pPlayer !is pParams.GetPlayer() )
		{
			pPlayer.TakeDamage( g_EntityFuncs.Instance(0).pev, g_EntityFuncs.Instance(0).pev, 10000, DMG_GENERIC);
		}
	}
}

void MakePlayersNonSolid( SayParameters@ pParams )
{
	for(int i = 1; i <= g_Engine.maxClients; ++i)
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if( pPlayer !is null )
		{
			pPlayer.pev.solid = SOLID_NOT;
		}
	}
}

void MakePlayersSolid( SayParameters@ pParams )
{
	for(int i = 1; i <= g_Engine.maxClients; ++i)
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if( pPlayer !is null )
		{
			pPlayer.pev.solid = SOLID_SLIDEBOX;
		}
	}
}

void RespawnAllPlayers( SayParameters@ pParams )
{
	g_PlayerFuncs.RespawnAllPlayers( true, true );
}

void SetKeyvalue( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();
	
	const string szTarget = pArguments[ 1 ];
	const string szKey = pArguments[ 2 ];
	const string szValue = pArguments[ 3 ];
	
	CBaseEntity@ pEnt = null;
	
	uint uiCount = 0;
	
	while( ( @pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, szTarget ) ) !is null )
	{
		g_EntityFuncs.DispatchKeyValue( pEnt.edict(), szKey, szValue );
		//pEnt.KeyValue( szKey, szValue );
		
		++uiCount;
	}
	
	g_PlayerFuncs.ClientPrint( pParams.GetPlayer(), HUD_PRINTTALK, "Set keyvalue on " + uiCount + " entities\n" );
}

void EntIndex( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	CBaseEntity@ pEntity = g_Utility.FindEntityForward( pPlayer, 4096 );
	
	if( pEntity !is null )
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "entity index: " + pEntity.entindex() + "\n" );
	}
}

void MyHullSize( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Your hull size is " + pPlayer.pev.mins.ToString() + ", " + pPlayer.pev.maxs.ToString() + "\n" );
}
