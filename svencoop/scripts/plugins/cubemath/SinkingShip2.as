
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Scheduler.SetInterval( "CheckPlayerSinking", 0.1 );
}

void CheckPlayerSinking(){
	for( int i = 0; i < g_Engine.maxEntities; ++i ) {
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
		
		if( pEntity !is null && pEntity.GetClassname() == "deadplayer" && pEntity.pev.speed < 10.0 && pEntity.pev.movetype != 5) {
			pEntity.pev.origin.z += 20.0;
			pEntity.pev.velocity.z -= 128.0;
			pEntity.pev.movetype = 5;
		}
	}
}
