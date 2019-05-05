
class CAlienflyer : ScriptBaseMonsterEntity{
  private CBaseEntity@ m_pGoalEnt;
  private Vector m_vel1;
  private Vector m_vel2;
  private Vector m_pos1;
  private Vector m_pos2;
  private Vector m_ang1;
  private Vector m_ang2;
  private float m_startTime;
  private float m_dTime;

  private Vector m_velocity;

  private float m_flIdealtilt;
  private float m_flRotortilt;

  private float m_flRightHealth;
  private float m_flLeftHealth;

  private int m_iSoundState;
  private int m_iSpriteTexture;

  private int m_iPitch;

  private int m_iExplode;
  private int	m_iBodyGibs;
  
  private int m_iDoLeftSmokePuff;
  private int m_iDoRightSmokePuff;
  
	private int m_sModelIndexFireball;
	private int m_sModelIndexSmoke;
  
  void Spawn(){
    // g_Game.AlertMessage( at_console, "Spawn\n" );
    Precache();
    
    pev.movetype = MOVETYPE_FLY;
    pev.solid = SOLID_NOT;

    g_EntityFuncs.SetModel( self, "models/decay/flyer.mdl" );
    g_EntityFuncs.SetSize( self.pev, Vector( -400, -400, -100), Vector(400, 400, 32));
    g_EntityFuncs.SetOrigin( self, self.pev.origin );

    pev.flags         |= FL_MONSTER;
    pev.takedamage		= DAMAGE_NO;
    m_flRightHealth		= 500;
    m_flLeftHealth		= 500;
    pev.health			  = 1000;
    pev.rendermode    = 1;

    self.m_flFieldOfView = 0; // 180 degrees
    
		pev.sequence = 0;
		self.ResetSequenceInfo();
		pev.frame = Math.RandomLong(0, 0xFF);
    
    self.InitBoneControllers();

    SetThink( ThinkFunction( FlyThink ) );
    // SetTouch( TouchFunction( CommandUse ) );

    if ((pev.spawnflags & 0x40) == 0){
      
      pev.solid = SOLID_BBOX;
      pev.takedamage = DAMAGE_YES;
      pev.rendermode = 0;
      
      m_startTime = g_Engine.time + 1.0;
      pev.nextthink = m_startTime;
    }else{
      SetUse( UseFunction( StartupUse ) );
    }

    m_pos2 = pev.origin;
    m_ang2 = pev.angles;
    m_vel2 = pev.velocity;
  }
  
  void Precache() {
		BaseClass.Precache();
    
    g_Game.PrecacheModel("models/decay/flyer.mdl");
    g_Game.PrecacheModel("sprites/steam1.spr");

    g_SoundSystem.PrecacheSound("boid/boid_idle1.wav");
    g_SoundSystem.PrecacheSound("boid/boid_idle2.wav");
    g_SoundSystem.PrecacheSound("boid/boid_idle3.wav");
    g_SoundSystem.PrecacheSound("weapons/mortarhit.wav");

    m_iSpriteTexture = g_Game.PrecacheModel( "sprites/rope.spr" );

    m_iExplode	= g_Game.PrecacheModel( "sprites/fexplo.spr" );
    m_iBodyGibs = g_Game.PrecacheModel("models/decay/flyer_gibs.mdl");
    
		m_sModelIndexFireball = g_EngineFuncs.ModelIndex("sprites/zerogxplode.spr");
		m_sModelIndexSmoke = g_EngineFuncs.ModelIndex("sprites/steam1.spr");
  }

  void CommandUse( CBaseEntity@ pOther ) {
    // g_Game.AlertMessage( at_console, "CommandUse\n" );
    pev.nextthink = g_Engine.time + 0.1;
  }
  
  void UpdateGoal() {
    // g_Game.AlertMessage( at_console, "UpdateGoal\n" );
    
    if (m_pGoalEnt is null) {
      g_Game.AlertMessage( at_console, "WARNING: m_pGoalEnt is null!\n" );
      return;
    }
    // g_Game.AlertMessage( at_console, "WARNING: m_pGoalEnt is %1\n", m_pGoalEnt.pev.targetname );
    // g_Game.AlertMessage( at_console, "WARNING: m_pGoalEnt target is %1\n", m_pGoalEnt.pev.target );
    
    m_pos1 = m_pos2;
    m_ang1 = m_ang2;
    m_vel1 = m_vel2;
    m_pos2 = m_pGoalEnt.pev.origin;
    m_ang2 = m_pGoalEnt.pev.angles;
    Math.MakeAimVectors( Vector( 0, m_ang2.y, 0 ) );
    m_vel2 = g_Engine.v_forward * m_pGoalEnt.pev.speed;

    m_startTime = m_startTime + m_dTime;
    m_dTime = 2.0 * (m_pos1 - m_pos2).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed);
    if(m_dTime == 0.0) {
      
      // WARNING: m_dTime shouldn't be Zero!
      // DEBUG: m_dTime = 2.0 * (m_pos1 - m_pos2).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed);
      // DEBUG: m_dTime = 2.0 * (Vector(192, 1056, 2848) - Vector(192, 1056, 2848)).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed);
      // DEBUG: m_dTime = 2.0 * Vector(0, 0, 0).Length() / (Vector(0.00001, -800, 0).Length() + 800);
      // DEBUG: m_dTime = 2.0 * Vector(0, 0, 0).Length() / (800 + 800);
      // DEBUG: m_dTime = 2.0 * 0 / 1600;
      // DEBUG: m_dTime = 0 / 1600;
      // DEBUG: m_dTime = 0;
      
      g_Game.AlertMessage( at_console, "WARNING: m_dTime shouldn't be Zero!\n" );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = 2.0 * (m_pos1 - m_pos2).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed);\n" );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = 2.0 * (Vector(%1, %2, %3) - Vector(%4, %5, %6)).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed);\n",
        m_pos1.x, m_pos1.y, m_pos1.z, m_pos2.x, m_pos2.y, m_pos2.z
      );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = 2.0 * Vector(%1, %2, %3).Length() / (Vector(%4, %5, %6).Length() + %7);\n",
        m_pos1.x - m_pos2.x, m_pos1.y - m_pos2.y, m_pos1.z - m_pos2.z, m_vel1.x, m_vel1.y, m_vel1.z, m_pGoalEnt.pev.speed
      );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = 2.0 * Vector(%1, %2, %3).Length() / (%4 + %5);\n",
        m_pos1.x - m_pos2.x, m_pos1.y - m_pos2.y, m_pos1.z - m_pos2.z, m_vel1.Length(), m_pGoalEnt.pev.speed
      );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = 2.0 * %1 / %2;\n",
        (m_pos1 - m_pos2).Length(), m_vel1.Length() + m_pGoalEnt.pev.speed
      );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = %1 / %2;\n",
        2.0 * (m_pos1 - m_pos2).Length(), m_vel1.Length() + m_pGoalEnt.pev.speed
      );
      g_Game.AlertMessage( at_console, "DEBUG: m_dTime = %1;\n",
        2.0 * (m_pos1 - m_pos2).Length() / (m_vel1.Length() + m_pGoalEnt.pev.speed)
      );
      m_dTime = 1.0;
    }
    
    if (m_ang1.y - m_ang2.y < -180) {
      m_ang1.y += 360;
    } else if (m_ang1.y - m_ang2.y > 180) {
      m_ang1.y -= 360;
    }

    if (m_pGoalEnt.pev.speed < 400)
      m_flIdealtilt = 0;
    else
      m_flIdealtilt = -90;
  }

  void FlyThink() {
    // g_Game.AlertMessage( at_console, "FlyThink\n" );
    self.StudioFrameAdvance();
    pev.nextthink = g_Engine.time + 0.1;
    
    // this monster has a target
    if ( m_pGoalEnt is null && !string( self.pev.target ).IsEmpty() ) {
      @m_pGoalEnt = g_EntityFuncs.FindEntityByTargetname( null, ( pev.target ) );
      UpdateGoal();
    }
    
    if (g_Engine.time > m_startTime + m_dTime) {
      if(!string( m_pGoalEnt.pev.message ).IsEmpty()){
        g_EntityFuncs.FireTargets( m_pGoalEnt.pev.message , null, null, USE_ON, 0.0f, 0.0f);
      }
      @m_pGoalEnt = g_EntityFuncs.FindEntityByTargetname( null, ( m_pGoalEnt.pev.target ) );
      UpdateGoal();
    }
    
    Flight();
    ShowDamage();
  }

  float UTIL_SplineFraction( float value, float scale ){
    // g_Game.AlertMessage( at_console, "UTIL_SplineFraction\n" );
    value = scale * value;
    float valueSquared = value * value;

    // Nice little ease-in, ease-out spline-like curve
    return 3 * valueSquared - 2 * valueSquared * value;
  }

  void Flight() {
    // g_Game.AlertMessage( at_console, "Flight\n" );
    float t = (g_Engine.time - m_startTime);
    float scale = 1.0 / m_dTime;
    
    float f = UTIL_SplineFraction( t * scale, 1.0 );
    
    Vector pos = (m_pos1 + m_vel1 * t) * (1.0 - f) + (m_pos2 - m_vel2 * (m_dTime - t)) * f;
    Vector ang = (m_ang1) * (1.0 - f) + (m_ang2) * f;
    m_velocity = m_vel1 * (1.0 - f) + m_vel2 * f;
    
    g_EntityFuncs.SetOrigin( self, pos );
    pev.angles = ang;
    Math.MakeAimVectors( pev.angles );
    float flSpeed = DotProduct( g_Engine.v_forward, m_velocity );

    // float flSpeed = DotProduct( g_Engine.v_forward, pev.velocity );

    float m_flIdealtilt = (160 - flSpeed) / 10.0;

    // ALERT( at_console, "%f %f\n", flSpeed, flIdealtilt );
    if (m_flRotortilt < m_flIdealtilt) {
      m_flRotortilt += 0.5;
      if (m_flRotortilt > 0) m_flRotortilt = 0;
    }
    
    if (m_flRotortilt > m_flIdealtilt) {
      m_flRotortilt -= 0.5;
      if (m_flRotortilt < -90) m_flRotortilt = -90;
    }
    
    self.SetBoneController( 0, m_flRotortilt );
    
    
    
    if (m_iSoundState == 0) {
      g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "boid/boid_idle2.wav", 1.0, 0.15, 0, 100);

      m_iSoundState = SND_CHANGE_PITCH; // hack for going through level transitions
    }else{
      // CBaseEntity *pPlayer = NULL;

      // pPlayer = UTIL_FindEntityByClassname( NULL, "player" );
      // UNDONE: this needs to send different sounds to every player for multiplayer.	
      // if (pPlayer){
        // float pitch = DotProduct( m_velocity - pPlayer->pev.velocity, (pPlayer->pev.origin - pev.origin).Normalize() );
        
        float pitchf = DotProduct( pev.velocity, (pev.origin).Normalize() );
        
        int pitch = int(100 + pitchf / 75.0);
        
        if (pitch > 250) 
          pitch = 250;
        if (pitch < 50)
          pitch = 50;
        
        if (pitch == 100)
          pitch = 101;
        
        if (pitch != m_iPitch) {
          m_iPitch = pitch;
          g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "boid/boid_idle2.wav", 1.0, 0.15, 0, pitch);
          // ALERT( at_console, "%.0f\n", pitch );
        }
        
      // }
    }
  }


  void HitTouch( CBaseEntity@ pOther ) {
    // g_Game.AlertMessage( at_console, "HitTouch\n" );
    pev.nextthink = g_Engine.time + 2.0;
  }



  void Killed( entvars_t@ pevAttacker, int iGib ) {
    // g_Game.AlertMessage( at_console, "Killed\n" );
    pev.movetype = MOVETYPE_TOSS;
    pev.gravity = 0.3;
    pev.velocity = m_velocity;
    pev.avelocity = Vector( Math.RandomFloat( -20, 20 ), 0, Math.RandomFloat( -50, 50 ) );
		g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "boid/boid_idle2.wav" );
    
		g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -64), Vector( 32, 32, 0) );
    SetThink( ThinkFunction( DyingThink ) );
    SetTouch( TouchFunction( CrashTouch ) );
    pev.nextthink = g_Engine.time + 0.1;
    pev.health = 0;
    pev.takedamage = DAMAGE_NO;

    m_startTime = g_Engine.time + 4.0;
  }

  void CrashTouch( CBaseEntity@ pOther ) {
    // g_Game.AlertMessage( at_console, "CrashTouch\n" );
    // only crash if we hit something solid
    if ( pOther.pev.solid == SOLID_BSP) 
    {
      SetTouch(null);
      m_startTime = g_Engine.time;
      pev.nextthink = g_Engine.time;
      m_velocity = pev.velocity;
    }
  }


  void DyingThink() {
    // g_Game.AlertMessage( at_console, "DyingThink\n" );
    self.StudioFrameAdvance();
    pev.nextthink = g_Engine.time + 0.1;

    pev.avelocity = pev.avelocity * 1.02;

    // still falling?
    if (m_startTime > g_Engine.time ) {
      Math.MakeAimVectors( pev.angles );
      ShowDamage();

      Vector vecSpot = pev.origin + pev.velocity * 0.2;

      // random explosions
			NetworkMessage explosions( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				explosions.WriteByte( TE_EXPLOSION);		// This just makes a dynamic light now
				explosions.WriteCoord( pev.origin.x + Math.RandomFloat( -150, 150 ));
				explosions.WriteCoord( pev.origin.y + Math.RandomFloat( -150, 150 ));
				explosions.WriteCoord( pev.origin.z + Math.RandomFloat( -150, -50 ));
				explosions.WriteShort( m_sModelIndexFireball );
				explosions.WriteByte( Math.RandomLong(0,29) + 30  ); // scale * 10
				explosions.WriteByte( 12  ); // framerate
				explosions.WriteByte( TE_EXPLFLAG_NOSOUND );
			explosions.End();

      // lots of smoke
			NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				smoke.WriteByte( TE_SMOKE );
				smoke.WriteCoord( pev.origin.x + Math.RandomFloat( -150, 150 ));
				smoke.WriteCoord( pev.origin.y + Math.RandomFloat( -150, 150 ));
				smoke.WriteCoord( pev.origin.z + Math.RandomFloat( -150, -50 ));
				smoke.WriteShort( m_sModelIndexSmoke );
				smoke.WriteByte( 100 ); // scale * 10
				smoke.WriteByte( 10  ); // framerate
			smoke.End();

			vecSpot = pev.origin + (pev.mins + pev.maxs) * 0.5;
			NetworkMessage breakmodel( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
				breakmodel.WriteByte( TE_BREAKMODEL);

				// position
				breakmodel.WriteCoord( vecSpot.x );
				breakmodel.WriteCoord( vecSpot.y );
				breakmodel.WriteCoord( vecSpot.z );

				// size
				breakmodel.WriteCoord( 400 );
				breakmodel.WriteCoord( 400 );
				breakmodel.WriteCoord( 132 );

				// velocity
				breakmodel.WriteCoord( pev.velocity.x ); 
				breakmodel.WriteCoord( pev.velocity.y );
				breakmodel.WriteCoord( pev.velocity.z );

				// randomization
				breakmodel.WriteByte( 50 ); 

				// Model
				breakmodel.WriteShort( m_iBodyGibs );	//model id#

				// # of shards
				breakmodel.WriteByte( 4 );	// let client decide

				// duration
				breakmodel.WriteByte( 30 );// 3.0 seconds

				// flags

				breakmodel.WriteByte( BREAK_METAL );
			breakmodel.End();

      // don't stop it we touch a entity
			pev.flags &= ~FL_ONGROUND;
			pev.nextthink = g_Engine.time + 0.2;
      return;
    }else{
      Vector vecSpot = pev.origin + (pev.mins + pev.maxs) * 0.5;

      /*
      MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
        WRITE_BYTE( TE_EXPLOSION);		// This just makes a dynamic light now
        WRITE_COORD( vecSpot.x );
        WRITE_COORD( vecSpot.y );
        WRITE_COORD( vecSpot.z + 512 );
        WRITE_SHORT( m_iExplode );
        WRITE_BYTE( 250 ); // scale * 10
        WRITE_BYTE( 10  ); // framerate
      MESSAGE_END();
      */

      // gibs
			NetworkMessage fireball( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
				fireball.WriteByte( TE_SPRITE );
				fireball.WriteCoord( vecSpot.x );
				fireball.WriteCoord( vecSpot.y );
				fireball.WriteCoord( vecSpot.z + 512 );
				fireball.WriteShort( m_iExplode );
				fireball.WriteByte( 250 ); // scale * 10
				fireball.WriteByte( 255 ); // brightness
			fireball.End();

      /*
      MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
        WRITE_BYTE( TE_SMOKE );
        WRITE_COORD( vecSpot.x );
        WRITE_COORD( vecSpot.y );
        WRITE_COORD( vecSpot.z + 300 );
        WRITE_SHORT( g_sModelIndexSmoke );
        WRITE_BYTE( 250 ); // scale * 10
        WRITE_BYTE( 6  ); // framerate
      MESSAGE_END();
      */

      // blast circle
			NetworkMessage blastcircle( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				blastcircle.WriteByte( TE_BEAMCYLINDER );
				blastcircle.WriteCoord( pev.origin.x);
				blastcircle.WriteCoord( pev.origin.y);
				blastcircle.WriteCoord( pev.origin.z);
				blastcircle.WriteCoord( pev.origin.x);
				blastcircle.WriteCoord( pev.origin.y);
				blastcircle.WriteCoord( pev.origin.z + 2000 ); // reach damage radius over .2 seconds
				blastcircle.WriteShort( m_iSpriteTexture );
				blastcircle.WriteByte( 0 ); // startframe
				blastcircle.WriteByte( 0 ); // framerate
				blastcircle.WriteByte( 4 ); // life
				blastcircle.WriteByte( 32 );  // width
				blastcircle.WriteByte( 0 );   // noise
				blastcircle.WriteByte( 255 );   // r, g, b
				blastcircle.WriteByte( 255 );   // r, g, b
				blastcircle.WriteByte( 192 );   // r, g, b
				blastcircle.WriteByte( 128 ); // brightness
				blastcircle.WriteByte( 0 );		// speed
			blastcircle.End();

			g_SoundSystem.EmitSound(self.edict(), CHAN_STATIC, "weapons/mortarhit.wav", 1.0, 0.3);

			g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, self.pev, 300, 128, CLASS_NONE, DMG_BLAST );

      // gibs
      vecSpot = pev.origin + (pev.mins + pev.maxs) * 0.5;
			NetworkMessage gibs( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
				gibs.WriteByte( TE_BREAKMODEL);

				// position
				gibs.WriteCoord( vecSpot.x );
				gibs.WriteCoord( vecSpot.y );
				gibs.WriteCoord( vecSpot.z + 64);

				// size
				gibs.WriteCoord( 400 );
				gibs.WriteCoord( 400 );
				gibs.WriteCoord( 128 );

				// velocity
				gibs.WriteCoord( 0 ); 
				gibs.WriteCoord( 0 );
				gibs.WriteCoord( 200 );

				// randomization
				gibs.WriteByte( 30 ); 

				// Model
				gibs.WriteShort( m_iBodyGibs );	//model id#

				// # of shards
				gibs.WriteByte( 200 );

				// duration
				gibs.WriteByte( 200 );// 10.0 seconds

				// flags

				gibs.WriteByte( BREAK_METAL );
			gibs.End();
      
      g_EntityFuncs.FireTargets( "previctory_mm" , null, null, USE_ON, 0.0f, 0.0f);
      g_EntityFuncs.Remove( self );
    }
  }


  void ShowDamage() {
    // g_Game.AlertMessage( at_console, "ShowDamage\n" );
    if (m_iDoLeftSmokePuff > 0 || Math.RandomLong(0,99) > m_flLeftHealth) {
      Vector vecSrc = pev.origin + g_Engine.v_right * -340;
      
			NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				smoke.WriteByte( TE_SMOKE );
				smoke.WriteCoord( pev.origin.x );
				smoke.WriteCoord( pev.origin.y );
				smoke.WriteCoord( pev.origin.z );
				smoke.WriteShort( m_sModelIndexSmoke );
				smoke.WriteByte( Math.RandomLong(0,9) + 20 ); // scale * 10
				smoke.WriteByte( 12 ); // framerate
			smoke.End();
      
      if (m_iDoLeftSmokePuff > 0)
        m_iDoLeftSmokePuff--;
    }
    if (m_iDoRightSmokePuff > 0 || Math.RandomLong(0,99) > m_flRightHealth) {
      Vector vecSrc = pev.origin + g_Engine.v_right * 340;
      
			NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSrc );
				smoke.WriteByte( TE_SMOKE );
				smoke.WriteCoord( vecSrc.x );
				smoke.WriteCoord( vecSrc.y );
				smoke.WriteCoord( vecSrc.z );
				smoke.WriteShort( m_sModelIndexSmoke );
				smoke.WriteByte( Math.RandomLong(0,9) + 20 ); // scale * 10
				smoke.WriteByte( 12 ); // framerate
			smoke.End();
      
      if (m_iDoRightSmokePuff > 0)
        m_iDoRightSmokePuff--;
    }
  }
  
	void StartupUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ) {
    // g_Game.AlertMessage( at_console, "StartupUse\n" );
    m_startTime = g_Engine.time + 0.1;
		pev.nextthink = m_startTime;
    
    pev.health = 750;
    float addHealth = 500;
    
    CBasePlayer@ pPlayer = null;
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
      @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
      
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
      
      pev.health += addHealth;
      addHealth *= 0.9;
    }
    
    pev.solid = SOLID_BBOX;
    pev.takedamage = DAMAGE_YES;
    pev.rendermode = 0;
    
		SetUse( null );
	}
}

void RegisterAlienflyer(){
  g_CustomEntityFuncs.RegisterCustomEntity( "CAlienflyer", "monster_alienflyer" );
}
