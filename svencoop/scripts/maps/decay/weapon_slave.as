/*  
* The original Half-Life version of the mp5
*/

enum ISlaveWeaponAnimation
{
  ISLWEP_IDLE1 = 0,
  ISLWEP_IDLE2,
  ISLWEP_ATTACK1_HIT,
  ISLWEP_ATTACK1_MISS,
  ISLWEP_ATTACK2_MISS,
  ISLWEP_ATTACK2_HIT,
  ISLWEP_ATTACK3_MISS,
  ISLWEP_ATTACK3_HIT,
  ISLWEP_CHARGE,
  ISLWEP_CHARGE_LOOP,
  ISLWEP_ZAP,
  ISLWEP_RETURN,
};

class weapon_slave : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	float m_flChargeTime;
	TraceResult m_trHit;
	int m_iSwing;
	int m_iMode;
	
	void Spawn(){
		Precache();
		g_EntityFuncs.SetModel( self, "models/decay/w_slave.mdl" );
		
    m_iMode = 0;
    m_flChargeTime = -1.0f;
    
		self.FallInit();
	}

	void Precache(){
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "sprites/lgtning.spr" );
		g_Game.PrecacheModel( "models/decay/v_slave.mdl" );
		g_Game.PrecacheModel( "models/decay/w_slave.mdl" );
		g_Game.PrecacheModel( "models/decay/p_slave.mdl" );
		
		g_SoundSystem.PrecacheSound( "debris/zap1.wav" );
		g_SoundSystem.PrecacheSound( "debris/zap4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/electro4.wav" );
    g_SoundSystem.PrecacheSound( "hassault/hw_shoot1.wav" );
    g_SoundSystem.PrecacheSound( "zombie/zo_pain2.wav" );
    g_SoundSystem.PrecacheSound( "headcrab/hc_headbite.wav" );
    g_SoundSystem.PrecacheSound( "weapons/cbar_miss1.wav" );
	  g_SoundSystem.PrecacheSound( "zombie/claw_strike1.wav" );
	  g_SoundSystem.PrecacheSound( "zombie/claw_strike2.wav" );
	  g_SoundSystem.PrecacheSound( "zombie/claw_strike3.wav" );
	  g_SoundSystem.PrecacheSound( "zombie/claw_miss1.wav" );
	  g_SoundSystem.PrecacheSound( "zombie/claw_miss2.wav" );
	}

	bool GetItemInfo( ItemInfo& out info ){
		info.iMaxAmmo1 	= -1;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 		= 0;
		info.iPosition 	= 7;
		info.iFlags 	= 0;
		info.iWeight 	= 100;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer ){
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
			
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
    
    pPlayer.pev.armortype = 0;
    
		return true;
	}
	
	bool Deploy(){
		return self.DefaultDeploy(
				self.GetV_Model( "models/decay/v_slave.mdl" ),
				self.GetP_Model( "models/decay/p_slave.mdl" ), ISLWEP_IDLE1, "mp5"
		);
	}
	
	void Holster(int skiplocal){
		BaseClass.Holster( skiplocal );
	}
	
	
	void PrimaryAttack()
	{
		if( !Swing( 1 ) )
		{
			SetThink( ThinkFunction( this.SwingAgain ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}
	
	void Smack()
	{
		g_WeaponFuncs.DecalGunshot( m_trHit, BULLET_PLAYER_CROWBAR );
	}


	void SwingAgain()
	{
		Swing( 0 );
	}

	bool Swing( int fFirst )
	{
		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 32;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 3 )
				{
				case 0:
					self.SendWeaponAnim( ISLWEP_ATTACK1_MISS ); break;
				case 1:
					self.SendWeaponAnim( ISLWEP_ATTACK2_MISS ); break;
				case 2:
					self.SendWeaponAnim( ISLWEP_ATTACK3_MISS ); break;
				}
				self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
				// play wiff or swish sound
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );

				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 2 ) + 1 )
			{
			case 0:
				self.SendWeaponAnim( ISLWEP_ATTACK1_HIT ); break;
			case 1:
				self.SendWeaponAnim( ISLWEP_ATTACK2_HIT ); break;
			case 2:
				self.SendWeaponAnim( ISLWEP_ATTACK3_HIT ); break;
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			// AdamR: Custom damage option
			float flDamage = 10;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;
			// AdamR: End

			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextPrimaryAttack + 1 < g_Engine.time )
			{
				// first swing does full damage
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
			}
			else
			{
				// subsequent swings do 50% (Changed -Sniper) (Half)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB );  
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = g_Engine.time + 0.30; //0.25
				self.m_flNextSecondaryAttack = g_Engine.time + 0.30; //0.25
				self.m_flTimeWeaponIdle = g_Engine.time + 0.30; //0.25

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
	// aone
					if( pEntity.IsPlayer() )		// lets pull them
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}
	// end aone
					// play thwack or smack sound
					switch( Math.RandomLong( 0, 2 ) )
					{
					case 0:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 1, ATTN_NORM ); break;
					case 1:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 1, ATTN_NORM ); break;
					case 2:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextPrimaryAttack = g_Engine.time + 0.25; //0.25
				self.m_flNextSecondaryAttack = g_Engine.time + 0.25; //0.25
				self.m_flTimeWeaponIdle = g_Engine.time + 0.25; //0.25
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;

				// also play crowbar strike
				switch( Math.RandomLong( 0, 2 ) )
				{
				case 0:
					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
					break;
				case 1:
					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
					break;
				case 2:
					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
					break;
				}
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.2;

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}
  
	void SecondaryAttack()
	{
    if(m_flChargeTime < 0.0f){
      m_flChargeTime = g_Engine.time;
      m_iMode = 0;
    }else{
      if(m_iMode == 0 || g_Engine.time - m_flChargeTime > 0.2f * float(m_iMode) - 0.1f) {
        
        if(m_iMode < 17){
          for (int j = 0; j < m_iMode; j++) {
            TraceResult tr;
            float flDist = 1.0;
            
            Vector vecSrc = self.pev.origin + g_Engine.v_up * 36 + g_Engine.v_forward * 32;

            for (int i = 0; i < 4; i++) {
              Vector vecAim = g_Engine.v_right * Math.RandomFloat( -1.0, 1.0 ) + g_Engine.v_up * Math.RandomFloat( -1.0, 1.0 ) + g_Engine.v_forward * Math.RandomFloat( -0.75, 0.75 );
              TraceResult tr1;
              
              g_Utility.TraceLine( vecSrc, vecSrc + vecAim * 512, dont_ignore_monsters, m_pPlayer.edict(), tr1 );
              if (flDist > tr1.flFraction) {
                tr = tr1;
                flDist = tr.flFraction;
              }
            }

            // Found something anything close enough
            if ( flDist < 1.0 ) {
              g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_CROWBAR );

              CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 30 );
              m_pBeam.PointsInit( self.pev.origin, tr.vecEndPos );
              m_pBeam.SetColor( 96, 128, 16 );
              m_pBeam.SetBrightness( 64 );
              m_pBeam.SetNoise( 80 );
              m_pBeam.LiveForTime(0.5);
            }
          }
        }
        
        if(m_iMode == 17){
          self.SendWeaponAnim( ISLWEP_RETURN );
          g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", 1, ATTN_NORM, 0, 100 );
          m_iMode++;
        }else if(m_iMode < 5) {
          if(m_iMode < 1) {
            self.SendWeaponAnim( ISLWEP_CHARGE );
          }
          g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "debris/zap4.wav", 1, ATTN_NORM, 0, 100 + m_iMode * 10 );
          m_iMode++;
        }else if(m_iMode < 17){
          self.SendWeaponAnim( ISLWEP_CHARGE_LOOP );
          g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "debris/zap4.wav", 1, ATTN_NORM, 0, 140 + m_iMode * 2 );
          m_iMode++;
        }
      }
    }
    self.m_flNextPrimaryAttack = g_Engine.time + 0.25;
    self.m_flNextSecondaryAttack = g_Engine.time + 0.01;
    self.m_flTimeWeaponIdle = g_Engine.time;
	}
  
  void ZapBeam(){
    Vector vecSrc, vecAim;
    TraceResult tr;
    
    vecSrc = m_pPlayer.GetGunPosition();
    
    float deflection = 0.02;
    
    for(int i = 0; i < 3; i++){
      vecAim = m_pPlayer.GetAutoaimVector( 0.0f ) + g_Engine.v_right * Math.RandomFloat( -deflection, deflection ) + g_Engine.v_up * Math.RandomFloat( -deflection, deflection );
      g_Utility.TraceLine( vecSrc, vecSrc + vecAim * 1024, dont_ignore_monsters, m_pPlayer.edict(), tr );
      CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 50 );
      m_pBeam.PointsInit( self.pev.origin, tr.vecEndPos );
      m_pBeam.SetColor( 180, 255, 96 );
      m_pBeam.SetBrightness( 255 );
      m_pBeam.SetNoise( 20 );
      m_pBeam.LiveForTime(0.5);
    }
    
    vecAim = m_pPlayer.GetAutoaimVector( 0.0f );
    g_Utility.TraceLine( vecSrc, vecSrc + vecAim * 1024, dont_ignore_monsters, m_pPlayer.edict(), tr );
    
    CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
    
    if (pEntity !is null) {
      if (pEntity.pev.classname == "player" || pEntity.pev.classname == "deadplayer") {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
        if(pPlayer !is null && pPlayer.IsConnected()){
          if(pPlayer.IsAlive()){
            if (pPlayer.pev.health < pPlayer.pev.max_health) {
              pPlayer.pev.health += 10.0;

              if (pPlayer.pev.health > pPlayer.pev.max_health)
                pPlayer.pev.health = pPlayer.pev.max_health;
            }
            g_WeaponFuncs.ClearMultiDamage();
            pPlayer.TraceAttack( pev, 0.0, vecAim, tr, DMG_SHOCK ); 
            g_WeaponFuncs.ApplyMultiDamage( self.pev, self.pev );
          }else{
            pPlayer.GetObserver().RemoveDeadBody();
            pPlayer.Revive();
          }
        }
      }else{
        g_WeaponFuncs.ClearMultiDamage();
        pEntity.TraceAttack( pev, 55.0, vecAim, tr, DMG_SHOCK ); 
        g_WeaponFuncs.ApplyMultiDamage( self.pev, self.pev );
      }
    }
  }
  
	void WeaponIdle()
	{
    self.ResetEmptySound();
    m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
    if(m_iMode > 4 && m_iMode < 17){
      ZapBeam();
      g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hassault/hw_shoot1.wav", 1, ATTN_NORM, 0, Math.RandomLong( 130, 160 ) );
      self.SendWeaponAnim( ISLWEP_ZAP );
      
      self.m_flTimeWeaponIdle = g_Engine.time + 1.0;
    }else{
      
      if( self.m_flTimeWeaponIdle > g_Engine.time ) return;
      
      int iAnim;
      switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
      {
      case 0:	
        iAnim = ISLWEP_IDLE1;	
        break;
      
      case 1:
        iAnim = ISLWEP_IDLE2;
        break;
        
      default:
        iAnim = ISLWEP_IDLE2;
        break;
      }

      self.SendWeaponAnim( iAnim );

      self.m_flTimeWeaponIdle = g_Engine.time + 5.0; // how long till we do this again.
    }
    
    m_flChargeTime = -1.0;
    m_iMode = 0;
  }
}

string GetWeaponIslaveName()
{
	return "weapon_slave";
}

void RegisterWeaponIslave()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_slave", GetWeaponIslaveName() );
	g_ItemRegistry.RegisterWeapon( GetWeaponIslaveName(), "decay" );
}
