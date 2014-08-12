// misc.sp
public Action:CallAdmin_OnDrawOwnReason(client)
{
	g_bClientOwnReason[client] = true;
	return Plugin_Continue;
}

stock bool:IsValidClient(client)
{
    if(client >= 1 && client <= MaxClients && IsValidEntity(client) && IsClientConnected(client) && IsClientInGame(client))
        return true;  
    return false;
}  

public SetServerTags()
{
	new Handle:CvarHandle;	
	CvarHandle = FindConVar("sv_tags");
	decl String:szServerTags[1024];
	GetConVarString(CvarHandle, szServerTags, 1024);
	if (StrContains(szServerTags,"KZTimer 1.",true) == -1 && StrContains(szServerTags,"Tickrate",true) == -1)
	{
		if (g_bProMode)
			Format(szServerTags, 1024, "%s, KZTimer %s, ProMode",szServerTags,VERSION);
		else
			Format(szServerTags, 1024, "%s, KZTimer %s, Tickrate %i",szServerTags,VERSION,g_Server_Tickrate);
		SetConVarString(CvarHandle, szServerTags);
	}
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
	new Float:fltickrate = 1.0 / GetTickInterval( );
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	PrintToConsole(client, "This server is running KZTimer v%s - Author: 1NuTWunDeR <STEAM_0:1:73507922> - Server tickrate: %i", VERSION, RoundToNearest(fltickrate));
	PrintToConsole(client, "KZTimer steam group: http://steamcommunity.com/groups/KZTIMER");
	if (timeleft > 0)
		PrintToConsole(client, "Timeleft on %s: %s",g_szMapName, finalOutput);
	PrintToConsole(client, " ");
	PrintToConsole(client, "Client commands:");
	PrintToConsole(client, "!help, !menu, !options, !checkpoint, !gocheck, !prev, !next, !undo, !profile, !compare,");
	PrintToConsole(client, "!bhopcheck, !maptop, top, !start, !stop, !pause, !usp, !challenge, !surrender, !goto, !spec,");
	PrintToConsole(client, "!showsettings, !latest, !measure, !ljblock, !ranks, !flashlight");
	PrintToConsole(client, "(options menu contains: !adv, !info, !colorchat, !cpmessage, !sound, !menusound");
	PrintToConsole(client, "!hide, !hidespecs, !showtime, !disablegoto, !sync, !bhop)");
	PrintToConsole(client, " ");
	PrintToConsole(client, "Live scoreboard:");
	PrintToConsole(client, "Kills: Time in seconds");
	PrintToConsole(client, "Assists: Checkpoints");
	PrintToConsole(client, "Deaths: Teleports");
	PrintToConsole(client, "MVP Stars: Number of finished map runs on the current map");
	PrintToConsole(client, " ");
	PrintToConsole(client, "How does the ranking system work?");		
	PrintToConsole(client, "The System depends mostly on your map and jumpstats ranks.");	
	PrintToConsole(client, "Once you finished a map, you can get only points by improving your rank!");	
	PrintToConsole(client, "Furthermore, you can lose points when others have beaten your map ranks.");	
	PrintToConsole(client, " ");
	PrintToConsole(client, "Calculation:");
	PrintToConsole(client, "TP Time: Rank percentage * 100 (extra bonus: Top 20 rankings, max. 400p for #1)");	
	PrintToConsole(client, "PRO Time (without teleports): Rank percentage * 200 (extra bonus: Top 20 rankings, max. 600p for #1)");
	PrintToConsole(client, "Extra points for time improvements: %ip", g_ExtraPoints);	
	PrintToConsole(client, "JumpStats: Rank percentage (Top 20) * 500");	
	PrintToConsole(client, " ");
	PrintToConsole(client, "Skill groups:");
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[1],g_pr_rank_Percentage[1],g_szSkillGroups[2], g_pr_rank_Percentage[2],g_szSkillGroups[3], g_pr_rank_Percentage[3],g_szSkillGroups[4], g_pr_rank_Percentage[4]);
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[5], g_pr_rank_Percentage[5], g_szSkillGroups[6],g_pr_rank_Percentage[6], g_szSkillGroups[7], g_pr_rank_Percentage[7], g_szSkillGroups[8], g_pr_rank_Percentage[8]);
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");		
	PrintToConsole(client, "KZTimer Global Edition available at http://steamcommunity.com/groups/KZTIMER");
	PrintToConsole(client, "-> This version provides sharing of map records across KZTimer servers!");
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
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
	if(!g_bRadioCommands && IsValidClient(client))
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

public GetServerInfo()
{
	new pieces[4];
	decl String:code2[3];
	decl String:NetIP[256];
	new longip = GetConVarInt(FindConVar("hostip"));
	new port = GetConVarInt( FindConVar( "hostport" ));
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;
	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
	GeoipCountry(NetIP, g_szServerCountry, 100);

	if(!strcmp(g_szServerCountry, NULL_STRING))
		Format( g_szServerCountry, 100, "Unknown", g_szServerCountry );
	else				
		if( StrContains( g_szServerCountry, "United", false ) != -1 || 
			StrContains( g_szServerCountry, "Republic", false ) != -1 || 
			StrContains( g_szServerCountry, "Federation", false ) != -1 || 
			StrContains( g_szServerCountry, "Island", false ) != -1 || 
			StrContains( g_szServerCountry, "Netherlands", false ) != -1 || 
			StrContains( g_szServerCountry, "Isle", false ) != -1 || 
			StrContains( g_szServerCountry, "Bahamas", false ) != -1 || 
			StrContains( g_szServerCountry, "Maldives", false ) != -1 || 
			StrContains( g_szServerCountry, "Philippines", false ) != -1 || 
			StrContains( g_szServerCountry, "Vatican", false ) != -1 )
		{
			Format( g_szServerCountry, 100, "The %s", g_szServerCountry );
		}	
	if(GeoipCode2(NetIP, code2))
		Format(g_szServerCountryCode, 16, "%s",code2);
	else
		Format(g_szServerCountryCode, 16, "??",code2);
	Format(g_szServerIp, sizeof(g_szServerIp), "%s:%i",NetIP,port);
	GetConVarString(FindConVar("hostname"),g_szServerName,sizeof(g_szServerName));
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

public PlayButtonSound(client)
{
	decl String:buffer[255];
	Format(buffer, sizeof(buffer), "play %s", RELATIVE_BUTTON_PATH); 
	new Float:diff = GetEngineTime() - g_fLastTimeButtonSound[client];
	if (diff > 0.1)
	{
		ClientCommand(client, buffer); 	
		//spec stop sound
		for(new i = 1; i <= MaxClients; i++) 
		{		
			if (IsValidClient(i) && !IsPlayerAlive(i))
			{			
				new SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
				if (SpecMode == 4 || SpecMode == 5)
				{		
					new Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");	
					if (Target == client)
					{
						decl String:szsound[255];
						Format(szsound, sizeof(szsound), "play %s", RELATIVE_BUTTON_PATH); 
						ClientCommand(i,szsound);
					}
				}					
			}
		}
	}
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
	if (IsValidClient(i) && !IsFakeClient(client))	
	{
		Client_Stop(i,0);
	}
	
	KzAdminMenu(client);
}

public CreateButton(client,String:targetname[]) 
{
	if (IsValidClient(client) && IsPlayerAlive(client))
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
	g_fCurrentRunTime[client] = GetEngineTime() - g_fStartTime[client] - g_fPauseTime[client];					
	if (g_bPause[client])
		Format(g_szMenuTitleRun[client], 255, "%s\nTimer on Hold", g_szPlayerPanelText[client]);
	else
	{
		FormatTimeFloat(client, g_fCurrentRunTime[client], 1);
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
	if (g_js_LeetJump_Count[client] == 3 || g_js_LeetJump_Count[client] == 5)
	{
		for (new i = 1; i <= MaxClients; i++)
		{ 
			if(IsValidClient(i) && !IsFakeClient(i) && i != client && g_bColorChat[i] && g_bEnableQuakeSounds[i])
			{	
					if (g_js_LeetJump_Count[client]==3)
					{
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH); 	
						ClientCommand(i, buffer); 
					}
					else
						if (g_js_LeetJump_Count[client]==5)
						{
							Format(buffer, sizeof(buffer), "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH); 		
							ClientCommand(i, buffer); 
						}
			}
		}
	}
	
	//client sound
	if 	(IsValidClient(client) && !IsFakeClient(client) && g_bEnableQuakeSounds[client])
	{
		if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
		{
			Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 
			ClientCommand(client, buffer); 
		}
			else
			if (g_js_LeetJump_Count[client]==3)
			{
				Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH); 	
				ClientCommand(client, buffer); 
			}
			else
			if (g_js_LeetJump_Count[client]==5)
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
		if (IsValidClient(i))
			SetEntProp(i, Prop_Send, "m_iAccount", 0);
	}
}

public PlayRecordSound(iRecordtype)
{
	decl String:buffer[255];
	if (iRecordtype==1)
	    for(new i = 1; i <= GetMaxClients(); i++) 
		{ 
			if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true) 
			{ 
				Format(buffer, sizeof(buffer), "play %s", PRO_RELATIVE_SOUND_PATH); 
				ClientCommand(i, buffer); 
			}
		} 
	else
		if (iRecordtype==2 || iRecordtype == 3)
			for(new i = 1; i <= GetMaxClients(); i++) 
			{ 
				if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true) 
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
	AddFileToDownloadsTable(g_sReplayBotArmModel2);
	AddFileToDownloadsTable(g_sReplayBotPlayerModel2);
	g_GlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt",true);
	PrecacheModel("materials/models/props/startkztimer.vmt",true);
	PrecacheModel("materials/models/props/stopkztimer.vmt",true);
	PrecacheModel("models/props/switch001.mdl",true);	
	g_Beam[0] = PrecacheModel("materials/sprites/laser.vmt");
	g_Beam[1] = PrecacheModel("materials/sprites/halo01.vmt");
	PrecacheModel(g_sReplayBotArmModel,true);
	PrecacheModel(g_sReplayBotPlayerModel,true);
	PrecacheModel(g_sReplayBotArmModel2,true);
	PrecacheModel(g_sReplayBotPlayerModel2,true);
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
	if (IsValidClient(client))
	{
		
		decl String:szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);
		new count;
		new rank;
		if (type==1)
		{
			count = g_MapTimesCountPro;
			rank = g_MapRankPro[client];
			FormatTimeFloat(client, g_fRecordTimePro, 3);	
		}
		else
		if (type==0)
		{
			count = g_MapTimesCountTp;
			rank = g_MapRankTp[client];		
			FormatTimeFloat(client, g_fRecordTime, 3);	
		}
		for(new i = 1; i <= GetMaxClients(); i++) 
			if(IsValidClient(i) && !IsFakeClient(i)) 
			{
				if (g_Time_Type[client] == 0)
				{
					PrintToChat(i, "%t", "MapFinished0",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,  LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE); 
					PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_Tp_Final[client],rank,count,g_szTime[client]); 
				}
				else
				if (g_Time_Type[client] == 1)
				{
					PrintToChat(i, "%t", "MapFinished1",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,PURPLE,GRAY,LIMEGREEN, g_szNewTime[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE); 
					PrintToConsole(i, "%s finished with a PRO TIME of (%s). [rank #%i/%i | record %s]",szName,g_szNewTime[client],rank,count,g_szTime[client]);  
				}			
				else
					if (g_Time_Type[client] == 2)
					{
						PrintToChat(i, "%t", "MapFinished2",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  				
						PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_Tp_Final[client],g_szTimeDifference[client],rank,count,g_szTime[client]);  
					}
					else
						if (g_Time_Type[client] == 3)
						{
							PrintToChat(i, "%t", "MapFinished3",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,PURPLE,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  				
							PrintToConsole(i, "%s finished with a PRO TIME of (%s). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 	
						}
						else
							if (g_Time_Type[client] == 4)
							{
								PrintToChat(i, "%t", "MapFinished4",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  	
								PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_Tp_Final[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 
							}
							else
								if (g_Time_Type[client] == 5)
								{
									PrintToChat(i, "%t", "MapFinished5",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,PURPLE,GRAY,LIMEGREEN, g_szNewTime[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,g_szTime[client],WHITE);  	
									PrintToConsole(i, "%s finished with a PRO TIME of (%s). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szNewTime[client],g_szTimeDifference[client],rank,count,g_szTime[client]); 
								}
				//new record msg
				if (g_FinishingType[client] == 2)				
				{
					PrintToChat(i, "%t", "NewProRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,PURPLE);  
					PrintToConsole(i, "[KZ] %s scored a new PRO RECORD",szName); 	
				}		
				else
					if (g_FinishingType[client] == 1)				
					{
						PrintToChat(i, "%t", "NewTpRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW); 	
						PrintToConsole(i, "[KZ] %s scored a new TP RECORD",szName); 	
					}					
			}
		
		if (rank==99999 && IsValidClient(client))
			PrintToChat(client, "[%cKZ%c] %cFailed to save your data correctly! Please contact an admin.",MOSSGREEN,WHITE,DARKRED,RED,DARKRED); 	
		//Sound
		PlayRecordSound(g_Sound_Type[client]);			
	
		//noclip MsgMsg
		if (IsValidClient(client) && g_bMapFinished[client] == false && !StrEqual(g_pr_rankname[client],g_szSkillGroups[8]) && !(GetUserFlagBits(client) & ADMFLAG_RESERVATION) && !(GetUserFlagBits(client) & ADMFLAG_ROOT) && !(GetUserFlagBits(client) & ADMFLAG_GENERIC) && g_bNoClipS)
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
		if (g_pr_points[client] < g_pr_rank_Percentage[1])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[0]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",WHITE,g_szSkillGroups[0],WHITE);
		}
		else
		if (g_pr_rank_Percentage[1] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[2])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[1]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",WHITE,g_szSkillGroups[1],WHITE);
		}
		else
		if (g_pr_rank_Percentage[2] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[3])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[2]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",GRAY,g_szSkillGroups[2],WHITE);		
		}
		else
		if (g_pr_rank_Percentage[3] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[4])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[3]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",LIGHTBLUE,g_szSkillGroups[3],WHITE);		
		}
		else
		if (g_pr_rank_Percentage[4] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[5])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[4]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",BLUE,g_szSkillGroups[4],WHITE);
		}
		else
		if (g_pr_rank_Percentage[5] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[6])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[5]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",DARKBLUE,g_szSkillGroups[5],WHITE);
		}
		else
		if (g_pr_rank_Percentage[6] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[7])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[6]);
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",PINK,g_szSkillGroups[6],WHITE);
		}
		else
		if (g_pr_rank_Percentage[7] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[8])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[7]);	
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",LIGHTRED,g_szSkillGroups[7],WHITE);
		}
		else
		if (g_pr_points[client] >= g_pr_rank_Percentage[8])
		{
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[8]);	
			Format(g_pr_chat_coloredrank[client], 32, "%c%s%c",DARKRED,g_szSkillGroups[8],WHITE);
		}
	}	
	else
		Format(g_pr_rankname[client], 32, "");	
	
	// MAPPER Clantag
	decl String:sPath[PLATFORM_MAX_PATH];
	decl String:line[128]
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", MAPPERS_PATH);
	if (FileExists(sPath))
	{
		decl String:szSteamId[32];
		GetClientAuthString(client, szSteamId, 32);	
		new Handle:fileHandle=OpenFile(sPath,"r");		
		while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
		{
			if ((StrContains(line, "//") == -1))
			{	
				TrimString(line);
				if (StrEqual(line,szSteamId))
				{
					Format(g_pr_rankname[client], 32, "MAPPER");	
					Format(g_pr_chat_coloredrank[client], 32, "%cMAPPER%c",LIMEGREEN,WHITE);
				}
			}	
		}
		CloseHandle(fileHandle);
	}
	
	// VIP & ADMIN Clantag
	if (g_bVipClantag)			
		if ((GetUserFlagBits(client) & ADMFLAG_RESERVATION) && !(GetUserFlagBits(client) & ADMFLAG_ROOT) && !(GetUserFlagBits(client) & ADMFLAG_GENERIC))
		{
			Format(g_pr_rankname[client], 32, "VIP");	
			Format(g_pr_chat_coloredrank[client], 32, "%cVIP%c",LIMEGREEN,WHITE);
		}
		
	if (g_bAdminClantag)
		if (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC) 
		{
			Format(g_pr_rankname[client], 32, "ADMIN");	
			Format(g_pr_chat_coloredrank[client], 32, "%cADMIN%c",LIMEGREEN,WHITE);
		}
}

public SpectatorCount(client)
{
	decl String:szBuffer[64];
	new specs = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && g_bSpectate[i])
			specs++;
	}
	Format(szBuffer, sizeof(szBuffer), "[INFO] Specs: %i", specs);		
	CS_SetClientName(client, szBuffer);		
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

	decl String:szChatRank[64];
	if (g_bColoredChatRanks)
		Format(szChatRank, 64, "%s",g_pr_chat_coloredrank[client]);
	else
		Format(szChatRank, 64, "%s",g_pr_rankname[client]);
				
	if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))		
		CPrintToChatAll("{green}%s{default} [{grey}%s{default}] *SPEC* {grey}%s{default}: %s",g_szCountryCode[client], szChatRank, szName,szTextToAll);
	else
		if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
			CPrintToChatAll("[{grey}%s{default}] *SPEC* {grey}%s{default}: %s", szChatRank,szName,szTextToAll);
		else
			if (g_bCountry)
				CPrintToChatAll("[{green}%s{default}] *SPEC* {grey}%s{default}: %s", g_szCountryCode[client],szName, szTextToAll);
			else		
				CPrintToChatAll("*SPEC* {grey}%s{default}: %s", szName, szTextToAll);
	for (new i = 1; i <= MaxClients; i++)
		if (IsValidClient(i))	
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
	if (!IsValidClient(client) || g_bTopMenuOpen[client] || IsFakeClient(client))
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
	
	if (bot == 0 && g_ProBot != -1 && IsValidClient(g_ProBot))
		SetEntityRenderColor(g_ProBot, g_ReplayBotProColor[0], g_ReplayBotProColor[1], g_ReplayBotProColor[2], 50);
	if (bot == 1 && g_TpBot != -1  && IsValidClient(g_TpBot))
		SetEntityRenderColor(g_TpBot, g_ReplayBotTpColor[0], g_ReplayBotTpColor[1], g_ReplayBotTpColor[2], 50);
}

public SetSkillGroups()
{
	//Map Points	
	new mapcount;
	if (g_pr_MapCount < 1)
		mapcount = 1;
	else
		mapcount = g_pr_MapCount;	
	g_pr_PointUnit = 1; 
	new Float: MaxPoints = float(mapcount) * 1300.0 + 3000.0; //1300 = map max, 3000 = jumpstats max
	new g_RankCount = 0;
	
	decl String:sPath[PLATFORM_MAX_PATH], String:sBuffer[32];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/kztimer/skillgroups.cfg");	
	
	if (FileExists(sPath))
	{
		new Handle:hKeyValues = CreateKeyValues("KZTimer.SkillGroups");
		if(FileToKeyValues(hKeyValues, sPath) && KvGotoFirstSubKey(hKeyValues))
		{
			do
			{
				if (g_RankCount <= 8)
				{
					KvGetString(hKeyValues, "name", g_szSkillGroups[g_RankCount], 32);
					KvGetString(hKeyValues, "percentage", sBuffer,32);
					if (g_RankCount != 0)
						g_pr_rank_Percentage[g_RankCount] = RoundToCeil(MaxPoints * StringToFloat(sBuffer));  
				}
				g_RankCount++;
			}
			while (KvGotoNextKey(hKeyValues));
		}
		if (hKeyValues != INVALID_HANDLE)
			CloseHandle(hKeyValues);
	}
	else
		SetFailState("<KZTIMER> addons/sourcemod/configs/kztimer/skillgroups.cfg not found.");
}
	
public SpecList(client)
{
	if (!IsValidClient(client) || g_bTopMenuOpen[client]  || IsFakeClient(client))
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
		if (IsValidClient(x) && !IsPlayerAlive(x))
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
	if (IsValidClient(client))
	{
		decl String:szSteamID[32];
		decl String:szName[64];
		GetClientAuthString(client,szSteamID,32);
		GetClientName(client,szName,64);
		new bantime= RoundToZero(g_fBanDuration*60);
		decl String:banmsg[255];
		Format(banmsg, sizeof(banmsg), "KZ-AntiCheat: You were banned for using %s (%.0fh)",szbantype,g_fBanDuration); 	
		if(g_bCanUseSourcebans)
			SBBanPlayer(0, client, bantime, banmsg);
		else
			BanClient(client, bantime, BANFLAG_AUTO, banmsg, banmsg);
		db_DeleteCheater(client,szSteamID);
	}
}

public GiveUsp(client)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return;		
	g_UspDrops[client]++;
	GivePlayerItem(client, "weapon_usp_silencer");
	if (!g_bPreStrafe && !g_bProMode)
		PrintToChat(client, "%t", "Usp1", MOSSGREEN,WHITE);
	PrintToChat(client, "%t", "Usp2", MOSSGREEN,WHITE);
}
	
Float:GetVSpeed(Float:favVEL[3])
{
	new Float:vVelocity[3];
	vVelocity = favVEL;
	vVelocity[2] = 0.0;
	
	return GetVectorLength(vVelocity);
}

public bool:WallCheck(client)
{
	decl Float:pos[3];
	decl Float:endpos[3];
	decl Float:angs[3];
	decl Float:vecs[3];                    
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, angs);
	GetAngleVectors(angs, vecs, NULL_VECTOR, NULL_VECTOR);
	angs[1] = -180.0;
	while (angs[1] != 180.0)
	{
		new Handle:trace = TR_TraceRayFilterEx(pos, angs, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

		if(TR_DidHit(trace))
		{				
				TR_GetEndPosition(endpos, trace);
				new Float: fdist = GetVectorDistance(endpos, pos, false);			
				if (fdist <= 25.0)
				{			
					CloseHandle(trace); 
					return true;
				}
		}
		CloseHandle(trace); 
		angs[1]+=15.0;
	}
	return false;
}

//OnPlayerRunCmd Stuff

public Prestrafe(client, mouse_ang, &buttons)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || (!g_bPreStrafe && !g_bProMode) || (g_bSlowDownCheck[client]) | !(GetEntityFlags(client) & FL_ONGROUND))
		return;
	
	//var
	new g_mouseAbs, MaxMouseAbs, MaxFrameCount;	
	decl String:classname[64];
	GetClientWeapon(client, classname, 64);
	new Float: IncSpeed, Float: DecSpeed;
	new Float: speed = GetSpeed(client);
	new bool: bForward;
	
	//direction
	if (GetClientMovingDirection(client) > 0.0)
		bForward=true;
	else
		bForward=false;
		
	
	//no mouse movement?
	if (mouse_ang == 0)
	{
		new Float: diff = GetEngineTime() - g_fVelocityModifierLastChange[client]
		if (diff > 0.2)
		{
			if(StrEqual(classname, "weapon_hkp2000"))
				g_PrestrafeVelocity[client] = 1.042;
			else
				g_PrestrafeVelocity[client] = 1.0;
			g_fVelocityModifierLastChange[client] = GetEngineTime();
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", g_PrestrafeVelocity[client]);
		}
		g_LastMouseDir[client] = mouse_ang;
		return;
	}

	if ((GetEntityFlags(client) & FL_ONGROUND) && ((buttons & IN_MOVERIGHT) || (buttons & IN_MOVELEFT)) && speed > 249.0)
	{       
		//mouse ang diff
		g_mouseAbs = mouse_ang - g_LastMouseDir[client];
		if (g_mouseAbs < 0)
			g_mouseAbs = g_mouseAbs*-1;
			
		//tickrate depending values
		if (g_Server_Tickrate == 64)
		{
			MaxMouseAbs =  30;
			MaxFrameCount = 45;
			IncSpeed = 0.00165;
			if ((g_PrestrafeVelocity[client] > 1.08 && StrEqual(classname, "weapon_hkp2000")) || (g_PrestrafeVelocity[client] > 1.04 && !StrEqual(classname, "weapon_hkp2000")))
				IncSpeed = 0.001;
			DecSpeed = 0.006;
		}
		
		if (g_Server_Tickrate == 102)
		{
			MaxMouseAbs =  35;
			MaxFrameCount = 60;	
			IncSpeed = 0.00149;
			if ((g_PrestrafeVelocity[client] > 1.08 && StrEqual(classname, "weapon_hkp2000")) || (g_PrestrafeVelocity[client] > 1.04 && !StrEqual(classname, "weapon_hkp2000")))
				IncSpeed = 0.001;			
			DecSpeed = 0.006;
			
		}
		
		if (g_Server_Tickrate == 128)
		{
			MaxMouseAbs =  35;
			MaxFrameCount = 80;	
			IncSpeed = 0.00145;
			if ((g_PrestrafeVelocity[client] > 1.08 && StrEqual(classname, "weapon_hkp2000")) || (g_PrestrafeVelocity[client] > 1.04 && !StrEqual(classname, "weapon_hkp2000")))
				IncSpeed = 0.001;			
			DecSpeed = 0.006;
		}
		

		if (((buttons & IN_MOVERIGHT && ((mouse_ang > 0 && bForward) || (mouse_ang < 0 && !bForward)))) || (buttons & IN_MOVELEFT && ((mouse_ang > 0 && !bForward) || (mouse_ang < 0 && bForward)) && g_mouseAbs < MaxMouseAbs))
		{       
			g_PrestrafeFrameCounter[client]++;
						
			//Add speed if Prestrafe frames smaller than max frame count	
			if (g_PrestrafeFrameCounter[client] < MaxFrameCount)
			{	
				//increase speed
				g_PrestrafeVelocity[client]+= IncSpeed;
				
				//usp
				if(StrEqual(classname, "weapon_hkp2000"))
				{		
					if (g_PrestrafeVelocity[client] > 1.15)
						g_PrestrafeVelocity[client]-=0.007;
				}
				else
					if (g_PrestrafeVelocity[client] > 1.104)
						g_PrestrafeVelocity[client]-=0.007;
				
				g_PrestrafeVelocity[client]+= IncSpeed;
			}
			else
			{
				//decrease speed
				g_PrestrafeVelocity[client]-= DecSpeed;
				
				//usp reset 250.0 speed
				if(StrEqual(classname, "weapon_hkp2000"))
				{
					if (g_PrestrafeVelocity[client]< 1.042)
					{
						g_PrestrafeFrameCounter[client] = 0;
						g_PrestrafeVelocity[client]= 1.042;
					}
				}
				else	
					//knife reset 250.0 speed
					if (g_PrestrafeVelocity[client]< 1.0)
					{	
						g_PrestrafeFrameCounter[client] = 0;
						g_PrestrafeVelocity[client]= 1.0;	
					}
				g_PrestrafeFrameCounter[client] = g_PrestrafeFrameCounter[client] - 2;
			}
		}
		else
		{
			//no prestrafe
			g_PrestrafeVelocity[client] -= 0.04;
			if(StrEqual(classname, "weapon_hkp2000"))
			{
				if (g_PrestrafeVelocity[client]< 1.042)
					g_PrestrafeVelocity[client]= 1.042;
			}
			else						
			if (g_PrestrafeVelocity[client]< 1.0)
				g_PrestrafeVelocity[client]= 1.0;		
		}
	}
	else
	{
		if(StrEqual(classname, "weapon_hkp2000"))
			g_PrestrafeVelocity[client] = 1.042;
		else
			g_PrestrafeVelocity[client] = 1.0;	
		g_PrestrafeFrameCounter[client] = 0;
	}
	
	//Set VelocityModifier	
	SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", g_PrestrafeVelocity[client]);
	g_fVelocityModifierLastChange[client] = GetEngineTime();
	g_LastMouseDir[client] = mouse_ang;
}

//zipcore movedirection
stock Float:GetClientMovingDirection(client)
{
	new Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fVelocity);
	   
	new Float:fEyeAngles[3];
	GetClientEyeAngles(client, fEyeAngles);

	if(fEyeAngles[0] > 70.0) fEyeAngles[0] = 70.0;
	if(fEyeAngles[0] < -70.0) fEyeAngles[0] = -70.0;

	new Float:fViewDirection[3];
	GetAngleVectors(fEyeAngles, fViewDirection, NULL_VECTOR, NULL_VECTOR);
	   
	NormalizeVector(fVelocity, fVelocity);
	NormalizeVector(fViewDirection, fViewDirection);

	new Float:direction = GetVectorDotProduct(fVelocity, fViewDirection);
	   
	return direction;
}

public MenuRefresh(client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
		
	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;		
	}	

	//Timer Panel
	if (!g_bSayHook[client])
	{
		if (g_bTimeractivated[client])
		{
			if (g_bClimbersMenuOpen[client] == false)
				PlayerPanel(client);
		}
		
		//refresh ClimbersMenu when timer active
		if (g_bTimeractivated[client])
		{
			if (g_bClimbersMenuOpen[client] && !g_bMenuOpen[client])
				ClimbersMenu(client);
			else
				if (g_bClimbersMenuwasOpen[client]  && !g_bMenuOpen[client])
				{
					g_bClimbersMenuwasOpen[client]=false;
					ClimbersMenu(client);	
				}
			//Check Time
			if (g_fCurrentRunTime[client] > g_fPersonalRecordPro[client] && !g_bMissedProBest[client] && g_OverallTp[client] == 0 && !g_bPause[client])
			{
				g_bMissedProBest[client]=true;
				FormatTimeFloat(client, g_fPersonalRecordPro[client], 3);
				if (g_fPersonalRecordPro[client] > 0.0)
					PrintToChat(client, "%t", "MissedProBest", MOSSGREEN,WHITE,GRAY,YELLOW,g_szTime[client],GRAY);
				EmitSoundToClient(client,"buttons/button18.wav",client);
			}
			else
				if (g_fCurrentRunTime[client] > g_fPersonalRecord[client] && !g_bMissedTpBest[client] && !g_bPause[client])
				{
					g_bMissedTpBest[client]=true;
					FormatTimeFloat(client, g_fPersonalRecord[client], 3);
					if (g_fPersonalRecord[client] > 0.0)
						PrintToChat(client, "%t", "MissedTpBest", MOSSGREEN,WHITE,GRAY,YELLOW,g_szTime[client],GRAY);
					EmitSoundToClient(client,"buttons/button18.wav",client);
				}
		}
	}
}

public WjJumpPreCheck(client, &buttons)
{
	if(GetEntityFlags(client) & FL_ONGROUND && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		if (buttons & IN_JUMP)
			g_bLastButtonJump[client] = true;
		else
			g_bLastButtonJump[client] = false;
	}		
}

public TeleportCheck(client, Float: origin[3])
{
	if((StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc")  || StrEqual(g_szMapTag[0],"bkz")) || g_bAutoBhop2 == false)
	{
		if (!IsFakeClient(client))
		{
			new Float:sum = FloatAbs(origin[0]) - FloatAbs(g_fLastPosition[client][0]);
			if (sum > 15.0 || sum < -15.0)
			{
					if (g_js_bPlayerJumped[client])	
					{
						ResetJump(client);
					}	
			}
			else
			{
				sum = FloatAbs(origin[1]) - FloatAbs(g_fLastPosition[client][1]);
				if (sum > 15.0 || sum < -15.0)
				{
					if (g_js_bPlayerJumped[client])
					{
						ResetJump(client);
					}			
				}
			}	
			if (sum > 85.0 || sum < -85.0)
			{
				if (!g_bValidTeleport[client])
				{
					g_bTimeractivated[client]=false;		
				}
				g_bValidTeleport[client]=false;
			}
			else
			{
				sum = FloatAbs(origin[1]) - FloatAbs(g_fLastPosition[client][1]);
				if (sum > 80.0 || sum < -80.0)
				{
					if (!g_bValidTeleport[client])
					{
						g_bTimeractivated[client]=false;	
					}
					g_bValidTeleport[client]=false;
				}
			}	
		}
	}
}

public NoClipCheck(client)
{
	new MoveType:mt = GetEntityMoveType(client); 
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{	
		if (mt == MOVETYPE_NOCLIP)
			g_bNoClipUsed[client]=true;
	}
	else
	{		
		if (g_js_GroundFrames[client] > 10)
			g_bNoClipUsed[client]=false;
	}		  
	if(mt == MOVETYPE_NOCLIP && (g_js_bPlayerJumped[client] || g_bTimeractivated[client]))
	{
		if (g_js_bPlayerJumped[client])
		{
			ResetJump(client);
		}
		g_bTimeractivated[client] = false;
	}
}

public SpeedCap(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	static bool:IsOnGround[MAXPLAYERS + 1]; 
	new ClientFlags = GetEntityFlags(client);
	if (ClientFlags & FL_ONGROUND)
	{
		if (!IsOnGround[client])
		{
			IsOnGround[client] = true;    
			new Float:CurVelVec[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);
			if (GetVectorLength(CurVelVec) > g_fBhopSpeedCap)
			{
				
				NormalizeVector(CurVelVec, CurVelVec);
				ScaleVector(CurVelVec, g_fBhopSpeedCap);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
			}
		}
	}
	else
		IsOnGround[client] = false;	
}

public ButtonPressCheck(client, &buttons, Float: origin[3], Float:speed)
{
	if (g_LastButton[client] != IN_USE && buttons & IN_USE && (g_fCurrentRunTime[client] > 0.1 || g_fCurrentRunTime[client] == -1.0))
	{
		new  Float: distance1 = GetVectorDistance(origin, g_fStartButtonPos);
		new  Float: distance2 = GetVectorDistance(origin, g_fEndButtonPos);
		if (distance1 < 80.0 && speed < 251.0)
		{
			CL_OnStartTimerPress(client);
			g_fLastTimeButtonSound[client] = GetEngineTime();
		}
		else
			if (distance2 < 80.0)
			{
				CL_OnEndTimerPress(client);
				g_fLastTimeButtonSound[client] = GetEngineTime();
			}
	}		
}


public bool:Filter_NoPlayers(entity, mask)
	return entity > MaxClients && !GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	
public CalcJumpMaxSpeed(client, Float: fspeed)
{
	if (g_js_bPlayerJumped[client])
		if (g_fLastSpeed[client] <= fspeed)
			g_js_fMax_Speed[client] = fspeed;
}

public CalcJumpHeight(client)
{
	if (g_js_bPlayerJumped[client])
	{
		new Float:height[3];
		GetClientAbsOrigin(client, height);
		if (height[2] > g_js_fMax_Height[client])
			g_js_fMax_Height[client] = height[2];	
		g_fLastHeight[client] = height[2];
	}
}

public CalcLastJumpHeight(client, &buttons, Float: origin[3])
{
	if(GetEntityFlags(client) & FL_ONGROUND && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		decl Float:flPos[3];
		GetClientAbsOrigin(client, flPos);	
		g_js_fJump_JumpOff_PosLastHeight[client] = flPos[2];
	}		
	new Float:distance = GetVectorDistance(g_fLastPosition[client], origin);
	if(distance > 25.0)
	{
		if(g_js_bPlayerJumped[client])
			g_js_bPlayerJumped[client] = false;
	}
}

public CalcJumpSync(client, Float: speed, Float: ang, &buttons)
{
	if (g_js_bPlayerJumped[client])
	{
		new bool: turning_right = false;
		new bool: turning_left = false;
		
		if( ang < g_fLastAngles[client][1])
			turning_right = true;
		else 
			if( ang > g_fLastAngles[client][1])
				turning_left = true;	
		
		//strafestats
		if(turning_left || turning_right)
		{
			if( !g_js_Strafing_AW[client] && ((buttons & IN_FORWARD) || (buttons & IN_MOVELEFT)) && !(buttons & IN_MOVERIGHT) && !(buttons & IN_BACK) )
			{
				g_js_Strafing_AW[client] = true;
				g_js_Strafing_SD[client] = false;					
				g_js_StrafeCount[client]++; 
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Frames[client][g_js_StrafeCount[client]-1] = 0.0;		
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;	
			}
			else if( !g_js_Strafing_SD[client] && ((buttons & IN_BACK) || (buttons & IN_MOVERIGHT)) && !(buttons & IN_MOVELEFT) && !(buttons & IN_FORWARD) )
			{
				g_js_Strafing_AW[client] = false;
				g_js_Strafing_SD[client] = true;
				g_js_StrafeCount[client]++; 
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Frames[client][g_js_StrafeCount[client]-1] = 0.0;		
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;		
			}				
		}									
		//sync
		if( g_fLastSpeed[client] < speed )
		{
			g_js_Good_Sync_Frames[client]++;		
			if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
			{
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client] - 1]++;
				g_js_Strafe_Gained[client][g_js_StrafeCount[client] - 1] += (speed - g_fLastSpeed[client]);
			}
		}	
		else 
			if( g_fLastSpeed[client] > speed )
			{
				if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
					g_js_Strafe_Lost[client][g_js_StrafeCount[client] - 1] += (g_fLastSpeed[client] - speed);
			}

		//strafe frames
		if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
		{
			g_js_Strafe_Frames[client][g_js_StrafeCount[client] - 1]++;
			if( g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] < speed )
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;
		}
		//total frames
		g_js_Sync_Frames[client]++;
	}
}

public GravityCheck(client)
{
	new Float:flGravity = GetEntityGravity(client);		
	if ((flGravity != 0.0 && flGravity !=1.0) && g_js_bPlayerJumped[client])
		ResetJump(client);
}

//Credits: Antistrafe hack by Zipcore
//https://forums.alliedmods.net/showthread.php?t=230851
public StrafeHackAntiCheat(client,Float:angles[3],&buttons)
{
	if (IsFakeClient(client))
		return;
	new x = MAX_STRAFES2 - 1;
	new Float: vel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
	if(g_PlayerStates[client][nStrafes] >= x)
	{
		ComputeStrafes(client);
		ResetStrafes(client);	
		GetClientAbsOrigin(client, g_fvLastOrigin[client]);
		GetClientAbsAngles(client, g_fvLastAngles[client]);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fvLastVelocity[client]);
	}
	else
	{
		new Float:time = GetGameTime();	
		/* Prepare angle */
		new Float:vAngles[3];
		vAngles[1] = angles[1];
		vAngles[1] += 360;	
		/* Angle direction */
		new bool:angle_gain;
		if (g_fvLastAngles[client][1] < angles[1])
			angle_gain = true;
		else
			angle_gain = false;
		
		/* Angle changed direction */
		if (g_PlayerStates[client][bStrafeAngleGain][g_PlayerStates[client][nStrafes]] != angle_gain)
		{
			g_PlayerStates[client][bStrafeAngleGain][g_PlayerStates[client][nStrafes]] = angle_gain;
			g_PlayerStates[client][fStrafeTimeAngleTurn][g_PlayerStates[client][nStrafes]] = time;
		}
		
		/* Validate strafe */
		new nButtonCount;
		if(buttons & IN_MOVELEFT)
			nButtonCount++;
		if(buttons & IN_MOVERIGHT)
			nButtonCount++;
		if(buttons & IN_FORWARD)
			nButtonCount++;
		if(buttons & IN_BACK)
			nButtonCount++;
		
		/* Get strafe phase */
		new bool:newstrafe;
		if(nButtonCount == 1)
		{
			/* Start new strafe */
			if(g_PlayerStates[client][nStrafeDir] != STRAFE_A && buttons & IN_MOVELEFT)
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_A;
				newstrafe = true;
			}
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_A && (vel[1] < 0))
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_A;
				newstrafe = true
			}
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_D && buttons & IN_MOVERIGHT)
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_D;
				newstrafe = true;
			}			
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_D && (vel[1] < 0))
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_D;
				newstrafe = true
			}			
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_W && buttons & IN_FORWARD)
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_W;
				newstrafe = true;
			}		
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_W && (vel[1] < 0))
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_W;
				newstrafe = true
			}			
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_S && buttons & IN_BACK)
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_S;
				newstrafe = true;
			}				
			else if(g_PlayerStates[client][nStrafeDir] != STRAFE_S && (vel[1] < 0))
			{
				g_PlayerStates[client][nStrafeDir] = STRAFE_S;
				newstrafe = true
			}
			
			/* Continue strafe */
			else if(g_PlayerStates[client][nStrafeDir] == STRAFE_A && buttons & IN_MOVELEFT)
			{
				g_PlayerStates[client][fStrafeTimeLastSync][g_PlayerStates[client][nStrafes]] = time;
			}
			else if(g_PlayerStates[client][nStrafeDir] == STRAFE_D && buttons & IN_MOVERIGHT)
			{
				g_PlayerStates[client][fStrafeTimeLastSync][g_PlayerStates[client][nStrafes]] = time;
			}
			else if(g_PlayerStates[client][nStrafeDir] == STRAFE_W && buttons & IN_FORWARD)
			{
				g_PlayerStates[client][fStrafeTimeLastSync][g_PlayerStates[client][nStrafes]] = time;
			}
			else if(g_PlayerStates[client][nStrafeDir] == STRAFE_S && buttons & IN_BACK)
			{
				g_PlayerStates[client][fStrafeTimeLastSync][g_PlayerStates[client][nStrafes]] = time;
			}
		}
		
		/* New strafe action */
		if(newstrafe && !IsFakeClient(client))
		{
			g_PlayerStates[client][nStrafes]++;
			/* Get delay between angle turned and key pressed for a new strafe */
			new Float:strafe_delay;
			strafe_delay = time-g_PlayerStates[client][fStrafeTimeLastSync][g_PlayerStates[client][nStrafes]-1];
			if (!g_bRoundEnd)
				g_PlayerStates[client][fStrafeDelay][g_PlayerStates[client][nStrafes]] = strafe_delay;
		}
		
		/* Boosted strafe check */
		if(g_PlayerStates[client][nStrafes] > 0)
		{
			new Float:fVelDelta;
			fVelDelta = GetSpeed(client) - GetVSpeed(g_fvLastVelocity[client]);
		
			if(!(GetEntityFlags(client) & FL_ONGROUND))
			{
				/* Filter low speed */
				if(GetSpeed(client) >= GetEntPropFloat(client, Prop_Send, "m_flMaxspeed"))
				{
					/* Filter low acceleration */
					if(fVelDelta > 3.0)
					{
						/* Strafe is boosted */
						if(!g_PlayerStates[client][bBoosted][g_PlayerStates[client][nStrafes]])
							g_PlayerStates[client][nStrafesBoosted]++;				
						g_PlayerStates[client][bBoosted][g_PlayerStates[client][nStrafes]] = true;
					}
				}
			}
		}
		
		/* Save last player status */
		GetClientAbsOrigin(client, g_fvLastOrigin[client]);
		GetClientAbsAngles(client, g_fvLastAngles[client]);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fvLastVelocity[client]);
	}
}	

public AutoBhopFunction(client,&buttons)
{
	if (!IsValidClient(client))
		return;
	if (g_bAutoBhop2 && g_bAutoBhopClient[client])
	{
		if (buttons & IN_JUMP)
			if (!(GetEntityFlags(client) & FL_ONGROUND))
				if (!(GetEntityMoveType(client) & MOVETYPE_LADDER))
					if (GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
						buttons &= ~IN_JUMP;
						
	}
}

//Credits: Macrodox by Inami
//https://forums.alliedmods.net/showthread.php?p=1678026	
public BhopHackAntiCheat(client,&buttons)
{
	if (IsFakeClient(client))
		return;
	static bool:bHoldingJump[MAXPLAYERS + 1];
	static bLastOnGround[MAXPLAYERS + 1];
	if(buttons & IN_JUMP)
	{
		if(!bHoldingJump[client])
		{
			bHoldingJump[client] = true;//started pressing +jump
			g_aiJumps[client]++;
			if (bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
				g_fafAvgPerfJumps[client] = ( g_fafAvgPerfJumps[client] * 9.0 + 0 ) / 10.0;
			   
			else 
				if (!bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
				g_fafAvgPerfJumps[client] = ( g_fafAvgPerfJumps[client] * 9.0 + 1 ) / 10.0;
		}
	}
	else 
		if(bHoldingJump[client]) 
			bHoldingJump[client] = false;//released (-jump)
	bLastOnGround[client] = GetEntityFlags(client) & FL_ONGROUND;  
}


public BoosterCheck(client)
{
	new Float:flbaseVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
	if (flbaseVelocity[0] != 0.0 || flbaseVelocity[1] != 0.0 || flbaseVelocity[2] != 0.0 && g_js_bPlayerJumped[client])
		ResetJump(client);
}

public WaterCheck(client)
{
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 0 && g_js_bPlayerJumped[client])
		ResetJump(client);
}

public SurfCheck(client)
{
	if (g_js_bPlayerJumped[client] && WallCheck(client))
	{
		ResetJump(client);
	}
}

public ResetJump(client)
{
	Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>", g_js_fJump_Distance[client]);
	g_js_GroundFrames[client] = 0;
	g_js_bPlayerJumped[client] = false;		
}

public DeadHud(client)
{
	decl String:szTick[32];
	Format(szTick, 32, "%i", g_Server_Tickrate);			
	new ObservedUser = -1;
	decl String:sSpecs[512];
	Format(sSpecs, 512, "");
	new SpecMode;			
	ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");	
	SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");	
	if (SpecMode == 4 || SpecMode == 5)
	{
		g_SpecTarget[client] = ObservedUser;
		new count=0;
		//Speclist
		if (1 <= ObservedUser <= MaxClients)
		{
			for(new x = 1; x <= MaxClients; x++) 
			{					
				if (IsValidClient(x) && !IsFakeClient(client) && !IsPlayerAlive(x) && GetClientTeam(x) >= 1 && GetClientTeam(x) <= 3)
				{
				
					SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");	
					if (SpecMode == 4 || SpecMode == 5)
					{				
						new ObservedUser2 = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
						if (ObservedUser == ObservedUser2)
						{
							count++;
							if (count < 6)
							Format(sSpecs, 512, "%s%N\n", sSpecs, x);									
						}	
						if (count ==6)
							Format(sSpecs, 512, "%s...", sSpecs);	
					}
				}					
			}
			if(!StrEqual(sSpecs,""))
			{
				decl String:szName[MAX_NAME_LENGTH];
				GetClientName(ObservedUser, szName, MAX_NAME_LENGTH);
				if (g_bTimeractivated[ObservedUser] == true)
				{			
					decl String:szTime[32];
					decl String:szTPBest[32];
					decl String:szProBest[32];
					new Float:Time = GetEngineTime() - g_fStartTime[ObservedUser] - g_fPauseTime[ObservedUser];				
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot)
						FormatTimeFloat(client, Time, 1);
					else
						FormatTimeFloat(client, Time, 4);
					Format(szTime, 32, "%s", g_szTime[client]);						
					if (!g_bPause[ObservedUser])
					{
						
						if (g_fPersonalRecord[ObservedUser] > 0.0)
						{	
							FormatTimeFloat(client, g_fPersonalRecord[ObservedUser], 3);
							Format(szTPBest, 32, "%s (#%i/%i)", g_szTime[client],g_MapRankTp[ObservedUser],g_MapTimesCountTp);	
						}	
						else
							Format(szTPBest, 32, "None");	
						if (g_fPersonalRecordPro[ObservedUser] > 0.0)
						{
							FormatTimeFloat(client, g_fPersonalRecordPro[ObservedUser], 3);
							Format(szProBest, 32, "%s (#%i/%i)", g_szTime[client],g_MapRankPro[ObservedUser],g_MapTimesCountPro);		
						}
						else
							Format(szProBest, 32, "None");	
													
						if (ObservedUser != g_ProBot && ObservedUser != g_TpBot)
						{
							Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \n%s\nTeleports: %i\n \nPersonal Bests\nPro: %s\nTP: %s", count, sSpecs, szTime,g_OverallTp[ObservedUser],szProBest,szTPBest);
							if (!g_bShowSpecs[client])
								Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\nTeleports: %i\n \nPersonal Bests\nPro: %s\nTP: %s", count,szTime,g_OverallTp[ObservedUser],szProBest,szTPBest);
						}
						else
						{	
							if (ObservedUser == g_ProBot)
								Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\nTime: %s\nTickrate: %s\nSpecs: %i",szTime,szTick,count);
							else
								Format(g_szPlayerPanelText[client], 512, "[TP Replay]\nTime: %s\nTeleports: %i\nTickrate: %s\nSpecs: %i", szTime,g_ReplayRecordTps,szTick,count);	
						}
					}
					else
					{
						if (ObservedUser == g_ProBot)
							Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\nTime: PAUSED\nTickrate: %s\nSpecs: %i",szTick,count);
						else
						{
							if (ObservedUser == g_TpBot)
								Format(g_szPlayerPanelText[client], 512, "[TP Replay]\nTime: PAUSED\nTeleports: %i\nTickrate: %s\nSpecs: %i", g_ReplayRecordTps,szTick,count);	
							else
								Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \nPAUSED", count, sSpecs);
						}
					}
				}
				else
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot) 
					{
						if (g_bShowSpecs[client])
							Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s", count, sSpecs);		
						else
							Format(g_szPlayerPanelText[client], 512, "Specs (%i)",count);		
						
					}
				}
			
				if (!g_bShowTime[client] && g_bShowSpecs[client])
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot) 
						Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s", count, sSpecs);	
					else
					{
						if (ObservedUser == g_ProBot)
							Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s\nSpecs (%i):\n%s", g_szReplayName,szTick, count, sSpecs);	
						else
							Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s\nSpecs (%i):\n%s", g_szReplayNameTp,szTick, count, sSpecs);	
						
					}	
				}
				if (!g_bShowTime[client] && !g_bShowSpecs[client])
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot) 
						Format(g_szPlayerPanelText[client], 512, "");	
					else
					{
						if (ObservedUser == g_ProBot)
							Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s", g_szReplayName,szTick);	
						else
							Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s", g_szReplayNameTp,szTick);	
						
					}	
				}
				g_bClimbersMenuOpen[client] = false;	
				
				SpecList(client);
			}
		}
		//keys
		decl String:sResult[256];	
		new Buttons;
		if (1 <= ObservedUser <= MaxClients && g_bInfoPanel[client] && IsValidEntity(ObservedUser) && 1 <= ObservedUser <= MaxClients && !IsFakeClient(client))
		{
			Buttons = g_LastButton[ObservedUser];					
			if (Buttons & IN_MOVELEFT)
				Format(sResult, sizeof(sResult), "<b>Keys</b>: A");
			else
				Format(sResult, sizeof(sResult), "<b>Keys</b>: _");
			if (Buttons & IN_FORWARD)
				Format(sResult, sizeof(sResult), "%s W", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);	
			if (Buttons & IN_BACK)
				Format(sResult, sizeof(sResult), "%s S", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);	
			if (Buttons & IN_MOVERIGHT)
				Format(sResult, sizeof(sResult), "%s D", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);	
			if (Buttons & IN_DUCK)
				Format(sResult, sizeof(sResult), "%s - DUCK", sResult);
			else
				Format(sResult, sizeof(sResult), "%s - _", sResult);			
			if (Buttons & IN_JUMP)
				Format(sResult, sizeof(sResult), "%s JUMP", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);	
									
			if (g_bJumpStats)
			{
				if (g_js_bPlayerJumped[ObservedUser] && (g_bPreStrafe || g_bProMode))
				{
					if (ObservedUser == g_ProBot || ObservedUser == g_TpBot)
						PrintHintText(client,"<font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s\n%s</font>",g_js_szLastJumpDistance[ObservedUser],g_fSpeed[ObservedUser],sResult);
					else
						PrintHintText(client,"<font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s (%.0f)\n%s</font>",g_js_szLastJumpDistance[ObservedUser],g_fSpeed[ObservedUser],g_js_fPreStrafe[ObservedUser],sResult);
				}
				else
					PrintHintText(client,"<font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s\n%s</font>",g_js_szLastJumpDistance[ObservedUser],g_fSpeed[ObservedUser],sResult);
				
			}
			else
				PrintHintText(client,"<font color='#948d8d'><b>Speed</b>: %.1f u/s\n<b>Velocity</b>: %.1f u/s\n%s</font>",g_fSpeed[ObservedUser],GetVelocity(ObservedUser),sResult);
		}			
	}	
	else
		g_SpecTarget[client] = -1;
}

public AliveMainTimer(client)
{

	//bhop plattform
	if (GetEntityFlags(client) & FL_ONGROUND)
		g_js_TotalGroundFrames[client]++;
	else
		g_js_TotalGroundFrames[client]=0;
	if (g_js_TotalGroundFrames[client] > 1 && g_bOnBhopPlattform[client])
		g_bOnBhopPlattform[client] = false;
			
	//Wall check (JumpStats)
	SurfCheck(client);
	
	if (IsFakeClient(client))
		return;
		
	//menu check
	if (!g_bTimeractivated[client])
	{
		if (g_bClimbersMenuOpen[client] && !g_bMenuOpen[client])
			ClimbersMenu(client);
		else
			if (g_bClimbersMenuwasOpen[client]  && !g_bMenuOpen[client])
			{
				g_bClimbersMenuwasOpen[client]=false;
				ClimbersMenu(client);	
			}	
		PlayerPanel(client);			
	}		

	//AutBhop check
	if (g_bAutoBhop2 && g_bTimeractivated[client])
		g_bAutoBhopWasActive[client] = true;

	//challenge check
	if (g_bChallenge_Request[client])
	{
		new Float:time= GetEngineTime() - g_fChallenge_RequestTime[client];
		if (time>20.0)
		{
			PrintToChat(client, "%t", "ChallengeRequestExpired", RED,WHITE,YELLOW);
			g_bChallenge_Request[client] = false;
		}
	}
	
	//Spec list for players
	Format(g_szPlayerPanelText[client], 512, "");
	decl String:sSpecs[512];
	new SpecMode;
	Format(sSpecs, 512, "");
	new count=0;
	for(new i = 1; i <= MaxClients; i++) 
	{
		if (IsValidClient(i) && !IsFakeClient(client) && !IsPlayerAlive(i) && !g_bFirstTeamJoin[i] && g_bSpectate[i])
		{			
			SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{		
				new Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");	
				if (Target == client)
				{
					count++;
					if (count < 6)
					Format(sSpecs, 512, "%s%N\n", sSpecs, i);

				}	
				if (count == 6)
					Format(sSpecs, 512, "%s...", sSpecs);
			}					
		}		
	}	
	if (count > 0)
	{
		if (g_bShowSpecs[client])
			Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s ", count, sSpecs);
		else
			Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n ", count);
		SpecList(client);
	}
	else
		Format(g_szPlayerPanelText[client], 512, "");	
}


//Credits: Macrodox by Inami
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

//Credits: Macrodox by Inami
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
    g_aaiLastJumps[client][0],
    g_aaiLastJumps[client][1],
    g_aaiLastJumps[client][2],
    g_aaiLastJumps[client][3],
    g_aaiLastJumps[client][4],
    g_aaiLastJumps[client][5],
    g_aaiLastJumps[client][6],
    g_aaiLastJumps[client][7],
    g_aaiLastJumps[client][8],
    g_aaiLastJumps[client][9],
    g_aaiLastJumps[client][10],
    g_aaiLastJumps[client][11],
    g_aaiLastJumps[client][12],
    g_aaiLastJumps[client][13],
    g_aaiLastJumps[client][14],
    g_aaiLastJumps[client][15],
    g_aaiLastJumps[client][16],
    g_aaiLastJumps[client][17],
    g_aaiLastJumps[client][18],
    g_aaiLastJumps[client][19],
    g_aaiLastJumps[client][20],
    g_aaiLastJumps[client][21],
    g_aaiLastJumps[client][22],
    g_aaiLastJumps[client][23],
    g_aaiLastJumps[client][24],
    g_aaiLastJumps[client][25],
    g_aaiLastJumps[client][26],
    g_aaiLastJumps[client][27],
    g_aaiLastJumps[client][28],
    g_aaiLastJumps[client][29],
	GRAY,
	WHITE,
    g_fafAvgJumps[client],
    g_fafAvgSpeed[client],
	GRAY,
	WHITE,
    g_fafAvgPerfJumps[client]);
}

//Credits: Macrodox by Inami
//https://forums.alliedmods.net/showthread.php?p=1678026
public GetClientStatsLog(client, String:string[], length)
{
    new Float:origin[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
    new String:map[128];
    GetCurrentMap(map, 128);
    Format(string, length, "%L Avg bhop ground frames: %f Avg bhop speed: %f Perfection: %f %s %f %f %f Last: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i",
    client,
    g_fafAvgJumps[client],
    g_fafAvgSpeed[client],
    g_fafAvgPerfJumps[client],
    map,
    origin[0],
    origin[1],
    origin[2],
    g_aaiLastJumps[client][0],
    g_aaiLastJumps[client][1],
    g_aaiLastJumps[client][2],
    g_aaiLastJumps[client][3],
    g_aaiLastJumps[client][4],
    g_aaiLastJumps[client][5],
    g_aaiLastJumps[client][6],
    g_aaiLastJumps[client][7],
    g_aaiLastJumps[client][8],
    g_aaiLastJumps[client][9],
    g_aaiLastJumps[client][10],
    g_aaiLastJumps[client][11],
    g_aaiLastJumps[client][12],
    g_aaiLastJumps[client][13],
    g_aaiLastJumps[client][14],
    g_aaiLastJumps[client][15],
    g_aaiLastJumps[client][16],
    g_aaiLastJumps[client][17],
    g_aaiLastJumps[client][18],
    g_aaiLastJumps[client][19],
    g_aaiLastJumps[client][20],
    g_aaiLastJumps[client][21],
    g_aaiLastJumps[client][22],
    g_aaiLastJumps[client][23],
    g_aaiLastJumps[client][24],
    g_aaiLastJumps[client][25],
    g_aaiLastJumps[client][26],
    g_aaiLastJumps[client][27],
    g_aaiLastJumps[client][28],
    g_aaiLastJumps[client][29]);
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public Teleport(client, bhop)
{
	decl i;
	new tele = -1, ent = bhop;

	//search door trigger list
	for (i = 0; i < g_BhopDoorCount; i++) 
	{
		if(ent == g_BhopDoorList[i]) 
		{
			tele = g_BhopDoorTeleList[i];
			break;
		}
	}

	//no destination? search button trigger list
	if(tele == -1) 
	{
		for (i = 0; i < g_BhopButtonCount; i++) 
		{
			if(ent == g_BhopButtonList[i]) 
			{
				tele = g_BhopButtonTeleList[i];
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

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public FindBhopBlocks() 
{
	decl Float:startpos[3], Float:endpos[3], Float:mins[3], Float:maxs[3], tele;
	new ent = -1;
	new Float:flbaseVelocity[3];
	while((ent = FindEntityByClassname(ent,"func_door")) != -1) 
	{
		if(g_DoorOffs_vecPosition1 == -1) 
		{
			g_DoorOffs_vecPosition1 = FindDataMapOffs(ent,"m_vecPosition1");
			g_DoorOffs_vecPosition2 = FindDataMapOffs(ent,"m_vecPosition2");
			g_DoorOffs_flSpeed = FindDataMapOffs(ent,"m_flSpeed");
			g_DoorOffs_spawnflags = FindDataMapOffs(ent,"m_spawnflags");
			g_DoorOffs_NoiseMoving = FindDataMapOffs(ent,"m_NoiseMoving");
			g_DoorOffs_sLockedSound = FindDataMapOffs(ent,"m_ls.sLockedSound");
			g_DoorOffs_bLocked = FindDataMapOffs(ent,"m_bLocked");		
		}

		GetEntDataVector(ent,g_DoorOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_DoorOffs_vecPosition2,endpos);
		
		
		if(startpos[2] > endpos[2]) 
		{
			GetEntDataVector(ent,g_Offs_vecMins,mins);
			GetEntDataVector(ent,g_Offs_vecMaxs,maxs);
			GetEntPropVector(ent, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
			new Float:speed = GetEntDataFloat(ent,g_DoorOffs_flSpeed);
			
			if((flbaseVelocity[0] != 1100.0 && flbaseVelocity[1] != 1100.0 && flbaseVelocity[2] != 1100.0) && (maxs[2] - mins[2]) < 80 && (startpos[2] > endpos[2] || speed > 100))
			{
				startpos[0] += (mins[0] + maxs[0]) * 0.5;
				startpos[1] += (mins[1] + maxs[1]) * 0.5;
				startpos[2] += maxs[2];
				
				if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1 || (speed > 100 && startpos[2] < endpos[2]))
				{
					g_BhopDoorList[g_BhopDoorCount] = ent;
					g_BhopDoorTeleList[g_BhopDoorCount] = tele;

					if(++g_BhopDoorCount == sizeof g_BhopDoorList) 
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
		if(g_ButtonOffs_vecPosition1 == -1) 
		{
			g_ButtonOffs_vecPosition1 = FindDataMapOffs(ent,"m_vecPosition1");
			g_ButtonOffs_vecPosition2 = FindDataMapOffs(ent,"m_vecPosition2");
			g_ButtonOffs_flSpeed = FindDataMapOffs(ent,"m_flSpeed");
			g_ButtonOffs_spawnflags = FindDataMapOffs(ent,"m_spawnflags");
		}

		GetEntDataVector(ent,g_ButtonOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_ButtonOffs_vecPosition2,endpos);

		if(startpos[2] > endpos[2] && (GetEntData(ent,g_ButtonOffs_spawnflags,4) & SF_BUTTON_TOUCH_ACTIVATES)) 
		{
			GetEntDataVector(ent,g_Offs_vecMins,mins);
			GetEntDataVector(ent,g_Offs_vecMaxs,maxs);

			startpos[0] += (mins[0] + maxs[0]) * 0.5;
			startpos[1] += (mins[1] + maxs[1]) * 0.5;
			startpos[2] += maxs[2];

			if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1) 
			{
				g_BhopButtonList[g_BhopButtonCount] = ent;
				g_BhopButtonTeleList[g_BhopButtonCount] = tele;

				if(++g_BhopButtonCount == sizeof g_BhopButtonList) 
				{
					break;
				}
			}
		}
	}
	AlterBhopBlocks(false);
}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public AlterBhopBlocks(bool:bRevertChanges) 
{
	static Float:vecDoorPosition2[sizeof g_BhopDoorList][3];
	static Float:flDoorSpeed[sizeof g_BhopDoorList];
	static iDoorSpawnflags[sizeof g_BhopDoorList];
	static bool:bDoorLocked[sizeof g_BhopDoorList];
	static Float:vecButtonPosition2[sizeof g_BhopButtonList][3];
	static Float:flButtonSpeed[sizeof g_BhopButtonList];
	static iButtonSpawnflags[sizeof g_BhopButtonList];
	decl ent, i;
	if(bRevertChanges) 
	{
		for(i = 0; i < g_BhopDoorCount; i++) 
		{
			ent = g_BhopDoorList[i];
			if(IsValidEntity(ent)) 
			{
				SetEntDataVector(ent,g_DoorOffs_vecPosition2,vecDoorPosition2[i]);
				SetEntDataFloat(ent,g_DoorOffs_flSpeed,flDoorSpeed[i]);
				SetEntData(ent,g_DoorOffs_spawnflags,iDoorSpawnflags[i],4);
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

		for(i = 0; i < g_BhopButtonCount; i++) 
		{
			ent = g_BhopButtonList[i];
			if(IsValidEntity(ent)) 
			{
				SetEntDataVector(ent,g_ButtonOffs_vecPosition2,vecButtonPosition2[i]);
				SetEntDataFloat(ent,g_ButtonOffs_flSpeed,flButtonSpeed[i]);
				SetEntData(ent,g_ButtonOffs_spawnflags,iButtonSpawnflags[i],4);
				SDKUnhook(ent,SDKHook_Touch,Entity_Touch);
			}
		}
	}
	else 
	{	//note: This only gets called directly after finding the blocks, so the entities are valid.
		decl Float:startpos[3];
		for(i = 0; i < g_BhopDoorCount; i++) 
		{
			ent = g_BhopDoorList[i];
			GetEntDataVector(ent,g_DoorOffs_vecPosition2,vecDoorPosition2[i]);
			flDoorSpeed[i] = GetEntDataFloat(ent,g_DoorOffs_flSpeed);
			iDoorSpawnflags[i] = GetEntData(ent,g_DoorOffs_spawnflags,4);
			bDoorLocked[i] = GetEntData(ent,g_DoorOffs_bLocked,1) ? true : false;
			GetEntDataVector(ent,g_DoorOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_DoorOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_DoorOffs_flSpeed,0.0);
			SetEntData(ent,g_DoorOffs_spawnflags,SF_DOOR_PTOUCH,4);
			AcceptEntityInput(ent,"Lock");
			SetEntData(ent,g_DoorOffs_sLockedSound,GetEntData(ent,g_DoorOffs_NoiseMoving,4),4);
			if(flDoorSpeed[i] <= 100)
			{
				SDKHook(ent,SDKHook_Touch,Entity_Touch);
			}
			else
			{
				g_fBhopDoorSp[i] = flDoorSpeed[i];
				SDKHook(ent,SDKHook_Touch,Entity_BoostTouch);
			}
		}

		for(i = 0; i < g_BhopButtonCount; i++) 
		{
			ent = g_BhopButtonList[i];
			GetEntDataVector(ent,g_ButtonOffs_vecPosition2,vecButtonPosition2[i]);
			flButtonSpeed[i] = GetEntDataFloat(ent,g_ButtonOffs_flSpeed);
			iButtonSpawnflags[i] = GetEntData(ent,g_ButtonOffs_spawnflags,4);
			GetEntDataVector(ent,g_ButtonOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_ButtonOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_ButtonOffs_flSpeed,0.0);
			SetEntData(ent,g_ButtonOffs_spawnflags,SF_BUTTON_DONTMOVE|SF_BUTTON_TOUCH_ACTIVATES,4);			
			SDKHook(ent,SDKHook_Touch,Entity_Touch);
		}
	}

}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public Entity_BoostTouch(bhop,client) 
{
	if(0 < client <= MaxClients) 
	{
		new Float:speed = -1.0;		
		static i;
		for(i = 0; i < g_BhopDoorCount; i++) 
		{
			if(bhop == g_BhopDoorList[i]) 
			{
				speed = g_fBhopDoorSp[i]
				break
			}
		}		
		if(speed != -1 && speed) 
		{
			
			new Float:ovel[3]
			Entity_GetBaseVelocity(client, ovel)
			new Float:evel[3]
			Entity_GetLocalVelocity(client, evel)
			if(ovel[2] < speed && evel[2] < speed)
			{
				new Float:vel[3]
				vel[0] = Float:0
				vel[1] = Float:0
				vel[2] = speed * 1.8
				Entity_SetBaseVelocity(client, vel)
			}
		}
	}
}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public Entity_Touch(bhop,client) 
{
	//bhop = entity
	if(0 < client <= MaxClients) 
	{
		g_bValidTeleport[client] = true;
		if (!g_bAllowCpOnBhopPlattforms)
			g_bOnBhopPlattform[client]=true;
		if (!g_bMultiplayerBhop)
			return;
		static Float:flPunishTime[MAXPLAYERS + 1], iLastBlock[MAXPLAYERS + 1] = { -1,... };		
		new Float:time = GetGameTime();		
		new Float:diff = time - flPunishTime[client];		
		if(iLastBlock[client] != bhop || diff > BLOCK_COOLDOWN) 
		{
			//reset cooldown
			iLastBlock[client] = bhop;
			flPunishTime[client] = time + BLOCK_TELEPORT;
			
		}
		else 
			if(diff > BLOCK_TELEPORT) 
			{
				if(time - g_fLastJump[client] > (BLOCK_TELEPORT + BLOCK_COOLDOWN))
				{
					Teleport(client, iLastBlock[client]);
					iLastBlock[client] = -1;
				}
			}
	}
}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
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

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public GetAbsBoundingBox(ent,Float:mins[3],Float:maxs[3]) 
{
	decl Float:origin[3];
	GetEntDataVector(ent,g_Offs_vecOrigin,origin);
	GetEntDataVector(ent,g_Offs_vecMins,mins);
	GetEntDataVector(ent,g_Offs_vecMaxs,maxs);
	mins[0] += origin[0];
	mins[1] += origin[1];
	mins[2] += origin[2];
	maxs[0] += origin[0];
	maxs[1] += origin[1];
	maxs[2] += origin[2];
}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
stock ResetMultiBhop()
{
	if (!g_bMultiplayerBhop)
		return;
	g_BhopDoorCount = 0;
	g_BhopButtonCount = 0;
	FindBhopBlocks();
	AlterBhopBlocks(true);
	g_BhopDoorCount = 0;
	g_BhopButtonCount = 0;
	FindBhopBlocks();
}

//Credits: Measure-Plugin by DaFox
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
	g_fvMeasurePos[client][arg][0] = origin[0];
	g_fvMeasurePos[client][arg][1] = origin[1];
	g_fvMeasurePos[client][arg][2] = origin[2];
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

//Credits: Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PRed(Handle:timer,any:client) 
{
	P2PXBeam(client,0);
}

//Credits: Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PGreen(Handle:timer,any:client) 
{
	P2PXBeam(client,1);
}

//Credits: Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
P2PXBeam(client,arg) 
{
	decl Float:Origin0[3],Float:Origin1[3],Float:Origin2[3],Float:Origin3[3]	
	Origin0[0] = (g_fvMeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (g_fvMeasurePos[client][arg][1] + 8.0);
	Origin0[2] = g_fvMeasurePos[client][arg][2];	
	Origin1[0] = (g_fvMeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (g_fvMeasurePos[client][arg][1] - 8.0);
	Origin1[2] = g_fvMeasurePos[client][arg][2];	
	Origin2[0] = (g_fvMeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (g_fvMeasurePos[client][arg][1] - 8.0);
	Origin2[2] = g_fvMeasurePos[client][arg][2];	
	Origin3[0] = (g_fvMeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (g_fvMeasurePos[client][arg][1] + 8.0);
	Origin3[2] = g_fvMeasurePos[client][arg][2];	
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

//Credits: Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
Beam(client,Float:vecStart[3],Float:vecEnd[3],Float:life,Float:width,r,g,b) 
{
	TE_Start("BeamPoints")
	TE_WriteNum("m_nModelIndex",g_GlowSprite);
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

//Credits: Measure-Plugin by DaFox
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

	g_fvMeasurePos[client][0][0] = 0.0; //This is stupid.
	g_fvMeasurePos[client][0][1] = 0.0;
	g_fvMeasurePos[client][0][2] = 0.0;
	g_fvMeasurePos[client][1][0] = 0.0;
	g_fvMeasurePos[client][1][1] = 0.0;
	g_fvMeasurePos[client][1][2] = 0.0;
}

//Credits: Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public bool:TraceFilterPlayers(entity,contentsMask) 
{
	return (entity > MaxClients) ? true : false;
}

//Credits: Timer by Zipcore
//https://github.com/Zipcore/Timer/
stock GetGroundOrigin(client, Float:pos[3])
{
	new Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}

//Credits: Timer by Zipcore
//https://github.com/Zipcore/Timer/
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

//Credits: Timer by Zipcore
//https://github.com/Zipcore/Timer/
public bool:TraceEntityFilterPlayer(entity, contentsMask) 
{
    return entity > MaxClients;
}


//Credits: Antistrafe Hack by Zipcore
//https://forums.alliedmods.net/showthread.php?t=230851
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
				decl String:sPath[512];
				BuildPath(Path_SM, sPath, sizeof(sPath), "%s", ANTICHEAT_LOG_PATH);
				if (g_bAutoBan)
					LogToFile(sPath, "%s reason: strafe hack (autoban)", reason);	
				else
					LogToFile(sPath, "%s reason: strafe hack", reason);	
				g_bFlagged[client] = true;
				if (g_bAutoBan)	
					PerformBan(client,"a strafe hack");
			}
		}	
	}
}

public CreateNavFiles()
{
	new String:DestFile[256];
	new String:SourceFile[256];
	Format(SourceFile, sizeof(SourceFile), "maps/replay_bot.nav");
	if (!FileExists(SourceFile))
	{
		LogError("<KZTIMER> Failed to create .nav files. Reason: %s doesn't exist!", SourceFile);
		return;
	}
	new String:map[256];
	new mapListSerial = -1;
	if (ReadMapList(g_MapList,	mapListSerial, "mapcyclefile", MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_NO_DEFAULT) == INVALID_HANDLE)
		if (mapListSerial == -1)
			SetFailState("<KZTIMER> Mapcycle not found.");

	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (!StrEqual(map, "", false))
		{
			Format(DestFile, sizeof(DestFile), "maps/%s.nav", map);
			if (!FileExists(DestFile))
				File_Copy(SourceFile, DestFile);
		}
	}	
}

//Credits: Antistrafe Hack by Zipcore
//https://forums.alliedmods.net/showthread.php?t=230851
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

public LoadInfoBot()
{
	if (!g_bInfoBot)
		return;

	g_InfoBot = -1;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i) || !IsFakeClient(i) || i == g_TpBot || i == g_ProBot)
			continue;
		g_InfoBot = i;
		break;
	}
	if(IsValidClient(g_InfoBot))
	{	
		Format(g_pr_rankname[g_InfoBot], 16, "BOT");
		CS_SetClientClanTag(g_InfoBot, "");
		SetEntProp(g_InfoBot, Prop_Send, "m_iAddonBits", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iPrimaryAddon", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iSecondaryAddon", 0); 		
		SetEntProp(g_InfoBot, Prop_Send, "m_iObserverMode", 1);
		SetInfoBotName(g_InfoBot);	
	}
	else
	{
		new count = 0;
		if (g_bTpReplay)
			count++;
		if (g_bProReplay)
			count++;
		if (g_bInfoBot)
			count++;
		if (count==0)
			return;
		decl String:szBuffer2[64];
		Format(szBuffer2, sizeof(szBuffer2), "bot_quota %i", count); 	
		ServerCommand(szBuffer2);		
		CreateTimer(0.5, RefreshInfoBot,TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:RefreshInfoBot(Handle:timer)
{
	LoadInfoBot();
}

public ProMode_Slowdown(client)
{
	if (!g_bProMode || !IsValidClient(client))
		return;
	if (!(GetEntityFlags(client) & FL_ONGROUND) && g_bOnGround[client])	
	g_bOnGround[client]=false;
	if ((GetEntityFlags(client) & FL_ONGROUND) && !g_bOnGround[client])	
	{
		g_bOnGround[client]=true;		
		if (!g_bGoodBhop[client])
		{
			g_bSlowDownCheck[client]=true;
			CreateTimer(0.2, ResetSlowdownTimer, client, TIMER_FLAG_NO_MAPCHANGE);
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", 0.65);
			g_bGoodBhop[client]=false;
		}
	}
}		
public ProMode_SpeeCap(client)
{
	static bool:IsOnGround[MAXPLAYERS + 1]; 
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new ClientFlags = GetEntityFlags(client);
		if (ClientFlags & FL_ONGROUND)
		{
			if (!IsOnGround[client])
			{
				IsOnGround[client] = true;    
				new Float:CurVelVec[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);
				new Float:speed = GetSpeed(client);
				if (speed > 300.0)
				{
					g_bPrestrafeTooHigh[client] = true;    
					NormalizeVector(CurVelVec, CurVelVec);
					ScaleVector(CurVelVec, 250.0);
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
				}
			}
		}
		else
			IsOnGround[client] = false;
	}
}	
	
public SetInfoBotName(ent)
{
	decl String:szBuffer[64];
	decl String:sNextMap[128];	
	if (!IsValidClient(g_InfoBot) || !g_bInfoBot)
		return;
	if(g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
		Format(sNextMap, sizeof(sNextMap), "Pending Vote");
	else
	{
		GetNextMap(sNextMap, sizeof(sNextMap));
		new String:mapPieces[6][128];
		new lastPiece = ExplodeString(sNextMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[])); 
		Format(sNextMap, sizeof(sNextMap), "%s", mapPieces[lastPiece-1]); 			
	}			
	new timeleft;
	GetMapTimeLeft(timeleft);
	new Float:ftime = float(timeleft);
	FormatTimeFloat(g_InfoBot,ftime,4);
	new Handle:hTmp;	
	hTmp = FindConVar("mp_timelimit");
	new iTimeLimit = GetConVarInt(hTmp);			
	if (hTmp != INVALID_HANDLE)
		CloseHandle(hTmp);	
	if (g_bMapEnd && iTimeLimit > 0)
		Format(szBuffer, sizeof(szBuffer), "%s (in %s)",sNextMap, g_szTime[g_InfoBot]);
	else
		Format(szBuffer, sizeof(szBuffer), "Pending Vote (no time limit)");
	CS_SetClientName(g_InfoBot, szBuffer);
	Client_SetScore(g_InfoBot,9999);
	CS_SetClientClanTag(g_InfoBot, "NEXTMAP");
}

public InfoTimerAlive(client)
{
	if (g_bInfoPanel[client] && IsValidClient(client))
	{
		decl String:sResult[256];	
		new Buttons;
		Buttons = g_LastButton[client];			
		if (Buttons & IN_MOVELEFT)
			Format(sResult, sizeof(sResult), "<b>Keys</b>: A");
		else
			Format(sResult, sizeof(sResult), "<b>Keys</b>: _");
		if (Buttons & IN_FORWARD)
			Format(sResult, sizeof(sResult), "%s W", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);	
		if (Buttons & IN_BACK)
			Format(sResult, sizeof(sResult), "%s S", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);	
		if (Buttons & IN_MOVERIGHT)
			Format(sResult, sizeof(sResult), "%s D", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);	
		if (Buttons & IN_DUCK)
			Format(sResult, sizeof(sResult), "%s - DUCK", sResult);
		else
			Format(sResult, sizeof(sResult), "%s - _", sResult);			
		if (Buttons & IN_JUMP)
			Format(sResult, sizeof(sResult), "%s JUMP", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);	

		if (IsValidEntity(client) && 1 <= client <= MaxClients && !g_bOverlay[client])
		{
			if (g_bJumpStats)
			{		
				if (g_js_bPlayerJumped[client] && (g_bPreStrafe || g_bProMode))
					PrintHintText(client,"<font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s (%.0f)\n%s</font>",g_js_szLastJumpDistance[client],g_fSpeed[client],g_js_fPreStrafe[client],sResult);
				else
					PrintHintText(client,"<font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s\n%s</font>",g_js_szLastJumpDistance[client],g_fSpeed[client],sResult);
			}
			else
				PrintHintText(client,"<font color='#948d8d'><b>Speed</b>: %.1f u/s\n<b>Velocity</b>: %.1f u/s\n%s</font>",g_fSpeed[client],GetVelocity(client),sResult);			
		}
	}	
}