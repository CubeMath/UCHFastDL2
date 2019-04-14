AdminMapchanger@ g_AdminMapchanger;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	//Only admins can use this
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	
	AdminMapchanger cAdminMapchanger();
	@g_AdminMapchanger = @cAdminMapchanger;
	
	Initialize();
}

void Initialize() {
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

class AdminMapchanger{
	
	AdminMapchanger(){
	}
	
	bool Execute( SayParameters@ pParams ) final {
		string args = pParams.GetCommand();
		CBasePlayer@ plr = pParams.GetPlayer();
		args.ToLowercase();
		
		if(args.Find("admin_map") == 0){
			pParams.ShouldHide = true;
			
			string mapname = args.SubString(10);
			
			if(args.Length() < 11 || args.Find("admin_map ") == String::INVALID_INDEX){
				g_PlayerFuncs.ClientPrint( plr, HUD_PRINTTALK, "Usage: admin_map <mapname>\n" ); 
			}else{
				
				bool mapcheck = false;
				mapcheck = mapcheck || mapname == "hl_c00";
				mapcheck = mapcheck || mapname == "hl_c01_a1";
				mapcheck = mapcheck || mapname == "hl_c01_a2";
				mapcheck = mapcheck || mapname == "hl_c02_a1";
				mapcheck = mapcheck || mapname == "hl_c02_a2";
				mapcheck = mapcheck || mapname == "hl_c03";
				mapcheck = mapcheck || mapname == "hl_c04";
				mapcheck = mapcheck || mapname == "hl_c05_a1";
				mapcheck = mapcheck || mapname == "hl_c05_a2";
				mapcheck = mapcheck || mapname == "hl_c05_a3";
				mapcheck = mapcheck || mapname == "hl_c06";
				mapcheck = mapcheck || mapname == "hl_c07_a1";
				mapcheck = mapcheck || mapname == "hl_c07_a2";
				mapcheck = mapcheck || mapname == "hl_c08_a1";
				mapcheck = mapcheck || mapname == "hl_c08_a2";
				mapcheck = mapcheck || mapname == "hl_c09";
				mapcheck = mapcheck || mapname == "hl_c10";
				mapcheck = mapcheck || mapname == "hl_c11_a1";
				mapcheck = mapcheck || mapname == "hl_c11_a2";
				mapcheck = mapcheck || mapname == "hl_c11_a3";
				mapcheck = mapcheck || mapname == "hl_c11_a4";
				mapcheck = mapcheck || mapname == "hl_c11_a5";
				mapcheck = mapcheck || mapname == "hl_c12";
				mapcheck = mapcheck || mapname == "hl_c13_a1";
				mapcheck = mapcheck || mapname == "hl_c13_a2";
				mapcheck = mapcheck || mapname == "hl_c13_a3";
				mapcheck = mapcheck || mapname == "hl_c13_a4";
				mapcheck = mapcheck || mapname == "hl_c14";
				mapcheck = mapcheck || mapname == "hl_c15";
				mapcheck = mapcheck || mapname == "hl_c16_a1";
				mapcheck = mapcheck || mapname == "hl_c16_a2";
				mapcheck = mapcheck || mapname == "hl_c16_a3";
				mapcheck = mapcheck || mapname == "hl_c16_a4";
				mapcheck = mapcheck || mapname == "hl_c17";
				mapcheck = mapcheck || mapname == "hl_c18";
				
				mapcheck = mapcheck || mapname == "ba_tram1";
				mapcheck = mapcheck || mapname == "ba_tram2";
				mapcheck = mapcheck || mapname == "ba_tram3";
				mapcheck = mapcheck || mapname == "ba_security1";
				mapcheck = mapcheck || mapname == "ba_security2";
				mapcheck = mapcheck || mapname == "ba_maint";
				mapcheck = mapcheck || mapname == "ba_elevator";
				mapcheck = mapcheck || mapname == "ba_canal1";
				mapcheck = mapcheck || mapname == "ba_canal1b";
				mapcheck = mapcheck || mapname == "ba_canal2";
				mapcheck = mapcheck || mapname == "ba_canal3";
				mapcheck = mapcheck || mapname == "ba_yard1";
				mapcheck = mapcheck || mapname == "ba_yard2";
				mapcheck = mapcheck || mapname == "ba_yard3";
				mapcheck = mapcheck || mapname == "ba_yard3a";
				mapcheck = mapcheck || mapname == "ba_yard3b";
				mapcheck = mapcheck || mapname == "ba_yard4";
				mapcheck = mapcheck || mapname == "ba_yard4a";
				mapcheck = mapcheck || mapname == "ba_yard5";
				mapcheck = mapcheck || mapname == "ba_yard5a";
				mapcheck = mapcheck || mapname == "ba_xen1";
				mapcheck = mapcheck || mapname == "ba_xen2";
				mapcheck = mapcheck || mapname == "ba_xen3";
				mapcheck = mapcheck || mapname == "ba_xen4";
				mapcheck = mapcheck || mapname == "ba_xen5";
				mapcheck = mapcheck || mapname == "ba_xen6";
				mapcheck = mapcheck || mapname == "ba_teleport1";
				mapcheck = mapcheck || mapname == "ba_teleport2";
				mapcheck = mapcheck || mapname == "ba_power1";
				mapcheck = mapcheck || mapname == "ba_power2";
				mapcheck = mapcheck || mapname == "ba_outro";
				
				mapcheck = mapcheck || mapname == "of0a0";
				mapcheck = mapcheck || mapname == "of1a1";
				mapcheck = mapcheck || mapname == "of1a2";
				mapcheck = mapcheck || mapname == "of1a3";
				mapcheck = mapcheck || mapname == "of1a4";
				mapcheck = mapcheck || mapname == "of1a4b";
				mapcheck = mapcheck || mapname == "of1a5";
				mapcheck = mapcheck || mapname == "of1a5b";
				mapcheck = mapcheck || mapname == "of1a6";
				mapcheck = mapcheck || mapname == "of2a1";
				mapcheck = mapcheck || mapname == "of2a1b";
				mapcheck = mapcheck || mapname == "of2a2";
				mapcheck = mapcheck || mapname == "of2a4";
				mapcheck = mapcheck || mapname == "of2a5";
				mapcheck = mapcheck || mapname == "of2a6";
				mapcheck = mapcheck || mapname == "of3a1";
				mapcheck = mapcheck || mapname == "of3a2";
				mapcheck = mapcheck || mapname == "of3a4";
				mapcheck = mapcheck || mapname == "of3a5";
				mapcheck = mapcheck || mapname == "of3a6";
				mapcheck = mapcheck || mapname == "of4a1";
				mapcheck = mapcheck || mapname == "of4a2";
				mapcheck = mapcheck || mapname == "of4a3";
				mapcheck = mapcheck || mapname == "of4a4";
				mapcheck = mapcheck || mapname == "of4a5";
				mapcheck = mapcheck || mapname == "of5a1";
				mapcheck = mapcheck || mapname == "of5a2";
				mapcheck = mapcheck || mapname == "of5a3";
				mapcheck = mapcheck || mapname == "of5a4";
				mapcheck = mapcheck || mapname == "of6a1";
				mapcheck = mapcheck || mapname == "of6a2";
				mapcheck = mapcheck || mapname == "of6a3";
				mapcheck = mapcheck || mapname == "of6a4";
				mapcheck = mapcheck || mapname == "of6a4b";
				
				mapcheck = mapcheck || mapname == "uplink";
				
				mapcheck = mapcheck || mapname == "th_ep1_00";
				mapcheck = mapcheck || mapname == "th_ep1_01";
				mapcheck = mapcheck || mapname == "th_ep1_02";
				mapcheck = mapcheck || mapname == "th_ep1_03";
				mapcheck = mapcheck || mapname == "th_ep1_04";
				mapcheck = mapcheck || mapname == "th_ep1_05";
				mapcheck = mapcheck || mapname == "th_ep2_00";
				mapcheck = mapcheck || mapname == "th_ep2_01";
				mapcheck = mapcheck || mapname == "th_ep2_02";
				mapcheck = mapcheck || mapname == "th_ep2_03";
				mapcheck = mapcheck || mapname == "th_ep2_04";
				mapcheck = mapcheck || mapname == "th_ep3_00";
				mapcheck = mapcheck || mapname == "th_ep3_01";
				mapcheck = mapcheck || mapname == "th_ep3_02";
				mapcheck = mapcheck || mapname == "th_ep3_03";
				mapcheck = mapcheck || mapname == "th_ep3_04";
				mapcheck = mapcheck || mapname == "th_ep3_05";
				mapcheck = mapcheck || mapname == "th_ep3_06";
				mapcheck = mapcheck || mapname == "th_ep3_07";
				
				mapcheck = mapcheck || mapname == "choose_campaign_4";
				
				if(mapcheck){
					g_EngineFuncs.ChangeLevel( mapname );
				}else{
					g_Game.AlertMessage( at_logged, "ADMIN-MAPCHANGE to \""+mapname+"\"\n" );
					g_PlayerFuncs.ClientPrint( plr, HUD_PRINTTALK, "You are not allowed to change map to \""+mapname+"\"!\n" ); 
				}
			}
			
			return true;
		}
		
		return false;
	}
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	if( g_AdminMapchanger.Execute( pParams ) )
		return HOOK_HANDLED;
		
	return HOOK_CONTINUE;
}