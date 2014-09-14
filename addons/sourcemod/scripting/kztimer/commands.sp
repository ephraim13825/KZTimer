public Action:Client_Usp(client, args)
{
	if (g_UspDrops[client] < 3)
		GiveUsp(client);
	else
		PrintToChat(client, "%t", "Usp3", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public Action:Client_Ljblock(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		LJBlockMenu(client);
	return Plugin_Handled;
}

public Action:Client_Language(client, args)
{
	if (!IsValidClient(client))
			return Plugin_Handled;
	StopClimbersMenu(client);
	DisplayMenu(g_hLangMenu, client, MENU_TIME_FOREVER);	
	return Plugin_Handled;
}

public LJBlockMenu(client)
{	
	new Handle:menu = CreateMenu(LjBlockMenuHandler);
	SetMenuTitle(menu, "Block Jump Menu");
	AddMenuItem(menu, "0", "Select Destination");
	AddMenuItem(menu, "0", "Reset Destination");
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	g_bMenuOpen[client]=true;
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}

public LjBlockMenuHandler(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			Function_BlockJump(client);
			LJBlockMenu(client);
		}
		else if(select == 1)
		{
			g_bLJBlock[client] = false;
			LJBlockMenu(client);
		}
	}
}

public Action:Client_Flashlight(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client)) 
		SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	return Plugin_Handled;
}


//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public Action:Command_Stats(client, args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[%cKZ%c] Usage: !bhopcheck <name>",MOSSGREEN,WHITE);
        return Plugin_Handled;
    }   
    decl String:arg[65];
    GetCmdArg(1, arg, sizeof(arg));   
    decl String:target_name[MAX_TARGET_LENGTH];
    decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;  
    if ((target_count = ProcessTargetString(
                    arg,
                    client,
                    target_list,
                    MAXPLAYERS,
                    COMMAND_FILTER_NO_IMMUNITY,
                    target_name,
                    sizeof(target_name),
                    tn_is_ml)) <= 0)
    {
        PrintToConsole(client, "Not found or invalid parameter.");
        return Plugin_Handled;
    }    
    for (new i = 0; i < target_count; i++)
        PerformStats(client, target_list[i]);      
    return Plugin_Handled;
}



public Action:Client_Challenge(client, args)
{
	if (!g_bChallenge[client] && !g_bChallenge_Request[client])
	{
		if(IsPlayerAlive(client))
		{
			if (g_bNoBlock)
			{
				g_bMenuOpen[client]=true;
				new Handle:menu = CreateMenu(ChallengeMenuHandler1);
				if (g_bAllowCheckpoints)
				{
					SetMenuTitle(menu, "Challenge - Checkpoints?");
					AddMenuItem(menu, "Yes", "Yes");	
				}
				else
					SetMenuTitle(menu, "Challenge - Checkpoints?\nCheckpoints disabled");
				AddMenuItem(menu, "No", "No");	
				SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);			
			}
			else
				PrintToChat(client, "%t", "ChallengeFailed1",RED,WHITE);
		}
		else
			PrintToChat(client, "%t", "ChallengeFailed2",RED,WHITE);
	}
	else
		PrintToChat(client, "%t", "ChallengeFailed3",RED,WHITE);
	return Plugin_Handled;
}

public ChallengeMenuHandler1(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info,"Yes"))
			g_bChallenge_Checkpoints[param1]=true;
		else
			g_bChallenge_Checkpoints[param1]=false;
		new Handle:menu2 = CreateMenu(ChallengeMenuHandler2);
		g_bMenuOpen[param1]=true;
		decl String:tmp[64];
		if (g_bPointSystem)
			Format(tmp, 64, "Challenge - Player Bet?\nYour Points: %i", g_pr_points[param1]);
		else
			Format(tmp, 64, "Challenge - Player Bet?\nPlayer point system disabled", g_pr_points[param1]);
		SetMenuTitle(menu2, tmp);		
		AddMenuItem(menu2, "0", "No bet");			
		if (g_bPointSystem)
		{
			Format(tmp, 64, "%i", g_pr_PointUnit*50);
			if (g_pr_PointUnit*5  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);	
			Format(tmp, 64, "%i", (g_pr_PointUnit*100));
			if ((g_pr_PointUnit*10)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);		
			Format(tmp, 64, "%i", (g_pr_PointUnit*250));
			if ((g_pr_PointUnit*25)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);		
			Format(tmp, 64, "%i", (g_pr_PointUnit*500));
			if ((g_pr_PointUnit*50)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);	
		}
		SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public ChallengeMenuHandler2(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		new value = StringToInt(info);
		if (value == g_pr_PointUnit*50)		
			g_Challenge_Bet[param1] = 50;
		else
			if (value == (g_pr_PointUnit*100))	
				g_Challenge_Bet[param1] = 100;
			else
				if (value == (g_pr_PointUnit*250))	
					g_Challenge_Bet[param1] = 250;		
				else
					if (value == (g_pr_PointUnit*500))	
						g_Challenge_Bet[param1] = 500;		
					else
						g_Challenge_Bet[param1] = 0;		
		decl String:szPlayerName[MAX_NAME_LENGTH];	
		new Handle:menu2 = CreateMenu(ChallengeMenuHandler3);
		SetMenuTitle(menu2, "Challenge - Select your Opponent");
		new playerCount=0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1 && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				AddMenuItem(menu2, szPlayerName, szPlayerName);	
				playerCount++;
			}
		}
		if (playerCount>0)
		{
			g_bMenuOpen[param1]=true;
			SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu2, param1, MENU_TIME_FOREVER);		
		}
		else
		{
			PrintToChat(param1, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);
		}
		
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public ChallengeMenuHandler3(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szTargetName[MAX_NAME_LENGTH];
		GetClientName(param1, szPlayerName, MAX_NAME_LENGTH);
		GetMenuItem(menu, param2, info, sizeof(info));
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szTargetName, MAX_NAME_LENGTH);	
				
				if(StrEqual(info,szTargetName))
				{
					if (!g_bChallenge[i])
					{
						if ((g_pr_PointUnit*g_Challenge_Bet[param1]) <= g_pr_points[i])
						{
							//id of challenger
							decl String:szSteamId[32];
							GetClientAuthString(i, szSteamId, 32);	
							Format(g_szChallenge_OpponentID[param1], 32, szSteamId);					
							decl String:cp[16];
							if (g_bChallenge_Checkpoints[param1])
								Format(cp, 16, " allowed");
							else
								Format(cp, 16, " forbidden");
							new value = g_pr_PointUnit * g_Challenge_Bet[param1];
							PrintToChat(param1, "%t", "Challenge1", RED,WHITE, YELLOW, szTargetName, value,cp);					
							//target msg
							EmitSoundToClient(i,"buttons/button15.wav",i);
							PrintToChat(i, "%t", "Challenge2", RED,WHITE, YELLOW, szPlayerName, GREEN, WHITE, value,cp);
							g_fChallenge_RequestTime[param1] = GetEngineTime();
							g_bChallenge_Request[param1]=true;
						}
						else
						{
							PrintToChat(param1, "%t", "ChallengeFailed5", RED,WHITE, szTargetName, g_pr_points[i]);
						}
					}
					else
						PrintToChat(param1, "%t", "ChallengeFailed6", RED,WHITE, szTargetName);
				}
			}
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public Action:Client_Abort(client, args)
{
	if (g_bChallenge[client])
	{
		if (g_bChallenge_Abort[client])
		{
			g_bChallenge_Abort[client]=false;
			PrintToChat(client, "[%cKZ%c] You have disagreed to abort the challenge.",RED,WHITE);
		}
		else
		{
			g_bChallenge_Abort[client]=true;
			PrintToChat(client, "[%cKZ%c] You have agreed to abort the challenge. Waiting for your opponent..",RED,WHITE, GREEN);
		}
	}
	return Plugin_Handled;
}

public Action:Client_Accept(client, args)
{
	decl String:szSteamId[32];
	decl String:szCP[32];
	GetClientAuthString(client, szSteamId, 32);		
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && i != client && g_bChallenge_Request[i])
		{
			if(StrEqual(szSteamId,g_szChallenge_OpponentID[i]))
			{		
				GetClientAuthString(i, g_szChallenge_OpponentID[client], 32);
				g_bChallenge_Request[i]=false;
				g_bChallenge[i]=true;
				g_bChallenge[client]=true;
				g_bChallenge_Abort[client]=false;
				g_bChallenge_Abort[i]=false;
				g_Challenge_Bet[client] = g_Challenge_Bet[i];
				g_bChallenge_Checkpoints[client] = g_bChallenge_Checkpoints[i];
				TeleportEntity(client, g_fSpawnPosition[i],NULL_VECTOR, Float:{0.0,0.0,-100.0});
				TeleportEntity(i, g_fSpawnPosition[i],NULL_VECTOR, Float:{0.0,0.0,-100.0});
				SetEntityMoveType(i, MOVETYPE_NONE);
				SetEntityMoveType(client, MOVETYPE_NONE);
				g_CountdownTime[i] = 10;
				g_CountdownTime[client] = 10;
				CreateTimer(1.0, Timer_Countdown, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, Timer_Countdown, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				PrintToChat(client, "%t", "Challenge3",RED,WHITE, YELLOW);
				PrintToChat(i, "%t", "Challenge3",RED,WHITE, YELLOW);			
				decl String:szPlayer1[MAX_NAME_LENGTH];			
				decl String:szPlayer2[MAX_NAME_LENGTH];
				GetClientName(i, szPlayer1, MAX_NAME_LENGTH);
				GetClientName(client, szPlayer2, MAX_NAME_LENGTH);
				
				if (g_bChallenge_Checkpoints[i])
					Format(szCP, sizeof(szCP), "Allowed"); 
				else
					Format(szCP, sizeof(szCP), "Forbidden");
				new points = g_Challenge_Bet[i]*2*g_pr_PointUnit;
				PrintToChatAll("[%cKZ%c] Challenge: %c%s%c vs. %c%s%c",RED,WHITE,MOSSGREEN,szPlayer1,WHITE,MOSSGREEN,szPlayer2,WHITE);
				PrintToChatAll("[%cKZ%c] Checkpoints: %c%s%c, Pot: %c%ip",RED,WHITE,GRAY,szCP,WHITE,GRAY,points);
		
				new r1 = GetRandomInt(55, 255);
				new r2 = GetRandomInt(55, 255);
				new r3 = GetRandomInt(0, 55);
				new r4 = GetRandomInt(0, 255);
				SetEntityRenderColor(i, r1, r2, r3, r4);
				SetEntityRenderColor(client, r1, r2, r3, r4);
				g_bTimeractivated[client] = false;
				g_bTimeractivated[i] = false;
				g_fPlayerCordsUndoTp[i][0] = 0.0;
				g_fPlayerCordsUndoTp[i][1] = 0.0;
				g_fPlayerCordsUndoTp[i][2] = 0.0;		
				g_CurrentCp[i] = -1;
				g_CounterCp[i] = 0;	
				g_OverallCp[i] = 0;
				g_OverallTp[i] = 0;
				g_fPlayerCordsUndoTp[client][0] = 0.0;
				g_fPlayerCordsUndoTp[client][1] = 0.0;
				g_fPlayerCordsUndoTp[client][2] = 0.0;		
				g_CurrentCp[client] = -1;
				g_CounterCp[client] = 0;	
				g_OverallCp[client] = 0;
				g_OverallTp[client] = 0;
				CreateTimer(1.0, CheckChallenge, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, CheckChallenge, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Handled;
}

public Action:Client_Surrender (client, args)
{
	decl String:szSteamIdOpponent[32];
	decl String:szNameOpponent[MAX_NAME_LENGTH];	
	decl String:szName[MAX_NAME_LENGTH];	
	if (g_bChallenge[client])
	{
		GetClientName(client, szName, MAX_NAME_LENGTH);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client)
			{	
				GetClientAuthString(i, szSteamIdOpponent, 32);		
				if (StrEqual(szSteamIdOpponent,g_szChallenge_OpponentID[client]))
				{
					GetClientName(i, szNameOpponent, MAX_NAME_LENGTH);	
					g_bChallenge[i]=false;
					g_bChallenge[client]=false;
					db_insertPlayerChallenge(i);
					SetEntityRenderColor(i, 255,255,255,255);
					SetEntityRenderColor(client, 255,255,255,255);
					
					//msg
					for (new j = 1; j <= MaxClients; j++)
					{
						if (IsValidClient(j) && IsValidEntity(j))
						{						
								PrintToChat(j, "%t", "Challenge4",RED,WHITE,MOSSGREEN,szNameOpponent, WHITE,MOSSGREEN,szName,WHITE);
						}
					}	
					//win ratio
					SetEntityMoveType(client, MOVETYPE_WALK);
					SetEntityMoveType(i, MOVETYPE_WALK);
					g_Challenge_WinRatio[client]--;
					g_Challenge_WinRatio[i]++;
					
					if (g_Challenge_Bet[client] > 0)
					{
						g_Challenge_PointsRatio[client]-= g_Challenge_Bet[client]*g_pr_PointUnit;
						g_Challenge_PointsRatio[i]+= g_Challenge_Bet[i]*g_pr_PointUnit;
						g_pr_showmsg[i] = true;
						g_pr_showmsg[client] = true;
						PrintToChat(i, "%t", "Rc_PlayerRankStart", MOSSGREEN,WHITE,GRAY);
						PrintToChat(client, "%t", "Rc_PlayerRankStart", MOSSGREEN,WHITE,GRAY);
						new lostpoints = g_Challenge_Bet[client] * g_pr_PointUnit;
						for (new j = 1; j <= MaxClients; j++)
							if (IsValidClient(j) && IsValidEntity(j))
								PrintToChat(j, "[%cKZ%c] %c%s%c has lost %c%i %cpoints!", MOSSGREEN, WHITE, PURPLE,szName, GRAY, RED, lostpoints,GRAY);
					}
					//db update
					CreateTimer(0.0, UpdatePlayerProfile, i,TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.5, UpdatePlayerProfile, client,TIMER_FLAG_NO_MAPCHANGE);
					i = MaxClients+1;
				}
			}
		}		
	}
	return Plugin_Handled;
}

//public Action:Command_ext_Menu(client, String:command[32])
public Action:Command_ext_Menu(client, const String:command[], argc) 
{
	StopClimbersMenu(client);
	return Plugin_Handled;
}

public StopClimbersMenu(client)
{
	g_bMenuOpen[client] = true;
	if (g_hclimbersmenu[client] != INVALID_HANDLE)
	{	
		g_hclimbersmenu[client] = INVALID_HANDLE;
	}
	if (g_bClimbersMenuOpen[client])
		g_bClimbersMenuwasOpen[client]=true;
	else
		g_bClimbersMenuwasOpen[client]=false;
	g_bClimbersMenuOpen[client] = false;	
}

public Action:Command_JoinTeam(client, const String:command[], argc) 
{ 
	if(!argc || !client || !IsValidClient(client))
		return Plugin_Handled;

	if (IsFakeClient(client))
		return Plugin_Continue;
		
	decl String:m_szTeam[8];
	GetCmdArg(1, m_szTeam, sizeof(m_szTeam));
	new m_iTeam = StringToInt(m_szTeam);

	
	if(CS_TEAM_SPECTATOR<=m_iTeam<=CS_TEAM_CT)
		g_SelectedTeam[client]=m_iTeam;

	if (1 < m_iTeam <= 3) 
	{ 
		if (g_TSpawns==0 && m_iTeam == 2)
			return Plugin_Continue;
		if (g_CTSpawns==0 && m_iTeam == 3)
			return Plugin_Continue;
		if(g_bSpectate[client])
		{
			if(g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
			{
				g_fPauseTime[client] = GetEngineTime() - g_fStartPauseTime[client];
			}
			g_bSpectate[client] = false;
		}	
		CS_SwitchTeam(client, m_iTeam); 	
		CS_RespawnPlayer(client);	
		return Plugin_Handled;
	}
	if (m_iTeam == 1)
		ChangeClientTeam(client, m_iTeam);
	return Plugin_Handled;
}  

public Action:Client_OptionMenu(client, args)
{
	OptionMenu(client);
	return Plugin_Handled;
}

public Action:Client_Next(client, args)
{	
	if(g_CurrentCp[client] == -1)
	{
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
		return Plugin_Handled;
	}
	TeleClient(client,1);
	return Plugin_Handled;
}

public Action:Client_Undo(client, args)
{	
	if (IsValidClient(client))
	{
		if(g_fPlayerCordsUndoTp[client][0] == 0.0 && g_fPlayerCordsUndoTp[client][1] == 0.0 && g_fPlayerCordsUndoTp[client][2] == 0.0)
			return Plugin_Handled;
		g_bValidTeleport[client]=true;
		if (!g_bAllowCpOnBhopPlattforms)
		{
			g_bUndo[client]	= true;
			g_bUndoTimer[client] = true;
			g_fLastUndo[client] = GetEngineTime();
		}	
		TeleportEntity(client, g_fPlayerCordsUndoTp[client],g_fPlayerAnglesUndoTp[client], Float:{0.0,0.0,-100.0});
		g_js_LeetJump_Count[client] = 0;
	}
	return Plugin_Handled;
}

public Action:NoClip(client, args)
{
	decl String:szSteamId[32];
	if (IsValidClient(client))					
		GetClientAuthString(client, szSteamId, 32);	
	if (IsValidClient(client) && (g_bNoClipS || GetUserFlagBits(client) & ADMFLAG_RESERVATION || GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC || StrEqual(g_pr_rankname[client],"MAPPER") || StrEqual(szSteamId,"STEAM_1:1:73507922")))
	{
		if (!g_bMapFinished[client])
		{
			//BEST RANK || ADMIN || VIP
			if ((StrEqual(g_pr_rankname[client],g_szSkillGroups[8])  || StrEqual(szSteamId,"STEAM_1:1:73507922") || StrEqual(g_pr_rankname[client],"MAPPER") || GetUserFlagBits(client) & ADMFLAG_RESERVATION || GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC) && !g_bNoClip[client])
				Action_NoClip(client);
			else
				PrintToChat(client, "%t", "NoclipNotAvailable2",MOSSGREEN, WHITE, g_szSkillGroups[8]);
		}
		else
			if (!g_bNoClip[client])
				Action_NoClip(client);	
	}
	else
		if (IsValidClient(client))
			PrintToChat(client, "%t", "NoclipNotAvailable3",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public Action:UnNoClip(client, args)
{
	if (g_bNoClip[client] == true)
		Action_UnNoClip(client);
	return Plugin_Handled;
}

public Action:Client_Prev(client, args)
{
	if(g_CurrentCp[client] == -1)
	{
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
		return Plugin_Handled;
	}
	TeleClient(client,-1);
	return Plugin_Handled;
}

public Action:Client_Save(client, args)
{
	SaveClientLocation(client)
	return Plugin_Handled;	
}

public Action:Client_Tele(client, args)
{
	TeleClient(client,0);
	return Plugin_Handled;
}

public Action:Client_Top(client, args)
{	
	TopMenu(client);
	return Plugin_Handled;
}

public Action:Client_MapTop(client, args)
{	
	if (args==0)
	{
		PrintToChat(client, "%t", "MapTopFail",MOSSGREEN,WHITE);
		return Plugin_Handled;
	}
	decl String:szArg[128];   
	GetCmdArg(1, szArg, 128);
	db_selectMapTopClimbers(client,szArg);
	return Plugin_Handled;
}


public Action:Client_Spec(client, args)
{	
	SpecPlayer(client, args);
	return Plugin_Handled;
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Command_Menu(client,args) 
{
	StopClimbersMenu(client);
	DisplayMenu(g_hMainMenu,client,MENU_TIME_FOREVER)
	return Plugin_Handled
}

public Handler_MainMenu(Handle:menu,MenuAction:action,param1,param2) 
{
	if(action == MenuAction_Select) 
	{
		switch(param2) 
		{
			case 0: {	//Point 1 (Red)
				GetPos(param1,0)
			}
			case 1: {	//Point 2 (Green)
				GetPos(param1,1)
			}
			case 2: {	//Find Distance
				if(g_bMeasurePosSet[param1][0] && g_bMeasurePosSet[param1][1]) 
				{
					new Float:vDist = GetVectorDistance(g_fvMeasurePos[param1][0],g_fvMeasurePos[param1][1])
					new Float:vHightDist = (g_fvMeasurePos[param1][0][2] - g_fvMeasurePos[param1][1][2])
					PrintToChat(param1, "%t", "Measure1",MOSSGREEN,WHITE,vDist,vHightDist);					
					Beam(param1,g_fvMeasurePos[param1][0],g_fvMeasurePos[param1][1],4.0,2.0,0,0,255)
				}
				else 
					PrintToChat(param1, "%t", "Measure2",MOSSGREEN,WHITE);
			}
			case 3: {	//Reset
				ResetPos(param1)
			}
		}
		DisplayMenu(g_hMainMenu,param1,MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel) 
	{
		g_bMenuOpen[param1] = false;
		ResetPos(param1);
	}
}


public SpecPlayer(client,args)
{
	decl String:szPlayerName[MAX_NAME_LENGTH];
	decl String:szPlayerName2[128];
	decl String:szOrgTargetName[MAX_NAME_LENGTH];
	decl String:szTargetName[MAX_NAME_LENGTH];
	decl String:szArg[MAX_NAME_LENGTH];
	Format(szTargetName, MAX_NAME_LENGTH, ""); 
	Format(szOrgTargetName, MAX_NAME_LENGTH, ""); 
	
	if (args==0)
	{		
		new Handle:menu = CreateMenu(SpecMenuHandler);
		
		if(g_bSpectate[client])
			SetMenuTitle(menu, "spec menu (press 'm' to rejoin a team!)\nselect a player:");	
		else
			SetMenuTitle(menu, "spec menu\nselect a player:");	
		new playerCount=0;
		
		//add replay bots
		if (g_ProBot != -1 || g_TpBot != -1)
		{
			if (g_ProBot != -1 && IsValidClient(g_ProBot) && IsPlayerAlive(g_ProBot))
			{
				Format(szPlayerName2, 128, "PRO Replay (%s)",g_szReplayTime);
				AddMenuItem(menu, "PRO RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
			if (g_TpBot != -1 && IsValidClient(g_TpBot) && IsPlayerAlive(g_TpBot))
			{
				Format(szPlayerName2, 128, "TP Replay (%s)",g_szReplayTimeTp);
				AddMenuItem(menu, "TP RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		
		new x = 0;
		//add players
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				if (x==0)
					AddMenuItem(menu, "brp123123xcxc", ">> PLAYER WITH MOST EXP. POINTS <<");
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				Format(szPlayerName2, 128, "%s (%s)",szPlayerName, g_pr_rankname[i]);
				AddMenuItem(menu, szPlayerName, szPlayerName2);
				playerCount++;		
				x++;
			}
		}
		
		if (playerCount>0)
		{
			g_bMenuOpen[client]=true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);		
		}		
		else
			PrintToChat(client, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);
	}
	else 
	{
		for (new i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i==1)
					Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg); 
				else
					Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg); 
			}
		}	
		Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName); 
		StringToUpper(szTargetName);	
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client )
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);		
				StringToUpper(szPlayerName);
				if ((StrContains(szPlayerName, szTargetName) != -1))
				{
					ChangeClientTeam(client, 1);
					SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", i);  
					SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
					SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);	
					return;
				}
			}
		}	
		PrintToChat(client, "%t", "PlayerNotFound",MOSSGREEN,WHITE, szOrgTargetName);	
	}
}

public SpecMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
	
		if(StrEqual(info,"brp123123xcxc"))
		{
			new playerid;
			new count = 0;
			new points = -1;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1 && !IsFakeClient(i))
				{
					if (g_pr_points[i] > points)
					{
						points = g_pr_points[i];
						playerid = i;
						count++;
					}
				}						
			}
			if (count==0)
				PrintToChat(param1, "%t", "NoPlayerTop", MOSSGREEN,WHITE);
			else
			{
				ChangeClientTeam(param1, 1);
				SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", playerid);  
				SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
				SetEntProp(param1, Prop_Send, "m_bDrawViewmodel", 1);							
			}
		}
		else
		{		
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
					if (i == g_TpBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "TP RECORD REPLAY"); 
					else
						if (i == g_ProBot)
							Format(szPlayerName, MAX_NAME_LENGTH, "PRO RECORD REPLAY"); 			
					if(StrEqual(info,szPlayerName))
					{
						ChangeClientTeam(param1, 1);
						SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", i);  
						SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
						SetEntProp(param1, Prop_Send, "m_bDrawViewmodel", 1);					
					}
				}			
			}
		}		
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public Action:Client_Kzmenu(client, args)
{
	if (!g_bAllowCheckpoints && IsValidClient(client))
		PrintToChat(client, "%t", "CMenuDisabled",MOSSGREEN, WHITE);
	else
	{
		g_bMenuOpen[client]=false;
		ClimbersMenu(client);    
	}
	return Plugin_Handled;
}

public CompareMenu(client,args)
{
	decl String:szArg[MAX_NAME_LENGTH];
	decl String:szPlayerName[MAX_NAME_LENGTH];	
	if (args == 0)
	{
		Format(szPlayerName, MAX_NAME_LENGTH, "");
		new Handle:menu = CreateMenu(CompareSelectMenuHandler);
		SetMenuTitle(menu, "compare menu\nselect a player:");		
		new playerCount=0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				AddMenuItem(menu, szPlayerName, szPlayerName);	
				playerCount++;
			}
		}
		if (playerCount>0)
		{
			g_bMenuOpen[client]=true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);	
		}	
		else
			PrintToChat(client,"[%cKZ%c] No valid players found",MOSSGREEN,WHITE);
		return;
	}
	else
	{	
		for (new i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i==1)
					Format(szPlayerName, MAX_NAME_LENGTH, "%s", szArg); 
				else
					Format(szPlayerName, MAX_NAME_LENGTH, "%s %s",  szPlayerName, szArg); 
			}
		}
		//player ingame? new name?
		if (!StrEqual(szPlayerName,"",false))
		{
			new bool:bPlayerFound=false;
			decl String:szSteamId2[32];
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szName2[MAX_NAME_LENGTH];		
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i!=client)
				{
					GetClientName(i, szName, MAX_NAME_LENGTH);		
					StringToUpper(szName);
					Format(szName2, MAX_NAME_LENGTH, "%s", szPlayerName); 
					if ((StrContains(szName, szName2) != -1))
					{
						bPlayerFound=true;
						GetClientAuthString(i, szSteamId2, 32);
						continue;
					}
				}
			}
			if (bPlayerFound)
				db_viewPlayerRank2(client, szSteamId2);
			else
				db_viewPlayerAll2(client, szPlayerName);
		}	
	}
}

public CompareSelectMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				if(StrEqual(info,szPlayerName))
				{
					decl String:szSteamId[32];
					GetClientAuthString(i, szSteamId, 32);	
					db_viewPlayerRank2(param1, szSteamId);
				}
			}
		}
		CompareMenu(param1,0);
	}
	else
	if(action == MenuAction_Cancel)
	{
		if (IsValidClient(param1))
			g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		if (IsValidClient(param1))
			g_bSelectProfile[param1]=false;
		CloseHandle(menu);
	}
}

public ProfileMenu(client,args)
{
	//spam protection
	new Float:diff = GetEngineTime() - g_fProfileMenuLastQuery[client];
	if (diff < 0.5)
	{
		StopClimbersMenu(client);
		g_bSelectProfile[client]=false;
		return;
	}
	g_fProfileMenuLastQuery[client] = GetEngineTime();
	
	decl String:szArg[MAX_NAME_LENGTH];
	//no argument
	if (args == 0)
	{
		decl String:szPlayerName[MAX_NAME_LENGTH];	
		new Handle:menu = CreateMenu(ProfileSelectMenuHandler);
		SetMenuTitle(menu, "profile menu\nselect a player:");		
		GetClientName(client, szPlayerName, MAX_NAME_LENGTH);	
		AddMenuItem(menu, szPlayerName, szPlayerName);	
		new playerCount=1;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				AddMenuItem(menu, szPlayerName, szPlayerName);	
				playerCount++;
			}
		}
		g_bMenuOpen[client]=true;
		g_bSelectProfile[client]=true;
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);		
		return;
	}
	//get name
	else 
	{
		if (args != -1)
		{
			g_bSelectProfile[client]=false;
			Format(g_szProfileName[client], MAX_NAME_LENGTH, "");
			for (new i = 1; i < 20; i++)
			{
				GetCmdArg(i, szArg, MAX_NAME_LENGTH);
				if (!StrEqual(szArg, "", false))
				{
					if (i==1)
						Format( g_szProfileName[client], MAX_NAME_LENGTH, "%s", szArg); 
					else
						Format( g_szProfileName[client], MAX_NAME_LENGTH, "%s %s",  g_szProfileName[client], szArg); 
				}
			}
		}
	}
	//player ingame? new name?
	if (args != 0 && !StrEqual(g_szProfileName[client],"",false))
	{
		new bool:bPlayerFound=false;
		decl String:szSteamId2[32];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szName2[MAX_NAME_LENGTH];		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szName, MAX_NAME_LENGTH);		
				StringToUpper(szName);
				Format(szName2, MAX_NAME_LENGTH, "%s", g_szProfileName[client]); 
				if ((StrContains(szName, szName2) != -1))
				{
					bPlayerFound=true;
					GetClientAuthString(i, szSteamId2, 32);
					continue;
				}
			}
		}
		if (bPlayerFound)
			db_viewPlayerRank(client, szSteamId2);
		else
		{
			if(!g_bProfileSelected[client])
				db_viewPlayerAll(client, g_szProfileName[client]);
			else
				db_ReOpenSelectedProfile(client, g_szProfileName[client]);
		}
	}
}

public ProfileSelectMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				if(StrEqual(info,szPlayerName))
				{
					Format(g_szProfileName[param1], MAX_NAME_LENGTH, "%s", szPlayerName); 
					decl String:szSteamId[32];
					GetClientAuthString(i, szSteamId, 32);	
					db_viewPlayerRank(param1, szSteamId);
				}
			}
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		if (IsValidClient(param1))
			g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		if (IsValidClient(param1))
			g_bSelectProfile[param1]=false;
		CloseHandle(menu);
	}
}

public Action:Client_AutoBhop(client, args) 
{ 	
	AutoBhop(client);
	if (g_bAutoBhop2)
	{
		if (!g_bAutoBhopClient[client])
			PrintToChat(client, "%t", "AutoBhop2",MOSSGREEN,WHITE);
		else
			PrintToChat(client, "%t", "AutoBhop1",MOSSGREEN,WHITE);
	}
	return Plugin_Handled;
} 

public AutoBhop(client)
{
	if (!g_bAutoBhop2)
		PrintToChat(client, "%t", "AutoBhop3",MOSSGREEN,WHITE);
	if (!g_bAutoBhopClient[client])
		g_bAutoBhopClient[client] = true; 
	else
		g_bAutoBhopClient[client] = false; 
}

public Action:Client_Hide(client, args) 
{ 	
	HideMethod(client)
	if (!g_bHide[client])
		PrintToChat(client, "%t", "Hide1",MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Hide2",MOSSGREEN,WHITE);
	return Plugin_Handled;
} 

public HideMethod(client)
{
	if (!g_bHide[client])
		g_bHide[client] = true; 
	else
		g_bHide[client] = false; 
}

public Action:Client_Latest(client, args)
{
	db_ViewLatestRecords(client);
	return Plugin_Handled;
}

public Action:Client_Showsettings(client, args)
{
	ShowSrvSettings(client);
	return Plugin_Handled;
}

public Action:Client_Help(client, args)
{
	HelpPanel(client);
	return Plugin_Handled;
}

public Action:Client_Ranks(client, args)
{
	if (IsValidClient(client))
		PrintToChat(client, "[%cKZ%c] %c%s (0p)  %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)",
		MOSSGREEN,WHITE, WHITE, g_szSkillGroups[0],WHITE,g_szSkillGroups[1],WHITE,g_pr_rank_Percentage[1], GRAY, g_szSkillGroups[2],GRAY,g_pr_rank_Percentage[2],LIGHTBLUE, 
		g_szSkillGroups[3],LIGHTBLUE,g_pr_rank_Percentage[3],BLUE, g_szSkillGroups[4],BLUE,g_pr_rank_Percentage[4],DARKBLUE,g_szSkillGroups[5],DARKBLUE,g_pr_rank_Percentage[5],
		PINK,g_szSkillGroups[6],PINK,g_pr_rank_Percentage[6],LIGHTRED,g_szSkillGroups[7],LIGHTRED,g_pr_rank_Percentage[7],DARKRED,g_szSkillGroups[8],DARKRED,g_pr_rank_Percentage[8]);
	return Plugin_Handled;
}

public Action:Client_Profile(client, args)
{
	ProfileMenu(client,args);
	return Plugin_Handled;
}

public Action:Client_Compare(client, args)
{
	CompareMenu(client,args);
	return Plugin_Handled;
}

public Action:Client_Start(client, args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) == 1) 
		return Plugin_Handled;
	
	new Float: e_time = GetEngineTime();
	new Float: diff = e_time - g_fStartCommandUsed_LastTime[client];
	if (diff < 0.8)
		return Plugin_Handled;	
		
	//spawn at Timer
	if (g_bRespawnAtTimer[client]==true)
	{
		g_bValidTeleport[client]=true;
		TeleportEntity(client, g_fPlayerCordsRestart[client],g_fPlayerAnglesRestart[client], Float:{0.0,0.0,-100.0});		
	}
	else //else spawn at spawnpoint
		CS_RespawnPlayer(client);	
		
	if (g_bAutoTimer)
		CL_OnStartTimerPress(client);
		
	g_js_bPlayerJumped[client] = false;
	g_bNoClip[client] = false;
	
	if(StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"surf"))
		CL_OnStartTimerPress(client);
	return Plugin_Handled;	
}

public Action:Client_Pause(client, args) 
{
	if (GetClientTeam(client) == 1) return Plugin_Handled;
	PauseMethod(client);	
	if (g_bPause[client]==false)
		PrintToChat(client, "%t", "Pause2",MOSSGREEN, WHITE, RED, WHITE);
	else
		PrintToChat(client, "%t", "Pause3",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public PauseMethod(client)
{
	if (GetClientTeam(client) == 1) return;
	if (g_bPause[client]==false && IsValidEntity(client))
	{
		if (g_bPauseServerside==false && client != g_ProBot && client != g_TpBot) 
		{
			PrintToChat(client, "%t", "Pause1",MOSSGREEN, WHITE,RED,WHITE);
			return;
		}
		g_bPause[client]=true;		
		new Float:fVel[3];
		fVel[0] = 0.000000;
		fVel[1] = 0.000000;
		fVel[2] = 0.000000;
		SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
		SetEntityMoveType(client, MOVETYPE_NONE);
		//Timer enabled?
		if(g_bTimeractivated[client] == true)
		{
			g_fStartPauseTime[client] = GetEngineTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];	
		}
		SetEntityRenderMode(client, RENDER_NONE);
		SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	else
	{
		if(g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
		{
			g_fPauseTime[client] = GetEngineTime() - g_fStartPauseTime[client];
		}
		g_bNoClip[client]=false;
		g_bPause[client]=false;
		if (!g_bRoundEnd)
			SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_NORMAL);
		if (g_bNoBlock)
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 5, true);
		TeleportEntity(client, NULL_VECTOR,NULL_VECTOR, Float:{0.0,0.0,-100.0});
	}
}

public Action:Client_CPMessage(client, args) 
{
	CPMessage(client);
	if (g_bCPTextMessage[client] == true)
		PrintToChat(client, "%t", "CpMessage1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "CpMessage2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}


public CPMessage(client)
{
	if (g_bCPTextMessage[client] == true)
		g_bCPTextMessage[client] = false;
	else
		g_bCPTextMessage[client] = true;
}


public Action:Client_HideSpecs(client, args) 
{
	HideSpecs(client);
	if (g_bShowSpecs[client] == true)
		PrintToChat(client, "%t", "HideSpecs1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideSpecs2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public HideSpecs(client)
{
	if (g_bShowSpecs[client] == true)
		g_bShowSpecs[client] = false;
	else
		g_bShowSpecs[client] = true;
}

public Action:Client_AdvClimbersMenu(client, args) 
{
	AdvClimbersMenu(client);
	if (g_bAdvancedClimbersMenu[client])
		PrintToChat(client, "%t", "AdvClimbersMenu1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "AdvClimbersMenu2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}


public AdvClimbersMenu(client)
{
	if (g_bAdvancedClimbersMenu[client])
		g_bAdvancedClimbersMenu[client] = false;
	else
		g_bAdvancedClimbersMenu[client] = true;
}


public Action:Client_Showtime(client, args) 
{
	ShowTime(client)
	if (g_bShowTime[client])
		PrintToChat(client, "%t", "Showtime1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "Showtime2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public ShowTime(client)
{
	if (g_bShowTime[client])
		g_bShowTime[client] = false;
	else
		g_bShowTime[client] = true;
}

public Action:Client_DisableGoTo(client, args) 
{
	DisableGoTo(client);
	if (g_bGoToClient[client])
		PrintToChat(client, "%t", "DisableGoto1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "DisableGoto2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}


public DisableGoTo(client)
{
	if (g_bGoToClient[client])
		g_bGoToClient[client]=false;
	else
		g_bGoToClient[client]=true;
}
	
public GoToMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		for (new i = 1; i <= MaxClients; i++)
		{	
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
				if(StrEqual(info,szPlayerName))
				{
					GotoMethod(param1,i);
				}
				else
				{
					if (i == MaxClients)
					{
						PrintToChat(param1, "%t", "Goto4", MOSSGREEN,WHITE, szPlayerName);
						Client_GoTo(param1,0);
					}
				}
			}
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;	
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public GotoMethod(client, i)
{	
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	decl String:szTargetName[MAX_NAME_LENGTH];
	GetClientName(i, szTargetName, MAX_NAME_LENGTH);	
	if (GetEntityFlags(i) & FL_ONGROUND)
	{
		new ducked = GetEntProp(i, Prop_Send, "m_bDucked");
		new ducking = GetEntProp(i, Prop_Send, "m_bDucking");
		if (!(GetClientButtons(client) & IN_DUCK) && ducked == 0 && ducking == 0)
		{
			g_js_bPlayerJumped[client] = false;
			new Float:position[3];
			new Float:angles[3];
			GetClientAbsOrigin(i,position);
			GetClientEyeAngles(i,angles);
			new Float:fVelocity[3];
			fVelocity[0] = 0.0;
			fVelocity[1] = 0.0;
			fVelocity[2] = 0.0;
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			TeleportEntity(client, position,angles, Float:{0.0,0.0,-100.0});
			decl String:szClientName[MAX_NAME_LENGTH];
			GetClientName(client, szClientName, MAX_NAME_LENGTH);	
			PrintToChat(i, "%t", "Goto5", MOSSGREEN,WHITE, szClientName);
		}
		else
		{
			PrintToChat(client, "%t", "Goto6", MOSSGREEN,WHITE, szTargetName);
			Client_GoTo(client,0);
		}
	}
	else
	{
		PrintToChat(client, "%t", "Goto7", MOSSGREEN,WHITE, szTargetName);
		Client_GoTo(client,0);
	}
}

public Action:Client_GoTo(client, args) 
{
	if (!g_bGoToServer)
		PrintToChat(client, "%t", "Goto1",MOSSGREEN,WHITE,RED,WHITE);
	else
	if (!g_bNoBlock)
		PrintToChat(client, "%t", "Goto2",MOSSGREEN,WHITE);
	else
	if (g_bTimeractivated[client])
		PrintToChat(client, "%t", "Goto3",MOSSGREEN,WHITE, GREEN,WHITE);
	else
	{
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szOrgTargetName[MAX_NAME_LENGTH];
		decl String:szTargetName[MAX_NAME_LENGTH];
		decl String:szArg[MAX_NAME_LENGTH];
		if (args==0)
		{
			new Handle:menu = CreateMenu(GoToMenuHandler);
			SetMenuTitle(menu, "goto menu\nselect a player:");
			new playerCount=0;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(client))
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);	
					AddMenuItem(menu, szPlayerName, szPlayerName);	
					playerCount++;
				}
			}
			if (playerCount>0)
			{
				g_bMenuOpen[client]=true;
				SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);		
			}
			else
			{
				CloseHandle(menu);
				PrintToChat(client, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);
			}
		}
		else 
		{
			for (new i = 1; i < 20; i++)
			{
				GetCmdArg(i, szArg, MAX_NAME_LENGTH);
				if (!StrEqual(szArg, "", false))
				{
					if (i==1)
						Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg); 
					else
						Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg); 
				}
			}	
			Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName); 
			StringToUpper(szTargetName);	
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != client )
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);		
					StringToUpper(szPlayerName);
					if ((StrContains(szPlayerName, szTargetName) != -1))
					{
						GotoMethod(client,i);
						return Plugin_Handled;
					}
				}
			}	
			PrintToChat(client, "%t", "PlayerNotFound",MOSSGREEN,WHITE, szOrgTargetName);	
		}
	}
	return Plugin_Handled;
}

public Action:Client_StrafeSync(client, args) 
{
	StrafeSync(client);
	if (g_bStrafeSync[client])
		PrintToChat(client, "%t", "StrafeSync1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "StrafeSync2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public StrafeSync(client)
{
	if (g_bStrafeSync[client])
		g_bStrafeSync[client] = false;
	else
		g_bStrafeSync[client] = true;
}

public Action:Client_ClimbersMenuSounds(client, args) 
{
	ClimbersMenuSounds(client);
	if (g_bClimbersMenuSounds[client])
		PrintToChat(client, "%t", "ClimbersMenuSounds1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "ClimbersMenuSounds2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public ClimbersMenuSounds(client)
{
	if (g_bClimbersMenuSounds[client])
		g_bClimbersMenuSounds[client] = false;
	else
		g_bClimbersMenuSounds[client] = true;
}
		
public Action:Client_QuakeSounds(client, args) 
{
	QuakeSounds(client);
	if (g_bEnableQuakeSounds[client])
		PrintToChat(client, "%t", "QuakeSounds1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "QuakeSounds2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public QuakeSounds(client)
{
	if (g_bEnableQuakeSounds[client])
		g_bEnableQuakeSounds[client] = false;
	else
		g_bEnableQuakeSounds[client] = true;
}
public Action:Client_InfoPanel(client, args) 
{
	InfoPanel(client);
	if (g_bInfoPanel[client] == true)
		PrintToChat(client, "%t", "Info1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Info2", MOSSGREEN,WHITE);	
	return Plugin_Handled;
}

public InfoPanel(client)
{
	if (g_bInfoPanel[client])
		g_bInfoPanel[client] = false;
	else
	{
		g_bInfoPanel[client] = true;	
	}
}
/*public Action:Client_Shownames(client, args) 
{
	ShowNames(client);
	if (g_bShowNames[client])
		PrintToChat(client, "%t", "ShowNames1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "ShowNames2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public ShowNames(client)
{
	if (g_bShowNames[client])
		g_bShowNames[client] = false;
	else
		g_bShowNames[client] = true;		
}*/

public Action:Client_Colorchat(client, args) 
{
	ColorChat(client);
	if (g_bColorChat[client])
		PrintToChat(client, "%t", "Colorchat1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Colorchat2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public ColorChat(client)
{
	if (g_bColorChat[client])
		g_bColorChat[client] = false;
	else
		g_bColorChat[client] = true;
}

public Action:Client_Stop(client, args)
{
	if (g_bTimeractivated[client])
	{
		g_bClimbersMenuOpen[client]=false;
		PlayerPanel(client);
		g_bTimeractivated[client] = false;	
		g_fStartTime[client] = -1.0;
		g_fCurrentRunTime[client] = -1.0;		
		PrintToChat(client, "%t", "TimerStopped1",MOSSGREEN,WHITE);
		
		//zipcore anti strafe hack
		if(g_PlayerStates[client][bOn])
		{
			g_PlayerStates[client][bOn] = false;
			ComputeStrafes(client);
		}
	}
	return Plugin_Handled;
}

public Action:Client_lj(client, args)
{
	db_selectTopLj(client);
	return Plugin_Handled;
}

public Action:Client_bhop(client, args)
{
	db_selectTopBhop(client);
	return Plugin_Handled;
}

public SaveClientLocation(client)
{
	if (IsFakeClient(client) || !IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) == 1) 
		return;
			
		
	if (!g_bChallenge_Checkpoints[client] && g_bChallenge[client])
	{
		PrintToChat(client, "%t", "NoCpsDuringChallenge", RED,WHITE);
		return;
	}

	
	//if player on ground
	if(GetEntDataEnt2(client, FindSendPropOffs("CBasePlayer", "m_hGroundEntity")) != -1)
	{
		if (CPLIMIT == g_CounterCp[client]) 
		{
			g_CurrentCp[client] = -1;
			g_CounterCp[client] = 0;
		}
		
		//on bhop block?
		if (g_bOnBhopPlattform[client])
		{
			if (g_bClimbersMenuSounds[client])
				EmitSoundToClient(client,"buttons/button10.wav",client);
			PrintToChat(client, "%t", "CheckpointsNotonBhopPlattforms", MOSSGREEN,WHITE,RED);
			return;
		}
		
		//save coordinates for new cp
		GetClientAbsOrigin(client,g_fPlayerCords[client][g_CounterCp[client]]);
		GetClientEyeAngles(client,g_fPlayerAngles[client][g_CounterCp[client]]);

		//increase counters
		g_CurrentCp[client] = g_CounterCp[client];
		g_CounterCp[client]++;
		g_OverallCp[client]++;		
		if (g_bClimbersMenuSounds[client])
			EmitSoundToClient(client,"buttons/blip1.wav",client);
		if (g_bCPTextMessage[client])
			PrintToChat(client, "%t", "CheckpointSaved", MOSSGREEN,WHITE,GRAY);
	}
	else
	{
		if (g_bClimbersMenuSounds[client])
			EmitSoundToClient(client,"buttons/button10.wav",client);
		PrintToChat(client, "%t", "CheckpointsNotinAir", MOSSGREEN,WHITE,RED);
	}
}

public TeleClient(client,pos)
{
	if (!IsValidClient(client) || IsFakeClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) == 1 || g_CurrentCp[client] == -1) 
		return;
		
	if (!g_bAllowCheckpoints)
	{
		PrintToChat(client, "%t", "CheckpointsDisabled", MOSSGREEN,WHITE);
		return;
	}
	new current = g_CurrentCp[client];
	new CounterCp = g_CounterCp[client];
	if (g_OverallCp[client] > CPLIMIT)
	{
		//if on last slot and next
		if(current == CPLIMIT-1 && pos == 1)
		{
			//reset to first
			g_CurrentCp[client] = -1;
			current = -1;
		}
		//if on first slot and previous
		if(current == 0  && pos == -1)
		{
			//reset to last
			g_CurrentCp[client] = CPLIMIT;
			current = CPLIMIT;
		}	
	}
	else
	{
		//if on last slot and next
		if(current == CounterCp-1 && pos == 1)
		{
			//reset to first
			g_CurrentCp[client] = -1;
			current = -1;
		}
		//if on first slot and previous
		if(current == 0  && pos == -1)
		{
			//reset to last
			g_CurrentCp[client] = CounterCp;
			current = CounterCp;
		}
	}
			
	new actual = current+pos;
	if(actual < 0 || actual > g_OverallCp[client])
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
	else
	{ 
		g_js_bPlayerJumped[client] = false;
		g_js_StrafeCount[client] = 0;
		g_js_GroundFrames[client] = 0;
		g_js_MultiBhop_Count[client] = 1;
		g_OverallTp[client]++;
		new Float:fVelocity[3];
		fVelocity[0] = 0.0;
		fVelocity[1] = 0.0;
		fVelocity[2] = 0.0;
		if (IsValidClient(client))
		{			
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			

			GetClientAbsOrigin(client, g_fPlayerCordsUndoTp[client]);
			GetClientEyeAngles(client,g_fPlayerAnglesUndoTp[client]);
			g_bValidTeleport[client]=true;
			if (!(GetEntityFlags(client) & FL_ONGROUND))
				g_js_LeetJump_Count[client] = 0;
			TeleportEntity(client, g_fPlayerCords[client][actual],g_fPlayerAngles[client][actual], Float:{0.0,0.0,-100.0});
			g_CurrentCp[client] += pos;
			if (g_bClimbersMenuSounds[client]==true)
				EmitSoundToClient(client,"buttons/blip1.wav",client);
		}
	}		
}

public Action_NoClip(client)
{    
	if(IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		new team = GetClientTeam(client);
		if (team==2 || team==3)
		{
			new MoveType:mt = GetEntityMoveType(client);   
			if(mt == MOVETYPE_WALK)
			{
				if (g_bTimeractivated[client])
				{
					g_bTimeractivated[client] = false;
					g_fStartTime[client] = -1.0;
					g_fCurrentRunTime[client] = -1.0;
				}				
				g_fLastTimeNoClipUsed[client] = GetEngineTime();
				ResetJump(client);
				SetEntityMoveType(client, MOVETYPE_NOCLIP);
				SetEntityRenderMode(client , RENDER_NONE); 
				SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				g_bNoClip[client] = true;
			}
		}
	}
	return;
}  

public Action_UnNoClip(client)
{    
	if(IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		new team = GetClientTeam(client);
		if (team==2 || team==3)
		{
			new MoveType:mt = GetEntityMoveType(client);   
			if(mt == MOVETYPE_NOCLIP)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntityRenderMode(client, RENDER_NORMAL);
				if(g_bNoBlock)
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				else
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
				g_bNoClip[client] = false;
			}
		}
	}
	return;
}  

public ClimbersMenu(client)
{
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1 || !g_bAllowCheckpoints)
	{
		g_bClimbersMenuOpen[client] = false;
		return;
	}
	g_bClimbersMenuOpen[client] = true;
	decl String:buffer[32];
	decl String:title[128];
	g_hclimbersmenu[client] = CreateMenu(ClimbersMenuHandler);
	if (g_bTimeractivated[client])
	{
		GetcurrentRunTime(client);
		SetMenuTitle(g_hclimbersmenu[client], g_szMenuTitleRun[client]);
				
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu1", client, g_OverallCp[client]);
		AddMenuItem(g_hclimbersmenu[client], "!save", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu2", client, g_OverallTp[client]);	
		AddMenuItem(g_hclimbersmenu[client], "!tele", buffer);
		if (g_bAdvancedClimbersMenu[client])
		{	
			if (g_OverallCp[client] > 1)
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer);		
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);			
			}
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu5", client);
			if(g_fPlayerCordsUndoTp[client][0] == 0.0 && g_fPlayerCordsUndoTp[client][1] == 0.0 && g_fPlayerCordsUndoTp[client][2] == 0.0)
				AddMenuItem(g_hclimbersmenu[client], "!undo", buffer,ITEMDRAW_DISABLED);
			else
				AddMenuItem(g_hclimbersmenu[client], "!undo", buffer);
			if (g_bPause[client])
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu7", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu6", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}	
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);
			AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		}	
		else
		{
			if (g_bPause[client])
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu7", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu6", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}	
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);
			AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		}
	}
	else
	{
		Format(title, 128, "%T", "ClimbersMenu10", client, g_szPlayerPanelText[client],GetSpeed(client));
		SetMenuTitle(g_hclimbersmenu[client], title);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu11", client);
		AddMenuItem(g_hclimbersmenu[client], "!save", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu12", client);
		AddMenuItem(g_hclimbersmenu[client], "!tele", buffer);
		if (g_bAdvancedClimbersMenu[client])
		{	
			Format(title, 128, "%T", "ClimbersMenu10", client, g_szPlayerPanelText[client],GetSpeed(client));
			SetMenuTitle(g_hclimbersmenu[client], title);		
			if (g_OverallCp[client] > 1)
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer);	
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);	
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);			
			}
		}
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);	
		AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu9", client);	
		AddMenuItem(g_hclimbersmenu[client], "!Options", buffer);
	}
	SetMenuPagination(g_hclimbersmenu[client], MENU_NO_PAGINATION); 
	SetMenuOptionFlags(g_hclimbersmenu[client], MENUFLAG_BUTTON_EXIT);
	DisplayMenu(g_hclimbersmenu[client], client, MENU_TIME_FOREVER);
}



public ClimbersMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		if (g_bTimeractivated[param1])
		{
			if (g_bAdvancedClimbersMenu[param1])
			{
				switch(param2)
				{
					case 0: SaveClientLocation(param1);
					case 1: TeleClient(param1,0);
					case 2: Client_Prev(param1,0);
					case 3: Client_Next(param1,0); 
					case 4: Client_Undo(param1,0); 
					case 5: PauseMethod(param1);
					case 6: Client_Start(param1, 0);
				}
			}
			else
				switch(param2)
				{
					case 0: SaveClientLocation(param1);
					case 1: TeleClient(param1,0);
					case 2: PauseMethod(param1);
					case 3: Client_Start(param1, 0);
				}
		}
		else
		{
			if (g_bAdvancedClimbersMenu[param1])
			switch(param2)
			{
				case 0: SaveClientLocation(param1);
				case 1: TeleClient(param1,0);
				case 2: Client_Prev(param1,0);
				case 3: Client_Next(param1,0); 
				case 4: Client_Start(param1, 0);
				case 5: OptionMenu(param1);
			}	
			else
				switch(param2)
				{
					case 0: SaveClientLocation(param1);
					case 1: TeleClient(param1,0);
					case 2: Client_Start(param1, 0);
					case 3: OptionMenu(param1);
				}		
		}
		//note: options menu priority
		if (g_bTimeractivated[param1] == false && param2 == 5 && g_bAdvancedClimbersMenu[param1])
		{
		}
		else
		if (g_bTimeractivated[param1] == false && param2 == 3 && !g_bAdvancedClimbersMenu[param1])
		{
		}		
		else
				ClimbersMenu(param1);
	}	
	else
		if(action == MenuAction_Cancel)
		{
			if (param2 == -3)
				g_bClimbersMenuOpen[param1]=false;
		}
		else 
			if (action == MenuAction_End)
			{	
				CloseHandle(menu);
			}
}


public TopMenu(client)
{
	g_MenuLevel[client]=-1;
	g_bTopMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:topmenu = CreateMenu(TopMenuHandler);
	SetMenuTitle(topmenu, "Top Menu");
	if (g_bPointSystem)
		AddMenuItem(topmenu, "Top 100 Players", "Top 100 Players");
	AddMenuItem(topmenu, "Top 5 Challengers", "Top 5 Challengers");
	AddMenuItem(topmenu, "Top 5 Record Holders", "Top 5 Pro Record Holders");
	AddMenuItem(topmenu, "Top 5 Record Holders", "Top 5 TP Record Holders");
	AddMenuItem(topmenu, "Map Top", "Map Top");	
	if (g_bJumpStats)
		AddMenuItem(topmenu, "Jump Top", "Jump Top");
	SetMenuOptionFlags(topmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu, client, MENU_TIME_FOREVER);
}

public TopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		if(g_bPointSystem)
		{
			switch(param2)
			{
				case 0: db_selectTopPlayers(param1);
				case 1: db_selectTopChallengers(param1);
				case 2: db_selectTopProRecordHolders(param1);
				case 3: db_selectTopTpRecordHolders(param1);
				case 4: MapTopMenu(param1);
				case 5: JumpTopMenu(param1);
			}
			if (param2==5 && !g_bJumpStats)
				PrintToChat(param1, "%t", "JumpstatsDisabled",MOSSGREEN,WHITE);
		}
		else
		{
			switch(param2)
			{
				case 0: db_selectTopChallengers(param1);
				case 1: db_selectTopProRecordHolders(param1);
				case 2: db_selectTopTpRecordHolders(param1);
				case 3: MapTopMenu(param1);
				case 4: JumpTopMenu(param1);
			}
			if (param2==4 && !g_bJumpStats)
				PrintToChat(param1, "%t", "JumpStatsDisabled",MOSSGREEN,WHITE);
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			g_bTopMenuOpen[param1]=false;	
		}
		else 
			if (action == MenuAction_End)
			{	
				CloseHandle(menu);
			}
}

public MapTopMenu(client)
{
	new Handle:topmenu2 = CreateMenu(MapTopMenuHandler);
	SetMenuTitle(topmenu2, "Map Top");
		
	if (g_bAllowCheckpoints)
	{
		AddMenuItem(topmenu2, "!topclimbers", "Top 50 Overall");
		AddMenuItem(topmenu2, "!proclimbers", "Top 20 Pro");
		AddMenuItem(topmenu2, "!cpclimbers", "Top 20 TP");
	}
	else
	{
		AddMenuItem(topmenu2, "!topclimbers", "Top 50 Overall");
		AddMenuItem(topmenu2, "!proclimbers", "Top 20 Pro",ITEMDRAW_DISABLED);
		AddMenuItem(topmenu2, "!cpclimbers", "Top 20 TP",ITEMDRAW_DISABLED);
	}
	SetMenuOptionFlags(topmenu2, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu2, client, MENU_TIME_FOREVER);
}

public MapTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_selectTopClimbers(param1,g_szMapName);
			case 1: db_selectProClimbers(param1);
			case 2: db_selectTPClimbers(param1);
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			TopMenu(param1);
		}
		else 
			if (action == MenuAction_End)
			{	
				CloseHandle(menu);
			}
}

public JumpTopMenu(client)
{
	g_bTopMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:topmenu2 = CreateMenu(JumpTopMenuHandler);
	SetMenuTitle(topmenu2, "Jump Top");
	AddMenuItem(topmenu2, "!lj", "Top 20 Longjump");
	AddMenuItem(topmenu2, "!ljblock", "Top 20 Block Longjump");
	AddMenuItem(topmenu2, "!bhop", "Top 20 Bunnyhop");	
	AddMenuItem(topmenu2, "!multibhop", "Top 20 Multi-Bunnyhop");
	AddMenuItem(topmenu2, "!dropbhop", "Top 20 Drop-Bunnyhop");	
	AddMenuItem(topmenu2, "!wj", "Top 20 Weirdjump");
	SetMenuOptionFlags(topmenu2, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu2, client, MENU_TIME_FOREVER);
}

public JumpTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_selectTopLj(param1);
			case 1: db_selectTopLjBlock(param1);
			case 2: db_selectTopBhop(param1);
			case 3: db_selectTopMultiBhop(param1);
			case 4: db_selectTopDropBhop(param1);
			case 5: db_selectTopWj(param1);
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		TopMenu(param1);
	}
	else if (action == MenuAction_End)
	{	
		CloseHandle(menu);
	}
}

public HelpPanel(client)
{
	g_bMenuOpen[client] = true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:panel = CreatePanel();
	decl String:title[64];
	Format(title, 64, "KZ Timer Help (1/3) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, title);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!helpmenu - opens this menu");
	DrawPanelText(panel, "!menu - climbers menu");
	DrawPanelText(panel, "!options - options menu");	
	DrawPanelText(panel, "!top - top menu");
	DrawPanelText(panel, "!latest - latest local records");
	DrawPanelText(panel, "!profile [<name>] - player profile");
	DrawPanelText(panel, "!checkpoint / !gocheck - checkpoint / gocheck");
	DrawPanelText(panel, "!prev / !next - previous or next checkpoint");
	DrawPanelText(panel, "!undo - undoes your last gocheck");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanelHandler, 10000);
	CloseHandle(panel);
}

public HelpPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel2(param1);
		else
		{
			g_bMenuOpen[param1] = false;
			ClimbersMenu(param1);		
		}
	}
}

public HelpPanel2(client)
{
	new Handle:panel = CreatePanel();
	decl String:szTmp[64];
	Format(szTmp, 64, "KZ Timer Help (2/3) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ")	
	DrawPanelText(panel, "!start/!r - go back to start");
	DrawPanelText(panel, "!stop - stops your timer");
	DrawPanelText(panel, "!pause - on/off client pause");	
	DrawPanelText(panel, "!usp - spawns a usp");
	DrawPanelText(panel, "!challenge - starts a challenge/race against someone");	
	DrawPanelText(panel, "!spec [<name>] - selects a player you want to watch");	
	DrawPanelText(panel, "!goto [<name>] - teleports you to a given player");
	DrawPanelText(panel, "!compare [<name>] - compares your challenge results with a given player");
	DrawPanelText(panel, "!showsettings - shows plugin settings");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel2Handler, 10000);
	CloseHandle(panel);
}
public HelpPanel2Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel(param1);
		else
			if(param2==2)
				HelpPanel3(param1);
			else
			{
				g_bMenuOpen[param1] = false;
				ClimbersMenu(param1);
			}
	}
}

public HelpPanel3(client)
{
	new Handle:panel = CreatePanel();
	decl String:szTmp[64];
	Format(szTmp, 64, "KZ Timer Help (3/3) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");	
	DrawPanelText(panel, "!maptop <mapname> - displays map top for a given map");
	DrawPanelText(panel, "!bhopcheck <name> - checks bhop stats for a given player");
	DrawPanelText(panel, "!ljblock - registers a longjump block");
	DrawPanelText(panel, "!flashlight - on/off flashlight");
	DrawPanelText(panel, "!ranks - prints available ranks into chat");
	DrawPanelText(panel, "!measure - allows you to measure the distance between 2 points");
	DrawPanelText(panel, "!language - select your language");
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "noclip bind: bind KEY +noclip");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel3Handler, 10000);
	CloseHandle(panel);
}
public HelpPanel3Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel2(param1);
		else
		{
			g_bMenuOpen[param1] = false;
			ClimbersMenu(param1);
		}
	}
}

public ShowSrvSettings(client)
{
	PrintToConsole(client, " ");
	PrintToConsole(client, "-----------------");
	PrintToConsole(client, "KZ Timer settings");
	PrintToConsole(client, "-----------------");
	PrintToConsole(client, "kz_admin_clantag %b", g_bAdminClantag);
	
	
	PrintToConsole(client, "kz_anticheat_ban_duration %.1fh", g_fBanDuration);
	PrintToConsole(client, "kz_auto_bhop %i (bhop_ & surf_ maps)", g_bAutoBhop);
	PrintToConsole(client, "kz_auto_timer %i", g_bAutoTimer);
	PrintToConsole(client, "kz_autoheal %i", g_Autohealing_Hp);
	PrintToConsole(client, "kz_autorespawn %b", g_bAutoRespawn);
	PrintToConsole(client, "kz_checkpoints %b", g_bAllowCheckpoints);
	PrintToConsole(client, "kz_checkpoints_on_bhop_plattforms %b", g_bAllowCpOnBhopPlattforms);
	PrintToConsole(client, "kz_clean_weapons %b", g_bCleanWeapons);
	PrintToConsole(client, "kz_colored_chatranks %b", g_bColoredChatRanks);
	PrintToConsole(client, "kz_connect_msg %b", g_bConnectMsg);
	PrintToConsole(client, "kz_country_tag %b", g_bCountry);
	PrintToConsole(client, "kz_custom_models %b", g_bPlayerSkinChange);	
	PrintToConsole(client, "kz_dist_min_lj %.1f", g_dist_good_lj);
	PrintToConsole(client, "kz_dist_pro_lj %.1f", g_dist_pro_lj);
	PrintToConsole(client, "kz_dist_leet_lj %.1f", g_dist_leet_lj);
	PrintToConsole(client, "kz_dist_min_bhop %.1f", g_dist_good_bhop);
	PrintToConsole(client, "kz_dist_pro_bhop %.1f", g_dist_pro_bhop);
	PrintToConsole(client, "kz_dist_leet_bhop %.1f", g_dist_leet_bhop);
	PrintToConsole(client, "kz_dist_min_multibhop %.1f", g_dist_good_multibhop);
	PrintToConsole(client, "kz_dist_pro_multibhop %.1f", g_dist_pro_multibhop);
	PrintToConsole(client, "kz_dist_leet_multibhop %.1f", g_dist_leet_multibhop);
	PrintToConsole(client, "kz_dist_min_dropbhop %.1f", g_dist_good_dropbhop);
	PrintToConsole(client, "kz_dist_pro_dropbhop %.1f", g_dist_pro_dropbhop);
	PrintToConsole(client, "kz_dist_leet_dropbhop %.1f", g_dist_leet_dropbhop);
	PrintToConsole(client, "kz_dist_min_wj %.1f", g_dist_good_weird);
	PrintToConsole(client, "kz_dist_pro_wj %.1f", g_dist_pro_weird);
	PrintToConsole(client, "kz_dist_leet_wj %.1f", g_dist_leet_weird);
	PrintToConsole(client, "kz_fps_check %b", g_bfpsCheck);	
	PrintToConsole(client, "kz_godmode %b", g_bgodmode);
	PrintToConsole(client, "kz_goto %b", g_bGoToServer);
	PrintToConsole(client, "kz_info_bot %b", g_bInfoBot);
	PrintToConsole(client, "kz_jumpstats %b", g_bJumpStats);
	PrintToConsole(client, "kz_noclip %b", g_bNoClipS);
	PrintToConsole(client, "kz_prespeed_cap %.1f (speed-limiter)", g_fBhopSpeedCap);
	PrintToConsole(client, "kz_map_end %b", g_bMapEnd);
	PrintToConsole(client, "kz_max_prespeed_bhop_dropbhop %.1f", g_fMaxBhopPreSpeed);
	PrintToConsole(client, "kz_multiplayer_bhop %b", g_bMultiplayerBhop);
	PrintToConsole(client, "kz_noblock %b", g_bNoBlock);
	PrintToConsole(client, "kz_pause %b", g_bPauseServerside);
	PrintToConsole(client, "kz_point_system %b", g_bPointSystem);
	PrintToConsole(client, "kz_prestrafe %b", g_bPreStrafe);
	PrintToConsole(client, "kz_pro_mode %b", g_bProMode);
	PrintToConsole(client, "kz_ranking_extra_points_firsttime %i", g_ExtraPoints2);
	PrintToConsole(client, "kz_ranking_extra_points_improvements %i", g_ExtraPoints);
	PrintToConsole(client, "kz_recalc_top100_on_mapstart %b", g_bRecalcTop100);	
	PrintToConsole(client, "kz_replay_bot %b", g_bReplayBot);
	PrintToConsole(client, "kz_restore %b", g_bRestore);
	PrintToConsole(client, "kz_settings_enforcer %b", g_bEnforcer);
	PrintToConsole(client, "kz_use_radio %b", g_bRadioCommands);
	PrintToConsole(client, "kz_vip_clantag %b", g_bVipClantag);
	PrintToConsole(client, "---------------");
	PrintToConsole(client, "Server settings");
	PrintToConsole(client, "---------------");
	new Handle:hTmp;	
	hTmp = FindConVar("sv_airaccelerate");
	new Float: flAA = GetConVarFloat(hTmp);			
	hTmp = FindConVar("sv_accelerate");
	new Float: flA = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_friction");
	new Float: flFriction = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_gravity");
	new Float: flGravity = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_enablebunnyhopping");
	new iBhop = GetConVarInt(hTmp);	
	hTmp = FindConVar("sv_maxspeed");
	new Float: flMaxSpeed = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_maxvelocity");
	new Float: flMaxVel = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_staminalandcost");
	new Float: flStamLand = GetConVarFloat(hTmp);	
	hTmp = FindConVar("sv_staminajumpcost");
	new Float: flStamJump = GetConVarFloat(hTmp);		
	hTmp = FindConVar("sv_wateraccelerate");
	new Float: flWaterA = GetConVarFloat(hTmp);
	if (hTmp != INVALID_HANDLE)
		CloseHandle(hTmp);		
	PrintToConsole(client, "sv_accelerate %.1f", flA);	
	PrintToConsole(client, "sv_airaccelerate %.1f", flAA);
	PrintToConsole(client, "sv_friction %.1f", flFriction);
	PrintToConsole(client, "sv_gravity %.1f", flGravity);
	PrintToConsole(client, "sv_enablebunnyhopping %i", iBhop);
	PrintToConsole(client, "sv_maxspeed %.1f", flMaxSpeed);
	PrintToConsole(client, "sv_maxvelocity %.1f", flMaxVel);
	PrintToConsole(client, "sv_staminalandcost %.2f", flStamLand);
	PrintToConsole(client, "sv_staminajumpcost %.2f", flStamJump);
	PrintToConsole(client, "sv_wateraccelerate %.1f", flWaterA);
	PrintToConsole(client, "-------------------------------------");		
	PrintToChat(client, "[%cKZ%c] See console for output!", MOSSGREEN,WHITE);	
}

public OptionMenu(client)
{
	g_bMenuOpen[client] = true;
	new Handle:optionmenu = CreateMenu(OptionMenuHandler);
	SetMenuTitle(optionmenu, "Options Menu");
	if (g_bAdvancedClimbersMenu[client])
		AddMenuItem(optionmenu, "Advanced climbers menu  -  Enabled", "Advanced climbers menu  -  Enabled");
	else
		AddMenuItem(optionmenu, "Advanced climbers menu  -  Disabled", "Advanced climbers menu  -  Disabled");
	//1
	if (g_bHide[client])
		AddMenuItem(optionmenu, "Hide Players  -  Enabled", "Hide players  -  Enabled");
	else
		AddMenuItem(optionmenu, "Hide Players  -  Disabled", "Hide players  -  Disabled");			
	//2
	if (g_bColorChat[client])	
		AddMenuItem(optionmenu, "Color chat  -  Enabled", "Color chat  -  Enabled");
	else
		AddMenuItem(optionmenu, "Color chat  -  Disabled", "Color chat  -  Disabled");
	//3
	if (g_bCPTextMessage[client])
		AddMenuItem(optionmenu, "CP chat message  -  Enabled", "Checkpoint chat message  -  Enabled");
	else
		AddMenuItem(optionmenu, "CP chat message  -  Disabled", "Checkpoint chat message  -  Disabled");
	//4
	if (g_bClimbersMenuSounds[client])
		AddMenuItem(optionmenu, "Climbers menu sound  -  Enabled", "Climbers menu sounds  -  Enabled");
	else
		AddMenuItem(optionmenu, "Climbers menu sound  -  Disabled", "Climbers menu sounds -  Disabled");
	//5
	if (g_bEnableQuakeSounds[client])
		AddMenuItem(optionmenu, "Quake sounds - Enabled", "Quake sounds - Enabled");
	else
		AddMenuItem(optionmenu, "Quake sounds - Disabled", "Quake sounds - Disabled");
	//6
	if (g_bStrafeSync[client])
		AddMenuItem(optionmenu, "Strafe Sync  -  Enabled", "Strafe sync in chat  -  Enabled");
	else
		AddMenuItem(optionmenu, "Strafe Sync  -  Disabled", "Strafe sync in chat  -  Disabled");			
	//7	
	if (g_bShowTime[client])
		AddMenuItem(optionmenu, "Show Timer  -  Enabled", "Show timer  -  Enabled");
	else
		AddMenuItem(optionmenu, "Show Timer  -  Disabled", "Show timer  -  Disabled");			
	//8
	if (g_bShowSpecs[client])
		AddMenuItem(optionmenu, "Spectator list  -  Enabled", "Spectator list  -  Enabled");
	else
		AddMenuItem(optionmenu, "Spectator list  -  Disabled", "Spectator list  -  Disabled");	
	//9
	if (g_bInfoPanel[client])
		AddMenuItem(optionmenu, "Speed/Keys panel  -  Enabled", "Speed/Keys panel  -  Enabled");
	else
		AddMenuItem(optionmenu, "Speed/Keys panel  -  Disabled", "Speed/Keys panel  -  Disabled");	
	//10
	/*if (g_bShowNames[client])
		AddMenuItem(optionmenu, "Target Name Panel  -  Enabled", "Target name panel  -  Enabled");
	else
		AddMenuItem(optionmenu, "Target Name Panel  -  Disabled", "Target name panel  -  Disabled");	*/
	//11
	if (g_bGoToClient[client])
		AddMenuItem(optionmenu, "Goto  -  Enabled", "Goto me  -  Enabled");
	else
		AddMenuItem(optionmenu, "Goto  -  Disabled", "Goto me  -  Disabled");					
	//12
	if (g_bAutoBhop2)
	{
		if (g_bAutoBhopClient[client])
			AddMenuItem(optionmenu, "AutoBhop  -  Enabled", "AutoBhop  -  Enabled");
		else
			AddMenuItem(optionmenu, "AutoBhop  -  Disabled", "AutoBhop  -  Disabled");	
	}	
		

	SetMenuOptionFlags(optionmenu, MENUFLAG_BUTTON_EXIT);
	if (g_OptionsMenuLastPage[client] < 6)
		DisplayMenuAtItem(optionmenu, client, 0, MENU_TIME_FOREVER);
	else
		if (g_OptionsMenuLastPage[client] < 12)
			DisplayMenuAtItem(optionmenu, client, 6, MENU_TIME_FOREVER);
		else
			if (g_OptionsMenuLastPage[client] < 18)
				DisplayMenuAtItem(optionmenu, client, 12, MENU_TIME_FOREVER);
}

public OptionMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{	
			case 0: AdvClimbersMenu(param1);
			case 1: HideMethod(param1);
			case 2: ColorChat(param1);
			case 3: CPMessage(param1);
			case 4: ClimbersMenuSounds(param1);
			case 5: QuakeSounds(param1);
			case 6: StrafeSync(param1);
			case 7: ShowTime(param1);
			case 8: HideSpecs(param1);
			case 9: InfoPanel(param1);
			case 10: DisableGoTo(param1);
			case 11: AutoBhop(param1);		
		}
		g_OptionsMenuLastPage[param1] = param2;
		OptionMenu(param1);					
	}
	else
		if(action == MenuAction_Cancel)
		{
			if (param2!=9)
				g_bMenuOpen[param1]=false;	
		}
		else 
			if (action == MenuAction_End)
			{	
				CloseHandle(menu);
			}
}