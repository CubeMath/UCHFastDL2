/*
* point_checkpoint
* This point entity represents a point in the world where players can trigger a checkpoint
* Dead players are revived
*/

enum PointCheckpointFlags
{
	SF_CHECKPOINT_REUSABLE 		= 1 << 0,	//This checkpoint is reusable
}

class point_checkpoint : ScriptBaseAnimating
{
	private CSprite@ m_pSprite;
	private int m_iNextPlayerToRevive = 1;
	
	// How much time between being triggered and starting the revival of dead players
	private float m_flDelayBeforeStart 			= 3;
	
	// Time between player revive
	private float m_flDelayBetweenRevive 		= 1;
	
	// How much time before this checkpoint becomes active again, if SF_CHECKPOINT_REUSABLE is set
	private float m_flDelayBeforeReactivation 	= 60; 	
	
	// When we started a respawn
	private float m_flRespawnStartTime;					
	
	// Show Xenmaker-like effect when the checkpoint is spawned?
	private bool m_fSpawnEffect					= false; 
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "m_flDelayBeforeStart" )
		{
			m_flDelayBeforeStart = atof( szValue );
			return true;
		}
		else if( szKey == "m_flDelayBetweenRevive" )
		{
			m_flDelayBetweenRevive = atof( szValue );
			return true;
		}
		else if( szKey == "m_flDelayBeforeReactivation" )
		{
			m_flDelayBeforeReactivation = atof( szValue );
			return true;
		}
		else if( szKey == "minhullsize" )
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		}
		else if( szKey == "maxhullsize" )
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else if( szKey == "m_fSpawnEffect" )
		{
			m_fSpawnEffect = atoi( szValue ) != 0;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	// If youre gonna use this in your script, make sure you don't try
	// to access invalid animations. -zode
	void SetAnim( int animIndex ) 
	{
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	
	void Precache()
	{
		BaseClass.Precache();
		
		// Allow for custom models
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( "models/common/lambda.mdl" );
		else
			g_Game.PrecacheModel( self.pev.model );
		
		g_Game.PrecacheModel( "sprites/exit1.spr" );
		
		g_SoundSystem.PrecacheSound( "../media/valve.mp3" );
		g_SoundSystem.PrecacheSound( "debris/beamstart7.wav" );
		g_SoundSystem.PrecacheSound( "ambience/port_suckout1.wav" );
		
		if( string( self.pev.message ).IsEmpty() )
			self.pev.message = "debris/beamstart4.wav";
			
		g_SoundSystem.PrecacheSound( self.pev.message );
	}
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_TRIGGER;
		
		self.pev.framerate 		= 1.0f;
		
		// Enabled by default
		self.pev.health			= 1.0f;
		
		// Not activated by default
		self.pev.frags			= 0.0f;
		
		// Allow for custom models
		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/common/lambda.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		// Custom hull size
		if( self.pev.vuser1 != g_vecZero && self.pev.vuser2 != g_vecZero )
			g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
		else
			g_EntityFuncs.SetSize( self.pev, Vector( -8, -8, -16 ), Vector( 8, 8, 16 ) );
			
		SetAnim( 0 ); // set sequence to 0 aka idle
			
		// If the map supports survival mode but survival is not active yet,
		// spawn disabled checkpoint
		if ( g_SurvivalMode.MapSupportEnabled() && !g_SurvivalMode.IsActive() )
			SetEnabled( false );
		else
			SetEnabled( true );
		
		if ( IsEnabled() )
		{
			// Fire netname entity on spawn (if specified and checkpoint is enabled)
			if ( !string( self.pev.netname ).IsEmpty() )
				g_EntityFuncs.FireTargets( self.pev.netname, self, self, USE_TOGGLE );
				
			// Create Xenmaker-like effect
			if ( m_fSpawnEffect )
				CreateSpawnEffect();
		}
		
		SetThink( ThinkFunction( this.IdleThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void CreateSpawnEffect()
	{
		int iBeamCount = 8;
		Vector vBeamColor = Vector(217,226,146);
		int iBeamAlpha = 128;
		float flBeamRadius = 256;

		Vector vLightColor = Vector(39,209,137);
		float flLightRadius = 160;

		Vector vStartSpriteColor = Vector(65,209,61);
		float flStartSpriteScale = 1.0f;
		float flStartSpriteFramerate = 12;
		int iStartSpriteAlpha = 255;

		Vector vEndSpriteColor = Vector(159,240,214);
		float flEndSpriteScale = 1.0f;
		float flEndSpriteFramerate = 12;
		int iEndSpriteAlpha = 255;

		// create the clientside effect

		NetworkMessage msg( MSG_PVS, NetworkMessages::TE_CUSTOM, pev.origin );
			msg.WriteByte( 2 /*TE_C_XEN_PORTAL*/ );
			msg.WriteVector( pev.origin );
			// for the beams
			msg.WriteByte( iBeamCount );
			msg.WriteVector( vBeamColor );
			msg.WriteByte( iBeamAlpha );
			msg.WriteCoord( flBeamRadius );
			// for the dlight
			msg.WriteVector( vLightColor );
			msg.WriteCoord( flLightRadius );
			// for the sprites
			msg.WriteVector( vStartSpriteColor );
			msg.WriteByte( int( flStartSpriteScale*10 ) );
			msg.WriteByte( int( flStartSpriteFramerate ) );
			msg.WriteByte( iStartSpriteAlpha );
			
			msg.WriteVector( vEndSpriteColor );
			msg.WriteByte( int( flEndSpriteScale*10 ) );
			msg.WriteByte( int( flEndSpriteFramerate ) );
			msg.WriteByte( iEndSpriteAlpha );
		msg.End();
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		if( !IsEnabled() || IsActivated() || !pOther.IsPlayer() )
			return;
		
		g_Game.AlertMessage( at_logged, "CHECKPOINT: \"%1\" activated Checkpoint\n", pOther.pev.netname );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "" + pOther.pev.netname + " just activated a Respawn-Point.\n" );
		
		// Set activated
		self.pev.frags = 1.0f;
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "../media/valve.mp3", 1.0f, ATTN_NONE );

		self.pev.rendermode		= kRenderTransTexture;
		self.pev.renderamt		= 255;
		
		SetThink( ThinkFunction( this.FadeThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
		
		// Trigger targets
		self.SUB_UseTargets( pOther, USE_TOGGLE, 0 );
	}
	
	bool IsEnabled() const { return self.pev.health != 0.0f; }
	
	bool IsActivated() const { return self.pev.frags != 0.0f; }
	
	void SetEnabled( const bool bEnabled )
	{
		if( bEnabled == IsEnabled() )
			return;
		
		if ( bEnabled && !IsActivated() )
			self.pev.effects &= ~EF_NODRAW;
		else
			self.pev.effects |= EF_NODRAW;
		
		self.pev.health = bEnabled ? 1.0f : 0.0f;
	}
	
	// GeckoN: Idle Think - just to make sure the animation gets updated properly.
	// Should fix the "checkpoint jitter" issue.
	void IdleThink()
	{
		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void FadeThink()
	{
		if ( self.pev.renderamt > 0 )
		{
			self.StudioFrameAdvance();
			
			self.pev.renderamt -= 30;
			if ( self.pev.renderamt < 0 )
				self.pev.renderamt = 0;
			
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		else
		{
			SetThink( ThinkFunction( this.RespawnStartThink ) );
			self.pev.nextthink = g_Engine.time + m_flDelayBeforeStart;
			
			m_flRespawnStartTime = g_Engine.time;
		
			// Make this entity invisible
			self.pev.effects |= EF_NODRAW;
			
			self.pev.renderamt = 255;
		}
	}
	
	void RespawnStartThink()
	{
		//Clean up the old sprite if needed
		if( m_pSprite !is null )
			g_EntityFuncs.Remove( m_pSprite );
		
		m_iNextPlayerToRevive = 1;
		
		@m_pSprite = g_EntityFuncs.CreateSprite( "sprites/exit1.spr", self.pev.origin, true, 10 );
		m_pSprite.TurnOn();
		m_pSprite.pev.rendermode = kRenderTransAdd;
		m_pSprite.pev.renderamt = 128;
	
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "debris/beamstart7.wav", 1.0f, ATTN_NORM );
		
		SetThink( ThinkFunction( this.RespawnThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	//Revives 1 player every m_flDelayBetweenRevive seconds, if any players need reviving.
	void RespawnThink()
	{
		CBasePlayer@ pPlayer;
		
		for( ; m_iNextPlayerToRevive <= g_Engine.maxClients; ++m_iNextPlayerToRevive )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( m_iNextPlayerToRevive );
			
			//Only respawn if the player died before this checkpoint was activated
			//Prevents exploitation
			if( pPlayer !is null && pPlayer.IsConnected() && !pPlayer.IsAlive() && pPlayer.m_fDeadTime < m_flRespawnStartTime )
			{
				//Revive player and move to this checkpoint
				pPlayer.GetObserver().RemoveDeadBody();
				pPlayer.SetOrigin( self.pev.origin );
				pPlayer.Revive();
				
				//Call player equip
				//Only disable default giving if there are game_player_equip entities in give mode
				CBaseEntity @pEquipEntity = null;
				while ( ( @pEquipEntity = g_EntityFuncs.FindEntityByClassname( pEquipEntity, "game_player_equip" ) ) !is null  )
					pEquipEntity.Touch( pPlayer );
					
				//Congratulations, and celebrations, YOU'RE ALIVE!
				g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, self.pev.message, 1.0f, ATTN_NORM );
				
				++m_iNextPlayerToRevive; //Make sure to increment this to avoid unneeded loop
				break;
			}
		}
		
		//All players have been checked, close portal after 5 seconds.
		if( m_iNextPlayerToRevive > g_Engine.maxClients )
		{
			SetThink( ThinkFunction( this.StartKillSpriteThink ) );
			
			self.pev.nextthink = g_Engine.time + 5.0f;
		}
		//Another player could require reviving
		else
		{
			self.pev.nextthink = g_Engine.time + m_flDelayBetweenRevive;
		}
	}
	
	void StartKillSpriteThink()
	{
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "ambience/port_suckout1.wav", 1.0f, ATTN_NORM );
		
		SetThink( ThinkFunction( this.KillSpriteThink ) );
		self.pev.nextthink = g_Engine.time + 3.0f;
	}
	
	void CheckReusable()
	{
		if( self.pev.SpawnFlagBitSet( SF_CHECKPOINT_REUSABLE ) )
		{
			SetThink( ThinkFunction( this.ReenableThink ) );
			self.pev.nextthink = g_Engine.time + m_flDelayBeforeReactivation;
		}
		else
			SetThink( null );
	}
	
	void KillSpriteThink()
	{
		if( m_pSprite !is null )
		{
			g_EntityFuncs.Remove( m_pSprite );
			@m_pSprite = null;
		}
		
		CheckReusable();
	}
	
	void ReenableThink()
	{
		if ( IsEnabled() )
		{
			//Make visible again
			self.pev.effects &= ~EF_NODRAW;
		}
		
		self.pev.frags = 0.0f;
		
		SetThink( ThinkFunction( this.RespawnThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}

void RegisterPointCheckPointEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "point_checkpoint", "point_checkpoint" );
}