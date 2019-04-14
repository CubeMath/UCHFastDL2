
int entityId_1 = 0;
int entityId_2 = 0;
void poll_check(){
  
  CBasePlayer@ pPlayer = null;
	string m_sMap = g_Engine.mapname;
  
	if(m_sMap == "hl_c05_a2"){
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
      @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
      
      if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
        continue;
      
      if(pPlayer.pev.origin.x > -460 && pPlayer.pev.origin.x < 550 && pPlayer.pev.origin.y > 1714 && pPlayer.pev.origin.y < 2723){
      }else if(pPlayer.pev.origin.x > -2015 && pPlayer.pev.origin.x < -1008 && pPlayer.pev.origin.y > 1720 && pPlayer.pev.origin.y < 2723){
      }else if(pPlayer.pev.origin.x > -2015 && pPlayer.pev.origin.x < -1006 && pPlayer.pev.origin.y > 113 && pPlayer.pev.origin.y < 1166){
      }else{
        continue;
      }
      
      //Don't allow people to skip tentacles
      pPlayer.pev.velocity.x *= 0.5;
      pPlayer.pev.velocity.y *= 0.5;
      pPlayer.pev.velocity.z -= 64.0;
    }
    
    g_Scheduler.SetTimeout( "poll_check", 0.1f );
  }else if(m_sMap == "hl_c11_a5"){
    if(entityId_1 == 0){
      for( int i = 0; i < g_Engine.maxEntities; ++i ) {
        CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
        if( pEntity is null ) continue;
        
        string s_Targetname = pEntity.GetTargetname();
        if(s_Targetname == "boiler_door_2"){
          entityId_1 = i;
          break;
        }
      }
    }
    
    CBaseEntity@ pEntity = g_EntityFuncs.Instance( entityId_1 );
    if( pEntity is null ) return;
    
    //Only check if Boilder-Door is still closed
    if( pEntity.pev.angles.y == 0 ){
      for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
        @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
        
        if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
          continue;
        
        if(
            pPlayer.pev.origin.x > -1285 && pPlayer.pev.origin.x < -426 &&
            pPlayer.pev.origin.y > -4672 && pPlayer.pev.origin.y < -4612 &&
            pPlayer.pev.origin.z > -1524 && pPlayer.pev.origin.z < -1464
        ){
          //Teleport Player from upper pipe to lower pipe
          pPlayer.pev.origin.z -= 90.0;
        }else if(
            pPlayer.pev.origin.x > -816 && pPlayer.pev.origin.x < -208 &&
            pPlayer.pev.origin.y > -4176 && pPlayer.pev.origin.y < -3696 &&
            pPlayer.pev.origin.z > -1664 && pPlayer.pev.origin.z < -1312
        ){
          //Teleport Player from barney room to roof top
          pPlayer.pev.origin.x = -1100;
          pPlayer.pev.origin.y = -4800;
          pPlayer.pev.origin.z = -1350;
        }
      }
      
      g_Scheduler.SetTimeout( "poll_check", 0.1f );
    }
  }else if(m_sMap == "dy_fubar"){
    if(entityId_1 == 0){
      for( int i = 0; i < g_Engine.maxEntities; ++i ) {
        CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
        if( pEntity is null ) continue;
        
        string s_Targetname = pEntity.GetTargetname();
        if(s_Targetname == "turretdoor"){
          entityId_1 = i;
          break;
        }
      }
    }
    
    CBaseEntity@ pEntity = g_EntityFuncs.Instance( entityId_1 );
    if( pEntity is null ) return;
    
    if(entityId_2 == 0){
      if(pEntity.pev.origin.z > 1){
        entityId_2 = 1;
      }
      g_Scheduler.SetTimeout( "poll_check", 1.0f );
    }else{
      if(pEntity.pev.origin.z < 1){
        //Teleport people to battle area
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
          @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
          
          if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
            continue;
          
          if(
              pPlayer.pev.origin.y < -1424 ||
              (pPlayer.pev.origin.y < -1008 && pPlayer.pev.origin.x > 385) ||
              (
                  pPlayer.pev.origin.x >= 292 &&
                  pPlayer.pev.origin.x <= 385 &&
                  pPlayer.pev.origin.y >= -1424 &&
                  pPlayer.pev.origin.y <= -1200
              )
          ){
            pPlayer.pev.origin.x = 212;
            pPlayer.pev.origin.y = -1356;
            pPlayer.pev.origin.z = 1800;
          }
        }
      }else{
        g_Scheduler.SetTimeout( "poll_check", 1.0f );
      }
    }
  }
}
