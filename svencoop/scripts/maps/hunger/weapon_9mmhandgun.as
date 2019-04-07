/* weapon 9mm handgun for they hunger co-op.
 * WIP - Do not release. Author: Dynamite.
 * ==Specs==
 * Model: models/hunger/p_hunger9mmhandgun, v_hunger9mmhandgun, w_hunger9mmhandgun.
 * Sound: sound/hunger/thweapons/.
 * 
 * Ammo: 17 / ?.
*/


enum th_9mmhandgun
{
	PIS_IDLE1 = 0,
	PIS_IDLE2,
	PIS_IDLE3,
	PIS_SHOOT,
	PIS_NOSHOOT,
	PIS_RELOAD,
	PIS_RELOAD_NOSHOT,
	PIS_DRAW,
	PIS_HOLSTER,
	PIS_ADDSILENCER,
	PIS_REMSILENCER
};

class weapon_9mmhandgun : ScriptBasePlayerWeaponEntity
{	
	int PISTOL_MAX_CLIP = 17;
	string gun_p = "models/hunger/p_hunger9mmhandgun.mdl";
	string gun_v = "models/hunger/v_hunger9mmhandgun.mdl";
	string gun_w = "models/hunger/w_hunger9mmhandgun.mdl";
	
	void Spawn() {
		Precache();
		
		
		/* This fills the clip with X amount of ammo so it ain't empty when you pick it up.
		* Ammo more than 'info.iMaxClip' will be added to the extra ammo. */
		self.m_iDefaultAmmo = PISTOL_MAX_CLIP;
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( gun_w ) );
		self.FallInit();
	}

	void Precache() {
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( gun_p );
		g_Game.PrecacheModel( gun_v );
		g_Game.PrecacheModel( gun_w );
		g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/pl_gun1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pl_gun2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pl_gun3.wav" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		g_SoundSystem.PrecacheSound( "items/9mmclip2.wav" );
	}

	bool GetItemInfo( ItemInfo& out info ) {
		//info.pszName = pev.classname;
		//info.pszAmmo1 = "9mm";
		info.iMaxAmmo1 = 36;
		//info.pszAmmo2 = null;
		info.iMaxAmmo2 = -1;
		info.iMaxClip = 17;
		info.iFlags = 0;
		/* Slot in HUD. Crowbar = 0.
		 * Position in HUD. Crowbar = 1. */
		info.iSlot = 1;
		info.iPosition = 8; // this is dumb. Try to define this elsewhere. (solokiller says it cannot be)
		info.iWeight = 6; // ^
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer ) {
		if ( BaseClass.AddToPlayer( pPlayer ) )
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}

	bool Deploy() {
		return self.DefaultDeploy( self.GetV_Model( gun_v ), self.GetP_Model( gun_p ), PIS_DRAW, "9mmhandgun" );
	}

	float WeaponTimeBase() {
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack() {
		
		if( self.m_iClip <= 0 )
		{
			// Play empty sound.
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "weapons/dryfire1.wav", 0.6, ATTN_NORM, 0, 100 );
			self.m_flNextPrimaryAttack =  WeaponTimeBase() + 0.15;
			return;
		}
		
		self.m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		self.m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.SendWeaponAnim( PIS_SHOOT, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "weapons/pl_gun3.wav", 0.8, ATTN_NORM, 0, 100 );
		
		// firing animation
		self.m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
			Vector vecSrc	 = self.m_pPlayer.GetGunPosition();
		Vector vecAiming = self.m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		self.m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 4096, BULLET_PLAYER_9MM, 2 );
		
		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.3;
		if (self.m_flNextPrimaryAttack < WeaponTimeBase())
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3;
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( self.m_pPlayer.random_seed,  10, 15 );
		
		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_7DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_7DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, self.m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_357 );
			}
		}
		--self.m_iClip;
	}
	
	
	/*void SecondaryAttack() {
		if( pev->body == 1 )
		{
			SendWeaponAnim( PIS_REMSILENCER, 0, 1 );
			m_iNextAnimation = 2;
			m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + 1.5;
		}
		
		m_flNextPrimaryAttack = m_flNextSecondaryAttack = UTIL_WeaponTimeBase() + 2;
		
		return;
		
	}*/
		

	void Reload() {
		/* How much ammo to reload, animation name, time(?), ?.
		* 9mm handgun reload animation is 71 frames @ 25 fps = 2.84s for reload.
		* But I round it up to 2.9. */
		self.DefaultReload( PISTOL_MAX_CLIP, PIS_RELOAD, 2.9, 0 );
		
		// Reload for 3rd person view.
		BaseClass.Reload();
	}

	void WeaponIdle() {
		self.ResetEmptySound();
		
		self.m_pPlayer.GetAutoaimVector( AUTOAIM_8DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		switch ( g_PlayerFuncs.SharedRandomLong( self.m_pPlayer.random_seed,  0, 2 ) )
		{
			case 0:	
				iAnim = PIS_IDLE1;	
				break;
			case 1:
				iAnim = PIS_IDLE2;
				break;
			case 2:
				iAnim = PIS_IDLE3;
				break;
		}
		
		self.SendWeaponAnim( iAnim );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( self.m_pPlayer.random_seed,  10, 15 );// how long till we do this again.
	}
}

