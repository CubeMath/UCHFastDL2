// Author: KernCore
// Modified by: GeckonCZ

#include "baseweapon"

namespace THWeaponM16A1
{

const string WEAPON_NAME			= "weapon_m16a1";
const string AMMO_DROP_NAME			= "ammo_556clip";
const string AMMO_TYPE				= "556";

const int M16A1_MAX_CARRY   		= 600;
const int M16A1_DEFAULT_GIVE		= 100;
const int M16A1_MAX_CLIP    		= 20;
const int M16A1_WEIGHT      		= 25;

enum TheyHungerM16A1Animation_e
{
	M16A1_IDLE_FIDGET = 0,
	M16A1_IDLE,
	M16A1_RELOAD,
	M16A1_RELOAD_EMPTY,
	M16A1_DEPLOY,
	M16A1_SHOOT
};

class CM16A1 : CBaseCustomWeapon
{
	string M16A1_W_MODEL = "models/hunger/weapons/m16a1/w_m16.mdl";
	string M16A1_V_MODEL = "models/hunger/weapons/m16a1/v_m16.mdl";
	string M16A1_P_MODEL = "models/hunger/weapons/m16a1/p_m16.mdl";

	string M16A1_S_BURST = "hunger/weapons/m16a1/m16_burst.wav";
	string M16A1_S_FIRE1 = "hunger/weapons/m16a1/m16_fire1.wav";
	string M16A1_S_FIRE2 = "hunger/weapons/m16a1/m16_fire2.wav";
	string M16A1_S_FIRE3 = "hunger/weapons/m16a1/m16_fire3.wav";

	int m_iShotsFired;
	
	int m_iShell;

	int m_iBurstLeft = 0;
	int m_iBurstCount = 0;
	
	float m_flNextBurstFireTime = 0;
	bool m_isSemiAuto;
	bool m_isBurstFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, M16A1_W_MODEL );

		self.m_iDefaultAmmo = M16A1_DEFAULT_GIVE;
		m_iShotsFired = 0;

		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( M16A1_W_MODEL );
		g_Game.PrecacheModel( M16A1_V_MODEL );
		g_Game.PrecacheModel( M16A1_P_MODEL );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( M16A1_S_BURST );
		g_SoundSystem.PrecacheSound( M16A1_S_FIRE1 );
		g_SoundSystem.PrecacheSound( M16A1_S_FIRE2 );
		g_SoundSystem.PrecacheSound( M16A1_S_FIRE3 );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m16a1/m16_boltcatch.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m16a1/m16_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m16a1/m16_magout.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/m16a1/m16_safety.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= M16A1_MAX_CARRY;
		info.iAmmo1Drop	= M16A1_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip	= M16A1_MAX_CLIP;
		info.iSlot   	= 2;
		info.iPosition	= 7;
		info.iFlags 	= 0;
		info.iWeight	= M16A1_WEIGHT;
	   
		return true;
	}
   
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger2( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger2.WriteLong( self.m_iId );
		hunger2.End();
		
		return true;
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

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
 
	bool Deploy()
	{
		bool fResult = self.DefaultDeploy( self.GetV_Model( M16A1_V_MODEL ), self.GetP_Model( M16A1_P_MODEL ), M16A1_DEPLOY, "m16" );

		float deployTime = 0.56;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;

		return fResult;
	}

	void Holster( int skipLocal = 0 )
	{
		//Cancel burst.
		self.m_fInReload = false;
		m_iBurstLeft = 0;
		m_iShotsFired = 0;

		BaseClass.Holster( skipLocal );
	}

	/**
	*   Fires a single bullet, sets correct effects and settings.
	*/
	void FireABullet()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		self.SendWeaponAnim( M16A1_SHOOT, 0, 0 );

		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_SAW );

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
		}

		TraceResult tr;

		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir;

		if( m_isBurstFire == true )
		{
			vecDir = vecAiming + x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x += Math.RandomLong( -2, -1 );
		}
		if( m_isSemiAuto == true )
		{
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x += Math.RandomLong( -2, -1 );
		}
 
		Vector vecEnd   = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 7, -7 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );

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

	private void PlayFireSound()
	{
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, M16A1_S_FIRE1, Math.RandomFloat( 0.96, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, M16A1_S_FIRE2, Math.RandomFloat( 0.96, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
			case 2: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, M16A1_S_FIRE3, Math.RandomFloat( 0.96, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) ); break;
		}
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

		//Julcoool
		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.14;

		PlayFireSound();
		
		FireABullet();
		m_isSemiAuto = true;
		m_isBurstFire = false;
	}

	void SecondaryAttack()
	{
		CBasePlayer@ pPlayer = m_pPlayer;
		
		if( pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		//Fire at most 3 bullets.
		m_iBurstCount = Math.min( 3, self.m_iClip );
		m_iBurstLeft = m_iBurstCount - 1;
 
		m_flNextBurstFireTime = WeaponTimeBase() + 0.055;
		//Prevent primary attack before burst finishes. Might need to be finetuned.
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
		   
		if( m_iBurstCount == 3 )
		{
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, M16A1_S_BURST, Math.RandomFloat( 0.99, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x0f ) );
		}
		else
		{
			//Fewer than 3 bullets left, play individual fire sounds.
			PlayFireSound();
		}

		FireABullet();
		m_isSemiAuto = false;
		m_isBurstFire = true;
	}

	void Reload()
	{
		m_iBurstLeft = 0;
		m_iShotsFired = 0;
	   
		if( self.m_iClip < M16A1_MAX_CLIP )
		{
			BaseClass.Reload();
		}

		self.m_iClip == 0 ? self.DefaultReload( M16A1_MAX_CLIP, M16A1_RELOAD_EMPTY, 2.56, 0 ) : self.DefaultReload( M16A1_MAX_CLIP, M16A1_RELOAD, 2.06, 0 );
	}

	//Overridden to prevent WeaponIdle from being blocked by holding down buttons.
	void ItemPostFrame()
	{
		//If firing bursts, handle next shot.
		if( m_iBurstLeft > 0 )
		{
			if( m_flNextBurstFireTime < WeaponTimeBase() )
			{
				if( self.m_iClip <= 0 )
				{
					m_iBurstLeft = 0;
					return;
				}
				else
				{
					--m_iBurstLeft;
				}

				if( m_iBurstCount < 3 )
				{
					PlayFireSound();
				}

				FireABullet();

				if( m_iBurstLeft > 0 )
					m_flNextBurstFireTime = WeaponTimeBase() + 0.1;
				else
					m_flNextBurstFireTime = 0;
			}

			//While firing a burst, don't allow reload or any other weapon actions. Might be best to let some things run though.
			return;
		}

		BaseClass.ItemPostFrame();
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
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = M16A1_IDLE_FIDGET;
			break;
			
			case 1: iAnim = M16A1_IDLE;
			break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponM16A1::CM16A1", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons", AMMO_TYPE, "", AMMO_DROP_NAME, "" );
}

} // end of namespace
