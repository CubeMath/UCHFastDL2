
class item_healthkit2 : ScriptBasePlayerItemEntity {

	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
		g_Game.PrecacheModel( "models/hlclassic/w_medkit.mdl" );
		g_SoundSystem.PrecacheSound( "items/smallmedkit1.wav" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	void Spawn() {
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/hlclassic/w_medkit.mdl" );
		
		BaseClass.Spawn();
	}
	
	void Touch( CBaseEntity@ pOther ) {
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() ) return;
		
		if(pOther.pev.health < pOther.pev.max_health){
			NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pOther.edict() );
				message.WriteString( "item_healthkit" );
			message.End();
			
			float juice = g_EngineFuncs.CVarGetFloat( "sk_healthkit" );
			float juice2 = juice - (pOther.pev.max_health - pOther.pev.health);
			
			pOther.TakeHealth( juice, DMG_GENERIC );
			
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "items/smallmedkit1.wav", 1.0f, ATTN_NORM );
			
			if(juice2 > 0.0f){
				int iGive = int(ceil(juice2));
				
				pOther.GiveAmmo( iGive, "health", 100 );
			}
			
			g_EntityFuncs.Remove( self );
		}else if( pOther.GiveAmmo( int(ceil(g_EngineFuncs.CVarGetFloat( "sk_healthkit" ))), "health", 100 ) != -1 ){
			NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pOther.edict() );
				message.WriteString( "item_healthkit" );
			message.End();
			
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			
			g_EntityFuncs.Remove( self );
		}
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		Touch( pActivator );
	}
}

void RegisterItemHealthkit2CustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "item_healthkit2", "item_healthkit2" );
	g_ItemRegistry.RegisterItem( "item_healthkit2", "" );
}
