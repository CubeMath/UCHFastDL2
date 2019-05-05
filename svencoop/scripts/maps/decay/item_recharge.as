
class Citem_recharge: ScriptBaseItemEntity {
  int    m_iJuice;
  int    m_iOn;          // 0 = off, 1 = startup, 2 = going
  float  m_flSoundTime;
  float  m_flNextCharge;
  CBaseEntity@ m_hActivator;
  
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		// if( 
      // szKey == "style" ||
      // szKey == "height" ||
      // szKey == "value1" ||
      // szKey == "value2" ||
      // szKey == "value3"
    // ) {
			// return true;
		// }
		// else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
  void Spawn(){
    Precache();
    
    self.pev.solid = SOLID_BBOX;
    self.pev.movetype = MOVETYPE_PUSH;
    m_flNextCharge = 0.0f;
    m_flSoundTime = 0.0f;
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetModel( self, "models/decay/hev.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector(-8, -8, -8), Vector(8, 8, 32) );
    
    m_iJuice = int(g_EngineFuncs.CVarGetFloat("sk_suitcharger"));
    self.pev.skin = 0;
    m_iOn = 0;
    
    SetUse( UseFunction( this.ChargeUse ) );
  }

  void Precache() {
    g_SoundSystem.PrecacheSound("items/suitcharge1.wav");
    g_SoundSystem.PrecacheSound("items/suitchargeno1.wav");
    g_SoundSystem.PrecacheSound("items/suitchargeok1.wav");
		g_Game.PrecacheModel( self, "models/decay/hev.mdl" );
		g_Game.PrecacheModel( self, "models/decay/hev_glass.mdl" );
  }
  
  // void Touch( CBaseEntity@ pActivator )	{
    // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.85, ATTN_NORM);
  // }
  
  void ChargeUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f) {
    // g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "HEV-DEBUG: ChargeUse\n" );
    
    // if it's not a player, ignore
    if (pActivator.pev.classname != "player") {
      return;
    }
    // Make sure that we have a caller
    if (pActivator is null) {
      return;
    }
    
    if(g_Engine.mapname == "dy_alien"){
      if (m_flSoundTime <= g_Engine.time) {
        m_flSoundTime = g_Engine.time + 0.62;
        g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeno1.wav", 0.85, ATTN_NORM);
      }
      return;
    }
    
    for(int i = 0; i < 5; i++){
      // if there is no juice left, turn it off
      // if (m_iJuice <= 0) {
        // Off();
      // }
      
      // if the player doesn't have the suit, or there is no juice left, make the deny noise
      if (m_iJuice <= 0) {
        self.pev.skin = 1;      
        if (m_flSoundTime <= g_Engine.time) {
          m_flSoundTime = g_Engine.time + 0.62;
          g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeno1.wav", 0.85, ATTN_NORM);
        }
        return;
      }
      
      // self.pev.nextthink = self.pev.ltime + 0.25;
      // SetThink( ThinkFunction( this.Off ) );

      // Time to recharge yet?

      // if (m_flNextCharge >= g_Engine.time) {
        // return;
      // }
      
      // Play the on sound or the looping charging sound
      // if (m_iOn == 0) {
        // m_iOn++;
        // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.85, ATTN_NORM);
        // m_flSoundTime = 0.56 + g_Engine.time;
      // }
      
      // if ((m_iOn == 1) && (m_flSoundTime <= g_Engine.time)) {
        // m_iOn++;
        // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitcharge1.wav", 0.85, ATTN_NORM);
      // }

      // charge the player
      if (pActivator.pev.armorvalue < pActivator.pev.armortype) {
        m_iJuice--;
        pActivator.pev.armorvalue += 1;

        if (pActivator.pev.armorvalue > pActivator.pev.armortype)
          pActivator.pev.armorvalue = pActivator.pev.armortype;
      }
    }
    
    g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.85, ATTN_NORM);
    
    // govern the rate of charge
    // m_flNextCharge = g_Engine.time + 0.1;
  }
  
  /*
  void Off() {
    if (m_iOn > 1){
      // Stop looping sound.
      g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.0, ATTN_NORM);
      // g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "items/suitcharge1.wav" );
    }
    
    m_iOn = 0;
    
    SetThink( null );
  }
  */
}

class Citem_healthcharger: ScriptBaseItemEntity {
  int    m_iJuice;
  int    m_iOn;          // 0 = off, 1 = startup, 2 = going
  float  m_flSoundTime;
  float  m_flNextCharge;
  CBaseEntity@ m_hActivator;
  
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		// if( 
      // szKey == "style" ||
      // szKey == "height" ||
      // szKey == "value1" ||
      // szKey == "value2" ||
      // szKey == "value3"
    // ) {
			// return true;
		// }
		// else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
  void Spawn(){
    Precache();
    
    self.pev.solid = SOLID_BBOX;
    self.pev.movetype = MOVETYPE_PUSH;
    m_flNextCharge = 0.0f;
    m_flSoundTime = 0.0f;
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetModel( self, "models/decay/health_charger_body.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector(-8, -8, -8), Vector(8, 8, 32) );
    
    m_iJuice = int(g_EngineFuncs.CVarGetFloat("sk_suitcharger"));
    self.pev.skin = 0;
    m_iOn = 0;
    
    SetUse( UseFunction( this.ChargeUse ) );
  }

  void Precache() {
    g_SoundSystem.PrecacheSound("items/medshot4.wav");
    g_SoundSystem.PrecacheSound("items/medshotno1.wav");
    g_SoundSystem.PrecacheSound("items/medcharge4.wav");
		g_Game.PrecacheModel( self, "models/decay/health_charger_body.mdl" );
		g_Game.PrecacheModel( self, "models/decay/health_charger_both.mdl" );
  }
  
  // void Touch( CBaseEntity@ pActivator )	{
    // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.85, ATTN_NORM);
  // }
  
  void ChargeUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f) {
    // g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "HEV-DEBUG: ChargeUse\n" );
    
    // if it's not a player, ignore
    if (pActivator.pev.classname != "player") {
      return;
    }
    // Make sure that we have a caller
    if (pActivator is null) {
      return;
    }
    
    if(g_Engine.mapname == "dy_alien"){
      if (m_flSoundTime <= g_Engine.time) {
        m_flSoundTime = g_Engine.time + 0.62;
        g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeno1.wav", 0.85, ATTN_NORM);
      }
      return;
    }
    
    for(int i = 0; i < 5; i++){
      // if there is no juice left, turn it off
      // if (m_iJuice <= 0) {
        // Off();
      // }
      // if the player doesn't have the suit, or there is no juice left, make the deny noise
      if (m_iJuice <= 0) {
        self.pev.skin = 1;      
        if (m_flSoundTime <= g_Engine.time) {
          m_flSoundTime = g_Engine.time + 0.62;
          g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/medshotno1.wav", 0.85, ATTN_NORM);
        }
        return;
      }
      
      // self.pev.nextthink = self.pev.ltime + 0.25;
      // SetThink( ThinkFunction( this.Off ) );

      // Time to recharge yet?

      // if (m_flNextCharge >= g_Engine.time) {
        // return;
      // }
      
      // Play the on sound or the looping charging sound
      // if (m_iOn == 0) {
        // m_iOn++;
        // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/medshot4.wav", 0.85, ATTN_NORM);
        // m_flSoundTime = 0.56 + g_Engine.time;
      // }
      
      // if ((m_iOn == 1) && (m_flSoundTime <= g_Engine.time)) {
        // m_iOn++;
        // g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitcharge1.wav", 0.85, ATTN_NORM);
      // }

      // charge the player
      if (pActivator.pev.health < pActivator.pev.max_health) {
        m_iJuice--;
        pActivator.pev.health += 1;

        if (pActivator.pev.health > pActivator.pev.max_health)
          pActivator.pev.health = pActivator.pev.max_health;
      }
    }
    
    g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/medshot4.wav", 0.85, ATTN_NORM);
    
    // govern the rate of charge
    // m_flNextCharge = g_Engine.time + 0.1;
  }
  
  /*
  void Off() {
    if (m_iOn > 1){
      // Stop looping sound.
      g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 0.0, ATTN_NORM);
      // g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "items/suitcharge1.wav" );
    }
    
    m_iOn = 0;
    
    SetThink( null );
  }
  */
}

void RegisterItemRechargeCustomEntity() {
  // g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "HEV-DEBUG: Register Item Recharge\n" );
	g_CustomEntityFuncs.RegisterCustomEntity( "Citem_recharge", "item_recharge" );
	g_CustomEntityFuncs.RegisterCustomEntity( "Citem_healthcharger", "item_healthcharger" );
}

