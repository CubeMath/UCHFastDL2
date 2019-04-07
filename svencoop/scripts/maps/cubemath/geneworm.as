
enum GenewormAnimation
{
	GENEWORM_MELEE1 = 0,
	GENEWORM_MELEE2,
	GENEWORM_MELEE3,
	GENEWORM_DATTACK1,
	GENEWORM_DATTACK2,
	GENEWORM_DATTACK3,
	GENEWORM_EYEPAIN1,
	GENEWORM_EYEPAIN2,
	GENEWORM_BIGPAIN1,
	GENEWORM_BIGPAIN2,
	GENEWORM_BIGPAIN3,
	GENEWORM_BIGPAIN4,
	GENEWORM_MAD,
	GENEWORM_SCREAM1,
	GENEWORM_SCREAM2,
	GENEWORM_IDLE,
	GENEWORM_IDLEPAIN1,
	GENEWORM_IDLEPAIN2,
	GENEWORM_IDLEPAIN3,
	GENEWORM_DEATH,
	GENEWORM_ENTRY
};

Vector g_posGeneEyeL;
Vector g_posGeneEyeR;
Vector g_posGeneHeart;
int g_openHeart;
int g_EyeStatusR;
int g_EyeStatusL;
int g_Phase;
float g_animTime;
float g_moveWall;

class monster_geneworm : ScriptBaseMonsterEntity {
	
	private float time1;
	private float time2;
	private Vector aimPos;
	private int aimPlyIdx;
	private float idleMaxTime1;
	private float idleMaxTime2;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}

	// if youre gonna use this in your script, make sure you dont try to access invalid animations -zode
	void SetAnim(int animIndex) {
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
		self.InitBoneControllers();
		
		switch(animIndex){
		case GENEWORM_MELEE1:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_attack_mounted_gun.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_MELEE2:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_attack_mounted_rocket.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_MELEE3:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_big_attack_forward.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_DATTACK1:
		case GENEWORM_DATTACK2:
		case GENEWORM_DATTACK3:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_beam_attack.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_EYEPAIN1:
		case GENEWORM_EYEPAIN2:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_shot_in_eye.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_BIGPAIN1:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_final_pain1.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_BIGPAIN2:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_final_pain2.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_BIGPAIN3:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_final_pain3.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_BIGPAIN4:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_final_pain4.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_DEATH:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_death.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		case GENEWORM_ENTRY:
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "geneworm/geneworm_entry.wav", 1.0f, ATTN_NONE, 0, 100 );
			break;
		}
	}
	
	void Precache() {
		BaseClass.Precache();
		g_Game.PrecacheModel( "models/geneworm.mdl" );
		g_Game.PrecacheModel( "models/strooper.mdl" );
		g_Game.PrecacheModel( "models/strooper_gibs.mdl" );
		g_Game.PrecacheModel( "models/voltigore.mdl" );
		g_Game.PrecacheModel( "models/vgibs.mdl" );
		g_Game.PrecacheModel( "sprites/ballsmoke.spr" );
		g_Game.PrecacheModel( "sprites/tele1.spr" );
		g_Game.PrecacheModel( "sprites/boss_glow.spr" );
		g_Game.PrecacheModel( "sprites/muzzle_shock.spr" );
		g_Game.PrecacheModel( "sprites/blueflare2.spr" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_attack_mounted_gun.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_attack_mounted_rocket.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_beam_attack.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_big_attack_forward.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_death.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_entry.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_final_pain1.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_final_pain2.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_final_pain3.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_final_pain4.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_idle1.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_idle2.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_idle3.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_idle4.wav" );
		g_SoundSystem.PrecacheSound( "geneworm/geneworm_shot_in_eye.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/blis.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/dit.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/dup.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/ga.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/hyu.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/ka.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/kiml.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/kss.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/ku.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/kur.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/kyur.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/mub.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/puh.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/pur.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/ras.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/thirv.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/wirt.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_fire.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_attack.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_die1.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_die2.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_die3.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_die4.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_pain1.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_pain2.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_pain3.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_pain4.wav" );
		g_SoundSystem.PrecacheSound( "shocktrooper/shock_trooper_pain5.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_alert1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_alert2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_alert3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_attack_melee1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_attack_melee2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_attack_shock.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_communicate1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_communicate2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_communicate3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_die1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_die2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_die3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_eat.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_footstep1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_footstep2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_footstep3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_idle1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_idle2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_idle3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_pain1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_pain2.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_pain3.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_pain4.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_run_grunt1.wav" );
		g_SoundSystem.PrecacheSound( "voltigore/voltigore_run_grunt2.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_miss1.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_miss2.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike1.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike2.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike3.wav" );
		g_SoundSystem.PrecacheSound( "debris/beamstart1.wav" );
		g_SoundSystem.PrecacheSound( "debris/beamstart2.wav" );
		g_SoundSystem.PrecacheSound( "debris/beamstart7.wav" );
		g_SoundSystem.PrecacheSound( "debris/zap4.wav" );
		g_SoundSystem.PrecacheSound( "debris/zap5.wav" );
		g_SoundSystem.PrecacheSound( "debris/zap6.wav" );
		g_SoundSystem.PrecacheSound( "debris/zap7.wav" );
	}
	
	void calcHitboxes(float animFps){
		self.pev.frame = int((g_Engine.time - time1)*animFps);
		self.pev.frame = int((g_Engine.time - time1)*animFps);
		Vector vecBuf;
		self.GetAttachment(3, g_posGeneEyeL, vecBuf);
		self.GetAttachment(2, g_posGeneEyeR, vecBuf);
		self.GetAttachment(1, g_posGeneHeart, vecBuf);
		self.pev.frame = 0;
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/geneworm.mdl" );
		// g_EntityFuncs.SetSize( self.pev, Vector( -320, -320, 0), Vector(320, 320, 640));
		
		self.pev.movetype 		= MOVETYPE_FLY;
		self.pev.solid 			= SOLID_NOT;
		self.pev.effects		= 0;
		self.pev.rendermode		= 2;
		self.pev.renderamt		= 0;
		self.pev.targetname     = "anthony";
		self.pev.framerate      = 1.0f;
		self.pev.skin			= 0;
		
		aimPos = Vector(0, 0, 0);
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		SetAnim(GENEWORM_IDLE);
		g_posGeneEyeL = Vector(0, 0, 4096);
		g_posGeneEyeR = Vector(0, 0, 4096);
		g_posGeneHeart = Vector(0, 0, 4096);
		g_openHeart = 0;
		g_EyeStatusR = -1;
		g_EyeStatusL = -1;
		g_Phase = 0;
		g_animTime = -100.0;
		g_moveWall = 0.0;
		idleMaxTime1 = 0.0f;
		idleMaxTime2 = 0.0f;
		g_EntityFuncs.Create("geneworm_eyel1", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_eyel2", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_eyer1", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_eyer2", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart1", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart2", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart3", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart4", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart5", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart6", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_heart7", self.pev.origin, Vector(0, 0, 0), false);
		g_EntityFuncs.Create("geneworm_wall", Vector(0, 0, 0), Vector(0, 0, 0), false);
		g_EntityFuncs.Create("shockie_maker", self.pev.origin, Vector(0, 0, 0), false);
		
		
		// SetTouch( TouchFunction( this.BossTouch ) );
		self.m_FormattedName = "Gene Worm Boss";
		
		// self.MonsterInit();
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		SetAnim(GENEWORM_ENTRY);
		
		time1 = g_Engine.time;
		
		SetThink( ThinkFunction( this.ThinkFadeIn ) );
        self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkFadeIn(){
		calcHitboxes(18.39f);
		int renAmt = int((g_Engine.time - time1)/8.0f * 255.0f);
		if(renAmt > 255) renAmt = 255;
		if(renAmt < 0) renAmt = 0;
		self.pev.renderamt = renAmt;
		
		g_moveWall = -2176.0f*(g_Engine.time - time1)/13.84f;
		if(g_moveWall < -1088.0f) g_moveWall = -1088.0f;
		
		if(g_Engine.time - time1 > 13.84f){
			g_moveWall = -1088.0f;
			gotoIdle();
			g_EyeStatusR = 0;
			g_EyeStatusL = 0;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	//Left
	void ThinkEyepain1(){
		calcHitboxes(117.51f);
		if(g_Engine.time - time1 > 2.18f){
			if(g_EyeStatusR == -1) g_EyeStatusR = 0;
			if(g_EyeStatusL == -1) g_EyeStatusL = 0;
			SetAnim(GENEWORM_MAD);
			g_EntityFuncs.FireTargets("GeneWormWallHit", null, null, USE_TOGGLE, 0.0f, 1.0f);
			SetThink( ThinkFunction( this.ThinkMad ) );
			time1 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	//Right
	void ThinkEyepain2(){
		calcHitboxes(117.51f);
		if(g_Engine.time - time1 > 2.18f){
			if(g_EyeStatusR == -1) g_EyeStatusR = 0;
			if(g_EyeStatusL == -1) g_EyeStatusL = 0;
			SetAnim(GENEWORM_MAD);
			g_EntityFuncs.FireTargets("GeneWormWallHit", null, null, USE_TOGGLE, 0.0f, 1.0f);
			SetThink( ThinkFunction( this.ThinkMad ) );
			time1 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	int findPlayerToMelee(){
		int countR = 0;
		int countL = 0;
		int countM = 0;
		
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
			
			Vector ori = pPlayer.pev.origin;
			
			if(ori.x >= -368.0 && ori.x <= 94.0 && ori.y >= -924.0 && ori.y <= -624.0) countR++;
			if(ori.x >= 384.0 && ori.x <= 672.0 && ori.y >= -940.0 && ori.y <= -624.0) countL++;
			if(ori.x >= 62.0 && ori.x <= 290.0 && ori.y >= -848.0 && ori.y <= -624.0) countM++;
		}
		
		if(countR + countL + countM == 0) return -1;
		if(countM > 0) return GENEWORM_MELEE3;
		if(countR > countL) return GENEWORM_MELEE2;
		return GENEWORM_MELEE1;
	}
	
	void startAttack(int useAcid){
		if(g_EyeStatusR < 2) g_EyeStatusR = -1;
		if(g_EyeStatusL < 2) g_EyeStatusL = -1;
		
		if(useAcid == 0){
			switch(findPlayerToMelee()){
			case GENEWORM_MELEE1:
				SetAnim(GENEWORM_MELEE1);
				g_EntityFuncs.FireTargets("GeneWormLeftSlash", null, null, USE_ON, 0.0f, 1.1f);
				g_EntityFuncs.FireTargets("GeneWormLeftSlash", null, null, USE_OFF, 0.0f, 1.4f);
				SetThink( ThinkFunction( this.ThinkMelee1 ) );
				break;
			case GENEWORM_MELEE2:
				SetAnim(GENEWORM_MELEE2);
				g_EntityFuncs.FireTargets("GeneWormRightSlash", null, null, USE_ON, 0.0f, 1.5f);
				g_EntityFuncs.FireTargets("GeneWormRightSlash", null, null, USE_OFF, 0.0f, 1.8f);
				SetThink( ThinkFunction( this.ThinkMelee2 ) );
				break;
			case GENEWORM_MELEE3:
				SetAnim(GENEWORM_MELEE3);
				g_EntityFuncs.FireTargets("GeneWormCenterSlash", null, null, USE_ON, 0.0f, 1.2f);
				g_EntityFuncs.FireTargets("GeneWormCenterSlash", null, null, USE_OFF, 0.0f, 1.5f);
				SetThink( ThinkFunction( this.ThinkMelee3 ) );
				break;
			default:
				if(g_Phase == 0){
					gotoIdle();
				}else{
					startAttack(1);
				}
			}
		}else{
			int bestIdx = -1;
			float bestValue = -1.0;
			Vector plyOri = Vector(0.0, 0.0, 0.0);
			
			CBasePlayer@ pPlayer = null;
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			   
				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;
				
				if(pPlayer.pev.origin.x < 720.0 && (pPlayer.pev.origin.x > -16.0 || pPlayer.pev.origin.y > -908.0)){
					float targetValue = 1408.0 + pPlayer.pev.origin.y;
					if(targetValue > bestValue){
						bestValue = targetValue;
						bestIdx = iPlayer;
						plyOri = pPlayer.pev.origin;
					}
				}
			}
			
			aimPlyIdx = bestIdx;
			
			if(aimPlyIdx == -1){
				//No player found to attack
				//Go back to Idle
				gotoIdle();
			}else{
				if(plyOri.z < 256.0f){
					//Acid Mid
					SetAnim(GENEWORM_DATTACK1);
				}else{
					if(plyOri.x > 160.0f){
						//Acid Left
						SetAnim(GENEWORM_DATTACK2);
					}else{
						//Acid Right
						SetAnim(GENEWORM_DATTACK3);
					}
				}
				time2 = g_Engine.time + 2.2f;
				SetThink( ThinkFunction( this.ThinkAcidSpit ) );
			}
		}
		time1 = g_Engine.time;
	}
	
	void gotoIdle(){
		if(g_EyeStatusR == -1) g_EyeStatusR = 0;
		if(g_EyeStatusL == -1) g_EyeStatusL = 0;
		switch(g_Phase){
			case 0:
				SetAnim(GENEWORM_IDLE);
				idleMaxTime1 = 4.03f;
				idleMaxTime2 = 63.47f;
				break;
			case 1:
				SetAnim(GENEWORM_IDLEPAIN1);
				idleMaxTime1 = 3.45f;
				idleMaxTime2 = 74.04f;
				break;
			case 2:
				SetAnim(GENEWORM_IDLEPAIN2);
				idleMaxTime1 = 2.68f;
				idleMaxTime2 = 95.20f;
				break;
			default:
				SetAnim(GENEWORM_IDLEPAIN3);
				idleMaxTime1 = 2.01f;
				idleMaxTime2 = 126.94f;
		}
		SetThink( ThinkFunction( this.ThinkIdle ) );
		time1 = g_Engine.time;
	}
	
	void ThinkIdle(){
		calcHitboxes(idleMaxTime2);
		if(g_Engine.time - time1 > idleMaxTime1){
			startAttack(0);
		}else if(g_EyeStatusL == 1){
			if(g_EyeStatusR < 2) {
				g_EyeStatusR = -1;
				self.pev.skin = 1;
				SetAnim(GENEWORM_EYEPAIN1); //Left
				SetThink( ThinkFunction( this.ThinkEyepain1 ) );
			}else{
				self.pev.skin = 3;
				switch(g_Phase){
					case 0:
						g_openHeart = 3;
						break;
					case 1:
						g_openHeart = 2;
						break;
					default:
						g_openHeart = 1;
				}
				SetAnim(GENEWORM_BIGPAIN1); //PAIN
				SetThink( ThinkFunction( this.ThinkBHurt1 ) );
			}
			g_EyeStatusL = 2;
			time1 = g_Engine.time;
		}else if(g_EyeStatusR == 1){
			if(g_EyeStatusL < 2) {
				g_EyeStatusL = -1;
				self.pev.skin = 2;
				SetAnim(GENEWORM_EYEPAIN2); //Right
				SetThink( ThinkFunction( this.ThinkEyepain2 ) );
			}else{
				self.pev.skin = 3;
				switch(g_Phase){
					case 0:
						g_openHeart = 3;
						break;
					case 1:
						g_openHeart = 2;
						break;
					default:
						g_openHeart = 1;
				}
				SetAnim(GENEWORM_BIGPAIN1); //PAIN
				SetThink( ThinkFunction( this.ThinkBHurt1 ) );
			}
			g_EyeStatusR = 2;
			time1 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkAcidSpit(){
		calcHitboxes(48.12f);
		if(g_Engine.time - time1 > 5.27f){
			gotoIdle();
		}else{
			if(g_Engine.time - time1 < 4.0f && g_Engine.time > time2){
				time2 += 0.1f;
				
				Vector posi;
				Vector angi;
				
				self.pev.frame = int((g_Engine.time - time1)*48.12f);
				
				// string aStr = "Geneworm Frame: "+self.pev.frame+"\n";
				// g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
				
				self.GetAttachment(0, posi, angi);
				posi.z += 24.0f;
				self.pev.frame = 0;
				
				CBaseEntity@ pEntity = g_EntityFuncs.Create("geneworm_acid", posi, Vector(0, 0, 0), false);
				
				if(aimPlyIdx > -1){
					CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( aimPlyIdx );
				   
					if( pPlayer is null || !pPlayer.IsConnected() ){}else{
						aimPos = pPlayer.pev.origin;
						aimPos.z += 32;
					}
				}else{
					aimPos = self.pev.origin;
					aimPos.y -= -1.0;
				}
				
				Vector vecSpeed = Vector(0, 0, 0);
				vecSpeed = aimPos - posi;
				float vecSpeed_normal = sqrt(vecSpeed.x*vecSpeed.x+vecSpeed.y*vecSpeed.y+vecSpeed.z*vecSpeed.z);
				vecSpeed = vecSpeed * 1024.0f / vecSpeed_normal;
				
				pEntity.pev.velocity = vecSpeed;
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	//Left
	void ThinkMelee1(){
		calcHitboxes(153.60f);
		if(g_Engine.time - time1 > 1.64f){
			if(g_Phase < 3){
				gotoIdle();
			}else{
				startAttack(1);
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	//Right
	void ThinkMelee2(){
		calcHitboxes(98.46f);
		if(g_Engine.time - time1 > 2.57f){
			if(g_Phase < 3){
				gotoIdle();
			}else{
				startAttack(1);
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	//Center
	void ThinkMelee3(){
		calcHitboxes(135.53f);
		if(g_Engine.time - time1 > 1.85f){
			if(g_Phase < 3){
				gotoIdle();
			}else{
				startAttack(1);
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkMad(){
		calcHitboxes(146.89f);
		if(g_Engine.time - time1 > 1.71f){
			if(g_Phase == 0){
				gotoIdle();
			}else if(g_Phase == 1){
				startAttack(1);
			}else{
				startAttack(0);
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkBHurt1(){
		calcHitboxes(101.05f);
		if(g_Engine.time - time1 > 2.53f){
			SetAnim(GENEWORM_BIGPAIN2);
			SetThink( ThinkFunction( this.ThinkBHurt2 ) );
			time1 = g_Engine.time;
		}else if(g_openHeart == -1){
			if(g_Phase > 3){
				SetAnim(GENEWORM_DEATH);
				SetThink( ThinkFunction( this.ThinkDeath ) );
				g_EntityFuncs.FireTargets("GeneWormDead", null, null, USE_TOGGLE, 0.0f, 1.0f);
			}else{
				g_Phase++;
				SetAnim(GENEWORM_BIGPAIN3);
				SetThink( ThinkFunction( this.ThinkBHurt3 ) );
			}
			time1 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkBHurt2(){
		calcHitboxes(36.31f);
		if(g_Engine.time - time1 > 7.05f){
			if(g_openHeart > 1){
				g_openHeart--;
				SetAnim(GENEWORM_BIGPAIN2);
				SetThink( ThinkFunction( this.ThinkBHurt2 ) );
			}else{
				SetAnim(GENEWORM_BIGPAIN4);
				SetThink( ThinkFunction( this.ThinkBHurt4 ) );
				time2 = g_Engine.time;
			}
			time1 = g_Engine.time;
		}else if(g_openHeart == -1){
			if(g_Phase > 3){
				SetAnim(GENEWORM_DEATH);
				SetThink( ThinkFunction( this.ThinkDeath ) );
				g_EntityFuncs.FireTargets("GeneWormDead", null, null, USE_TOGGLE, 0.0f, 1.0f);
			}else{
				g_Phase++;
				SetAnim(GENEWORM_BIGPAIN3);
				SetThink( ThinkFunction( this.ThinkBHurt3 ) );
			}
			time1 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkBHurt3(){
		calcHitboxes(44.95f);
		if(g_Engine.time - time1 > 5.70f){
			SetAnim(GENEWORM_BIGPAIN4);
			SetThink( ThinkFunction( this.ThinkBHurt4 ) );
			time1 = g_Engine.time;
			time2 = g_Engine.time;
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkBHurt4(){
		calcHitboxes(38.55f);
		if(g_Engine.time - time2 > 3.5f){
			time2 += 10.0f;
			g_animTime = g_Engine.time;
		}
		if(g_Engine.time - time1 > 6.64f){
			self.pev.skin = 0;
			switch(g_Phase){
			case 1:
				gotoIdle();
				g_EyeStatusR = 0;
				g_EyeStatusL = 0;
				break;
			case 2:
				startAttack(0);
				g_EyeStatusR = -1;
				g_EyeStatusL = -1;
				break;
			default:
				SetAnim(GENEWORM_MAD);
				g_EntityFuncs.FireTargets("GeneWormWallHit", null, null, USE_TOGGLE, 0.0f, 1.0f);
				ThinkMad();
				g_EyeStatusR = -1;
				g_EyeStatusL = -1;
			}
		}
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	void ThinkDeath(){
		calcHitboxes(12.49f);
		if(g_Engine.time - time1 < 20.5f){
			self.pev.renderamt = 255.0f - (g_Engine.time - time1)*255.0f/20.5f;
			self.pev.nextthink = g_Engine.time + 0.01f;
		}
	}
}

class geneworm_acid : ScriptBaseEntity {
	
	private array<CBaseEntity@> playerWhiteList;
	
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
		self.pev.rendercolor    = Vector( 0.0f, 255.0f, 0.0f );
		self.pev.scale 		    = 0.75f;
		
		g_EntityFuncs.SetModel( self, "sprites/ballsmoke.spr" );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink( ThinkFunction( SolidThink ) );
		SetTouch( TouchFunction( DetoTouch ) );
	}
	
	void SolidThink(){
		// self.pev.movetype = MOVETYPE_FLY;
		self.pev.solid = SOLID_TRIGGER;
		g_EntityFuncs.SetSize( self.pev, Vector( -4,-4,-16 ), Vector( 4,4,16 ) );
		float bestDist = 1.0f;
		
		string aStr = "";
		
		for(int i1 = 0; i1 < 2; i1++){
			for(int i2 = 0; i2 < 2; i2++){
				for(int i3 = 0; i3 < 2; i3++){
					Vector startPos = self.pev.origin - Vector(-4, -4, -4) + Vector( 8*i1, 8*i2, 8*i3);
					Vector endPos = startPos + 8.0 * self.pev.velocity;
					TraceResult tr;
					
					g_Utility.TraceLine( startPos, endPos, ignore_monsters, self.edict(), tr );
					
					Vector endPosOff = tr.vecEndPos - startPos;
					float endPosOffDist = sqrt(endPosOff.x * endPosOff.x + endPosOff.y * endPosOff.y + endPosOff.z * endPosOff.z);
					
					if(bestDist < endPosOffDist) bestDist = endPosOffDist;
				}
			}
		}
		
		float aveVelo = sqrt(self.pev.velocity.x * self.pev.velocity.x + self.pev.velocity.y * self.pev.velocity.y + self.pev.velocity.z * self.pev.velocity.z);
		
		if(aveVelo < 0.1f){
			self.pev.nextthink = g_Engine.time + 0.01f;
		}else{
			self.pev.nextthink = g_Engine.time + bestDist / aveVelo + 0.01f;
		}
		
		SetThink( ThinkFunction( DetoThink ) );
	}
	
	void DetoThink(){
		if(self !is null && g_EntityFuncs.IsValidEntity( self.edict() )){
			g_EntityFuncs.Remove( self );
		}
	}
	
	void DetoTouch( CBaseEntity@ pOther ){
		float flDamage = 10.0f;
		
		if(pOther.IsPlayer()){
			if(playerWhiteList.find(pOther) > -1) return;
		}
		
		g_WeaponFuncs.ClearMultiDamage();
		pOther.TakeDamage( self.pev, self.pev, flDamage, DMG_ACID);
		g_WeaponFuncs.ApplyMultiDamage( self.pev, self.pev );
		
		if(pOther.IsPlayer()){
			playerWhiteList.insertLast(pOther);
		}
	}
}

class geneworm_eyel1 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		self.pev.takedamage	    = DAMAGE_YES;
		
		// self.pev.framerate      = 1.0f;
		// self.pev.rendermode     = 5;
		// self.pev.renderamt      = 255.0f;
		// self.pev.rendercolor    = Vector( 255.0f, 0.0f, 0.0f );
		// self.pev.scale 		    = 1.0f;
		// g_EntityFuncs.SetModel( self, "sprites/ballsmoke.spr" );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-48, -24, -32 ), Vector(-32, 24, 32 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneEyeL;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType){	
		if( pevAttacker is null ) return 0;
		if( bitsDamageType != DMG_ENERGYBEAM ) return 0;
		
		if(g_EyeStatusL == 0) g_EyeStatusL = 1;
		
		return 0;
	}
}

class geneworm_eyel2 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-112, -48, -64 ), Vector(-48, 48, 64 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneEyeL;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_eyer1 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		self.pev.takedamage	    = DAMAGE_YES;
		
		// self.pev.framerate      = 1.0f;
		// self.pev.rendermode     = 5;
		// self.pev.renderamt      = 255.0f;
		// self.pev.rendercolor    = Vector( 255.0f, 0.0f, 0.0f );
		// self.pev.scale 		    = 1.0f;
		// g_EntityFuncs.SetModel( self, "sprites/ballsmoke.spr" );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(32, -24, -32 ), Vector(48, 24, 32 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneEyeR;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType){	
		if( pevAttacker is null ) return 0;
		if( bitsDamageType != DMG_ENERGYBEAM ) return 0;
		
		if(g_EyeStatusR == 0) g_EyeStatusR = 1;
		
		return 0;
	}
}

class geneworm_eyer2 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(48, -48, -64 ), Vector(112, 48, 64 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneEyeR;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart1 : ScriptBaseEntity {
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		self.pev.takedamage	    = DAMAGE_YES;
		
		self.pev.framerate      = 1.0f;
		self.pev.rendermode     = 5;
		self.pev.renderamt      = 255.0f;
		self.pev.scale          = 1.0f;
		self.pev.frame          = 0;
		self.pev.health         = 300.0f;
		g_EntityFuncs.SetModel( self, "sprites/boss_glow.spr" );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-40, 16, -40 ), Vector(40, 20, 40 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		if(g_openHeart != 0 && g_animTime + 10.0f < g_Engine.time){
			self.pev.renderamt = 255.0f;
		}else{
			self.pev.renderamt = 0.0f;
		}
		
		self.pev.frame = int(g_Engine.time * 10.0f) % 25;
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType){	
		if( pevAttacker is null ) return 0;
		
		if(g_openHeart > 0){
			if((bitsDamageType & DMG_BULLET) != 0) flDamage /= 2.0f;
			if((bitsDamageType & DMG_BLAST) != 0) flDamage *= 1.5f;
			if((bitsDamageType & DMG_SONIC) != 0) flDamage *= 1.5f;
			if(pevInflictor.classname == "sporegrenade") pevInflictor.dmgtime = g_Engine.time;
			
			self.pev.health -= flDamage;
			
			if(self.pev.health <= 0.0f) {
				g_openHeart = -1;
				self.pev.health = 300.0f;
			}
		}
		
		return 0;
	}
}

class geneworm_heart2 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-80, -64, 40 ), Vector(80, 20, 80 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart3 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(40, -64, -40 ), Vector(80, 20, 40 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart4 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-80, -64, -40 ), Vector(-40, 20, 40 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart5 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-80, -64, -80 ), Vector(80, 20, -40 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart6 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-80, 20, -80 ), Vector(80, 32, 80 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_heart7 : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetSize( self.pev, Vector(-40, -64, -40 ), Vector(40, -32, 40 ) );
		
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin = g_posGeneHeart;
		if(g_openHeart != 0){
			self.pev.origin.z -= 1024.0f;
		}
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class geneworm_wall : ScriptBaseEntity {
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NOCLIP;
		self.pev.solid          = SOLID_BBOX;
		
		g_EntityFuncs.SetSize( self.pev, Vector(-352, 448, 0), Vector(608, 1536, 64) );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink( ThinkFunction( MoveThink ) );
	}
	
	void MoveThink(){
		self.pev.origin.y = g_moveWall;
		
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
			
			if(g_moveWall < 0.1f && g_moveWall > -1087.9f){
				if(pPlayer.pev.origin.x < 720.0f && pPlayer.pev.origin.y > 424.0f + g_moveWall){
					pPlayer.pev.origin.y = 424.0f + g_moveWall;
					if(pPlayer.pev.origin.x > 495.9f) pPlayer.pev.origin.x = 495.9f;
					if(pPlayer.pev.origin.x < -239.9f) pPlayer.pev.origin.x = -239.9f;
					if(pPlayer.pev.origin.x > 181.0f) pPlayer.pev.origin.x -= 1.0f;
					if(pPlayer.pev.origin.x < 179.0f) pPlayer.pev.origin.x += 1.0f;
					if(pPlayer.pev.velocity.y > -200.0f) pPlayer.pev.velocity.y = -200.0f;
					if(g_moveWall < -1069.9f && pPlayer.pev.origin.z < 7.9f) pPlayer.pev.origin.z = 8.1f;
				}
			}else{
				if(pPlayer.pev.origin.x < 720.0f && pPlayer.pev.origin.y > 431.9f + g_moveWall){
					pPlayer.pev.origin.y = 431.9f + g_moveWall;
					if(pPlayer.pev.origin.x > 181.0f) pPlayer.pev.origin.x -= 1.0f;
					if(pPlayer.pev.origin.x < 179.0f) pPlayer.pev.origin.x += 1.0f;
					if(pPlayer.pev.velocity.y > 0.0f) pPlayer.pev.velocity.y = 0.0f;
				}
			}
		}
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

class shockie_maker : ScriptBaseEntity {
	private int state;
	
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
		self.pev.scale          = 1.0f;
		self.pev.frame          = 0;
		self.pev.origin			= Vector(0, 0, -4096);
		state = 0;
		g_EntityFuncs.SetModel( self, "sprites/tele1.spr" );
		
		self.pev.nextthink = g_Engine.time + 0.01f;
		
		SetThink( ThinkFunction( AnimThink ) );
	}
	
	void AnimThink(){
		self.pev.frame = int(g_Engine.time * 10.0f) % 25;
		
		switch(state){
			case 0:
				if(g_animTime + 5.0f > g_Engine.time) {
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "debris/beamstart7.wav", 1.0f, ATTN_NONE, 0, 100 );
					state = 1;
					self.pev.scale = 0.5f;
					self.pev.origin = g_posGeneHeart;
					self.pev.velocity = (Vector(150.0f, -1020.0f, 128.0f) - self.pev.origin)/2.0f;
				}
				break;
			case 1:
				if(g_animTime + 2.0f < g_Engine.time) {
					g_EntityFuncs.FireTargets("teleport_beam_chaos", null, null, USE_ON, 0.0f, 0.0f);
					g_EntityFuncs.FireTargets("teleport_beam_chaos", null, null, USE_OFF, 0.0f, 1.0f);
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_STATIC, "debris/beamstart2.wav", 1.0f, ATTN_NONE, 0, 100 );
					state = 2;
					self.pev.velocity = Vector(0.0f, 0.0f, 0.0f);
					self.pev.origin = Vector(150.0f, -1020.0f, 128.0f);
					self.pev.scale = 2.0f;
				}else{
					self.pev.scale = 0.5f + 1.5f * (g_Engine.time - g_animTime)/2.0f;
				}
				break;
			case 2:
				if(g_animTime + 3.0f < g_Engine.time) {
					if(g_Phase > 3){
						// HAHAHAHA! Surprize Motherfuckers! >:D
						g_EntityFuncs.Create("monster_alien_voltigore", self.pev.origin, Vector(0, 270, 0), false);
					}else{
						g_EntityFuncs.Create("monster_shocktrooper", self.pev.origin, Vector(0, 270, 0), false);
					}
					state = 3;
				}
				break;
			case 3:
				if(g_animTime + 4.0f < g_Engine.time) {
					state = 4;
				}
				break;
			case 4:
				if(g_animTime + 6.0f < g_Engine.time) {
					state = 0;
					self.pev.origin.z -= 1024.0f;
				}else{
					self.pev.scale = 6.0f + g_animTime - g_Engine.time;
				}
				break;
		}
		
		self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

void RegisterGenewormCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_acid", "geneworm_acid" );
	g_CustomEntityFuncs.RegisterCustomEntity( "monster_geneworm", "monster_geneworm" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_eyel1", "geneworm_eyel1" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_eyel2", "geneworm_eyel2" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_eyer1", "geneworm_eyer1" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_eyer2", "geneworm_eyer2" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart1", "geneworm_heart1" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart2", "geneworm_heart2" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart3", "geneworm_heart3" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart4", "geneworm_heart4" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart5", "geneworm_heart5" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart6", "geneworm_heart6" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_heart7", "geneworm_heart7" );
	g_CustomEntityFuncs.RegisterCustomEntity( "shockie_maker", "shockie_maker" );
	g_CustomEntityFuncs.RegisterCustomEntity( "geneworm_wall", "geneworm_wall" );
}
