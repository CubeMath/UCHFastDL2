
class arrow : ScriptBaseEntity {
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.speed = 0;
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		g_EntityFuncs.SetModel(self, "models/cubemath/arrow2d.mdl");
	}
}

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

void MapInit(){
	g_Game.PrecacheModel( "models/cubemath/arrow2d.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "arrow", "arrow" );
}

HookReturnCode ClientSay(SayParameters@ pParams){
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	string str = pParams.GetCommand();
	str.ToUppercase();
	
	if (str == "!ARROW"){
		Vector vecSrc = pPlayer.GetGunPosition();
		Vector vecDir = pPlayer.GetAutoaimVector( 0.0f );
		Vector vecEnd = vecSrc + vecDir * 8192.0f;
		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, ignore_monsters, pPlayer.edict(), tr );
		
		//Vector tr.vecPlaneNormal
		//Vector vecDir
		float angleToNormal = -DotProduct(tr.vecPlaneNormal, vecDir);
		
		Vector reflectVec = tr.vecPlaneNormal * angleToNormal + vecDir;
		float lenReflectVec = reflectVec.x*reflectVec.x+reflectVec.y*reflectVec.y+reflectVec.z*reflectVec.z;
		if(lenReflectVec != 0.0){
			lenReflectVec = sqrt(lenReflectVec);
			reflectVec.x = reflectVec.x/lenReflectVec;
			reflectVec.y = reflectVec.y/lenReflectVec;
			reflectVec.z = reflectVec.z/lenReflectVec;
		}
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create( "arrow", tr.vecEndPos, Math.VecToAngles( reflectVec ), false );
		
		// string aStr = "tr.vecPlaneNormal: (" + tr.vecPlaneNormal.x + ", " + tr.vecPlaneNormal.y + ", " + tr.vecPlaneNormal.z + ")\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		// aStr = "reflectVec: (" + reflectVec.x + ", " + reflectVec.y + ", " + reflectVec.z + ")\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		
		Vector vecPlaneNormal2 = tr.vecPlaneNormal;
		vecPlaneNormal2.z = 0.0;
		float angleToHorizont = 0.0f;
		
		float lenvecPlaneNormal2 = vecPlaneNormal2.x*vecPlaneNormal2.x+vecPlaneNormal2.y*vecPlaneNormal2.y;
		
		if(lenvecPlaneNormal2 != 0.0){
			lenvecPlaneNormal2 = sqrt(lenvecPlaneNormal2);
			
			vecPlaneNormal2.x = vecPlaneNormal2.x/lenvecPlaneNormal2;
			vecPlaneNormal2.y = vecPlaneNormal2.y/lenvecPlaneNormal2;
			
			angleToHorizont = asin(DotProduct(tr.vecPlaneNormal, vecPlaneNormal2))*180.0f/3.14159265358979323846f;
		}
		
		// aStr = "angleToHorizont: " + angleToHorizont + "\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		
		Vector vecCross = CrossProduct(tr.vecPlaneNormal, reflectVec);
		// aStr = "vecCross: (" + vecCross.x + ", " + vecCross.y + ", " + vecCross.z + ")\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		
		Vector reflectVec2 = vecCross;
		reflectVec2.z = 0.0;
		float angleToHorizont2 = 0.0f;
		
		float lenreflectVec2 = reflectVec2.x*reflectVec2.x+reflectVec2.y*reflectVec2.y;
		
		if(lenreflectVec2 != 0.0){
			lenreflectVec2 = sqrt(lenreflectVec2);
			
			reflectVec2.x = reflectVec2.x/lenreflectVec2;
			reflectVec2.y = reflectVec2.y/lenreflectVec2;
			
			angleToHorizont2 = acos(DotProduct(vecCross, reflectVec2))*180.0f/3.14159265358979323846f;
		}
		
		// aStr = "angleToHorizont2: " + angleToHorizont2 + "\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		
		if(angleToHorizont > 89.0){
			pEntity.pev.angles.z = 90.0;
		}else if(angleToHorizont > 0.0){
			if(vecCross.z < 0.0)
				pEntity.pev.angles.z = -angleToHorizont2;
			else
				pEntity.pev.angles.z = angleToHorizont2;
		}
		
		// aStr = "pEntity.pev.angles: (" + pEntity.pev.angles.x + ", " + pEntity.pev.angles.y + ", " + pEntity.pev.angles.z + ")\n";
		// g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, aStr );
		
		//pEntity.pev.angles.z = pEntity.pev.angles.y * tr.vecPlaneNormal.z;
		
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}else if (str == "!ARROW_DELETE" || str == "!ARROW_REMOVE"){
		Vector vecSrc = pPlayer.GetGunPosition();
		Vector vecDir = pPlayer.GetAutoaimVector( 0.0f );
		Vector vecEnd = vecSrc + vecDir * 8192.0f;
		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, ignore_monsters, pPlayer.edict(), tr );
		
		CBaseEntity@ pEntityClosest = null;
		float distClosest = 300000000.0f;
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			if( pEntity is null ) continue;
			if( pEntity.pev.classname != "arrow" ) continue;
			
			Vector midPos = pEntity.pev.origin;
			
			Vector distVec = Vector(0,0,0);
			distVec.x = midPos.x - tr.vecEndPos.x;
			distVec.y = midPos.y - tr.vecEndPos.y;
			distVec.z = midPos.z - tr.vecEndPos.z;
			
			float currDist = distVec.x * distVec.x + distVec.y * distVec.y + distVec.z * distVec.z;
			
			if(currDist < distClosest){
				distClosest = currDist;
				@pEntityClosest = @pEntity;
			}
		}
		
		if( pEntityClosest !is null ){
			g_EntityFuncs.Remove( pEntityClosest );
		}
		
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}else if (str == "!ARROW_CLEAR" || str == "!ARROW_CLEAN"){
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			if( pEntity is null ) continue;
			if( pEntity.pev.classname != "arrow" ) continue;
			
			g_EntityFuncs.Remove( pEntity );
		}
		
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
