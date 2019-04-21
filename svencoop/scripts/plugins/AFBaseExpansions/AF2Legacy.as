// direct copypaste from AF2 code - helper.as (modif: 24.12.2016, 03:41)

namespace AF2LegacyCode
{
	//dubbed: superstring

	string sstring(string vin)
	{
		return string(vin);
	}

	string sstring(double vin)
	{
		return string(vin);
	}

	string sstring(int vin)
	{
		return string(vin);
	}

	string sstring(uint vin)
	{
		return string(vin);
	}

	string sstring(bool vin)
	{
		return string(vin);
	}

	string sstring(char vin)
	{
		return string(vin);
	}

	string sstring(Vector vin)
	{
		string sComp = string(vin.x)+" "+string(vin.y)+" "+string(vin.z);
		return sComp;
	}

	// this was written because there is
	// no way to "get" a keyvalue exactly

	string getKeyValue(CBasePlayer@ pPlayer, string sKey)
	{
		return getKeyValue(cast<CBaseEntity@>(pPlayer), sKey);
	}

	string getKeyValue(CBaseEntity@ pEntity, string sKey)
	{
		if(sKey == "classname")
		{
			return sstring(pEntity.pev.classname);
		}else if(sKey == "origin")
		{
			return sstring(pEntity.pev.origin);
		}else if(sKey == "oldorigin")
		{
			return sstring(pEntity.pev.oldorigin);
		}else if(sKey == "velocity")
		{
			return sstring(pEntity.pev.velocity);
		}else if(sKey == "movedir")
		{
			return sstring(pEntity.pev.movedir);
		}else if(sKey == "angles")
		{
			return sstring(pEntity.pev.angles);
		}else if(sKey == "avelocity")
		{
			return sstring(pEntity.pev.avelocity);
		}else if(sKey == "punchangle")
		{
			return sstring(pEntity.pev.punchangle);
		}else if(sKey == "v_angle")
		{
			return sstring(pEntity.pev.v_angle);
		}else if(sKey == "endpos")
		{
			return sstring(pEntity.pev.endpos);
		}else if(sKey == "startpos")
		{
			return sstring(pEntity.pev.startpos);
		}else if(sKey == "modelindex")
		{
			return sstring(pEntity.pev.modelindex);
		}else if(sKey == "model")
		{
			return sstring(pEntity.pev.model);
		}else if(sKey == "viewmodel")
		{
			return sstring(pEntity.pev.viewmodel);
		}else if(sKey == "weaponmodel")
		{
			return sstring(pEntity.pev.weaponmodel);
		}else if(sKey == "absmin")
		{
			return sstring(pEntity.pev.absmin);
		}else if(sKey == "absmax")
		{
			return sstring(pEntity.pev.absmax);
		}else if(sKey == "mins")
		{
			return sstring(pEntity.pev.mins);
		}else if(sKey == "maxs")
		{
			return sstring(pEntity.pev.maxs);
		}else if(sKey == "size")
		{
			return sstring(pEntity.pev.size);
		}else if(sKey == "movetype")
		{
			return sstring(pEntity.pev.movetype);
		}else if(sKey == "solid")
		{
			return sstring(pEntity.pev.solid);
		}else if(sKey == "skin")
		{
			return sstring(pEntity.pev.skin);
		}else if(sKey == "body")
		{
			return sstring(pEntity.pev.body);
		}else if(sKey == "effects")
		{
			return sstring(pEntity.pev.effects);
		}else if(sKey == "gravity")
		{
			return sstring(pEntity.pev.gravity);
		}else if(sKey == "friction")
		{
			return sstring(pEntity.pev.friction);
		}else if(sKey == "sequence")
		{
			return sstring(pEntity.pev.sequence);
		}else if(sKey == "gaitsequence")
		{
			return sstring(pEntity.pev.gaitsequence);
		}else if(sKey == "scale")
		{
			return sstring(pEntity.pev.scale);
		}else if(sKey == "rendermode")
		{
			return sstring(pEntity.pev.rendermode);
		}else if(sKey == "renderamt")
		{
			return sstring(pEntity.pev.renderamt);
		}else if(sKey == "rendercolor")
		{
			return sstring(pEntity.pev.rendercolor);
		}else if(sKey == "renderfx")
		{
			return sstring(pEntity.pev.renderfx);
		}else if(sKey == "health")
		{
			return sstring(pEntity.pev.health);
		}else if(sKey == "frags")
		{
			return sstring(pEntity.pev.frags);
		}else if(sKey == "weapons")
		{
			return sstring(pEntity.pev.weapons);
		}else if(sKey == "takedamage")
		{
			return sstring(pEntity.pev.takedamage);
		}else if(sKey == "deadflag")
		{
			return sstring(pEntity.pev.deadflag);
		}else if(sKey == "view_ofs")
		{
			return sstring(pEntity.pev.view_ofs);
		}else if(sKey == "impulse")
		{
			return sstring(pEntity.pev.impulse);
		}else if(sKey == "spawnflags")
		{
			return sstring(pEntity.pev.spawnflags);
		}else if(sKey == "flags")
		{
			return sstring(pEntity.pev.flags);
		}else if(sKey == "colormap")
		{
			return sstring(pEntity.pev.colormap);
		}else if(sKey == "team")
		{
			return sstring(pEntity.pev.team);
		}else if(sKey == "max_health")
		{
			return sstring(pEntity.pev.max_health);
		}else if(sKey == "armortype")
		{
			return sstring(pEntity.pev.armortype);
		}else if(sKey == "armorvalue")
		{
			return sstring(pEntity.pev.armorvalue);
		}else if(sKey == "target")
		{
			return sstring(pEntity.pev.target);
		}else if(sKey == "targetname")
		{
			return sstring(pEntity.pev.targetname);
		}else if(sKey == "netname")
		{
			return sstring(pEntity.pev.netname);
		}else if(sKey == "message")
		{
			return sstring(pEntity.pev.message);
		}else if(sKey == "dmg")
		{
			return sstring(pEntity.pev.dmg);
		}else if(sKey == "noise")
		{
			return sstring(pEntity.pev.noise);
		}else if(sKey == "noise1")
		{
			return sstring(pEntity.pev.noise1);
		}else if(sKey == "noise2")
		{
			return sstring(pEntity.pev.noise2);
		}else if(sKey == "noise3")
		{
			return sstring(pEntity.pev.noise3);
		}else if(sKey == "speed")
		{
			return sstring(pEntity.pev.speed);
		}else if(sKey == "maxspeed")
		{
			return sstring(pEntity.pev.maxspeed);
		}else if(sKey == "iuser1")
		{
			return sstring(pEntity.pev.iuser1);
		}else if(sKey == "iuser2")
		{
			return sstring(pEntity.pev.iuser2);
		}else if(sKey == "iuser3")
		{
			return sstring(pEntity.pev.iuser3);
		}else if(sKey == "iuser4")
		{
			return sstring(pEntity.pev.iuser4);
		}else if(sKey == "fuser1")
		{
			return sstring(pEntity.pev.fuser1);
		}else if(sKey == "fuser2")
		{
			return sstring(pEntity.pev.fuser2);
		}else if(sKey == "fuser3")
		{
			return sstring(pEntity.pev.fuser3);
		}else if(sKey == "fuser4")
		{
			return sstring(pEntity.pev.fuser4);
		}else if(sKey == "vuser1")
		{
			return sstring(pEntity.pev.vuser1);
		}else if(sKey == "vuser2")
		{
			return sstring(pEntity.pev.vuser2);
		}else if(sKey == "vuser3")
		{
			return sstring(pEntity.pev.vuser3);
		}else if(sKey == "vuser4")
		{
			return sstring(pEntity.pev.vuser4);
		}else if(sKey == "entindex")
		{
			return sstring(pEntity.entindex());
		}else{
			return "§§§§N/A";
		}
	}
	
	dictionary reverseGetKeyvalue(CBaseEntity@ pEntity)
	{
		string sHold = "";
		dictionary dKeyvalues;
		
		sHold = sstring(pEntity.pev.oldorigin);
		if(sHold.Length() > 0)
			dKeyvalues["oldorigin"] = sHold;
		sHold = sstring(pEntity.pev.velocity);
		if(sHold.Length() > 0)
			dKeyvalues["velocity"] = sHold;
		sHold = sstring(pEntity.pev.movedir);
		if(sHold.Length() > 0)
			dKeyvalues["movedir"] = sHold;
		sHold = sstring(pEntity.pev.angles);
		if(sHold.Length() > 0)
			dKeyvalues["angles"] = sHold;
		sHold = sstring(pEntity.pev.avelocity);
		if(sHold.Length() > 0)
			dKeyvalues["avelocity"] = sHold;
		sHold = sstring(pEntity.pev.punchangle);
		if(sHold.Length() > 0)
			dKeyvalues["punchangle"] = sHold;
		sHold = sstring(pEntity.pev.v_angle);
		if(sHold.Length() > 0)
			dKeyvalues["v_angle"] = sHold;
		sHold = sstring(pEntity.pev.endpos);
		if(sHold.Length() > 0)
			dKeyvalues["endpos"] = sHold;
		sHold = sstring(pEntity.pev.startpos);
		if(sHold.Length() > 0)
			dKeyvalues["startpos"] = sHold;
		sHold = sstring(pEntity.pev.modelindex);
		if(sHold.Length() > 0)
			dKeyvalues["modelindex"] = sHold;
		sHold = sstring(pEntity.pev.model);
		if(sHold.Length() > 0)
			dKeyvalues["model"] = sHold;
		sHold = sstring(pEntity.pev.viewmodel);
		if(sHold.Length() > 0)
			dKeyvalues["viewmodel"] = sHold;
		sHold = sstring(pEntity.pev.weaponmodel);
		if(sHold.Length() > 0)
			dKeyvalues["weaponmodel"] = sHold;
		sHold = sstring(pEntity.pev.absmin);
		if(sHold.Length() > 0)
			dKeyvalues["absmin"] = sHold;
		sHold = sstring(pEntity.pev.absmax);
		if(sHold.Length() > 0)
			dKeyvalues["absmax"] = sHold;
		sHold = sstring(pEntity.pev.mins);
		if(sHold.Length() > 0)
			dKeyvalues["mins"] = sHold;
		sHold = sstring(pEntity.pev.maxs);
		if(sHold.Length() > 0)
			dKeyvalues["maxs"] = sHold;
		sHold = sstring(pEntity.pev.size);
		if(sHold.Length() > 0)
			dKeyvalues["size"] = sHold;
		sHold = sstring(pEntity.pev.movetype);
		if(sHold.Length() > 0)
			dKeyvalues["movetype"] = sHold;
		sHold = sstring(pEntity.pev.solid);
		if(sHold.Length() > 0)
			dKeyvalues["solid"] = sHold;
		sHold = sstring(pEntity.pev.skin);
		if(sHold.Length() > 0)
			dKeyvalues["skin"] = sHold;
		sHold = sstring(pEntity.pev.body);
		if(sHold.Length() > 0)
			dKeyvalues["body"] = sHold;
		sHold = sstring(pEntity.pev.effects);
		if(sHold.Length() > 0)
			dKeyvalues["effects"] = sHold;
		sHold = sstring(pEntity.pev.gravity);
		if(sHold.Length() > 0)
			dKeyvalues["gravity"] = sHold;
		sHold = sstring(pEntity.pev.friction);
		if(sHold.Length() > 0)
			dKeyvalues["friction"] = sHold;
		sHold = sstring(pEntity.pev.sequence);
		if(sHold.Length() > 0)
			dKeyvalues["sequence"] = sHold;
		sHold = sstring(pEntity.pev.gaitsequence);
		if(sHold.Length() > 0)
			dKeyvalues["gaitsequence"] = sHold;
		sHold = sstring(pEntity.pev.scale);
		if(sHold.Length() > 0)
			dKeyvalues["scale"] = sHold;
		sHold = sstring(pEntity.pev.rendermode);
		if(sHold.Length() > 0)
			dKeyvalues["rendermode"] = sHold;
		sHold = sstring(pEntity.pev.renderamt);
		if(sHold.Length() > 0)
			dKeyvalues["renderamt"] = sHold;
		sHold = sstring(pEntity.pev.rendercolor);
		if(sHold.Length() > 0)
			dKeyvalues["rendercolor"] = sHold;
		sHold = sstring(pEntity.pev.renderfx);
		if(sHold.Length() > 0)
			dKeyvalues["renderfx"] = sHold;
		sHold = sstring(pEntity.pev.health);
		if(sHold.Length() > 0)
			dKeyvalues["health"] = sHold;
		sHold = sstring(pEntity.pev.frags);
		if(sHold.Length() > 0)
			dKeyvalues["frags"] = sHold;
		sHold = sstring(pEntity.pev.weapons);
		if(sHold.Length() > 0)
			dKeyvalues["weapons"] = sHold;
		sHold = sstring(pEntity.pev.takedamage);
		if(sHold.Length() > 0)
			dKeyvalues["takedamage"] = sHold;
		sHold = sstring(pEntity.pev.deadflag);
		if(sHold.Length() > 0)
			dKeyvalues["deadflag"] = sHold;
		sHold = sstring(pEntity.pev.view_ofs);
		if(sHold.Length() > 0)
			dKeyvalues["view_ofs"] = sHold;
		sHold = sstring(pEntity.pev.impulse);
		if(sHold.Length() > 0)
			dKeyvalues["impulse"] = sHold;
		sHold = sstring(pEntity.pev.spawnflags);
		if(sHold.Length() > 0)
			dKeyvalues["spawnflags"] = sHold;
		sHold = sstring(pEntity.pev.colormap);
		if(sHold.Length() > 0)
			dKeyvalues["colormap"] = sHold;
		sHold = sstring(pEntity.pev.team);
		if(sHold.Length() > 0)
			dKeyvalues["team"] = sHold;
		sHold = sstring(pEntity.pev.max_health);
		if(sHold.Length() > 0)
			dKeyvalues["max_health"] = sHold;
		sHold = sstring(pEntity.pev.armortype);
		if(sHold.Length() > 0)
			dKeyvalues["armortype"] = sHold;
		sHold = sstring(pEntity.pev.target);
		if(sHold.Length() > 0)
			dKeyvalues["target"] = sHold;
		sHold = sstring(pEntity.pev.targetname);
		if(sHold.Length() > 0)
			dKeyvalues["targetname"] = sHold;
		sHold = sstring(pEntity.pev.netname);
		if(sHold.Length() > 0)
			dKeyvalues["netname"] = sHold;
		sHold = sstring(pEntity.pev.message);
		if(sHold.Length() > 0)
			dKeyvalues["message"] = sHold;
		sHold = sstring(pEntity.pev.dmg);
		if(sHold.Length() > 0)
			dKeyvalues["dmg"] = sHold;
		sHold = sstring(pEntity.pev.noise);
		if(sHold.Length() > 0)
			dKeyvalues["noise"] = sHold;
		sHold = sstring(pEntity.pev.noise1);
		if(sHold.Length() > 0)
			dKeyvalues["noise1"] = sHold;
		sHold = sstring(pEntity.pev.noise2);
		if(sHold.Length() > 0)
			dKeyvalues["noise2"] = sHold;
		sHold = sstring(pEntity.pev.noise3);
		if(sHold.Length() > 0)
			dKeyvalues["noise3"] = sHold;
		sHold = sstring(pEntity.pev.speed);
		if(sHold.Length() > 0)
			dKeyvalues["speed"] = sHold;
		sHold = sstring(pEntity.pev.maxspeed);
		if(sHold.Length() > 0)
			dKeyvalues["maxspeed"] = sHold;
		sHold = sstring(pEntity.pev.iuser1);
		if(sHold.Length() > 0)
			dKeyvalues["iuser1"] = sHold;
		sHold = sstring(pEntity.pev.iuser2);
		if(sHold.Length() > 0)
			dKeyvalues["iuser2"] = sHold;
		sHold = sstring(pEntity.pev.iuser3);
		if(sHold.Length() > 0)
			dKeyvalues["iuser3"] = sHold;
		sHold = sstring(pEntity.pev.iuser4);
		if(sHold.Length() > 0)
			dKeyvalues["iuser4"] = sHold;
		sHold = sstring(pEntity.pev.fuser1);
		if(sHold.Length() > 0)
			dKeyvalues["fuser1"] = sHold;
		sHold = sstring(pEntity.pev.fuser2);
		if(sHold.Length() > 0)
			dKeyvalues["fuser2"] = sHold;
		sHold = sstring(pEntity.pev.fuser3);
		if(sHold.Length() > 0)
			dKeyvalues["fuser3"] = sHold;
		sHold = sstring(pEntity.pev.fuser4);
		if(sHold.Length() > 0)
			dKeyvalues["fuser4"] = sHold;
		sHold = sstring(pEntity.pev.vuser1);
		if(sHold.Length() > 0)
			dKeyvalues["vuser1"] = sHold;
		sHold = sstring(pEntity.pev.vuser2);
		if(sHold.Length() > 0)
			dKeyvalues["vuser2"] = sHold;
		sHold = sstring(pEntity.pev.vuser3);
		if(sHold.Length() > 0)
			dKeyvalues["vuser3"] = sHold;
		sHold = sstring(pEntity.pev.vuser4);
		if(sHold.Length() > 0)
			dKeyvalues["vuser4"] = sHold;
		
		return dKeyvalues;
	}
	
	dictionary prunezero(dictionary din)
	{
		array<string> dk = din.getKeys();
		dictionary dout;
		for(uint i = 0; i < dk.length(); i++)
		{
			string sTest = string(din[dk[i]]);
			if(sTest == "" || sTest == " " || sTest == "0" || sTest == "0 " || sTest == "0 0 0" || sTest == "0 0 0 ")
				continue;
				
			// remove origin data
			if(dk[i] == "origin" || dk[i] == "oldorigin")
				continue;
				
			dout[dk[i]] = sTest;
		}
		
		return dout;
	}
	
	dictionary cleancopy(dictionary din)
	{
		array<string> dk = din.getKeys();
		dictionary dout;
		for(uint i = 0; i < dk.length(); i++)
		{
			string sTest = string(din[dk[i]]);
			if(dk[i] == "origin" || dk[i] == "oldorigin" || dk[i] == "startpos" || dk[i] == "endpos" || dk[i] == "size" || dk[i] == "mins" || dk[i] == "maxs" || dk[i] == "absmin" || dk[i] == "absmax")
				continue;
				
			dout[dk[i]] = sTest;
		}
		
		return prunezero(dout);
	}

}