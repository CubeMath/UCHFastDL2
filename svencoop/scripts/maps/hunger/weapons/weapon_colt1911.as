// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponM1911
{

const string WEAPON_NAME			= "weapon_colt1911";
const string AMMO_DROP_NAME			= "ammo_9mmclip";
const string AMMO_TYPE				= "9mm";

const int COLT_MAX_CARRY    		= 250;
const int COLT_DEFAULT_GIVE 		= 28;
const int COLT_MAX_CLIP     		= 7;
const int COLT_WEIGHT       		= 15;

enum TheyHungerM1911A1Animation_e
{
	M1911A1_IDLE = 0,
	M1911A1_SHOOT,
	M1911A1_SHOOT_EMPTY,
	M1911A1_RELOAD,
	M1911A1_RELOAD_EMPTY,
	M1911A1_DRAW,
	M1911A1_HOLSTER,
	M1911A1_FIDGET1,
	M1911A1_FIDGET2,
	M1911A1_FIDGET3
};

class CM1911 : CBaseCustomWeapon
{
	string COLT_V_MODEL = "models/hunger/weapons/colt/v_1911.mdl";
	string COLT_W_MODEL = "models/hunger/weapons/colt/w_1911.mdl";
	string COLT_P_MODEL = "models/hunger/weapons/colt/p_1911.mdl";

	string COLT_S_FIRE1 = "hunger/weapons/colt/colt_fire1.wav";
	string COLT_S_FIRE2 = "hunger/weapons/colt/colt_fire2.wav";
	string COLT_S_EMPTY = "hunger/weapons/colt/colt_empty.wav";

	int m_iShotsFired;

	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, COLT_W_MODEL );

		self.m_iDefaultAmmo = COLT_DEFAULT_GIVE;
		m_iShotsFired = 0;

		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( COLT_W_MODEL );
		g_Game.PrecacheModel( COLT_V_MODEL );
		g_Game.PrecacheModel( COLT_P_MODEL );
		g_Game.PrecacheModel( "sprites/wep_smoke_02.spr" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( COLT_S_FIRE1 );
		g_SoundSystem.PrecacheSound( COLT_S_FIRE2 );
		g_SoundSystem.PrecacheSound( COLT_S_EMPTY );
		g_SoundSystem.PrecacheSound( "hunger/weapons/colt/1911_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/colt/1911_magout.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/colt/1911_slideforward.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= COLT_MAX_CARRY;
		info.iAmmo1Drop	= COLT_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= COLT_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 4;
		info.iFlags		= 0;
		info.iWeight	= COLT_WEIGHT;
		
		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, COLT_S_EMPTY, 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger3( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger3.WriteLong( self.m_iId );
		hunger3.End();
		
		return true;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool fResult = self.DefaultDeploy( self.GetV_Model( COLT_V_MODEL ), self.GetP_Model( COLT_P_MODEL ), M1911A1_DRAW, "onehanded" );
			
		float deployTime = 1.03f;
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
		
		if( self.m_iClip <= 0 )
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
		
		pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		pPlayer.pev.effects |= EF_MUZZLEFLASH;
		pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( self.m_iClip == 0 )
		{
			self.SendWeaponAnim( M1911A1_SHOOT_EMPTY, 0, 0 );
			pPlayer.m_flNextAttack = 0.4;
		}
		else if( self.m_iClip > 0 )
		{
			self.SendWeaponAnim( M1911A1_SHOOT, 0, 0 );
			pPlayer.pev.waterlevel == WATERLEVEL_HEAD ? 
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2 :
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.135;
		}
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, COLT_S_FIRE1, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
			case 1: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, COLT_S_FIRE2, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
		}
		
		Vector vecSrc	 = pPlayer.GetGunPosition();
		Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		int m_iBulletDamage = Math.RandomLong( 10, 13 );

		pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, ( pPlayer.pev.waterlevel == WATERLEVEL_HEAD ) ? 2048 : 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, m_iBulletDamage );

		if( self.m_iClip == 0 && pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}

		pPlayer.pev.punchangle.x += Math.RandomFloat( -1.9, -1.5 );

		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		
		GetDefaultShellInfo( pPlayer, vecShellVelocity, vecShellOrigin, 23, 7, -7 );
		
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
		if( self.m_iClip < COLT_MAX_CLIP )
		{
			BaseClass.Reload();
			m_iShotsFired = 0;
		}

		( self.m_iClip == 0 ) ? self.DefaultReload( COLT_MAX_CLIP, M1911A1_RELOAD_EMPTY, 3.16, 0 ) : self.DefaultReload( COLT_MAX_CLIP, M1911A1_RELOAD, 2.666, 0 );
	}
	
	void WeaponIdle()
	{
		//Julcoool
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
		{
			return;
		}
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = M1911A1_IDLE;
			break;
			
			case 1: iAnim = M1911A1_FIDGET1;
			break;

			case 2: iAnim = M1911A1_FIDGET2;
			break;

			case 3: iAnim = M1911A1_FIDGET3;
			break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponM1911::CM1911", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
