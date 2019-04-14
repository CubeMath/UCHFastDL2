#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "HLSPClassicMode"
#include "cubemath/trigger_once_mp"
//#include "cubemath/weapon_debug"
#include "cubemath/polling_check_players"

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterTriggerOnceMpEntity();
	//RegisterWeaponDebug();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
  poll_check();
}
