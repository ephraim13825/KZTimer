//button hook
public Action:NormalSHook_callback(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
    if(entity > MaxClients)
    {
        new String:clsname[20]; GetEntityClassname(entity, clsname, sizeof(clsname));
        if(StrEqual(clsname, "func_button", false))
        {
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}  

//usp attack spam protection
public Action:Event_OnFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client   = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientInGame(client) && g_bAttackSpamProtection) 
	{
		decl String: weapon[64];
		GetEventString(event, "weapon", weapon, 64);
		if (StrContains(weapon,"knife",true) == -1 && g_AttackCounter[client] < 41)
		{	
			if (g_AttackCounter[client] < 41)
			{
				g_AttackCounter[client]++;
				if (StrContains(weapon,"grenade",true) != -1 || StrContains(weapon,"flash",true) != -1)
				{
					g_AttackCounter[client] = g_AttackCounter[client] + 9;
					if (g_AttackCounter[client] > 41)
						g_AttackCounter[client] = 41;
				}
			}
		}
	}
}

// - PlayerSpawn -
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client != 0)
	{	
		g_fStartCommandUsed_LastTime[client] = GetEngineTime();
		g_js_bPlayerJumped[client] = false;
		g_SpecTarget[client] = -1;	
		g_bOnGround[client] = true;
		g_MouseAbsCount[client] = 0;
		g_bPause[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_NORMAL);
		
		//strip weapons
		if ((GetClientTeam(client) > 1) && IsValidClient(client))
		{			
			StripAllWeapons(client);
			if (!IsFakeClient(client))
				GivePlayerItem(client, "weapon_usp_silencer");
			if (!g_bStartWithUsp[client])
			{
				new weapon = GetPlayerWeaponSlot(client, 2);
				if (weapon != -1 && !IsFakeClient(client))
					 SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			}
		}	
		
		//godmode
		if (g_bgodmode || IsFakeClient(client))
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		else
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			
		//NoBlock
		if(g_bNoBlock || IsFakeClient(client))
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
							
		//botmimic2		
		if(g_hBotMimicsRecord[client] != INVALID_HANDLE && IsFakeClient(client))
		{
			g_BotMimicTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}	
		
		if (IsFakeClient(client))	
		{
			if (client==g_InfoBot)
				CS_SetClientClanTag(client, ""); 	
			else
				CS_SetClientClanTag(client, "LOCALHOST"); 	
			return Plugin_Continue;
		}
		
		//fps Check
		QueryClientConVar(client, "fps_max", ConVarQueryFinished:FPSCheck, client);		
		
		//change player skin
		if (g_bPlayerSkinChange && (GetClientTeam(client) > 1))
		{
			SetEntPropString(client, Prop_Send, "m_szArmsModel", g_sArmModel);
			SetEntityModel(client,  g_sPlayerModel);
		}		

		//1st spawn & t/ct
		if (g_bFirstSpawn[client] && (GetClientTeam(client) > 1))		
		{
			StartRecording(client);
			CreateTimer(1.5, CenterMsgTimer, client,TIMER_FLAG_NO_MAPCHANGE);		
			g_bFirstSpawn[client] = false;
		}
		
		//get start pos for challenge
		GetClientAbsOrigin(client, g_fSpawnPosition[client]);
		
		//restore position (before spec or last session) && Climbers Menu
		if ((GetClientTeam(client) > 1))
		{
			if (g_bRestorePosition[client])
			{			
				g_bPositionRestored[client] = true;
				TeleportEntity(client, g_fPlayerCordsRestore[client],g_fPlayerAnglesRestore[client],NULL_VECTOR);
				g_bRestorePosition[client]  = false;
			}
			else
				if (g_bRespawnPosition[client])
				{
					TeleportEntity(client, g_fPlayerCordsRestore[client],g_fPlayerAnglesRestore[client],NULL_VECTOR);
					g_bRespawnPosition[client] = false;
				}		
				else
					if (g_bAutoTimer)
						CreateTimer(0.1, StartTimer, client,TIMER_FLAG_NO_MAPCHANGE);		
					else
					{
						g_bTimeractivated[client] = false;	
						g_fStartTime[client] = -1.0;
						g_fCurrentRunTime[client] = -1.0;	
					}			
			CreateTimer(0.0, ClimbersMenuTimer, client,TIMER_FLAG_NO_MAPCHANGE);
		}

		
		//hide radar
		CreateTimer(0.0, HideRadar, client,TIMER_FLAG_NO_MAPCHANGE);
		
		//set clantag
		CreateTimer(1.5, SetClanTag, client,TIMER_FLAG_NO_MAPCHANGE);	
				
		//set speclist
		Format(g_szPlayerPanelText[client], 512, "");		
		
		if (g_bClimbersMenuwasOpen[client] && (GetClientTeam(client) > 1))
		{
			g_bClimbersMenuwasOpen[client] = false;
			ClimbersMenu(client);
		}

		//get speed & origin
		g_fLastSpeed[client] = GetSpeed(client);
		GetClientAbsOrigin(client, g_fLastPosition[client]);				
	}
	return Plugin_Continue;
}

public Action:Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bConnectMsg)
	{
		decl String:szName[64];
		new String:disconnectReason[64];
		new clientid = GetEventInt(event,"userid");
		new client = GetClientOfUserId(clientid);
		if (!IsValidClient(client) || IsFakeClient(client))
			return Plugin_Handled;
		GetEventString(event, "name", szName, sizeof(szName));
		GetEventString(event, "reason", disconnectReason, sizeof(disconnectReason));  
		for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
				PrintToChat(i, "%t", "Disconnected1",WHITE, MOSSGREEN, szName, WHITE, disconnectReason);	
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public Action:Say_Hook(client, const String:command[], argc)
{
	//Call Admin - Own Reason
	if (g_bClientOwnReason[client])
	{
		StopClimbersMenu(client);
		g_bClientOwnReason[client] = false;
		return Plugin_Continue;
	}
	
	//Chat trigger?
	g_bSayHook[client]=true;
	if (IsValidClient(client))
	{		
		decl String:sText[1024];
		GetCmdArgString(sText, sizeof(sText));
		StripQuotes(sText);
		new team = GetClientTeam(client);		
		TrimString(sText); 
		
		ReplaceString(sText,1024,"{darkred}","",false);
		ReplaceString(sText,1024,"{green}","",false);
		ReplaceString(sText,1024,"{lightgreen}","",false);
		ReplaceString(sText,1024,"{blue}","",false);
		ReplaceString(sText,1024,"{olive}","",false);
		ReplaceString(sText,1024,"{lime}","",false);
		ReplaceString(sText,1024,"{red}","",false);
		ReplaceString(sText,1024,"{purple}","",false);
		ReplaceString(sText,1024,"{grey}","",false);
		ReplaceString(sText,1024,"{yellow}","",false);
		ReplaceString(sText,1024,"{lightblue}","",false);
		ReplaceString(sText,1024,"{steelblue}","",false);
		ReplaceString(sText,1024,"{darkblue}","",false);
		ReplaceString(sText,1024,"{pink}","",false);
		ReplaceString(sText,1024,"{lightred}","",false);
		
		//empty message
		if(StrEqual(sText, " ") || StrEqual(sText, ""))
		{
			g_bSayHook[client]=false;
			return Plugin_Handled;		
		}

		//lowercase
		if((sText[0] == '/') || (sText[0] == '!'))
		{
			if(IsCharUpper(sText[1]))
			{
				for(new i = 0; i <= strlen(sText); ++i)
						sText[i] = CharToLower(sText[i]);
				g_bSayHook[client]=false;
				FakeClientCommand(client, "say %s", sText);
				return Plugin_Handled;
			}
		}
		
		//blocked commands
		for(new i = 0; i < sizeof(g_BlockedChatText); i++)
		{
			if (StrEqual(g_BlockedChatText[i],sText,true))
			{
				g_bSayHook[client]=false;
				return Plugin_Handled;			
			}
		}
		
		//chat trigger?
		if((IsChatTrigger() && sText[0] == '/') || (sText[0] == '@' && (GetUserFlagBits(client) & ADMFLAG_ROOT ||  GetUserFlagBits(client) & ADMFLAG_GENERIC)))
		{
			g_bSayHook[client]=false;
			return Plugin_Continue;
		}

		decl String:szName[32];
		GetClientName(client,szName,32);		
		ReplaceString(szName,32,"{darkred}","",false);
		ReplaceString(szName,32,"{green}","",false);
		ReplaceString(szName,32,"{lightgreen}","",false);
		ReplaceString(szName,32,"{blue}","",false);
		ReplaceString(szName,32,"{olive}","",false);
		ReplaceString(szName,32,"{lime}","",false);
		ReplaceString(szName,32,"{red}","",false);
		ReplaceString(szName,32,"{purple}","",false);
		ReplaceString(szName,32,"{grey}","",false);
		ReplaceString(szName,32,"{yellow}","",false);
		ReplaceString(szName,32,"{lightblue}","",false);
		ReplaceString(szName,32,"{steelblue}","",false);
		ReplaceString(szName,32,"{darkblue}","",false);
		ReplaceString(szName,32,"{pink}","",false);
		ReplaceString(szName,32,"{lightred}","",false);
		
		////////////////
		//say stuff
		//
		//SPEC
		if (team==1)
		{
			PrintSpecMessageAll(client);
			g_bSayHook[client]=false;
			return Plugin_Handled;
		}
		else
		{
			decl String:szChatRank[64];
			Format(szChatRank, 64, "%s",g_pr_chat_coloredrank[client]);	
			
			if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
			{						
				if (StrEqual(sText,""))
				{
					g_bSayHook[client]=false;
					return Plugin_Handled;
				}
				if (IsPlayerAlive(client))
					CPrintToChatAllEx(client,"{green}%s{default} %s {teamcolor}%s{default}: %s",g_szCountryCode[client],szChatRank,szName,sText);			
				else
					CPrintToChatAllEx(client,"{green}%s{default} %s {teamcolor}*DEAD* %s{default}: %s",g_szCountryCode[client],szChatRank,szName,sText);
				g_bSayHook[client]=false;				
				return Plugin_Handled;
			}
			else
			{
				if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
				{
					if (StrEqual(sText,""))
					{
						g_bSayHook[client]=false;
						return Plugin_Handled;
					}
					if (IsPlayerAlive(client))
						CPrintToChatAllEx(client,"%s {teamcolor}%s{default}: %s",szChatRank,szName,sText);	
					else
						CPrintToChatAllEx(client,"%s {teamcolor}*DEAD* %s{default}: %s",szChatRank,szName,sText);	
					g_bSayHook[client]=false;					
					return Plugin_Handled;							
				}
				else
					if (g_bCountry)
					{
						if (StrEqual(sText,""))
						{
							g_bSayHook[client]=false;
							return Plugin_Handled;
						}
						if (IsPlayerAlive(client))
							CPrintToChatAllEx(client,"[{green}%s{default}] {teamcolor}%s{default}: %s",g_szCountryCode[client],szName,sText);	
						else
							CPrintToChatAllEx(client,"[{green}%s{default}] {teamcolor}*DEAD* %s{default}: %s",g_szCountryCode[client],szName,sText);		
						g_bSayHook[client]=false;
						return Plugin_Handled;							
					}								
			}
		}	
	}
	g_bSayHook[client]=false;
	return Plugin_Continue;
}

public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;
	new team = GetEventInt(event, "team");
	if(team == 1)
	{
		SpecListMenuDead(client);
		if (!g_bFirstSpawn[client])
		{
			GetClientAbsOrigin(client,g_fPlayerCordsRestore[client]);
			GetClientEyeAngles(client, g_fPlayerAnglesRestore[client]);
			g_bRespawnPosition[client] = true;
		}
		if (g_bTimeractivated[client] == true)
		{	
			g_fStartPauseTime[client] = GetEngineTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];	
		}
		g_bSpectate[client] = true;
		//PrintToChat(client, "%t", "SpecInfo",MOSSGREEN,WHITE,GREEN,WHITE);
		if (g_bPause[client])
			g_bPauseWasActivated[client]=true;
		g_bPause[client]=false;
	}
	return Plugin_Continue;
}


public Action:Hook_SetTransmit(entity, client) 
{ 
    if (client != entity && (0 < entity <= MaxClients) && IsValidClient(client)) 
	{
		if (g_bChallenge[client] && !g_bHide[client])
		{
			if (!StrEqual(g_szSteamID[entity], g_szChallenge_OpponentID[client], false))
				return Plugin_Handled;
		}
		else
			if (g_bHide[client] && entity != g_SpecTarget[client])
				return Plugin_Handled; 
			else
				if (entity == g_InfoBot && entity != g_SpecTarget[client])
					return Plugin_Handled;
	}	
    return Plugin_Continue; 
}  

// - PlayerDeath -
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event,"userid");
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
		{			
			if(g_hRecording[client] != INVALID_HANDLE)
				StopRecording(client);			
			CreateTimer(2.0, RemoveRagdoll, client);
		}
		else 
			if(g_hBotMimicsRecord[client] != INVALID_HANDLE)
			{
				g_BotMimicTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
				if(GetClientTeam(client) >= CS_TEAM_T)
					CreateTimer(1.0, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
	}
	return Plugin_Continue;
}
					
public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	if (g_bRoundEnd)
		return Plugin_Continue;
	new timeleft;
	GetMapTimeLeft(timeleft);
	if (timeleft>= -1)
		return Plugin_Handled;
	g_bRoundEnd=true;
	return Plugin_Continue;
}  


public Action:Event_OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bRoundEnd=true;
		
	//Unhook ent stuff
	new ent = -1;
	SDKUnhook(0,SDKHook_Touch,Touch_Wall);	
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Push_Touch);
	return Plugin_Continue;
}

// OnRoundRestart
public Action:Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	//hook ent stuff
	new ent = -1;
	SDKHook(0,SDKHook_Touch,Touch_Wall);	
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKHook(ent,SDKHook_Touch,Push_Touch);

	new iEnt;
	for(new i = 0; i < sizeof(EntityList); i++)
	{
		while((iEnt = FindEntityByClassname(iEnt, EntityList[i])) != -1)
		{
			AcceptEntityInput(iEnt, "Disable");
			AcceptEntityInput(iEnt, "Kill");
		}
	}
		
	g_bRoundEnd=false;
	db_selectMapButtons();
	OnPluginPauseChange(false);
	return Plugin_Continue; 
}

public OnPlayerThink(entity)
{
	SetEntPropEnt(entity, Prop_Send, "m_bSpotted", 0); 
}


//Credits: Timer by zipcore
//https://github.com/Zipcore/Timer/
public Action:Touch_Wall(ent,client)
{
	if(IsValidClient(client))
	{
		if(!(GetEntityFlags(client)&FL_ONGROUND)  && g_js_bPlayerJumped[client])
		{
			new Float:origin[3], Float:temp[3];
			GetGroundOrigin(client, origin);
			GetClientAbsOrigin(client, temp);
			if(temp[2] - origin[2] <= 0.2)
			{
				ResetJump(client);
			}
		}
	}
	return Plugin_Continue;
}

//Credits: Timer by zipcore
//https://github.com/Zipcore/Timer/
public Action:Push_Touch(ent,client)
{
	if(IsValidClient(client) && g_js_bPlayerJumped[client])
	{
		ResetJump(client);
	}
	return Plugin_Continue;
}

// PlayerHurt 
public Action:Event_OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bgodmode && g_Autohealing_Hp > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new remainingHeatlh = GetEventInt(event, "health");
		if (remainingHeatlh>0)
		{
			if ((remainingHeatlh+g_Autohealing_Hp) > 100)
				SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), 100);
			else
				SetEntData(client, FindSendPropOffs("CBasePlayer", "m_iHealth"), remainingHeatlh+g_Autohealing_Hp);
		}
	}
	return Plugin_Continue; 
}

// PlayerDamage (if godmode 0)
public Action:Hook_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (g_bgodmode)
		return Plugin_Handled;
	return Plugin_Continue;
}

//fpscheck
public FPSCheck(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	if (IsValidClient(client) && !IsFakeClient(client) && !g_bKickStatus[client])
	{
		new fps_max = StringToInt(cvarValue);  	  
		if (fps_max > 0 && fps_max < 120)
		{
			CreateTimer(10.0, KickPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
			g_bKickStatus[client]=true;
		}	
	}
}

//Credits: TnTSCS
//https://forums.alliedmods.net/showthread.php?t=233966
public Action:OnLogAction(Handle:source, Identity:ident, client, target, const String:message[])
{	
    if ((1 > target > MaxClients))
        return Plugin_Continue;
    if (IsValidClient(target) && IsPlayerAlive(target) && g_bTimeractivated[target] && !IsFakeClient(target))
	{
		new String:logtag[PLATFORM_MAX_PATH];
		if (ident == Identity_Plugin)
			GetPluginFilename(source, logtag, sizeof(logtag));
		else
			Format(logtag, sizeof(logtag), "OTHER");
		if ((strcmp("playercommands.smx", logtag, false) == 0) ||(strcmp("slap.smx", logtag, false) == 0))
			Client_Stop(target, 0);
	}   
    return Plugin_Continue;
}  

// OnPlayerRunCmd
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	new Float:speed, Float:origin[3],Float:ang[3];
	if (g_bRoundEnd || !IsValidClient(client))
		return Plugin_Continue;	
	
	//client information
	g_CurrentButton[client] = buttons;
	GetClientAbsOrigin(client, origin);
	GetClientEyeAngles(client, ang);			
	speed = GetSpeed(client);	
	
	//Set ground frames
	if (g_js_bPlayerJumped[client] == false && GetEntityFlags(client) & FL_ONGROUND && ((buttons & IN_MOVERIGHT) || (buttons & IN_MOVELEFT) || (buttons & IN_BACK) || (buttons & IN_FORWARD)))
		g_js_GroundFrames[client]++;
	
	//some methods..	
	if(IsPlayerAlive(client))	
	{	
		//menu refreshing
		MenuTitleRefreshing(client);	
		
		//get player speed
		g_fSpeed[client] = speed;
		
		//undo check
		if(g_bUndo[client] || g_bUndoTimer[client])
		{
			buttons &= ~IN_JUMP;
			buttons &= ~IN_DUCK;
			if ((GetEntityFlags(client) & FL_ONGROUND) && g_bUndo[client])
			{
				CreateTimer(0.5, ResetUndo, client, TIMER_FLAG_NO_MAPCHANGE);
				g_bUndo[client]	= false;
			}
		}
			
		//replay bots
		PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		
		//movement modifications
		SpeedCap(client);	
		AutoBhopFunction(client, buttons);
		Prestrafe(client, ang[1], buttons);

		//usp attack spam protection
		if (g_bAttackSpamProtection && client > 0 && IsClientInGame(client))
		{
			decl String:classnamex[64];
			GetClientWeapon(client, classnamex, 64);
			if(StrContains(classnamex,"knife",true) == -1 && g_AttackCounter[client] >= 40)
			{
				if(buttons & IN_ATTACK)
				{
					new weaponx = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
					SetEntPropFloat(weaponx, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
				}
			}
		}
		
		//hook mod enabled?
		if (g_bHookMod)
		{
			if (HGR_IsHooking(client) || HGR_IsGrabbing(client) || HGR_IsBeingGrabbed(client) || HGR_IsRoping(client) || HGR_IsPushing(client))
			{
				g_js_bPlayerJumped[client] = false;
				g_bTimeractivated[client] = false;
			}
		}
		
		//several methods
		ButtonPressCheck(client, buttons, origin, speed);
		TeleportCheck(client, origin);
		NoClipCheck(client);
		WaterCheck(client);
		BoosterCheck(client);
		WjJumpPreCheck(client,buttons);
		CalcJumpMaxSpeed(client, speed);
		CalcJumpHeight(client);
		CalcJumpSync(client, speed, ang[1], buttons);
		CalcLastJumpHeight(client, buttons, origin);		
		BhopHackAntiCheat(client, buttons);

		//LJ Blocks
		if (!g_js_bPlayerJumped[client] && GetEntityFlags(client) & FL_ONGROUND && ((buttons & IN_JUMP)))
		{
			decl Float:temp[3], Float: pos[3];
			GetClientAbsOrigin(client,pos);
			g_bLJBlockValidJumpoff[client]=false;
			if(g_bLJBlock[client])
			{
				g_bLJBlockValidJumpoff[client]=true;
				g_bLjStarDest[client]=false;
				GetEdgeOrigin(client, origin, temp);
				g_fEdgeDist[client] = GetVectorDistance(temp, origin);
				if(!IsCoordInBlockPoint(pos,g_fOriginBlock[client],false))				
					if(IsCoordInBlockPoint(pos,g_fDestBlock[client],false))
					{
						g_bLjStarDest[client]=true;
					}
					else
						g_bLJBlockValidJumpoff[client]=false;
			}
		}
		if(g_bLJBlock[client])
		{
			TE_SendBlockPoint(client, g_fDestBlock[client][0], g_fDestBlock[client][1], g_Beam[0]);
			TE_SendBlockPoint(client, g_fOriginBlock[client][0], g_fOriginBlock[client][1], g_Beam[0]);
		}	
	}
	
	// jumpstats (landing)	
	if(GetEntityFlags(client) & FL_ONGROUND && !g_js_bInvalidGround[client] && !g_bLastInvalidGround[client] && g_js_bPlayerJumped[client] == true && weapon != -1 && IsValidEntity(weapon) && GetEntProp(client, Prop_Data, "m_nWaterLevel") < 1)
	{		
		GetGroundOrigin(client, g_js_fJump_Landing_Pos[client]);
		g_fAirTime[client] = GetEngineTime() - g_fAirTime[client];
		if (g_bJumpStats && !g_bKickStatus[client])
			Postthink(client);
	}	
				
	// reset/save current values
	if (GetEntityFlags(client) & FL_ONGROUND)
	{
		g_fLastPositionOnGround[client] = origin;
		g_bLastInvalidGround[client] = g_js_bInvalidGround[client];
	}
	if (!(GetEntityFlags(client) & FL_ONGROUND) && g_js_bPlayerJumped[client] == false)
		g_js_GroundFrames[client] = 0;			
	g_fLastAngles[client] = ang;
	g_fLastSpeed[client] = speed;
	g_fLastPosition[client] = origin;
	g_LastButton[client] = buttons;
	return Plugin_Continue;
}

public Action:Event_OnJump(Handle:Event, const String:Name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Event, "userid"));	

	new Float: flEngineTime = GetEngineTime()
	//noclip check
	new Float:flDiff = flEngineTime - g_fLastTimeNoClipUsed[client];
	if (flDiff < 4.0)
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Float:{0.0,0.0,-100.0});
	g_fLastJump[client] = flEngineTime;
	g_fAirTime[client] = flEngineTime;
	new bool:touchwall = WallCheck(client);	
	if (g_bJumpStats && !touchwall)
		Prethink(client, Float:{0.0,0.0,0.0},0.0);
}
			
public Hook_PostThinkPost(entity)
{
	SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
} 

public Hook_OnTouch(client, other)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new String:classname[32];
		if (IsValidEdict(other))
			GetEntityClassname(other, classname, 32);		
		if (StrEqual(classname,"func_movelinear"))
		{
			g_js_bFuncMoveLinear[client] = true;
			return;
		}
		if (!(GetEntityFlags(client) & FL_ONGROUND) || other != 0)
			ResetJump(client);	
	}
}  

public Action:Event_JoinTeamFailed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !IsClientInGame(client))
		return Plugin_Continue;
	new EJoinTeamReason:m_eReason = EJoinTeamReason:GetEventInt(event, "reason");
	new m_iTs = GetTeamClientCount(CS_TEAM_T);
	new m_iCTs = GetTeamClientCount(CS_TEAM_CT);
	switch(m_eReason)
	{
		case k_OneTeamChange:
		{
			return Plugin_Continue;
		}

		case k_TeamsFull:
		{
			if(m_iCTs == g_CTSpawns && m_iTs == g_TSpawns)
				return Plugin_Continue;
		}
		case k_TTeamFull:
		{
			if(m_iTs == g_TSpawns)
				return Plugin_Continue;
		}
		case k_CTTeamFull:
		{
			if(m_iCTs == g_CTSpawns)
				return Plugin_Continue;
		}
		default:
		{
			return Plugin_Continue;
		}
	}
	ChangeClientTeam(client, g_SelectedTeam[client]);

	return Plugin_Handled;
}

public Teleport_OnStartTouch(const String:output[], caller, client, Float:delay)
{
	if (IsValidClient(client))
	{	
		if (GetEntityFlags(client) & FL_ONGROUND)
			g_bOnBhopPlattform[client]=true;
		g_bValidTeleport[client]=true;
	}
}  

public Teleport_OnEndTouch(const String:output[], caller, client, Float:delay)
{
	if (IsValidClient(client) && g_bOnBhopPlattform[client])
	{
		g_bOnBhopPlattform[client] = false;
		g_fLastTimeBhopBlock[client] = GetEngineTime();
	}
}  

//https://forums.alliedmods.net/showthread.php?p=1678026 by Inami
public Action:Event_OnJumpMacroDox(Handle:Event, const String:Name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Event, "userid"));	
	if(IsValidClient(client) && !IsFakeClient(client) && !g_bAutoBhop2)
	{	
		g_fafAvgJumps[client] = ( g_fafAvgJumps[client] * 9.0 + float(g_aiJumps[client]) ) / 10.0;	
		decl Float:vec_vel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec_vel);
		vec_vel[2] = 0.0;
		new Float:speed = GetVectorLength(vec_vel);
		g_fafAvgSpeed[client] = (g_fafAvgSpeed[client] * 9.0 + speed) / 10.0;
		
		g_aaiLastJumps[client][g_NumberJumpsAbove[client]] = g_aiJumps[client];
		g_NumberJumpsAbove[client]++;
		if (g_NumberJumpsAbove[client] == 30)
		{
			g_NumberJumpsAbove[client] = 0;
		}
				
		if(g_fafAvgJumps[client] > 14.0)
		{
			//HYPERSCROLLING:  http://hmxgaming.com/index.php?/topic/1459-cheating-isnt-cool-hyperscrolling-for-bhop-is-an-example/
			//disabled because it does not give you more speed than usual scrolling
			/*//check if more than 8 of the last 30 jumps were above 12
			g_NumberJumpsAbove[client] = 0;
			
			for (new i = 0; i < 29; i++)	//count
			{
				if((g_aaiLastJumps[client][i]) > (14 - 1))	//threshhold for # jump commands
				{
					g_NumberJumpsAbove[client]++;
				}
			}
			if((g_NumberJumpsAbove[client] > (14 - 1)) && (g_fafAvgPerfJumps[client] >= 0.4))	//if more than #
			{
				if (g_bAntiCheat && !g_bHyperscroll[client])
				{
					g_bHyperscroll[client] = true;
					new String:banstats[256];
					GetClientStatsLog(client, banstats, sizeof(banstats));		
					decl String:sPath[512];
					BuildPath(Path_SM, sPath, sizeof(sPath), "%s", ANTICHEAT_LOG_PATH);
					LogToFile(sPath, "%s reason: hyperscrolling" banstats);
				}
			}*/
		}
		else if(g_aiJumps[client] > 1)
		{
			g_aiAutojumps[client] = 0;
		}

		g_aiJumps[client] = 0;
		new Float:tempvec[3];
		tempvec = g_favLastPos[client];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", g_favLastPos[client]);
		
		new Float:len = GetVectorDistance(g_favLastPos[client], tempvec, true);
		if (len < 30.0)
		{   
			g_aiIgnoreCount[client] = 2;
		}
		
		if (g_fafAvgPerfJumps[client] >= 0.9)
		{
			if (g_bAntiCheat && !g_bFlagged[client])
			{
				new String:banstats[256];
				GetClientStatsLog(client, banstats, sizeof(banstats));		
				decl String:sPath[512];
				BuildPath(Path_SM, sPath, sizeof(sPath), "%s", ANTICHEAT_LOG_PATH);
				if (g_bAutoBan)
				{
					LogToFile(sPath, "%s, Reason: bhop hack detected. (autoban)", banstats);	
				}
				else
					LogToFile(sPath, "%s, Reason: bhop hack detected.", banstats);	
				g_bFlagged[client] = true;
				if (g_bAutoBan)	
					PerformBan(client,"a bhop hack");
			}
		}
	}
}

