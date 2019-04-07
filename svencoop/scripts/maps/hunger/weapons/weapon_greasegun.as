// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponGreasegun
{

const string WEAPON_NAME			= "weapon_greasegun";
const string AMMO_DROP_NAME			= "ammo_greasegun";
const string AMMO_TYPE				= "9mm";

const int GREASEGUN_MAX_CARRY    	= 250;
const int GREASEGUN_DEFAULT_GIVE 	= 60;
const int GREASEGUN_MAX_CLIP     	= 20;
const int GREASEGUN_WEIGHT       	= 15;

enum TheyHungerM3GREASEGUNAnimation_e
{
	M3GREASEGUN_LONGIDLE = 0,
	M3GREASEGUN_IDLE,
	M3GREASEGUN_RELOAD,
	M3GREASEGUN_RELOAD_EMPTY,
	M3GREASEGUN_DRAW,
	M3GREASEGUN_SHOOT1,
	M3GREASEGUN_SHOOT2,
	M3GREASEGUN_SHOOT3
};

class CGreasegun : CBaseCustomWeapon
{
	string M3_W_MODEL = "models/hunger/weapons/greasegun/w_greasegun.mdl";
	string M3_V_MODEL = "models/hunger/weapons/greasegun/v_greasegun.mdl";
	string M3_P_MODEL = "models/hunger/weapons/greasegun/p_greasegun.mdl";

	string M3_S_FIRE1 = "hunger/weapons/greasegun/M3_shoot1.wav";

	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, M3_W_MODEL );
		
		self.m_iDefaultAmmo = GREASEGUN_DEFAULT_GIVE;
		
		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( M3_W_MODEL );
		g_Game.PrecacheModel( M3_V_MODEL );
		g_Game.PrecacheModel( M3_P_MODEL );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( M3_S_FIRE1 );
		g_SoundSystem.PrecacheSound( "hunger/weapons/greasegun/M3_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/greasegun/M3_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/greasegun/M3_magout.wav" );
		
		g_Game.PrecacheOther( AMMO_DROP_NAME );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= GREASEGUN_MAX_CARRY;
		info.iAmmo1Drop	= GREASEGUN_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= GREASEGUN_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 4;
		info.iFlags		= 0;
		info.iWeight	= GREASEGUN_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger6( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger6.WriteLong( self.m_iId );
		hunger6.End();
		
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
		bool fResult = self.DefaultDeploy ( self.GetV_Model( M3_V_MODEL ), self.GetP_Model( M3_P_MODEL ), M3GREASEGUN_DRAW, "mp5" );
		
		float deployTime = 1.03;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
		
		return fResult;
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.147;
		
		pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		pPlayer.pev.effects |= EF_MUZZLEFLASH;
		pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( pPlayer.random_seed, 0, 2 ) )
		{
			case 0: 
			self.SendWeaponAnim( M3GREASEGUN_SHOOT1, 0, 0 );
			pPlayer.pev.punchangle.y += Math.RandomFloat( -0.4, 0.4 );
			break;

			case 1:
			self.SendWeaponAnim( M3GREASEGUN_SHOOT2, 0, 0 );
			pPlayer.pev.punchangle.y += -0.3;
			break;
			case 2:
			self.SendWeaponAnim( M3GREASEGUN_SHOOT3, 0, 0 );
			pPlayer.pev.punchangle.y += 0.3;
			break;
		}
		
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, M3_S_FIRE1, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
		
		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_iClip == 0 && pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );

		pPlayer.pev.punchangle.x -= 1.6;

		pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 8192, BULLET_PLAYER_MP5 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		
		GetDefaultShellInfo( pPlayer, vecShellVelocity, vecShellOrigin, 25, 7, -7 );
		
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

	void Reload()
	{
		if( self.m_iClip < GREASEGUN_MAX_CLIP )
			BaseClass.Reload();

		self.m_iClip == 0 ? self.DefaultReload( GREASEGUN_MAX_CLIP, M3GREASEGUN_RELOAD_EMPTY, 3.03, 0 ) : self.DefaultReload( GREASEGUN_MAX_CLIP, M3GREASEGUN_RELOAD, 2.03, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = M3GREASEGUN_LONGIDLE;
			break;
			
			case 1: iAnim = M3GREASEGUN_IDLE;
			break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class CGreasegunMagazine : CBaseCustomAmmo
{
	string GREASEGUN_MAG_MODEL = "models/hunger/weapons/greasegun/w_greasegun_mag.mdl";
	
	CGreasegunMagazine()
	{
		m_strModel = GREASEGUN_MAG_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = GREASEGUN_MAX_CLIP;
		m_iMax = GREASEGUN_MAX_CARRY;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponGreasegun::CGreasegunMagazine", AMMO_DROP_NAME );
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponGreasegun::CGreasegun", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
