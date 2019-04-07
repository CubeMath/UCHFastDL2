void MapEnded( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if ( g_SurvivalMode.IsEnabled() )
	{
		g_SurvivalMode.EndRound();
	}
	else
	{
		g_EntityFuncs.FireTargets( "leveldead_loadsaved", pActivator, pCaller, USE_TOGGLE );
	}
}
