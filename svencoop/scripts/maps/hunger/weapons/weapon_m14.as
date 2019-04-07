// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponM14
{

const string WEAPON_NAME			= "weapon_m14";
const string AMMO_DROP_NAME			= "ammo_762";
const string AMMO_TYPE				= "m40a1";

const int M14_MAX_CARRY 			= 15;
const int M14_DEFAULT_GIVE			= 10;
const int M14_MAX_CLIP  			= 10;
const int M14_WEIGHT    			= 30;

enum TheyHungerM14Animation_e
{
	M14_IDLE1 = 0,
	M14_IDLE2,
	M14_IDLE3,
	M14_SHOOT,
	M14_SHOOT_LAST,
	M14_RELOAD,
	M14_RELOAD_EMPTY,
	M14_DEPLOY
};

enum ZOOM_MODE
{
	ZOOM_NOSCOPE = 0,
	ZOOM_SCOPED,
	ZOOM_SCOPED_2X
};

class CM14 : CBaseCustomWeapon
{
	string M14_V_MODEL = "models/hunger/weapons/m14/v_m14.mdl";
	string M14_W_MODEL = "models/hunger/weapons/m14/w_m14.mdl";
	string M14_P_MODEL = "models/hunger/weapons/m14/p_m14.mdl";
	
	string M14_S_FIRE1 = "hunger/weapons/m14/m14_shot1.wav";
	string M14_S_FIRE2 = "hunger/weapons/m14/m14_shot2.wav";
	string M14_S_ZOOM = "hunger/weapons/m14/m14_zoom.wav";

	int m_iCurrentMode;
	int m_iShotsFired;
	
	int m_iShell;
	
	// GeckoN: Movement speed modifier
	int m_iSpeedType;
	float m_flSpeedModifier;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, M14_W_MODEL );
		
		self.m_iDefaultAmmo = M14_DEFAULT_GIVE;
		m_iCurrentMode = ZOOM_NOSCOPE;
		m_iShotsFired = 0;
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( M14_W_MODEL );
		g_Game.PrecacheModel( M14_V_MODEL );
		g_Game.PrecacheModel( M14_P_MODEL );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( M14_S_FIRE1 );
		g_SoundSystem.PrecacheSound( M14_S_FIRE2 );
		g_SoundSystem.PrecacheSound( M14_S_ZOOM );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m14/m14_boltrelease.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m14/m14_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m14/m14_magout.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= M14_MAX_CARRY;
		info.iAmmo1Drop	= M14_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= M14_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= M14_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger5( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger5.WriteLong( self.m_iId );
		hunger5.End();
		
		// GeckoN: Movement speed modifier
		m_iSpeedType = ZOOM_NOSCOPE;
		m_flSpeedModifier = 0.0f;

		return true;
	}
	
	// GeckoN: Movement speed modifier
	void SetPlayerSpeed()
	{
		const int iType = m_iCurrentMode;
		
		// Do we even need to change the speed?
		if( iType == m_iSpeedType )
			return;

		// Remove previous speed reduction we applied
		m_pPlayer.m_flEffectSpeed += m_flSpeedModifier;

		switch( iType )
		{
		case ZOOM_SCOPED:
			m_flSpeedModifier = 0.45f; // Scoped, 45% speed reduction
			break;
		case ZOOM_SCOPED_2X:
			m_flSpeedModifier = 0.65f; // 2x scoped, 65% speed reduction
			break;
		case ZOOM_NOSCOPE:
		default:
			m_flSpeedModifier = 0.0f; // Not holding or dropping weapon
			break;
		}
		
		m_pPlayer.m_flEffectSpeed -= m_flSpeedModifier;

		m_pPlayer.ApplyEffects();
		m_iSpeedType = iType;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		
		if ( self.m_fInZoom )
		{
			SecondaryAttack();
		}

		m_iCurrentMode = ZOOM_NOSCOPE;
		ToggleZoom( 0 );
		SetPlayerSpeed();
		m_pPlayer.m_szAnimExtension = "sniper";
		
		BaseClass.Holster( skipLocal );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}
	
	void ToggleZoom( int zoomedFOV )
	{
		if ( self.m_fInZoom == true )
		{
			SetFOV( 0 ); // 0 means reset to default fov
		}
		else if ( self.m_fInZoom == false )
		{
			SetFOV( zoomedFOV );
		}
	}
	
	bool Deploy()
	{
		bool fResult = self.DefaultDeploy ( self.GetV_Model( M14_V_MODEL ), self.GetP_Model( M14_P_MODEL ), M14_DEPLOY, "sniper" );
		
		m_iCurrentMode = ZOOM_NOSCOPE;
		ToggleZoom( 0 );
		float deployTime = 0.7;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
		
		return fResult;
	}

	void PrimaryAttack()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		if( pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		
		--self.m_iClip;
		
		pPlayer.pev.effects |= EF_MUZZLEFLASH;
		pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.25f;
		if( self.m_iClip == 0 )
		{
			self.SendWeaponAnim( M14_SHOOT_LAST, 0, 0 );
			pPlayer.m_flNextAttack = 0.3;
		}
		else
		{
			self.SendWeaponAnim( M14_SHOOT, 0, 0 );
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.25;
		}
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, M14_S_FIRE1, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
			case 1: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, M14_S_FIRE2, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
		}
		
		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		int m_iBulletDamage = 55;
		
		if ( m_iCurrentMode == ZOOM_NOSCOPE )
		{
			pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_5DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, m_iBulletDamage );
		}
		else
		{
			pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, m_iBulletDamage );
		}

		if( self.m_iClip == 0 && pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}
		
		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		if ( m_iCurrentMode == ZOOM_NOSCOPE )
		{
			vecDir = vecAiming + x * VECTOR_CONE_5DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_5DEGREES.y * g_Engine.v_up;
			pPlayer.pev.punchangle.x += -3;
		}
		else
		{
			vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;
			pPlayer.pev.punchangle.x += -2;
		}

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		
		GetDefaultShellInfo( pPlayer, vecShellVelocity, vecShellOrigin, 14, 7, -7 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
				{
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
	}

	void SecondaryAttack()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.25f;
		switch ( m_iCurrentMode )
		{
			case ZOOM_NOSCOPE:
			{
				m_iCurrentMode = ZOOM_SCOPED;
				ToggleZoom( 45 );
				SetPlayerSpeed();
				pPlayer.m_szAnimExtension = "sniperscope";
				break;
			}
		
			case ZOOM_SCOPED:
			{
				m_iCurrentMode = ZOOM_SCOPED_2X;
				ToggleZoom( 20 );
				SetPlayerSpeed();
				pPlayer.m_szAnimExtension = "sniperscope";
				break;
			}
			
			case ZOOM_SCOPED_2X:
			{
				m_iCurrentMode = ZOOM_NOSCOPE;
				ToggleZoom( 0 );
				SetPlayerSpeed();
				pPlayer.m_szAnimExtension = "sniper";
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, M14_S_ZOOM, 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void Reload()
	{
		m_pPlayer.m_szAnimExtension = "sniper";
		if( self.m_iClip < M14_MAX_CLIP && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			BaseClass.Reload();
			m_iCurrentMode = ZOOM_NOSCOPE;
			m_iShotsFired = 0;
			SetPlayerSpeed();
			ToggleZoom( 0 );
		}

		self.m_iClip == 0 ? self.DefaultReload( M14_MAX_CLIP, M14_RELOAD_EMPTY, 4.03, 0 ) : self.DefaultReload( M14_MAX_CLIP, M14_RELOAD, 3.03, 0 );
	}
	
	void WeaponIdle()
	{
		// Can we fire?
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			// If the player is still holding the attack button, m_iShotsFired won't reset to 0
			// Preventing the automatic firing of the weapon
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				// Player released the button, reset now
				m_iShotsFired = 0;
			}
		}

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 2 ) )
		{
			case 0:	iAnim = M14_IDLE1;
			break;
			
			case 1: iAnim = M14_IDLE2;
			break;

			case 2: iAnim = M14_IDLE3;
			break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponM14::CM14", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
