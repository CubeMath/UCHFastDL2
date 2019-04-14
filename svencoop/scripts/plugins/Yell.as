/*
* This plugin is a sample for how to use client commands to implement speech
*/
const array<string> g_MoveSounds = 
{
	"hgrunt/move!.wav",
	"hgrunt/gr_pain1.wav",
	"hgrunt/c2a3_hg_laugh.wav",
	"hgrunt/gr_loadtalk.wav",
	"hgrunt/shit!.wav",
	"drill/add01.wav",
	"drill/add02.wav",
	"barney/ba_attacking0.wav",
	"vox/move.wav",
	"fgrunt/intro_fg01.wav",
	"fgrunt/intro_fg02.wav",
	"fgrunt/intro_fg03.wav",
	"fgrunt/intro_fg04.wav",
	"fgrunt/intro_fg05.wav",
	"fgrunt/intro_fg06.wav",
	"fgrunt/intro_fg07.wav",
	"fgrunt/intro_fg08.wav",
	"fgrunt/intro_fg09.wav",
	"fgrunt/intro_fg10.wav",
	"fgrunt/intro_fg11.wav",
	"fgrunt/intro_fg12.wav",
	"fgrunt/intro_fg13.wav",
	"fgrunt/intro_fg14.wav",
	"fgrunt/intro_fg15.wav",
	"fgrunt/intro_fg16.wav",
	"fgrunt/intro_fg17.wav",
	"fgrunt/intro_fg18.wav",
	"fgrunt/intro_fg19.wav",
};

const array<string> g_SpecialSounds = 
{
	"drill/intro01.wav",
	"drill/intro02.wav",
	"drill/intro03.wav",
	"ambience/goal_1.wav",
	"tfc/misc/b1.wav",
	"tfc/misc/b2.wav",
	"tfc/misc/endgame.wav",
	"tfc/misc/party1.wav",
	"tfc/misc/party2.wav",
	"tfc/player/death1.wav",
	"tfc/player/death2.wav",
	"tfc/player/death3.wav",
	"tfc/player/death4.wav",
	"tfc/player/death5.wav",
	"tfc/player/drown1.wav",
	"tfc/player/drown2.wav",
	"tfc/player/h2odeath.wav",
	"tfc/player/pain1.wav",
	"tfc/player/pain2.wav",
	"tfc/player/pain3.wav",
	"tfc/player/pain4.wav",
	"tfc/player/pain5.wav",
	"tfc/player/pain6.wav",
	"tfc/player/plyrjmp8.wav",
	"tfc/speech/saveme1.wav",
	"tfc/speech/saveme2.wav"
};

const array<string> g_FreeSounds = 
{
	"misc/broken_tram1.wav",
	"misc/broken_tram2.wav",
	"misc/broken_tram3.wav",
	"misc/broken_tram4.wav",
	"misc/broken_tram5.wav"
};

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sven Co-op Development Team" );
	g_Module.ScriptInfo.SetContactInfo( "www.svencoop.com" );
}

void MapInit()
{
	for( uint uiIndex = 0; uiIndex < g_MoveSounds.length(); ++uiIndex )
		g_SoundSystem.PrecacheSound( g_MoveSounds[ uiIndex ] );
		
	for( uint uiIndex = 0; uiIndex < g_SpecialSounds.length(); ++uiIndex )
		g_SoundSystem.PrecacheSound( g_SpecialSounds[ uiIndex ] );
		
		for( uint uiIndex = 0; uiIndex < g_FreeSounds.length(); ++uiIndex )
		g_SoundSystem.PrecacheSound( g_FreeSounds[ uiIndex ] );
}

void YellSomething( CBasePlayer@ pPlayer, bool fPitchMod, const array<string>@ pSounds )
{	
	if( pPlayer.m_flNextClientCommandTime <= g_Engine.time )
	{
		const int iRandom = Math.RandomLong( 0, pSounds.length() - 1 );
		
		string szSound = pSounds[ iRandom ];
	
		g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_VOICE, szSound, 1, 1, 0, int( 100 * ( fPitchMod ? Math.RandomFloat( 0.75, 1.5 ) : 1 ) ) );
		
		pPlayer.m_flNextClientCommandTime = g_Engine.time + PLAYERCOMMAND_WAIT;
	}
	else
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "You must wait " + ( float( int( ( pPlayer.m_flNextClientCommandTime - g_Engine.time ) * 10 ) ) / 10 ) + " seconds before\nyou can yell to move.\n" );
	}
}

void YellSomething( const CCommand@ args )
{
	YellSomething( g_ConCommandSystem.GetCurrentPlayer(), false, @g_MoveSounds );
}

CClientCommand yell_something( "yell_something", "Yell for players to move", @YellSomething );

void YellSomethingWeird( const CCommand@ args )
{
	YellSomething( g_ConCommandSystem.GetCurrentPlayer(), true, @g_MoveSounds );
}

CClientCommand yell_something_weird( "yell_something_weird", "Yell for players to move", @YellSomethingWeird );

void YellStuff( const CCommand@ args )
{
	YellSomething( g_ConCommandSystem.GetCurrentPlayer(), true, @g_SpecialSounds );
}

CClientCommand yell_stuff( "yell_stuff", "Yell stuff", @YellStuff );

void YellFree( const CCommand@ args )
{
	if( args.ArgC() < 2 )
		return;
		
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
		
	const string szSound = args.Arg( 1 );
	
	const float flPitch = args.ArgC() >= 3 ? atof( args.Arg( 2 ) ) : 1;
	
	if( pPlayer.m_flNextClientCommandTime <= g_Engine.time )
	{	
		g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_VOICE, szSound, 1, 1, 0, int( 100 * flPitch ) );
		
		pPlayer.m_flNextClientCommandTime = g_Engine.time + PLAYERCOMMAND_WAIT;
	}
	else
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_center, "You must wait " + ( float( int( ( pPlayer.m_flNextClientCommandTime - g_Engine.time ) * 10 ) ) / 10 ) + " seconds before\nyou can yell.\n" );
	}
}

CClientCommand yell_free( "yell_free", "Yell free sound", @YellFree );