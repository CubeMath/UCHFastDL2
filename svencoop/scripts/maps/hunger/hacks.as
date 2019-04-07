// this is just a bunch of dirty hacks to get broken shit working. 

// crowbar on they16 wouldn't drop to the ground when the bench it's on breaks. 
void they16_crowbarphysics(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue) {
	CBaseEntity@ ent = null;
	if( ( @ent = g_EntityFuncs.FindEntityByTargetname( ent, "as_th_weapondrophack" ) ) !is null ) {
		ent.Respawn();
		g_EntityFuncs.Remove(ent);
	}
}
