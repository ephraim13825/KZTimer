// misc.sp

public SetServerTags()
{
	new Handle:CvarHandle;	
	CvarHandle = FindConVar("sv_tags");
	decl String:szServerTags[1024];
	GetConVarString(CvarHandle, szServerTags, 1024);
	Format(szServerTags, 1024, "%s, kztimer, tickrate %i",szServerTags,g_tickrate);
	SetConVarString(CvarHandle, szServerTags);
	if (CvarHandle != INVALID_HANDLE)
		CloseHandle(CvarHandle);
}
		
public PrintConsoleInfo(client)
{
	new timeleft;
	GetMapTimeLeft(timeleft)
	new mins, secs;	
	decl String:finalOutput[1024];
	mins = timeleft / 60;
	secs = timeleft % 60;
	Format(finalOutput, 1024, "%d:%02d", mins, secs);
	new mapbonus= RoundToNearest(g_pr_rank_Master/4.0);
	new Float:fltickrate = 1.0 / GetTickInterval( );
	if (g_bUpdate)
	{
		//PrintToConsole(client, "--------------------------------------------------------------------------------------------------------");
		//PrintToConsole(client, "KZTimer %s outdated. New version available (https://forums.alliedmods.net/showthread.php?t=223274)", VERSION);
	}
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	PrintToConsole(client, "This server is running KZTimer v%s - Tickrate: %i", VERSION, RoundToNearest(fltickrate));
	if (timeleft > 0)
		PrintToConsole(client, "Timeleft on %s: %s",g_szMapName, finalOutput);
	PrintToConsole(client, " ");
	PrintToConsole(client, "Client commands:");
	PrintToConsole(client, "!help, !menu, !options, !checkpoint, !gocheck, !prev, !next, !undo, !profile, !compare, !bhopcheck, !maptop");
	PrintToConsole(client, "!top, !start, !stop, !pause, !usp, !challenge, !surrender, !goto, !spec, !showsettings, !latest, !measure");
	PrintToConsole(client, "(options menu contains: !adv, !info, !colorchat, !cpmessage, !sound, !menusound");
	PrintToConsole(client, "!hide, !hidespecs, !showtime, !disablegoto, !shownames, !sync, !bhop)");
	PrintToConsole(client, " ");
	PrintToConsole(client, "Live scoreboard:");
	PrintToConsole(client, "Kills: Time in seconds");
	PrintToConsole(client, "Assists: Checkpoints");
	PrintToConsole(client, "Deaths: Teleports");
	PrintToConsole(client, "MVP Stars: Number of finished map runs on the current map");
	PrintToConsole(client, " ");
	PrintToConsole(client, "How does the ranking system work?");		
	PrintToConsole(client, "The System depends on your current rank on each map, to prevent points farming.");	
	PrintToConsole(client, "Once you finished a map, you can get only points by improving your rank! (#1,#2,#3 extra bonus)");	
	PrintToConsole(client, "You will get a bonus of %ip when your map completion (tp+pro) has reached 100%",mapbonus);	
	PrintToConsole(client, "Moreover, you can earn points by winning challenges and top 20 lj's, wj's, bhop jumps,");
	PrintToConsole(client, "dropbhop jumps and multi-bhop jumps.");	
	PrintToConsole(client, " ");
	PrintToConsole(client, "Skill groups:");
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[1],g_pr_rank_Novice,g_szSkillGroups[2], g_pr_rank_Scrub,g_szSkillGroups[3], g_pr_rank_Rookie,g_szSkillGroups[4], g_pr_rank_Skilled);
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[5], g_pr_rank_Expert, g_szSkillGroups[6],g_pr_rank_Pro, g_szSkillGroups[7], g_pr_rank_Elite, g_szSkillGroups[8], g_pr_rank_Master);
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");	
	if (g_hDbGlobal == INVALID_HANDLE || !g_BGlobalDBConnected)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: No connection to the global database.");
	else
		if (g_bMapButtons)
			PrintToConsole(client, "[KZ] Global Records disabled. Reason: Self-build climb buttons detected. (only integrated buttons supported)");
		else
			if (!g_bEnforcer)
				PrintToConsole(client, "[KZ] Global Records disabled. Reason: Server settings enforcer disabled.");
			else
				if (!g_bglobalValidFilesize)
					PrintToConsole(client, "[KZ] Global Records disabled. Reason: Wrong .bsp/map file size. (other version registered in the global database. Please contact an admin.)");	
				else
					if (!g_bAntiCheat)
						PrintToConsole(client, "[KZ] Global Records disabled. Reason: KZ AntiCheat disabled.");
					else
						if (g_bAutoTimer)
							PrintToConsole(client, "[KZ] Global Records disabled. Reason: kz_auto_timer enabled.");
						else
							if (g_bAutoBhopWasActive[client])
								PrintToConsole(client, "[KZ] Global Records disabled. Reason: kz_auto_bhop enabled.");	
	PrintToConsole(client," ");
}
stock FakePrecacheSound( const String:szPath[] )
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

stock Client_SetAssists(client, value)
{
	new assists_offset = FindDataMapOffs( client, "m_iFrags" ) + ASSISTS_OFFSET_FROM_FRAGS; 
	SetEntData(client, assists_offset, value );
}

public SetStandingStartButton(client)
{	
	CreateButton(client,"climb_startbuttonx");
}


public SetStandingStopButton(client)
{
	CreateButton(client,"climb_endbuttonx");
}

public Action:BlockRadio(client, const String:command[], args) 
{
	if(!g_bRadioCommands && IsClientInGame(client))
	{
		PrintToChat(client, "%t", "RadioCommandsDisabled", LIMEGREEN,WHITE);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public StringToUpper(String:input[]) 
{
	for(new i = 0; ; i++) 
	{
		if(input[i] == '\0') 
			return;
		input[i] = CharToUpper(input[i]);
	}
}

public GetCountry(client)
{
	if(client != 0)
	{
		if(!IsFakeClient(client))
		{
			new String:IP[16];
			decl String:code2[3];
			GetClientIP(client, IP, 16);
			
			//COUNTRY
			GeoipCountry(IP, g_szCountry[client], 100);     
			if(!strcmp(g_szCountry[client], NULL_STRING))
				Format( g_szCountry[client], 100, "Unknown", g_szCountry[client] );
			else				
				if( StrContains( g_szCountry[client], "United", false ) != -1 || 
					StrContains( g_szCountry[client], "Republic", false ) != -1 || 
					StrContains( g_szCountry[client], "Federation", false ) != -1 || 
					StrContains( g_szCountry[client], "Island", false ) != -1 || 
					StrContains( g_szCountry[client], "Netherlands", false ) != -1 || 
					StrContains( g_szCountry[client], "Isle", false ) != -1 || 
					StrContains( g_szCountry[client], "Bahamas", false ) != -1 || 
					StrContains( g_szCountry[client], "Maldives", false ) != -1 || 
					StrContains( g_szCountry[client], "Philippines", false ) != -1 || 
					StrContains( g_szCountry[client], "Vatican", false ) != -1 )
				{
					Format( g_szCountry[client], 100, "The %s", g_szCountry[client] );
				}				
			//CODE
			if(GeoipCode2(IP, code2))
			{
				Format(g_szCountryCode[client], 16, "%s",code2);		
			}
			else
				Format(g_szCountryCode[client], 16, "??");	
		}
	}
}

public StripWeapons(client) 
{
	new weapons;
	for (new i = 0; i < 4; i++)
	{
		if (i < 4 && (weapons = GetPlayerWeaponSlot(client, i)) != -1 && (weapons = GetPlayerWeaponSlot(client, i)) != 2) 
		{
			RemovePlayerItem(client, weapons);	
		}
		GivePlayerItem(client, "weapon_knife");	
	}
	if (IsFakeClient(client))
		GivePlayerItem(client, "weapon_usp_silencer");		
}

public DeleteButtons(client)
{
	new String:classname[32];
	Format(classname,32,"prop_physics_override");
	for (new i; i < GetEntityCount(); i++)
    {
        if (IsValidEdict(i) && GetEntityClassname(i, classname, 32))
		{
			decl String:targetname[64];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			if (StrEqual(targetname, "climb_startbuttonx", false) || StrEqual(targetname, "climb_endbuttonx", false))
			{
				if (StrEqual(targetname, "climb_startbuttonx", false))
				{
					g_fStartButtonPos[0] = -999999.9;
					g_fStartButtonPos[1] = -999999.9;
					g_fStartButtonPos[2] = -999999.9;
				}
				else
				{
					g_fEndButtonPos[0] = -999999.9;
					g_fEndButtonPos[1] = -999999.9;
					g_fEndButtonPos[2] = -999999.9;		
				}
				AcceptEntityInput(i, "Kill"); 
				RemoveEdict(i);
			}
		}	
	}
	Format(classname,32,"env_sprite");
	for (new i; i < GetEntityCount(); i++)
	{
        if (IsValidEdict(i) && GetEntityClassname(i, classname, 32))
		{
			decl String:targetname[64];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			if (StrEqual(targetname, "starttimersign", false) || StrEqual(targetname, "stoptimersign", false))
			{
				AcceptEntityInput(i, "Kill");
				RemoveEdict(i);
			}
		}
	}
	g_bMapButtons = false;
	GetButtonsPos();

	//stop player times (global record fake)
	for (new i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && !IsFakeClient(client))	
	{
		Client_Stop(i,0);
	}
	
	KzAdminMenu(client);
}

public CreateButton(client,String:targetname[]) 
{
	if (IsPlayerAlive(client))
	{
		//location (crosshair)
		new Float:locationPlayer[3];
		new Float:location[3];
		GetClientAbsOrigin(client, locationPlayer);
		GetClientEyePosition(client, location);
		new Float:ang[3];
		GetClientEyeAngles(client, ang);
		new Float:location2[3];
		location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
		location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
		ang[0] -= (2*ang[0]);
		location2[2] = (location[2]+(100*(Sine(DegToRad(ang[0])))));
		location2[2] = locationPlayer[2];
	
		new ent = CreateEntityByName("prop_physics_override");
		if (ent != -1)
		{  
			DispatchKeyValue(ent, "model", "models/props/switch001.mdl");	
			DispatchKeyValue(ent, "spawnflags", "264");
			DispatchKeyValue(ent, "targetname",targetname);
			DispatchSpawn(ent);  
			ang[0] = 0.0;
			ang[1] += 180.0;
			TeleportEntity(ent, location2, ang, NULL_VECTOR);
			SDKHook(ent, SDKHook_UsePost, OnUsePost);	
			if (StrEqual(targetname, "climb_startbuttonx"))
				PrintToChat(client,"%c[%cKZ%c] Start button built!", WHITE,MOSSGREEN,WHITE);
			else
				PrintToChat(client,"%c[%cKZ%c] Stop button built!", WHITE,MOSSGREEN,WHITE);
			g_bMapButtons=true;
			ang[1] -= 180.0;
		}
		new sprite = CreateEntityByName("env_sprite");
		if(sprite != -1) 
		{ 
			DispatchKeyValue(sprite, "classname", "env_sprite");
			DispatchKeyValue(sprite, "spawnflags", "1");
			DispatchKeyValue(sprite, "scale", "0.2");
			if (StrEqual(targetname, "climb_startbuttonx"))
			{
				DispatchKeyValue(sprite, "model", "materials/models/props/startkztimer.vmt"); 
				DispatchKeyValue(sprite, "targetname", "starttimersign");
			}
			else
			{
				DispatchKeyValue(sprite, "model", "materials/models/props/stopkztimer.vmt"); 
				DispatchKeyValue(sprite, "targetname", "stoptimersign");
			}
			DispatchKeyValue(sprite, "rendermode", "1");
			DispatchKeyValue(sprite, "framerate", "0");
			DispatchKeyValue(sprite, "HDRColorScale", "1.0");
			DispatchKeyValue(sprite, "rendercolor", "255 255 255");
			DispatchKeyValue(sprite, "renderamt", "255");
			DispatchSpawn(sprite);
			location = location2;	
			location[2]+=95;
			ang[0] = 0.0;
			TeleportEntity(sprite, location, ang, NULL_VECTOR);
		}
		
		if (StrEqual(targetname, "climb_startbuttonx"))
		{
			db_updateMapButtons(location2[0],location2[1],location2[2],ang[1],0);
			g_fStartButtonPos = location2;
		}
		else
		{
			db_updateMapButtons(location2[0],location2[1],location2[2],ang[1],1);
			g_fEndButtonPos =  location2;
		}
	}
	else
		PrintToChat(client, "%t", "AdminSetButton", MOSSGREEN,WHITE); 
	KzAdminMenu(client);
}

public GetButtonsPos()
{
	for (new i; i < GetEntityCount(); i++)
    {
        if (IsValidEdict(i))
		{
			decl String:targetname[64];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			if (StrEqual(targetname, "climb_startbutton", false))
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", g_fStartButtonPos);
				GetEntPropVector(i, Prop_Data, "m_angRotation", g_fStartButtonAngle);  
			}
			else
				if (StrEqual(targetname, "climb_endbutton", false) || StrEqual(targetname, "climb_stopbutton", false))
				{
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", g_fEndButtonPos);
					GetEntPropVector(i, Prop_Data, "m_angRotation", g_fEndButtonAngle);  
				}
		}	
	}
}

// - Get Runtime -
public GetcurrentRunTime(client)
{
	g_fRunTime[client] = GetEngineTime() - g_fStartTime[client] - g_fPauseTime[client];					
	if (g_bPause[client])
		Format(g_szMenuTitleRun[client], 255, "%s\nTimer on Hold", g_szPlayerPanelText[client]);
	else
	{
		FormatTimeFloat(client, g_fRunTime[client], 1);
		if(g_bShowTime[client])
		{		
			if(StrEqual(g_szPlayerPanelText[client],""))		
				Format(g_szMenuTitleRun[client], 255, "%s", g_szTime[client]);
			else
				Format(g_szMenuTitleRun[client], 255, "%s\n%s", g_szPlayerPanelText[client],g_szTime[client]);
		}
		else
		{
			Format(g_szMenuTitleRun[client], 255, "%s", g_szPlayerPanelText[client]);
		}
	}	
}

public Float:GetSpeed(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
	return speed;
}

public Float:GetVelocity(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0)+Pow(fVelocity[2],2.0));
	return speed;
}

public PlayLeetJumpSound(client)
{
	decl String:buffer[255];	

	//all sound
	if (g_LeetJumpDominating[client] == 3 || g_LeetJumpDominating[client] == 5)
	{
		for (new i = 1; i <= MaxClients; i++)
		{ 
			if(IsClientInGame(i) && !IsFakeClient(i) && i != client && g_bColorChat[i] && g_bEnableQuakeSounds[i])
			{	
					if (g_LeetJumpDominating[client]==3)
					{
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH); 	
						ClientCommand(i, buffer); 
					}
					else
						if (g_LeetJumpDominating[client]==5)
						{
							Format(buffer, sizeof(buffer), "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH); 		
							ClientCommand(i, buffer); 
						}
			}
		}
	}
	
	//client sound
	if 	(IsClientInGame(client) && !IsFakeClient(client) && g_bEnableQuakeSounds[client])
	{
		if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
		{
			Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 
			ClientCommand(client, buffer); 
		}
			else
			if (g_LeetJumpDominating[client]==3)
			{
				Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH); 	
				ClientCommand(client, buffer); 
			}
			else
			if (g_LeetJumpDominating[client]==5)
			{
				Format(buffer, sizeof(buffer), "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH); 		
				ClientCommand(client, buffer); 
			}					
	}
}

public SetCashState()
{
	ServerCommand("mp_startmoney 0; mp_playercashawards 0; mp_teamcashawards 0");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
			SetEntProp(i, Prop_Send, "m_iAccount", 0);
	}
}

public PlayRecordSound(iRecordtype)
{
	decl String:buffer[255];
	if (iRecordtype==1)
	    for(new i = 1; i <= GetMaxClients(); i++) 
		{ 
			if(IsClientInGame(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true) 
			{ 
				Format(buffer, sizeof(buffer), "play %s", PRO_RELATIVE_SOUND_PATH); 
				ClientCommand(i, buffer); 
			}
		} 
	else
		if (iRecordtype==2 || iRecordtype == 3)
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsClientInGame(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true) 
				{ 
					Format(buffer, sizeof(buffer), "play %s", CP_RELATIVE_SOUND_PATH); 
					ClientCommand(i, buffer); 
				}
			}
}

public InitPrecache()
{
	AddFileToDownloadsTable( PRO_FULL_SOUND_PATH );
	FakePrecacheSound( PRO_RELATIVE_SOUND_PATH );	
	AddFileToDownloadsTable( CP_FULL_SOUND_PATH );
	FakePrecacheSound( CP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PRO_FULL_SOUND_PATH );
	FakePrecacheSound( PRO_RELATIVE_SOUND_PATH );	
	AddFileToDownloadsTable( LEETJUMP_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( LEETJUMP_DOMINATING_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( LEETJUMP_RAMPAGE_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PROJUMP_FULL_SOUND_PATH );
	FakePrecacheSound( PROJUMP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable("models/props/switch001.mdl");
	AddFileToDownloadsTable("models/props/switch001.vvd");
	AddFileToDownloadsTable("models/props/switch001.phy");
	AddFileToDownloadsTable("models/props/switch001.vtx");
	AddFileToDownloadsTable("models/props/switch001.dx90.vtx");		
	AddFileToDownloadsTable("materials/models/props/switch.vmt");
	AddFileToDownloadsTable("materials/models/props/switch.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_normal.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_normal.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_lightwarp.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_lightwarp.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_exponent.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_exponent.vtf");
	AddFileToDownloadsTable("materials/models/props/startkztimer.vmt");
	AddFileToDownloadsTable("materials/models/props/startkztimer.vtf");	
	AddFileToDownloadsTable("materials/models/props/stopkztimer.vmt");
	AddFileToDownloadsTable("materials/models/props/stopkztimer.vtf");
	AddFileToDownloadsTable("materials/sprites/bluelaser1.vmt");
	AddFileToDownloadsTable("materials/sprites/bluelaser1.vtf");
	AddFileToDownloadsTable(g_sArmModel);
	AddFileToDownloadsTable(g_sPlayerModel);
	AddFileToDownloadsTable(g_sReplayBotArmModel);
	AddFileToDownloadsTable(g_sReplayBotPlayerModel);
	g_iGlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt",true);
	PrecacheModel("materials/models/props/startkztimer.vmt",true);
	PrecacheModel("materials/models/props/stopkztimer.vmt",true);
	PrecacheModel("models/props/switch001.mdl",true);	
	PrecacheModel(g_sReplayBotArmModel,true);
	PrecacheModel(g_sReplayBotPlayerModel,true);
	PrecacheModel(g_sArmModel,true);
	PrecacheModel(g_sPlayerModel,true);
}

// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
stock TraceClientViewEntity(client)
{
	new Float:m_vecOrigin[3];
	new Float:m_angRotation[3];
	GetClientEyePosition(client, m_vecOrigin);
	GetClientEyeAngles(client, m_angRotation);
	new Handle:tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	new pEntity = -1;
	if (TR_DidHit(tr))
	{
		pEntity = TR_GetEntityIndex(tr);
		CloseHandle(tr);
		return pEntity;
	}
	CloseHandle(tr);
	return -1;
}

// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
public bool:TRDontHitSelf(entity, mask, any:data)
{
	if (entity == data)
		return false;
	return true;
}

public PrintMapRecords(client)
{
	if (g_fRecordTimeGlobal102 != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTimeGlobal102, 3);
		PrintToChat(client, "[%cKZ%c] %cGLOBAL RECORD (102)%c: %s (%s)",MOSSGREEN,WHITE,RED,WHITE, g_szTime[client], g_szRecordGlobalPlayer102); 
	}	
	if (g_fRecordTimeGlobal != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTimeGlobal, 3);
		PrintToChat(client, "[%cKZ%c] %cGLOBAL RECORD (64)%c: %s (%s)",MOSSGREEN,WHITE,RED,WHITE, g_szTime[client], g_szRecordGlobalPlayer); 
	}	
	if (g_fRecordTimeGlobal128 != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTimeGlobal128, 3);
		PrintToChat(client, "[%cKZ%c] %cGLOBAL RECORD (128)%c: %s (%s)",MOSSGREEN,WHITE,RED,WHITE, g_szTime[client], g_szRecordGlobalPlayer128); 
	}	
	if (g_fRecordTimePro != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTimePro, 3);
		PrintToChat(client, "[%cKZ%c] %cPRO RECORD%c: %s (%s)",MOSSGREEN,WHITE,PURPLE,WHITE, g_szTime[client], g_szRecordPlayerPro); 
	}	
	if (g_fRecordTime != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTime, 3);
		PrintToChat(client, "[%cKZ%c] %cTP RECORD%c: %s (%s)",MOSSGREEN,WHITE,YELLOW,WHITE, g_szTime[client], g_szRecordPlayer); 
	}	
}

public MapFinishedMsgs(client, type)
{	
	if (IsClientConnected(client))
	{
		
		decl String:szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);
		new count;
		new rank;
		if (type==1)
		{
			count = g_maptimes_pro;
			rank = g_maprank_pro[client];
			FormatTimeFloat(client, g_fRecordTimePro, 3);	
		}
		else
		if (type==0)
		{
			count = g_maptimes_tp;
			rank = g_maprank_tp[client];		
			FormatTimeFloat(client, g_fRecordTime, 3);	
		}
		for(new i = 1; i <= GetMaxClients(); i++) 
		if(IsClientInGame(i) && !IsFakeClient(i)) 
		{
			if (g_time_type[client] == 0)
			{
				PrintToChat(i, "%t", "MapFinished0",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_newTp[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE); 
				PrintToConsole(i, "%s finished with a tp time of (%s, TP's: %i). [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_newTp[client],rank,count,g_szTime[client]); 
			}
			else
			if (g_time_type[client] == 1)
			{
				PrintToChat(i, "%t", "MapFinished1",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE); 
				PrintToConsole(i, "%s finished with a pro time of (%s). [rank #%i/%i | record %s]",szName,g_szNewTime[client],rank,count,g_szTime[client]);  
			}			
			else
				if (g_time_type[client] == 2)
				{
					PrintToChat(i, "%t", "MapFinished2",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_newTp[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  				
					PrintToConsole(i, "%s finished with a tp time of (%s, TP's: %i). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_newTp[client],g_szTimeDifference[client],rank,count,g_szTime[client]);  
				}
				else
					if (g_time_type[client] == 3)
					{
						PrintToChat(i, "%t", "MapFinished3",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  				
						PrintToConsole(i, "%s finished with a pro time of (%s). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 	
					}
					else
						if (g_time_type[client] == 4)
						{
							PrintToChat(i, "%t", "MapFinished4",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_newTp[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  	
							PrintToConsole(i, "%s finished with a tp time of (%s, TP's: %i). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_newTp[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 
						}
						else
							if (g_time_type[client] == 5)
							{
								PrintToChat(i, "%t", "MapFinished5",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  	
								PrintToConsole(i, "%s finished with a pro time of (%s). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 
							}
			//new record msg
			if (g_record_type[client] == 5)				
			{
				PrintToChat(i, "%t", "NewGlobalRecord102",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED); 	
				PrintToConsole(i, "[KZ] %s scored a new GLOBAL RECORD (102)",szName); 		
			}
			else
				if (g_record_type[client] == 4)				
				{
					PrintToChat(i, "%t", "NewGlobalRecord128",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED); 	
					PrintToConsole(i, "[KZ] %s scored a new GLOBAL RECORD (128)",szName); 		
				}
				else
					if (g_record_type[client] == 3)				
					{
						PrintToChat(i, "%t", "NewGlobalRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED); 	
						PrintToConsole(i, "[KZ] %s scored a new GLOBAL RECORD",szName); 		
					}
					else
						if (g_record_type[client] == 2)				
						{
							PrintToChat(i, "%t", "NewProRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,PURPLE);  
							PrintToConsole(i, "[KZ] %s scored a new PRO RECORD",szName); 	
						}		
						else
							if (g_record_type[client] == 1)				
							{
								PrintToChat(i, "%t", "NewTpRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW); 	
								PrintToConsole(i, "[KZ] %s scored a new TP RECORD",szName); 	
							}					
		}
		
		if (rank==99999)
			PrintToChat(client, "[%cKZ%c] %cFailed to save your data correctly! Please contact an admin.",MOSSGREEN,WHITE,DARKRED,RED,DARKRED); 	
		//Sound
		PlayRecordSound(g_sound_type[client]);			
	
		//noclip MsgMsg
		if (IsClientInGame(client) && g_bMapFinished[client] == false && !StrEqual(g_pr_rankname[client],"MASTER") && g_bNoClipS)
			PrintToChat(client, "%t", "NoClipUnlocked",MOSSGREEN,WHITE,YELLOW);
		g_bMapFinished[client] = true;
		CreateTimer(2.0, DBUpdateTimer, client,TIMER_FLAG_NO_MAPCHANGE);
		g_fStartTime[client] = -1.0;		
	}
}

public ReplaceChar(String:sSplitChar[], String:sReplace[], String:sString[64])
{
	StrCat(sString, sizeof(sString), " ");
	new String:sBuffer[16][256];
	ExplodeString(sString, sSplitChar, sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));
	strcopy(sString, sizeof(sString), "");
	for (new i = 0; i < sizeof(sBuffer); i++)
	{
		if (strcmp(sBuffer[i], "") == 0)
			continue;
		if (i != 0)
		{
			new String:sTmpStr[256];
			Format(sTmpStr, sizeof(sTmpStr), "%s%s", sReplace, sBuffer[i]);
			StrCat(sString, sizeof(sString), sTmpStr);
		}
		else
		{
			StrCat(sString, sizeof(sString), sBuffer[i]);
		}
	}
}

public FormatTimeFloat(client, Float:time, type)
{
	decl String:szMilli[16];
	decl String:szSeconds[16];
	decl String:szMinutes[16];
	decl String:szHours[16];
	new imilli;
	new iseconds;
	new iminutes;
	new ihours;
	time = FloatAbs(time);
	imilli = RoundToZero(time*100);
	imilli = imilli%100;
	iseconds = RoundToZero(time);
	iseconds = iseconds%60;	
	iminutes = RoundToZero(time/60);	
	iminutes = iminutes%60;	
	ihours = RoundToZero((time/60)/60);

	if (imilli < 10)
		Format(szMilli, 16, "0%dms", imilli);
	else
		Format(szMilli, 16, "%dms", imilli);
	if (iseconds < 10)
		Format(szSeconds, 16, "0%ds", iseconds);
	else
		Format(szSeconds, 16, "%ds", iseconds);
	if (iminutes < 10)
		Format(szMinutes, 16, "0%dm", iminutes);
	else
		Format(szMinutes, 16, "%dm", iminutes);	
	if (type==1)
	{
		Format(szHours, 16, "%dm", iminutes);	
		if (ihours>0)	
		{
			Format(szHours, 16, "%dh", ihours);
			Format(g_szTime[client], 32, "%s %s %s %s", szHours, szMinutes,szSeconds,szMilli);
		}
		else
			Format(g_szTime[client], 32, "%s %s %s", szMinutes,szSeconds,szMilli);	
	}
	else
	if (type==2)
	{
		imilli = RoundToZero(time*1000);
		imilli = imilli%1000;
		if (imilli < 10)
			Format(szMilli, 16, "00%dms", imilli);
		else
		if (imilli < 100)
			Format(szMilli, 16, "0%dms", imilli);
		else
			Format(szMilli, 16, "%dms", imilli);
		Format(szHours, 16, "%dh", ihours);
		Format(g_szTime[client], 32, "%s %s %s %s",szHours, szMinutes,szSeconds,szMilli);
	}
	else
	if (type==3)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);	
		if (ihours>0)	
		{
			Format(szHours, 16, "%d", ihours);
			Format(g_szTime[client], 32, "%s:%s:%s.%s", szHours, szMinutes,szSeconds,szMilli);
		}
		else
			Format(g_szTime[client], 32, "%s:%s.%s", szMinutes,szSeconds,szMilli);	
	}
	if (type==4)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);	
		if (ihours>0)	
		{
			Format(szHours, 16, "%d", ihours);
			Format(g_szTime[client], 32, "%s:%s:%s", szHours, szMinutes,szSeconds);
		}
		else
			Format(g_szTime[client], 32, "%s:%s", szMinutes,szSeconds);	
	}
}

public SetPlayerRank(client)
{
	if (g_bPointSystem)
	{
		if (g_pr_points[client] < g_pr_rank_Novice)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[0]);
		else					
		if (g_pr_rank_Novice <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Scrub)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[1]);
		else
		if (g_pr_rank_Scrub <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Rookie)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[2]);
		else
		if (g_pr_rank_Rookie <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Skilled)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[3]);
		else
		if (g_pr_rank_Skilled <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Expert)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[4]);
		else
		if (g_pr_rank_Expert <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Pro)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[5]);
		else
		if (g_pr_rank_Pro <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Elite)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[6]);
		else
		if (g_pr_rank_Elite <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Master)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[7]);		
		else
		if (g_pr_points[client] >= g_pr_rank_Master)
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[8]);	
	}	
	else
		Format(g_pr_rankname[client], 32, "");	
		
	// VIP & ADMIN Clantag
	if (g_bVipClantag)			
		if ((GetUserFlagBits(client) & ADMFLAG_RESERVATION) && !(GetUserFlagBits(client) & ADMFLAG_ROOT) && !(GetUserFlagBits(client) & ADMFLAG_GENERIC))
			Format(g_pr_rankname[client], 32, "VIP");	
			
	if (g_bAdminClantag)
		if (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC) 
			Format(g_pr_rankname[client], 32, "ADMIN");			
}

stock Action:PrintSpecMessageAll(client)
{
	decl String:szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, sizeof(szName));
	decl String:szTextToAll[1024];
	GetCmdArgString(szTextToAll, sizeof(szTextToAll));
	StripQuotes(szTextToAll);
	if (StrEqual(szTextToAll,"") || StrEqual(szTextToAll," ") || StrEqual(szTextToAll,"  "))
		return Plugin_Handled;
		
	if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
		CPrintToChatAll("%c%s%c [%c%s%c] *SPEC* %c%s%c: %s", GREEN,g_szCountryCode[client],WHITE,GRAY,g_pr_rankname[client],WHITE,GRAY,szName,WHITE, szTextToAll);
	else
		if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
			CPrintToChatAll("[%c%s%c] *SPEC* %c%s%c: %s", GRAY,g_pr_rankname[client],WHITE,GRAY,szName,WHITE, szTextToAll);
		else
			if (g_bCountry)
				CPrintToChatAll("[%c%s%c] *SPEC* %c%s%c: %s", GREEN,g_szCountryCode[client],WHITE,GRAY,szName,WHITE, szTextToAll);
			else		
				CPrintToChatAll("*SPEC* %c%s%c: %s", GRAY,szName,WHITE, szTextToAll);
	for (new i = 1; i <= MaxClients; i++)
		if (1 <= i <= MaxClients && IsClientInGame(i) && IsValidEntity(i))	
		{
			if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
				PrintToConsole(i, "%s [%s] *SPEC* %s: %s", g_szCountryCode[client],g_pr_rankname[client],szName, szTextToAll);
			else	
				if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
					PrintToConsole(i, "[%s] *SPEC* %s: %s", g_szCountryCode[client],szName, szTextToAll);		
				else
					if (g_bPointSystem)
						PrintToConsole(i, "[%s] *SPEC* %s: %s", g_pr_rankname[client],szName, szTextToAll);	
						else
							PrintToConsole(i, "*SPEC* %s: %s", szName, szTextToAll);
		}
	return Plugin_Handled;
}

//http://pastebin.com/YdUWS93H
public bool:CheatFlag(const String:voice_inputfromfile[], bool:isCommand, bool:remove)
{
	if(remove)
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags &= ~FCVAR_CHEAT);
				return true;
			} 
			else 
				return false;			
		} 
		else 
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags &= ~FCVAR_CHEAT))
				return true;
			else 
				return false;
		}
	}
	else
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags & FCVAR_CHEAT);
				return true;
			}
			else 
				return false;
			
			
		} else
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags & FCVAR_CHEAT))	
				return true;
			else 
				return false;
				
		}
	}
}

public PlayerPanel(client)
{	
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || g_bTopMenuOpen[client] || IsFakeClient(client))
		return;
	
	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;		
	}	
	if (g_bMenuOpen[client] || g_bClimbersMenuOpen[client]) 
		return;	
	if (g_bTimeractivated[client])
	{
		GetcurrentRunTime(client);
		if(!StrEqual(g_szMenuTitleRun[client],""))		
		{
			new Handle:panel = CreatePanel();
			DrawPanelText(panel, g_szMenuTitleRun[client]);
			SendPanelToClient(panel, client, PanelHandler, 1);
			CloseHandle(panel);
		}
	}
	else
	{
		new String:szTmp[255];
		new Handle:panel = CreatePanel();				
		if(!StrEqual(g_szPlayerPanelText[client],""))
			Format(szTmp, 255, "%s\nSpeed: %.1f u/s",g_szPlayerPanelText[client],GetSpeed(client));
		else
			Format(szTmp, 255, "Speed: %.1f u/s",GetSpeed(client));
		
		DrawPanelText(panel, szTmp);
		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);
		
	}
}

public GetRGBColor(bot, String:color[256])
{
	decl String:sPart[4];
	new iFirstSpace = FindCharInString(color, ' ', false) + 1;
	new iLastSpace  = FindCharInString(color, ' ', true) + 1;
	strcopy(sPart, iFirstSpace, color);
	if (bot==1)
		g_ReplayBotTpColor[0] = StringToInt(sPart);
	else
		g_ReplayBotProColor[0] = StringToInt(sPart);
	strcopy(sPart, iLastSpace - iFirstSpace, color[iFirstSpace]);
	if (bot==1)
		g_ReplayBotTpColor[1] = StringToInt(sPart);
	else
		g_ReplayBotProColor[1] = StringToInt(sPart);
	strcopy(sPart, strlen(color) - iLastSpace + 1, color[iLastSpace]);
	if (bot==1)
		g_ReplayBotTpColor[2] = StringToInt(sPart);
	else
		g_ReplayBotProColor[2] = StringToInt(sPart);
	
	if (bot == 0 && g_iBot != -1 && IsValidEntity(g_iBot) && IsClientInGame(g_iBot))
		SetEntityRenderColor(g_iBot, g_ReplayBotProColor[0], g_ReplayBotProColor[1], g_ReplayBotProColor[2], 50);
	if (bot == 1 && g_iBot2 != -1  && IsValidEntity(g_iBot2) && IsClientInGame(g_iBot2))
		SetEntityRenderColor(g_iBot2, g_ReplayBotTpColor[0], g_ReplayBotTpColor[1], g_ReplayBotTpColor[2], 50);
}

public SetSkillGroups()
{
	decl String:sPath[PLATFORM_MAX_PATH];
	decl String:line[128]
	Format(sPath, sizeof(sPath), "configs/kztimer/skill_groups.txt");
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	new Handle:fileHandle=OpenFile(sPath,"r");		
	new yy = 0;
	while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
	{
		TrimString(line);
		if ((StrContains(line, "//") == -1))
		{		
			if (yy < 9) 
				Format(g_szSkillGroups[yy], sizeof(g_szSkillGroups), "%s", line);
			yy++;
		}	
	}
	CloseHandle(fileHandle);
}
	
public SpecList(client)
{
	if (!IsClientInGame(client) || g_bTopMenuOpen[client]  || IsFakeClient(client))
		return;
		
	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;		
	}
	if (g_bTimeractivated[client] && !g_bSpectate[client]) 
		return; 
	if (g_bMenuOpen[client] || g_bClimbersMenuOpen[client]) 
		return;
	if(!StrEqual(g_szPlayerPanelText[client],""))
	{
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, g_szPlayerPanelText[client]);
		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);
	}
}

public PanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
}

public bool:TraceRayDontHitSelf(entity, mask, any:data) 
{
	return (entity != data);
}

stock bool:IntoBool(status)
{
	if(status > 0)
		return true;
	else
		return false;
}

stock BooltoInt(bool:status)
{
	if(status)
		return 1;
	else
		return 0;
}

public PlayQuakeSound_Spec(client, String:buffer[255])
{
	new SpecMode;
	for(new x = 1; x <= MaxClients; x++) 
	{
		if (IsClientInGame(x) && !IsPlayerAlive(x))
		{			
			SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{		
				new Target = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");	
				if (Target == client)
					if (g_bEnableQuakeSounds[x] && g_bColorChat[x])
						ClientCommand(x, buffer); 
			}					
		}		
	}
}

public PerformBan(client, String:szbantype[16])
{
	if (IsValidEntity(client) && IsClientInGame(client))
	{
		decl String:szSteamID[32];
		decl String:szName[64];
		GetClientAuthString(client,szSteamID,32);
		GetClientName(client,szName,64);
		new bantime= RoundToZero(g_fBanDuration*60);
		decl String:banmsg[255];
		Format(banmsg, sizeof(banmsg), "KZ-AntiCheat: You were banned for using %s (%.0fh)",szbantype,g_fBanDuration); 	
		if(bCanUseSourcebans)
			SBBanPlayer(0, client, bantime, banmsg);
		else
			BanClient(client, bantime, BANFLAG_AUTO, banmsg, banmsg);
		db_DeleteCheater(client,szSteamID);
	}
}

public GiveUsp(client)
{
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		return;		
	g_UspDrops[client]++;
	GivePlayerItem(client, "weapon_usp_silencer");
	if (!g_bPreStrafe)
		PrintToChat(client, "%t", "Usp1", MOSSGREEN,WHITE);
	PrintToChat(client, "%t", "Usp2", MOSSGREEN,WHITE);
}
							
//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public PerformStats(client, target)
{
	new String:banstats[256];
	GetClientStats(target, banstats, sizeof(banstats));
	PrintToChat(client, "[%cKZ%c] %s",MOSSGREEN,WHITE,banstats);
	PrintToConsole(client, "[KZ] %s",banstats);
	if (g_bAutoBhop2)
	{
		PrintToChat(client, "[%cKZ%c] AutoBhop enabled",MOSSGREEN,WHITE);
		PrintToConsole(client, "[KZ] AutoBhop enabled");
	}
}

//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public GetClientStats(client, String:string[], length)
{
	new String:map[128];
	new String:szName[64];
	GetClientName(client,szName,64);
	GetCurrentMap(map, 128);
	Format(string, length, "%cPlayer%c: %s - %cLast bhops%c: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i (%cAvg%c: %.1f/%.1f %cPerf%c: %.2f)",	
	LIMEGREEN,
	WHITE,
	szName,
	LIMEGREEN,
	WHITE,
    aaiLastJumps[client][0],
    aaiLastJumps[client][1],
    aaiLastJumps[client][2],
    aaiLastJumps[client][3],
    aaiLastJumps[client][4],
    aaiLastJumps[client][5],
    aaiLastJumps[client][6],
    aaiLastJumps[client][7],
    aaiLastJumps[client][8],
    aaiLastJumps[client][9],
    aaiLastJumps[client][10],
    aaiLastJumps[client][11],
    aaiLastJumps[client][12],
    aaiLastJumps[client][13],
    aaiLastJumps[client][14],
    aaiLastJumps[client][15],
    aaiLastJumps[client][16],
    aaiLastJumps[client][17],
    aaiLastJumps[client][18],
    aaiLastJumps[client][19],
    aaiLastJumps[client][20],
    aaiLastJumps[client][21],
    aaiLastJumps[client][22],
    aaiLastJumps[client][23],
    aaiLastJumps[client][24],
    aaiLastJumps[client][25],
    aaiLastJumps[client][26],
    aaiLastJumps[client][27],
    aaiLastJumps[client][28],
    aaiLastJumps[client][29],
	GRAY,
	WHITE,
    afAvgJumps[client],
    afAvgSpeed[client],
	GRAY,
	WHITE,
    afAvgPerfJumps[client]);
}

public GetClientStatsLog(client, String:string[], length)
{
    new Float:origin[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
    new String:map[128];
    GetCurrentMap(map, 128);
    Format(string, length, "%L Avg bhop ground frames: %f Avg bhop speed: %f Perfection: %f %s %f %f %f Last: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i",
    client,
    afAvgJumps[client],
    afAvgSpeed[client],
    afAvgPerfJumps[client],
    map,
    origin[0],
    origin[1],
    origin[2],
    aaiLastJumps[client][0],
    aaiLastJumps[client][1],
    aaiLastJumps[client][2],
    aaiLastJumps[client][3],
    aaiLastJumps[client][4],
    aaiLastJumps[client][5],
    aaiLastJumps[client][6],
    aaiLastJumps[client][7],
    aaiLastJumps[client][8],
    aaiLastJumps[client][9],
    aaiLastJumps[client][10],
    aaiLastJumps[client][11],
    aaiLastJumps[client][12],
    aaiLastJumps[client][13],
    aaiLastJumps[client][14],
    aaiLastJumps[client][15],
    aaiLastJumps[client][16],
    aaiLastJumps[client][17],
    aaiLastJumps[client][18],
    aaiLastJumps[client][19],
    aaiLastJumps[client][20],
    aaiLastJumps[client][21],
    aaiLastJumps[client][22],
    aaiLastJumps[client][23],
    aaiLastJumps[client][24],
    aaiLastJumps[client][25],
    aaiLastJumps[client][26],
    aaiLastJumps[client][27],
    aaiLastJumps[client][28],
    aaiLastJumps[client][29]);
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public Teleport(client, bhop)
{
	decl i;
	new tele = -1, ent = bhop;

	//search door trigger list
	for (i = 0; i < g_iBhopDoorCount; i++) 
	{
		if(ent == g_iBhopDoorList[i]) 
		{
			tele = g_iBhopDoorTeleList[i];
			break;
		}
	}

	//no destination? search button trigger list
	if(tele == -1) 
	{
		for (i = 0; i < g_iBhopButtonCount; i++) 
		{
			if(ent == g_iBhopButtonList[i]) 
			{
				tele = g_iBhopButtonTeleList[i];
				break;
			}
		}
	}

	//set teleport destination
	if(tele != -1 && IsValidEntity(tele)) 
	{
		SDKCall(g_hSDK_Touch,tele,client);
	}
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public FindBhopBlocks() 
{
	decl Float:startpos[3], Float:endpos[3], Float:mins[3], Float:maxs[3], tele;
	new ent = -1;
	new Float:flbaseVelocity[3];
	while((ent = FindEntityByClassname(ent,"func_door")) != -1) 
	{
		if(g_iDoorOffs_vecPosition1 == -1) 
		{
			g_iDoorOffs_vecPosition1 = FindDataMapOffs(ent,"m_vecPosition1");
			g_iDoorOffs_vecPosition2 = FindDataMapOffs(ent,"m_vecPosition2");
			g_iDoorOffs_flSpeed = FindDataMapOffs(ent,"m_flSpeed");
			g_iDoorOffs_spawnflags = FindDataMapOffs(ent,"m_spawnflags");
			g_iDoorOffs_NoiseMoving = FindDataMapOffs(ent,"m_NoiseMoving");
			g_iDoorOffs_sLockedSound = FindDataMapOffs(ent,"m_ls.sLockedSound");
			g_iDoorOffs_bLocked = FindDataMapOffs(ent,"m_bLocked");		
		}

		GetEntDataVector(ent,g_iDoorOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_iDoorOffs_vecPosition2,endpos);
		
		
		if(startpos[2] > endpos[2]) 
		{
			GetEntDataVector(ent,g_iOffs_vecMins,mins);
			GetEntDataVector(ent,g_iOffs_vecMaxs,maxs);
			GetEntPropVector(ent, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
			new Float:speed = GetEntDataFloat(ent,g_iDoorOffs_flSpeed);
			
			if((flbaseVelocity[0] != 1100.0 && flbaseVelocity[1] != 1100.0 && flbaseVelocity[2] != 1100.0) && (maxs[2] - mins[2]) < 80 && (startpos[2] > endpos[2] || speed > 100))
			{
				startpos[0] += (mins[0] + maxs[0]) * 0.5;
				startpos[1] += (mins[1] + maxs[1]) * 0.5;
				startpos[2] += maxs[2];
				
				if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1 || (speed > 100 && startpos[2] < endpos[2]))
				{
					g_iBhopDoorList[g_iBhopDoorCount] = ent;
					g_iBhopDoorTeleList[g_iBhopDoorCount] = tele;

					if(++g_iBhopDoorCount == sizeof g_iBhopDoorList) 
					{
						break;
					}
				}
			}
		}
	}

	ent = -1;

	while((ent = FindEntityByClassname(ent,"func_button")) != -1) 
	{
		if(g_iButtonOffs_vecPosition1 == -1) 
		{
			g_iButtonOffs_vecPosition1 = FindDataMapOffs(ent,"m_vecPosition1");
			g_iButtonOffs_vecPosition2 = FindDataMapOffs(ent,"m_vecPosition2");
			g_iButtonOffs_flSpeed = FindDataMapOffs(ent,"m_flSpeed");
			g_iButtonOffs_spawnflags = FindDataMapOffs(ent,"m_spawnflags");
		}

		GetEntDataVector(ent,g_iButtonOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_iButtonOffs_vecPosition2,endpos);

		if(startpos[2] > endpos[2] && (GetEntData(ent,g_iButtonOffs_spawnflags,4) & SF_BUTTON_TOUCH_ACTIVATES)) 
		{
			GetEntDataVector(ent,g_iOffs_vecMins,mins);
			GetEntDataVector(ent,g_iOffs_vecMaxs,maxs);

			startpos[0] += (mins[0] + maxs[0]) * 0.5;
			startpos[1] += (mins[1] + maxs[1]) * 0.5;
			startpos[2] += maxs[2];

			if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1) 
			{
				g_iBhopButtonList[g_iBhopButtonCount] = ent;
				g_iBhopButtonTeleList[g_iBhopButtonCount] = tele;

				if(++g_iBhopButtonCount == sizeof g_iBhopButtonList) 
				{
					break;
				}
			}
		}
	}
	AlterBhopBlocks(false);
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public AlterBhopBlocks(bool:bRevertChanges) 
{
	static Float:vecDoorPosition2[sizeof g_iBhopDoorList][3];
	static Float:flDoorSpeed[sizeof g_iBhopDoorList];
	static iDoorSpawnflags[sizeof g_iBhopDoorList];
	static bool:bDoorLocked[sizeof g_iBhopDoorList];
	static Float:vecButtonPosition2[sizeof g_iBhopButtonList][3];
	static Float:flButtonSpeed[sizeof g_iBhopButtonList];
	static iButtonSpawnflags[sizeof g_iBhopButtonList];
	decl ent, i;
	if(bRevertChanges) 
	{
		for(i = 0; i < g_iBhopDoorCount; i++) 
		{
			ent = g_iBhopDoorList[i];
			if(IsValidEntity(ent)) 
			{
				SetEntDataVector(ent,g_iDoorOffs_vecPosition2,vecDoorPosition2[i]);
				SetEntDataFloat(ent,g_iDoorOffs_flSpeed,flDoorSpeed[i]);
				SetEntData(ent,g_iDoorOffs_spawnflags,iDoorSpawnflags[i],4);
				if(!bDoorLocked[i]) 
				{
					AcceptEntityInput(ent,"Unlock");
				}
				if(flDoorSpeed[i] <= 100)
				{
					SDKUnhook(ent,SDKHook_Touch,Entity_Touch);
				}
				else
				{
					SDKUnhook(ent,SDKHook_Touch,Entity_BoostTouch);
				}
			}
		}

		for(i = 0; i < g_iBhopButtonCount; i++) 
		{
			ent = g_iBhopButtonList[i];
			if(IsValidEntity(ent)) 
			{
				SetEntDataVector(ent,g_iButtonOffs_vecPosition2,vecButtonPosition2[i]);
				SetEntDataFloat(ent,g_iButtonOffs_flSpeed,flButtonSpeed[i]);
				SetEntData(ent,g_iButtonOffs_spawnflags,iButtonSpawnflags[i],4);
				SDKUnhook(ent,SDKHook_Touch,Entity_Touch);
			}
		}
	}
	else 
	{	//note: This only gets called directly after finding the blocks, so the entities are valid.
		decl Float:startpos[3];
		for(i = 0; i < g_iBhopDoorCount; i++) 
		{
			ent = g_iBhopDoorList[i];
			GetEntDataVector(ent,g_iDoorOffs_vecPosition2,vecDoorPosition2[i]);
			flDoorSpeed[i] = GetEntDataFloat(ent,g_iDoorOffs_flSpeed);
			iDoorSpawnflags[i] = GetEntData(ent,g_iDoorOffs_spawnflags,4);
			bDoorLocked[i] = GetEntData(ent,g_iDoorOffs_bLocked,1) ? true : false;
			GetEntDataVector(ent,g_iDoorOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_iDoorOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_iDoorOffs_flSpeed,0.0);
			SetEntData(ent,g_iDoorOffs_spawnflags,SF_DOOR_PTOUCH,4);
			AcceptEntityInput(ent,"Lock");
			SetEntData(ent,g_iDoorOffs_sLockedSound,GetEntData(ent,g_iDoorOffs_NoiseMoving,4),4);
			if(flDoorSpeed[i] <= 100)
			{
				SDKHook(ent,SDKHook_Touch,Entity_Touch);
			}
			else
			{
				g_iBhopDoorSp[i] = flDoorSpeed[i];
				SDKHook(ent,SDKHook_Touch,Entity_BoostTouch);
			}
		}

		for(i = 0; i < g_iBhopButtonCount; i++) 
		{
			ent = g_iBhopButtonList[i];
			GetEntDataVector(ent,g_iButtonOffs_vecPosition2,vecButtonPosition2[i]);
			flButtonSpeed[i] = GetEntDataFloat(ent,g_iButtonOffs_flSpeed);
			iButtonSpawnflags[i] = GetEntData(ent,g_iButtonOffs_spawnflags,4);
			GetEntDataVector(ent,g_iButtonOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_iButtonOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_iButtonOffs_flSpeed,0.0);
			SetEntData(ent,g_iButtonOffs_spawnflags,SF_BUTTON_DONTMOVE|SF_BUTTON_TOUCH_ACTIVATES,4);			
			SDKHook(ent,SDKHook_Touch,Entity_Touch);
		}
	}

}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
CustomTraceForTeleports(const Float:startpos[3],Float:endheight,Float:step=1.0) 
{
	decl teleports[512];
	new tpcount, ent = -1;
	while((ent = FindEntityByClassname(ent,"trigger_teleport")) != -1 && tpcount != sizeof teleports)
	{
		teleports[tpcount++] = ent;
	}
	decl Float:mins[3], Float:maxs[3], Float:origin[3], i;
	origin[0] = startpos[0];
	origin[1] = startpos[1];
	origin[2] = startpos[2];
	do 
	{
		for(i = 0; i < tpcount; i++) 
		{
			ent = teleports[i];
			GetAbsBoundingBox(ent,mins,maxs);

			if(mins[0] <= origin[0] <= maxs[0] && mins[1] <= origin[1] <= maxs[1] && mins[2] <= origin[2] <= maxs[2]) 
			{
				return ent;
			}
		}
		origin[2] -= step;
	} 
	while(origin[2] >= endheight);
	return -1;
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public GetAbsBoundingBox(ent,Float:mins[3],Float:maxs[3]) 
{
	decl Float:origin[3];
	GetEntDataVector(ent,g_iOffs_vecOrigin,origin);
	GetEntDataVector(ent,g_iOffs_vecMins,mins);
	GetEntDataVector(ent,g_iOffs_vecMaxs,maxs);
	mins[0] += origin[0];
	mins[1] += origin[1];
	mins[2] += origin[2];
	maxs[0] += origin[0];
	maxs[1] += origin[1];
	maxs[2] += origin[2];
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
stock ResetMultiBhop()
{
	if (!g_bMultiplayerBhop)
		return;
	g_iBhopDoorCount = 0;
	g_iBhopButtonCount = 0;
	FindBhopBlocks();
	AlterBhopBlocks(true);
	g_iBhopDoorCount = 0;
	g_iBhopButtonCount = 0;
	FindBhopBlocks();
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
GetPos(client,arg) 
{
	decl Float:origin[3],Float:angles[3]	
	GetClientEyePosition(client,origin)
	GetClientEyeAngles(client,angles)	
	new Handle:trace = TR_TraceRayFilterEx(origin,angles,MASK_SHOT,RayType_Infinite,TraceFilterPlayers,client)
	if(!TR_DidHit(trace)) 
	{
		CloseHandle(trace);
		PrintToChat(client, "%t", "Measure3",MOSSGREEN,WHITE);
		return;
	}
	TR_GetEndPosition(origin,trace);
	CloseHandle(trace);
	g_vMeasurePos[client][arg][0] = origin[0];
	g_vMeasurePos[client][arg][1] = origin[1];
	g_vMeasurePos[client][arg][2] = origin[2];
	PrintToChat(client, "%t", "Measure4",MOSSGREEN,WHITE,arg+1,origin[0],origin[1],origin[2]);	
	if(arg == 0) 
	{
		if(g_hP2PRed[client] != INVALID_HANDLE) 
		{
			CloseHandle(g_hP2PRed[client]);
			g_hP2PRed[client] = INVALID_HANDLE;
		}
		g_bMeasurePosSet[client][0] = true;
		g_hP2PRed[client] = CreateTimer(1.0,Timer_P2PRed,client,TIMER_REPEAT);
		P2PXBeam(client,0);
	}
	else 
	{
		if(g_hP2PGreen[client] != INVALID_HANDLE) 
		{
			CloseHandle(g_hP2PGreen[client]);
			g_hP2PGreen[client] = INVALID_HANDLE;
		}
		g_bMeasurePosSet[client][1] = true;
		P2PXBeam(client,1);
		g_hP2PGreen[client] = CreateTimer(1.0,Timer_P2PGreen,client,TIMER_REPEAT);
	}
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PRed(Handle:timer,any:client) 
{
	P2PXBeam(client,0);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PGreen(Handle:timer,any:client) 
{
	P2PXBeam(client,1);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
P2PXBeam(client,arg) 
{
	decl Float:Origin0[3],Float:Origin1[3],Float:Origin2[3],Float:Origin3[3]	
	Origin0[0] = (g_vMeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (g_vMeasurePos[client][arg][1] + 8.0);
	Origin0[2] = g_vMeasurePos[client][arg][2];	
	Origin1[0] = (g_vMeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (g_vMeasurePos[client][arg][1] - 8.0);
	Origin1[2] = g_vMeasurePos[client][arg][2];	
	Origin2[0] = (g_vMeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (g_vMeasurePos[client][arg][1] - 8.0);
	Origin2[2] = g_vMeasurePos[client][arg][2];	
	Origin3[0] = (g_vMeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (g_vMeasurePos[client][arg][1] + 8.0);
	Origin3[2] = g_vMeasurePos[client][arg][2];	
	if(arg == 0) 
	{
		Beam(client,Origin0,Origin1,0.97,2.0,255,0,0);
		Beam(client,Origin2,Origin3,0.97,2.0,255,0,0);
	}
	else 
	{
		Beam(client,Origin0,Origin1,0.97,2.0,0,255,0);
		Beam(client,Origin2,Origin3,0.97,2.0,0,255,0);
	}
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
Beam(client,Float:vecStart[3],Float:vecEnd[3],Float:life,Float:width,r,g,b) 
{
	TE_Start("BeamPoints")
	TE_WriteNum("m_nModelIndex",g_iGlowSprite);
	TE_WriteNum("m_nHaloIndex",0);
	TE_WriteNum("m_nStartFrame",0);
	TE_WriteNum("m_nFrameRate",0);
	TE_WriteFloat("m_fLife",life);
	TE_WriteFloat("m_fWidth",width);
	TE_WriteFloat("m_fEndWidth",width);
	TE_WriteNum("m_nFadeLength",0);
	TE_WriteFloat("m_fAmplitude",0.0);
	TE_WriteNum("m_nSpeed",0);
	TE_WriteNum("r",r);
	TE_WriteNum("g",g);
	TE_WriteNum("b",b);
	TE_WriteNum("a",255);
	TE_WriteNum("m_nFlags",0);
	TE_WriteVector("m_vecStartPoint",vecStart);
	TE_WriteVector("m_vecEndPoint",vecEnd);
	TE_SendToClient(client);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
ResetPos(client) 
{
	if(g_hP2PRed[client] != INVALID_HANDLE) 
	{
		CloseHandle(g_hP2PRed[client]);
		g_hP2PRed[client] = INVALID_HANDLE;
	}
	if(g_hP2PGreen[client] != INVALID_HANDLE) 
	{
		CloseHandle(g_hP2PGreen[client]);
		g_hP2PGreen[client] = INVALID_HANDLE;
	}
	g_bMeasurePosSet[client][0] = false;
	g_bMeasurePosSet[client][1] = false;

	g_vMeasurePos[client][0][0] = 0.0; //This is stupid.
	g_vMeasurePos[client][0][1] = 0.0;
	g_vMeasurePos[client][0][2] = 0.0;
	g_vMeasurePos[client][1][0] = 0.0;
	g_vMeasurePos[client][1][1] = 0.0;
	g_vMeasurePos[client][1][2] = 0.0;
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public bool:TraceFilterPlayers(entity,contentsMask) 
{
	return (entity > MaxClients) ? true : false;
} //Thanks petsku

//jsfunction.inc
stock GetGroundOrigin(client, Float:pos[3])
{
	new Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}

//jsfunction.inc
stock TraceClientGroundOrigin(client, Float:result[3], Float:offset)
{
	new Float:temp[2][3];
	GetClientEyePosition(client, temp[0]);
	temp[1] = temp[0];
	temp[1][2] -= offset;
	new Float:mins[]={-16.0, -16.0, 0.0};
	new Float:maxs[]={16.0, 16.0, 60.0};
	new Handle:trace = TR_TraceHullFilterEx(temp[0], temp[1], mins, maxs, MASK_SHOT, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

//jsfunction.inc
public bool:TraceEntityFilterPlayer(entity, contentsMask) 
{
    return entity > MaxClients;
}


//zipcore strafe hack protection
stock ComputeStrafes(client)
{
	new nPerfect, nVeryGood, nGood, nPre, nStrafeCount;
	new Float:fPerfect, Float:fVeryGood, Float:fGood, Float:fPre;
	
	for(new i = 1; i < g_PlayerStates[client][nStrafes]; i++)
	{
		/* Ignore boosted strafes */
		if(g_PlayerStates[client][bBoosted][i])
			continue;
		
		/* Get tick delay */
		new delay = RoundToNearest(g_PlayerStates[client][fStrafeDelay][i]*100);
		
		/* Ignore bad strafes */
		if(10 *-1 > delay > 10)
		{
			continue;
		}
		
		/* Count analyzed strafes */
		nStrafeCount++;
		
		/* Count pre pressed strafes */
		if(delay < 0)
			nPre++;
		
		/* Count zero delay strafes */
		if(delay == 0)
		{
			nPerfect++;
			continue;
		}
		
		/* Count 1 tick strafes */
		if(delay == 1 || delay == -1)
		{
			nVeryGood++;
			continue;
		}
		
		/* Count 2 tick strafes */
		if(delay == 2 || delay == -2)
		{
			nGood++;
			continue;
		}
	}
	
	fPerfect = (float(nPerfect)/float(nStrafeCount))*100;
	fVeryGood = (float(nVeryGood)/float(nStrafeCount))*100;
	fGood = (float(nGood)/float(nStrafeCount))*100;
	fPre = (float(nPre)/float(nStrafeCount))*100;	
	
	/* Ingore if there isn't enough data left */
	if(nStrafeCount > 100)
	{	
		new String:auth[64];
		GetClientAuthString(client, auth, sizeof(auth));
		
		if(fPerfect >= 25.0 || fVeryGood > 50.0)
		{
			/* Ban player */
			new String:reason[256];	
			Format(reason, sizeof(reason), "%L 0-Tick: %d/100, 1-Tick: %d/100, 2-Tick: %d/100, Pre: %d/100 (%d strafes analyzed)", RoundToFloor(fPerfect), RoundToFloor(fVeryGood), RoundToFloor(fGood), RoundToFloor(fPre), nStrafeCount);
			
			if (g_bAntiCheat)
			{
				if (g_BGlobalDBConnected && g_bGlobalDB)
				{
					decl String:szName[64];
					GetClientName(client,szName,64);
					db_InsertBan(g_szSteamID[client], szName);
				}
				decl String:sPath[512];
				BuildPath(Path_SM, sPath, sizeof(sPath), "logs/kztimer_anticheat.log");
				if (g_bAutoBan)
					LogToFile(sPath, "%s reason: strafe hack (autoban)", reason);	
				else
					LogToFile(sPath, "%s reason: strafe hack", reason);	
				bFlagged[client] = true;
				if (g_bAutoBan)	
					PerformBan(client,"a strafe hack");
			}
		}	
	}
}

//zipcore strafe hack protection
stock ResetStrafes(client)
{
	g_PlayerStates[client][nStrafeDir] = 0;
	g_PlayerStates[client][nStrafes] = 0;
	g_PlayerStates[client][nStrafesBoosted] = 0;
	
	new Float:time = GetGameTime();
	
	for(new i = 0; i < MAX_STRAFES2; i++)
	{
		g_PlayerStates[client][bBoosted][i] = false;
		
		g_PlayerStates[client][fStrafeTimeLastSync][i] = time;
		g_PlayerStates[client][fStrafeTimeAngleTurn][i] = time;
		g_PlayerStates[client][bStrafeAngleGain][i] = false;
		g_PlayerStates[client][fStrafeDelay][i] = 0.0;
	}
}

Float:GetVSpeed(Float:v[3])
{
	new Float:vVelocity[3];
	vVelocity = v;
	vVelocity[2] = 0.0;
	
	return GetVectorLength(vVelocity);
}