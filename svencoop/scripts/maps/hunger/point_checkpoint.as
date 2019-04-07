/*
* point_checkpoint
* This point entity represents a point in the world where players can trigger a checkpoint
* Dead players are revived
* Customized for They Hunger
*/

enum PointCheckpointFlags
{
	SF_CHECKPOINT_REUSABLE 		= 1 << 0,	//This checkpoint is reusable
}

class point_checkpoint : ScriptBaseAnimating
{
	private int m_iNextPlayerToRevive = 1;
	
	private float m_flDelayBeforeStart 			= 1.5f; //How much time between being triggered and starting the revival of dead players
	private float m_flDelayBetweenRevive 		= 1; 	//Time between player revive
	
	private float m_flDelayBeforeReactivation 	= 60; 	//How much time before this checkpoint becomes active again, if SF_CHECKPOINT_REUSABLE is set
	
	private float m_flRespawnStartTime;					//When we started a respawn
	
	private Vector m_vecLightningStart = Vector(0,0,0);
	
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
		
		if ( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( "models/hunger/umbrella.mdl" );
		else
			g_Game.PrecacheModel( self.pev.model );
		
		g_Game.PrecacheModel("sprites/lgtning.spr");
		
		g_SoundSystem.PrecacheSound( "hunger/checkpointjingle.mp3" );
		
		if( string( self.pev.message ).IsEmpty() )
			self.pev.message = "debris/beamstart15.wav";
		
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
			g_EntityFuncs.SetModel( self, "models/hunger/umbrella.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );
			
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		// Custom hull size
		if( self.pev.vuser1 != g_vecZero && self.pev.vuser2 != g_vecZero )
			g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
		else
			g_EntityFuncs.SetSize( self.pev, Vector( -64, -64, -36 ), Vector( 64, 64, 36 ) );
		
		
		SetAnim( 1 ); // set sequence to 1 aka idle_closed
		
		// If the map supports survival mode but survival is not active yet,
		// spawn disabled checkpoint
		if ( g_SurvivalMode.MapSupportEnabled() && !g_SurvivalMode.IsActive() )
		{
			SetEnabled( false );
		}
		else
		{
			SetEnabled( true );
		}
		
		SetThink( ThinkFunction( this.IdleThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		if( !IsEnabled() || IsActivated() || !pOther.IsPlayer() )
			return;
		
		g_Game.AlertMessage( at_logged, "CHECKPOINT: \"%1\" activated Checkpoint\n", pOther.pev.netname );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "" + pOther.pev.netname + " just activated a Respawn-Point.\n" );
		
		// Set activated
		self.pev.frags = 1.0f;

		if (string(self.pev.netname).IsEmpty())
		{
			TraceResult tr;
			g_EngineFuncs.MakeVectors(self.pev.angles);
			g_Utility.TraceLine(self.pev.origin, self.pev.origin+g_Engine.v_up*4096, ignore_monsters, self.edict(), tr);
			// dont care if we didint hit skybox, itll look like it came from the sky anyways
			m_vecLightningStart = tr.vecEndPos;
		}
		else
		{
			CBaseEntity@ targetEntity = null;
			while((@targetEntity = g_EntityFuncs.FindEntityByTargetname(targetEntity, string(self.pev.netname))) !is null)
			{
				m_vecLightningStart = targetEntity.pev.origin;
			}
		}
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "hunger/checkpointjingle.mp3", 1.0f, ATTN_NONE );
		
		SetAnim( 2 ); 
		
		SetThink( ThinkFunction( this.RespawnStartThink ) );
		self.pev.nextthink = g_Engine.time + m_flDelayBeforeStart;
		
		m_flRespawnStartTime = g_Engine.time;
		
		//Trigger targets
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
	
	void RespawnStartThink()
	{
		m_iNextPlayerToRevive = 1;
		SetAnim( 0 ); // set sequence to 0 aka open idle
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
					
				LightningEffect( pPlayer );
				
				//Congratulations, and celebrations, YOU'RE ALIVE!
				g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, self.pev.message, 1.0f, ATTN_NORM );
				
				m_iNextPlayerToRevive++; //Make sure to increment this to avoid unneeded loop
				break;
			}
		}
		
		//All players have been checked, close portal after 5 seconds.
		if( m_iNextPlayerToRevive > g_Engine.maxClients )
		{
			self.pev.rendermode = kRenderTransTexture;
			self.pev.renderamt = 255;
			SetThink(ThinkFunction(this.FadeThink));
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		//Another player could require reviving
		else
		{
			self.StudioFrameAdvance();
			self.pev.nextthink = g_Engine.time + m_flDelayBetweenRevive;
		}
	}
	
	void FadeThink()
	{
		if (self.pev.renderamt > 0)
		{
			self.StudioFrameAdvance();
			self.pev.renderamt -= 5;
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		else
		{
			SetThink(null);
		}
	}
	
	void ReenableThink()
	{
		if ( IsEnabled() )
		{
			//Make visible again
			self.pev.effects &= ~EF_NODRAW;
		}
		
		self.pev.frags = 0.0f;
		
		SetAnim( 1 ); // set sequence to 1 aka idle_closed
		
		SetThink( ThinkFunction( this.IdleThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
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
	
	void LightningEffect( CBasePlayer@ pPlayer )
	{
		NetworkMessage message(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
			message.WriteByte(TE_BEAMPOINTS);
			message.WriteCoord(m_vecLightningStart.x);
			message.WriteCoord(m_vecLightningStart.y);
			message.WriteCoord(m_vecLightningStart.z);
			message.WriteCoord(pPlayer.pev.origin.x);
			message.WriteCoord(pPlayer.pev.origin.y);
			message.WriteCoord(pPlayer.pev.origin.z);
			message.WriteShort(g_EngineFuncs.ModelIndex("sprites/lgtning.spr"));
			message.WriteByte(0);
			message.WriteByte(20);	// framerate
			message.WriteByte(1);	// life
			message.WriteByte(24);	// width
			message.WriteByte(80);	// noise
			message.WriteByte(172);	// colors
			message.WriteByte(255); 
			message.WriteByte(255); 
			message.WriteByte(255);	// brightness
			message.WriteByte(0);	// scroll
		message.End();
	}

}

void RegisterPointCheckPointEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "point_checkpoint", "point_checkpoint" );
}
