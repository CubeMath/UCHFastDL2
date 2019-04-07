
class item_airbubble : ScriptBaseEntity {

	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
		g_Game.PrecacheModel( "sprites/bubble.spr" );
		g_SoundSystem.PrecacheSound( "debris/bustflesh1.wav" );
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_TRIGGER;
		self.pev.scale 			= 4.0;
		self.pev.rendermode		= 2;
		self.pev.renderamt		= 255;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetModel( self, "sprites/bubble.spr" );
		g_EntityFuncs.SetSize( self.pev, Vector(-32, -32, -32), Vector(32, 32, 32) );
		
		SetThink( ThinkFunction( this.letsRespawn ) );
	}
	
	void letsRespawn() {
		self.pev.renderamt = 255;
		self.pev.solid = SOLID_TRIGGER;
	}
	
	void Touch( CBaseEntity@ pOther ) {
		if( pOther is null || !pOther.IsPlayer() ) return;
		
		g_SoundSystem.EmitSoundDyn( pOther.edict(), CHAN_STATIC, "debris/bustflesh1.wav", 1.0f, ATTN_NONE, 0, 120 );
		
		pOther.pev.air_finished = g_Engine.time + 12.0;
		self.pev.solid = SOLID_NOT;
		self.pev.renderamt = 0;
        self.pev.nextthink = g_Engine.time + 1.0f;
		
		for(int i = 0; i < 20; ++i){
			CBaseEntity@ pEnt = g_EntityFuncs.Create("item_miniairbubble", self.pev.origin, Vector(0, 0, 0), false);
			pEnt.pev.velocity.x = Math.RandomFloat(-128.0f, 128.0f);
			pEnt.pev.velocity.y = Math.RandomFloat(-128.0f, 128.0f);
			pEnt.pev.velocity.z = Math.RandomFloat(-128.0f, 128.0f);
		}
	}
}


class item_miniairbubble : ScriptBaseEntity {
	
	private float lifeTime;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_FLY;
		self.pev.solid 			= SOLID_TRIGGER;
		self.pev.rendermode		= 2;
		self.pev.renderamt		= 255;
		self.pev.scale 			= 0.5;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetModel( self, "sprites/bubble.spr" );
		g_EntityFuncs.SetSize( self.pev, Vector(-8, -8, -8), Vector(8, 8, 8) );
		
		lifeTime = g_Engine.time + 1.0f;
		SetThink( ThinkFunction( this.ownThink ) );
        self.pev.nextthink = g_Engine.time + 0.05f;
	}
	
	void ownThink() {
		if(lifeTime < g_Engine.time + 1.0f) {
			if(lifeTime < g_Engine.time){
				g_EntityFuncs.Remove( self );
			}
			self.pev.renderamt = (lifeTime - g_Engine.time) * 255.0f;
		}
        self.pev.nextthink = g_Engine.time + 0.01f;
	}
}

void RegisterAirbubbleCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "item_airbubble", "item_airbubble" );
	g_CustomEntityFuncs.RegisterCustomEntity( "item_miniairbubble", "item_miniairbubble" );
}
