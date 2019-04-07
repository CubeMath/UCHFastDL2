
// Cyber-Franklin's hornet entity (based on agrunt hornet)
// Author: GeckonCZ

namespace THMonsterFranklinHornet
{

const int HORNET_TYPE_PRI			= 0;
const int HORNET_TYPE_ALT			= 1;
const float HORNET_PRI_SPEED		= 700.0f;
const float HORNET_ALT_SPEED		= 900.0f;
const float HORNET_BUZZ_VOLUME		= 0.8f;

const int HORNET_DAMAGE				= 10;

const string HORNET_MODEL			= "models/hornet.mdl";


class CFranklinHornet : ScriptBaseMonsterEntity
{
	private float			m_flStopAttack;
	private int				m_iHornetType;
	private float			m_flFlySpeed;
	
	private int				m_iHornetTrail;
	private int				m_iHornetPuff;
	
	// don't let hornets gib, ever.
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
	{
		// filter these bits a little.
		bitsDamageType &= ~ ( DMG_ALWAYSGIB );
		bitsDamageType |= DMG_NEVERGIB;

		return BaseClass.TakeDamage(pevInflictor, pevAttacker, flDamage, bitsDamageType);
	}

	void Spawn( void )
	{
		Precache();

		pev.movetype	= MOVETYPE_FLY;
		pev.solid		= SOLID_BBOX;
		pev.takedamage  = DAMAGE_YES;
		pev.flags		|= FL_MONSTER;
		pev.health		= 1;// weak!
		
		// hornets don't live as long in multiplayer
		m_flStopAttack = g_Engine.time + 3.5;
		//m_flStopAttack	= g_Engine.time + 5.0;

		self.m_flFieldOfView = 0.9; // +- 25 degrees

		if ( Math.RandomLong( 1, 5 ) <= 2 )
		{
			m_iHornetType = HORNET_TYPE_PRI;
			m_flFlySpeed = HORNET_PRI_SPEED;
		}
		else
		{
			m_iHornetType = HORNET_TYPE_ALT;
			m_flFlySpeed = HORNET_ALT_SPEED;
		}

		g_EntityFuncs.SetModel( self, HORNET_MODEL );
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) );

		SetTouch( TouchFunction( DieTouch ) );
		SetThink( ThinkFunction( StartTrack ) );

		edict_t@ pSoundEnt = pev.owner;
		if ( pSoundEnt is null )
			@pSoundEnt = self.edict();

		pev.dmg = HORNET_DAMAGE;
		
		pev.nextthink = g_Engine.time + 0.1;
		self.ResetSequenceInfo( );
	}

	void Precache( void )
	{
		g_Game.PrecacheModel( HORNET_MODEL );

		g_SoundSystem.PrecacheSound( "agrunt/ag_fire1.wav" );
		g_SoundSystem.PrecacheSound( "agrunt/ag_fire2.wav" );
		g_SoundSystem.PrecacheSound( "agrunt/ag_fire3.wav" );

		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_buzz1.wav" );
		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_buzz2.wav" );
		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_buzz3.wav" );

		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_hornethit1.wav" );
		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_hornethit2.wav" );
		g_SoundSystem.PrecacheSound( "hunger/hornet/ag_hornethit3.wav" );

		m_iHornetPuff = g_Game.PrecacheModel( "sprites/muz1.spr" );
		m_iHornetTrail = g_Game.PrecacheModel( "sprites/laserbeam.spr" );
	}	

	// hornets will never get mad at each other, no matter who the owner is.
	int IRelationship ( CBaseEntity@ pTarget )
	{
		if ( pTarget.pev.modelindex == pev.modelindex )
		{
			return R_NO;
		}

		return self.IRelationship( pTarget );
	}

	// ID's Hornet as their owner
	int Classify( void )
	{
		return CLASS_ALIEN_BIOWEAPON;
	}
	
	CBaseEntity@ FindClosestEnemy( float fRadius )
	{
		CBaseEntity@ ent = null;
		CBaseEntity@ enemy = null;
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
				
			if ( ent.edict() is pev.owner )
				continue;
				
			int rel = self.IRelationship(ent);
			if ( rel == R_AL || rel == R_NO )
				continue;
	
			float iDist = ( ent.pev.origin - self.pev.origin ).Length();
			if ( iDist < iNearest )
			{
				iNearest = iDist;
				@enemy = ent;
			}
		}
		while ( ent !is null );
		
		if ( enemy !is null )	
			g_Game.AlertMessage( at_console, "new enemy %1, relationship %2\n", enemy.GetClassname(), self.IRelationship(enemy) );
		
		return enemy;
	}

	// StartTrack - starts a hornet out tracking its target
	void StartTrack( void )
	{
		IgniteTrail();

		SetTouch( TouchFunction( TrackTouch ) );
		SetThink( ThinkFunction( TrackTarget ) );

		pev.nextthink = g_Engine.time + 0.1;
	}

	void StopTrack( void )
	{
		self.SUB_Remove();
	}

	// StartDart - starts a hornet out just flying straight.
	void StartDart ( void )
	{
		IgniteTrail();

		SetTouch( TouchFunction( DartTouch ) );
		SetThink( ThinkFunction( StopTrack ) );
		
		pev.nextthink = g_Engine.time + 4;
	}

	void IgniteTrail( void )
	{
		// trail
		NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			message.WriteByte( TE_BEAMFOLLOW );
			message.WriteShort( self.entindex() );
			message.WriteShort( m_iHornetTrail );
			message.WriteByte( 10 );
			message.WriteByte( 2 );
			
			switch ( m_iHornetType )
			{
			case HORNET_TYPE_PRI:
				message.WriteByte( 200 );	// r, was 179
				message.WriteByte( 100 );	// g, was 39
				message.WriteByte( 200 );	// b, was 14
				break;
			case HORNET_TYPE_ALT:
				message.WriteByte( 0 );		// r, was 255	
				message.WriteByte( 255 );	// g, was 128
				message.WriteByte( 190 );	// b, was 0
				break;
			}
			
			message.WriteByte( 128 );
		message.End();
	}

	// Hornet is flying, gently tracking target
	void TrackTarget( void )
	{
		Vector	vecFlightDir;
		Vector	vecDirToEnemy;
		float	flDelta;

		self.StudioFrameAdvance();

		if (g_Engine.time > m_flStopAttack)
		{
			SetTouch( null );
			SetThink( ThinkFunction( StopTrack ) );
			pev.nextthink = g_Engine.time + 0.1;
			return;
		}

		/*if ( !self.m_hEnemy.IsValid() )
		{
			self.m_hEnemy = FindClosestEnemy( 512 );
		}*/
		
		if ( self.m_hEnemy.IsValid() && self.FVisible( self.m_hEnemy.GetEntity(), true ))
		{
			self.m_vecEnemyLKP = self.m_hEnemy.GetEntity().BodyTarget( pev.origin );
		}
		else
		{
			self.m_vecEnemyLKP = self.m_vecEnemyLKP + pev.velocity * m_flFlySpeed * 0.1;
		}

		vecDirToEnemy = ( self.m_vecEnemyLKP - pev.origin ).Normalize();

		if (pev.velocity.Length() < 0.1)
			vecFlightDir = vecDirToEnemy;
		else 
			vecFlightDir = pev.velocity.Normalize();

		// measure how far the turn is, the wider the turn, the slow we'll go this time.
		flDelta = DotProduct ( vecFlightDir, vecDirToEnemy );
		
		if ( flDelta < 0.5 )
		{
			// hafta turn wide again. play sound
			switch ( Math.RandomLong( 0, 2 ) )
			{
			case 0:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz1.wav", HORNET_BUZZ_VOLUME, ATTN_NORM);	break;
			case 1:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz2.wav", HORNET_BUZZ_VOLUME, ATTN_NORM);	break;
			case 2:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz3.wav", HORNET_BUZZ_VOLUME, ATTN_NORM);	break;
			}
		}

		if ( flDelta <= 0 && m_iHornetType == HORNET_TYPE_PRI )
		{
			// no flying backwards, but we don't want to invert this, cause we'd go fast when we have to turn REAL far.
			flDelta = 0.25;
		}

		pev.velocity = ( vecFlightDir + vecDirToEnemy).Normalize();

		if ( pev.owner !is null && (pev.owner.vars.flags & FL_MONSTER) != 0 )
		{
			// random pattern applies to hornets fired by monsters
			pev.velocity.x += Math.RandomFloat( -0.08, 0.08 );// scramble the flight dir a bit.
			pev.velocity.y += Math.RandomFloat( -0.08, 0.08 );
			pev.velocity.z += Math.RandomFloat( -0.08, 0.08 );
		}
		
		switch ( m_iHornetType )
		{
			case HORNET_TYPE_PRI:
				pev.velocity = pev.velocity * ( m_flFlySpeed * flDelta );// scale the dir by the ( speed * width of turn )
				pev.nextthink = g_Engine.time + Math.RandomFloat( 0.1, 0.3 );
				break;
			case HORNET_TYPE_ALT:
				pev.velocity = pev.velocity * m_flFlySpeed;// do not have to slow down to turn.
				pev.nextthink = g_Engine.time + 0.1;// fixed think time
				break;
		}

		pev.angles = Math.VecToAngles (pev.velocity);

		pev.solid = SOLID_BBOX;

		// if hornet is close to the enemy, jet in a straight line for a half second.
		// Singleplayer only
		/*if ( self.m_hEnemy.IsValid() )
		{
			if ( flDelta >= 0.4f && ( pev.origin - self.m_vecEnemyLKP ).Length() <= 300.0f )
			{
				NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
					message.WriteByte( TE_SPRITE );
					message.WriteCoord( pev.origin.x );	// pos
					message.WriteCoord( pev.origin.y );
					message.WriteCoord( pev.origin.z );
					message.WriteShort( m_iHornetPuff );	// model
					//message.WriteByte( 0 );			// life * 10
					message.WriteByte( 2 );				// size * 10
					message.WriteByte( 128 );			// brightness
				message.End();

				switch ( Math.RandomLong( 0, 2 ) )
				{
				case 0:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz1.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
				case 1:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz2.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
				case 2:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_buzz3.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
				}
				pev.velocity = pev.velocity * 2;
				pev.nextthink = g_Engine.time + 1.0;
				// don't attack again
				m_flStopAttack = g_Engine.time;
			}
		}*/
	}

	// Tracking Hornet hit something
	void TrackTouch ( CBaseEntity@ pOther )
	{
		if ( pOther.edict() is pev.owner || pOther.pev.modelindex == pev.modelindex )
		{
			// bumped into the guy that shot it.
			pev.solid = SOLID_NOT;
			return;
		}

		if ( IRelationship( pOther ) <= R_NO )
		{
			// hit something we don't want to hurt, so turn around.

			pev.velocity = pev.velocity.Normalize();

			pev.velocity.x *= -1;
			pev.velocity.y *= -1;

			pev.origin = pev.origin + pev.velocity * 4; // bounce the hornet off a bit.
			pev.velocity = pev.velocity * m_flFlySpeed;

			return;
		}

		DieTouch( pOther );
	}

	void DartTouch( CBaseEntity@ pOther )
	{
		DieTouch( pOther );
	}

	void DieTouch( CBaseEntity@ pOther )
	{
		if ( pOther !is null && pOther.pev.takedamage != 0.0f )
		{
			// buzz when you plug someone
			switch (Math.RandomLong(0,2))
			{
				case 0:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_hornethit1.wav", 1, ATTN_NORM);	break;
				case 1:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_hornethit2.wav", 1, ATTN_NORM);	break;
				case 2:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "hunger/hornet/ag_hornethit3.wav", 1, ATTN_NORM);	break;
			}
				
			// do the damage
			pOther.TakeDamage( pev, pev.owner.vars, pev.dmg, DMG_BULLET );
		}

		// GeckoN: modelindex is const, let's apply EF_NODRAW instead
		//pev.modelindex = 0;// so will disappear for the 0.1 secs we wait until NEXTTHINK gets rid
		pev.effects |= EF_NODRAW;
		pev.solid = SOLID_NOT;

		SetThink ( ThinkFunction( StopTrack ) );
		pev.nextthink = g_Engine.time + 1;// stick around long enough for the sound to finish!
	}

}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THMonsterFranklinHornet::CFranklinHornet", "franklinhornet" );
}

} // end of namespace
