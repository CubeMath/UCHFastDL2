
const int DROPPER_WEIGHT = 15;

enum DropperAnimation
{
	DROPPER_IDLE1 = 0,
	DROPPER_FIDGET,
	DROPPER_FIRE1,
	DROPPER_RELOAD,
	DROPPER_HOLSTER,
	DROPPER_DRAW,
	DROPPER_IDLE2,
	DROPPER_IDLE3
};

class weapon_dropper : ScriptBasePlayerWeaponEntity
{
	void Spawn() {
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_357.mdl" );

		self.FallInit();
	}

	void Precache() {
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/hl/v_357.mdl" );
		g_Game.PrecacheModel( "models/hl/w_357.mdl" );
		g_Game.PrecacheModel( "models/hl/p_357.mdl" );

		g_Game.PrecacheModel( "models/shell.mdl" );

		g_Game.PrecacheModel( "models/w_357ammobox.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              

		//These are played by the model, needs changing there
		g_SoundSystem.PrecacheSound( "hl/items/clipinsert1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/cliprelease1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/guncock1.wav" );

		g_SoundSystem.PrecacheSound( "hl/weapons/357_reload1.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/357_shot1.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/357_shot2.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer ) {
		if( BaseClass.AddToPlayer( pPlayer ) ) {
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	bool PlayEmptySound() {
		if( self.m_bPlayEmptySound ) {
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( self.m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info ) {
		info.iMaxAmmo1 	= -1;
		info.iMaxAmmo2	= -1;
		info.iMaxClip 	= -1;
		info.iSlot 		= 0;
		info.iPosition 	= 5;
		info.iFlags 	= 0;
		info.iWeight 	= DROPPER_WEIGHT;

		return true;
	}

	bool Deploy() {
		return self.DefaultDeploy( self.GetV_Model( "models/hl/v_357.mdl" ), self.GetP_Model( "models/hl/p_357.mdl" ), DROPPER_DRAW, "weapon_custom" );
	}

	void Holster(int skiplocal) {
		
		self.m_fInReload = false;
		
		BaseClass.Holster( skiplocal );
	}
	
	void PrimaryAttack() {
		
		self.SendWeaponAnim( DROPPER_FIRE1, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( self.m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_shot1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );

		self.m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		self.m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		// player "shoot" animation
		self.m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = self.m_pPlayer.GetGunPosition();
		Vector vecAiming = self.m_pPlayer.GetAutoaimVector( 0.0 );
		
		
		self.m_flNextPrimaryAttack = g_Engine.time + 0.4;

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( self.m_pPlayer.random_seed,  10, 15 );
		
	}

	void SecondaryAttack() {
		self.m_flNextSecondaryAttack = g_Engine.time + 0.05;
	}

	void Reload() {
		self.DefaultReload( 0, DROPPER_RELOAD, 1.5, 0 );

		BaseClass.Reload();
	}
	
	void FinishReload() {
		self.m_iClip = -1;
	}

	void WeaponIdle() {
		self.ResetEmptySound();

		self.m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( self.m_pPlayer.random_seed, 0, 1 );

		if(flRand <= 0.5)
		{
			iAnim = DROPPER_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + (70.0/30.0);
		}
		if(flRand <= 0.7)
		{
			iAnim = DROPPER_IDLE2;
			self.m_flTimeWeaponIdle = g_Engine.time + (60.0/30.0);
		}
		if(flRand <= 0.9)
		{
			iAnim = DROPPER_IDLE3;
			self.m_flTimeWeaponIdle = g_Engine.time + (88.0/30.0);
		}
		else
		{
			iAnim = DROPPER_FIDGET;
			self.m_flTimeWeaponIdle = g_Engine.time + (170.0/30.0);
		}

		self.SendWeaponAnim( iAnim );
	}
}

string GetDropperName()
{
	return "weapon_dropper";
}

void RegisterDropper()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dropper", GetDropperName() );
	g_ItemRegistry.RegisterWeapon( GetDropperName(), "weapon_dropper", "357" );
}
