class func_wall_custom : ScriptBaseEntity {

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "minhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		}
		else if( szKey == "maxhullsize" ) {
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache() { BaseClass.Precache(); }
	
	void Spawn() {
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_BBOX;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
		
		if( self.pev.spawnflags & 1 != 0 ){
			TurnOff();
		}
		
		SetThink( ThinkFunction( this.KeepActive ) );
        self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void KeepActive(){
        self.pev.nextthink = g_Engine.time + 1.0f;
	}
	
	void Touch( CBaseEntity@ pOther ) {}
	
	void TurnOn(){
		self.pev.solid = SOLID_BBOX;
	}
	
	void TurnOff(){
		self.pev.solid = SOLID_NOT;
	}
	
	bool IsOn(){
		return self.pev.solid == SOLID_BBOX;
	}
	
	//I couldn't find CBaseEntity.ShouldToggle( useType, currentState )
	//so I wrote this Function!
	bool ShouldToggle( USE_TYPE useType, bool currentState ) {
		if ( useType != USE_TOGGLE && useType != USE_SET ) {
			if ( (currentState && useType == USE_ON) || (!currentState && useType == USE_OFF) )
				return false;
		}
		return true;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		if( ShouldToggle( useType, IsOn() ) ){
			if( IsOn() ) TurnOff();
			else TurnOn();
		}
	}
}

void RegisterFuncWallCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "func_wall_custom", "func_wall_custom" );
}
