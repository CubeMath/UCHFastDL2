#include "point_checkpoint"
#include "HLSPClassicMode"
#include "cubemath/disco_floor_system"
#include "cubemath/disco_drone"
#include "cubemath/disco_disconator"
#include "cubemath/disco_breakable"

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterDiscoFloorSystemCustomEntity();
	RegisterDiscoDroneCustomEntity();
	RegisterDiscoDisconatorCustomEntity();
	RegisterDiscoBreakableCustomEntity();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
}
