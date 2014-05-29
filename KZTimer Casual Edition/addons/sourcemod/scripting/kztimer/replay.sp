
//
// Botmimic2 - modified by abckrieger
// http://forums.alliedmods.net/showthread.php?t=164148
//

public Action:Timer_DelayedRespawn(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!client)
		return Plugin_Stop;
	
	if(g_hBotMimicsRecord[client] != INVALID_HANDLE && IsClientInGame(client) && !IsPlayerAlive(client) && IsFakeClient(client) && GetClientTeam(client) >= CS_TEAM_T)
		CS_RespawnPlayer(client);
	
	return Plugin_Stop;
}

public Action:Hook_WeaponCanSwitchTo(client, weapon)
{
	if(g_hBotMimicsRecord[client] == INVALID_HANDLE)
		return Plugin_Continue;
	
	if(g_iBotActiveWeapon[client] != weapon)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public StartRecording(client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client))
		return;
	
	g_hRecording[client] = CreateArray(_:FrameInfo);
	g_hRecordingAdditionalTeleport[client] = CreateArray(_:AdditionalTeleport);
	GetClientAbsOrigin(client, g_fInitialPosition[client]);
	GetClientEyeAngles(client, g_fInitialAngles[client]);
	g_iRecordedTicks[client] = 0;
	g_iOriginSnapshotInterval[client] = 0;
}

public StopRecording(client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || g_hRecording[client] == INVALID_HANDLE)
		return;
	CloseHandle(g_hRecording[client]);
	CloseHandle(g_hRecordingAdditionalTeleport[client]);	
	g_hRecording[client] = INVALID_HANDLE;
	g_hRecordingAdditionalTeleport[client] = INVALID_HANDLE;
	g_iRecordedTicks[client] = 0;
	g_iRecordPreviousWeapon[client] = 0;
	g_sRecordName[client][0] = 0;
	g_iCurrentAdditionalTeleportIndex[client] = 0;
	g_iOriginSnapshotInterval[client] = 0;
}

public SaveRecording(client, type)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || g_hRecording[client] == INVALID_HANDLE)
		return;
		
	decl String:sPath2[256];
	// Check if the default record folder exists?
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "data/kz_replays/");
	if(!DirExists(sPath2))
		CreateDirectory(sPath2, 511);
	if (type==0)
	{
		Format(sPath2, sizeof(sPath2), "data/kz_replays/%s.rec", g_szMapName);
		BuildPath(Path_SM, sPath2, sizeof(sPath2), "data/kz_replays/%s.rec", g_szMapName);
	}
	else
	{
		Format(sPath2, sizeof(sPath2), "data/kz_replays/%s_tp.rec", g_szMapName);
		BuildPath(Path_SM, sPath2, sizeof(sPath2), "data/kz_replays/%s_tp.rec", g_szMapName);
	}
				
	// Add to our loaded record list
	decl String:szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);
	
	new iHeader[FILE_HEADER_LENGTH];
	iHeader[_:FH_binaryFormatVersion] = BINARY_FORMAT_VERSION;
	strcopy(iHeader[_:FH_Time], 32, g_szNewTime[client]);
	iHeader[_:FH_tickCount] = GetArraySize(g_hRecording[client]);
	strcopy(iHeader[_:FH_Playername], 32, szName);
	iHeader[_:FH_Checkpoints] = g_OverallTp[client];
	Array_Copy(g_fInitialPosition[client], iHeader[_:FH_initialPosition], 3);
	Array_Copy(g_fInitialAngles[client], iHeader[_:FH_initialAngles], 3);
	iHeader[_:FH_frames] = g_hRecording[client];
	
	if(GetArraySize(g_hRecordingAdditionalTeleport[client]) > 0)
		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath2, g_hRecordingAdditionalTeleport[client]);
	else
		CloseHandle(g_hRecordingAdditionalTeleport[client]);	
	WriteRecordToDisk(sPath2, iHeader);
	g_bNewReplay[client]=false;
	
	if(g_hRecording[client] != INVALID_HANDLE)
		StopRecording(client);
}

WriteRecordToDisk(const String:sPath[], iFileHeader[FILE_HEADER_LENGTH])
{
	new Handle:hFile = OpenFile(sPath, "wb");
	if(hFile == INVALID_HANDLE)
	{
		LogError("Can't open the record file for writing! (%s)", sPath);
		return;
	}
	
	WriteFileCell(hFile, BM_MAGIC, 4);
	WriteFileCell(hFile, iFileHeader[_:FH_binaryFormatVersion], 1);
	WriteFileCell(hFile, strlen(iFileHeader[_:FH_Time]), 1);
	WriteFileString(hFile, iFileHeader[_:FH_Time], false);
	WriteFileCell(hFile, strlen(iFileHeader[_:FH_Playername]), 1);
	WriteFileString(hFile, iFileHeader[_:FH_Playername], false);
	WriteFileCell(hFile, iFileHeader[_:FH_Checkpoints], 4);
	WriteFile(hFile, _:iFileHeader[_:FH_initialPosition], 3, 4);
	WriteFile(hFile, _:iFileHeader[_:FH_initialAngles], 2, 4);
	
	new Handle:hAdditionalTeleport, iATIndex;
	GetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath, hAdditionalTeleport);
	
	new iTickCount = iFileHeader[_:FH_tickCount];
	WriteFileCell(hFile, iTickCount, 4);
	
	new iFrame[FRAME_INFO_SIZE];
	for(new i=0;i<iTickCount;i++)
	{
		GetArrayArray(iFileHeader[_:FH_frames], i, iFrame, _:FrameInfo);
		WriteFile(hFile, iFrame, _:FrameInfo, 4);
		
		// Handle the optional Teleport call
		if(hAdditionalTeleport != INVALID_HANDLE && iFrame[_:additionalFields] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN|ADDITIONAL_FIELD_TELEPORTED_ANGLES|ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			new iAT[AT_SIZE];
			GetArrayArray(hAdditionalTeleport, iATIndex, iAT, AT_SIZE);
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				WriteFile(hFile, _:iAT[_:atOrigin], 3, 4);
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				WriteFile(hFile, _:iAT[_:atAngles], 3, 4);
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				WriteFile(hFile, _:iAT[_:atVelocity], 3, 4);
			iATIndex++;
		}
	}
	
	CloseHandle(hFile);	
	LoadReplays();
}

public LoadReplays()
{
	if (!g_bReplayBot)
		return;
		
	ClearTrie(g_hLoadedRecordsAdditionalTeleport);

	decl String:sPath1[256]; 
	decl String:sPath2[256]; 
	Format(sPath1, sizeof(sPath1), "data/kz_replays/%s.rec",g_szMapName);
	BuildPath(Path_SM, sPath1, sizeof(sPath1), "data/kz_replays/%s.rec", g_szMapName);
	Format(sPath2, sizeof(sPath2), "data/kz_replays/%s_tp.rec",g_szMapName);
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "data/kz_replays/%s_tp.rec", g_szMapName);		
	g_bProReplay=false;
	g_bTpReplay=false;
	new Handle:hFilex = OpenFile(sPath1, "r");
	if(hFilex != INVALID_HANDLE)
		g_bProReplay=true;
		
	hFilex = OpenFile(sPath2, "r");
	if(hFilex != INVALID_HANDLE)
		g_bTpReplay=true;
	if(hFilex != INVALID_HANDLE)
		CloseHandle(hFilex);	
		
	g_iBot = -1;
	g_iBot2 = -1;
	if (g_bProReplay)
		LoadReplayPro();
	if (g_bTpReplay)
		LoadReplayTp();
}

public PlayRecord(client, type)
{
	decl String:sPath[256]; 
	if (type==0)
		Format(sPath, sizeof(sPath), "data/kz_replays/%s.rec",g_szMapName);
	else
		Format(sPath, sizeof(sPath), "data/kz_replays/%s_tp.rec",g_szMapName);
	// He's currently recording. Don't start to play some record on him at the same time.
	if(g_hRecording[client] != INVALID_HANDLE || !IsFakeClient(client))
		return;
	new iFileHeader[FILE_HEADER_LENGTH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	LoadRecordFromFile(sPath, iFileHeader);

	g_ReplayRecordTps = iFileHeader[_:FH_Checkpoints];
	if (g_ReplayRecordTps > 0)
	{
		Format(g_szReplayTimeTp, sizeof(g_szReplayTimeTp), "%s", iFileHeader[_:FH_Time]);	
		Format(g_szReplayNameTp, sizeof(g_szReplayNameTp), "%s", iFileHeader[_:FH_Playername]);	
	}
	else
	{
		Format(g_szReplayTime, sizeof(g_szReplayTime), "%s", iFileHeader[_:FH_Time]);	
		Format(g_szReplayName, sizeof(g_szReplayName), "%s", iFileHeader[_:FH_Playername]);		
	}
	g_hBotMimicsRecord[client] = iFileHeader[_:FH_frames];
	g_iBotMimicTick[client] = 0;
	g_iBotMimicRecordTickCount[client] = iFileHeader[_:FH_tickCount];
	g_iCurrentAdditionalTeleportIndex[client] = 0;
	
	Array_Copy(iFileHeader[_:FH_initialPosition], g_fInitialPosition[client], 3);
	Array_Copy(iFileHeader[_:FH_initialAngles], g_fInitialAngles[client], 3);
	SDKHook(client, SDKHook_WeaponCanSwitchTo, Hook_WeaponCanSwitchTo);
	// Respawn him to get him moving!
	if(IsClientInGame(client) && !IsPlayerAlive(client) && GetClientTeam(client) >= CS_TEAM_T)
		CS_RespawnPlayer(client);
}

	
public LoadRecordFromFile(const String:path[], headerInfo[FILE_HEADER_LENGTH])
{
	new Handle: hFile = OpenFile(path, "rb");
	if(hFile == INVALID_HANDLE)
		return;
	new iMagic;
	ReadFileCell(hFile, iMagic, 4);
	if(iMagic != BM_MAGIC)
	{
		CloseHandle(hFile);
		return;
	}
	new iBinaryFormatVersion;
	ReadFileCell(hFile, iBinaryFormatVersion, 1);
	headerInfo[_:FH_binaryFormatVersion] = iBinaryFormatVersion;
	
	if(iBinaryFormatVersion > BINARY_FORMAT_VERSION)
	{
		CloseHandle(hFile);
		return;
	}
		
	new iNameLength;
	ReadFileCell(hFile, iNameLength, 1);
	decl String:szTime[iNameLength+1];
	ReadFileString(hFile, szTime, iNameLength+1, iNameLength);
	szTime[iNameLength] = '\0';

	new iNameLength2;
	ReadFileCell(hFile, iNameLength2, 1);
	decl String:szName[iNameLength2+1];
	ReadFileString(hFile, szName, iNameLength2+1, iNameLength2);
	szName[iNameLength2] = '\0';

	new iCp;
	ReadFileCell(hFile, iCp, 4);
	
	ReadFile(hFile, _:headerInfo[_:FH_initialPosition], 3, 4);
	ReadFile(hFile, _:headerInfo[_:FH_initialAngles], 2, 4);

	new iTickCount;
	ReadFileCell(hFile, iTickCount, 4);
	
	strcopy(headerInfo[_:FH_Time], 32, szTime);
	strcopy(headerInfo[_:FH_Playername], 32, szName);
	headerInfo[_:FH_Checkpoints] = iCp;
	headerInfo[_:FH_tickCount] = iTickCount;
	headerInfo[_:FH_frames] = INVALID_HANDLE;
	
	new Handle:hRecordFrames = CreateArray(_:FrameInfo);
	new Handle:hAdditionalTeleport = CreateArray(AT_SIZE);
	
	new iFrame[FRAME_INFO_SIZE];
	for(new i=0;i<iTickCount;i++)
	{
		ReadFile(hFile, iFrame, _:FrameInfo, 4);
		PushArrayArray(hRecordFrames, iFrame, _:FrameInfo);
		
		if(iFrame[_:additionalFields] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN|ADDITIONAL_FIELD_TELEPORTED_ANGLES|ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			new iAT[AT_SIZE];
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				ReadFile(hFile, _:iAT[_:atOrigin], 3, 4);
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				ReadFile(hFile, _:iAT[_:atAngles], 3, 4);
			if(iFrame[_:additionalFields] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				ReadFile(hFile, _:iAT[_:atVelocity], 3, 4);
			iAT[_:atFlags] = iFrame[_:additionalFields] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN|ADDITIONAL_FIELD_TELEPORTED_ANGLES|ADDITIONAL_FIELD_TELEPORTED_VELOCITY);
			PushArrayArray(hAdditionalTeleport, iAT, AT_SIZE);
		}
	}
	
	headerInfo[_:FH_frames] = hRecordFrames;
	
	if(GetArraySize(hAdditionalTeleport) > 0)
		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, path, hAdditionalTeleport);
	CloseHandle(hFile);
	return;
}

public Action:RefreshBot(Handle:timer)
{
	LoadReplayPro();
}

public Action:RefreshBotTp(Handle:timer)
{
	LoadReplayTp();
}

public LoadReplayPro()
{
	g_iBot = -1;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		if(!IsFakeClient(i))
			continue;
		if(!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);
			continue;
		}
		g_iBot = i;
		new String:buffer[128];	
		Format(buffer, sizeof(buffer), "- PRO RECORD REPLAY");	
		
		CS_SetClientName(g_iBot, buffer);	 //causes crash on windows server
		g_fRunTime[g_iBot] = 0.0;
		break;
	}

	if(g_iBot > 0 && IsValidEntity(g_iBot) && IsClientInGame(g_iBot))
	{		
		PlayRecord(g_iBot,0);
		SetEntityRenderColor(g_iBot, g_ReplayBotProColor[0], g_ReplayBotProColor[1], g_ReplayBotProColor[2], 50);
		decl String:szSkin[256];
		decl String:szArm[256];
		Format(szSkin, 256, g_sReplayBotPlayerModel);
		Format(szArm, 256, g_sReplayBotArmModel);
		if (g_bPlayerSkinChange)
		{
			SetEntityModel(g_iBot, szSkin);
			SetEntPropString(g_iBot, Prop_Send, "m_szArmsModel", szArm);
		}
	}
	else
	{
		if(g_bTpReplay)
			ServerCommand("bot_quota 2");
		else
			if(g_bProReplay)
				ServerCommand("bot_quota 1");		
			else
			{
				ServerCommand("bot_quota 0");	
				return;
			}
		CreateTimer(2.0, RefreshBot,TIMER_FLAG_NO_MAPCHANGE);
	}
}

public LoadReplayTp()
{
	g_iBot2 = -1;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		if(!IsFakeClient(i))
			continue;
		if(!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);
			continue;
		}
		if(i==g_iBot)
			continue;
		g_iBot2 = i;
		g_fRunTime[g_iBot2] = 0.0;
		new String:buffer[128];
		Format(buffer, sizeof(buffer), "- TP RECORD REPLAY");	
		CS_SetClientName(g_iBot2, buffer);  //causes crash on windows server
		break;
	}

	if(g_iBot2 > 0 && IsValidEntity(g_iBot2) && IsClientInGame(g_iBot2))
	{			
		PlayRecord(g_iBot2,1);
		SetEntityRenderColor(g_iBot2, g_ReplayBotTpColor[0], g_ReplayBotTpColor[1], g_ReplayBotTpColor[2], 50);
		decl String:szSkin[256];
		decl String:szArm[256];
		Format(szSkin, 256, g_sReplayBotPlayerModel);
		Format(szArm, 256, g_sReplayBotArmModel);
		if (g_bPlayerSkinChange)
		{
			SetEntityModel(g_iBot2, szSkin);
			SetEntPropString(g_iBot2, Prop_Send, "m_szArmsModel", szArm);
		}
	}
	else
	{
		if(g_bProReplay)
			ServerCommand("bot_quota 2");
		else
			if(g_bTpReplay)
				ServerCommand("bot_quota 1");		
			else
			{
				ServerCommand("bot_quota 0");	
				return;
			}
		CreateTimer(6.0, RefreshBotTp,TIMER_FLAG_NO_MAPCHANGE);
	}
}

public StopPlayerMimic(client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client))
		return;
	g_iBotMimicTick[client] = 0;
	g_iCurrentAdditionalTeleportIndex[client] = 0;
	g_iBotMimicRecordTickCount[client] = 0;
	g_bValidTeleportCall[client] = false;
	SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Hook_WeaponCanSwitchTo);	
	g_hBotMimicsRecord[client] = INVALID_HANDLE;
}

public IsPlayerMimicing(client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Bad player index %d", client);
		return false;
	}	
	return g_hBotMimicsRecord[client] != INVALID_HANDLE;
}



public DeleteReplay(client, type, String:map[])
{
	decl String:sPath[256]; 
	if (type==1)
		Format(sPath, sizeof(sPath), "data/kz_replays/%s_tp.rec",map);
	else
		Format(sPath, sizeof(sPath), "data/kz_replays/%s.rec",map);
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	
	// Delete the file
	if(FileExists(sPath))
	{
		DeleteFile(sPath);
		if (type==1)
			PrintToConsole(client, "Tp Replay %s_tp.rec successfully deleted", map);
		else
			PrintToConsole(client, "Pro Replay %s.rec successfully deleted", map);
		if (StrEqual(map,g_szMapName))
		{
			CreateTimer(0.0,KickBotsTimer,_,TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(2.0,LoadReplaysTimer,_,TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
		PrintToConsole(client, "Failed! %s not found.",sPath);		
}