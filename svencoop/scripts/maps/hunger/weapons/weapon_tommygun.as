// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponThompson
{

const string WEAPON_NAME			= "weapon_tommygun";
const string AMMO_DROP_NAME			= "ammo_tommygun_drum";
const string AMMO_TYPE				= "9mm";

const int THOMPSON_MAX_CARRY    	= 250;
const int THOMPSON_DEFAULT_GIVE 	= 100;
const int THOMPSON_MAX_CLIP     	= 50;
const int THOMPSON_WEIGHT       	= 25;

enum TheyHungerTHOMPSONM1Animation_e
{
	THOMPSONM1_LONGIDLE = 0,
	THOMPSONM1_IDLE,
	THOMPSONM1_RELOAD_EMPTY,
	THOMPSONM1_RELOAD,
	THOMPSONM1_DEPLOY,
	THOMPSONM1_SHOOT1,
	THOMPSONM1_SHOOT2,
	THOMPSONM1_SHOOT3
};

class CThompson : CBaseCustomWeapon
{
	string TOMMY_W_MODEL = "models/hunger/weapons/tommygun/w_tommygun.mdl";
	string TOMMY_V_MODEL = "models/hunger/weapons/tommygun/v_tommygun.mdl";
	string TOMMY_P_MODEL = "models/hunger/weapons/tommygun/p_tommygun.mdl";

	int m_iShell;
	
	private uint m_iShotsFired = 0;
	private bool m_iDirection = true;							  

	string TOMMY_S_FIRE1 = "hunger/weapons/tommygun/fire.wav";
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, TOMMY_W_MODEL );
		
		self.m_iDefaultAmmo = THOMPSON_DEFAULT_GIVE;
		
		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( TOMMY_W_MODEL );
		g_Game.PrecacheModel( TOMMY_V_MODEL );
		g_Game.PrecacheModel( TOMMY_P_MODEL );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( TOMMY_S_FIRE1 );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_boltback.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_magout.wav" );
		
		g_Game.PrecacheOther( AMMO_DROP_NAME );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= THOMPSON_MAX_CARRY;
		info.iAmmo1Drop	= THOMPSON_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= THOMPSON_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 5;
		info.iFlags		= 0;
		info.iWeight	= THOMPSON_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger4( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger4.WriteLong( self.m_iId );
		hunger4.End();
		
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
		bool fResult = self.DefaultDeploy ( self.GetV_Model( TOMMY_V_MODEL ), self.GetP_Model( TOMMY_P_MODEL ), THOMPSONM1_DEPLOY, "sniper" );
		
		float deployTime = 0.62;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
		
		return fResult;
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		m_iShotsFired = 0;
		BaseClass.Holster( skipLocal );
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.09;
		
		pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		++m_iShotsFired;
		
		pPlayer.pev.effects |= EF_MUZZLEFLASH;
		pPlayer.SetAnimation( PLAYER_ATTACK1 );

		self.SendWeaponAnim( THOMPSONM1_SHOOT1 + Math.RandomLong( 0, 2 ), 0, 0 );

		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, TOMMY_S_FIRE1, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );

		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_iClip == 0 && pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );

		Vector vecCone = self.BulletAccuracy( VECTOR_CONE_4DEGREES, VECTOR_CONE_2DEGREES, VECTOR_CONE_1DEGREES );

		int m_iBulletDamage = Math.RandomLong( 10, 13 );
		pPlayer.FireBullets( 1, vecSrc, vecAiming, vecCone, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, m_iBulletDamage );

		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		Vector vecDir = vecAiming + x * vecCone.x * g_Engine.v_right + y * vecCone.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 8192;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		GetDefaultShellInfo( pPlayer, vecShellVelocity, vecShellOrigin, 19, 7, -7 );
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

		if( !( pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 1.3, 0.55, 0.4, 0.05, 4.75, 2.75, 5 );
		}
		else if( pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.9, 0.45, 0.25, 0.035, 3.5, 1.75, 7 );
		}
		else if( pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.75, 0.4, 0.175, 0.03, 2.75, 1.5, 10 );
		}
		else
		{
			KickBack( 0.775, 0.425, 0.2, 0.03, 3.0, 1.75, 9 );
		}
	}

	void Reload()
	{
		if( self.m_iClip == THOMPSON_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		m_iShotsFired = 0;
		(self.m_iClip == 0) ? self.DefaultReload( THOMPSON_MAX_CLIP, THOMPSONM1_RELOAD_EMPTY, 2.08, 0 ) : self.DefaultReload( THOMPSON_MAX_CLIP, THOMPSONM1_RELOAD, 1.56, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		if( self.m_flNextPrimaryAttack < g_Engine.time )
			m_iShotsFired = 0;

		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( THOMPSONM1_LONGIDLE + Math.RandomLong( 0, 1 ), 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  5, 7 );
	}

	void KickBack( float up_base, float lateral_base, float up_modifier, float lateral_modifier, float up_max, float lateral_max, int direction_change )
	{
		float flFront, flSide;

		if( m_iShotsFired == 1 )
		{
			flFront = up_base;
			flSide = lateral_base;
		}
		else
		{
			flFront = m_iShotsFired * up_modifier + up_base;
			flSide = m_iShotsFired * lateral_modifier + lateral_base;
		}

		m_pPlayer.pev.punchangle.x -= flFront;

		if( m_pPlayer.pev.punchangle.x < -up_max )
			m_pPlayer.pev.punchangle.x = -up_max;

		if( m_iDirection )
		{
			m_pPlayer.pev.punchangle.y += flSide;

			if( m_pPlayer.pev.punchangle.y > lateral_max )
				m_pPlayer.pev.punchangle.y = lateral_max;
		}
		else
		{
			m_pPlayer.pev.punchangle.y -= flSide;

			if( m_pPlayer.pev.punchangle.y < -lateral_max )
				m_pPlayer.pev.punchangle.y = -lateral_max;
		}

		if( Math.RandomLong( 0, direction_change ) == 0 )
		{
			m_iDirection = !m_iDirection;
		}
	}
}
	
class CThompsonDrumMagazine : CBaseCustomAmmo
{
	string TOMMY_MAG_MODEL = "models/hunger/weapons/tommygun/w_tommygun_mag.mdl";
	
	CThompsonDrumMagazine()
	{
		m_strModel = TOMMY_MAG_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = THOMPSON_MAX_CLIP;
		m_iMax = THOMPSON_MAX_CARRY;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponThompson::CThompsonDrumMagazine", AMMO_DROP_NAME );
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponThompson::CThompson", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
