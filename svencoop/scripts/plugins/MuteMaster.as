#include "../../Cfg"

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "Sven Co-op Team" );
	g_Module.ScriptInfo.SetContactInfo( "www.svencoop.com" );
	
	//Only admins can use this
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	
	PlayerManagement::Initialize();
}

namespace PlayerManagement {
const string g_szConfigFilename = "scripts/plugins/admin/Config/PlayerManagement.cfg";

final class Config {
	string m_szPrefix = "admin";	//Which prefix to use for all commands and output
}

Config g_Config;

AdminCommands g_AdminCommands;

/*
* Initializes the plugin, register hooks, commands, etc
*/
void Initialize() {
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	
	LoadConfig();
	
	//Register commands here
	g_AdminCommands.AddCommand( CreateCommand( "slap", @AdminSlap, 0, "[damage] [count]", false, "Cannot slap admins" ) );
		
	g_AdminCommands.AddCommand( CreateCommand( "slay", @AdminSlay, 0, "", false, "Cannot slay admins" ) );
	
	g_AdminCommands.AddCommand( CreateCommand( "kick", @AdminKick, 0, "[ban time, in minutes]", false, "Cannot kick admins" ) );
	
	g_AdminCommands.AddCommand( CreateCommand( "ban", @AdminBan, 0, "[ban time, in minutes]", false, "Cannot ban admins" ) );
	
	g_AdminCommands.AddCommand( CreateCommand( "teleport", @AdminTeleport, 0, "[x] [y] [z]" ) );
	g_AdminCommands.AddCommand( CreateCommand( "teleportto", @AdminTeleportToPlayer, 1, "<name or steam id>" ) );
	
	g_AdminCommands.AddCommand( CreateCommand( "sethealth", @AdminSetHealth, 1, "<health>" ) );
	
	g_AdminCommands.AddCommand( CreateCommand( "setarmor", @AdminSetArmor, 1, "<armor>" ) );
}

void LoadConfig() {
	//TODO: add relative paths
	Cfg::File@ pFile = Cfg::Parser().Parse( g_szConfigFilename );
	
	if( pFile !is null ) {
		g_Game.AlertMessage( at_console, "PlayerManagement: config file %1 loaded\n", g_szConfigFilename );
		
		Cfg::Command@ pCommand;
		
		string szPrefix = pFile.GetCommandArgument( "prefix" );
		
		szPrefix.Trim();
		
		if( !szPrefix.IsEmpty() && szPrefix.FindFirstOf( String::WHITESPACE_CHARACTERS ) == Math.SIZE_MAX ) {
			g_Config.m_szPrefix = szPrefix;
			
			g_Game.AlertMessage( at_console, "PlayerManagement: custom prefix set: \"%1\"\n", szPrefix );
		}
	}
	else
		g_Game.AlertMessage( at_console, "PlayerManagement: no config found\n" );
}

PlayerAdminCommand@ CreateCommand( const string& in szName, PlayerAdminCommandCallback@ pCallback, const uint uiMinimumArgumentsRequired, const string& in szHelpInfo, 
	const bool bCanTargetAdmins = true, const string& in szCannotTargetAdminsMessage = "" ) {
	return @PlayerAdminCommand( g_Config.m_szPrefix + "_" + szName, @pCallback, 
		uiMinimumArgumentsRequired, szHelpInfo, bCanTargetAdmins, szCannotTargetAdminsMessage );
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	if( g_AdminCommands.Execute( pParams ) )
		return HOOK_HANDLED;
		
	return HOOK_CONTINUE;
}

/*
* Helper function to get a player by Steam Id
*/
CBasePlayer@ GetPlayerBySteamId( const string& in szTargetSteamId ) {
	CBasePlayer@ pTarget;
		
	for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex ) {
		@pTarget = g_PlayerFuncs.FindPlayerByIndex( iIndex );
		
		if( pTarget !is null ) {
			const string szSteamId = g_EngineFuncs.GetPlayerAuthId( pTarget.edict() );
			
			if( szSteamId == szTargetSteamId )
				return pTarget;
		}
	}
		
	return null;
}

/*
* Helper function to get a player either by name or Steam Id
*/
CBasePlayer@ GetTargetPlayer( const string& in szNameOrSteamId ) {
	CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByName( szNameOrSteamId, false );
		
	if( pTarget !is null )
		return pTarget;
		
	return GetPlayerBySteamId( szNameOrSteamId );
}

enum AdminExecResult {
	ADMIN_EXEC_UNKNOWN = 0,										//Unknown command.
	ADMIN_EXEC_KNOWN_COMMAND_FIRST,
	ADMIN_EXEC_TOOFEWARGS = ADMIN_EXEC_KNOWN_COMMAND_FIRST,		//Command is known, but did not have enough arguments.
	ADMIN_EXEC_NOTARGET,										//Command is known, but no target by that name or id exists.
	ADMIN_EXEC_TARGETEDADMIN,									//Command is known, but targeted an admin, and it was not allowed to do so.
	ADMIN_EXEC_SUCCESS,											//Command is known and was successfully executed.
	ADMIN_EXEC_KNOWN_COMMAND_LAST = ADMIN_EXEC_SUCCESS
}

funcdef void AdminOutput( CBasePlayer@ pPlayer, const string& in szMessage );

void ServerAlert( CBasePlayer@, const string& in szMessage ) {
	g_Game.AlertMessage( at_console, "%1\n", szMessage );
}

void ClientAlert( CBasePlayer@ pPlayer, const string& in szMessage ) {
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szMessage );
}

final class AdminCommandParameters {
	private const CCommand@ m_pArgs;
	private CBasePlayer@ m_pAdmin;
	private CBasePlayer@ m_pTarget;
	private AdminOutput@ m_pOutput;
	
	const CCommand@ Args {
		get const { return m_pArgs; }
	}
	
	CBasePlayer@ Admin {
		get const { return m_pAdmin; }
	}
	
	CBasePlayer@ Target {
		get const { return m_pTarget; }
	}
	
	AdminCommandParameters( const CCommand@ args, CBasePlayer@ pAdmin, CBasePlayer@ pTarget, AdminOutput@ pOutput ) {
		@m_pArgs = args;
		@m_pAdmin = pAdmin;
		@m_pTarget = pTarget;
		@m_pOutput = pOutput;
	}
	
	void Output( CBasePlayer@ pPlayer, const string& in szMessage ) {
		m_pOutput( pPlayer, szMessage );
	}
}

funcdef void PlayerAdminCommandCallback( AdminCommandParameters@ pParams );

/*
* Helper class for admin commands that target a specific player
*/
final class PlayerAdminCommand {
	private string m_szName;
	
	private PlayerAdminCommandCallback@ m_pCallback;
	
	private uint m_uiMinArgumentsRequired = 0;
	
	private string m_szHelpInfo = "";
	
	private bool m_bCanTargetAdmins = true;
	
	private string m_szCannotTargetAdminsMessage = "Cannot target admins with this command";
	
	string Name {
		get const { return m_szName; }
	}
	
	PlayerAdminCommandCallback@ Callback {
		get const { return m_pCallback; }
	}
	
	uint MinimumArgumentsRequired {
		get const { return m_uiMinArgumentsRequired; }
	}
	
	string HelpInfo {
		get const { return m_szHelpInfo; }
	}
	
	bool CanTargetAdmins {
		get const { return m_bCanTargetAdmins; }
	}
	
	string CannotTargetAdminsMessage {
		get const { return m_szCannotTargetAdminsMessage; }
	}
	
	PlayerAdminCommand( const string& in szName, PlayerAdminCommandCallback@ pCallback, 
						const uint uiMinArgumentsRequired = 0, const string& in szHelpInfo = "",
						const bool bCanTargetAdmins = true, const string& in szCannotTargetAdminsMessage = "" ) {
		m_szName 					= szName;
		@m_pCallback 				= pCallback;
		m_uiMinArgumentsRequired 	= uiMinArgumentsRequired;
		m_szHelpInfo				= szHelpInfo;
		m_bCanTargetAdmins 			= bCanTargetAdmins;
		
		if( !szCannotTargetAdminsMessage.IsEmpty() ) {
			m_szCannotTargetAdminsMessage = szCannotTargetAdminsMessage;
		}
	}
	
	bool IsValid() const {
		return !m_szName.IsEmpty() && m_pCallback !is null;
	}
	
	AdminExecResult Execute( const CCommand@ args, CBasePlayer@ pAdmin, AdminOutput@ pOutput ) final {		
		if( args.ArgC() < 2 || m_uiMinArgumentsRequired > uint( args.ArgC() - 2 ) ) {
			//The target name/steam id is also a required argument.
			pOutput( pAdmin, "Not enough arguments for " + m_szName + ". Got " + ( args.ArgC() - 1 ) + ", expected " + ( m_uiMinArgumentsRequired + 1 ) + "\n" );
			
			if( !m_szHelpInfo.IsEmpty() )
				pOutput( pAdmin, "Usage: " + m_szName + " <name or steam id> " + m_szHelpInfo + "\n" );
				
			return ADMIN_EXEC_TOOFEWARGS;
		}
		
		CBasePlayer@ pTarget = GetTargetPlayer( args[ 1 ] );
		
		if( pTarget is null ) {
			pOutput( pAdmin, "No player by that name exists\n" );
			return ADMIN_EXEC_NOTARGET;
		}
		
		if( !m_bCanTargetAdmins ) {
			if( g_PlayerFuncs.AdminLevel( pTarget ) >= ADMIN_YES ) {
				pOutput( pAdmin, m_szCannotTargetAdminsMessage );
				
				return ADMIN_EXEC_TARGETEDADMIN;
			}
		}
		
		m_pCallback( @AdminCommandParameters( args, pAdmin, pTarget, pOutput ) );
		
		return ADMIN_EXEC_SUCCESS;
	}
	
	/*
	*	 For console commands
	*/
	void Execute( const CCommand@ args ) final {
		Execute( args, g_ConCommandSystem.GetCurrentPlayer(), @ServerAlert );
	}
}

final class AdminCommands {
	private dictionary m_Commands;
	
	private dictionary m_ConCommands;
	
	bool ContainsCommand( const string& in szName ) const {
		if( szName.IsEmpty() )
			return false;
			
		return m_Commands.exists( szName );
	}
	
	bool AddCommand( PlayerAdminCommand@ pCommand ) {
		if( pCommand is null )
			return false;
			
		if( !pCommand.IsValid() )
			return false;
			
		if( ContainsCommand( pCommand.Name ) )
			return false;
			
		m_Commands.set( pCommand.Name, @pCommand );
		
		CConCommand command( pCommand.Name, pCommand.HelpInfo, ConCommandCallback( pCommand.Execute ) );
		
		m_ConCommands.set( pCommand.Name, @command );
			
		return true;
	}
	
	bool Execute( SayParameters@ pParams ) final {
		AdminExecResult result = Execute( pParams.GetArguments(), pParams.GetPlayer() );
		
		if( result >= ADMIN_EXEC_KNOWN_COMMAND_FIRST ) {
			pParams.ShouldHide = true;
			
			return true;
		}
		
		return false;
	}
	
	AdminExecResult Execute( const CCommand@ args, CBasePlayer@ pPlayer ) final {
		//Sanity check. Should never happen though.
		if( args.ArgC() < 1 )
			return ADMIN_EXEC_UNKNOWN;
			
		PlayerAdminCommand@ pCommand = null;
		
		if( !m_Commands.get( args[ 0 ], @pCommand ) )
			return ADMIN_EXEC_UNKNOWN;
			
		return pCommand.Execute( args, pPlayer, @ClientAlert );
	}
}

void PrintAdminCommand( CBasePlayer@ pAdmin, CBasePlayer@ pTarget, const string& in szAction, const string& in szExtra = "" ) {
	//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Admin " + pAdmin.pev.netname + ": " + szAction + " " + pTarget.pev.netname + szExtra + "\n" );
}

void AdminSlap( AdminCommandParameters@ pParams ) {
	const CCommand@ args = pParams.Args;
	
	float flDamage = 0;
	
	if( args.ArgC() >= 3 ) {
		flDamage = atof( args[ 2 ] );
	}
	
	uint uiCount = 1;
	
	if( args.ArgC() >= 4 ) {
		uiCount = atoui( args[ 3 ] );
	}
	
	const string szCountMessage = uiCount > 1 ? " " + uiCount + " times" : "";
	const string szDmgMessage = flDamage != 0 ? " with " + flDamage + " damage" : "";
	
	PrintAdminCommand( pParams.Admin, pParams.Target, "Slapping", szCountMessage + szDmgMessage );
		
	for( uint uiSlapped = 0; uiSlapped < uiCount; ++uiSlapped )
		g_AdminControl.SlapPlayer( pParams.Admin, pParams.Target, flDamage, DMG_GENERIC );
}

void AdminSlay( AdminCommandParameters@ pParams ) {
	PrintAdminCommand( pParams.Admin, pParams.Target, "Slaying" );
	
	g_AdminControl.KillPlayer( pParams.Admin, pParams.Target );
}

void AdminKick( AdminCommandParameters@ pParams ) {	
	const CCommand@ args = pParams.Args;
	
	float flBanTime = -1;
	
	if( args.ArgC() >= 3 )
		flBanTime = atof( args[ 2 ] );
		
	PrintAdminCommand( pParams.Admin, pParams.Target, "Kicking" );

	g_AdminControl.KickPlayer( pParams.Admin, pParams.Target, flBanTime );
}

void AdminBan( AdminCommandParameters@ pParams ) {	
	const CCommand@ args = pParams.Args;
	
	float flBanTime = -1;
	
	if( args.ArgC() >= 3 )
		flBanTime = atof( args[ 2 ] );
		
	PrintAdminCommand( pParams.Admin, pParams.Target, "Banning" );
		
	g_AdminControl.BanPlayer( pParams.Admin, pParams.Target, flBanTime );
}

const int ADMIN_TP_FIRST_COORD_IDX = 2;

const string ADMIN_TP_USE_CURR_COORD = "c";

void AdminTeleport( AdminCommandParameters@ pParams ) {
	const CCommand@ args = pParams.Args;
	
	Vector vecDestination = pParams.Admin.pev.origin;
	
	for( int iIndex = ADMIN_TP_FIRST_COORD_IDX; iIndex < args.ArgC(); ++iIndex ) {
		const string szArg = args[ iIndex ];
		
		if( szArg != ADMIN_TP_USE_CURR_COORD ) {
			vecDestination[ iIndex - ADMIN_TP_FIRST_COORD_IDX ] = atof( szArg );
		}
	}
	
	PrintAdminCommand( pParams.Admin, pParams.Target, "Teleporting" );
	
	pParams.Target.SetOrigin( vecDestination );
}

void AdminTeleportToPlayer( AdminCommandParameters@ pParams ) {
	const CCommand@ args = pParams.Args;
	
	const string szTargetName = args[ 2 ];
	
	CBasePlayer@ pDestPlayer = GetTargetPlayer( szTargetName );
	
	if( pDestPlayer is null ) {
		pParams.Output( pParams.Admin, "No player by that name found\n" );
		return;
	}
	
	PrintAdminCommand( pParams.Admin, pParams.Target, "Teleporting", " To " + pDestPlayer.pev.netname );
	
	pParams.Target.SetOrigin( pDestPlayer.pev.origin );
}

void AdminSetHealth( AdminCommandParameters@ pParams ) {
	const CCommand@ args = pParams.Args;
	
	const float flHealth = atof( args[ 2 ] ); 
	
	PrintAdminCommand( pParams.Admin, pParams.Target, "Set Health", " To " + flHealth );
	
	//Don't allow player health to drop below 1; this can break game code TODO needs fixing
	pParams.Target.pev.health = Math.max( 1, flHealth );
}

void AdminSetArmor( AdminCommandParameters@ pParams ) {
	const CCommand@ args = pParams.Args;
	
	const float flArmor = atof( args[ 2 ] );
	
	PrintAdminCommand( pParams.Admin, pParams.Target, "Set Armor", " To " + flArmor );
	
	//Don't allow player armor to drop below 0; this can break game code TODO needs fixing
	pParams.Target.pev.armorvalue = Math.max( 0, flArmor );
}
}