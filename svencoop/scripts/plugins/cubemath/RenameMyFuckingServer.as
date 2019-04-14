
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
}

void MapInit(){
  string mapname = g_Engine.mapname;
	bool adDecay = false;
  
  if(mapname.Find("dy") == 0) adDecay = true;
  if(mapname == "hl_c18") adDecay = true;
  if(mapname == "of7a0") adDecay = true;
  if(mapname == "ba_outro") adDecay = true;
  
  if(adDecay)
    g_EngineFuncs.ServerCommand("hostname \"Half-Life Decay\"\n");
  else
    g_EngineFuncs.ServerCommand("hostname \"Anti-Rush - Supports Half-Life Decay\"\n");
  
  g_EngineFuncs.ServerExecute();
}
