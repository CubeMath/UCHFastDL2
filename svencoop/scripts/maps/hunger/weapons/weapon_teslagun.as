// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponTeslagun
{

const string WEAPON_NAME			= "weapon_teslagun";
const string AMMO_DROP_NAME			= ""; // "ammo_gaussclip";
const string AMMO_TYPE				= "uranium"; // GeckoN: TODO: Custom ammo?

const int TESLA_MAX_CARRY   		= 100;
const int TESLA_DEFAULT_GIVE 		= 100;
const int TESLA_AMMO_DROP	 		= 0; // 20;
const int TESLA_WEIGHT      		= 15;

enum TESLAGUNAnimation_e
{
	TESLAGUN_IDLE = 0,
	TESLAGUN_ATTACK,
	TESLAGUN_ATTACK_BIG,
	TESLAGUN_SPINUP,
	TESLAGUN_CHARGE,
	TESLAGUN_DRAW,
	TESLAGUN_SPINDOWN
};

class CTeslagun : CBaseCustomWeapon
{
	string TG_W_MODEL = "models/hunger/weapons/tesla/w_tesla.mdl";
	string TG_V_MODEL = "models/hunger/weapons/tesla/v_tesla.mdl";
	string TG_P_MODEL = "models/hunger/weapons/tesla/p_tesla.mdl";

	string TG_S_FIRE1 = "hunger/weapons/tesla/tesla_fire.ogg";
	string TG_S_FIRE2 = "hunger/weapons/tesla/tesla_bigrelease.ogg";
	string TG_S_CHARGE1 = "hunger/weapons/tesla/tesla_bigcharge.ogg";
	string TG_S_CHARGE2 = "hunger/weapons/tesla/tesla_chargehold.ogg";
	string TG_S_SPINUP1 = "hunger/weapons/tesla/tesla_spinup.ogg";

	private float m_flAmmoLoss;
	private float m_flNextAnim;
	private bool m_bShooting;
	private bool mCanFire;
	private bool mWasShooting;
	private int m_fInAttack;
	private int m_iWastedAmmo;
	private float m_flNextBeamTime;
	private float m_flNextAmmoBurn;
	private float m_flStartCharge;
	private float m_flAmmoStartCharge;

	CBeam@ pBeam;
	CBeam@ pBeam2;
	CBeam@ pBeam3;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, TG_W_MODEL );
		
		self.m_iDefaultAmmo = TESLA_DEFAULT_GIVE;
		m_flAmmoLoss = 0.0;
		m_flNextAnim = 0.0;
		m_bShooting = false;
		mCanFire = false;
		m_flNextBeamTime = 0;
		RemoveLightning();
		RemoveLightning2();
		RemoveLightning3();
		
		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( TG_W_MODEL );
		g_Game.PrecacheModel( TG_V_MODEL );
		g_Game.PrecacheModel( TG_P_MODEL );
		g_Game.PrecacheModel( "sprites/hunger/tesla_beam.spr" );

		g_SoundSystem.PrecacheSound( TG_S_FIRE1 );
		g_SoundSystem.PrecacheSound( TG_S_FIRE2 );
		g_SoundSystem.PrecacheSound( TG_S_CHARGE1 );
		g_SoundSystem.PrecacheSound( TG_S_CHARGE2 );
		g_SoundSystem.PrecacheSound( TG_S_SPINUP1 );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tesla/tesla_draw.ogg" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= TESLA_MAX_CARRY;
		info.iAmmo1Drop	= TESLA_AMMO_DROP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= WEAPON_NOCLIP;
		info.iSlot		= 3;
		info.iPosition	= 5;
		info.iFlags		= 0;
		info.iWeight	= TESLA_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger7( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger7.WriteLong( self.m_iId );
		hunger7.End();
		m_bShooting = false;
		RemoveLightning();
		RemoveLightning2();
		RemoveLightning3();
		
		return true;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool fResult = self.DefaultDeploy ( self.GetV_Model( TG_V_MODEL ), self.GetP_Model( TG_P_MODEL ), TESLAGUN_DRAW, "gauss" );
		
		float deployTime = 1.0;
		m_bShooting = false;
		mWasShooting = false;
		RemoveLightning();
		RemoveLightning2();
		RemoveLightning3();
		m_pPlayer.m_flNextAttack = deployTime;
		
		return fResult;
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		RemoveLightning();
		RemoveLightning2();
		RemoveLightning3();
		g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, TG_S_CHARGE1 );
		m_fInAttack = 0;
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		int iAmmo = pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );

		if( pPlayer.pev.waterlevel == WATERLEVEL_HEAD || iAmmo <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75f;
			return;
		}

		bool bDidShoot = !m_bShooting;

		if( !m_bShooting )
		{
			//Weapon is Spining up
			self.SendWeaponAnim( TESLAGUN_SPINUP, 0, 0 );
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, TG_S_SPINUP1, 0.95, ATTN_NORM, 0, 100 );
			m_flNextAnim = g_Engine.time + 0.6;
			mCanFire = false;
			m_bShooting = true;
			mWasShooting = true;
		}
		else if( m_flNextAnim <= g_Engine.time )
		{
			//After spining, attack
			self.SendWeaponAnim( TESLAGUN_ATTACK, 0, 0 );
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, TG_S_FIRE1, 0.95, ATTN_NORM, 0, 100 );
			m_flNextAnim = g_Engine.time + 0.2;
			mCanFire = true;
			m_bShooting = true;
			mWasShooting = true;
		}

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.05;

		if( m_flNextBeamTime < m_flNextAnim )
		{
			if( mCanFire == true )
			{
				//fire only when attacking
				pPlayer.pev.punchangle.x = -1.3;
				UpdateLightning( vecSrc, vecAiming, Math.RandomLong( 2, 6 ) );
				UpdateLightning2( vecSrc, vecAiming, 2 );
				UpdateLightning3( vecSrc, vecAiming, 2 );
				DynamicLight( pPlayer.pev.origin, 10, 255, 255, 255, 1, 10 );
				m_flNextBeamTime = g_Engine.time + 0.035;
			}
		}

		if( m_flAmmoLoss < g_Engine.time )
		{
			if( mCanFire == true )
			{
				//lose ammo only when attacking
				--iAmmo;
				m_flAmmoLoss = g_Engine.time + 0.2;
			}
		}
		
		pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
	
		if( iAmmo <= 0 )
		{
			pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}

		pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, iAmmo);
	}

	void SecondaryAttack()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		// don't fire underwater
		int iAmmo = pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		if( pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55;
			return;
		}

		if ( m_fInAttack == 0 )
		{
			if( iAmmo <= 1 )
			{
				self.PlayEmptySound();
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55;
				return;
			}

			iAmmo -= 1;
			m_iWastedAmmo += 1;
			m_flNextAmmoBurn = WeaponTimeBase();
			m_fInAttack = 1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.25;
			m_flStartCharge = WeaponTimeBase();
			m_flAmmoStartCharge = WeaponTimeBase() + 3.0;
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, TG_S_CHARGE1, 1.0, ATTN_NORM, 0, 100 );
			self.SendWeaponAnim( TESLAGUN_CHARGE, 0, 0 );
			
			if ( iAmmo <= 0 )
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.4;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 2.0;
				iAmmo = 0;
				return;
			}
		}
		
		else if ( m_fInAttack == 1 )
		{
			if ( self.m_flTimeWeaponIdle < WeaponTimeBase() )
			{
				m_fInAttack = 2;
			}
		}
		else
		{
			// during the charging process, eat one bit of ammo every once in a while
			if ( WeaponTimeBase() >= m_flNextAmmoBurn && m_flNextAmmoBurn != 1000 )
			{
				iAmmo -= 1;
				m_iWastedAmmo += 1;
				m_flNextAmmoBurn = WeaponTimeBase() + 0.1;
			}
			
			if ( iAmmo <= 0 )
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
				iAmmo = 0;
				return;
			}
		
			if ( WeaponTimeBase() >= m_flAmmoStartCharge )
				m_flNextAmmoBurn = 1000;

			if ( m_flStartCharge < WeaponTimeBase() - 4.0 )
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.5;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
				return;
			}
		}
		pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, iAmmo );
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
	}

	//Nero
	void StartFire()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_SoundSystem.StopSound( pPlayer.edict(), CHAN_WEAPON, TG_S_CHARGE1 );
		
		Math.MakeVectors( pPlayer.pev.v_angle + pPlayer.pev.punchangle );
		
		self.SendWeaponAnim( TESLAGUN_ATTACK_BIG, 0, 0 );

		UpdateLightning( vecSrc, vecAiming, 5 * m_iWastedAmmo );
		UpdateLightning2( vecSrc, vecAiming, 5 * m_iWastedAmmo );
		UpdateLightning3( vecSrc, vecAiming, 5 * m_iWastedAmmo );
		DynamicLight( pPlayer.pev.origin, 10, 255, 255, 255, 1, 10 );
		
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, TG_S_FIRE2, 1.0, ATTN_NORM, 0, 100 );
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 2.0;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
		pPlayer.pev.punchangle.x -= 2 + m_iWastedAmmo;
		m_iWastedAmmo = 0;
		m_fInAttack = 0;
	}

	void SpawnLightning3()
	{
		RemoveLightning3();
		@pBeam3 = @g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 4 );
		pBeam3.PointEntInit( self.pev.origin, m_pPlayer );
		pBeam3.SetBrightness( 255 );
		pBeam3.SetFlags( BEAM_FSHADEIN );
		pBeam3.SetEndAttachment( 1 );
		pBeam3.pev.spawnflags |= SF_BEAM_TEMPORARY | SF_BEAM_SPARKSTART | SF_BEAM_SHADEIN | SF_BEAM_SHADEOUT;
		@pBeam3.pev.owner = @m_pPlayer.edict();
		pBeam3.SetScrollRate( Math.RandomLong( 90, 110 ) );
		pBeam3.SetNoise( 15 );
	}

	void UpdateLightning3( const Vector& in vecSrc, const Vector& in vecAiming, int iDamage )
	{
		TraceResult tr;
		g_Utility.TraceLine( vecSrc, vecSrc + vecAiming * 512, dont_ignore_monsters, m_pPlayer.edict(), tr );
		if ( tr.fAllSolid != 0 )
		{
			RemoveLightning3();
			return;
		}

		if ( pBeam3 is null )
		{
			SpawnLightning3();
		}
		pBeam3.SetStartPos( tr.vecEndPos );

		if ( iDamage > 0 )
		{
			if ( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if( tr.flFraction != 1.0 )
				{
					pBeam3.DoSparks( tr.vecEndPos, self.pev.origin );
				}

				if ( pHit !is null )
				{
					g_WeaponFuncs.ClearMultiDamage();
					pHit.TraceAttack( m_pPlayer.pev, iDamage, vecAiming, tr, DMG_GIB_CORPSE );
					g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
				}
				if ( pHit is null || pHit.IsBSPModel() )
				{
					//pBeam3.DoSparks( tr.vecEndPos, self.pev.origin );
					//g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
	}

	void RemoveLightning3()
	{
		if ( pBeam3 !is null )
		{
			g_EntityFuncs.Remove( pBeam3 );
		}
		@pBeam3 = @null;
	}

	void SpawnLightning2()
	{
		RemoveLightning2();
		@pBeam2 = @g_EntityFuncs.CreateBeam( "sprites/hunger/tesla_beam.spr", 4 );
		pBeam2.PointEntInit( self.pev.origin, m_pPlayer );
		pBeam2.SetBrightness( 255 );
		pBeam2.SetFlags( BEAM_FSHADEIN );
		pBeam2.SetEndAttachment( 1 );
		pBeam2.pev.spawnflags |= SF_BEAM_TEMPORARY | SF_BEAM_SPARKSTART | SF_BEAM_SHADEIN | SF_BEAM_SHADEOUT;
		@pBeam2.pev.owner = @m_pPlayer.edict();
		pBeam2.SetScrollRate( Math.RandomLong( 90, 110 ) );
		pBeam2.SetNoise( 30 );
	}

	void UpdateLightning2( const Vector& in vecSrc, const Vector& in vecAiming, int iDamage )
	{
		TraceResult tr;
		g_Utility.TraceLine( vecSrc, vecSrc + vecAiming * 512, dont_ignore_monsters, m_pPlayer.edict(), tr );
		if ( tr.fAllSolid != 0 )
		{
			RemoveLightning2();
			return;
		}
		if ( pBeam2 is null )
		{
			SpawnLightning2();
		}
		pBeam2.SetStartPos( tr.vecEndPos );

		if ( iDamage > 0 )
		{
			if ( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if( tr.flFraction != 1.0 )
				{
					pBeam2.DoSparks( tr.vecEndPos, self.pev.origin );
				}

				if ( pHit !is null )
				{
					g_WeaponFuncs.ClearMultiDamage();
					pHit.TraceAttack( m_pPlayer.pev, iDamage, vecAiming, tr, DMG_ENERGYBEAM );
					g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
				}

				if ( pHit is null || pHit.IsBSPModel() )
				{
					//pBeam2.DoSparks( tr.vecEndPos, self.pev.origin );
					//g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
	}

	void RemoveLightning2()
	{
		if ( pBeam2 !is null )
		{
			g_EntityFuncs.Remove( pBeam2 );
		}
		@pBeam2 = @null;
	}

	void SpawnLightning()
	{
		RemoveLightning();
		@pBeam = @g_EntityFuncs.CreateBeam( "sprites/hunger/tesla_beam.spr", Math.RandomLong( 8, 10 ) );
		pBeam.PointEntInit( self.pev.origin, m_pPlayer );
		pBeam.SetBrightness( 255 );
		pBeam.SetFlags( BEAM_FSHADEIN );
		pBeam.SetEndAttachment( 1 );
		pBeam.pev.spawnflags |= SF_BEAM_TEMPORARY | SF_BEAM_SPARKSTART | SF_BEAM_SHADEIN | SF_BEAM_SHADEOUT;
		@pBeam.pev.owner = @m_pPlayer.edict();
		pBeam.SetScrollRate( Math.RandomLong( 90, 110 ) );
		pBeam.SetNoise( Math.RandomLong( 25, 30 ) );
	}

	//fgsfds
	void UpdateLightning( const Vector& in vecSrc, const Vector& in vecAiming, int iDamage )
	{
		TraceResult tr;
		g_Utility.TraceLine( vecSrc, vecSrc + vecAiming * 512, dont_ignore_monsters, m_pPlayer.edict(), tr );
		if ( tr.fAllSolid != 0 )
		{
			RemoveLightning();
			return;
		}
		if ( pBeam is null )
		{
			SpawnLightning();
		}
		pBeam.SetStartPos( tr.vecEndPos );

		if ( iDamage > 0 )
		{
			if ( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if( tr.flFraction != 1.0 )
				{
					pBeam.DoSparks( tr.vecEndPos, self.pev.origin );
				}
				if ( pHit !is null )
				{
					g_WeaponFuncs.ClearMultiDamage();
					pHit.TraceAttack( m_pPlayer.pev, iDamage, vecAiming, tr, DMG_SHOCK );
					g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
				}
				if ( pHit is null || pHit.IsBSPModel() )
				{
					//pBeam.SetStartPos( tr.vecEndPos );
					//g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
	}

	void RemoveLightning()
	{
		if ( pBeam !is null )
		{
			g_EntityFuncs.Remove( pBeam );
		}
		@pBeam = @null;
	}

	void ItemPreFrame()
	{
		//Remove beam if the player is holding both buttons at the same time
		if( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 && ( m_pPlayer.pev.button & IN_ATTACK2 ) != 0 )
		{
			RemoveLightning();
			RemoveLightning2();
			RemoveLightning3();
		}
		BaseClass.ItemPreFrame();
	}

	void ItemPostFrame()
	{
		if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			// Player released the button, reset now
			mCanFire = false;
			m_bShooting = false;

			RemoveLightning();
			RemoveLightning2();
			RemoveLightning3();
		}
		//Check for the water
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			RemoveLightning();
			RemoveLightning2();
			RemoveLightning3();
		}
		BaseClass.ItemPostFrame();
	}
	
	void WeaponIdle()
	{
		//Player released button, fire
		if (m_fInAttack != 0)
		{
			StartFire();
			m_fInAttack = 0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, TG_S_CHARGE1 );
		}

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
		{
			//Check to spin it down if the player was spining the coils or the attacking with it
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			{
				// Player released the button, reset now
				if( mWasShooting == true )
				{
					self.SendWeaponAnim( TESLAGUN_SPINDOWN, 0, 0 );
					self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.3;
					self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
					mWasShooting = false;
				}
			}
			return;
		}

		//Idle animation
		self.SendWeaponAnim( TESLAGUN_IDLE, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 2, 4 );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponTeslagun::CTeslagun", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
