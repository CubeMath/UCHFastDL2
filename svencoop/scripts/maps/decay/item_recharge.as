// PS2HL Suit Charger Station
// Based on from https://github.com/supadupaplex/ya-ps2hl-dll

// namespace PS2RECHARGE
// {
// Models
const string g_glassmodel = "models/decay/hev_glass.mdl";
const string g_hevchargermodel = "models/decay/hev.mdl";
const string g_suitchargesnd = "items/suitcharge1.wav";
const string g_suitchargenosnd = "items/suitchargeno1.wav";
const string g_suitchargeoksnd = "items/suitchargeok1.wav";
const string g_plasmaspr = "sprites/plasma.spr";

// Ents
const string g_glassname = "item_recharge_glass";
const string g_rechargestaname = "item_recharge";

// Custom defines
const float flHEVChargerRechargeTime = 60.0f;
const float g_flSuitchargerCapacity = g_EngineFuncs.CVarGetFloat( "sk_suitcharger" );

// Defines
const float RCHG_DELAY_THINK		= 0.1f;		// Think delay
const float RCHG_ACTIVE_RADIUS		= 70.0f;	// Distance at which charger is deployed
const float RCHG_USE_RADIUS		= 50.0f;	// Defines distance at which player can use charger
const uint RCHG_GLASS_TRANSPARENCY	= 128;		// Glass transparency (0 - max, 255 - min)
const bool RCHG_ACTIVATE_SOUND		= true;		// Play sound on activate (like in PS2 version)
const bool RCHG_SUIT_CHECK			= false;	// If defined then charger would not deploy for HEVless players (not present in PS2 version)
const bool RCHG_NO_BACK_USE			= true;		// Prevent usage from the back side (like in PS2 version)
const bool	RCHG_HACKED_BBOX		= true;		// BBox hack for GoldSource


//================================
// Charger itself
//================================

// Sequences
enum RechargeSeq
{
	RCHG_SEQ_IDLE =	0,	// "rest"
	RCHG_SEQ_DEPLOY,	// "deploy"
	RCHG_SEQ_HIBERNATE,	// "retract_arm"
	RCHG_SEQ_EXPAND,	// "give_charge"
	RCHG_SEQ_RETRACT,	// "retract_charge"
	RCHG_SEQ_RDY,		// "prep_charge"
	RCHG_SEQ_USE		// "charge_idle"
};

// Controllers
const uint RCHG_CTRL_CAM	= 0;	// Camera
const uint RCHG_CTRL_LCOIL	= 1;	// Left coil
const uint RCHG_CTRL_RCOIL 	= 2;	// Right coil
const uint RCHG_CTRL_ARM	= 3;	// Arm

const float RCHG_CTRL_COILS_MIN	= 0.0f;		// Coil controller min angle
const float RCHG_CTRL_COILS_MAX	= 360.0f;	// Coil controller max angle
const float RCHG_CTRL_COILS_SPEED	= 30.0f;	// Coil rotation speed (depends on think delay)

// Attachments
const uint RCHG_ATCH_BEAM_START 	= 3;
const uint RCHG_ATCH_BEAM_END		= 4;

// States
enum RechargeState
{
	RCHG_STATE_IDLE = 0,	// No player near by, wait
	RCHG_STATE_ACTIVATE,	// Player is near - deploy
	RCHG_STATE_READY,		// Player is near and deployed - rotate arm to player position
	RCHG_STATE_START,		// Player hit use - expand arm
	RCHG_STATE_USE,			// Give charge
	RCHG_STATE_STOP,		// Player stopped using - retract arm, continue tracking
	RCHG_STATE_DEACTIVATE,	// PLayer went away - hibernate, reset arm position
	RCHG_STATE_EMPTY		// Charger is empty (dead end state in SP, wait for recharge in MP)
};

//================================
// Glass for charger
//================================

class CChargerGlass : ScriptBaseAnimating
{
	void Precache()
	{
		g_Game.PrecacheModel( g_glassmodel );
	}
    
	void Spawn()
	{
		// Precache
		Precache();

		// Set model
		g_EntityFuncs.SetModel( self, g_glassmodel );

		// Properties
		self.pev.movetype = MOVETYPE_FLY;
	//	self.pev.classname = g_glassname;
		self.pev.solid = SOLID_NOT;

		// BBox
		Vector Zero;
		Zero.x = Zero.y = Zero.z = 0;
		g_EntityFuncs.SetSize( self.pev, Zero, Zero );

		// Visuals
		self.pev.rendermode = kRenderTransTexture;		// Mode with transparency
		self.pev.renderamt = RCHG_GLASS_TRANSPARENCY;	// Transparency amount

		// Default animation
		self.pev.sequence = RCHG_SEQ_IDLE;
		self.pev.frame = 0;
	}

	int ObjectCaps() 
    {
        return BaseClass.ObjectCaps() & ~FCAP_ACROSS_TRANSITION;
    }
}

//================================
// Charger itself
//================================

// Methods //
class CItemRecharge : ScriptBaseAnimating
{
	// From "func_recharge"
	float m_flNextCharge;
	int m_iReactivate;		// DeathMatch Delay until reactvated
	int m_iJuice;			// How much charge left
	int m_iOn;				// 0 = off, 1 = startup, 2 = going
	float m_flSoundTime;

	// New
	private bool IsUsed;					// Needed to track if charger is used
	private bool IsFrontAngle;				// Needed to track if player is in front or in back side of the charger
	private RechargeState CurrentState;	// Current state of the charger
	private float CoilsAngle;				// Current coils angle
	private CChargerGlass@ pGlass;			// Ptr. for glass
	//private EHandle m_hActivator;

	void Precache()
	{
		// Precache model
		g_Game.PrecacheModel( g_hevchargermodel );

		// Precache sounds
		g_SoundSystem.PrecacheSound( g_suitchargesnd );
		g_SoundSystem.PrecacheSound( g_suitchargenosnd );
		g_SoundSystem.PrecacheSound( g_suitchargeoksnd );

		// Precache sprite
		g_Game.PrecacheModel( g_plasmaspr );
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
		g_EntityFuncs.SetModel( self, g_hevchargermodel );
		
		// Set up BBox and origin
		self.pev.solid = SOLID_BBOX;//SOLID_TRIGGER;
		SetSequenceBox();
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		// Reset bone controllers
		self.InitBoneControllers();
		RotateCamArm( null );
		CoilsAngle = 0;
		RotateCoils();

		// Set move type
		//self.pev.movetype = MOVETYPE_PUSH;	// This was default for "func_recharge", but it breaks "nextthink" and bone controllers
		//self.pev.movetype = MOVETYPE_NONE;	// No bone controller interpolation in GoldSrc (but OK in Xash)
		self.pev.movetype = MOVETYPE_FLY;		// This type enables bone controller interpolation in GoldSrc

		// Get initial charge
		m_iJuice = int( g_flSuitchargerCapacity );

		// Set "on" skin
		self.pev.skin = 0;

		// Reset state
		ChangeState( RCHG_STATE_IDLE, RCHG_SEQ_IDLE );

		// Spawn glass entity
		CBaseEntity@ pGlassEnt = g_EntityFuncs.CreateEntity( g_glassname, null, false );
		@pGlass = cast<CChargerGlass@>(CastToScriptClass(@pGlassEnt));

		if ( pGlass is null )
			return;

		pGlass.Spawn();
		g_EntityFuncs.SetOrigin( pGlass.self, self.pev.origin );
		pGlass.pev.angles = self.pev.angles;
		@pGlass.pev.owner = @self.edict();

		// Set think delay
		self.pev.nextthink = g_Engine.time + RCHG_DELAY_THINK;
	}

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "style" ||
			szKey == "height" ||
			szKey == "value1" ||
			szKey == "value2" ||
			szKey == "value3" )
		{
			return true;
		}
		else if ( szKey == "dmdelay" )
		{
			m_iReactivate = atoi( szValue );
			return true;
		}
		else
			 return BaseClass.KeyValue( szKey, szValue );
	}

	void Think()
	{
		// Debug: show bounding box
		//DBG_RenderBBox( self.pev.origin, self.pev.mins, self.pev.maxs, int16( Math.Ceil( RCHG_DELAY_THINK / 0.1 ) ), 0xFF, 0x00, 0x00 ) );

		// Get current time
		float CurrentTime = g_Engine.time;

		// Set delay for next think
		self.pev.nextthink = CurrentTime + RCHG_DELAY_THINK;

		// Call animation handler
		self.StudioFrameAdvance( 0 );

		// DEBUG
		//static float LastTime = 0;
		//self.pev.nextthink = g_Engine.time + RCHG_DELAY_THINK;
		//string szMessage;
		//snprintf( szMessage, "Next: %1.1f \nReal: %2f\n", self.pev.nextthink - g_Engine.time, g_Engine.time - LastTime ); 
		//g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, szMessage ); // Message
		//LastTime = g_Engine.time;

		// Rotate coils
		if ( IsUsed )
		{
			CoilsAngle += RCHG_CTRL_COILS_SPEED;
			RotateCoils();
		}

		// Find player
		CBaseEntity@ pPlayer = FindPlayer( RCHG_ACTIVE_RADIUS );

		// Track player
		if ( CurrentState != RCHG_STATE_EMPTY && CurrentState != RCHG_STATE_DEACTIVATE )
			RotateCamArm( @pPlayer );
		else
			RotateCamArm( null );
		
		// State handler
		switch ( CurrentState )
		{
		case RCHG_STATE_IDLE:
			// Player found?
			if ( pPlayer !is null )
			{
				// Player is near

				// Prevent back side usage
				if ( RCHG_NO_BACK_USE && !IsFrontAngle )
					return;

				// Prevent deployment if player doesn't have HEV
				if ( RCHG_SUIT_CHECK && !(cast<CBasePlayer@>(pPlayer).HasSuit()) )
				{
					RotateCamArm( null );
					return;
				}

				// Emit sound
				if ( RCHG_ACTIVATE_SOUND )
					g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_suitchargeoksnd, 0.85, ATTN_NORM );

				// Change state
				// g_Game.AlertMessage( at_console, "item_recharge: activate\n" );
				ChangeState( RCHG_STATE_ACTIVATE, RCHG_SEQ_DEPLOY );
			}
			break;
		case RCHG_STATE_ACTIVATE:
			// Just wait until animation is played
			if ( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_recharge: ready\n" );
				ChangeState( RCHG_STATE_READY, RCHG_SEQ_RDY );
			}
			break;
		case RCHG_STATE_READY:
			// Show beam
			MakeBeam();

			// Player is near?
			if ( pPlayer is null )
			{
				// Nobody is near, hibernate
				// g_Game.AlertMessage( at_console, "item_recharge: deactivate\n" );
				ChangeState( RCHG_STATE_DEACTIVATE, RCHG_SEQ_HIBERNATE );
			}
			else
			{
				// Prevent back side usage
				if ( RCHG_NO_BACK_USE && !IsFrontAngle )
				{
					ChangeState( RCHG_STATE_DEACTIVATE, RCHG_SEQ_HIBERNATE );
					return;
				}
				
				// Check if used
				if ( IsUsed )
				{
					// g_Game.AlertMessage( at_console, "item_recharge: used\n" );
					ChangeState( RCHG_STATE_START, RCHG_SEQ_EXPAND );
				}
			}
			break;
		case RCHG_STATE_START:
			// Show beam
			MakeBeam();

			// Just wait until animation is played
			if ( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_recharge: giving charge\n" );
				ChangeState( RCHG_STATE_USE, RCHG_SEQ_USE );
			}
			break;
		case RCHG_STATE_USE:
			// Show beam
			MakeBeam();

			if ( !IsUsed )
			{
				// No longer used - change state
				// g_Game.AlertMessage( at_console, "item_recharge: stopping\n" );
				ChangeState( RCHG_STATE_STOP, RCHG_SEQ_RETRACT );
			}

			// Reset use flag
			IsUsed = false;
			break;
		case RCHG_STATE_STOP:
			// Show beam
			MakeBeam();

			// Just wait until animation is played
			if ( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_recharge: ready\n" );
				Off();
				ChangeState( RCHG_STATE_READY, RCHG_SEQ_RDY );
			}
			break;
		case RCHG_STATE_DEACTIVATE:
			// Just wait until animation is played
			if ( self.m_fSequenceFinished )
			{
				// g_Game.AlertMessage( at_console, "item_recharge: to idle\n" );
				ChangeState( RCHG_STATE_IDLE, RCHG_SEQ_IDLE );
			}
			break;
		case RCHG_STATE_EMPTY:
			// Swap animation to hibernate
			if ( self.pev.sequence == RCHG_SEQ_RETRACT && self.m_fSequenceFinished )
				ChangeSequence( RCHG_SEQ_HIBERNATE );

			// Swap animation to idle
			if ( self.pev.sequence == RCHG_SEQ_HIBERNATE && self.m_fSequenceFinished )
				ChangeSequence( RCHG_SEQ_IDLE );

			// Wait for next recharge (multiplayer)
			if ( m_flNextCharge != -1 && CurrentTime > m_flNextCharge )
			{
				Recharge();
				ChangeState( RCHG_STATE_IDLE, RCHG_SEQ_IDLE );
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

	void ChangeState( RechargeState NewState, int NewSequence )
	{
		CurrentState = NewState;
		//CurrentStateTime = g_Engine.time;	// I found no use for it so far
		ChangeSequence( NewSequence );
	}

	void RotateCamArm( CBaseEntity@ pPlayer )
	{
		float Angle;
		Vector ChToPl;

		if ( pPlayer !is null )
		{
			// Calculate angle
			ChToPl.x = self.pev.origin.x - pPlayer.pev.origin.x;
			ChToPl.y = self.pev.origin.y - pPlayer.pev.origin.y;
			ChToPl.z = self.pev.origin.z - pPlayer.pev.origin.z;
			ChToPl = Math.VecToAngles( ChToPl );
			Angle = ChToPl.y - self.pev.angles.y + 180;	// +180 - because player actually faces back side of the charger model

			// Angle correction
			if ( Angle > 180 )
			{
				while ( Angle > 180 )
					Angle -= 360;
			}
			else if ( Angle < -180 )
			{
				while ( Angle < -180 )
					Angle += 360;
			}

			if ( RCHG_NO_BACK_USE )
			{
				// Check if player is on front or in the back of the charger
				if (-90 > Angle || Angle > 90)
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

		self.SetBoneController( RCHG_CTRL_ARM, Angle );
		self.SetBoneController( RCHG_CTRL_CAM, Angle );
	}

	void RotateCoils()
	{
		if ( CoilsAngle > RCHG_CTRL_COILS_MAX )
			CoilsAngle -= 360.0f;
		else if ( CoilsAngle < RCHG_CTRL_COILS_MIN )
			CoilsAngle += 360.0f;//float CoilPos = float( m_iJuice ) / int( g_flSuitchargerCapacity ) * RCHG_COIL_SPEED;
		
		self.SetBoneController( RCHG_CTRL_LCOIL, CoilsAngle );
		self.SetBoneController( RCHG_CTRL_RCOIL, RCHG_CTRL_COILS_MAX - CoilsAngle );
		//// g_Game.AlertMessage( at_console, "item_recharge: coil angle: %1.1f\n", CoilPos );
	}

	// Show beam for one Think() cycle
	void MakeBeam()
	{
		// Spawn beam
		CBeam@ pBeam;
		//@pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 64 );
		@pBeam = g_EntityFuncs.CreateBeam( g_plasmaspr, 64 );
		
		if ( pBeam is null )
			return;

		// Link attachments
		pBeam.EntsInit( self.entindex(), self.entindex() );
		pBeam.SetStartAttachment( RCHG_ATCH_BEAM_START );
		pBeam.SetEndAttachment( RCHG_ATCH_BEAM_END );

		// Visual properties
		pBeam.SetColor( 64, 255, 64 );
		pBeam.SetBrightness( 128 );
		pBeam.SetWidth( 3 );
		pBeam.SetNoise( 5 );
		pBeam.SetScrollRate( 30 );
	//	pBeam.SetThink( ThinkFunction( pBeam.SUB_Remove ) ); // Used LiveForTime instead
		
		// Remove on the next think cycle
	//	pBeam.pev.nextthink = g_Engine.time + RCHG_DELAY_THINK;

		pBeam.LiveForTime( RCHG_DELAY_THINK );
	}

	CBaseEntity@ FindPlayer( float Radius )
	{
		CBaseEntity@ pPlayer = null;	// Result
		CBaseEntity@ pEntity = null;	// Used for search

		// Find near entities
		while ( ( @pEntity = g_EntityFuncs.FindEntityInSphere( pEntity, self.pev.origin, RCHG_ACTIVE_RADIUS, "player", "classname" ) ) !is null )
		{
			if ( pEntity.IsPlayer() )
			{
				// Found player - prepare result and terminate search
				@pPlayer = @pEntity;
				break;
			}
		}

		// Return result
		return pPlayer;
	}

	// Based on "func_recharge"
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		// Make sure that we have a caller
		if ( pActivator is null )
			return;

		// if it's not a player, ignore
		if ( !pActivator.IsPlayer() )
			return;

		if ( RCHG_NO_BACK_USE )
		{
			// PS2HL - prevent back side usage
			if ( !IsFrontAngle )
				return;
		}
		
		if ( RCHG_NO_BACK_USE )
		{
			// Check distance
			Vector Dist = self.pev.origin - pActivator.pev.origin;
			if ( Dist.Length2D() > RCHG_USE_RADIUS )
			{
				// g_Game.AlertMessage( at_console, "item_recharge: player is too far ...\n" );
				return;
			}
		}

		// if there is no juice left, turn it off
		if ( m_iJuice <= 0 )
		{
			// PS2HL
			// g_Game.AlertMessage( at_console, "item_recharge: empty\n" );
			self.pev.skin = 1;
			Off();
			if ( CurrentState != RCHG_STATE_EMPTY )
			{
				ChangeState( RCHG_STATE_EMPTY, RCHG_SEQ_RETRACT );

				// Set up recharge
				if ( ( m_iJuice <= 0 ) && ( ( m_iReactivate = flHEVChargerRechargeTime ) > 0 ) )
					m_flNextCharge = g_Engine.time + m_iReactivate;
				else
					m_flNextCharge = -1;	// No recharge
			}
		}

		// if the player doesn't have the suit, or there is no juice left, make the deny noise
		if ( ( m_iJuice <= 0 ) || ( !( cast<CBasePlayer@>(pActivator).HasSuit() ) ) )
		{
			if ( m_flSoundTime <= g_Engine.time )
			{
				m_flSoundTime = g_Engine.time + 0.62;
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_suitchargenosnd, 0.85, ATTN_NORM );
			}
			return;
		}

		//=============
		// PS2HL
		//=============
		// Speed up deploy if used early
		if ( CurrentState != RCHG_STATE_START && CurrentState != RCHG_STATE_USE )
			ChangeState( RCHG_STATE_START, RCHG_SEQ_EXPAND );
		
		// Set use flag
		IsUsed = true;
		//=============


		//self.pev.nextthink = self.pev.ltime + 0.25;
		//SetThink( this.Off );

		// Time to recharge yet?
		if ( m_flNextCharge >= g_Engine.time )
			return;

		// Make sure that we have a caller
		if ( pActivator is null )
			return;

		//m_hActivator = EHandle( pActivator );

		//only recharge the player

		if ( !pActivator.IsPlayer() )
			return;

		// Play the on sound or the looping charging sound
		if ( m_iOn <= 0 )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, g_suitchargeoksnd, 0.85, ATTN_NORM );
			m_flSoundTime = 0.56 + g_Engine.time;
		}
		if ( ( m_iOn == 1 ) && ( m_flSoundTime <= g_Engine.time ) )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, g_suitchargesnd, 0.85, ATTN_NORM );
		}


		// charge the player
		if ( pActivator.pev.armorvalue < 100 )
		{
			m_iJuice--;
			pActivator.pev.armorvalue += 1;

			if ( pActivator.pev.armorvalue > 100 )
				pActivator.pev.armorvalue = 100;
		}

		// govern the rate of charge
		m_flNextCharge = g_Engine.time + 0.1;
	}

	// Based on "func_recharge"
	void Recharge()
	{
		m_iJuice = int( g_flSuitchargerCapacity );
		self.pev.skin = 0;
	//	SetThink(&CBaseEntity::SUB_DoNothing);
		SetThink( null );
	}

	// Based on "func_recharge"
	void Off()
	{
		// Stop looping sound.
		if ( m_iOn > 1 )
			g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, g_suitchargesnd );

		IsUsed = false;
		m_iOn = 0;

		// if ( m_iJuice <= 0 )
			// g_Game.AlertMessage( at_console, "Next recharge in: %1 s\n", m_flNextCharge - g_Engine.time );
	}

	// Extract BBox from sequence (ripped from CBaseAnimating with one little change)
	void SetSequenceBox()
	{
		Vector mins, maxs;

		// Get sequence bbox
		if ( self.ExtractBbox( self.pev.sequence, mins, maxs ) )
		{
			if ( RCHG_HACKED_BBOX )
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
			yvector.y = cos( yaw) ;
			array<Vector> bounds( 2 );

			bounds[0] = mins;
			bounds[1] = maxs;

			Vector rmin( 9999, 9999, 9999 );
			Vector rmax( -9999, -9999, -9999 );
			Vector base, transformed;

			for ( uint i = 0; i <= 1; i++ )
			{
				base.x = bounds[i].x;
				for ( uint j = 0; j <= 1; j++ )
				{
					base.y = bounds[j].y;
					for ( uint k = 0; k <= 1; k++ )
					{
						base.z = bounds[k].z;

						// transform the point
						transformed.x = ( xvector.x * base.x ) + ( yvector.x * base.y );
						transformed.y = ( xvector.y * base.x ) + ( yvector.y * base.y );
						transformed.z = base.z;

						if ( transformed.x < rmin.x )
							rmin.x = transformed.x;
						if ( transformed.x > rmax.x )
							rmax.x = transformed.x;
						if ( transformed.y < rmin.y )
							rmin.y = transformed.y;
						if ( transformed.y > rmax.y )
							rmax.y = transformed.y;
						if ( transformed.z < rmin.z )
							rmin.z = transformed.z;
						if ( transformed.z > rmax.z )
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
/*
void DBG_RenderBBox( Vector origin, Vector mins, Vector maxs, int16 life, uint8 r, uint8 b, uint8 g )
{
	//********************Render boundarybox**************************

	NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
		msg.WriteByte( TE_BOX );
		msg.WriteCoord( origin.x + mins.x );
		msg.WriteCoord( origin.y + mins.y );
		msg.WriteCoord( origin.z + mins.z );
		msg.WriteCoord( origin.x + maxs.x );
		msg.WriteCoord( origin.y + maxs.y );
		msg.WriteCoord( origin.z + maxs.z );
		msg.WriteShort( life ); // life in 0.1 s
		msg.WriteByte( r ); // r, g, b
		msg.WriteByte( g ); // r, g, b
		msg.WriteByte( b );// r, g, b
	msg.End();  // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
*/
void RegisterItemRechargeCustomEntity()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "PS2RECHARGE::CChargerGlass", g_glassname );
    g_CustomEntityFuncs.RegisterCustomEntity( "PS2RECHARGE::CItemRecharge", g_rechargestaname );
}

// }
