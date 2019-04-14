final class InsultKiller {
	
	array<string> equalsList = {
		"CUNT",
		"DICK",
		"DIK",
		"FACKINOB",
		"FACKINGNOB",
		"FAKINOB",
		"FAKINGNOB",
		"FCKINOB",
		"FCKINGNOB",
		"FCUKINOB",
		"FCUKINGNOB",
		"FOCKINOB",
		"FOCKINGNOB",
		"FOKINOB",
		"FOKINGNOB",
		"FUCKINOB",
		"FUCKINGNOB",
		"FUKINOB",
		"FUKINGNOB",
		"FACKINOBS",
		"FACKINGNOBS",
		"FAKINOBS",
		"FAKINGNOBS",
		"FCKINOBS",
		"FCKINGNOBS",
		"FCUKINOBS",
		"FCUKINGNOBS",
		"FOCKINOBS",
		"FOCKINGNOBS",
		"FOKINOBS",
		"FOKINGNOBS",
		"FUCKINOBS",
		"FUCKINGNOBS",
		"FUKINOBS",
		"FUKINGNOBS",
		"FACKINRANDOM",
		"FACKINGRANDOM",
		"FAKINRANDOM",
		"FAKINGRANDOM",
		"FCKINRANDOM",
		"FCKINGRANDOM",
		"FCUKINRANDOM",
		"FCUKINGRANDOM",
		"FOCKINRANDOM",
		"FOCKINGRANDOM",
		"FOKINRANDOM",
		"FOKINGRANDOM",
		"FUCKINRANDOM",
		"FUCKINGRANDOM",
		"FUKINRANDOM",
		"FUKINGRANDOM",
		"FACKINRANDOMS",
		"FACKINGRANDOMS",
		"FAKINRANDOMS",
		"FAKINGRANDOMS",
		"FCKINRANDOMS",
		"FCKINGRANDOMS",
		"FCUKINRANDOMS",
		"FCUKINGRANDOMS",
		"FOCKINRANDOMS",
		"FOCKINGRANDOMS",
		"FOKINRANDOMS",
		"FOKINGRANDOMS",
		"FUCKINRANDOMS",
		"FUCKINGRANDOMS",
		"FUKINRANDOMS",
		"FUKINGRANDOMS",
		"FUCKER",
		"NAB",
		"NOB",
		"NOBS",
		"NUB",
		"NUBS",
		"RANDOMS",
		"YOURFACK",
		"YOURFAK",
		"YOURFCK",
		"YOURFCUK",
		"YOURFOCK",
		"YOURFOK",
		"YOURFUCK",
		"YOURFUK",
		"YOUSHIT"
	};
	
	array<string> negativList2 = {
		"ASHALE",
		"ASHOLE",
		"BITCH",
		"CACSUCKER",
		"CACSUKER",
		"CACKSUCKER",
		"CACKSUKER",
		"CAKSUCKER",
		"CAKSUKER",
		"COCSUCKER",
		"COCSUKER",
		"COCKSUCKER",
		"COCKSUKER",
		"COKSUCKER",
		"COKSUKER",
		"DICK",
		"FACKU",
		"FACKYOU",
		"FAKU",
		"FAKYOU",
		"FCKU",
		"FCKYOU",
		"FCUKU",
		"FCUKYOU",
		"FOCKU",
		"FOCKYOU",
		"FOKU",
		"FOKYOU",
		"FUCKU",
		"FUCKYOU",
		"FUKU",
		"FUKYOU",
		"HITLER",
		"IDIAT",
		"IDIOT",
		"MOTHERFACKER",
		"MOTHERFAKER",
		"MOTHERFCKER",
		"MOTHERFOCKER",
		"MOTHERFOKER",
		"MOTHERFUCKER",
		"MOTHERFUKER",
		"NIGA",
		"NIGER",
		"UBASTARD",
		"UBITCH",
		"UCACK",
		"UCOCK",
		"UCUNT",
		"UDICK",
		"UDUMB",
		"UFACK",
		"UFAGOT",
		"UFCK",
		"UFCUK",
		"UFOCK",
		"UFUCK",
		"UNAB",
		"UNOB",
		"UNUB",
		"UPIECEOFSHIT",
		"UPIECEOFSHT",
		"USHIT",
		"USUCK",
		"USCUK",
		"PUSY",
		"PUSI",
		"YOUAREGAY",
		"YOUARESHIT",
		"YOUARESHT",
		"YOUPIECEOFSHIT",
		"YOUPIECEOFSHT"
	};

	array<string> positivList2 = {
		"DICKBUT",
		"FACKUP",
		"FAKUP",
		"FCKUP",
		"FCUKUP",
		"FOCKUP",
		"FOKUP",
		"FUCKUP",
		"FUKUP",
		"PUSHIT",
		"RIOUSHIT",
		"RUSHIT",
		"YOUDUMBO",
		"YOUFUCKME",
		"YOUNOBODY"
	};
	
	InsultKiller(){
	}
	
	int countInsults2(string str){
		int counter = 0;
		
		for( uint i = 0; i < negativList2.size(); ++i ){
			if(str.Find(negativList2[i]) < String::INVALID_INDEX)++counter;
		}
		for( uint i = 0; i < positivList2.size(); ++i ){
			if(str.Find(positivList2[i]) < String::INVALID_INDEX)--counter;
		}
		
		return counter;
	}
	
	int countInsults3(string str){
		int counter = 0;
		
		for( uint i = 0; i < equalsList.size(); ++i ){
			if(str == equalsList[i])++counter;
		}
		
		return counter;
	}
}

InsultKiller@ g_InsultKiller;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	InsultKiller iKill();
	@g_InsultKiller = @iKill;
	
	Initialize();
}

void MapInit() {
}

void Initialize() {
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

string removeUnknown(string str) {
	
	str = "A"+str+"A";
	
	for( uint i = 1; i < str.Length()-1; ++i ){
		if(
			str[i] == 'A' || str[i] == 'B' || str[i] == 'C' || str[i] == 'D' || 
			str[i] == 'E' || str[i] == 'F' || str[i] == 'G' || str[i] == 'H' || 
			str[i] == 'I' || str[i] == 'J' || str[i] == 'K' || str[i] == 'L' || 
			str[i] == 'M' || str[i] == 'N' || str[i] == 'O' || str[i] == 'P' || 
			str[i] == 'Q' || str[i] == 'R' || str[i] == 'S' || str[i] == 'T' || 
			str[i] == 'U' || str[i] == 'V' || str[i] == 'W' || str[i] == 'X' || 
			str[i] == 'Y' || str[i] == 'Z'
		){
			//Valid Character
		}else if(str[i] == '!'){str = str.SubString(0, i) + "I" + str.SubString(i+1);
		}else if(str[i] == '$'){str = str.SubString(0, i) + "S" + str.SubString(i+1);
		}else if(str[i] == '&'){str = str.SubString(0, i) + "S" + str.SubString(i+1);
		}else if(str[i] == '0'){str = str.SubString(0, i) + "O" + str.SubString(i+1);
		}else if(str[i] == '1'){str = str.SubString(0, i) + "I" + str.SubString(i+1);
		}else if(str[i] == '2'){str = str.SubString(0, i) + "Z" + str.SubString(i+1);
		}else if(str[i] == '3'){str = str.SubString(0, i) + "E" + str.SubString(i+1);
		}else if(str[i] == '4'){str = str.SubString(0, i) + "A" + str.SubString(i+1);
		}else if(str[i] == '5'){str = str.SubString(0, i) + "S" + str.SubString(i+1);
		}else if(str[i] == '6'){str = str.SubString(0, i) + "G" + str.SubString(i+1);
		}else if(str[i] == '7'){str = str.SubString(0, i) + "T" + str.SubString(i+1);
		}else if(str[i] == '8'){str = str.SubString(0, i) + "B" + str.SubString(i+1);
		}else if(str[i] == '9'){str = str.SubString(0, i) + "G" + str.SubString(i+1);
		}else if(str[i] == '@'){str = str.SubString(0, i) + "A" + str.SubString(i+1);
		}else if(str[i] == '|'){str = str.SubString(0, i) + "I" + str.SubString(i+1);
		}else{
			str = str.SubString(0, i) + str.SubString(i+1);
			--i;
		}
	}
	
	str = str.SubString(1, str.Length()-2);
	return str;
}

string removeUnknown2(string str){
	str = removeUnknown(str);
	string lastLetter = "a";
	
	str = "A"+str+"A";
	for( uint i = 1; i < str.Length()-1; ++i ){
		
		if(str.SubString(i, 1)==lastLetter){
			str = str.SubString(0, i) + str.SubString(i+1);
			--i;
		} else {
			lastLetter = str.SubString(i, 1);
		}
	}
	str = str.SubString(1, str.Length()-2);
	
	return str;
}

string InsultCheck2( SayParameters@ m_pArgs ) {
	string str = m_pArgs.GetCommand();
	str.ToUppercase();
	str = removeUnknown2(str);
	
	return str;
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	string str2 = InsultCheck2( pParams );
	
	if(g_InsultKiller.countInsults2(str2) + g_InsultKiller.countInsults3(str2) > 0){
		CBasePlayer@ pPlayer = pParams.GetPlayer();
		
		pParams.ShouldHide = true;
		
		g_Game.AlertMessage( at_logged, "\"%1\" <%2> tried to say \"%3\"\n",
				pPlayer.pev.netname, g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ), pParams.GetCommand() );
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "SERVER: Message removed!\n"); 
	
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
