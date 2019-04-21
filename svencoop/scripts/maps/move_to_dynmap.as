//I used that script on Servers, where I can't modify its start-up parameter +map
//I just called this map_script from a map.cfg to change the map after I boot up the gameserver.
void MapActivate(){
	g_EngineFuncs.ChangeLevel( "dynamic_mapvote" );
}
