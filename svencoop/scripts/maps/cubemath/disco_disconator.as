
enum DisconatorAnimation
{
	DISCONATOR_IDLE = 0,
	DISCONATOR_BOMBL,
	DISCONATOR_BOMBR,
	DISCONATOR_BOMBB,
	DISCONATOR_RAGE,
	DISCONATOR_DIE
};

float g_musicBeginTime;
int isBossRunning;

class disco_player {
	CBasePlayer@ m_pPlayer;
	
	array<Vector> oldPos;
	
	disco_player( CBasePlayer@ pPlayer ){
		@m_pPlayer = pPlayer;
		
		oldPos.resize( 32 );
		
		for(int i = 0; i < 32; ++i){
			oldPos[i] = pPlayer.pev.origin;
		}
	}
	
	void updatePos( CBasePlayer@ pPlayer ){
		if( pPlayer is null || !pPlayer.IsConnected()){
			@m_pPlayer = null;
		}else{
			for(int i = 31; i > 0; --i){
				oldPos[i] = oldPos[i-1];
			}
			oldPos[0] = pPlayer.pev.origin;
		}
	}
}
array<disco_player@> g_disco_player;

class disco_aim_cross {
	
	CBasePlayer@ pTargetPlayer;
	Vector targetPos;
	int playerIndex;
	
	void ShufflePlayer(){
		float sumHealth = 0.0f;
		
		CBasePlayer@ pPlayer = null;
		@pTargetPlayer = null;
		playerIndex = -1;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
			
			sumHealth += pPlayer.pev.health;
		}
		
		float randomHealthPick = Math.RandomFloat( 0.0f, sumHealth );
		
		sumHealth = 0.0f;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
			
			sumHealth += pPlayer.pev.health;
			if(randomHealthPick <= sumHealth){
				@pTargetPlayer = @pPlayer;
				playerIndex = iPlayer - 1;
				break;
			}
		}
	}
	
	void ThinkResizeArray(){
		g_disco_player.resize( g_Engine.maxClients );
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;
			
			disco_player data( pPlayer );
			@g_disco_player[ pPlayer.entindex() - 1 ] = @data;
		}
		
		ShufflePlayer();
		CalcPosition();
	}
	
	void CalcPosition(){
		if(g_disco_player.size() != uint(g_Engine.maxClients)){
			ThinkResizeArray();
		}else{
			CBasePlayer@ pPlayer = null;
			
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;
				
				if(g_disco_player[ pPlayer.entindex() - 1 ] is null || g_disco_player[ pPlayer.entindex() - 1 ].m_pPlayer is null){
					disco_player data( pPlayer );
					@g_disco_player[ pPlayer.entindex() - 1 ] = @data;
				}else{
					g_disco_player[ pPlayer.entindex() - 1 ].updatePos( pPlayer );
				}
			}
			
			if( pTargetPlayer is null || !pTargetPlayer.IsConnected() || !pTargetPlayer.IsAlive() ){
				targetPos.x = 0.0f;
				targetPos.y = 0.0f;
				
				ShufflePlayer();
			}else{
				disco_player@ pTargetPlayerData = @g_disco_player[ playerIndex ];
				
				Vector posA = pTargetPlayerData.oldPos[31];
				Vector posC = pTargetPlayerData.oldPos[0];
				Vector posAC = posC - posA;
				
				targetPos.x = posAC.x*0.5f + posC.x;
				targetPos.y = posAC.y*0.5f + posC.y;
			}
			
			g_Scheduler.SetTimeout( @this, "CalcPosition", 0.1f);
		}
	}
}
disco_aim_cross g_disco_aim_cross;

class disco_health_logic : ScriptBaseEntity {
	
	CBaseEntity@ gloVariables;
	CBaseEntity@ bossHealthBox;
	CBaseEntity@ messageEntity;
	CBaseEntity@ disconatorEntity;
	
	int laserLevel;
	int bossLevel;
	float mapEntTimer;

	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			
			if( pEntity !is null){
				if( pEntity.pev.targetname == "variables") {
					@gloVariables = @pEntity;
				}
				if( pEntity.pev.targetname == "boss_health") {
					@bossHealthBox = @pEntity;
				}
				if( pEntity.pev.classname == "disco_disconator") {
					@disconatorEntity = @pEntity;
				}
			}
		}
		
		dictionary keyvalues = {
			{"message", "Health: 100.0"},
			{"targetname", "show_health"},
			{"delay", "0"},
			{"x", "-1"},
			{"y", "0.1"},
			{"effect", "0"},
			{"color", "255 255 255"},
			{"color2", "240 110 0"},
			{"fadein", "0.0"},
			{"fadeout", "0.5"},
			{"holdtime", "1.5"},
			{"fxtime", "0.25"},
			{"channel", "1"},
			{"spawnflags", "3"}
		};
		
		@messageEntity = g_EntityFuncs.CreateEntity( "game_text", keyvalues );
		
		SetThink( ThinkFunction( this.Think01 ) );
		self.pev.nextthink = g_Engine.time + 0.25f;
		laserLevel = 0;
		isBossRunning = 0;
		bossLevel = 1;
	}
	
	void Think01(){
		int bossmode = gloVariables.GetCustomKeyvalues().GetKeyvalue("$i_bossmode").GetInteger();
		
		if(bossmode == 1){
			g_musicBeginTime = 0.0f;
			isBossRunning = 1;
			
			SetThink( ThinkFunction( this.Think02 ) );
			if(bossHealthBox !is null){
				bossHealthBox.pev.health = 100000.0f;
			}
		}
		
		self.pev.nextthink = g_Engine.time + 0.25f;
	}
	
	void Think02(){
		CustomKeyvalues@ keyValues1 = gloVariables.GetCustomKeyvalues();
		float maxHealth = keyValues1.GetKeyvalue("$f_maxhealth").GetFloat();
		float health = keyValues1.GetKeyvalue("$f_health").GetFloat();
		float healthPercentage = keyValues1.GetKeyvalue("$f_health_percentage").GetFloat();
		
		if(bossHealthBox !is null){
			health -= 100000.0f - bossHealthBox.pev.health;
			bossHealthBox.pev.health = 100000.0f;
		}
		g_EntityFuncs.DispatchKeyValue(gloVariables.edict(), "$f_health", health);
		
		healthPercentage = health / maxHealth * 100.0f;
		if(healthPercentage > 0.0f && healthPercentage < 0.1f) healthPercentage = 0.1f;
		if(healthPercentage > 100.0f) healthPercentage = 100.0f;
		if(healthPercentage < 0.0f) healthPercentage = 0.0f;
		
		g_EntityFuncs.DispatchKeyValue(gloVariables.edict(), "$f_health_percentage", healthPercentage);
		
		if(laserLevel == 0 && healthPercentage <= 50.0f){
			g_EntityFuncs.FireTargets("laser_blue_1_harmless", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_blue_1_harmless", null, null, USE_OFF, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_blue_1", null, null, USE_ON, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_orange_1_harmless", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_orange_1_harmless", null, null, USE_OFF, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_orange_1", null, null, USE_ON, 0.0f, 3.0f);
			laserLevel = 1;
		}
		
		if(laserLevel == 1 && healthPercentage <= 25.0f){
			g_EntityFuncs.FireTargets("laser_blue_2_harmless", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_blue_2_harmless", null, null, USE_OFF, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_blue_2", null, null, USE_ON, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_orange_2_harmless", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_orange_2_harmless", null, null, USE_OFF, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("laser_orange_2", null, null, USE_ON, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("final_alert", null, null, USE_ON, 0.0f, 0.0f);
			laserLevel = 2;
		}
		
		self.pev.nextthink = g_Engine.time + 0.25f;
		
		if(healthPercentage <= 0.0f && bossLevel == 4) {
			CBaseEntity@ pEnt = g_EntityFuncs.Create("disco_disconator_dying", disconatorEntity.pev.origin, disconatorEntity.pev.angles, false);
			g_EntityFuncs.Remove( disconatorEntity );
			g_EntityFuncs.Remove( bossHealthBox );
			@disconatorEntity = @pEnt;
			bossLevel = 5;
			g_EntityFuncs.FireTargets("laser_blue_1", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_orange_1", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_blue_2", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("laser_orange_2", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("light_safe", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("light_dangerous", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("final_alert", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music4", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("exploding_boss_1", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("exploding_boss_6", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("exploding_boss_4", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("exploding_boss_9", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("exploding_boss_1", null, null, USE_ON, 0.0f, 0.7f);
			g_EntityFuncs.FireTargets("exploding_boss_2", null, null, USE_ON, 0.0f, 1.1f);
			g_EntityFuncs.FireTargets("exploding_boss_3", null, null, USE_ON, 0.0f, 1.3f);
			g_EntityFuncs.FireTargets("exploding_boss_4", null, null, USE_ON, 0.0f, 1.4f);
			g_EntityFuncs.FireTargets("exploding_boss_5", null, null, USE_ON, 0.0f, 1.5f);
			g_EntityFuncs.FireTargets("exploding_boss_6", null, null, USE_ON, 0.0f, 2.0f);
			g_EntityFuncs.FireTargets("exploding_boss_7", null, null, USE_ON, 0.0f, 2.2f);
			g_EntityFuncs.FireTargets("exploding_boss_8", null, null, USE_ON, 0.0f, 2.4f);
			g_EntityFuncs.FireTargets("exploding_boss_9", null, null, USE_ON, 0.0f, 2.5f);
			g_EntityFuncs.FireTargets("exploding_boss_1", null, null, USE_ON, 0.0f, 2.8f);
			g_EntityFuncs.FireTargets("exploding_boss_2", null, null, USE_ON, 0.0f, 2.9f);
			g_EntityFuncs.FireTargets("exploding_boss_3", null, null, USE_ON, 0.0f, 3.0f);
			g_EntityFuncs.FireTargets("exploding_boss_4", null, null, USE_ON, 0.0f, 3.3f);
			g_EntityFuncs.FireTargets("exploding_boss_5", null, null, USE_ON, 0.0f, 3.5f);
			g_EntityFuncs.FireTargets("exploding_boss_6", null, null, USE_ON, 0.0f, 3.6f);
			g_EntityFuncs.FireTargets("exploding_boss_7", null, null, USE_ON, 0.0f, 4.0f);
			g_EntityFuncs.FireTargets("exploding_boss_8", null, null, USE_ON, 0.0f, 4.2f);
			g_EntityFuncs.FireTargets("exploding_boss_9", null, null, USE_ON, 0.0f, 4.3f);
			g_EntityFuncs.FireTargets("exploding_boss_10", null, null, USE_ON, 0.0f, 5.0f);
			g_EntityFuncs.FireTargets("exploding_boss_1", null, null, USE_ON, 0.0f, 5.0f);
			g_EntityFuncs.FireTargets("exploding_boss_6", null, null, USE_ON, 0.0f, 5.0f);
			g_EntityFuncs.FireTargets("exploding_boss_4", null, null, USE_ON, 0.0f, 5.0f);
			g_EntityFuncs.FireTargets("exploding_boss_9", null, null, USE_ON, 0.0f, 5.0f);
			g_EntityFuncs.FireTargets("boss_metal", null, null, USE_ON, 0.0f, 5.0f);
			
			mapEntTimer = g_Engine.time + 15.0f;
			self.pev.nextthink = g_Engine.time + 10.0f;
			SetThink( ThinkFunction( this.Think03 ) );
		}else if(healthPercentage <= 25.0f && bossLevel == 3) {
			CBaseEntity@ pEnt = g_EntityFuncs.Create("disco_disconator4", disconatorEntity.pev.origin, disconatorEntity.pev.angles, false);
			g_EntityFuncs.Remove( disconatorEntity );
			@disconatorEntity = @pEnt;
			bossLevel = 4;
			g_EntityFuncs.FireTargets("light_dangerous", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("light_normal", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("boss_glass", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music3", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music4", null, null, USE_ON, 0.0f, 1.0f);
			g_musicBeginTime = g_Engine.time + 1.093f;
		}else if(healthPercentage <= 50.0f && bossLevel == 2) {
			CBaseEntity@ pEnt = g_EntityFuncs.Create("disco_disconator3", disconatorEntity.pev.origin, disconatorEntity.pev.angles, false);
			g_EntityFuncs.Remove( disconatorEntity );
			@disconatorEntity = @pEnt;
			bossLevel = 3;
			g_EntityFuncs.FireTargets("disco_beams", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("phase_2_breakable", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music2", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music3", null, null, USE_ON, 0.0f, 1.0f);
			g_musicBeginTime = g_Engine.time + 1.450f;
		}else if(healthPercentage <= 75.0f && bossLevel == 1) {
			CBaseEntity@ pEnt = g_EntityFuncs.Create("disco_disconator2", disconatorEntity.pev.origin, disconatorEntity.pev.angles, false);
			g_EntityFuncs.Remove( disconatorEntity );
			@disconatorEntity = @pEnt;
			bossLevel = 2;
			g_EntityFuncs.FireTargets("disco_beams", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("phase_1_breakable", null, null, USE_ON, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music1", null, null, USE_OFF, 0.0f, 0.0f);
			g_EntityFuncs.FireTargets("music2", null, null, USE_ON, 0.0f, 1.0f);
		}
		
		string mesStr = "Health: "+floor(healthPercentage)+"."+floor(healthPercentage*10.0f)%10.0f;
		g_EntityFuncs.DispatchKeyValue(messageEntity.edict(), "message", mesStr);
		
		g_EntityFuncs.FireTargets("show_health", null, null, USE_ON);
	}
	
	void Think03(){
		bool arePeopleAlife = false;
		
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
				continue;
			
			arePeopleAlife = true;
			break;
		}
		
		if(arePeopleAlife){
			g_EntityFuncs.DispatchKeyValue(messageEntity.edict(), "message", "Thank you for playing my map. Map by CubeMath.");
			if(mapEntTimer < g_Engine.time){
				SetThink( ThinkFunction( this.Think04 ) );
			}
		}else{
			g_EntityFuncs.DispatchKeyValue(messageEntity.edict(), "message", "You beat the Boss and yet failed to Survive. Game Over.");
		}
		
		g_EntityFuncs.FireTargets("show_health", null, null, USE_ON);
		
		self.pev.nextthink = g_Engine.time + 0.25f;
	}
	
	void Think04(){
		g_EntityFuncs.FireTargets("end_of_the_line", null, null, USE_ON, 0.0f, 0.0f);
	}
}

class disco_fireball : ScriptBaseEntity {
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_NOT;
		self.pev.framerate      = 1.0f;
		self.pev.rendermode     = 5;
		self.pev.renderamt      = 255.0f;
		self.pev.scale 		    = 0.25f;
		self.pev.gravity 	    = 0.75f;
		
		g_EntityFuncs.SetModel( self, "sprites/particlesprite.spr" );
		
		
		//Unlikely that the fireball needs >10s to touch floor.
		self.pev.nextthink = g_Engine.time + 0.125f;
		SetThink( ThinkFunction( SolidThink ) );
		SetTouch( TouchFunction( DetoTouch ) );
	}
	
	void SolidThink(){
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.solid = SOLID_BBOX;
		g_EntityFuncs.SetSize( self.pev, Vector( -8,-8,0 ), Vector( 8,8,8 ) );
		
		self.pev.nextthink = g_Engine.time + 10.0f;
		SetThink( ThinkFunction( DetoThink ) );
	}
	
	void DetoThink(){
		if(self !is null && g_EntityFuncs.IsValidEntity( self.edict() )){
			g_EntityFuncs.CreateExplosion(self.pev.origin, Vector(0,0,0), null, 49, true);
			g_EntityFuncs.Remove( self );
		}
	}
	
	void DetoTouch( CBaseEntity@ pOther ){
		DetoThink();
	}
}

class disco_disconator : ScriptBaseAnimating {
	CBaseEntity@ gloVariables2;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
		
		g_Game.PrecacheModel( "models/cubemath/arrow2d.mdl" );
		g_Game.PrecacheModel( "models/cubemath/discoboss/disconator.mdl" );
		g_Game.PrecacheModel( "models/cubemath/discoboss/disconatorbroken.mdl" );
		g_Game.PrecacheModel( "sprites/particlesprite.spr" );
	}
	
	// if youre gonna use this in your script, make sure you dont try to access invalid animations -zode
	void SetAnim(int animIndex) {
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel(self, "models/cubemath/discoboss/disconator.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		self.pev.targetname = "disconator";
		self.pev.framerate = 1.0f;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		SetAnim(DISCONATOR_IDLE);
		
		SetThink( ThinkFunction( this.ThinkPrepareBattle ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void ThinkPrepareBattle(){
		g_EntityFuncs.Create("disco_health_logic", self.pev.origin, Vector(0, 0, 0), false);
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			
			if( pEntity !is null){
				if( pEntity.pev.targetname == "variables") {
					@gloVariables2 = @pEntity;
					break;
				}
			}
		}
		
		SetThink( ThinkFunction( this.ThinkWait ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void ThinkWait(){
		int bossmode = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$i_bossmode").GetInteger();
		
		if(bossmode == 1){
			g_disco_aim_cross.ThinkResizeArray();
			SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
			
			g_EntityFuncs.FireTargets("music1", null, null, USE_ON, 0.0f, 0.0f);
		}
		
		self.pev.nextthink = g_Engine.time + 0.25f;
	}
	
	void ThinkRotateChooseDirection(){
		
		SetAnim(DISCONATOR_IDLE);
		
		float pHealth = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$f_health_percentage").GetFloat();
		
		if(pHealth > 90.0f){
			if(Math.RandomLong( 0, 1 ) == 1){
				self.pev.avelocity.y = -30.0f;
				SetThink( ThinkFunction( this.ThinkBreak1R ) );
			}else{
				self.pev.avelocity.y =  30.0f;
				SetThink( ThinkFunction( this.ThinkBreak1L ) );
			}
			self.pev.nextthink = g_Engine.time + Math.RandomFloat( 0.0f, 3.0f );
		}else{
			g_disco_aim_cross.ShufflePlayer();
			
			float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
			float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
			if(pathLength == 0.0f){
				ThinkThrowBombRight1();
			}else{
				float targetRotation = 0.0f;
				if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
				else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
				
				currentRotation -= targetRotation;
				while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
				while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
				
				if(currentRotation < 3.14159265358979323846f){
					self.pev.avelocity.y = -120.0f + pHealth;
					SetThink( ThinkFunction( this.ThinkRotating ) );
				}else{
					self.pev.avelocity.y =  120.0f - pHealth;
					SetThink( ThinkFunction( this.ThinkRotating ) );
				}
			}
			self.pev.nextthink = g_Engine.time + 0.0f;
		}
	}
	
	void ThinkRotating(){
		float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
		float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
		if(pathLength == 0.0f){
			self.pev.avelocity.y = 0.0f;
			
			SetThink( ThinkFunction( this.ThinkBreak1R ) );
		}else{
			float targetRotation = 0.0f;
			if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
			else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
			
			currentRotation -= targetRotation;
			while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
			while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
			
			if(currentRotation < 3.14159265358979323846f){
				if(self.pev.avelocity.y > 0.0f){
					
					SetThink( ThinkFunction( this.ThinkBreak1L ) );
				}
			}else{
				if(self.pev.avelocity.y < 0.0f){
					
					SetThink( ThinkFunction( this.ThinkBreak1R ) );
				}
			}
		}
		self.pev.nextthink = g_Engine.time + 0.0f;
	}
	
	void ThinkBreak1L(){
		self.pev.avelocity.y = 0.0f;
		SetThink( ThinkFunction( this.ThinkThrowBombLeft1 ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void ThinkBreak1R(){
		self.pev.avelocity.y = 0.0f;
		SetThink( ThinkFunction( this.ThinkThrowBombRight1 ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void ThinkThrowBombRight1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBR);
		
		SetThink( ThinkFunction( this.ThinkThrowBombRight2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombRight2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = -cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = 0.0f;
		float pHealth = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$f_health_percentage").GetFloat();
		if(pHealth > 90.0f){
			power = Math.RandomFloat( 0.0f, 1.0f );
		}else{
			power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
			if(power < 0.0f) power = 0.0f;
			if(power > 1.0f) power = 1.0f;
		}
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
	void ThinkThrowBombLeft1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBL);
		
		SetThink( ThinkFunction( this.ThinkThrowBombLeft2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombLeft2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = -sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = 0.0f;
		float pHealth = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$f_health_percentage").GetFloat();
		if(pHealth > 90.0f){
			power = Math.RandomFloat( 0.0f, 1.0f );
		}else{
			power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
			if(power < 0.0f) power = 0.0f;
			if(power > 1.0f) power = 1.0f;
		}
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
}

class disco_disconator2 : ScriptBaseAnimating {
	CBaseEntity@ gloVariables2;
	CBaseEntity@ aimCross;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	// if youre gonna use this in your script, make sure you dont try to access invalid animations -zode
	void SetAnim(int animIndex) {
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel(self, "models/cubemath/discoboss/disconator.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		self.pev.targetname = "disconator";
		self.pev.framerate = 1.0f;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		SetAnim(DISCONATOR_DIE);
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			
			if( pEntity !is null){
				if( pEntity.pev.targetname == "variables") {
					@gloVariables2 = @pEntity;
				}
				if( pEntity.pev.targetname == "phase_2_breakable") {
					pEntity.pev.rendermode = 0;
				}
				if( pEntity.pev.classname == "disco_aim_cross") {
					@aimCross = @pEntity;
				}
			}
		}
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 1.75f;
	}
	
	void ThinkRotateChooseDirection(){
		g_disco_aim_cross.ShufflePlayer();
		SetAnim(DISCONATOR_IDLE);
		
		float pHealth = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$f_health_percentage").GetFloat();
		
		float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
		float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
		if(pathLength == 0.0f){
			ThinkThrowBombRight1();
		}else{
			float targetRotation = 0.0f;
			if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
			else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
			
			currentRotation -= targetRotation;
			while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
			while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
			
			if(currentRotation < 3.14159265358979323846f){
				self.pev.avelocity.y = -120.0f + pHealth;
				SetThink( ThinkFunction( this.ThinkRotating ) );
			}else{
				self.pev.avelocity.y =  120.0f - pHealth;
				SetThink( ThinkFunction( this.ThinkRotating ) );
			}
		}
		self.pev.nextthink = g_Engine.time + 0.0f;
	}
	
	void ThinkRotating(){
		float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
		float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
		if(pathLength == 0.0f){
			self.pev.avelocity.y = 0.0f;
			
			SetThink( ThinkFunction( this.ThinkBreak2R ) );
		}else{
			float targetRotation = 0.0f;
			if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
			else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
			
			currentRotation -= targetRotation;
			while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
			while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
			
			if(currentRotation < 3.14159265358979323846f){
				if(self.pev.avelocity.y > 0.0f){
					
					SetThink( ThinkFunction( this.ThinkBreak2L ) );
				}
			}else{
				if(self.pev.avelocity.y < 0.0f){
					
					SetThink( ThinkFunction( this.ThinkBreak2R ) );
				}
			}
		}
		self.pev.nextthink = g_Engine.time + 0.0f;
	}
	
	void ThinkBreak2L(){
		self.pev.avelocity.y = 0.0f;
		SetThink( ThinkFunction( this.ThinkThrowBombLeft1 ) );
		self.pev.nextthink = g_Engine.time + 0.5f;
	}
	
	void ThinkBreak2R(){
		self.pev.avelocity.y = 0.0f;
		SetThink( ThinkFunction( this.ThinkThrowBombRight1 ) );
		self.pev.nextthink = g_Engine.time + 0.5f;
	}
	
	void ThinkThrowBombRight1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBR);
		
		SetThink( ThinkFunction( this.ThinkThrowBombRight2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombRight2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = -cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
		if(power < 0.0f) power = 0.0f;
		if(power > 1.0f) power = 1.0f;
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
	void ThinkThrowBombLeft1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBL);
		
		SetThink( ThinkFunction( this.ThinkThrowBombLeft2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombLeft2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = -sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
		if(power < 0.0f) power = 0.0f;
		if(power > 1.0f) power = 1.0f;
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
}

class disco_disconator3 : ScriptBaseAnimating {
	CBaseEntity@ gloVariables2;
	CBaseEntity@ aimCross;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	// if youre gonna use this in your script, make sure you dont try to access invalid animations -zode
	void SetAnim(int animIndex) {
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel(self, "models/cubemath/discoboss/disconator.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		self.pev.targetname = "disconator";
		self.pev.framerate = 1.0f;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		SetAnim(DISCONATOR_DIE);
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			
			if( pEntity !is null){
				if( pEntity.pev.targetname == "variables") {
					@gloVariables2 = @pEntity;
				}
				if( pEntity.pev.classname == "disco_aim_cross") {
					@aimCross = @pEntity;
				}
			}
		}
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 1.75f;
	}
	
	void ThinkRotateChooseDirection(){
		g_disco_aim_cross.ShufflePlayer();
		SetAnim(DISCONATOR_IDLE);
		
		float pHealth = gloVariables2.GetCustomKeyvalues().GetKeyvalue("$f_health_percentage").GetFloat();
		
		float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
		float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
		if(pathLength == 0.0f){
			ThinkThrowBombRight1();
		}else{
			float targetRotation = 0.0f;
			if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
			else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
			
			currentRotation -= targetRotation;
			while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
			while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
			
			if(currentRotation < 3.14159265358979323846f){
				self.pev.avelocity.y = -120.0f + pHealth;
				SetThink( ThinkFunction( this.ThinkRotating ) );
			}else{
				self.pev.avelocity.y =  120.0f - pHealth;
				SetThink( ThinkFunction( this.ThinkRotating ) );
			}
		}
		self.pev.nextthink = g_Engine.time + 0.0f;
	}
	
	void ThinkRotating(){
		float currentRotation = self.pev.angles.y / 180.0f * 3.14159265358979323846f;
		float pathLength = sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y);
		if(pathLength == 0.0f){
			self.pev.avelocity.y = 0.0f;
			
			SetThink( ThinkFunction( this.ThinkThrowBombRight1 ) );
		}else{
			float targetRotation = 0.0f;
			if(g_disco_aim_cross.targetPos.y < 0.0f) targetRotation = acos(-g_disco_aim_cross.targetPos.x/pathLength) - 3.14159265358979323846f;
			else targetRotation = acos(g_disco_aim_cross.targetPos.x/pathLength);
			
			currentRotation -= targetRotation;
			while(currentRotation < 0.0f) currentRotation += 3.14159265358979323846f * 2.0f;
			while(currentRotation > 3.14159265358979323846f * 2.0f) currentRotation -= 3.14159265358979323846f * 2.0f;
			
			if(currentRotation < 3.14159265358979323846f){
				if(self.pev.avelocity.y > 0.0f){
					
					SetThink( ThinkFunction( this.ThinkThrowBombLeft1 ) );
				}
			}else{
				if(self.pev.avelocity.y < 0.0f){
					
					SetThink( ThinkFunction( this.ThinkThrowBombRight1 ) );
				}
			}
		}
		self.pev.nextthink = g_Engine.time + 0.0f;
	}
	
	void ThinkThrowBombRight1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBR);
		
		SetThink( ThinkFunction( this.ThinkThrowBombRight2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombRight2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = -cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
		if(power < 0.0f) power = 0.0f;
		if(power > 1.0f) power = 1.0f;
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
	void ThinkThrowBombLeft1(){
		self.pev.avelocity.y = 0.0f;
		SetAnim(DISCONATOR_BOMBL);
		
		SetThink( ThinkFunction( this.ThinkThrowBombLeft2 ) );
		self.pev.nextthink = g_Engine.time + 0.13f;
	}
	
	void ThinkThrowBombLeft2(){
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = -sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = (sqrt(g_disco_aim_cross.targetPos.x*g_disco_aim_cross.targetPos.x+g_disco_aim_cross.targetPos.y*g_disco_aim_cross.targetPos.y) -100.0f) / 900.0f;
		if(power < 0.0f) power = 0.0f;
		if(power > 1.0f) power = 1.0f;
		
		pEntity.pev.velocity.x = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkRotateChooseDirection ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
}

class disco_disconator4 : ScriptBaseAnimating {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	// if youre gonna use this in your script, make sure you dont try to access invalid animations -zode
	void SetAnim(int animIndex) {
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel(self, "models/cubemath/discoboss/disconatorbroken.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		self.pev.targetname = "disconator";
		self.pev.framerate = 1.0f;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		SetAnim(DISCONATOR_DIE);
		
		SetThink( ThinkFunction( this.ThinkPreThrowBomb ) );
		self.pev.nextthink = g_Engine.time + 2.5f;
	}
	
	void ThinkPreThrowBomb(){
		SetAnim(DISCONATOR_RAGE);
		ThinkThrowBombLeft2();
	}
	
	void ThinkThrowBombRight2(){
		self.pev.frame = 8;
		self.pev.avelocity.y = Math.RandomFloat( 90.0f, 120.0f );
		
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = -cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = Math.RandomFloat( 0.0f, 1.0f );
		
		pEntity.pev.velocity.x = sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = -cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkThrowBombLeft2 ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
	
	void ThinkThrowBombLeft2(){
		self.pev.frame = 0;
		self.pev.avelocity.y = Math.RandomFloat( 90.0f, 120.0f );
		
		Vector fireballPos = self.pev.origin;
		fireballPos.z += 80.0f;
		fireballPos.x = -sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		fireballPos.y = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * 16.0f;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Create("disco_fireball", fireballPos, Vector(0, 0, 0), false);
		
		float power = Math.RandomFloat( 0.0f, 1.0f );
		
		pEntity.pev.velocity.x = -sin(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.y = cos(self.pev.angles.y/180.0f*3.14159265358979323846f) * (60.0f + 490.0f * power);
		pEntity.pev.velocity.z = 140.0f + 140.0f * power;
		
		SetThink( ThinkFunction( this.ThinkThrowBombRight2 ) );
		self.pev.nextthink = g_Engine.time + 0.53f;
	}
}

class disco_disconator_dying : ScriptBaseAnimating {
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel(self, "models/cubemath/discoboss/disconatorbroken.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		self.pev.targetname = "disconator";
		self.pev.framerate = 1.0f;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		self.pev.sequence = DISCONATOR_DIE;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
		
		self.pev.nextthink = g_Engine.time + 5.0f;
		SetThink( ThinkFunction( DieThink ) );
	}
	
	void DieThink(){
		g_EntityFuncs.Remove( self );
	}
}

void RegisterDiscoDisconatorCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_health_logic", "disco_health_logic" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_disconator", "disco_disconator" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_disconator2", "disco_disconator2" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_disconator3", "disco_disconator3" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_disconator4", "disco_disconator4" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_disconator_dying", "disco_disconator_dying" );
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_fireball", "disco_fireball" );
}
