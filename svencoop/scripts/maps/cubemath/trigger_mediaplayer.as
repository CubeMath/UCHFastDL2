class trigger_mediaplayer : ScriptBaseEntity {

	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
		g_SoundSystem.PrecacheSound( self.pev.message );
	}
	
	void Spawn() { Precache(); }
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		g_SoundSystem.PlaySound( self.edict(), CHAN_STATIC, self.pev.message, 1.0f, ATTN_NONE );
	}
}

void RegisterTriggerMediaPlayerEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_mediaplayer", "trigger_mediaplayer" );
}
