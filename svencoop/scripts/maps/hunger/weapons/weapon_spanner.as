// Author: GeckonCZ

#include "baseweapon"

namespace THWeaponSpanner
{

const string WEAPON_NAME			= "weapon_spanner";

const int SPANNER_WEIGHT 	  		= 0;

enum spanner_e
{
	SPANNER_IDLE = 0,
	SPANNER_ATTACK,
	SPANNER_ATTACK2,
	SPANNER_FIXIT,
	SPANNER_DRAW,
	SPANNER_HOLSTER,
	SPANNER_IDLE2,
	SPANNER_IDLE3
};

class CSpanner : CBaseCustomWeapon
{
	string SPANNER_W_MODEL = "models/hunger/weapons/spanner/w_spanner.mdl";
	string SPANNER_V_MODEL = "models/hunger/weapons/spanner/v_spanner.mdl";
	string SPANNER_P_MODEL = "models/hunger/weapons/spanner/p_spanner.mdl";
	
	int m_iSwing;
	
	TraceResult m_trHit;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( SPANNER_W_MODEL ) );
		self.m_iClip			= -1;
		self.m_flCustomDmg		= self.pev.dmg;

		BaseClass.Spawn();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( SPANNER_V_MODEL );
		g_Game.PrecacheModel( SPANNER_W_MODEL );
		g_Game.PrecacheModel( SPANNER_P_MODEL );

		g_SoundSystem.PrecacheSound( "weapons/pwrench_hit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_hit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_hitbod1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_hitbod2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_hitbod3.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_miss1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pwrench_miss2.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iAmmo1Drop		= -1;
		info.iMaxAmmo2		= -1;
		info.iAmmo2Drop		= -1;
		info.iMaxClip		= WEAPON_NOCLIP;
		info.iSlot			= 0;
		info.iPosition		= 5;
		info.iFlags			= ITEM_FLAG_ESSENTIAL;
		info.iWeight		= SPANNER_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger1( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			hunger1.WriteLong( self.m_iId );
		hunger1.End();

		return true;
	}

	bool Deploy()
	{
		bool fResult = self.DefaultDeploy( self.GetV_Model( SPANNER_V_MODEL ), self.GetP_Model( SPANNER_P_MODEL ), SPANNER_DRAW, "crowbar" );
		
		float deployTime = 0.66f;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
		
		return fResult;
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false;// cancel any reload in progress.

		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5; 

		m_pPlayer.pev.viewmodel = "";
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
		CBasePlayer@ pPlayer = m_pPlayer;
		
		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( pPlayer.pev.v_angle );
		Vector vecSrc	= pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 32;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch ( ( m_iSwing++ ) % 2 )
				{
				case 0: self.SendWeaponAnim( SPANNER_ATTACK ); break;
				case 1: self.SendWeaponAnim( SPANNER_ATTACK2 ); break;
				}
				self.m_flNextPrimaryAttack = g_Engine.time + 0.66f;
				self.m_flTimeWeaponIdle = g_Engine.time + 1.0f;
				
				// play wiff or swish sound
				// GeckoN: Use slightly higher pitch for the spanner
				switch ( Math.RandomLong( 0, 1 ) )
				{
				case 0: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_miss1.wav", 1, ATTN_NORM, 0, 106 + Math.RandomLong( 0, 8 ) );
				case 1: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_miss2.wav", 1, ATTN_NORM, 0, 106 + Math.RandomLong( 0, 8 ) );
				}

				// player "shoot" animation
				pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch ( ( m_iSwing++ ) % 2 )
			{
			case 0: self.SendWeaponAnim( SPANNER_ATTACK ); break;
			case 1: self.SendWeaponAnim( SPANNER_ATTACK2 ); break;
			}
			self.m_flTimeWeaponIdle = g_Engine.time + 0.66f;

			// player "shoot" animation
			pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			// AdamR: Custom damage option
			float flDamage = 10;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;
			// AdamR: End

			g_WeaponFuncs.ClearMultiDamage();

			// first swing does full damage
			pEntity.TraceAttack( pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
	
			g_WeaponFuncs.ApplyMultiDamage( pPlayer.pev, pPlayer.pev );

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = g_Engine.time + 0.35f;

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					// aone
					if( pEntity.IsPlayer() )		// lets pull them
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}
					// end aone
					// play thwack or smack sound
					switch ( Math.RandomLong( 0, 2 ) )
					{
					case 0: g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_hitbod1.wav", 1, ATTN_NORM ); break;
					case 1: g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_hitbod2.wav", 1, ATTN_NORM ); break;
					case 2: g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_hitbod3.wav", 1, ATTN_NORM ); break;
					}
					pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextPrimaryAttack = g_Engine.time + 0.30f;

				// also play crowbar strike
				switch( Math.RandomLong( 0, 1 ) )
				{
				case 0: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				case 1: g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "weapons/pwrench_hit2.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				}
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.2;

			pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flTime;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0:	iAnim = SPANNER_IDLE; flTime = 2.15f; break;
			case 1: iAnim = SPANNER_IDLE2; flTime = 1.86f; break;
			case 2: iAnim = SPANNER_IDLE3; flTime = 4.00f; break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = g_Engine.time + flTime;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THWeaponSpanner::CSpanner", WEAPON_NAME );
	g_ItemRegistry.RegisterWeapon( WEAPON_NAME, "hunger/weapons" );
}

} // end of namespace
