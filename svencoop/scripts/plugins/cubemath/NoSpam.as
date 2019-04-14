

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
}

void MapInit(){
	
}

HookReturnCode ClientSay(SayParameters@ pParams){
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer){
	
	return HOOK_CONTINUE;
}
