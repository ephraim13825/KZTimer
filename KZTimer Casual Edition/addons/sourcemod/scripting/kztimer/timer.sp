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
			PrintToChatAll("[%cMAP%c] 1..",DARKRED,WHITE);
		if (timeleft==-2)
		{		
			CreateTimer(0.0,KickBotsTimer,_,TIMER_FLAG_NO_MAPCHANGE);
			g_bRoundEnd=true;
			for (new client = 1; client <= MaxClients; client++)
			{				
				if(IsClientConnected(client) && IsClientInGame(client) && IsPlayerAlive(client))
				{
					SlapPlayer(client,9999,false);
				}
			}
		}
	}
}

public Action:SpeedTimer(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{	
		if (!IsValidEntity(i) || !IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		g_fSpeed[i] = GetSpeed(i);
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
	g_iBot=-1;
	g_iBot2=-1;
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
	new Float:x = GetEngineTime() - g_fconnected_time[client];
	if (oldrank && g_bPointSystem && x > 5.0)
		if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false) && IsClientInGame(client))
			PrintToChat(client,"%t","SkillGroup", MOSSGREEN, WHITE, GRAY,RED, g_pr_rankname[client]);
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
		if (IsValidEntity(client) && !IsFakeClient(client))
		{	
			
			//speed default
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
			else
			{ //autobhop active?
				if (g_bAutoBhop2)
					g_bAutoBhopWasActive[client] = true;
			}
		
			//force settings
			if (IsClientInGame(client) && IsPlayerAlive(client) && g_bTimeractivated[client] && !IsFakeClient(client))
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
				//exception for monsterjam		
				if (g_BGlobalDBConnected)
				{
					if (!StrEqual(g_szMapName,"bhop_monster_jam_b1"))
						SetEntPropFloat(client, Prop_Data, "m_flGravity", 0.0);	
				}
			}
			
			//challenge check
			if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			{
				if (g_bChallengeRequest[client])
				{
					new Float:time= GetEngineTime() - g_fChallengeRequestTime[client];
					if (time>20.0)
					{
						PrintToChat(client, "%t", "ChallengeRequestExpired", RED,WHITE,YELLOW);
						g_bChallengeRequest[client] = false;
					}
				}		
			}	
					
			//Spectator list player
			Format(g_szPlayerPanelText[client], 512, "");
			if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			{
				decl String:sSpecs[512];
				new SpecMode;
				Format(sSpecs, 512, "");
				new count=0;
				for(new i = 1; i <= MaxClients; i++) 
				{
					if (IsClientInGame(i) && !IsPlayerAlive(i) && !g_bFirstSpawn[i])
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
							if (count ==5)
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

			decl String:szTick[32];
			Format(szTick, 32, "%i", g_tickrate);	
				
			new ObservedUser = -1;
			if (IsClientInGame(client) && !IsPlayerAlive(client) && !IsFakeClient(client))
			{
				decl String:sSpecs[512];
				Format(sSpecs, 512, "");
				new SpecMode;			
				SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");	
				if (SpecMode == 4 || SpecMode == 5)
				{
					ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");	
					g_SpecTarget[client] = ObservedUser;
					new count=0;
					//Speclist
					if (1 <= ObservedUser <= MaxClients)
					{
						for(new x = 1; x <= MaxClients; x++) 
						{					
							if (IsClientInGame(x) && IsValidEntity(x) && !IsPlayerAlive(x) && GetClientTeam(x) >= 1 && GetClientTeam(x) <= 3)
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
									if (count ==5)
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
								if (ObservedUser != g_iBot && ObservedUser != g_iBot2)
									FormatTimeFloat(client, Time, 1);
								else
									FormatTimeFloat(client, Time, 4);
								Format(szTime, 32, "%s", g_szTime[client]);	
								
								
								if (!g_bPause[ObservedUser])
								{
									
									if (g_fPersonalRecord[ObservedUser] > 0.0)
									{	
										FormatTimeFloat(client, g_fPersonalRecord[ObservedUser], 3);
										Format(szTPBest, 32, "%s (#%i/%i)", g_szTime[client],g_maprank_tp[ObservedUser],g_maptimes_tp);	
									}	
									else
										Format(szTPBest, 32, "None");	
									if (g_fPersonalRecordPro[ObservedUser] > 0.0)
									{
										FormatTimeFloat(client, g_fPersonalRecordPro[ObservedUser], 3);
										Format(szProBest, 32, "%s (#%i/%i)", g_szTime[client],g_maprank_pro[ObservedUser],g_maptimes_pro);		
									}
									else
										Format(szProBest, 32, "None");	
																
									if (ObservedUser != g_iBot && ObservedUser != g_iBot2)
									{
										Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \n%s\nTeleports: %i\n \nPersonal Bests\nPro: %s\nTP: %s", count, sSpecs, szTime,g_OverallTp[ObservedUser],szProBest,szTPBest);
										if (!g_bShowSpecs[client])
											Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\nTeleports: %i\n \nPersonal Bests\nPro: %s\nTP: %s", count,szTime,g_OverallTp[ObservedUser],szProBest,szTPBest);
									}
									else
									{	
										if (ObservedUser == g_iBot)
											Format(g_szPlayerPanelText[client], 512, "[Replay]\nPlayer: %s\nRecord: %s\nTime: %s\nTickrate: %s\nSpecs: %i", g_szReplayName,g_szReplayTime,szTime,szTick,count);
										else
											Format(g_szPlayerPanelText[client], 512, "[Replay]\nPlayer: %s\nRecord: %s\nTime: %s\nTeleports: %i\nTickrate: %s\nSpecs: %i", g_szReplayNameTp,g_szReplayTimeTp,szTime,g_ReplayRecordTps,szTick,count);	
									}
								}
								else
								{
									if (ObservedUser == g_iBot)
										Format(g_szPlayerPanelText[client], 512, "[Replay]\nPlayer: %s\nRecord: %s\nTime: PAUSED\nTickrate: %s\nSpecs: %i", g_szReplayName,g_szReplayTime,szTick,count);
									else
									{
										if (ObservedUser == g_iBot2)
											Format(g_szPlayerPanelText[client], 512, "[Replay]\nPlayer: %s\nRecord: %s\nTime: PAUSED\nTeleports: %i\nTickrate: %s\nSpecs: %i", g_szReplayNameTp,g_szReplayTimeTp,g_ReplayRecordTps,szTick,count);	
										else
											Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \nPAUSED", count, sSpecs);
									}
								}
							}
							else
							{
								if (ObservedUser != g_iBot && ObservedUser != g_iBot2) 
								{
									if (g_bShowSpecs[client])
										Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s", count, sSpecs);		
									else
										Format(g_szPlayerPanelText[client], 512, "Specs (%i)",count);		
									
								}
							}
						
							if (!g_bShowTime[client] && g_bShowSpecs[client])
							{
								if (ObservedUser != g_iBot && ObservedUser != g_iBot2) 
									Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s", count, sSpecs);	
								else
								{
									if (ObservedUser == g_iBot)
										Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s\nSpecs (%i):\n%s", g_szReplayName,szTick, count, sSpecs);	
									else
										Format(g_szPlayerPanelText[client], 512, "Replay of\n%s\n \nTickrate: %s\nSpecs (%i):\n%s", g_szReplayNameTp,szTick, count, sSpecs);	
									
								}	
							}
							if (!g_bShowTime[client] && !g_bShowSpecs[client])
							{
								if (ObservedUser != g_iBot && ObservedUser != g_iBot2) 
									Format(g_szPlayerPanelText[client], 512, "");	
								else
								{
									if (ObservedUser == g_iBot)
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
							Format(sResult, sizeof(sResult), "Keys: A");
						else
							Format(sResult, sizeof(sResult), "Keys: _");
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
							if (g_bPlayerJumped[client] && g_bPreStrafe)
								PrintHintText(client,"Last Jump: %.1f units\nSpeed: %.1f u/s (%.0f)\n%s",g_fLastJumpDistance[ObservedUser],g_fSpeed[ObservedUser],g_fPreStrafe[ObservedUser],sResult);
							else
								PrintHintText(client,"Last Jump: %.1f units\nSpeed: %.1f u/s\n%s",g_fLastJumpDistance[ObservedUser],g_fSpeed[ObservedUser],sResult);
						}
						else
							PrintHintText(client,"Speed: %.1f u/s\nVelocity: %.1f u/s\n%s",g_fSpeed[ObservedUser],GetVelocity(ObservedUser),sResult);
					}	
				}	
				else
					g_SpecTarget[client] = -1;
			}
						
			//NAME
			if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			{				
				new target = TraceClientViewEntity(client);		
				decl String:classname[64];
				GetClientWeapon(client, classname, 64);
				/*if(StrEqual(classname, "weapon_hkp2000"))
				{
				}
				else*/
				if (IsValidEdict(target) && !g_bHide[client] && g_bShowNames[client] && target > 0 && target <= MaxClients)
				{
					new clientteam = GetClientTeam(client);
					new targetteam = GetClientTeam(target);
					CreateTimer(1.5, OverlayTimer, client,TIMER_FLAG_NO_MAPCHANGE);
					g_bOverlay[client]=true;
					if (clientteam != targetteam && !g_bPause[target])
					{
						if (target == g_iBot || target == g_iBot2)
						{
							if (target == g_iBot)
								PrintHintText(client, " \nPRO RECORD REPLAY [BOT]");   
							else
								PrintHintText(client, " \nTP RECORD REPLAY [BOT]");  
						}
						else
						{
							new String:clientName[32];
							GetClientName(target, clientName, sizeof(clientName));
							PrintHintText(client, " \n%s | %s (%d HP)", g_pr_rankname[target], clientName, GetClientHealth(target));   
						}
					}
				}
				else	
					if (g_bInfoPanel[client])
					{
						decl String:sResult[256];	
						new Buttons;
						Buttons = g_LastButton[client];			
						if (Buttons & IN_MOVELEFT)
							Format(sResult, sizeof(sResult), "Keys: A");
						else
							Format(sResult, sizeof(sResult), "Keys: _");
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
								if (g_bPlayerJumped[client] && g_bPreStrafe)
									PrintHintText(client,"Last Jump: %.1f units\nSpeed: %.1f u/s (%.0f)\n%s",g_fLastJumpDistance[client],g_fSpeed[client],g_fPreStrafe[client],sResult);
								else
									PrintHintText(client,"Last Jump: %.1f units\nSpeed: %.1f u/s\n%s",g_fLastJumpDistance[client],g_fSpeed[client],sResult);
							}
							else
								PrintHintText(client,"Speed: %.1f u/s\nVelocity: %.1f u/s\n%s",g_fSpeed[client],GetVelocity(client),sResult);
						}
					}				
			}
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
	if (IsClientInGame(client) && !IsFakeClient(client))
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
