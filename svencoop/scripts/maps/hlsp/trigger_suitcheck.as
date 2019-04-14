/*
* This script implements the entity trigger_suitcheck,
* used to check if players have a suit before opening the airlock
* in hl_c01_a1 (Anomalous Materials)
*
* Created by Josh "JPolito" Polito -- JPolito@svencoop.com
*/

class trigger_suitcheck : ScriptBaseEntity
{	
	string szTriggerAfterFound = "";
	string szTriggerAfterNotFound = "";

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if(szKey == "trigger_found") // Target triggered after a hazard suit has been found
		{
			szTriggerAfterFound = szValue;
			return true;
		}
		else if(szKey == "trigger_notfound") // Target triggered if a hazard suit has NOT been found
		{
			szTriggerAfterNotFound = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		//g_Game.AlertMessage(at_console, "Checking for suit...\n");
		if( pActivator is null || !pActivator.IsPlayer() )
			return;
			
		if( cast<CBasePlayer@>( pActivator ).HasSuit() )
		{
			// Triggers a target entity once the suit has been found
			g_EntityFuncs.FireTargets( szTriggerAfterFound, @self, @self, USE_TOGGLE, flValue );
			//g_Game.AlertMessage(at_console, "Player has suit!\n");
		}
		else	
		{
			// Triggers a target entity if the suit has not been found
			g_EntityFuncs.FireTargets( szTriggerAfterNotFound, @self, @self, USE_TOGGLE, flValue );
			//g_Game.AlertMessage(at_console, "No suit found.\n");
		}
		
		//g_Game.AlertMessage(at_console, "Suit check finished.\n");
	}
}

void RegisterTriggerSuitcheckEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_suitcheck", "trigger_suitcheck" );
}
