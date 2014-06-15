// timer.sp

public Action:RefreshAdminMenu(Handle:timer, any:client)
{
	if (IsValidEntity(client) && !IsFakeClient(client))
		KzAdminMenu(client);
}

public Action:DBUpdateTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))	
		db_updateStat(client);	
}

public Action:RefreshPoints(Handle:timer, any:client)
{
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
	if (!g_bBhop[client])
		g_LeetJumpDominating[client] = 0;
}

public Action:RespawnTimer(Handle:timer)
{
	//Player Respawn
	for (new client = 1; client <= MaxClients; client++)
	{	
		if (IsClientInGame(client) && !IsPlayerAlive(client) && (GetClientTeam(client) > 1) && !g_bSpectate[client] && g_bAutoRespawn && !IsFakeClient(client))	
		{									
			CreateTimer(1.0, RespawnPlayer, client);
		}
	}
}

public Action:CheckRemainingTime(Handle:timer)
{
	if (g_bMapEnd)
	{
		new timeleft;
		GetMapTimeLeft(timeleft);
		if (timeleft==600)
			PrintToChatAll("[%cMAP%c] 10 minutes remaining",DARKRED,WHITE);
		if (timeleft==300)
			PrintToChatAll("[%cMAP%c] 5 minutes remaining",DARKRED,WHITE);
		if (timeleft==120)
			PrintToChatAll("[%cMAP%c] 2 minutes remaining",DARKRED,WHITE);	
		if (timeleft==60)
			PrintToChatAll("[%cMAP%c] 60 seconds remaining",DARKRED,WHITE);
		if (timeleft==30)
			PrintToChatAll("[%cMAP%c] 30 seconds remaining",DARKRED,WHITE);
		if (timeleft==15)
			PrintToChatAll("[%cMAP%c] 15 seconds remaining",DARKRED,WHITE);
		if (timeleft==5)
			PrintToChatAll("[%cMAP%c] 5..",DARKRED,WHITE);
		if (timeleft==4)
			PrintToChatAll("[%cMAP%c] 4.",DARKRED,WHITE);
		if (timeleft==3)
			PrintToChatAll("[%cMAP%c] 3..",DARKRED,WHITE);
		if (timeleft==2)
		{
			ServerCommand("mp_ignore_round_win_conditions 0");
			PrintToChatAll("[%cMAP%c] 2..",DARKRED,WHITE);
		}
		if (timeleft==1)
		{
			g_bRoundEnd=true;
			PrintToChatAll("[%cMAP%c] 1..",DARKRED,WHITE);
			for (new client = 1; client <= MaxClients; client++)				
				if(IsClientInGame(client) && IsPlayerAlive(client))
					SlapPlayer(client,100);
		}
	}
}

public Action:MainTimer2(Handle:timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;
	
	//Scoreboard		
	for (new i = 1; i <= MaxClients; i++)
	{	
		if (!IsValidEntity(i) || !IsClientInGame(i) || g_bPause[i]) 
			continue;
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
	for (new i = 1; i <= MaxClients; i++)
	{	
		if (!IsValidEntity(i) || !IsClientInGame(i) || !IsPlayerAlive(i) || !(GetEntityFlags(i) & FL_ONGROUND)) 
			continue;	
		GetClientAbsOrigin(i,g_fPlayerCordsLastPosition[i]);
		GetClientEyeAngles(i,g_fPlayerAnglesLastPosition[i]);
		g_fPlayerLastTime[i] = g_fRunTime[i];
	}
	
	//clean weapons on ground
	new maxEntities = GetMaxEntities();
	decl String:classx[20];
	if (g_bCleanWeapons)
	{
		for (new i = MaxClients + 1; i < maxEntities; i++)
		{
			if (IsValidEdict(i) && (GetEntDataEnt2(i, ownerOffset) == -1))
			{
				GetEdictClassname(i, classx, sizeof(classx));
				if ((StrContains(classx, "weapon_") != -1) || (StrContains(classx, "item_") != -1))
				{
					AcceptEntityInput(i, "Kill");
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:SpawnButtons(Handle:timer)
{
	db_selectMapButtons();
}

public Action:OnDeathTimer(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		new team = GetClientTeam(client);
		if ( team != 1)
		{	
			if (g_bClimbersMenuOpen[client])
				g_bClimbersMenuOpen2[client] = true;
			
			//kill timer
			if (g_bTimeractivated[client] && (GetClientTeam(client) > 1)  && !g_bSpectate[client])
			{
				g_bTimeractivated[client] = false;
				g_fStartTime[client] = -1.0;
				g_fRunTime[client] = -1.0;
			}		
		}
	}
}

public Action:KickPlayer(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		decl String:szReason[64];
		Format(szReason, 64, "Please set your fps_max between 100 and 300");
		KickClient(client, "%s", szReason);
	}
}


//challenge start countdown
public Action:Timer_Countdown(Handle:timer, any:client)
{
	if (IsClientConnected(client) && g_bChallenge[client] && !IsFakeClient(client))
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

public Action:TpReplayTimer(Handle:timer, any:client)
{
	if (client && IsClientConnected(client) && !IsFakeClient(client))
		SaveRecording(client,1);
}

public Action:ProReplayTimer(Handle:timer, any:client)
{
	if (client && IsClientConnected(client) && !IsFakeClient(client))
		SaveRecording(client,0);
}

public Action:CheckChallenge(Handle:timer, any:client)
{
	new bool:oppenent=false;
	decl String:szSteamId[32];
	decl String:szName[32];
	decl String:szNameTarget[32];
	if (g_bChallenge[client] && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && i != client)
			{	
				GetClientAuthString(i, szSteamId, 32);		
				if (StrEqual(szSteamId,g_szCOpponentID[client]))
				{
					oppenent=true;		
					if (g_bChallengeAbort[i] && g_bChallengeAbort[client])
					{
						GetClientName(i,szNameTarget,32);
						GetClientName(client,szName,32);
						g_bChallenge[client]=false;
						g_bChallenge[i]=false;
						SetEntityRenderColor(client, 255,255,255,255);
						SetEntityRenderColor(i, 255,255,255,255);
						PrintToChat(client, "%t", "ChallengeAborted",RED,WHITE,GREEN,szNameTarget,WHITE);
						PrintToChat(i, "%t", "ChallengeAborted",RED,WHITE,szName,WHITE);
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
			g_pr_multiplier[client]+=g_CBet[client];
			g_challenge_win_ratio[client]++;
			g_challenge_points_ratio[client]+= (g_pr_points_finished*g_CBet[client]);			
			

			
			//db opponent
			db_selectRankedPlayer(g_szCOpponentID[client], g_CBet[client]);
			
			//chat msgs
			if (IsClientInGame(client))
				PrintToChat(client, "%t", "ChallengeWon",RED,WHITE,YELLOW,WHITE);

			//db client
			g_pr_showmsg[client]=true;
			CalculatePlayerRank(client);
			
			KillTimer(timer);
			return Plugin_Handled;
		}
	}
	else
		KillTimer(timer);
	return Plugin_Continue;
}

public Action:KickBotsTimer(Handle:timer)
{	
	ServerCommand("bot_quota 0"); 
}

public Action:LoadReplaysTimer(Handle:timer)
{
	if (g_bReplayBot)
		LoadReplays();
}

public Action:SetClanTag(Handle:timer, any:client)
{
	if (client > MaxClients || client < 1 || !IsValidEntity(client) || !IsClientInGame(client) || IsFakeClient(client) || g_pr_Calculating[client])
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
		if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false) && IsClientInGame(client))
		{
			if (g_bColoredChatRanks)
				CPrintToChat(client,"%t","SkillGroup", MOSSGREEN, WHITE, GRAY,GRAY, g_pr_chat_coloredrank[client]);
			else
				PrintToChat(client,"%t","SkillGroup", MOSSGREEN, WHITE, GRAY,RED, g_pr_rankname[client]);
		}
}

public Action:SettingsEnforcerTimer(Handle:timer)
{
	if (g_bEnforcer)		
		ServerCommand("kz_prespeed_cap 380.0;sv_staminalandcost 0;sv_maxspeed 320; sv_staminajumpcost 0; sv_gravity 800; sv_airaccelerate 100; sv_friction 4.8;sv_accelerate 6.5;sv_maxvelocity 2000;sv_cheats 0"); 	
	return Plugin_Continue;
}


public Action:MainTimer(Handle:timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;
	for (new client = 1; client <= MaxClients; client++)
	{		
		if (IsValidEntity(client) && IsClientInGame(client) && !IsFakeClient(client))
		{			
			if(IsPlayerAlive(client))
				AliveMainTimer(client);
			else
				DeadMainTimer(client);					
		}
	}	
	return Plugin_Continue;		
}

public Action:WelcomeMsgTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
		PrintToChat(client, "[%cKZ%c] %s", MOSSGREEN,WHITE, g_sWelcomeMsg);
}

public Action:OverlayTimer(Handle:timer, any:client)
{
	g_bOverlay[client]=false;
}

public Action:HelpMsgTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
		PrintToChat(client, "%t", "HelpMsg", MOSSGREEN,WHITE,GREEN,WHITE);
}

public Action:SteamGroupTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
		PrintToChat(client, "%t", "SteamGroup", MOSSGREEN,WHITE);
}

public Action:GetTakeOffSpeedTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		decl Float:fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = 0.0;
		g_fTakeOffSpeed[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	}
}

public Action:StartMsgTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
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
	if (IsClientInGame(client) && !IsFakeClient(client))
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
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		if (g_bAllowCheckpoints)
			if(StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"bkz"))
				Client_Kzmenu(client,0);
	}
}

public Action:RespawnPlayer(Handle:Timer, any:client)
{
	new timeleft;
	if (timeleft>-2 && IsClientInGame(client) && !IsPlayerAlive(client) && (GetClientTeam(client) > 1) && !g_bSpectate[client] && g_bAutoRespawn)
		CS_RespawnPlayer(client);
}
		
public Action:HideRadar(Handle:timer, any:client)
{
	if (IsValidEntity(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_bSpotted", 0);
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);	
	}
}

public Action:OpenMapTimes(Handle:timer, any:client)
{
	if (IsValidEntity(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		decl String:szSteamId[32];
		GetClientAuthString(client, szSteamId, 32);		
		db_viewRecord(client, szSteamId, g_szMapName);
	}
}