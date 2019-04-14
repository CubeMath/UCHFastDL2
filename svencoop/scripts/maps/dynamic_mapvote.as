
string g_model_floor_default;
string g_model_floor_vote;
string g_model_wall_default;
string g_model_wall_vote;
string g_model_ascii_error;
array<string> g_model_ascii;
array<string> g_mapvote_sprite;
array<string> g_mapvote_title;
array<string> g_mapvote_1;
array<string> g_mapvote_2;
int voteTime;
int voteTime2;
int targetMapIdx;

void addWallDefault(int x, int y){
	string posi = ""+x+" "+y+" 2048";
	dictionary keyvalues = {
			{ "model", g_model_wall_default },
			{ "origin", posi },
			{ "angles", "0 0 0" },
			{ "rendermode", "0" },
			{ "rendercolor", "0 0 0" },
			{ "renderfx", "0" },
			{ "style", "0" },
			{ "zhlt_lightflags", "0" }
	};
	g_EntityFuncs.CreateEntity("func_wall", keyvalues, true);
}

void addWallVote(int x, int y){
	string posi = ""+x+" "+y+" 2048";
	dictionary keyvalues = {
			{ "model", g_model_wall_vote },
			{ "origin", posi },
			{ "angles", "0 0 0" },
			{ "rendermode", "0" },
			{ "rendercolor", "0 0 0" },
			{ "renderfx", "0" },
			{ "style", "0" },
			{ "zhlt_lightflags", "0" }
	};
	g_EntityFuncs.CreateEntity("func_wall", keyvalues, true);
}

void addFloorDefault(int x, int y){
	string posi = ""+x+" "+y+" 2048";
	dictionary keyvalues = {
			{ "model", g_model_floor_default },
			{ "origin", posi },
			{ "angles", "0 0 0" },
			{ "rendermode", "0" },
			{ "rendercolor", "0 0 0" },
			{ "renderfx", "0" },
			{ "style", "0" },
			{ "zhlt_lightflags", "0" }
	};
	g_EntityFuncs.CreateEntity("func_wall", keyvalues, true);
}

void addFloorVote(int x, int y){
	string posi = ""+x+" "+y+" 2048";
	dictionary keyvalues = {
			{ "model", g_model_floor_vote },
			{ "origin", posi },
			{ "angles", "0 0 0" },
			{ "rendermode", "0" },
			{ "rendercolor", "0 0 0" },
			{ "renderfx", "0" },
			{ "style", "0" },
			{ "zhlt_lightflags", "0" }
	};
	g_EntityFuncs.CreateEntity("func_wall", keyvalues, true);
}

void addCharacterToVoteScreen(int x, int y, int z, char c){
	int charNum = 95;
	string modelName = g_model_ascii_error;
	if(c >= 32 && c <= 126){
		charNum = c - 32;
		if(charNum == 0) return;
		modelName = g_model_ascii[charNum];
	}
	
	string posi = ""+x+" "+y+" "+z;
	dictionary keyvalues = {
			{ "model", modelName },
			{ "origin", posi },
			{ "angles", "0 0 0" },
			{ "rendermode", "2" },
			{ "rendercolor", "0 0 0" },
			{ "renderamt", "255" },
			{ "renderfx", "0" },
			{ "style", "0" },
			{ "zhlt_lightflags", "0" },
			{ "skin", "-1" }
	};
	g_EntityFuncs.CreateEntity("func_illusionary", keyvalues, true);
}

void addTextToVoteScreen(int x, int y, string str){
	int screenPosX = 0;
	int screenPosY = 0;
	
	array<int> offset = {0, 0, 0, 0, 0};
	int offsetY = 0;
	
	for(uint i = 0; i < str.Length(); i++){
		if(screenPosX >= 22){
			screenPosX = 0;
			screenPosY++;
		}
		if(screenPosY >= 5) {
			break;
		}
		
		if(str[i] == '\n'){
			offset[screenPosY] = 11 - (screenPosX + 1) / 2;
			
			screenPosX = 0;
			screenPosY++;
		}else{
			screenPosX++;
		}
	}
	
	if(screenPosY < 5) {
		offset[screenPosY] = 11 - (screenPosX + 1) / 2;
		offsetY = 2 - (screenPosY + 1) / 2;
	}
	
	screenPosX = 0;
	screenPosY = 0;
	
	for(uint i = 0; i < str.Length(); i++){
	
		while(screenPosY < offsetY){
			screenPosX = 0;
			screenPosY++;
		}
		
		if(screenPosX >= 22){
			screenPosX = 0;
			screenPosY++;
		}
		if(screenPosY >= 5) break;
		
		if(str[i] == '\n'){
			screenPosX = 0;
			screenPosY++;
		}else{
			while(screenPosX < offset[screenPosY - offsetY]){
				screenPosX++;
			}
			addCharacterToVoteScreen(x-84+screenPosX*8, y-124, 2192-16*screenPosY, str[i]);
			screenPosX++;
		}
	}
	
}

void loadVoteFile(){
	File@ pFile = g_FileSystem.OpenFile( "scripts/maps/store/mapvote_maps.txt", OpenFile::READ );
	
	if( pFile is null || !pFile.IsOpen() ) {
		g_mapvote_sprite.resize( 1 );
		g_mapvote_title.resize( 1 );
		g_mapvote_1.resize( 1 );
		g_mapvote_2.resize( 1 );
		
		g_mapvote_sprite[0] = "";
		g_mapvote_title[0] = "File not found!\n/scripts/maps/store\n/mapvote_maps.txt";
		g_mapvote_1[0] = "hl_c00";
		g_mapvote_2[0] = "hl_c02_a1";
		return;
	}
	
	string line;
	int arrSize = 0;
	voteTime = -1;
	
	while( !pFile.EOFReached() ){
		pFile.ReadLine( line );
		
		if(line.Length() < 1) continue;
		
		if(voteTime < 0){
			if(line.Find("Time: ") == 0){
				voteTime = atoi( line.SubString( 6 ) );
			}
			
			if(voteTime < 0) {
				voteTime = 30;
			}else{
				continue;
			}
		}
		
		int splitter1 = -1;
		int splitter2 = -1;
		int splitter3 = -1;
		bool escapeMode = false;
		
		for(uint i = 0; i < line.Length(); i++){
			if(line[i] == "\\"){
				if(escapeMode){
					for(uint j = i; j < line.Length()-1; j++){
						line.SetCharAt(j, line[j+1]);
					}
					line = line.SubString( 0, line.Length()-1 );
					i--;
					escapeMode = false;
				}else{
					escapeMode = true;
				}
			}else if(line[i] == "n"){
				if(escapeMode){
					line.SetCharAt(i-1, char('\n'));
					for(uint j = i; j < line.Length()-1; j++){
						line.SetCharAt(j, line[j+1]);
					}
					line = line.SubString( 0, line.Length()-1 );
					i--;
					escapeMode =false;
				}
			}else if(line[i] == "|"){
				if(escapeMode){
					line.SetCharAt(i-1, char('|'));
					for(uint j = i; j < line.Length()-1; j++){
						line.SetCharAt(j, line[j+1]);
					}
					line = line.SubString( 0, line.Length()-1 );
					i--;
					escapeMode = false;
				}else if(splitter1 == -1){
					splitter1 = i;
				}else if(splitter2 == -1){
					splitter2 = i;
				}else if(splitter3 == -1){
					splitter3 = i;
				}
			}else{
				escapeMode = false;
			}
		}
		
		if(
			splitter1 != -1 &&
			line.SubString( 0, splitter1 ).Length() > 4 &&
			line.SubString( splitter1-4, 4 ) == ".spr"
		){
			if(splitter2 != -1){
				g_mapvote_sprite.resize( g_mapvote_sprite.size() + 1 );
				g_mapvote_title.resize( g_mapvote_title.size() + 1 );
				g_mapvote_1.resize( g_mapvote_1.size() + 1 );
				g_mapvote_2.resize( g_mapvote_2.size() + 1 );
				
				g_mapvote_sprite[g_mapvote_sprite.size() - 1] = line.SubString( 0, splitter1 );
				g_mapvote_title[g_mapvote_title.size() - 1] = line.SubString( splitter1+1, splitter2-splitter1-1 );
				
				if( g_mapvote_sprite[g_mapvote_sprite.size() - 1].Length() > 0 ){
					g_Game.PrecacheModel( g_mapvote_sprite[g_mapvote_sprite.size() - 1] );
				}
				
				if(splitter3 != -1){
					g_mapvote_1[g_mapvote_1.size() - 1] = line.SubString( splitter2+1, splitter3-splitter2-1 );
					g_mapvote_2[g_mapvote_2.size() - 1] = line.SubString( splitter3+1 );
				}else{
					g_mapvote_1[g_mapvote_1.size() - 1] = line.SubString( splitter2+1 );
					g_mapvote_2[g_mapvote_2.size() - 1] = "";
				}
			}
		}else{
			if(splitter1 != -1){
				g_mapvote_sprite.resize( g_mapvote_sprite.size() + 1 );
				g_mapvote_title.resize( g_mapvote_title.size() + 1 );
				g_mapvote_1.resize( g_mapvote_1.size() + 1 );
				g_mapvote_2.resize( g_mapvote_2.size() + 1 );
				
				g_mapvote_sprite[g_mapvote_sprite.size() - 1] = "";
				g_mapvote_title[g_mapvote_title.size() - 1] = line.SubString( 0, splitter1 );
				
				if(splitter2 != -1){
					g_mapvote_1[g_mapvote_1.size() - 1] = line.SubString( splitter1+1, splitter2-splitter1-1 );
					g_mapvote_2[g_mapvote_2.size() - 1] = line.SubString( splitter2+1 );
				}else{
					g_mapvote_1[g_mapvote_1.size() - 1] = line.SubString( splitter1+1 );
					g_mapvote_2[g_mapvote_2.size() - 1] = "";
				}
			}
		}
	}
	
	voteTime2 = voteTime;
	targetMapIdx = -1;
	
	if(g_mapvote_title.size() < 1){
		g_mapvote_sprite.resize( 1 );
		g_mapvote_title.resize( 1 );
		g_mapvote_1.resize( 1 );
		g_mapvote_2.resize( 1 );
		
		g_mapvote_sprite[0] = "";
		g_mapvote_title[0] = "Invalid Syntax!\nSyntax:\ntitle|mapname";
		g_mapvote_1[0] = "hl_c00";
		g_mapvote_2[0] = "hl_c02_a1";
	}
	
	pFile.Close();
}

void skip_intro_vote(){
	float flVoteTime = 10.0;
	float flPercentage = 50.1;
	
	Vote vote( "Skip-Vote", "Skip Intro?", flVoteTime, flPercentage );
	string aStr = "Yes ("+g_mapvote_2[targetMapIdx]+")";
	vote.SetYesText(aStr);
	aStr = "No ("+g_mapvote_1[targetMapIdx]+")";
	vote.SetNoText(aStr);
	vote.SetVoteBlockedCallback( @skip_intro_vote_blocked );
	vote.SetVoteEndCallback( @skip_intro_vote_end );
	
	vote.Start();
}

void skip_intro_vote_blocked( Vote@ pVote, float flTime ){
	g_Scheduler.SetTimeout( "skip_intro_vote", flTime );
}

void skip_intro_vote_end( Vote@ pVote, bool bResult, int iVoters ){
	if( !bResult || iVoters == 0 ){
		g_EngineFuncs.ChangeLevel( g_mapvote_1[targetMapIdx] );
		g_Scheduler.SetTimeout( "print_map404_message", 1.0f, false );
		return;
	}
	
	g_EngineFuncs.ChangeLevel( g_mapvote_2[targetMapIdx] );
	g_Scheduler.SetTimeout( "print_map404_message", 1.0f, true );
}

void change_first_map(){
	g_EngineFuncs.ChangeLevel( g_mapvote_1[targetMapIdx] );
	g_Scheduler.SetTimeout( "print_map404_message", 1.0f, false );
}

void print_map404_message(bool useSecondaryMap){
	
	HUDTextParams hudParams;
	hudParams.x = -1.0f;
	hudParams.y = 0.7;
	hudParams.r1 = 255;
	hudParams.g1 = 0;
	hudParams.b1 = 0;
	hudParams.r2 = 255;
	hudParams.g2 = 0;
	hudParams.b2 = 0;
	hudParams.effect = 0;
	hudParams.fadeinTime = 0.0f;
	hudParams.fadeoutTime = 0.80f;
	hudParams.holdTime = 2.0f;
	hudParams.channel = 1;
	
	g_Scheduler.SetTimeout( "vote_logic", 3.0f );
	
	if(useSecondaryMap){
		string aStr = "ERROR! Map not found: " + g_mapvote_2[targetMapIdx];
		g_PlayerFuncs.HudMessageAll(hudParams, aStr);
	}else{
		string aStr = "ERROR! Map not found: " + g_mapvote_1[targetMapIdx];
		g_PlayerFuncs.HudMessageAll(hudParams, aStr);
	}
	
	voteTime = voteTime2;
}

void vote_logic(){
	HUDTextParams hudParams;
	hudParams.x = -1.0f;
	hudParams.y = 0.7;
	hudParams.r1 = 255;
	hudParams.g1 = 255;
	hudParams.b1 = 255;
	hudParams.r2 = 255;
	hudParams.g2 = 255;
	hudParams.b2 = 255;
	hudParams.effect = 0;
	hudParams.fadeinTime = 0.0f;
	hudParams.fadeoutTime = 0.45f;
	hudParams.holdTime = 1.05f;
	hudParams.channel = 1;
	
	uint roomSize = g_mapvote_title.size();
	array<int> voters;
	voters.resize(roomSize);
	int totalVoters = 0;
	
	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		
		if( pPlayer is null || !pPlayer.IsConnected() || pPlayer.pev.origin.y < 640 || pPlayer.pev.origin.y > 896)
			continue;
		
		int relPos = int(pPlayer.pev.origin.x)+128*roomSize;
		int arr_idx = relPos/256;
		
		if(relPos < 0 || arr_idx >= int(roomSize))
			continue;
		
		totalVoters++;
		voters[arr_idx]++;
	}
	
	if(totalVoters == 0){
		voteTime = voteTime2;
		g_Scheduler.SetTimeout( "vote_logic", 1.0f );
	}else{
		int topIdx = -1;
		int topMax = -1;
		
		for( uint i = 0; i < roomSize; i++ ){
			if(voters[i] > topMax){
				topMax = voters[i];
				topIdx = i;
			}
		}
		
		string aStr = "Time: " + voteTime + "\n\nResult:\n" + g_mapvote_title[topIdx];
		g_PlayerFuncs.HudMessageAll(hudParams, aStr);
		
		voteTime--;
		if(voteTime < 0){
			g_SoundSystem.EmitSoundDyn( g_EntityFuncs.Instance(0).edict(), CHAN_STATIC, "buttons/bell1.wav", 1.0f, ATTN_NONE, 0, 100 );
			
			targetMapIdx = topIdx;
			
			if(g_mapvote_2[topIdx].Length() < 1){
				g_Scheduler.SetTimeout( "change_first_map", 2.0f );
			}else{
				g_Scheduler.SetTimeout( "skip_intro_vote", 2.0f );
			}
			
		}else{
			if(voteTime < 10)
				g_SoundSystem.EmitSoundDyn( g_EntityFuncs.Instance(0).edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 100 );
			g_Scheduler.SetTimeout( "vote_logic", 1.0f );
		}
	}
}

void MapInit(){
	g_SoundSystem.PrecacheSound( "buttons/blip1.wav" );
	g_SoundSystem.PrecacheSound( "buttons/bell1.wav" );
	
	g_mapvote_sprite.resize( 0 );
	g_mapvote_title.resize( 0 );
	g_mapvote_1.resize( 0 );
	g_mapvote_2.resize( 0 );
	
	loadVoteFile();
}

void MapActivate(){
	g_model_ascii.resize(95);
	
	for( int i = 0; i < g_Engine.maxEntities; ++i ) {
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
		
		if( pEntity !is null ) {
			string targetname = pEntity.pev.targetname;
			
			if(targetname == "wall_vote"){
				g_model_wall_vote = pEntity.pev.model;
				g_EntityFuncs.Remove( pEntity );
				
			}else if(targetname == "wall_default"){
				g_model_wall_default = pEntity.pev.model;
				g_EntityFuncs.Remove( pEntity );
				
			}else if(targetname == "floor_vote"){
				g_model_floor_vote = pEntity.pev.model;
				g_EntityFuncs.Remove( pEntity );
				
			}else if(targetname == "floor_default"){
				g_model_floor_default = pEntity.pev.model;
				g_EntityFuncs.Remove( pEntity );
				
			}else if(targetname.Find("ascii_") == 0){
				if(targetname == "ascii_err"){
					g_model_ascii_error = pEntity.pev.model;
				}else{
					int ascii_number = atoi( targetname.SubString( 6 ) );
					g_model_ascii[ascii_number-32] = pEntity.pev.model;
				}
				g_EntityFuncs.Remove( pEntity );
				
			}
		}
	}
	
	int roomSize = g_mapvote_title.size();
	if(roomSize > 63) roomSize = 63;
	
	addWallDefault(-128-roomSize*128, 768);
	addWallDefault(-128-roomSize*128, 512);
	addWallDefault(-128-roomSize*128, 256);
	addWallDefault(-128-roomSize*128, 0);
	
	addWallDefault(128+roomSize*128, 768);
	addWallDefault(128+roomSize*128, 512);
	addWallDefault(128+roomSize*128, 256);
	addWallDefault(128+roomSize*128, 0);
	
	for(int i = 0; i < roomSize; i++){
		addWallVote(i*256-roomSize*128+128, 1024);
		if(g_mapvote_sprite[i].Length() > 0){
			string oStr = "" + (i*256-roomSize*128+128) + " 897 2160";
			
			dictionary keyvalues = {
				{"model", g_mapvote_sprite[i]},
				{"vp_type", "4"},
				{"scale", "0.5"},
				{"framerate", "10"},
		//		{"angles", "0 90 0"}, Not sure why this is not working propertly
				{"rendercolor", "255 255 255"},
				{"rendermode", "2"},
				{"renderfx", "0"},
				{"renderamt", "255"},
				{"origin", oStr}
			};
			
			CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "env_sprite", keyvalues );
			pEntity.pev.angles = Vector(0, 90, 0);
		}else{
			addTextToVoteScreen(i*256-roomSize*128+128, 1024, g_mapvote_title[i]);
		}
		addFloorVote(i*256-roomSize*128+128, 768);
		addFloorDefault(i*256-roomSize*128+128, 512);
		addFloorDefault(i*256-roomSize*128+128, 256);
		addFloorDefault(i*256-roomSize*128+128, 0);
		addWallDefault(i*256-roomSize*128+128, -256);
	}
	
	g_Scheduler.SetTimeout( "vote_logic", 1.0f );
}
