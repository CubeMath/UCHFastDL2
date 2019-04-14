void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSayAdminSay );
}

HookReturnCode ClientSayAdminSay( SayParameters@ pParams ) {

	string args = pParams.GetCommand();
	args.ToLowercase();
	
	if(
			args.Find("admin_say ") == 0 ||
			args.Find(".admin_say ") == 0 ||
			args.Find("!admin_say ") == 0 ||
			args.Find("/admin_say ") == 0
	){
		string finalStr = "ADMINISTRATOR: "+pParams.GetCommand().SubString(10);
		
		pParams.ShouldHide = true;
		g_Game.AlertMessage( at_logged, "%1\n", finalStr );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, finalStr+"\n" );
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
