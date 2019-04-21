#include "AF2Legacy"

AF2AntiCheat af2antiCheat;

void AF2AntiCheat_Call()
{
	af2antiCheat.RegisterExpansion(af2antiCheat);
}

class AF2AntiCheat : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery2 Entity Commands";
		this.ShortName = "AF2E";
	}
	
	void ExpansionInit()
	{
		RegisterCommand("fun_fade", "s!iiiffii", "(targets) <r> <g> <b> <fadetime> <holdtime> <alpha> <flags> - fade target(s) screens!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_shake", "fff", "<amplitude> <frequency> <duration> - shake everyone's screen!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_gibhead", "s", "(targets) - GIBS!!! Spawns head gib on target(s)!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_gibrand", "s!i", "(targets) <amount> - GIBS!!! Spawns random gibs on target(s)!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_shootgrenade", "!ff", "<velocitymultipier> <time> - shoot grenades!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_shootportal", "!fff", "<damage> <radius> <velocity> - shoot portals!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_shootrocket", "!f", "<velocity> - shoot normal RPG rockets!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("fun_maplight", "s", "(character from A (darkest) to Z (brightest), M returns to normal) - set map lighting!", ACCESS_H, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_damage", "!fs", "<damage> <targetname> - damage entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_keyvalue", "s!sss", "(key) <value> <value> <value> - get/set keyvalue of entity you are aiming at, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_keyvaluename", "ss!sss", "(targetname) (key) <value> <value> <value> - get/set keyvalue of entity based on targetname, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_keyvaluerange", "sfs!sss", "(classname) (range) (key) <value> <value><value> - get/set keyvalue of entity based on classname and range, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_kill", "!s", "<targetname> - removes entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_trigger", "!s", "<targetname> - trigger entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_triggerrange", "sf", "(classname) (range) - trigger entity based on classname and range", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_rotate", "fff!s", "(x) (y) (z) <targetname> - rotate entity, if no targetname given it will attempt to trace forwards. For best results use 15 increments", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_rotateabsolute", "fff!s", "(x) (y) (z) <targetname> - set entity rotation, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_create", "s!s", "(classname) <\"key:value:key:value:key:value\" etc> - create entity, default position at your origin", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_movename", "s", "(targetname) - absolute move, entity is placed to your origin", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_move", "!b", "- Use without argument to see usage/alias - Grab entity and move it relative to you", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_movecopy", "!b", "- Use without argument to see usage/alias - Copy & grab (copied) entity and move it relative to you", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_drop", "", "- Drop entity that you are aiming at to ground", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_item", "s", "(weapon_/ammo_/item_ name) - Spawn weapon/ammo/item at your location", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_worldcopy", "f!vbbb", "(speed) <angle vector> <0/1 reverse> <0/1 xaxis> <0/1 yaxis> - Create worldcopy", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("ent_worldremove", "", "- Remove all worldcopies", ACCESS_F, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_disarm", "s", "(targets) - disarm target(s)", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("say !give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_giveall", "s", "(targets) - give target(s) all stock weapons", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_giveammo", "s", "(targets) - give target(s) ammo", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("say !giveammo", "s", "(targets) - give target(s) ammo", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("say !resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_setmaxspeed", "sf", "(targets) (speed) - set target(s) max speed", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_keyvalue", "ss!sss", "(targets) (key) <value> <value> <value> - get/set target(s) keyvalue", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_nosolid", "s!b", "(targets) <0/1 mode> - set target(s) solidity, don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("say !nosolid", "s!i", "(targets) <0/1 mode> - set target(s) nosolid mode, don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_noclip", "s!i", "(targets) <0/1 mode> - set target(s) noclip mode, don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_god", "s!i", "(targets) <0/1 mode> - set target(s) godmode, don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("say !freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_ignite", "s", "(targets) - ignite target(s)", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
		RegisterCommand("player_notarget", "s!i", "(targets) <0/1 mode> - set target(s) notarget, don't define mode to toggle", ACCESS_G, @AF2AntiCheat::banmeBanmeBanme);
	}
	
}

namespace AF2AntiCheat
{
	void banmeBanmeBanme(AFBaseArguments@ AFArgs)
	{
		CBasePlayer@ ply1 = AFArgs.User;
		if( ply1 is null ) return;
		
		string aStr = g_EngineFuncs.GetPlayerUserId( ply1.edict() );
		string cStr = ply1.pev.netname;
		string s2 = "CubeMath hates Cheaters!";
		
		g_Game.AlertMessage( at_logged, "BANNED( 10 Minutes ): \"" + cStr + "\" Reason: CubeMath hates Cheaters!\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "BANNED( 10 Minutes ): \"" + cStr + "\" Reason: CubeMath hates Cheaters!\n" );
		g_EngineFuncs.ServerCommand("kick \"#" + aStr + "\" \"BANNED( 10 Minutes ): CubeMath hates Cheaters!\"\n");
		g_EngineFuncs.ServerCommand("banid 10 " + g_EngineFuncs.GetPlayerAuthId(ply1.edict()) + "\n");
		g_EngineFuncs.ServerExecute();
	}
}