#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "HLSPClassicMode"
#include "cubemath/trigger_once_mp"
#include "cubemath/polling_check_players"
#include "decay/monster_alienflyer"
#include "decay/item_recharge"
#include "decay/trigger_condition_alone"
#include "decay/info_cheathelper"
#include "decay/weapon_slave"

void MapInit()
{
	RegisterItemRechargeCustomEntity();
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterTriggerOnceMpEntity();
	RegisterAlienflyer();
	RegisterTriggerAloneCustomEntity();
	RegisterInfoCheathelperCustomEntity();
	RegisterWeaponIslave();
  
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
  poll_check();
}
