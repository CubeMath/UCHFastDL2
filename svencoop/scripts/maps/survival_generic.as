#include "point_checkpoint"
#include "HLSPClassicMode"
#include "cubemath/trigger_once_mp"
#include "cubemath/item_airbubble"
// #include "cubemath/weapon_debug"

void MapInit()
{	
	RegisterPointCheckPointEntity();
	RegisterTriggerOnceMpEntity();
	RegisterAirbubbleCustomEntity();
	// RegisterWeaponDebug();
	
	// Map support is enabled here by default.
	// So you don't have to add "mp_survival_supported 1" to the map config
	g_SurvivalMode.EnableMapSupport();
	ClassicModeMapInit();
}

void ActivateSurvival( CBaseEntity@ pActivator, CBaseEntity@ pCaller,
	USE_TYPE useType, float flValue )
{
	g_SurvivalMode.Activate();
}
