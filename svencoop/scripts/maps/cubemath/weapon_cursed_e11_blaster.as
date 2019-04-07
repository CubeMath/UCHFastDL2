/*  
* The original Half-Life version of the mp5
*/

enum E11Animation
{
	E11_LONGIDLE = 0,
	E11_IDLE1,
	E11_LAUNCH,
	E11_RELOAD,
	E11_DEPLOY,
	E11_FIRE1,
	E11_FIRE2,
	E11_FIRE3,
};

class weapon_cursed_e11 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	
	void Spawn(){
		Precache();
		g_EntityFuncs.SetModel( self, "models/cubemath/cursed_e11_blaster/w_cursed_e11_blaster.mdl" );
		
		self.FallInit();
	}

	void Precache(){
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "sprites/laserbeam.spr" );
		g_Game.PrecacheModel( "models/cubemath/cursed_e11_blaster/v_cursed_e11_blaster.mdl" );
		g_Game.PrecacheModel( "models/cubemath/cursed_e11_blaster/w_cursed_e11_blaster.mdl" );
		g_Game.PrecacheModel( "models/cubemath/cursed_e11_blaster/p_cursed_e11_blaster.mdl" );
		
		g_SoundSystem.PrecacheSound( "cubemath/laser-blaster.wav" );
	}

	bool GetItemInfo( ItemInfo& out info ){
		info.iMaxAmmo1 	= -1;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 		= 6;
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

		return true;
	}
	
	bool Deploy(){
		return self.DefaultDeploy(
				self.GetV_Model( "models/cubemath/cursed_e11_blaster/v_cursed_e11_blaster.mdl" ),
				self.GetP_Model( "models/cubemath/cursed_e11_blaster/p_cursed_e11_blaster.mdl" ), E11_DEPLOY, "mp5"
		);
	}
	
	void Holster(int skiplocal){
		BaseClass.Holster( skiplocal );
	}
	
	void PrimaryAttack()
	{
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) ){
			case 0: self.SendWeaponAnim( E11_FIRE1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( E11_FIRE2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( E11_FIRE3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "cubemath/laser-blaster.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecSrc2 = vecSrc + g_Engine.v_up * -8.0f + g_Engine.v_right * 3.5f;
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		self.m_flNextPrimaryAttack = g_Engine.time + 0.35;

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		Vector vecDir;
		Vector vecTarget;
		
		int i = 0;
		for(;i < 1000; i++){
			TraceResult tr1;
			TraceResult tr2;
			float x, y;
			g_Utility.GetCircularGaussianSpread( x, y );
			bool boringTarget = false;
			
			float shakey = float(i*i)/1000000.0f;
			
			vecDir = vecAiming 
							+ x * shakey * g_Engine.v_right 
							+ y * shakey * g_Engine.v_up;

			Vector vecEnd = vecSrc + vecDir * 8192;

			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr1 );
			vecTarget = tr1.vecEndPos;
			
			if( tr1.flFraction < 1.0 ){
				if( tr1.pHit !is null ){
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr1.pHit );
				
					if( pHit is null || pHit.IsBSPModel() ){
						
						boringTarget = false;
						boringTarget = boringTarget || pHit.pev.classname == "worldspawn";
						boringTarget = boringTarget || pHit.pev.classname == "func_conveyor";
						boringTarget = boringTarget || pHit.pev.classname == "func_detail";
						boringTarget = boringTarget || pHit.pev.classname == "func_pendulum";
						boringTarget = boringTarget || pHit.pev.classname == "func_plat";
						boringTarget = boringTarget || pHit.pev.classname == "func_platrot";
						boringTarget = boringTarget || pHit.pev.classname == "func_tank";
						boringTarget = boringTarget || pHit.pev.classname == "func_tanklaser";
						boringTarget = boringTarget || pHit.pev.classname == "func_tankmortar";
						boringTarget = boringTarget || pHit.pev.classname == "func_tankrocket";
						boringTarget = boringTarget || pHit.pev.classname == "func_tracktrain";
						boringTarget = boringTarget || pHit.pev.classname == "func_train";
						boringTarget = boringTarget || pHit.pev.classname == "func_wall";
						boringTarget = boringTarget || pHit.pev.classname == "func_wall_toggle";
						
						if(boringTarget){
							
							//2nd Check
							g_Utility.TraceLine( vecSrc2, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr2 );
							if( tr2.flFraction < 1.0 ){
								if( tr2.pHit !is null ){
									CBaseEntity@ pHit2 = g_EntityFuncs.Instance( tr2.pHit );
								
									if( pHit2 is null || pHit2.IsBSPModel() ){
									
										boringTarget = false;
										boringTarget = boringTarget || pHit2.pev.classname == "worldspawn";
										boringTarget = boringTarget || pHit2.pev.classname == "func_conveyor";
										boringTarget = boringTarget || pHit2.pev.classname == "func_detail";
										boringTarget = boringTarget || pHit2.pev.classname == "func_pendulum";
										boringTarget = boringTarget || pHit2.pev.classname == "func_plat";
										boringTarget = boringTarget || pHit2.pev.classname == "func_platrot";
										boringTarget = boringTarget || pHit2.pev.classname == "func_tank";
										boringTarget = boringTarget || pHit2.pev.classname == "func_tanklaser";
										boringTarget = boringTarget || pHit2.pev.classname == "func_tankmortar";
										boringTarget = boringTarget || pHit2.pev.classname == "func_tankrocket";
										boringTarget = boringTarget || pHit2.pev.classname == "func_tracktrain";
										boringTarget = boringTarget || pHit2.pev.classname == "func_train";
										boringTarget = boringTarget || pHit2.pev.classname == "func_wall";
										boringTarget = boringTarget || pHit2.pev.classname == "func_wall_toggle";
						
										if(boringTarget){
											//okok, you won!
											g_WeaponFuncs.DecalGunshot( tr1, BULLET_PLAYER_357 );
											break;
										}
									}
								}
							}else{
								break;
							}
						}
					}
				}
			}else{
				//2nd Check
				g_Utility.TraceLine( vecSrc2, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr2 );
				if( tr2.flFraction < 1.0 ){
					if( tr2.pHit !is null ){
						CBaseEntity@ pHit = g_EntityFuncs.Instance( tr2.pHit );
						
						if( pHit is null || pHit.IsBSPModel() ){
							boringTarget = false;
							boringTarget = boringTarget || pHit.pev.classname == "worldspawn";
							boringTarget = boringTarget || pHit.pev.classname == "func_conveyor";
							boringTarget = boringTarget || pHit.pev.classname == "func_detail";
							boringTarget = boringTarget || pHit.pev.classname == "func_pendulum";
							boringTarget = boringTarget || pHit.pev.classname == "func_plat";
							boringTarget = boringTarget || pHit.pev.classname == "func_platrot";
							boringTarget = boringTarget || pHit.pev.classname == "func_tank";
							boringTarget = boringTarget || pHit.pev.classname == "func_tanklaser";
							boringTarget = boringTarget || pHit.pev.classname == "func_tankmortar";
							boringTarget = boringTarget || pHit.pev.classname == "func_tankrocket";
							boringTarget = boringTarget || pHit.pev.classname == "func_tracktrain";
							boringTarget = boringTarget || pHit.pev.classname == "func_train";
							boringTarget = boringTarget || pHit.pev.classname == "func_wall";
							boringTarget = boringTarget || pHit.pev.classname == "func_wall_toggle";
							
							if(boringTarget){
								//okok, you won!
								g_WeaponFuncs.DecalGunshot( tr1, BULLET_PLAYER_357 );
								break;
							}
						}
					}
				}else{
					break;
				}
			}
		}
		
		if(i < 1000){
			m_pPlayer.FireBullets( 1, vecSrc, vecDir, Vector(0,0,0), 8192, BULLET_PLAYER_SNIPER, 2 );
			
			CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam.PointsInit( vecSrc2, vecTarget );
			m_pBeam.SetColor( 255, 0, 0 );
			m_pBeam.SetBrightness( 255 );
			m_pBeam.SetNoise( 0.0f );
			m_pBeam.SetWidth( 12 );
			m_pBeam.LiveForTime(0.05f);
			@m_pBeam.pev.owner = @m_pPlayer.edict();
			
			CBeam@ m_pBeam2 = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 1 );
			m_pBeam2.PointsInit( vecSrc2, vecTarget );
			m_pBeam2.SetColor( 255, 255, 255 );
			m_pBeam2.SetBrightness( 255 );
			m_pBeam2.SetNoise( 0.0f );
			m_pBeam2.SetWidth( 8 );
			m_pBeam2.LiveForTime(0.05f);
			@m_pBeam2.pev.owner = @m_pPlayer.edict();
			
		}
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
		case 0:	
			iAnim = E11_LONGIDLE;	
			break;
		
		case 1:
			iAnim = E11_IDLE1;
			break;
			
		default:
			iAnim = E11_IDLE1;
			break;
		}

		self.SendWeaponAnim( iAnim );

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );// how long till we do this again.
	}
}

string GetHLE11Name()
{
	return "weapon_cursed_e11";
}

void RegisterHLE11()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_cursed_e11", GetHLE11Name() );
	g_ItemRegistry.RegisterWeapon( GetHLE11Name(), "cubemath/cursed_e11_blaster" );
}
