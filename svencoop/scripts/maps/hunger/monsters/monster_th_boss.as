
// Sheriff apache entity
// Author: GeckonCZ

namespace THMonsterBoss
{

const int SF_WAITFORTRIGGER	= (0x04 | 0x40); // UNDONE: Fix!
const int SF_NOWRECKAGE		= 0x08;

const int BOSS_HEALTH_BASE = 1000;
const int BOSS_HEALTH_PER_PLAYER_INC = 200;

const int EXPLOSION_DAMAGE_RADIUS = 128; // TODO: Wild guess

const string BOSS_MODEL = "models/hunger/boss.mdl";

class CBoss : ScriptBaseMonsterEntity
{
	private float m_flForce;
	private float m_flNext;

	private Vector m_vecTarget;
	private Vector m_posTarget;

	private Vector m_vecDesired;
	private Vector m_posDesired;

	private Vector m_vecGoal;

	private Vector m_angGun;
	private float m_flLastSeen;
	private float m_flPrevSeen;

	private int m_iSoundState; // don't save this

	private int m_iSpriteTexture;
	private int m_iExplode;
	private int m_iBodyGibs;

	private float m_flGoalSpeed;

	private int m_iDoSmokePuff;
	private CBeam@ m_pBeam;
	
	private CBaseEntity@ m_pGoalEnt; // TODO: Init?
	
	private int m_sModelIndexFireball;
	private int m_sModelIndexSmoke;

	void SetObjectCollisionBox( void )
	{
		pev.absmin = pev.origin + Vector( -300, -300, -172);
		pev.absmax = pev.origin + Vector(300, 300, 8);
	}
	
	void UpdateOnRemove()
	{
		//g_Game.AlertMessage( at_console, "UpdateOnRemove\n" );
		
		// Stop rotor sounds, issue #2833
		g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "apache/ap_rotor2.wav" );
		
		BaseClass.UpdateOnRemove();
	}
	
	void Spawn()
	{
		Precache();
		
		pev.movetype				= MOVETYPE_FLY;
		pev.solid					= SOLID_BBOX;
		
		self.m_bloodColor			= DONT_BLEED;
		
		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, BOSS_MODEL );
			
		g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -64 ), Vector( 32, 32, 0 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		pev.flags 					|= FL_MONSTER;
		pev.takedamage				= DAMAGE_AIM;
		pev.health					= BOSS_HEALTH_BASE;
		
		self.m_flFieldOfView = -0.707; // 270 degrees

		pev.sequence = 0;
		self.ResetSequenceInfo();
		pev.frame = Math.RandomLong(0, 0xFF);

		self.MonsterInit();
		
		self.InitBoneControllers();

		self.SetClassification( CLASS_ALIEN_MILITARY );
		
		if ( (pev.spawnflags & SF_WAITFORTRIGGER ) != 0 )
		{
			SetUse( UseFunction( StartupUse ) );
		}
		else
		{
			SetThink( ThinkFunction( HuntThink ) );
			SetTouch( TouchFunction( FlyTouch ) );
			pev.nextthink = g_Engine.time + 1.0;
		}
	}

	void Precache()
	{
		BaseClass.Precache();
		
		//Model precache optimization -Sniper
		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( BOSS_MODEL );
		}

		g_SoundSystem.PrecacheSound("apache/ap_rotor1.wav");
		g_SoundSystem.PrecacheSound("apache/ap_rotor2.wav");
		g_SoundSystem.PrecacheSound("apache/ap_rotor3.wav");
		g_SoundSystem.PrecacheSound("apache/ap_whine1.wav");
		
		g_SoundSystem.PrecacheSound("weapons/mortarhit.wav");
		
		m_iSpriteTexture = g_Game.PrecacheModel( "sprites/white.spr" );
		
		g_SoundSystem.PrecacheSound( "turret/tu_fire1.wav" );

		g_Game.PrecacheModel( "sprites/lgtning.spr" );
		
		m_iExplode = g_Game.PrecacheModel("sprites/fexplo.spr");
		m_iBodyGibs = g_Game.PrecacheModel("models/metalplategibs_green.mdl");
		
		// Fireball and Smoke sprites should be already precached by the game.
		m_sModelIndexFireball = g_EngineFuncs.ModelIndex("sprites/zerogxplode.spr");
		m_sModelIndexSmoke = g_EngineFuncs.ModelIndex("sprites/steam1.spr");
	}
	
	CBaseEntity@ FindClosestEnemy( float fRadius )
	{
		CBaseEntity@ ent = null;
		float iNearest = fRadius;

		do
		{
			@ent = g_EntityFuncs.FindEntityInSphere( ent, self.pev.origin,
				fRadius, "*", "classname" ); 
			
			if ( ent is null || !ent.IsAlive() )
				continue;
	
			if ( ent.pev.classname == "squadmaker" )
				continue;
	
			if ( ent.entindex() == self.entindex() )
				continue;
				
			int rel = self.IRelationship(ent);
			if ( rel == R_AL || rel == R_NO )
				continue;
	
			float iDist = ( ent.pev.origin - self.pev.origin ).Length();
			if ( iDist < iNearest )
			{
				iNearest = iDist;
				@self.pev.enemy = ent.edict();
			}
		}
		while ( ent !is null );
		
		return g_EntityFuncs.Instance( self.pev.enemy );
	}

	void NullThink( void )
	{
		self.StudioFrameAdvance();
		pev.nextthink = g_Engine.time + 0.5;
	}

	void StartupUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		SetThink( ThinkFunction( HuntThink ) );
		SetTouch( TouchFunction( FlyTouch ) );
		pev.nextthink = g_Engine.time + 0.1;
		SetUse( null );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		pev.deadflag = DEAD_DYING;
		self.FCheckAITrigger();
		
		pev.movetype = MOVETYPE_BOUNCE;
		pev.gravity = 0.3;

		g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "apache/ap_rotor2.wav" );

		g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -64), Vector( 32, 32, 0) );
		SetThink( ThinkFunction( DyingThink ) );
		SetTouch( TouchFunction( CrashTouch ) );
		pev.nextthink = g_Engine.time + 0.1;
		pev.health = 0;
		pev.takedamage = DAMAGE_NO;

		if ( ( pev.spawnflags & SF_NOWRECKAGE ) != 0 )
		{
			m_flNext = g_Engine.time + 4.0;
		}
		else
		{
			m_flNext = g_Engine.time + 15.0;
		}
	}

	void DyingThink( void )
	{
		self.StudioFrameAdvance( );
		pev.nextthink = g_Engine.time + 0.2;
		pev.avelocity = pev.avelocity * 1.02;
		
		pev.avelocity.x += Math.RandomLong(1, -1);
		pev.avelocity.z += Math.RandomLong(1, -1);
		Math.MakeVectors( pev.angles ); // A bit of upward lift.
		pev.velocity = pev.velocity + (g_Engine.v_up * 75);

		pev.movetype = MOVETYPE_TOSS;
		pev.gravity = 0.8;

		// still falling?
		if (m_flNext > g_Engine.time )
		{
			//g_Game.AlertMessage( at_console, "Crashing\n" );
			
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
			
			switch( Math.RandomLong(0,2) )
			{
				case 0: g_SoundSystem.PlaySound( null, CHAN_AUTO, "weapons/explode3.wav", 1.0, 0.3, 0, PITCH_NORM, 0, true, self.pev.origin ); break;
				case 1: g_SoundSystem.PlaySound( null, CHAN_AUTO, "weapons/explode4.wav", 1.0, 0.3, 0, PITCH_NORM, 0, true, self.pev.origin ); break;
				case 2: g_SoundSystem.PlaySound( null, CHAN_AUTO, "weapons/explode5.wav", 1.0, 0.3, 0, PITCH_NORM, 0, true, self.pev.origin ); break;
			}

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

			Vector vecSpot = pev.origin + (pev.mins + pev.maxs) * 0.5;
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
		}
		else
		{
			//g_Game.AlertMessage( at_console, "Crashed\n" );
			
			Vector vecSpot = pev.origin + (pev.mins + pev.maxs) * 0.5;

			// fireball
			NetworkMessage fireball( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
				fireball.WriteByte( TE_SPRITE );
				fireball.WriteCoord( vecSpot.x );
				fireball.WriteCoord( vecSpot.y );
				fireball.WriteCoord( vecSpot.z + 256 );
				fireball.WriteShort( m_iExplode );
				fireball.WriteByte( 120 ); // scale * 10
				fireball.WriteByte( 255 ); // brightness
			fireball.End();
			
			// Big Smoke (RIP you betraying bastard)
			NetworkMessage bigsmoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
				bigsmoke.WriteByte( TE_SMOKE );
				bigsmoke.WriteCoord( vecSpot.x );
				bigsmoke.WriteCoord( vecSpot.y );
				bigsmoke.WriteCoord( vecSpot.z + 512 );
				bigsmoke.WriteShort( m_sModelIndexSmoke );
				bigsmoke.WriteByte( 250 ); // scale * 10
				bigsmoke.WriteByte( 5  ); // framerate
			bigsmoke.End();

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

			g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, self.pev, 300, EXPLOSION_DAMAGE_RADIUS, CLASS_NONE, DMG_BLAST );

			// GeckoN: No wreckage or gibs, it would be hardly noticeable anyway.
			/*
			//if (!(pev.spawnflags & SF_NOWRECKAGE) && (pev.flags & FL_ONGROUND) != 0 )
			if ((pev.flags & FL_ONGROUND) != 0 )
			{
				CBaseEntity@ pWreckage = g_EntityFuncs.Create( "cycler_wreckage", pev.origin, pev.angles, false, self.edict() );
				// SET_MODEL( ENT(pWreckage.pev), STRING(pev.model) );
				g_EntityFuncs.SetSize( pWreckage.pev, Vector( -200, -200, -128 ), Vector( 200, 200, -32 ) );
				pWreckage.pev.frame = pev.frame;
				pWreckage.pev.sequence = pev.sequence;
				pWreckage.pev.framerate = 0;
				pWreckage.pev.dmgtime = g_Engine.time + 5;
			}

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
			gibs.End();*/

			SetThink( ThinkFunction( ThinkRemove ) );
			pev.nextthink = g_Engine.time + 0.1;
		}
	}

	void ThinkRemove( void )
	{
		//g_Game.AlertMessage( at_console, "ThinkRemove\n" );
		self.SUB_Remove();
	}
	
	void FlyTouch( CBaseEntity@ pOther )
	{
		// bounce if we hit something solid
		if ( pOther.pev.solid == SOLID_BSP) 
		{
			TraceResult tr = g_Utility.GetGlobalTrace( );

			// UNDONE, do a real bounce
			pev.velocity = pev.velocity + tr.vecPlaneNormal * (pev.velocity.Length() + 200);
		}
	}

	void CrashTouch( CBaseEntity@ pOther )
	{
		// only crash if we hit something solid
		if ( pOther.pev.solid == SOLID_BSP) 
		{
			SetTouch( null );
			m_flNext = g_Engine.time;
			pev.nextthink = g_Engine.time;
		}
	}

	void GibMonster( void )
	{
		// g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_VOICE, "common/bodysplat.wav", 0.75, ATTN_NORM, 0, 200);		
	}

	void HuntThink( void )
	{
		//g_Game.AlertMessage( at_console, "HuntThink\n" );
		
		self.StudioFrameAdvance();
		pev.nextthink = g_Engine.time + 0.1;

		ShowDamage();

		if ( m_pGoalEnt is null &&
			!string( self.pev.target ).IsEmpty() )// this monster has a target
		{
			@m_pGoalEnt = g_EntityFuncs.FindEntityByTargetname( null, ( pev.target ) );
			if (m_pGoalEnt !is null )
			{
				m_posDesired = m_pGoalEnt.pev.origin;
				Math.MakeAimVectors( m_pGoalEnt.pev.angles );
				m_vecGoal = g_Engine.v_forward;
			}
		}

		//if (!self.m_hEnemy.IsValid())
		{
			self.m_hEnemy = FindClosestEnemy( 4092 );
		}

		// generic speed up
		if (m_flGoalSpeed < 800)
			m_flGoalSpeed += 5;

		if (self.m_hEnemy.IsValid())
		{
			//g_Game.AlertMessage( at_console, "Valid Enemy\n" );
			// g_Game.AlertMessage( at_console, "%1\n", ( self.m_hEnemy.pev.classname ) );
			if (self.FVisible( self.m_hEnemy, true ))
			{
				if (m_flLastSeen < g_Engine.time - 5)
					m_flPrevSeen = g_Engine.time;
				m_flLastSeen = g_Engine.time;
				m_posTarget = self.m_hEnemy.GetEntity().Center( );
			}
			else
			{
				self.m_hEnemy = null;
			}
		}

		m_vecTarget = (m_posTarget - pev.origin).Normalize();

		float flLength = (pev.origin - m_posDesired).Length();

		if (m_pGoalEnt !is null)
		{
			// g_Game.AlertMessage( at_console, "%1\n", flLength );

			if (flLength < 128)
			{
				@m_pGoalEnt = g_EntityFuncs.FindEntityByTargetname( null, ( m_pGoalEnt.pev.target ) );
				if (m_pGoalEnt !is null)
				{
					m_posDesired = m_pGoalEnt.pev.origin;
					Math.MakeAimVectors( m_pGoalEnt.pev.angles );
					m_vecGoal = g_Engine.v_forward;
					flLength = (pev.origin - m_posDesired).Length();
				}
			}
		}
		else
		{
			m_posDesired = pev.origin;
		}

		if (flLength > 250) // 500
		{
			// float flLength2 = (m_posTarget - pev.origin).Length() * (1.5 - DotProduct((m_posTarget - pev.origin).Normalize(), pev.velocity.Normalize() ));
			// if (flLength2 < flLength)
			if (m_flLastSeen + 90 > g_Engine.time && DotProduct( (m_posTarget - pev.origin).Normalize(), (m_posDesired - pev.origin).Normalize( )) > 0.25)
			{
				m_vecDesired = (m_posTarget - pev.origin).Normalize( );
			}
			else
			{
				m_vecDesired = (m_posDesired - pev.origin).Normalize( );
			}
		}
		else
		{
			m_vecDesired = m_vecGoal;
		}

		Flight();

		// g_Game.AlertMessage( at_console, "%1 %2 %3\n", g_Engine.time, m_flLastSeen, m_flPrevSeen );
		if ((m_flLastSeen + 1 > g_Engine.time) && (m_flPrevSeen + 2 < g_Engine.time))
		{
			if (FireGun( ))
			{
				// slow down if we're fireing
				if (m_flGoalSpeed > 400)
					m_flGoalSpeed = 400;
			}
		}

		Math.MakeAimVectors( pev.angles );
		Vector vecEst = (g_Engine.v_forward * 800 + pev.velocity).Normalize( );
		// g_Game.AlertMessage( at_console, "%1 %2 %3 %4\n", pev.angles.x < 0, DotProduct( pev.velocity, g_Engine.v_forward ) > -100, m_flNext < g_Engine.time, DotProduct( m_vecTarget, vecEst ) );
	}


	void Flight( void )
	{
		//g_Game.AlertMessage( at_console, "Flight\n" );
		
		// tilt model 5 degrees
		Vector vecAdj = Vector( 5.0, 0, 0 );

		// estimate where I'll be facing in one seconds
		Math.MakeAimVectors( pev.angles + pev.avelocity * 2 + vecAdj);
		// Vector vecEst1 = pev.origin + pev.velocity + g_Engine.v_up * m_flForce - Vector( 0, 0, 384 );
		// float flSide = DotProduct( m_posDesired - vecEst1, g_Engine.v_right );
		
		float flSide = DotProduct( m_vecDesired, g_Engine.v_right );

		if (flSide < 0)
		{
			if (pev.avelocity.y < 60)
			{
				pev.avelocity.y += 8; // 9 * (3.0/2.0);
			}
		}
		else
		{
			if (pev.avelocity.y > -60)
			{
				pev.avelocity.y -= 8; // 9 * (3.0/2.0);
			}
		}
		pev.avelocity.y *= 0.98;

		// estimate where I'll be in two seconds
		Math.MakeAimVectors( pev.angles + pev.avelocity * 1 + vecAdj);
		Vector vecEst = pev.origin + pev.velocity * 2.0 + g_Engine.v_up * m_flForce * 20 - Vector( 0, 0, 384 * 2 );

		// add immediate force
		Math.MakeAimVectors( pev.angles + vecAdj);
		pev.velocity.x += g_Engine.v_up.x * m_flForce;
		pev.velocity.y += g_Engine.v_up.y * m_flForce;
		pev.velocity.z += g_Engine.v_up.z * m_flForce;
		// add gravity
		pev.velocity.z -= 38.4; // 32ft/sec


		float flSpeed = pev.velocity.Length();
		float flDir = DotProduct( Vector( g_Engine.v_forward.x, g_Engine.v_forward.y, 0 ), Vector( pev.velocity.x, pev.velocity.y, 0 ) );
		if (flDir < 0)
			flSpeed = -flSpeed;

		float flDist = DotProduct( m_posDesired - vecEst, g_Engine.v_forward );

		// float flSlip = DotProduct( pev.velocity, g_Engine.v_right );
		float flSlip = -DotProduct( m_posDesired - vecEst, g_Engine.v_right );

		// fly sideways
		if (flSlip > 0)
		{
			if (pev.angles.z > -30 && pev.avelocity.z > -15)
				pev.avelocity.z -= 4;
			else
				pev.avelocity.z += 2;
		}
		else
		{

			if (pev.angles.z < 30 && pev.avelocity.z < 15)
				pev.avelocity.z += 4;
			else
				pev.avelocity.z -= 2;
		}

		// sideways drag
		pev.velocity.x = pev.velocity.x * (1.0 - abs( g_Engine.v_right.x ) * 0.05);
		pev.velocity.y = pev.velocity.y * (1.0 - abs( g_Engine.v_right.y ) * 0.05);
		pev.velocity.z = pev.velocity.z * (1.0 - abs( g_Engine.v_right.z ) * 0.05);

		// general drag
		pev.velocity = pev.velocity * 0.995;
		
		// apply power to stay correct height
		if (m_flForce < 80 && vecEst.z < m_posDesired.z) 
		{
			m_flForce += 12;
		}
		else if (m_flForce > 30)
		{
			if (vecEst.z > m_posDesired.z) 
				m_flForce -= 8;
		}

		// pitch forward or back to get to target
		if (flDist > 0 && flSpeed < m_flGoalSpeed /* && flSpeed < flDist */ && pev.angles.x + pev.avelocity.x > -40)
		{
			// g_Game.AlertMessage( at_console, "F " );
			// lean forward
			pev.avelocity.x -= 12.0;
		}
		else if (flDist < 0 && flSpeed > -50 && pev.angles.x + pev.avelocity.x  < 20)
		{
			// g_Game.AlertMessage( at_console, "B " );
			// lean backward
			pev.avelocity.x += 12.0;
		}
		else if (pev.angles.x + pev.avelocity.x > 0)
		{
			// g_Game.AlertMessage( at_console, "f " );
			pev.avelocity.x -= 4.0;
		}
		else if (pev.angles.x + pev.avelocity.x < 0)
		{
			// g_Game.AlertMessage( at_console, "b " );
			pev.avelocity.x += 4.0;
		}

		// g_Game.AlertMessage( at_console, "%1 %2 : %3 %4 : %5 %6 : %7\n", pev.origin.x, pev.velocity.x, flDist, flSpeed, pev.angles.x, pev.avelocity.x, m_flForce ); 
		// g_Game.AlertMessage( at_console, "%1 %2 : %3 %4 : %5\n", pev.origin.z, pev.velocity.z, vecEst.z, m_posDesired.z, m_flForce ); 

		// make rotor, engine sounds
		if (m_iSoundState == 0)
		{
			g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "apache/ap_rotor2.wav", 1.0, 0.3, 0, 110 );
			// g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "apache/ap_whine1.wav", 0.5, 0.2, 0, 110 );

			m_iSoundState = SND_CHANGE_PITCH; // hack for going through level transitions
		}
		else
		{
			//CBaseEntity@ pPlayer = null;

			// UNDONE: this needs to send different sounds to every player for multiplayer.	
			//pPlayer = UTIL_FindEntityByClassname( null, "player" );
			//while( ( @pPlayer = g_EntityFuncs.FindEntityByClassname( pPlayer, "player" ) ) !is null )
			{
				// TODO:
				//float pitchf = DotProduct( pev.velocity - pPlayer.pev.velocity, (pPlayer.pev.origin - pev.origin).Normalize() );
				float pitchf = DotProduct( pev.velocity, (pev.origin).Normalize() );
				
				int pitch = int(100 + pitchf / 50.0);

				if (pitch > 250) 
					pitch = 250;
				if (pitch < 50)
					pitch = 50;
				if (pitch == 100)
					pitch = 101;

				float flVol = (m_flForce / 100.0) + .1;
				if (flVol > 1.0) 
					flVol = 1.0;

				g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "apache/ap_rotor2.wav", 1.0, 0.3, SND_CHANGE_PITCH | SND_CHANGE_VOL, pitch);
			}
			// g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, "apache/ap_whine1.wav", flVol, 0.2, SND_CHANGE_PITCH | SND_CHANGE_VOL, pitch);
		
			// g_Game.AlertMessage( at_console, "%1 %2\n", pitch, flVol );
		}
	}

	bool FireGun( void )
	{
		//g_Game.AlertMessage( at_console, "Fire\n" );
		
		Math.MakeAimVectors( pev.angles );
			
		Vector posGun, angGun;
		self.GetAttachment( 1, posGun, angGun );

		Vector vecTarget = (m_posTarget - posGun).Normalize( );

		Vector vecOut;

		vecOut.x = DotProduct( g_Engine.v_forward, vecTarget );
		vecOut.y = -DotProduct( g_Engine.v_right, vecTarget );
		vecOut.z = DotProduct( g_Engine.v_up, vecTarget );
		
		Vector angles = Math.VecToAngles (vecOut);
		
		angles.y -= 90;
		
		angles.x = -angles.x;
		if (angles.y > 180)
			angles.y = angles.y - 360;
		if (angles.y < -180)
			angles.y = angles.y + 360;
		if (angles.x > 180)
			angles.x = angles.x - 360;
		if (angles.x < -180)
			angles.x = angles.x + 360;

		if (angles.x > m_angGun.x)
			m_angGun.x = Math.min( angles.x, m_angGun.x + 12 );
		if (angles.x < m_angGun.x)
			m_angGun.x = Math.max( angles.x, m_angGun.x - 12 );
		if (angles.y > m_angGun.y)
			m_angGun.y = Math.min( angles.y, m_angGun.y + 12 );
		if (angles.y < m_angGun.y)
			m_angGun.y = Math.max( angles.y, m_angGun.y - 12 );

		m_angGun.y = self.SetBoneController( 0, m_angGun.y ); // left/right
		m_angGun.x = self.SetBoneController( 1, m_angGun.x ); // up/down

		Vector posBarrel, angBarrel;
		self.GetAttachment( 0, posBarrel, angBarrel );
		Vector vecGun = (posBarrel - posGun).Normalize( );

		if (DotProduct( vecGun, vecTarget ) > 0.98)
		{
			self.FireBullets( 1, posGun, vecGun, VECTOR_CONE_3DEGREES, 8192, BULLET_MONSTER_12MM, 1 );
			g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_WEAPON, "turret/tu_fire1.wav", 1, 0.3);

			return true;
		}
		
		if (m_pBeam !is null)
		{
			g_EntityFuncs.Remove( m_pBeam );
			@m_pBeam = null;
		}
		
		return false;
	}

	void ShowDamage( void )
	{
		int trigger = BOSS_HEALTH_BASE / 2;
		if (m_iDoSmokePuff > 0 || Math.RandomLong(0,trigger) > pev.health)
		{
			NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				smoke.WriteByte( TE_SMOKE );
				smoke.WriteCoord( pev.origin.x );
				smoke.WriteCoord( pev.origin.y );
				smoke.WriteCoord( pev.origin.z - 32 );
				smoke.WriteShort( m_sModelIndexSmoke );
				smoke.WriteByte( Math.RandomLong(0,9) + 20 ); // scale * 10
				smoke.WriteByte( 12 ); // framerate
			smoke.End();
		}
		if (m_iDoSmokePuff > 0)
			m_iDoSmokePuff--;
	}


	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		//CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );
		
		if (pevInflictor.owner is self.edict())
			return 0;
			
		if ( pevAttacker is null )
			return 0;

		if ( (bitsDamageType & DMG_BLAST) != 0 )
		{
			flDamage *= 2;
		}

		/*
		if ( (bitsDamageType & DMG_BULLET) != 0 && flDamage > 50)
		{
			// clip bullet damage at 50
			flDamage = 50;
		}
		*/

		// g_Game.AlertMessage( at_console, "%1\n", flDamage );
		return BaseClass.TakeDamage(  pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}



	void TraceAttack( entvars_t@ pevAttacker, float flDamage, Vector vecDir, TraceResult/*@*/ ptr, int bitsDamageType)
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( ptr.pHit );

		if ( pEntity is null )
			return;
			
		// g_Game.AlertMessage( at_console, "%1 %2\n", ptr.iHitgroup, flDamage );

		// ignore blades
		if (ptr.iHitgroup == 6 && (bitsDamageType & (DMG_ENERGYBEAM|DMG_BULLET|DMG_CLUB)) != 0)
			return;

		// hit hard, hits cockpit, hits engines
		if (flDamage > 50 || ptr.iHitgroup == 1 || ptr.iHitgroup == 2)
		{
			g_WeaponFuncs.ClearMultiDamage();
			//if ( pEntity.pev.takedamage != 0 )
			{
				pEntity.TraceAttack( pevAttacker, flDamage, vecDir, ptr, bitsDamageType );
			}
			// g_Game.AlertMessage( at_console, "%1\n", flDamage );
			g_WeaponFuncs.ApplyMultiDamage( pevAttacker, self.pev/*, flDamage, bitsDamageType*/ );
			m_iDoSmokePuff = int( 3 + (flDamage / 5.0) );
		}
		else
		{
			// do half damage in the body
			// g_WeaponFuncs.ApplyMultiDamage( pevAttacker, self.pev, flDamage / 2.0, bitsDamageType );
			g_Utility.Ricochet( ptr.vecEndPos, 2.0 );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THMonsterBoss::CBoss", "monster_th_boss" );
}

} // end of namespace
