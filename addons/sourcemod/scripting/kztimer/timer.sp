// timer.sp

public Action:RefreshAdminMenu(Handle:timer, any:client)
{
	if (IsValidEntity(client) && !IsFakeClient(client))
		KzAdminMenu(client);
}

public Action:UpdatePlayerProfile(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))	
		db_updateStat(client);	
}

public Action:HyperscrollWarningTimer(Handle:timer, any:client)
{
	g_bHyperscrollWarning[client] = true;
}

public Action:MoveTypeNoneTimer(Handle:timer, any:client)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
}

public Action:BhopCheck(Handle:timer, any:client)
{
	if (!g_js_bBhop[client])
		g_js_LeetJump_Count[client] = 0;
}

public Action:AttackTimer(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{	
		if (!IsValidClient(i) || IsFakeClient(i))
			continue;	
		
		if (g_AttackCounter[i] > 0)
		{
			if (g_AttackCounter[i] < 5)
				g_AttackCounter[i] = 0;
			else
				g_AttackCounter[i] = g_AttackCounter[i]  - 5;
		}
	}
}

public Action:CheckRemainingTime(Handle:timer)
{
	new Handle:hTmp;	
	hTmp = FindConVar("mp_timelimit");
	new iTimeLimit = GetConVarInt(hTmp);			
	if (hTmp != INVALID_HANDLE)
		CloseHandle(hTmp);	
	if (g_bMapEnd && iTimeLimit > 0)
	{
		new timeleft;
		GetMapTimeLeft(timeleft);		
		switch(timeleft)
		{
			case 1800: PrintToChatAll("%t", "TimeleftMinutes",LIGHTRED,WHITE,timeleft/60);
			case 1200: PrintToChatAll("%t", "TimeleftMinutes",LIGHTRED,WHITE,timeleft/60);
			case 600:  PrintToChatAll("%t", "TimeleftMinutes",LIGHTRED,WHITE,timeleft/60);
			case 300:  PrintToChatAll("%t", "TimeleftMinutes",LIGHTRED,WHITE,timeleft/60);
			case 120:  PrintToChatAll("%t", "TimeleftMinutes",LIGHTRED,WHITE,timeleft/60);
			case 60:   PrintToChatAll("%t", "TimeleftSeconds",LIGHTRED,WHITE,timeleft); 
			case 30:   PrintToChatAll("%t", "TimeleftSeconds",LIGHTRED,WHITE,timeleft); 
			case 15:   PrintToChatAll("%t", "TimeleftSeconds",LIGHTRED,WHITE,timeleft); 		
			case -1:   PrintToChatAll("%t", "TimeleftCounter",LIGHTRED,WHITE,3); 	
			case -2:   PrintToChatAll("%t", "TimeleftCounter",LIGHTRED,WHITE,2); 	
			case -3:
			{
				if (!g_bRoundEnd)
				{
					g_bRoundEnd=true;			
					ServerCommand("mp_ignore_round_win_conditions 0");
					PrintToChatAll("%t", "TimeleftCounter",LIGHTRED,WHITE,1); 	
					CreateTimer(1.0, TerminateRoundTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
} 

public Action:MainTimer2(Handle:timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;

	SetInfoBotName(g_InfoBot);	
	for (new i = 1; i <= MaxClients; i++)
	{	
		if (!IsValidClient(i) || i == g_InfoBot)
			continue;
		
		if (!IsFakeClient(i) && !g_bKickStatus[i])
			QueryClientConVar(i, "fps_max", ConVarQueryFinished:FPSCheck, i);
		
		//Scoreboard			
		if (!g_bPause[i]) 
		{
			new Float:fltime = GetEngineTime() - g_fStartTime[i] - g_fPauseTime[i] + 1.0;
			if (IsPlayerAlive(i) && g_bTimeractivated[i])
			{
				new time = RoundToZero(fltime);
				Client_SetScore(i,time); 
				Client_SetAssists(i,g_OverallCp[i]);		
				Client_SetDeaths(i,g_OverallTp[i]);								
			}
			else
			{		
				Client_SetScore(i,0);
				Client_SetDeaths(i,0);
				Client_SetAssists(i,0);
			}
			if (!IsFakeClient(i) && !g_pr_Calculating[i])
				CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);		
		}
				
		//Last Cords & Angles
		if (IsPlayerAlive(i)) 
		{
			GetClientAbsOrigin(i,g_fPlayerCordsLastPosition[i]);
			GetClientEyeAngles(i,g_fPlayerAnglesLastPosition[i]);
		}
	}
	
	//clean weapons on ground
	new maxEntities = GetMaxEntities();
	decl String:classx[20];
	if (g_bCleanWeapons)
	{
		for (new j = MaxClients + 1; j < maxEntities; j++)
		{
			if (IsValidEdict(j) && (GetEntDataEnt2(j, g_ownerOffset) == -1))
			{
				GetEdictClassname(j, classx, sizeof(classx));
				if ((StrContains(classx, "weapon_") != -1) || (StrContains(classx, "item_") != -1))
				{
					AcceptEntityInput(j, "Kill");
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:CreateMapButtons(Handle:timer)
{
	db_selectMapButtons();
}

public Action:OnDeathTimer(Handle:Timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		new team = GetClientTeam(client);
		if ( team != 1)
		{	
			if (g_bClimbersMenuOpen[client])
				g_bClimbersMenuwasOpen[client] = true;
			
			//kill timer
			if (g_bTimeractivated[client] && (GetClientTeam(client) > 1)  && !g_bSpectate[client])
			{
				g_bTimeractivated[client] = false;
				g_fStartTime[client] = -1.0;
				g_fCurrentRunTime[client] = -1.0;
			}		
		}
	}
}

public Action:KickPlayer(Handle:Timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		decl String:szReason[64];
		Format(szReason, 64, "Please set your fps_max between 120 and 300");		
		KickClient(client, "%s", szReason);
	}
}

public Action:KickPlayer2(Handle:Timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		decl String:szReason[64];
		Format(szReason, 64, "Please set your fps_max greater than or equal to 120");		
		KickClient(client, "%s", szReason);
	}
}



//challenge start countdown
public Action:Timer_Countdown(Handle:timer, any:client)
{
	if (IsValidClient(client) && g_bChallenge[client] && !IsFakeClient(client))
	{
		PrintToChat(client,"[%cKZ%c] %c%i",RED,WHITE,YELLOW,g_CountdownTime[client]);
		g_CountdownTime[client]--;
		if(g_CountdownTime[client] <= 0) 
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			PrintToChat(client, "%t", "ChallengeStarted1",RED,WHITE,YELLOW);
			PrintToChat(client, "%t", "ChallengeStarted2",RED,WHITE,YELLOW);
			PrintToChat(client, "%t", "ChallengeStarted3",RED,WHITE,YELLOW);
			PrintToChat(client, "%t", "ChallengeStarted4",RED,WHITE,YELLOW);
			KillTimer(timer);
			return Plugin_Handled;
		}
	}
	else
		KillTimer(timer);
	return Plugin_Continue;
}

public Action:ResetUndo(Handle:timer, any:client)
{
	if (IsValidClient(client) && !g_bUndo[client])
	{
		new Float: diff = GetEngineTime() - g_fLastUndo[client];
		if (diff >= 0.5)
			g_bUndoTimer[client] = false;
	}
}

public Action:TpReplayTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client,1);
}

public Action:ProReplayTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client,0);
}

public Action:CheckChallenge(Handle:timer, any:client)
{
	new bool:oppenent=false;
	decl String:szSteamId[32];
	decl String:szSteamIdx[128];
	decl String:szName[32];
	decl String:szNameTarget[32];
	if (g_bChallenge[client] && IsValidClient(client) && !IsFakeClient(client))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client)
			{	
				GetClientAuthString(i, szSteamId, 32);		
				if (StrEqual(szSteamId,g_szChallenge_OpponentID[client]))
				{
					oppenent=true;		
					if (g_bChallenge_Abort[i] && g_bChallenge_Abort[client])
					{
						GetClientName(i,szNameTarget,32);
						GetClientName(client,szName,32);
						g_bChallenge[client]=false;
						g_bChallenge[i]=false;
						SetEntityRenderColor(client, 255,255,255,255);
						SetEntityRenderColor(i, 255,255,255,255);
						PrintToChat(client, "%t", "ChallengeAborted",RED,WHITE,GREEN,szNameTarget,WHITE);
						PrintToChat(i, "%t", "ChallengeAborted",RED,WHITE,GREEN,szName,WHITE);
						SetEntityMoveType(client, MOVETYPE_WALK);
						SetEntityMoveType(i, MOVETYPE_WALK);
					}				
				}
			}
		}
		if (!oppenent)
		{				
			SetEntityRenderColor(client, 255,255,255,255);
			g_bChallenge[client]=false;
			
			//db challenge entry
			db_insertPlayerChallenge(client);
			
			//new points
			g_pr_showmsg[client]=true;
			CreateTimer(0.5, UpdatePlayerProfile, client,TIMER_FLAG_NO_MAPCHANGE);
			
			//db opponent
			Format(szSteamIdx,128,"%s",g_szChallenge_OpponentID[client]);
			RecalcPlayerRank(64,szSteamIdx);
			
			//chat msgs
			if (IsValidClient(client))
				PrintToChat(client, "%t", "ChallengeWon",RED,WHITE,YELLOW,WHITE);
					
			KillTimer(timer);
			return Plugin_Handled;
		}
	}
	else
		KillTimer(timer);
	return Plugin_Continue;
}

public Action:LoadReplaysTimer(Handle:timer)
{
	if (g_bReplayBot)
		LoadReplays();
}

public Action:SetClanTag(Handle:timer, any:client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_pr_Calculating[client])
		return;

	if (!g_bCountry && !g_bPointSystem && !g_bAdminClantag && !g_bVipClantag)
	{
		CS_SetClientClanTag(client, ""); 	
		return;
	}
	
	decl String:old_pr_rankname[32];  
	decl String:tag[32];  
	new bool:oldrank;
	
	if (!StrEqual(g_pr_rankname[client], "", false))
	{
		oldrank=true;
		Format(old_pr_rankname, 32, "%s", g_pr_rankname[client]); 
	}		
	SetPlayerRank(client);
		
	if (g_bCountry)
	{
		Format(tag, 32, "%s | %s",g_szCountryCode[client],g_pr_rankname[client]);	
		CS_SetClientClanTag(client, tag); 	
	}
	else
	{
		if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
			CS_SetClientClanTag(client, g_pr_rankname[client]); 	
	}
	
	//new rank
	if (oldrank && g_bPointSystem)
		if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false) && IsValidClient(client))
		{
			if (g_bColoredChatRanks)
				CPrintToChat(client,"%t","SkillGroup", MOSSGREEN, WHITE, GRAY,GRAY, g_pr_chat_coloredrank[client]);
			else
				PrintToChat(client,"%t","SkillGroup", MOSSGREEN, WHITE, GRAY,RED, g_pr_rankname[client]);
		}
}

public Action:ResetSlowdownTimer(Handle:timer, any:client)
{
	g_bSlowDownCheck[client]=false;	
}

public Action:SettingsEnforcerTimer(Handle:timer)
{
	if (g_bEnforcer && !g_bProMode)		
		ServerCommand("kz_prespeed_cap 380.0;sv_staminalandcost 0;sv_maxspeed 320; sv_staminajumpcost 0; sv_gravity 800; sv_airaccelerate 100; sv_friction 4.8;sv_accelerate 6.5;sv_maxvelocity 2000;sv_cheats 0"); 	
	else
	if (g_bEnforcer && g_bProMode)		
		ServerCommand("sv_airaccelerate 100;sv_staminalandcost 0.0;sv_staminajumpcost 0.0;sv_stopspeed 75;sv_maxspeed 320; sv_gravity 800; sv_friction 4;sv_accelerate 5;sv_maxvelocity 2000;sv_cheats 0");
	return Plugin_Continue;
}

public Action:TerminateRoundTimer(Handle:timer)
{
	//PrintToChatAll("[%cMAP%c] 0..",LIGHTRED,WHITE);
	CS_TerminateRound(1.0, CSRoundEnd_CTWin, true);
}


public Action:MainTimer(Handle:timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;
	for (new client = 1; client <= MaxClients; client++)
	{		
		if (IsValidClient(client))
		{			
			if(IsPlayerAlive(client))
			{
				InfoTimerAlive(client);
				AliveMainTimer(client);	
			}
			else
				DeadHud(client);				
		}
	}	
	return Plugin_Continue;		
}

public Action:WelcomeMsgTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client) && !StrEqual(g_sWelcomeMsg,""))
		CPrintToChat(client, "%s", g_sWelcomeMsg);
}

public Action:OverlayTimer(Handle:timer, any:client)
{
	g_bOverlay[client]=false;
}

public Action:HelpMsgTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		PrintToChat(client, "%t", "HelpMsg", MOSSGREEN,WHITE,GREEN,WHITE);
}

public Action:SteamGroupTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		PrintToChat(client, "[%cKZ%c] %cJoin the %cKZTimer steam group%c to receive latest news about KZTimer updates and new kreedz maps: http://steamcommunity.com/groups/kztimer", MOSSGREEN,WHITE,GRAY,LIMEGREEN,GRAY);
		PrintToConsole(client, "[KZ] Join the KZTimer steam group to receive latest news about KZTimer updates and new kreedz maps: http://steamcommunity.com/groups/kztimer");	
	}	
}

public Action:GetTakeOffSpeedTimer(Handle:timer, any:client)
{
	if (IsValidClient(client))
	{
		decl Float:fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = 0.0;
		g_js_fTakeOff_Speed[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	}
}

public Action:StartMsgTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		
		if (!g_bLanguageSelected[client])
			PrintToChat(client, "%t", "LanguageSwitch", MOSSGREEN,WHITE,GRAY,WHITE);
		if (g_bAntiCheat)
			PrintToChat(client, "%t", "AntiCheatEnabled", MOSSGREEN,WHITE,LIMEGREEN);
		if (g_bEnforcer)
			PrintToChat(client, "%t", "SettingsEnforcerEnabled", MOSSGREEN,WHITE,LIMEGREEN);
		else
			PrintToChat(client, "%t", "SettingsEnforcerDisabled", MOSSGREEN,WHITE,GRAY);	
			
		PrintMapRecords(client);	
	}
}

public Action:CenterMsgTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (g_bRestoreCMsg[client])
		{
			CreateTimer(3.5, OverlayTimer, client,TIMER_FLAG_NO_MAPCHANGE);
			g_bOverlay[client]=true;
			PrintHintText(client,"%t", "PositionRestored");
		}
		
		if (!g_bAutoTimer && IsPlayerAlive(client) && !g_bRestoreCMsg[client])
		{
			CreateTimer(3.5, OverlayTimer, client,TIMER_FLAG_NO_MAPCHANGE);
			g_bOverlay[client]=true;
			PrintHintText(client,"%t", "TimerStartReminder");
		}
		g_bRestoreCMsg[client]=false;
	}
}

public Action:ClimbersMenuTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (g_bAllowCheckpoints)
			if(StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"bkz"))
				Client_Kzmenu(client,0);
	}
}

public Action:RemoveRagdoll(Handle:timer, any:victim)
{
    if (IsValidEntity(victim) && !IsPlayerAlive(victim))
    {
        new player_ragdoll = GetEntDataEnt2(victim, g_ragdolls);
        if (player_ragdoll != -1)
            RemoveEdict(player_ragdoll);
    }
}

public Action:HideRadar(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_bSpotted", 0);
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);	
	}
}

public Action:OpenMapTimes(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		decl String:szSteamId[32];
		GetClientAuthString(client, szSteamId, 32);		
		db_viewRecord(client, szSteamId, g_szMapName);
	}
}

// Credits: Team Limit Bypass by Zephyrus
//https://forums.alliedmods.net/showthread.php?t=219812
public Action:Timer_OnMapStart(Handle:timer, any:data)
{
	
	g_TSpawns=0;
	g_CTSpawns=0;

	new ent = -1;
	while((ent = FindEntityByClassname(ent, "info_player_counterterrorist")) != -1) ++g_CTSpawns;
	ent = -1;
	while((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1) ++g_TSpawns;

	return Plugin_Stop;
}