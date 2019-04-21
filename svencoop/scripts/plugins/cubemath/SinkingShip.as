array<CBaseEntity@> g_entIdx;
array<Vector> g_oldOri;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Scheduler.SetInterval( "CheckPlayerSinking", 0.1 );
	
	g_entIdx.resize( g_Engine.maxClients );
	g_oldOri.resize( g_Engine.maxClients );
	
	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		@g_entIdx[ iPlayer ] = null;
		g_oldOri[ iPlayer ] = Vector(0, 0, 0);
	}
}

void MapInit(){
	g_entIdx.resize( g_Engine.maxClients );
	g_oldOri.resize( g_Engine.maxClients );
	
	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		@g_entIdx[ iPlayer ] = null;
		g_oldOri[ iPlayer ] = Vector(0, 0, 0);
	}
}

void CheckPlayerSinking(){
	int jMax = g_Engine.maxClients;
	for( int j = 0; j < jMax; ++j ){
		if(g_entIdx[ j ] is null){
			
			for( int k = j; k+1 < jMax; k++){
				@g_entIdx[ k ] = @g_entIdx[ k+1 ];
				g_oldOri[ k ] = g_oldOri[ k+1 ];
			}
			
			@g_entIdx[ jMax-1 ] = null;
			g_oldOri[ jMax-1 ] = Vector(0, 0, 0);
			
			--j;
			--jMax;
		}else{
			Vector distance = g_entIdx[ j ].pev.origin - g_oldOri[ j ];
			float distanceF = sqrt(distance.x*distance.x + distance.y*distance.y + distance.z*distance.z);
			
			if( distanceF > 0.0 && distanceF < 2.0 ){
				g_entIdx[ j ].pev.origin = g_oldOri[ j ];
			}
		}
	}
	
	for( int i = 0; i < g_Engine.maxEntities; ++i ) {
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
		
		if( pEntity !is null && pEntity.GetClassname() == "deadplayer") {
			for( int j = 0; j < g_Engine.maxClients; ++j ){
				if(g_entIdx[ j ] is null){
					@g_entIdx[ j ] = @pEntity;
					g_oldOri[ j ] = pEntity.pev.origin;
					break;
				}else if(g_entIdx[ j ] == pEntity){
					break;
				}
			}
		}
	}
}
