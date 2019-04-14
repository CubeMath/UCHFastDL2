
//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sven Co-op Team" );
	g_Module.ScriptInfo.SetContactInfo( "www.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void SendVoxMessage( const string& in strVoxLine, edict_t@ dest = null )
{
	string strMsg = "spk \"" + strVoxLine + "\"";
	
	NetworkMessage msg( dest is null ? MSG_ALL : MSG_ONE, NetworkMessages::SVC_STUFFTEXT, dest );
		msg.WriteString( strMsg );
	msg.End();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();
	
	if( pArguments.ArgC() >= 1 )
	{
		if( pArguments[ 0 ] == "!vox" )
		{
			string strVoxLine;
			for( int iIndex = 1; iIndex < pArguments.ArgC(); ++iIndex )
			{
				if ( iIndex > 1 )
					strVoxLine += " ";
				strVoxLine += pArguments[ iIndex ];
			}
			SendVoxMessage( strVoxLine, null );
			
			pParams.ShouldHide = true;
			
			return HOOK_HANDLED;
		}
	}
	
	return HOOK_CONTINUE;
}
