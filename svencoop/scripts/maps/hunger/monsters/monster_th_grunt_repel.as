
// Parachute grunt (based on repel grunt)
// Author: GeckonCZ

namespace THMonsterGruntRepel
{

const int TH_GRUNT_PARACHUTE_BODYPART = 3;
const int TH_GRUNT_PARACHUTE_HIDDEN = 0;
const int TH_GRUNT_PARACHUTE_VISIBLE = 1;

const string TH_GRUNT_MODEL = "models/hunger/hgrunt.mdl";

class CGruntRepel : ScriptBaseMonsterEntity
{
	private EHandle m_hHgrunt;

	void Spawn( void )
	{
		Precache();
		
		pev.solid = SOLID_NOT;

		SetUse( UseFunction( RepelUse ) );
	}

	void Precache()
	{
		g_Game.PrecacheOther( "monster_human_grunt" );
		
		g_Game.PrecacheModel( TH_GRUNT_MODEL );
	}
	
	void RepelUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		TraceResult tr;
		g_Utility.TraceLine( pev.origin, pev.origin + Vector( 0, 0, -4096.0), dont_ignore_monsters, self.edict(), tr );
		/*
		if ( tr.pHit !is null && g_EntityFuncs.Instance( tr.pHit ).pev.solid != SOLID_BSP )
			return null;
		*/
		
		// Use custom model
		dictionary keyvalues = { { "model", TH_GRUNT_MODEL } };
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_human_grunt", keyvalues, false ); // Delayed spawn
		
		CBaseMonster@ pGrunt = pEntity.MyMonsterPointer();
		
		pGrunt.pev.origin = pev.origin;
		pGrunt.pev.angles = pev.angles;
		pGrunt.pev.spawnflags = pev.spawnflags;
		pGrunt.pev.health = pev.health;
		pGrunt.pev.netname = pev.netname;
		pGrunt.pev.weapons = pev.weapons;
		
		g_EntityFuncs.DispatchSpawn( pGrunt.edict() );
		
		pGrunt.pev.movetype = MOVETYPE_FLY;
		pGrunt.pev.velocity = Vector( 0, 0, Math.RandomFloat( -196, -128 ) );
		pGrunt.SetActivity( ACT_GLIDE );
		// UNDONE: position?
		pGrunt.m_vecLastPosition = tr.vecEndPos;
		pGrunt.m_iTriggerCondition = self.m_iTriggerCondition;
		pGrunt.m_iszTriggerTarget = self.m_iszTriggerTarget;
		
		m_hHgrunt = EHandle( pGrunt );
		
		ShowParachute();
		
		SetThink( ThinkFunction( ThinkHideParachute ) );
		pev.nextthink = g_Engine.time + -4096.0 * tr.flFraction / pGrunt.pev.velocity.z + 0.5;
	}
	
	void ThinkHideParachute( void )
	{
		//g_Game.AlertMessage( at_console, "ThinkHideParachute\n" );
		HideParachute();
		
		SetThink( ThinkFunction( ThinkRemove ) );
		pev.nextthink = g_Engine.time + 0.1;
	}

	void ThinkRemove( void )
	{
		//g_Game.AlertMessage( at_console, "ThinkRemove\n" );
		self.SUB_Remove();
	}
	
	void ShowParachute( void )
	{
		if ( !m_hHgrunt.IsValid() )
			return;
			
		CBaseMonster@ pGrunt = m_hHgrunt.GetEntity().MyMonsterPointer();
		pGrunt.SetBodygroup( TH_GRUNT_PARACHUTE_BODYPART, TH_GRUNT_PARACHUTE_VISIBLE );
	}
	
	void HideParachute( void )
	{
		if ( !m_hHgrunt.IsValid() )
			return;

		CBaseMonster@ pGrunt = m_hHgrunt.GetEntity().MyMonsterPointer();
		pGrunt.SetBodygroup( TH_GRUNT_PARACHUTE_BODYPART, TH_GRUNT_PARACHUTE_HIDDEN );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "THMonsterGruntRepel::CGruntRepel", "monster_th_grunt_repel" );
}

} // end of namespace
