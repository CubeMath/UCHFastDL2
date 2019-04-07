
class disco_breakable : ScriptBaseEntity {
	void Precache() {
		BaseClass.Precache();
		
		g_SoundSystem.PrecacheSound( "debris/metal1.wav" );
		g_SoundSystem.PrecacheSound( "debris/metal3.wav" );
	}
	
	void Spawn() {
		Precache();
		
		self.pev.solid = SOLID_BSP;
		self.pev.movetype = MOVETYPE_PUSH;
		self.pev.takedamage	= DAMAGE_YES;
		
		g_EntityFuncs.SetModel(self, self.pev.model);
	}
	
	void DamageSound(){
		int pitch = PITCH_NORM;
		float fvol = Math.RandomFloat(0.75, 1.0);
		array<string> rgpsz = { "debris/metal1.wav", "debris/metal3.wav"};
		
		if (Math.RandomLong(0,2) == 0)
			pitch = 95 + Math.RandomLong(0,34);
		
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, rgpsz[Math.RandomLong(0,1)], fvol, ATTN_NORM, 0, pitch );
	}
	
	int TakeDamage(entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType){
		
		//Only explosives
		if (bitsDamageType == DMG_BLAST && pevAttacker.ClassNameIs( "player" )){
			//Give Player Points for Damaging this.
			if(isBossRunning == 1) pevAttacker.frags += int(ceil(flDamage/10.0f));
		}else{
			return 0;
		}
		
		DamageSound();
		
		return BaseClass.TakeDamage(pevInflictor, pevAttacker, flDamage, bitsDamageType);
	}
}

void RegisterDiscoBreakableCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_breakable", "disco_breakable" );
}
