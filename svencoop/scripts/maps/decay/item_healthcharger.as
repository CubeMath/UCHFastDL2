// PS2HL Health Charger Station
// Based off from https://github.com/supadupaplex/ya-ps2hl-dll

// Models
const string g_bottlemodel = "models/decay/health_charger_both.mdl";
const string g_chargemodel = "models/decay/health_charger_body.mdl";
const string g_medshotsnd = "items/medshot4.wav";
const string g_medshotnosnd = "items/medshotno1.wav";
const string g_medchargesnd = "items/medcharge4.wav";

// Ents
const string g_bottlename = "item_healthcharger_bottle";
const string g_healthstaname = "item_healthcharger";

// Custom defines
const float flHealthChargerRechargeTime = 60.0f; 	// Figure out if this can be set dynamically in the game and fetch it -R4to0
const float g_flTotalCharge = g_EngineFuncs.CVarGetFloat( "sk_healthcharger" );

// Defines
const float HCHG_DELAY_THINK		= 0.1f;		// Think delay
const float HCHG_ACTIVE_RADIUS		= 70.0f;	// Distance at which charger is deployed
const float HCHG_USE_RADIUS			= 50.0f;	// Defines distance at which player can use charger
const uint HCHG_GLASS_TRANSPARENCY	= 128;		// Glass bottle transparency (0 - max, 255 - min)
const bool HCHG_ACTIVATE_SOUND		= true;		// Play sound on activate (like in PS2 version)
const bool HCHG_SUIT_CHECK			= false;	// If defined then charger would not deploy for HEVless players (not present in PS2 version)
const bool HCHG_NO_BACK_USE			= true;		// Prevent usage from the back side (like in PS2 version)
const bool HCHG_HACKED_BBOX			= true;		// BBox hack for GoldSource

//================================
// Bottle for charger
//================================

// Sequences
enum BottleSeq
{
	HBOTTLE_SEQ_IDLE = 0,	// "still"
	HBOTTLE_SEQ_USE,		// "slosh"
	HBOTTLE_SEQ_STOP		// "to_rest"
};

// Controllers
const uint HBOTTLE_CTRL_LVL			= 0;		// Green goo level controller
const float HBOTTLE_CTRL_LVL_MIN	= -11.0f;	// Angle that corresponds to the min goo level
const float HBOTTLE_CTRL_LVL_MAX	= 0.0f;		// Angle that corresponds to the max goo level

// States
//enum BottleState
//{
//	HBOTTLE_STATE_IDLE = 0,	// Rest
//	HBOTTLE_STATE_USE,		// Slosh
//	HBOTTLE_STATE_STOP		// Stop slosh and go to idle
//};

//================================
// Charger itself
//================================

// Sequences
enum HGSeq
{
	HCHG_SEQ_IDLE = 0,	// "still"
	HCHG_SEQ_DEPLOY,	// "deploy"
	HCHG_SEQ_HIBERNATE,	// "retract_arm"
	HCHG_SEQ_EXPAND,	// "give_shot"
	HCHG_SEQ_RETRACT,	// "retract_shot"
	HCHG_SEQ_RDY,		// "prep_shot"
	HCHG_SEQ_USE		// "shot_idle"
}

// Controllers
const uint HCHG_CTRL_ARM = 0;	// Arm
const uint HCHG_CTRL_CAM = 1;	// Camera

// States
enum RechargeState2
{
	HCHG_STATE_IDLE = 0,	// No player near by, wait
	HCHG_STATE_ACTIVATE,	// Player is near - deploy
	HCHG_STATE_READY,		// Player is near and deployed - rotate arm to player position
	HCHG_STATE_START,		// Player hit use - expand arm
	HCHG_STATE_USE,			// Give charge
	HCHG_STATE_STOP,		// Player stopped using - retract arm, continue tracking
	HCHG_STATE_DEACTIVATE,	// PLayer went away - hibernate, reset arm position
	HCHG_STATE_EMPTY		// Charger is empty (dead end state in SP, wait for recharge in MP)
};

//================================
// Bottle for charger
//================================

class CHealthBottle : ScriptBaseAnimating
{
	void Precache()
	{
		g_Game.PrecacheModel( g_bottlemodel );
	}

	int ObjectCaps() 
    {
        return BaseClass.ObjectCaps() & ~FCAP_ACROSS_TRANSITION;
    }
	
	void Spawn()
	{
		// Precache
		Precache();

		// Set model
		g_EntityFuncs.SetModel( self, g_bottlemodel );

		// Properties
		self.pev.movetype = MOVETYPE_FLY;
		//self.pev.classname = "item_healthcharger_bottle"; // In AS, this is constant
		self.pev.solid = SOLID_BBOX;

		// BBox
		Vector Zero;
		Zero.x = Zero.y = Zero.z = 0;
		g_EntityFuncs.SetSize( self.pev, Zero, Zero );

		// Visuals
		self.pev.rendermode = kRenderTransTexture;		// Mode with transparency
		self.pev.renderamt = HCHG_GLASS_TRANSPARENCY;	// Transparency amount

		// Initial animation
		self.pev.sequence = HBOTTLE_SEQ_IDLE;
		self.pev.frame = 0;

		// Set think delay
		self.pev.nextthink = g_Engine.time + HCHG_DELAY_THINK;
	}

	void Think()
	{
		// Set delay for next think
		self.pev.nextthink = g_Engine.time + HCHG_DELAY_THINK;
		
		// Call animation handler
		self.StudioFrameAdvance( 0 );
		
		// State handler
		switch( self.pev.sequence )
		{
		//case HBOTTLE_SEQ_IDLE:
		//	// Idle - do nothing
		//	break;
		case HBOTTLE_SEQ_USE:
			// Reset frame counter to loop
			if( self.m_fSequenceFinished )
			{
				self.m_fSequenceFinished = false;
				self.pev.frame = 0;
			}
			break;
		case HBOTTLE_SEQ_STOP:
			// Just wait until animation is played
			if( self.m_fSequenceFinished )
				ChangeSequence( HBOTTLE_SEQ_IDLE );
			break;
		default:
			// Do nothing
			break;
		}
	}
	
	void ChangeSequence( int NewSequence )
	{
		if( self.pev.sequence == NewSequence )
			return;

		// Set sequence
		self.pev.sequence = NewSequence;

		// Prepare sequence
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}

	void SetLevel( float Level )
	{
		// Convert level to angle
		Level = HBOTTLE_CTRL_LVL_MIN + Level * ( HBOTTLE_CTRL_LVL_MAX - HBOTTLE_CTRL_LVL_MIN );

		// Set goo level controller
		self.SetBoneController( HBOTTLE_CTRL_LVL, Level );
	}
}

//================================
// Charger itself
//================================

// Item class. Using CBaseAnimating because of some model functions 
// and there is no CBaseButton exposed in AS -R4to0 
class CItemHealthCharger : ScriptBaseAnimating
{
	float m_flNextCharge;
	uint m_iReactivate;		// DeathMatch Delay until reactvated
	uint m_iJuice;			// How many charge left
	uint m_iOn;				// 0 = off, 1 = startup, 2 = going
	float m_flSoundTime;

	private bool IsUsed;
	private bool IsFrontAngle;
	private RechargeState2 CurrentState;
	private CHealthBottle@ pBottle;

	void Precache()
	{
		g_Game.PrecacheModel( g_chargemodel );
		g_SoundSystem.PrecacheSound( g_medshotsnd );
		g_SoundSystem.PrecacheSound( g_medshotnosnd );
		g_SoundSystem.PrecacheSound( g_medchargesnd );
	}
	
	int ObjectCaps() 
    {
        return ( BaseClass.ObjectCaps() | FCAP_CONTINUOUS_USE ) & ~FCAP_ACROSS_TRANSITION;
    }
	
	void Spawn()
	{
		// Precache models & sounds
		Precache();

		// Set model
		g_EntityFuncs.SetModel( self, g_chargemodel );

		// Set up BBox and origin
		self.pev.solid = SOLID_BBOX;//SOLID_TRIGGER;
		SetSequenceBox();
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		// Reset bone controllers
		self.InitBoneControllers();
		RotateCamArm( null );

		// Set move type
		//self.pev.movetype = MOVETYPE_PUSH;	// This was default for "func_healthcharger", but it breaks "nextthink" and bone controllers
		//self.pev.movetype = MOVETYPE_NONE;	// No bone controller interpolation in GoldSrc (but OK in Xash)

		self.pev.movetype = MOVETYPE_FLY;		// This type enables bone controller interpolation in GoldSrc
		
		// Get initial charge
		m_iJuice = int( g_flTotalCharge );
		
		// Set "on" skin
		self.pev.skin = 0;

		// Reset state
		ChangeState( HCHG_STATE_IDLE, HCHG_SEQ_IDLE );
		
		// Spawn bottle entity
		CBaseEntity@ pBottleEnt = g_EntityFuncs.CreateEntity( g_bottlename, null,  false );
		@pBottle = cast<CHealthBottle@>(CastToScriptClass(@pBottleEnt));
		pBottle.Spawn();
		g_EntityFuncs.SetOrigin( pBottle.self, self.pev.origin );
		pBottle.pev.angles = self.pev.angles;
		@pBottle.pev.owner = @self.edict();
		pBottle.SetLevel( 1.0f );
		
		// Set think delay
		self.pev.nextthink = g_Engine.time + HCHG_DELAY_THINK;
	}
	
    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        if( szKey == "style" ||
			szKey == "height" ||
			szKey == "value1" ||
			szKey == "value2" ||
			szKey == "value3")
		{
            return true;
        }
        else if( szKey == "dmdelay" )
        {
            m_iReactivate = atoi( szValue );
            return true;
        }
        else
            return BaseClass.KeyValue( szKey, szValue );
    }

	void Think()
	{
		// Get current time
		float CurrentTime = g_Engine.time;

		// Set delay for next think
		self.pev.nextthink = CurrentTime + HCHG_DELAY_THINK;

		// Call animation handler
		self.StudioFrameAdvance( 0 );

		// Update goo level
		if( IsUsed )
			pBottle.SetLevel( m_iJuice / g_flTotalCharge );
			
		//// g_Game.AlertMessage( at_console, "item_healthcharger: Think(): Level is at %1 for %2/%3 \n", m_iJuice / g_flTotalCharge, m_iJuice, g_flTotalCharge );

		// Find player
		CBaseEntity@ pPlayer = FindPlayer( HCHG_ACTIVE_RADIUS );

		// Track player
		if( CurrentState != HCHG_STATE_EMPTY && CurrentState != HCHG_STATE_DEACTIVATE )
			RotateCamArm( @pPlayer );
		else
			RotateCamArm( null );

		// State handler
		switch( CurrentState )
		{
		case HCHG_STATE_IDLE:
			// Player found?
			if( pPlayer !is null )
			{
				// Player is near

				// Prevent back side usage
				if( HCHG_NO_BACK_USE && !IsFrontAngle )
					return;

				// Prevent deployment if player doesn't have HEV
				if( HCHG_SUIT_CHECK && !(cast<CBasePlayer@>(pPlayer).HasSuit()) )
				{
					RotateCamArm( null );
					return;
				}

				// Emit sound
				if( HCHG_ACTIVATE_SOUND )
					g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_medshotsnd, 0.85, ATTN_NORM );

				// Change state
				// g_Game.AlertMessage( at_console, "item_healthcharger: activate\n" );
				ChangeState( HCHG_STATE_ACTIVATE, HCHG_SEQ_DEPLOY );
			}
			break;
		case HCHG_STATE_ACTIVATE:
			// Just wait until animation is played
			if( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_healthcharger: ready\n" );
				ChangeState( HCHG_STATE_READY, HCHG_SEQ_RDY );
			}
			break;
		case HCHG_STATE_READY:
			// Player is near?
			if( pPlayer is null )
			{
				// Nobody is near, hibernate
				// g_Game.AlertMessage( at_console, "item_healthcharger: deactivate\n" );
				ChangeState( HCHG_STATE_DEACTIVATE, HCHG_SEQ_HIBERNATE );
			}
			else
			{
				// Prevent back side usage
				if( HCHG_NO_BACK_USE && !IsFrontAngle )
				{
					ChangeState( HCHG_STATE_DEACTIVATE, HCHG_SEQ_HIBERNATE );
					return;
				}

				// Check if used
				if( IsUsed )
				{
					// g_Game.AlertMessage( at_console, "item_healthcharger: used\n" );
					ChangeState( HCHG_STATE_START, HCHG_SEQ_EXPAND );
					pBottle.ChangeSequence( HBOTTLE_SEQ_USE );
				}
			}
			break;
		case HCHG_STATE_START:
			// Just wait until animation is played
			if( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_healthcharger: giving charge\n" );
				ChangeState( HCHG_STATE_USE, HCHG_SEQ_USE );
			}
			break;
		case HCHG_STATE_USE:
			if( !IsUsed )
			{
				// No longer used - change state
				// g_Game.AlertMessage( at_console, "item_healthcharger: stopping\n" );
				ChangeState( HCHG_STATE_STOP, HCHG_SEQ_RETRACT );
				pBottle.ChangeSequence( HBOTTLE_SEQ_STOP );
			}

			// Reset use flag
			IsUsed = false;
			break;
		case HCHG_STATE_STOP:
			// Just wait until animation is played
			if( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_healthcharger: ready\n" );
				Off();
				ChangeState( HCHG_STATE_READY, HCHG_SEQ_RDY );
			}
			break;
		case HCHG_STATE_DEACTIVATE:
			// Just wait until animation is played
			if( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_healthcharger: to idle\n" );
				ChangeState( HCHG_STATE_IDLE, HCHG_SEQ_IDLE );
			}
			break;
		case HCHG_STATE_EMPTY:
			// Swap animation to hibernate
			if( self.pev.sequence == HCHG_SEQ_RETRACT && self.m_fSequenceFinished )
				ChangeSequence( HCHG_SEQ_HIBERNATE );

			// Swap animation to idle
			if( self.pev.sequence == HCHG_SEQ_HIBERNATE && self.m_fSequenceFinished )
				ChangeSequence( HCHG_SEQ_IDLE );

			// Wait for next recharge (multiplayer)
			if( m_flNextCharge != -1 && CurrentTime > m_flNextCharge )
			{
				Recharge();
				ChangeState( HCHG_STATE_IDLE, HCHG_SEQ_IDLE );
			}
			break;
		default:
			// Do nothing
			break;
		}
	}
	
	void ChangeSequence( int NewSequence )
	{
		// Set sequence
		self.pev.sequence = NewSequence;

		// Prepare sequence
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void ChangeState( RechargeState2 NewState, int NewSequence )
	{
		CurrentState = NewState;
		//CurrentStateTime = g_Engine.time;	// I found no use for it so far
		ChangeSequence( NewSequence );
	}

	void RotateCamArm( CBaseEntity@ pPlayer )
	{
		float Angle;
		Vector ChToPl;
		
		if( pPlayer !is null )
		{
			// Calculate angle
			ChToPl.x = self.pev.origin.x - pPlayer.pev.origin.x;
			ChToPl.y = self.pev.origin.y - pPlayer.pev.origin.y;
			ChToPl.z = self.pev.origin.z - pPlayer.pev.origin.z;
			ChToPl = Math.VecToAngles( ChToPl );
			Angle = ChToPl.y - self.pev.angles.y + 180;	// +180 - because player actually faces back side of the charger model

			// Angle correction
			if( Angle > 180)
			{
				while( Angle > 180 )
					Angle -= 360;
			}
			else if( Angle < -180 )
			{
				while( Angle < -180 )
					Angle += 360;
			}
			
			if( HCHG_NO_BACK_USE )
			{
				// Check if player is on front or in the back of the charger
				if( -90 > Angle || Angle > 90 )
				{
					IsFrontAngle = false;
					Angle = 0;
				}
				else
					IsFrontAngle = true;
			}
		}
		else
		{
			Angle = 0;
		}

		// Rotate bone controllers
		self.SetBoneController( HCHG_CTRL_ARM, Angle );
		self.SetBoneController( HCHG_CTRL_CAM, Angle );
	}

	CBaseEntity@ FindPlayer( float Radius )
	{
		CBaseEntity@ pPlayer = null;	// Result
		CBaseEntity@ pEntity = null;	// Used for search

		// Find near entities
		while( ( @pEntity = g_EntityFuncs.FindEntityInSphere( pEntity, self.pev.origin, HCHG_ACTIVE_RADIUS, "*", "classname" ) ) !is null )
		{
			if( pEntity.IsPlayer() )
			{
				// Found player - prepare result and terminate search
				@pPlayer = @pEntity;
				break;
			}
		}
		
		// Find near entities
		//while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "player" ) ) !is null )
		//{
		//	Vector Dist = self.pev.origin - pEntity.pev.origin;
		//	if( Dist.Length2D() < HCHG_ACTIVE_RADIUS )
		//	{
		//		// Found player - prepare result and terminate search
		//		pPlayer = pEntity;
		//		break;
		//	}
		//}

		// Return result
		return pPlayer;
	}

	// Based on "func_healthcharger"
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		// Make sure that we have a caller
		if( pActivator is null )
            return;

		// if it's not a player, ignore
		if ( !pActivator.IsPlayer() )
			return;

		if( HCHG_NO_BACK_USE )
		{
			if( !IsFrontAngle )
			return;

			// Check distance
			Vector Dist = self.pev.origin - pActivator.pev.origin;
			if( Dist.Length2D() > HCHG_USE_RADIUS )
			{
				// g_Game.AlertMessage( at_console, "item_healthcharger: player is too far ...\n" );
				return;
			}
		}
		
		// if there is no juice left, turn it off
		if( m_iJuice <= 0 )
		{
			// PS2HL
			// g_Game.AlertMessage( at_console, "item_healthcharger: empty\n" );
			self.pev.skin = 1;
			Off();
			if( CurrentState != HCHG_STATE_EMPTY )
			{
				ChangeState( HCHG_STATE_EMPTY, HCHG_SEQ_RETRACT );
				pBottle.ChangeSequence( HBOTTLE_SEQ_STOP );

				// Set up recharge
				if( ( m_iJuice == 0 ) && ( ( m_iReactivate = flHealthChargerRechargeTime ) > 0 ) )
					m_flNextCharge = g_Engine.time + m_iReactivate;
				else
					m_flNextCharge = -1;	// No recharge
			}
		}

		// if the player doesn't have the suit, or there is no juice left, make the deny noise
		if( ( m_iJuice <= 0 ) || ( !(cast<CBasePlayer@>(pActivator).HasSuit()) ) )
		{
			if( m_flSoundTime <= g_Engine.time )
			{
				m_flSoundTime = g_Engine.time + 0.62;
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_medshotnosnd, 1.0, ATTN_NORM );
			}
			return;
		}
		
		//=============
		// PS2HL
		//=============
		// Speed up deploy if used early
		if( CurrentState != HCHG_STATE_START && CurrentState != HCHG_STATE_USE )
		{
			ChangeState( HCHG_STATE_START, HCHG_SEQ_EXPAND );
			pBottle.ChangeSequence( HBOTTLE_SEQ_USE );
		}
		
		// Set use flag
		IsUsed = true;
		//=============
		
		//self.pev.nextthink = self.pev.ltime + 0.25;
		//SetThink( this.Off );

		// Time to recharge yet?
		if( m_flNextCharge >= g_Engine.time )
			return;

		// Play the on sound or the looping charging sound
		if( m_iOn == 0 )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_medshotsnd, 1.0, ATTN_NORM );
			m_flSoundTime = 0.56 + g_Engine.time;
		}
		if( ( m_iOn == 1 ) && ( m_flSoundTime <= g_Engine.time ) )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_medchargesnd, 1.0, ATTN_NORM );
		}
		
		// charge the player
		if( pActivator.TakeHealth( 1, DMG_GENERIC ) )
		{
			m_iJuice--;
		}
		
		// govern the rate of charge
		m_flNextCharge = g_Engine.time + 0.1;
	}

	// Based on "func_healthcharger"
	void Recharge()
	{
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_medshotsnd, 1.0, ATTN_NORM );
		m_iJuice = int( g_flTotalCharge );
		self.pev.skin = 0;
		pBottle.SetLevel( 1.0f );
		//SetThink( null );
	}

	// Based on "func_healthcharger"
	void Off()
	{
		// Stop looping sound.
		if( m_iOn > 1 )
			g_SoundSystem.StopSound( self.edict(), CHAN_ITEM, g_medchargesnd );

		IsUsed = false;
		m_iOn = 0;

		// if( m_iJuice <= 0 )
			// g_Game.AlertMessage( at_console, "Next recharge in: %1.0f s", m_flNextCharge - g_Engine.time );
	}

	// Extract BBox from sequence (ripped from CBaseAnimating with one little change)
	void SetSequenceBox()
	{
		Vector mins, maxs;

		// Get sequence bbox
		if( self.ExtractBbox( self.pev.sequence, mins, maxs ) )
		{
			if( HCHG_HACKED_BBOX )
			{
				// PS2HL - hack for GoldSource:
				// it makes no sence, but BBox should have max size of 4 in horisontal
				// axes, otherwise nearby doors and elevators can freak out
				mins.x = -4;
				maxs.x = 2;
				mins.y = -4;
				maxs.y = 4;
			}

			// expand box for rotation
			// find min / max for rotations
			float yaw = self.pev.angles.y * ( Math.PI / 180.0f );
			
			Vector xvector, yvector;
            xvector.x = cos( yaw );
            xvector.y = sin( yaw );
            yvector.x = -sin( yaw );
            yvector.y = cos( yaw );
            array<Vector> bounds( 2 );
			
			bounds[0] = mins;
            bounds[1] = maxs;
			
			Vector rmin( 9999, 9999, 9999 );
            Vector rmax( -9999, -9999, -9999 );
            Vector base, transformed;
			
			for( uint i = 0; i <= 1; i++ )
            {
                base.x = bounds[i].x;
                for( uint j = 0; j <= 1; j++ )
                {
                    base.y = bounds[j].y;
                    for( uint k = 0; k <= 1; k++ )
                    {
                        base.z = bounds[k].z;

                        // transform the point
                        transformed.x = ( xvector.x * base.x ) + ( yvector.x * base.y );
                        transformed.y = ( xvector.y * base.x ) + ( yvector.y * base.y );
                        transformed.z = base.z;
                        
                        if( transformed.x < rmin.x )
                            rmin.x = transformed.x;
                        if( transformed.x > rmax.x )
                            rmax.x = transformed.x;
                        if( transformed.y < rmin.y )
                            rmin.y = transformed.y;
                        if( transformed.y > rmax.y )
                            rmax.y = transformed.y;
                        if( transformed.z < rmin.z )
                            rmin.z = transformed.z;
                        if( transformed.z > rmax.z )
                            rmax.z = transformed.z;
                    }
                }
            }
            //rmin.z = 0;
            //rmax.z = rmin.z + 1;
            g_EntityFuncs.SetSize( self.pev, rmin, rmax );
		}
	}
}

void RegisterItemHealthCustomEntity()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "PS2HEALTHCHARGER::CHealthBottle", g_bottlename );
    g_CustomEntityFuncs.RegisterCustomEntity( "PS2HEALTHCHARGER::CItemHealthCharger", g_healthstaname );
}
