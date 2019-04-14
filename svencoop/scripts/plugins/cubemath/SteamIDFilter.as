//final class IPAddressPlayerData {
//	private string address;
//	private CBasePlayer@ pPlayer;
//	
//	IPAddressPlayerData( string network_address ){
//		address = network_address;
//	}
//	
//	IPAddressPlayerData( CBasePlayer@ ply, string network_address ){
//		address = network_address;
//		@pPlayer = ply;
//	}
//	
//	CBasePlayer@ Player{
//		get const { return pPlayer; }
//	}
//	
//	void setBasePlayer(CBasePlayer@ ply){
//		@pPlayer = ply;
//	}
//	
//	string getIPAddress(){
//		return address;
//	}
//}

//array<IPAddressPlayerData@> g_IPAddressPlayerData;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	//g_IPAddressPlayerData.resize( g_Engine.maxClients );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientConnected, @ClientConnected2 );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	
	//CBasePlayer@ pPlayer = null;
	
	//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
	//for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		//@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		//if( pPlayer is null || !pPlayer.IsConnected() )
		//	continue;
		
		//IPAddressPlayerData data( pPlayer, "" );
		//@g_IPAddressPlayerData[ pPlayer.entindex() - 1 ] = @data;
	//}
}

void MapInit() {
}

HookReturnCode ClientConnected2( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason ) {
	
	//IPAddressPlayerData data( szIPAddress );
	//@g_IPAddressPlayerData[ g_EntityFuncs.Instance(pEntity).entindex() - 1 ] = @data;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){

	//@g_IPAddressPlayerData[ pPlayer.entindex() - 1 ] = null;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ) {
	
	string steamid = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	int steamNumber = atoi(steamid.SubString(10));
	
	bool banhim = (steamNumber>207500000 && steamNumber<210000000);
	banhim = banhim && !(steamid == "STEAM_0:0:207702193");
	banhim = banhim && !(steamid == "STEAM_0:0:208212180");
	banhim = banhim && !(steamid == "STEAM_0:0:208373261");
	banhim = banhim && !(steamid == "STEAM_0:1:207524357");
	
	if(banhim){
		//IPAddressPlayerData@ ipPly = g_IPAddressPlayerData[ pPlayer.entindex() - 1 ];
		
		//string bStr = "";
		//if(ipPly !is null){
		//	bStr = ipPly.getIPAddress();
		//	bStr = bStr.SubString(0, bStr.Length()-6);
		//}
		
		string banStr = "banid 0 "+steamid+" kick\n";
		g_EngineFuncs.ServerCommand(banStr);
		
		//if(bStr.Length()>6){
		//	string ipStr = "addip 0 "+bStr+"\n";
		//	g_EngineFuncs.ServerCommand(ipStr);
		//}
		
		//Don't even think about to uncomment that line
		//Because it crashes Server!
		//g_EngineFuncs.ServerExecute();
	}
	
	return HOOK_CONTINUE;
}
