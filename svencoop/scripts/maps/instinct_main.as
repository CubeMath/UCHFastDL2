#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_multiple_mp"
#include "cubemath/func_wall_custom"
#include "instinct_polygon"

array<Vector> old_ply_posis;
array<float> old_ply_velocity;

void just_fallingdamage()
{
	CBasePlayer@ pPlayer = null;
	string m_sMap = g_Engine.mapname;
  
	if(m_sMap == "instinct_7")
	{
	
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	  
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pPlayer.m_fLongJump)
			{
				continue;
			} 
	  
			if( ( pPlayer.pev.flags & FL_ONGROUND ) == 0 )
			{
				old_ply_velocity[iPlayer] = pPlayer.m_flFallVelocity ;
				continue;
			}
 
			if( pPlayer.pev.origin.z < -504 && pPlayer.pev.origin.z > -1110 )
			{				
				if(pPlayer.pev.origin.x >= -720 || pPlayer.pev.origin.y >= 1480 )
				{
					if( pPlayer.pev.origin.y < 16 || pPlayer.pev.origin.z > -840)
					{					
						if( old_ply_velocity[iPlayer] >= 700 )
						{
							entvars_t@ world = g_EntityFuncs.Instance(0).pev;
							pPlayer.TakeDamage(world, world, 10000.0f, DMG_FALL);
							continue;
						}
					}
          
					continue;
				}
				
				if( old_ply_velocity[iPlayer] >= 700 )
				{
					entvars_t@ world = g_EntityFuncs.Instance(0).pev;
					pPlayer.TakeDamage(world, world, 10000.0f, DMG_FALL);
					continue;
				}
				
			}
		}
    
		g_Scheduler.SetTimeout( "just_fallingdamage", 0.05f );
		
	}
	
	else if(m_sMap == "instinct_9")
	{
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
      
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
			{
				continue;
			}
      
			// if( ( pPlayer.pev.flags & FL_ONGROUND ) == 0 )
			//{
			//	continue;
			//}
      
			if( pPlayer.pev.origin.z < get_nearest_point_z(pPlayer.pev.origin) )
			{
				old_ply_posis[iPlayer] = pPlayer.pev.origin;
				continue;
			}
      
			Vector quad_check;
			quad_check.x = pPlayer.pev.origin.x;
			quad_check.y = pPlayer.pev.origin.y;
			quad_check.z = pPlayer.pev.origin.z;
      
			quad_check.x -= 16.0;
			quad_check.y -= 16.0;
		  
			if( !isInside(quad_check) )
			{
				pPlayer.pev.origin = old_ply_posis[iPlayer];
				pPlayer.pev.velocity.x = 0.0;
				pPlayer.pev.velocity.y = 0.0;
				continue;
			}
      
			quad_check.x += 32.0;
			
			if( !isInside(quad_check) )
			{
				pPlayer.pev.origin = old_ply_posis[iPlayer];
				pPlayer.pev.velocity.x = 0.0;
				pPlayer.pev.velocity.y = 0.0;
				continue;
			}
		  
			quad_check.y += 32.0;
		  
			if( !isInside(quad_check) )
			{
				pPlayer.pev.origin = old_ply_posis[iPlayer];
				pPlayer.pev.velocity.x = 0.0;
				pPlayer.pev.velocity.y = 0.0;
				continue;
			}
      
			quad_check.x -= 32.0;
		
			if( !isInside(quad_check) )
			{
				pPlayer.pev.origin = old_ply_posis[iPlayer];
				pPlayer.pev.velocity.x = 0.0;
				pPlayer.pev.velocity.y = 0.0;
				continue;
			}
      
			old_ply_posis[iPlayer] = pPlayer.pev.origin;
		}
    
		g_Scheduler.SetTimeout( "just_fallingdamage", 0.1f );
		
	}
}

void MapInit(){
	RegisterPointCheckPointEntity();
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMultipleMpEntity();
	RegisterFuncWallCustomEntity();
  g_Scheduler.SetTimeout( "just_fallingdamage", 0.1f );
  
  old_ply_posis.resize(g_Engine.maxClients);
  old_ply_velocity.resize(g_Engine.maxClients);
  for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
    old_ply_posis[iPlayer] = Vector(0,0,0);
  }
}