/*  
* The original Half-Life version of the 357
*/

const int PYTHON_DEFAULT_GIVE = 6;
const int _357_MAX_CARRY = 36;
const int PYTHON_MAX_CLIP = 6;
const int PYTHON_WEIGHT = 15;

enum PythonAnimation
{
	PYTHON_IDLE1 = 0,
	PYTHON_FIDGET,
	PYTHON_FIRE1,
	PYTHON_RELOAD,
	PYTHON_HOLSTER,
	PYTHON_DRAW,
	PYTHON_IDLE2,
	PYTHON_IDLE3
};

class weapon_hl357 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	bool m_fInZoom;
	int m_iShell;
	int	m_iSecondaryAmmo;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hlclassic/w_357.mdl" );

		self.m_iDefaultAmmo = PYTHON_DEFAULT_GIVE;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hl357.txt" );

		g_Game.PrecacheModel( "models/hlclassic/v_357.mdl" );
		g_Game.PrecacheModel( "models/hlclassic/w_357.mdl" );
		g_Game.PrecacheModel( "models/hlclassic/p_357.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_Game.PrecacheModel( "models/w_357ammobox.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              

		//These are played by the model, needs changing there
		g_SoundSystem.PrecacheSound( "hlclassic/items/clipinsert1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/items/cliprelease1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/items/guncock1.wav" );

		g_SoundSystem.PrecacheSound( "hlclassic/weapons/357_reload1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/357_cock1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/357_shot1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/357_shot2.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
		
		@m_pPlayer = pPlayer;
		
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		
		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= _357_MAX_CARRY;
		info.iAmmo1Drop = PYTHON_MAX_CLIP;
		info.iMaxAmmo2	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip 	= PYTHON_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= PYTHON_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/hlclassic/v_357.mdl" ), self.GetP_Model( "models/hlclassic/p_357.mdl" ), PYTHON_DRAW, "python" );
	}

	void Holster(int skiplocal){
		
		self.m_fInReload = false;
		
		if( m_fInZoom )
		{
			SecondaryAttack();
		}
		
		//m_pPlayer.m_flNextAttack = g_Engine.time + 1.0; 
		
		BaseClass.Holster( skiplocal );
	}
	
	void PrimaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}
		
		self.SendWeaponAnim( PYTHON_FIRE1, 0, 0 );
		
		switch( Math.RandomLong( 0, 1 ) ){
		case 0:
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/357_shot1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
			break;
		case 1:
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/357_shot2.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
			break;
		}
		
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;
		
		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_357, 0 );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		
		self.m_flNextPrimaryAttack = g_Engine.time + 0.75;

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		TraceResult tr;
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 8192;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_357 );
			}
		}
		
		m_pPlayer.pev.punchangle.x = -10.0;
	}

	void SecondaryAttack()
	{
		if( m_pPlayer.pev.fov != 0 )
		{
			m_fInZoom = false;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 0; // 0 means reset to default fov
		}
		else if( m_pPlayer.pev.fov != 40 )
		{
			m_fInZoom = true;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 40;
		}
		self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
	}

	void Reload()
	{
		if( m_pPlayer.pev.fov != 0 )
		{
			m_fInZoom = false;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 0; // 0 means reset to default fov
		}
		
		self.DefaultReload( PYTHON_MAX_CLIP, PYTHON_RELOAD, 3.2, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );

		if(flRand <= 0.5)
		{
			iAnim = PYTHON_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + (70.0/30.0);
		}
		if(flRand <= 0.7)
		{
			iAnim = PYTHON_IDLE2;
			self.m_flTimeWeaponIdle = g_Engine.time + (60.0/30.0);
		}
		if(flRand <= 0.9)
		{
			iAnim = PYTHON_IDLE3;
			self.m_flTimeWeaponIdle = g_Engine.time + (88.0/30.0);
		}
		else
		{
			iAnim = PYTHON_FIDGET;
			self.m_flTimeWeaponIdle = g_Engine.time + (170.0/30.0);
		}

		self.SendWeaponAnim( iAnim );
	}
}

string GetHLPYTHONName()
{
	return "weapon_hl357";
}

void RegisterHLPYTHON()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hl357", GetHLPYTHONName() );
	g_ItemRegistry.RegisterWeapon( GetHLPYTHONName(), "hl_weapons", "357", "", "ammo_357", "" );
}
