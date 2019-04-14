int dropper_weapon_box_counter = 0;
int dropper_weapon_box_counter_max = 300;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSayDropper );
}

HookReturnCode ClientSayDropper(SayParameters@ pParams){
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	const CCommand@ pArguments = pParams.GetArguments();
	string str = pArguments[0];
	str.ToUppercase();
	
	if( str == "DROPAMMO" ){
		pParams.ShouldHide = true;
		
		string ammoName1 = "";
		string ammoName2 = "";
		
		if( pPlayer.m_hActiveItem.GetEntity() !is null ) {
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_hActiveItem.GetEntity() );
			if( pWeapon !is null ){
				ammoName1 = pWeapon.pszAmmo1();
				ammoName2 = pWeapon.pszAmmo2();
			}
		}
		
		int ammoInv = 0;
		int ammoInv2 = 0;
		int ammoInvHealth = 0;
		int ammoInvOld = -1;
		if(ammoName1 != "") ammoInvOld = pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex(ammoName1));
		int ammoInvOld2 = -1;
		if(ammoName2 != "") ammoInvOld2 = pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex(ammoName2));
		
		str = pArguments[1];
		str.ToUppercase();
		
		int customDrop = atoi(pArguments[1]);
		int customDrop2 = atoi(pArguments[2]);
		
		if (ammoName1 == "Snarks"){
			if(customDrop<1){
				ammoInv = 1;
			}else{
				if (customDrop>ammoInvOld) customDrop=ammoInvOld;
				ammoInv = customDrop;
			}
			pPlayer.m_rgAmmo(g_PlayerFuncs.GetAmmoIndex(ammoName1), ammoInvOld-ammoInv);
		}else if(ammoName1 == "health"){
			if(ammoInvOld >= 10){
				ammoInvHealth = 1;
				pPlayer.m_rgAmmo(g_PlayerFuncs.GetAmmoIndex(ammoName1), ammoInvOld-10);
				
				string tarName = "dropper_weaponbox_"+dropper_weapon_box_counter;
				
				CBaseEntity@ pEntity = null;
				@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, tarName);
				if( !(pEntity is null) )
					g_EntityFuncs.Remove(pEntity);
				
				CBaseEntity@ pWeaponBox = g_EntityFuncs.Create("ammo_medkit", pPlayer.pev.origin, pPlayer.pev.angles, false);
				
				pWeaponBox.pev.targetname = tarName;
				pWeaponBox.pev.spawnflags = 1024;
				pWeaponBox.pev.origin.z = pWeaponBox.pev.origin.z - 16.0f;
				pWeaponBox.pev.velocity.x = cos(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 240.0f;
				pWeaponBox.pev.velocity.y = sin(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 240.0f;
				pWeaponBox.pev.velocity.z = sin(pPlayer.pev.angles.x/60.0f*3.1415927f) * 240.0f + 240.0f ;
				pWeaponBox.pev.solid = SOLID_NOT;
				
				dropper_weapon_box_counter++;
				if ( dropper_weapon_box_counter >= dropper_weapon_box_counter_max ) dropper_weapon_box_counter = 0;
			}
			
		}else if(ammoName1 != "" && ammoName1 != "Hornets" && g_PlayerFuncs.GetAmmoIndex(ammoName1) > 0){
			if(customDrop<1){
				ammoInv = pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex(ammoName1));
				ammoInv = ammoInv-ammoInv*9/10;
			}else{
				if (customDrop>ammoInvOld) customDrop=ammoInvOld;
				ammoInv = customDrop;
			}
			pPlayer.m_rgAmmo(g_PlayerFuncs.GetAmmoIndex(ammoName1), ammoInvOld-ammoInv);
		}
		
		if(ammoName2 != "" && g_PlayerFuncs.GetAmmoIndex(ammoName2) > 0){
			if(customDrop2<1){
				ammoInv2 = pPlayer.AmmoInventory(g_PlayerFuncs.GetAmmoIndex(ammoName2));
				ammoInv2 = ammoInv2-ammoInv2*9/10;
			}else{
				if (customDrop2>ammoInvOld2) customDrop2=ammoInvOld2;
				ammoInv2 = customDrop2;
			}
			pPlayer.m_rgAmmo(g_PlayerFuncs.GetAmmoIndex(ammoName2), ammoInvOld2-ammoInv2);
		}
		
		if(ammoInv > 0 || ammoInv2 > 0) {
			
			string tarName = "dropper_weaponbox_"+dropper_weapon_box_counter;
			
			CBaseEntity@ pEntity = null;
			@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, tarName);
			if( !(pEntity is null) )
				g_EntityFuncs.Remove(pEntity);
			
			CBaseEntity@ pWeaponBox = g_EntityFuncs.Create("weaponbox", pPlayer.pev.origin, pPlayer.pev.angles, false);
			
			pWeaponBox.pev.targetname = tarName;
			pWeaponBox.pev.spawnflags = 1024;
			pWeaponBox.pev.origin.z = pWeaponBox.pev.origin.z - 16.0f;
			pWeaponBox.pev.velocity.x = cos(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
			pWeaponBox.pev.velocity.y = sin(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
			pWeaponBox.pev.velocity.z = sin(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f + 160.0f ;
			pWeaponBox.pev.solid = SOLID_NOT;
			
			array<string> strArr(3);
			strArr[0] = tarName;
			strArr[1] = ammoName1;
			strArr[2] = ammoName2;
			array<int> intArr(2);
			intArr[0] = ammoInv;
			intArr[1] = ammoInv2;
			
			g_Scheduler.SetTimeout( "AmmoHandling", 0.01, strArr, intArr );
			
			dropper_weapon_box_counter++;
			if ( dropper_weapon_box_counter >= dropper_weapon_box_counter_max ) dropper_weapon_box_counter = 0;
			
		}else if(ammoInvHealth == 0){
			string str1 = "AMMO-DROPPER: Couldn't drop Ammo!\n";
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, str1);
		}
		
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}

void AmmoHandling(array<string>@ strArr, array<int>@ intArr){
	CBaseEntity@ pWeaponBox = null;
	@pWeaponBox = g_EntityFuncs.FindEntityByTargetname(pWeaponBox, strArr[0]);

	if( pWeaponBox !is null ) {
		//pWeaponBox.pev.solid = SOLID_TRIGGER;
		if(intArr[0]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), strArr[1], intArr[0] );
		if(intArr[1]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), strArr[2], intArr[1] );
	}
}
