
class Cinfo_cheathelper: ScriptBaseItemEntity {
  string m_cheatStr;
  
	bool KeyValue( const string& in szKey, const string& in szValue ) {
		return BaseClass.KeyValue( szKey, szValue );
	}
	
  void Spawn(){
    Precache();
    
    self.pev.solid = SOLID_NOT;
    self.pev.movetype = MOVETYPE_NONE;
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
  }

  void Precache() {}
  
  void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f) {
    
    // if it's not a player, ignore
    if (pActivator is null || pActivator.pev.classname != "player") {
      return;
    }
    
    if (pCaller is null) {
      return;
    }
    
    m_cheatStr = m_cheatStr + pCaller.pev.targetname;
    if(m_cheatStr.Length() > 9) m_cheatStr = m_cheatStr.SubString(m_cheatStr.Length()-9, m_cheatStr.Length());
    
    // string aStr = "CHEATER-DEBUG: " + m_cheatStr + "\n";
    
    if(m_cheatStr.Length() > 5 && m_cheatStr.SubString(m_cheatStr.Length()-6, m_cheatStr.Length()) == "ucxltt"){
      g_EntityFuncs.FireTargets("devshed", null, null, USE_ON, 0.0f, 0.0f);
      m_cheatStr = "";
    }else if(m_cheatStr.Length() > 7 && m_cheatStr.SubString(m_cheatStr.Length()-8, m_cheatStr.Length()) == "sclltxrr"){
      g_EntityFuncs.FireTargets("unlock_alien", null, null, USE_ON, 0.0f, 0.0f);
      m_cheatStr = "";
    }else if(m_cheatStr.Length() > 8 && m_cheatStr.SubString(m_cheatStr.Length()-9, m_cheatStr.Length()) == "utututscr"){
      g_EntityFuncs.FireTargets("unlock_gman", null, null, USE_ON, 0.0f, 0.0f);
      m_cheatStr = "";
    }
    
    // g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
  }
}

void RegisterInfoCheathelperCustomEntity() {
	g_CustomEntityFuncs.RegisterCustomEntity( "Cinfo_cheathelper", "info_cheathelper" );
}

