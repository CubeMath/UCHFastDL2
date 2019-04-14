void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_OWNER );
	
}

void MapInit() {
	RegisterWeaponDebug();
}

class weapon_debug : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	private int m_mode = 0;
	private int m_switch = 0;
	private int m_iSprModel;
	private float m_cooldown;
	
	void Spawn(){
		Precache();
		self.m_iClip = -1;
		m_cooldown = g_Engine.time + 0.1f;
		
		self.FallInit();// get ready to fall
	}

	void Precache(){
		self.PrecacheCustomModels();
		
		m_iSprModel = g_Game.PrecacheModel( "sprites/dot.spr" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer ){
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		m_mode = 1;
		
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		
		return true;
	}
	
	bool GetItemInfo( ItemInfo& out info ){
		info.iMaxAmmo1 = -1;
		info.iMaxAmmo2 = -1;
		info.iSlot = 6;
		info.iPosition = 5;
		info.iWeight = 1;
		info.iFlags = 0;
		info.iMaxClip = WEAPON_NOCLIP;
		
		return true;
	}
	
	void DrawHUD(string aStr){
		HUDTextParams params;
		params.x = 0.6f;
		params.y = 0.5f;
		params.r1 = 255;
		params.g1 = 255;
		params.b1 = 255;
		params.a1 = 255;
		params.r2 = 255;
		params.g2 = 255;
		params.b2 = 255;
		params.a2 = 255;
		params.fadeinTime = 0.0f;
		params.fadeoutTime = 0.0f;
		params.holdTime = 0.2f;
		params.channel = 1;
		
		g_PlayerFuncs.HudMessage( m_pPlayer, params, aStr );
		g_PlayerFuncs.HudToggleElement( m_pPlayer, 1, true );
	}
	
	bool Deploy(){
		return self.DefaultDeploy( self.GetV_Model( "" ), self.GetP_Model( "" ), 0, "crowbar" );
	}
	
	void Holster( int skipLocal = 0 ){
		BaseClass.Holster( skipLocal );
	}
	
	void drawCoordinates(int firemode){
		TraceResult tr;
		
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecDir = m_pPlayer.GetAutoaimVector( 0.0f );
		
		Vector vecEnd = vecSrc + vecDir * 65536.0f;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if(firemode == 1) {
			m_pPlayer.pev.origin = m_pPlayer.pev.origin + vecDir * 16.0f;
			m_pPlayer.pev.velocity = Vector(0,0,0);
			m_switch = 2;
		}
		if(firemode == 2) {
			m_pPlayer.pev.origin = m_pPlayer.pev.origin - vecDir * 16.0f;
			m_pPlayer.pev.velocity = Vector(0,0,0);
			m_switch = 3;
		}
		
		if( tr.pHit !is null ){
			tr.vecEndPos.x = floor(tr.vecEndPos.x+0.5f);
			tr.vecEndPos.y = floor(tr.vecEndPos.y+0.5f);
			tr.vecEndPos.z = floor(tr.vecEndPos.z+0.5f);
			
      Vector copyAng = m_pPlayer.pev.angles;
			copyAng.x = floor(copyAng.x*3.0+0.5f);
			copyAng.y = floor(copyAng.y+0.5f);
      
			string aStr = "Mode 1 - TargetPos:\nx: "+tr.vecEndPos.x+
      "\ny: "+tr.vecEndPos.y+
      "\nz: "+tr.vecEndPos.z+
      "\npitch: "+copyAng.x+
      "\nyaw: "+copyAng.y;
			
			vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
			
			CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam.PointsInit( vecSrc, tr.vecEndPos );
			m_pBeam.SetColor( 255, 0, 0 );
			m_pBeam.SetBrightness( 255 );
			m_pBeam.SetNoise( 0.0f );
			m_pBeam.SetWidth( 1 );
			m_pBeam.LiveForTime(0.001f);
			
			DrawHUD(aStr);
		}
	}
	
	void drawEntityData(int firemode){
		Vector vecAiming = m_pPlayer.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		edict_t@ pHit = tr.pHit;
		
		if(pHit !is null){
		
			if(m_switch == 0){
				if(firemode == 1) g_EntityFuncs.Instance(pHit).Use( m_pPlayer, m_pPlayer, USE_ON , 0 );
				if(firemode == 2) g_EntityFuncs.Instance(pHit).Use( m_pPlayer, m_pPlayer, USE_OFF, 0 );
				
				m_switch = 1;
			}
			
			string aStr = "Mode 2 - Entity-Data:\nClassname: \""+pHit.vars.classname+
					"\"\nTargetname: \""+pHit.vars.targetname+
					"\"\nTarget: \""+pHit.vars.target+
					"\"\nMessage: \""+pHit.vars.message+
					"\"\nNetname: \""+pHit.vars.netname+
					"\"\nModel: \""+pHit.vars.model+
					"\"\nOrigin: "+pHit.vars.origin.x+" "+pHit.vars.origin.y+" "+pHit.vars.origin.z+
					"\nAngles: "+pHit.vars.angles.x+" "+pHit.vars.angles.y+" "+pHit.vars.angles.z+
					"\nHealth: "+pHit.vars.health+
					"\nSpeed: "+pHit.vars.speed+
					"\nMovetype: "+pHit.vars.movetype+
					"\nSolid: "+pHit.vars.solid;
					
			vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
			
			CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam.PointsInit( vecSrc, tr.vecEndPos );
			m_pBeam.SetColor( 255, 0, 0 );
			m_pBeam.SetBrightness( 255 );
			m_pBeam.SetNoise( 0.0f );
			m_pBeam.SetWidth( 1 );
			m_pBeam.LiveForTime(0.001f);
			
			DrawHUD(aStr);
		}
	}
	
	void drawEntityData2(int firemode){
		if(m_cooldown > g_Engine.time && firemode == 0) return;
		m_cooldown = g_Engine.time + 0.1f;
		
		Vector vecAiming = m_pPlayer.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 128.0f;
		float maxDist = 256.0f;
		float minDist = 64.0f;
		
		CBaseEntity@ pEntityClosest = null;
		float distClosest = maxDist*maxDist*3.0f;
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			if( pEntity is null ) continue;
			if( pEntity.pev.classname == "beam" ) continue;
			Vector midPos = pEntity.pev.origin;
			if( midPos.x == 0 && midPos.y == 0 && midPos.z == 0 ) midPos = pEntity.Center();
			if( midPos.x == 0 && midPos.y == 0 && midPos.z == 0 ) continue;
			if( midPos.x > vecEnd.x + maxDist || midPos.x < vecEnd.x - maxDist) continue;
			if( midPos.y > vecEnd.y + maxDist || midPos.y < vecEnd.y - maxDist) continue;
			if( midPos.z > vecEnd.z + maxDist || midPos.z < vecEnd.z - maxDist) continue;
			
			if(
					midPos.x < vecSrc.x + minDist && midPos.x > vecSrc.x - minDist &&
					midPos.y < vecSrc.y + minDist && midPos.y > vecSrc.y - minDist &&
					midPos.z < vecSrc.z + minDist && midPos.z > vecSrc.z - minDist
			)continue;
			
			NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				message.WriteByte( TE_SPRITE );
				message.WriteCoord( midPos.x );	// pos
				message.WriteCoord( midPos.y );
				message.WriteCoord( midPos.z );
				message.WriteShort( m_iSprModel );	// model
				message.WriteByte( 1 );				// size * 10
				message.WriteByte( 128 );			// brightness
			message.End();
			
			Vector distVec = Vector(0,0,0);
			distVec.x = midPos.x - vecEnd.x;
			distVec.y = midPos.y - vecEnd.y;
			distVec.z = midPos.z - vecEnd.z;
			
			float currDist = distVec.x * distVec.x + distVec.y * distVec.y + distVec.z * distVec.z;
			
			if(currDist < distClosest){
				distClosest = currDist;
				@pEntityClosest = @pEntity;
			}
		}
		
		if(pEntityClosest is null){
			string aStr = "Mode 3 - Entity-Connections:\nNo Entity found!";
		
			vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
			
			CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam.PointsInit( vecSrc, vecEnd );
			m_pBeam.SetColor( 255, 0, 0 );
			m_pBeam.SetBrightness( 255 );
			m_pBeam.SetNoise( 0.0f );
			m_pBeam.SetWidth( 1 );
			m_pBeam.LiveForTime(0.1f);
			
			DrawHUD(aStr);
		}else{
			if(m_switch == 0){
				if(firemode == 1) {
					pEntityClosest.Use( m_pPlayer, m_pPlayer, USE_ON , 0 );
					if(pEntityClosest.pev.classname == "trigger_once" || pEntityClosest.pev.classname == "trigger_multiple"){
						g_EntityFuncs.FireTargets(pEntityClosest.pev.target, m_pPlayer, m_pPlayer, USE_TOGGLE, 0.0f, 0.0f);
						if(pEntityClosest.pev.classname == "trigger_once") g_EntityFuncs.Remove( pEntityClosest );
					}
				}
				if(firemode == 2) {
					pEntityClosest.Use( m_pPlayer, m_pPlayer, USE_OFF, 0 );
					if(pEntityClosest.pev.classname == "trigger_once" || pEntityClosest.pev.classname == "trigger_multiple"){
						g_EntityFuncs.FireTargets(pEntityClosest.pev.target, m_pPlayer, m_pPlayer, USE_TOGGLE, 0.0f, 0.0f);
						if(pEntityClosest.pev.classname == "trigger_once") g_EntityFuncs.Remove( pEntityClosest );
					}
				}
				
				m_switch = 1;
			}
			
			string aStr = "Mode 3 - Entity-Connections:\nClassname: \""+pEntityClosest.pev.classname+
					"\"\nTargetname: \""+pEntityClosest.pev.targetname+
					"\"\nTarget: \""+pEntityClosest.pev.target+
					"\"\nMessage: \""+pEntityClosest.pev.message+
					"\"\nNetname: \""+pEntityClosest.pev.netname+
					"\"\nModel: \""+pEntityClosest.pev.model+
					"\"\nOrigin: "+pEntityClosest.pev.origin.x+" "+pEntityClosest.pev.origin.y+" "+pEntityClosest.pev.origin.z+
					"\nAngles: "+pEntityClosest.pev.angles.x+" "+pEntityClosest.pev.angles.y+" "+pEntityClosest.pev.angles.z+
					"\nHealth: "+pEntityClosest.pev.health+
					"\nSpeed: "+pEntityClosest.pev.speed+
					"\nMovetype: "+pEntityClosest.pev.movetype+
					"\nSolid: "+pEntityClosest.pev.solid;
			
			vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
			
			Vector midPos = pEntityClosest.pev.origin;
			if( midPos.x == 0 && midPos.y == 0 && midPos.z == 0 ) midPos = pEntityClosest.Center();
			
			bool useTar = string(pEntityClosest.pev.target).Length() > 0;
			bool useMes = string(pEntityClosest.pev.message).Length() > 0;
			bool useNet = string(pEntityClosest.pev.netname).Length() > 0;
			
			for( int i = 0; i < g_Engine.maxEntities; ++i ) {
				CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
				if( pEntity is null ) continue;
				if( pEntity.pev.classname == "beam" ) continue;
				
				Vector midPos2 = pEntity.pev.origin;
				if( midPos2.x == 0 && midPos2.y == 0 && midPos2.z == 0 ) midPos2 = pEntity.Center();
				
				if(useTar && string(pEntity.pev.targetname) == string(pEntityClosest.pev.target)){
					CBeam@ m_pBeam1 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam1.PointsInit( midPos, midPos2 );
					m_pBeam1.SetColor( 0, 255, 0 );
					m_pBeam1.SetBrightness( 255 );
					m_pBeam1.SetNoise( 0.0f );
					m_pBeam1.SetWidth( 1 );
					m_pBeam1.LiveForTime(0.1f);
				}
				
				if(useMes && string(pEntity.pev.targetname) == string(pEntityClosest.pev.message)){
					CBeam@ m_pBeam2 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam2.PointsInit( midPos, midPos2 );
					m_pBeam2.SetColor( 0, 255, 0 );
					m_pBeam2.SetBrightness( 255 );
					m_pBeam2.SetNoise( 0.0f );
					m_pBeam2.SetWidth( 1 );
					m_pBeam2.LiveForTime(0.1f);
				}
				
				if(useNet && string(pEntity.pev.targetname) == string(pEntityClosest.pev.netname)){
					CBeam@ m_pBeam3 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam3.PointsInit( midPos, midPos2 );
					m_pBeam3.SetColor( 0, 255, 0 );
					m_pBeam3.SetBrightness( 255 );
					m_pBeam3.SetNoise( 0.0f );
					m_pBeam3.SetWidth( 1 );
					m_pBeam3.LiveForTime(0.1f);
				}
				
				if(string(pEntity.pev.target).Length() > 0 && string(pEntity.pev.target) == string(pEntityClosest.pev.targetname)){
					CBeam@ m_pBeam3 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam3.PointsInit( midPos, midPos2 );
					m_pBeam3.SetColor( 0, 0, 255 );
					m_pBeam3.SetBrightness( 255 );
					m_pBeam3.SetNoise( 0.0f );
					m_pBeam3.SetWidth( 1 );
					m_pBeam3.LiveForTime(0.1f);
				}
				
				if(string(pEntity.pev.message).Length() > 0 && string(pEntity.pev.message) == string(pEntityClosest.pev.targetname)){
					CBeam@ m_pBeam3 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam3.PointsInit( midPos, midPos2 );
					m_pBeam3.SetColor( 0, 0, 255 );
					m_pBeam3.SetBrightness( 255 );
					m_pBeam3.SetNoise( 0.0f );
					m_pBeam3.SetWidth( 1 );
					m_pBeam3.LiveForTime(0.1f);
				}
				
				if(string(pEntity.pev.netname).Length() > 0 && string(pEntity.pev.netname) == string(pEntityClosest.pev.targetname)){
					CBeam@ m_pBeam3 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam3.PointsInit( midPos, midPos2 );
					m_pBeam3.SetColor( 0, 0, 255 );
					m_pBeam3.SetBrightness( 255 );
					m_pBeam3.SetNoise( 0.0f );
					m_pBeam3.SetWidth( 1 );
					m_pBeam3.LiveForTime(0.1f);
				}
			}
			
			CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam.PointsInit( vecSrc, midPos );
			m_pBeam.SetColor( 255, 0, 0 );
			m_pBeam.SetBrightness( 255 );
			m_pBeam.SetNoise( 0.0f );
			m_pBeam.SetWidth( 1 );
			m_pBeam.LiveForTime(0.1f);
			
			DrawHUD(aStr);
		}
	}
	
	void drawDestroyer(int firemode){
		Vector vecAiming = m_pPlayer.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		edict_t@ pHit = tr.pHit;
		
		if(pHit !is null){
			
			if(string(pHit.vars.classname).Find("monster_") == 0){
				string aStr = "Mode 4 - Destroyer:\nClassname: \""+pHit.vars.classname+
						"\"\nTargetname: \""+pHit.vars.targetname+"\"";
				
				vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
				Vector midPos2 = pHit.vars.origin;
				if( midPos2.x == 0 && midPos2.y == 0 && midPos2.z == 0 ) midPos2 = g_EntityFuncs.Instance(pHit).Center();
				
				NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
					message.WriteByte( TE_SPRITE );
					message.WriteCoord( midPos2.x );	// pos
					message.WriteCoord( midPos2.y );
					message.WriteCoord( midPos2.z );
					message.WriteShort( m_iSprModel );	// model
					message.WriteByte( 1 );				// size * 10
					message.WriteByte( 128 );			// brightness
				message.End();
				
				CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
				m_pBeam.PointsInit( vecSrc, midPos2 );
				m_pBeam.SetColor( 255, 0, 0 );
				m_pBeam.SetBrightness( 255 );
				m_pBeam.SetNoise( 0.0f );
				m_pBeam.SetWidth( 1 );
				m_pBeam.LiveForTime(0.001f);
				
				DrawHUD(aStr);
					
				if(m_switch == 0){
					if(firemode == 1 || firemode == 2) {
						g_EntityFuncs.Instance(pHit).TakeDamage(m_pPlayer.pev, m_pPlayer.pev, pHit.vars.health * 2.0f + 1.0f, DMG_ALWAYSGIB);
					}
					m_switch = 1;
				}
			}else if(pHit.vars.classname == "worldspawn" || pHit.vars.classname == "player"){
				//Find a proper Target!
				float maxDist = 256.0f;
				float minDist = 64.0f;
				
				CBaseEntity@ pEntityClosest = null;
				float distClosest = maxDist*maxDist*3.0f;
				
				for( int i = 0; i < g_Engine.maxEntities; ++i ) {
					CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
					if( pEntity is null ) continue;
					if( pEntity.pev.classname == "beam" ) continue;
					if( pEntity.pev.classname == "worldspawn" ) continue;
					if( pEntity.pev.classname == "player" ) continue;
					Vector midPos = pEntity.pev.origin;
					if( midPos.x == 0 && midPos.y == 0 && midPos.z == 0 ) midPos = pEntity.Center();
					if( midPos.x == 0 && midPos.y == 0 && midPos.z == 0 ) continue;
					if( midPos.x > tr.vecEndPos.x + maxDist || midPos.x < tr.vecEndPos.x - maxDist) continue;
					if( midPos.y > tr.vecEndPos.y + maxDist || midPos.y < tr.vecEndPos.y - maxDist) continue;
					if( midPos.z > tr.vecEndPos.z + maxDist || midPos.z < tr.vecEndPos.z - maxDist) continue;
					
					if(
							midPos.x < vecSrc.x + minDist && midPos.x > vecSrc.x - minDist &&
							midPos.y < vecSrc.y + minDist && midPos.y > vecSrc.y - minDist &&
							midPos.z < vecSrc.z + minDist && midPos.z > vecSrc.z - minDist
					)continue;
					
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
				
				if(pEntityClosest is null){
					string aStr = "Mode 4 - Destroyer:\nNo Entity found!";
					
					vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
					
					CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam.PointsInit( vecSrc, tr.vecEndPos );
					m_pBeam.SetColor( 255, 0, 0 );
					m_pBeam.SetBrightness( 255 );
					m_pBeam.SetNoise( 0.0f );
					m_pBeam.SetWidth( 1 );
					m_pBeam.LiveForTime(0.001f);
					
					DrawHUD(aStr);
				}else{
					string aStr = "Mode 4 - Destroyer:\nClassname: \""+pEntityClosest.pev.classname+
							"\"\nTargetname: \""+pEntityClosest.pev.targetname+"\"";
					
					vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
					Vector midPos2 = pEntityClosest.pev.origin;
					if( midPos2.x == 0 && midPos2.y == 0 && midPos2.z == 0 ) midPos2 = pEntityClosest.Center();
					
					NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
						message.WriteByte( TE_SPRITE );
						message.WriteCoord( midPos2.x );	// pos
						message.WriteCoord( midPos2.y );
						message.WriteCoord( midPos2.z );
						message.WriteShort( m_iSprModel );	// model
						message.WriteByte( 1 );				// size * 10
						message.WriteByte( 128 );			// brightness
					message.End();
					
					CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
					m_pBeam.PointsInit( vecSrc, midPos2 );
					m_pBeam.SetColor( 255, 0, 0 );
					m_pBeam.SetBrightness( 255 );
					m_pBeam.SetNoise( 0.0f );
					m_pBeam.SetWidth( 1 );
					m_pBeam.LiveForTime(0.001f);
					
					DrawHUD(aStr);
						
					if(m_switch == 0){
						if(firemode == 1 || firemode == 2) {
							if(firemode == 1 && string(pEntityClosest.pev.classname).Find("monster_") == 0){
								pEntityClosest.TakeDamage(m_pPlayer.pev, m_pPlayer.pev, pEntityClosest.pev.health * 2.0f + 1.0f, DMG_ALWAYSGIB);
							}else{
								g_EntityFuncs.Remove( pEntityClosest );
							}
						}
						m_switch = 1;
					}
				}
			}else{
				string aStr = "Mode 4 - Destroyer:\nClassname: \""+pHit.vars.classname+
						"\"\nTargetname: \""+pHit.vars.targetname+"\"";
				
				vecSrc = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 8.0f;
				Vector midPos2 = pHit.vars.origin;
				if( midPos2.x == 0 && midPos2.y == 0 && midPos2.z == 0 ) midPos2 = g_EntityFuncs.Instance(pHit).Center();
				
				NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
					message.WriteByte( TE_SPRITE );
					message.WriteCoord( midPos2.x );	// pos
					message.WriteCoord( midPos2.y );
					message.WriteCoord( midPos2.z );
					message.WriteShort( m_iSprModel );	// model
					message.WriteByte( 1 );				// size * 10
					message.WriteByte( 128 );			// brightness
				message.End();
				
				CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
				m_pBeam.PointsInit( vecSrc, midPos2 );
				m_pBeam.SetColor( 255, 0, 0 );
				m_pBeam.SetBrightness( 255 );
				m_pBeam.SetNoise( 0.0f );
				m_pBeam.SetWidth( 1 );
				m_pBeam.LiveForTime(0.001f);
				
				DrawHUD(aStr);
					
				if(m_switch == 0){
					if(firemode == 1 || firemode == 2) {
						g_EntityFuncs.Remove( g_EntityFuncs.Instance(pHit) );
					}
					m_switch = 1;
				}
			}
		}
	}
	
	void chooseMode(int firemode){
		switch( m_mode ){
		case 1:	
			drawCoordinates(firemode);
			break;
		case 2:
			drawEntityData(firemode);
			break;
		case 3:
			drawEntityData2(firemode);
			break;
		case 4:
			drawDestroyer(firemode);
			break;
		}
	}
	
	void PrimaryAttack(){
		chooseMode(1);
		
		self.m_flNextPrimaryAttack = g_Engine.time;
		self.m_flNextSecondaryAttack = g_Engine.time;
		self.m_flNextTertiaryAttack = g_Engine.time;
		self.m_flTimeWeaponIdle = g_Engine.time;
	}
	
	void SecondaryAttack(){
		chooseMode(2);
		
		self.m_flNextPrimaryAttack = g_Engine.time;
		self.m_flNextSecondaryAttack = g_Engine.time;
		self.m_flNextTertiaryAttack = g_Engine.time;
		self.m_flTimeWeaponIdle = g_Engine.time;
	}
	
	void TertiaryAttack(){
	
		if(m_switch == 0){
			m_mode++;
			if(m_mode > 4) m_mode = 1;
			
			m_switch = 1;
		}
		
		chooseMode(3);
		
		self.m_flNextPrimaryAttack = g_Engine.time;
		self.m_flNextSecondaryAttack = g_Engine.time;
		self.m_flNextTertiaryAttack = g_Engine.time;
		self.m_flTimeWeaponIdle = g_Engine.time;
	}
	
	void WeaponIdle(){
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;
		
		chooseMode(0);
		
		Vector vecDir = m_pPlayer.GetAutoaimVector( 0.0f );
		if(m_switch == 2) m_pPlayer.pev.velocity = vecDir * 480.0f;
		if(m_switch == 3) m_pPlayer.pev.velocity = -vecDir * 480.0f;
		
		m_switch = 0;
		self.m_flNextPrimaryAttack = g_Engine.time;
		self.m_flNextSecondaryAttack = g_Engine.time;
		self.m_flNextTertiaryAttack = g_Engine.time;
		self.m_flTimeWeaponIdle = g_Engine.time;
	}
}

void RegisterWeaponDebug()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_debug", "weapon_debug" );
	g_ItemRegistry.RegisterWeapon( "weapon_debug", "cubemath" );
}
