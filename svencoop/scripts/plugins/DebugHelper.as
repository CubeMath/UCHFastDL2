final class CooldownTimes {
	float posax = 0.0f;
	float posay = 0.0f;
	float posaz = 0.0f;
	
	float minx = 300000.0f;
	float miny = 300000.0f;
	float minz = 300000.0f;
	float maxx = -300000.0f;
	float maxy = -300000.0f;
	float maxz = -300000.0f;
	float maxsubx = 0.0f;
	float maxsuby = 0.0f;
	float maxsubz = 0.0f;
	
	float stopwatch = 0.0f;
	
	CooldownTimes(){
	}
}

CooldownTimes@ g_CooldownTimes;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_OWNER );
	
	CooldownTimes ctimes();
	@g_CooldownTimes = @ctimes;
	
	Initialize();
}

void MapInit() {
	g_SoundSystem.PrecacheSound( "buttons/blip1.wav" );
	
	g_CooldownTimes.maxsubx = 0.0f;
	g_CooldownTimes.maxsuby = 0.0f;
	g_CooldownTimes.maxsubz = 0.0f;
}

void Initialize() {
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

void ChatCheck( SayParameters@ m_pArgs ) {
	string str = m_pArgs.GetCommand();
	CBasePlayer@ m_caller = m_pArgs.GetPlayer();
	str.ToUppercase();
	
	if (str.opEquals("R")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		ply.pev.origin.x = 0;
		ply.pev.origin.y = 0;
		ply.pev.origin.z = 0;
	}
	
	if (str.opEquals("TP")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		TraceResult tr2;
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		g_Utility.TraceLine( tr.vecEndPos, tr.vecEndPos + tr.vecPlaneNormal * 48.0f, dont_ignore_monsters, ply.edict(), tr2 );
		
		float posx = (tr2.vecEndPos.x+tr.vecEndPos.x)/2.0f;
		float posy = (tr2.vecEndPos.y+tr.vecEndPos.y)/2.0f;
		float posz = (tr2.vecEndPos.z+tr.vecEndPos.z)/2.0f-28.0f;
		
		ply.pev.origin.x = posx;
		ply.pev.origin.y = posy;
		ply.pev.origin.z = posz;
	}
	
	if (str.opEquals("P")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		float posx = floor(tr.vecEndPos.x+0.5f);
		float posy = floor(tr.vecEndPos.y+0.5f);
		float posz = floor(tr.vecEndPos.z+0.5f);
		
		string aStr = "\"origin\" \""+posx+" "+posy+" "+posz+"\"\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
	}
	
	if (str.opEquals("P3")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = Vector(0.0f, 0.0f, -1.0f);
		
		Vector vecSrc = ply.pev.origin;
		Vector vecEnd = vecSrc + vecAiming * 256.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		float posx = floor(tr.vecEndPos.x+0.5f);
		float posy = floor(tr.vecEndPos.y+0.5f);
		float posz = floor(tr.vecEndPos.z+0.5f);
		float angl = floor(ply.pev.angles.y+0.5f);
		
		string aStr = ""+g_Engine.mapname+","+posx+" "+posy+" "+posz+","+angl+",NNNNN,NNNNN,NNNNN,NNNNN\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
	}
	
	if (str.opEquals("P2")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		string aStr;
		edict_t@ pHit = tr.pHit;
		
		if(pHit !is null){
			aStr = "\n\"classname\" \""+pHit.vars.classname+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
			aStr = "\"targetname\" \""+pHit.vars.targetname+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
			aStr = "\"target\" \""+pHit.vars.target+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
			aStr = "\"model\" \""+pHit.vars.model+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
			aStr = "\"origin\" \""+pHit.vars.origin.x+" "+pHit.vars.origin.y+" "+pHit.vars.origin.z+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
			aStr = "\"angles\" \""+pHit.vars.angles.x+" "+pHit.vars.angles.y+" "+pHit.vars.angles.z+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
		}else{
			float posx = floor(tr.vecEndPos.x+0.5f);
			float posy = floor(tr.vecEndPos.y+0.5f);
			float posz = floor(tr.vecEndPos.z+0.5f);
			
			aStr = "\"origin\" \""+posx+" "+posy+" "+posz+"\"\n";
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
		}
	}
	
	if (str.opEquals("A")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		g_CooldownTimes.posax = floor(tr.vecEndPos.x+0.5f);
		g_CooldownTimes.posay = floor(tr.vecEndPos.y+0.5f);
		g_CooldownTimes.posaz = floor(tr.vecEndPos.z+0.5f);
	}
	
	if (str.opEquals("B")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		float posx = floor(tr.vecEndPos.x+0.5f) - g_CooldownTimes.posax;
		float posy = floor(tr.vecEndPos.y+0.5f) - g_CooldownTimes.posay;
		float posz = floor(tr.vecEndPos.z+0.5f) - g_CooldownTimes.posaz;
		
		string aStr = "\"origin\" \""+posx+" "+posy+" "+posz+"\"\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
	}
	
	if (str.opEquals("M")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		float posx = floor(tr.vecEndPos.x+0.5f);
		float posy = floor(tr.vecEndPos.y+0.5f);
		float posz = floor(tr.vecEndPos.z+0.5f);
		
		if (posx < g_CooldownTimes.minx) g_CooldownTimes.minx = posx;
		if (posy < g_CooldownTimes.miny) g_CooldownTimes.miny = posy;
		if (posz < g_CooldownTimes.minz) g_CooldownTimes.minz = posz;
		if (posx > g_CooldownTimes.maxx) g_CooldownTimes.maxx = posx;
		if (posy > g_CooldownTimes.maxy) g_CooldownTimes.maxy = posy;
		if (posz > g_CooldownTimes.maxz) g_CooldownTimes.maxz = posz;
	}
	
	if (str.opEquals("MA")){
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		
		Vector vecAiming = ply.GetAutoaimVector( 0.0f );
		
		Vector vecSrc = ply.GetGunPosition();
		Vector vecEnd = vecSrc + vecAiming * 65536.0f;

		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ply.edict(), tr );
		
		float posx = floor(tr.vecEndPos.x+0.5f);
		float posy = floor(tr.vecEndPos.y+0.5f);
		float posz = floor(tr.vecEndPos.z+0.5f);
		
		g_CooldownTimes.maxsubx = atof( posx );
		g_CooldownTimes.maxsuby = atof( posy );
		g_CooldownTimes.maxsubz = atof( posz );
	}
	
	if (str.Find("M ") == 0 && str.Length()>6){
		m_pArgs.ShouldHide = true;
		array<string> aStrs = str.Split(" ");
		if (aStrs.length() == 4){
			CBasePlayer @ply = m_pArgs.GetPlayer();
			g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
			
			g_CooldownTimes.maxsubx = atof( aStrs[1] );
			g_CooldownTimes.maxsuby = atof( aStrs[2] );
			g_CooldownTimes.maxsubz = atof( aStrs[3] );
		}
	}
	
	if (str.opEquals("MINMAX")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		string aStr = "\"minhullsize\" \""+
				(g_CooldownTimes.minx-g_CooldownTimes.maxsubx)+" "+
				(g_CooldownTimes.miny-g_CooldownTimes.maxsuby)+" "+
				(g_CooldownTimes.minz-g_CooldownTimes.maxsubz)+"\"\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
		
		aStr = "\"maxhullsize\" \""+
				(g_CooldownTimes.maxx-g_CooldownTimes.maxsubx)+" "+
				(g_CooldownTimes.maxy-g_CooldownTimes.maxsuby)+" "+
				(g_CooldownTimes.maxz-g_CooldownTimes.maxsubz)+"\"\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
		
		g_CooldownTimes.minx = 300000.0f;
		g_CooldownTimes.miny = 300000.0f;
		g_CooldownTimes.minz = 300000.0f;
		g_CooldownTimes.maxx = -300000.0f;
		g_CooldownTimes.maxy = -300000.0f;
		g_CooldownTimes.maxz = -300000.0f;
	}
	
	if (str.opEquals("T")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		string aStr = "Maptime: "+g_Engine.time+"s\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
	}
	
	if (str.opEquals("TA")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		g_CooldownTimes.stopwatch = g_Engine.time;
	}
	
	if (str.opEquals("TB")) {
		m_pArgs.ShouldHide = true;
		CBasePlayer @ply = m_pArgs.GetPlayer();
		g_SoundSystem.EmitSoundDyn( ply.edict(), CHAN_STATIC, "buttons/blip1.wav", 1.0f, ATTN_NONE, 0, 150 );
		string aStr = "Stopwatch: "+(g_Engine.time-g_CooldownTimes.stopwatch)+"s\n";
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
	}
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	ChatCheck( pParams );
	return HOOK_CONTINUE;
}
