
class disco_drone : ScriptBaseEntity {
	
	array<EHandle> grenades;
	int currentArrIdx;
	int numberPeople;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() {
		BaseClass.Precache();
	}
	
	void Spawn() {
		Precache();
		
		self.pev.speed = 0;
		
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NOCLIP;

		g_EntityFuncs.SetModel(self, self.pev.model);
		g_EntityFuncs.SetSize(self.pev, self.pev.mins, self.pev.maxs);
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		
		currentArrIdx = 0;
		
		grenades.resize( 32 );
		
		SetThink( ThinkFunction( this.WaitThink ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void WaitThink(){
		if(isBossRunning == 1){
			SetThink( ThinkFunction( this.FlyToTargetThink ) );
		}
		self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	//TODO Need better Calculation
	void FlyToTargetThink() {
		
		numberPeople = 0;
		int lowestGrenadeAmount = 10;
		int lowestGrenadeCount = -1;
		
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;
			
			numberPeople += 1;
			if(lowestGrenadeAmount > pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex("Hand Grenade"))){
				lowestGrenadeAmount = pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex("Hand Grenade"));
				lowestGrenadeCount = 0;
			}else if(lowestGrenadeAmount == pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex("Hand Grenade"))){
				lowestGrenadeCount++;
			}
		}
		
		float x1 = 0.0f;
		float y1 = 0.0f;
		
		if(lowestGrenadeCount > 0 ){
			int targetGrenadeCount = Math.RandomLong( 0, lowestGrenadeCount );
			
			lowestGrenadeCount = 0;
			
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;
				
				if(lowestGrenadeAmount == pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex("Hand Grenade"))){
					lowestGrenadeCount++;
					
					if(lowestGrenadeCount > targetGrenadeCount){
						x1 = pPlayer.pev.origin.x;
						y1 = pPlayer.pev.origin.y;
						break;
					}
				}
			}
		}
		
		if(x1 == 0.0f && y1 == 0.0f){
			lowestGrenadeAmount = 10;
		}
		
		float circleSize = sqrt(Math.RandomFloat( 0.0f, 1.0f )) * 900.0f;
		float circleRoti = Math.RandomFloat( -3.14159265358979323846f, 3.14159265358979323846f );
		float x2 = sin(circleRoti) * circleSize;
		float y2 = cos(circleRoti) * circleSize;
		
		float speed = 64.0f + 32.0f * numberPeople;
		float x = (float(lowestGrenadeAmount) * x2 + float(10-lowestGrenadeAmount) * x1)/10.0f;
		float y = (float(lowestGrenadeAmount) * y2 + float(10-lowestGrenadeAmount) * y1)/10.0f;
		float distance = sqrt( (x-self.pev.origin.x)*(x-self.pev.origin.x) + (y-self.pev.origin.y)*(y-self.pev.origin.y) );
		
		if(distance < 0.01f) distance = 0.01f;
		
		self.pev.velocity.x = ((x-self.pev.origin.x)/distance)*speed;
		self.pev.velocity.y = ((y-self.pev.origin.y)/distance)*speed;
		
		SetThink( ThinkFunction( this.DropgrenadeThink1 ) );
		self.pev.nextthink = g_Engine.time + (distance/speed);
	}
	
	void DropgrenadeThink1() {
		self.pev.velocity.x = 0.0f;
		self.pev.velocity.y = 0.0f;
		
		SetThink( ThinkFunction( this.DropgrenadeThink2 ) );
		
		int np = numberPeople;
		if(np > 16) np = 16;
		self.pev.nextthink = g_Engine.time + 1.6f - 0.1f * float(np);
	}
	
	void DropgrenadeThink2() {
		int haveSpace = -1;
		
		currentArrIdx++;
		if(currentArrIdx >= 32){
			currentArrIdx = 0;
		}
		
		//Destroy Grenade-Ammo
		if( EHandle(grenades[currentArrIdx]).IsValid() ){
			g_EntityFuncs.Remove( EHandle(grenades[currentArrIdx]).GetEntity() );
		}
		
		//Create Grenade-Ammo
		grenades[currentArrIdx] = EHandle(g_EntityFuncs.Create("weapon_handgrenade", self.pev.origin, Vector(0, 0, 0), false));
		
		SetThink( ThinkFunction( this.FlyToTargetThink ) );
		int np = numberPeople;
		if(np > 16) np = 16;
		self.pev.nextthink = g_Engine.time + 1.6f - 0.1f * float(np);
	}
	
}

void RegisterDiscoDroneCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "disco_drone", "disco_drone" );
}
