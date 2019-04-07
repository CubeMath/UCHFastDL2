/*
* They Hunger
* Main script file
*
* Created by Josh "JPolito" Polito -- JPolito@svencoop.com
* Modified by Tomas "GeckoN" Slavotinek
*/

#include "th_weapons"
#include "monsters/monster_th_grunt_repel"
#include "monsters/monster_th_cyberfranklin"
#include "monsters/monster_th_boss"
#include "point_checkpoint"
#include "leveldead_loadsaved"
#include "../cubemath/trigger_once_mp"
#include "../cubemath/item_airbubble"

array<ItemMapping@> g_ItemMappings =
{ 
	ItemMapping( "weapon_9mmAR", THWeaponThompson::WEAPON_NAME ), 
	ItemMapping( "weapon_shotgun", THWeaponSawedoff::WEAPON_NAME ), 
	ItemMapping( "weapon_m16", THWeaponM16A1::WEAPON_NAME ), 
	ItemMapping( "weapon_9mmhandgun", THWeaponM1911::WEAPON_NAME ), 
	ItemMapping( "weapon_eagle", "weapon_357" )
};

void MapInit()
{
	// Register custom weapons
	THWeaponSawedoff::Register();
	THWeaponM16A1::Register();
	THWeaponM1911::Register();
	THWeaponThompson::Register();
	THWeaponM14::Register();
	THWeaponTeslagun::Register();
	THWeaponGreasegun::Register();
	THWeaponSpanner::Register();
	
	// Register checkpoint entity
	RegisterPointCheckPointEntity();
	
	// Register custom monsters
	THMonsterGruntRepel::Register();
	if ( g_Engine.mapname == "th_ep3_07" )
	{
		THMonsterCyberFranklin::Register();
		THMonsterBoss::Register();
	}
	
	// Register other stuff
	RegisterTriggerOnceMpEntity();
	RegisterAirbubbleCustomEntity();
	
	// Initialize classic mode (item mapping only)
	g_ClassicMode.SetItemMappings( @g_ItemMappings );
	g_ClassicMode.ForceItemRemap( true );
}

void MapActivate()
{
	InitObserver();
	
	if ( g_Engine.mapname == "th_ep3_07" )
	{
		// Adjust difficulty of boss battle (based on skill cvar and player count)
		float flAdjDelay = g_SurvivalMode.IsEnabled() ? g_SurvivalMode.GetDelayBeforeStart() : 20;
		g_Scheduler.SetTimeout( "AdjustDifficulty", flAdjDelay );
	}
}

void SetHealthByClassname( string sClassName, int iHealth )
{
	CBaseEntity@ pEntity = null;
	while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, sClassName ) ) !is null )
	{
		if ( pEntity is null || !pEntity.IsAlive() )
			continue;
			
		pEntity.pev.health = iHealth;
		//g_Game.AlertMessage( at_console, "Setting health of %1 to %2\n", sClassName, iHealth );
	}
}

int CalcNewHealth( int iBaseHealth, int iPerPlayerInc )
{
	int iNumPlayers = g_PlayerFuncs.GetNumPlayers();
	int iPlayerMul = Math.clamp( 0, 8, iNumPlayers );
	int iSkill = int( g_EngineFuncs.CVarGetFloat( "skill" ) );
	iSkill = Math.clamp( 1, 3, iSkill );
	
	int iRelBaseHealth = iBaseHealth + ( iBaseHealth / 3 ) * ( iSkill - 2 );
	int iRelPerPlayerInc = iPerPlayerInc + ( iPerPlayerInc / 3 ) * ( iSkill - 2 );
	return iRelBaseHealth + iRelPerPlayerInc * iPlayerMul;
}

void AdjustDifficulty( void )
{
	int iHealth;
	int iNumPlayers = g_PlayerFuncs.GetNumPlayers();
	int iSkill = int( g_EngineFuncs.CVarGetFloat( "skill" ) );
	//g_Game.AlertMessage( at_console, "Adjusting difficulty for skill %1 and %2 player(s).\n", iSkill, iNumPlayers );
	
	iHealth = CalcNewHealth( THMonsterBoss::BOSS_HEALTH_BASE, THMonsterBoss::BOSS_HEALTH_PER_PLAYER_INC );
	SetHealthByClassname( "monster_th_boss", iHealth );
		
	iHealth = CalcNewHealth( THMonsterCyberFranklin::CYBERFRANKLIN_HEALTH_BASE, THMonsterCyberFranklin::CYBERFRANKLIN_HEALTH_PER_PLAYER_INC );
	SetHealthByClassname( "monster_th_cyberfranklin", iHealth );
}

void InitObserver()
{
	g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 ); 
	g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 0 );
}

void EnableObserver(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if ( !g_SurvivalMode.IsActive() )
		InitObserver();
	
    if( pActivator is null || !pActivator.IsPlayer() )
        return;
        
    CBasePlayer@ player = cast<CBasePlayer@>( pActivator );

    player.GetObserver().StartObserver(player.pev.origin, Vector(), false);
}

void ActivateSurvival(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_SurvivalMode.Activate();
}
