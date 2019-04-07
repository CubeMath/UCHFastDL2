// Base class for all TH weapons
// Author: GeckonCZ

class CBaseCustomWeapon : ScriptBasePlayerWeaponEntity
{
	// Possible workaround for the SendWeaponAnim() access violation crash.
	// According to R4to0 this seems to provide at least some improvement.
	// GeckoN: TODO: Remove this once the core issue is addressed.
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}
	
	void GetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity,
		Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale )
	{
		Vector vecForward, vecRight, vecUp;
		
		g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );
		
		const float fR = Math.RandomFloat( 50, 70 );
		const float fU = Math.RandomFloat( 100, 150 );
	 
		for( int i = 0; i < 3; ++i )
		{
			ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
			ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
		}
	}

	// Helper function - creates a dynamic light (DLIGHT)
	void DynamicLight( Vector vecPos, int radius, int r, int g, int b, int8 life, int decay )
	{
		NetworkMessage THDL( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			THDL.WriteByte( TE_DLIGHT );
			THDL.WriteCoord( vecPos.x );
			THDL.WriteCoord( vecPos.y );
			THDL.WriteCoord( vecPos.z );
			THDL.WriteByte( radius );
			THDL.WriteByte( int(r) );
			THDL.WriteByte( int(g) );
			THDL.WriteByte( int(b) );
			THDL.WriteByte( life );
			THDL.WriteByte( decay );
		THDL.End();
	}
	
	// GeckoN: UNUSED
	/*void TheyHungerSmoke( Vector pos, string sprite = "sprites/wep_smoke_02.spr",
		int scale = 5, int frameRate = 15, NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null)
	{
		NetworkMessage TheyHungerSmoke( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
			TheyHungerSmoke.WriteByte( TE_SMOKE );
			TheyHungerSmoke.WriteCoord( pos.x );
			TheyHungerSmoke.WriteCoord( pos.y );
			TheyHungerSmoke.WriteCoord( pos.z );
			TheyHungerSmoke.WriteShort( g_EngineFuncs.ModelIndex( sprite ) );
			TheyHungerSmoke.WriteByte( scale );
			TheyHungerSmoke.WriteByte( frameRate );
		TheyHungerSmoke.End();
	}*/

	// GeckoN: UNUSED
	/*void TheyHungerDynamicTracer( Vector start, Vector end,
		NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null )
	{
		NetworkMessage THDT( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
			THDT.WriteByte( TE_TRACER );
			THDT.WriteCoord( start.x );
			THDT.WriteCoord( start.y );
			THDT.WriteCoord( start.z );
			THDT.WriteCoord( end.x );
			THDT.WriteCoord( end.y );
			THDT.WriteCoord( end.z );
		THDT.End();
	}*/
}

class CBaseCustomAmmo : ScriptBasePlayerAmmoEntity
{
	protected string m_strModel = "models/error.mdl";
	protected string m_strName;
	protected int m_iAmount = 0;
	protected int m_iMax = 0;
	
	protected string m_strPickupSound = "items/gunpickup2.wav";

	void Precache()
	{
		g_Game.PrecacheModel( m_strModel );
		
		g_SoundSystem.PrecacheSound( m_strPickupSound );
	}
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, m_strModel );
		BaseClass.Spawn();
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( m_iAmount, m_strName, m_iMax, false ) == -1 )
			return false;
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, m_strPickupSound, 1, ATTN_NORM );
		
		return true;
	}
}