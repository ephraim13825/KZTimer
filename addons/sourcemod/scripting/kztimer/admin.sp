public OnAdminMenuReady(Handle:topmenu)
{
	if (topmenu == g_hAdminMenu)
		return;

	g_hAdminMenu = topmenu;
	new TopMenuObject:serverCmds = FindTopMenuCategory(g_hAdminMenu, ADMINMENU_SERVERCOMMANDS);
	AddToTopMenu(g_hAdminMenu, "sm_kzadmin", TopMenuObject_Item, TopMenuHandler2, serverCmds, "sm_kzadmin", ADMFLAG_RCON);
}

public TopMenuHandler2(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "KZ Timer");

	else 
		if (action == TopMenuAction_SelectOption)
			Admin_KzPanel(param, 0);
}

public Action:Admin_KzPanel(client, args)
{
	PrintToChat(client, "[%cKZ%c] See console for more commands", LIMEGREEN,WHITE);
	PrintToConsole(client,"\n \n[KZ Admin]\n");
	PrintToConsole(client,"more server cvars: \n rcon kz_prespeed_cap - Limits player's pre speed\n rcon kz_max_prespeed_bhop_dropbhop - Max counted pre speed for bhop & dropbhop (jumpstats)\n rcon kz_replay_bot_pro_color - Pro replay bot color. Format: \"red green blue\" from 0 - 255\n rcon kz_replay_bot_tp_color - Tp replay bot color. Format: \"red green blue\" from 0 - 255\n rcon kz_dist_min_bhop - Minimum distance for bhops to be considered good");
	PrintToConsole(client," rcon kz_dist_pro_bhop - Minimum distance for bhops to be considered pro\n rcon kz_dist_leet_bhop - Minimum distance for bhops to be considered leet\n rcon kz_dist_min_wj - Minimum distance for weirdjumps to be considered good\n rcon kz_dist_min_lj - Minimum distance for longjumps to be considered good");
	PrintToConsole(client," rcon kz_dist_pro_lj - Minimum distance for longjumps to be considered pro\n rcon kz_dist_leet_lj - Minimum distance for longjumps to be considered leet\n rcon kz_dist_pro_wj - Minimum distance for weirdjumps to be considered pro\n rcon kz_dist_leet_wj - Minimum distance for weirdjumps to be considered leet");
	PrintToConsole(client," rcon kz_dist_min_dropbhop - Minimum distance for dropbhop to be considered good\n rcon kz_dist_pro_dropbhop - Minimum distance for dropbhop to be considered pro\n rcon kz_dist_leet_dropbhop - Minimum distance for dropbhop to be considered leet\n rcon kz_dist_min_multibhop - Minimum distance for multibhop to be considered good");
	PrintToConsole(client," rcon kz_dist_pro_multibhop - Minimum distance for multibhop to be considered pro\n rcon kz_dist_leet_multibhop - Minimum distance for multibhop to be considered leet");		
	if ((GetUserFlagBits(client) & ADMFLAG_ROOT))
	{
		PrintToConsole(client,"\nAdmin commands:\nsm_deleteproreplay <mapname> (Deletes pro replay file for a given map)\n sm_deletetpreplay <mapname> (Deletes tp replay file for a given map)");
		PrintToConsole(client,"[database table playerrank]\n sm_resetranks (Drops playerrank table)\n sm_getmultiplier <steamid> (Gets the dynamic points multiplier for given steamid)\n sm_setmultiplier <steamid> <multiplier> (Sets the dynamic points multiplier for given steamid)\n [players have to refresh their profile afterwards]");
		PrintToConsole(client,"[database table playertimes]\n sm_resettimes (Drops playertimes table)\n sm_resetmaptimes <map> (Resets player times for given map)\n sm_resetplayertimes <steamid> [<map>] (Resets tp&pro times for given steamid with or without given map.)\n sm_resetplayertptime <steamid> <map> (Resets tp map time for given steamid and map)");
		PrintToConsole(client," sm_resetplayerprotime <steamid> <map> (Resets pro map time for given steamid and map)\n[database table jumpstats]\n sm_resetjumpstats (Drops jumpstats table)");
		PrintToConsole(client," sm_resetallljrecords (Resets all lj records)\n sm_resetallljblockrecords (Resets all lj block records)\n sm_resetallwjrecords (Resets all wj records)\n sm_resetallbhoprecords (Resets all bhop records)\n sm_resetallmultibhoprecords (Resets all multi bhop records)\n sm_resetalldropbhopecords (Resets all drop bhop records)");
		PrintToConsole(client," sm_resetplayerjumpstats <steamid> (Resets jump stats for given steamid)\n sm_resetljrecord <steamid> (Resets lj record for given steamid)\n sm_resetljblockrecord <steamid> (Resets lj block record for given steamid)\n sm_resetwjrecord <steamid> (Resets wj record for given steamid)\n sm_resetbhoprecord <steamid> (Resets bhop record for given steamid)\n sm_resetmultibhoprecord <steamid> (Resets multi bhop record for given steamid)\n sm_resetdropbhoprecord <steamid> (Resets drop bhop record for given steamid)");
		
	}
	KzAdminMenu(client);
	return Plugin_Handled;
}
	
public KzAdminMenu(client)
{
	if(!IsValidClient(client))
		return;
	g_bClimbersMenuOpen[client] = false;
	g_bMenuOpen[client]=true;
	decl String:szTmp[64];
	
	new Handle:adminmenu = CreateMenu(AdminPanelHandler);
	Format(szTmp, sizeof(szTmp), "KZ Timer %s Admin Menu\nNoclip: bind KEY +noclip",VERSION); 	
	SetMenuTitle(adminmenu, szTmp);
	if (MAX_PR_PLAYERS <  g_pr_RankedPlayers)
		AddMenuItem(adminmenu, "[1.] Recalculate player rankings", "[1.] Recalculate player rankings",ITEMDRAW_DISABLED);
	else
	{	
		if (!g_pr_RankingRecalc_InProgress)
			AddMenuItem(adminmenu, "[1.] Recalculate player rankings", "[1.] Recalculate player rankings");
		else
			AddMenuItem(adminmenu, "[1.] Recalculate player rankings", "[1.] Stop the recalculation");
	}
	AddMenuItem(adminmenu, "", "-------------------------------------",ITEMDRAW_DISABLED);		
	AddMenuItem(adminmenu, "[3.] Set start button", "[3.] Set start button");
	AddMenuItem(adminmenu, "[4.] Set stop button", "[4.] Set stop button");
	AddMenuItem(adminmenu, "[5.] Remove buttons", "[5.] Remove buttons");
	if (g_bEnforcer)
		Format(szTmp, sizeof(szTmp), "[6.] Settings enforcer  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[6.] Settings enforcer  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bgodmode)
		Format(szTmp, sizeof(szTmp), "[7.] Godmode  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[7] Godmode  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bAllowCheckpoints)
		Format(szTmp, sizeof(szTmp), "[8.] Checkpoints  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[8.] Checkpoints  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bNoBlock)
		Format(szTmp, sizeof(szTmp), "[9.] Noblock  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[9.] Noblock  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bAutoRespawn)
		Format(szTmp, sizeof(szTmp), "[10.] Autorespawn  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[10.] Autorespawn  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bCleanWeapons)
		Format(szTmp, sizeof(szTmp), "[11.] Clean weapons  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[11.] Clean weapons  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bRestore)
		Format(szTmp, sizeof(szTmp), "[12.] Restore function  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[12.] Restore function  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bPauseServerside)
		Format(szTmp, sizeof(szTmp), "[13.] !pause command -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[13.] !pause command  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bGoToServer)
		Format(szTmp, sizeof(szTmp), "[14.] !goto command  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[14.] !goto command  -  Disabled"); 
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bRadioCommands)
		Format(szTmp, sizeof(szTmp), "[15.] Radio commands  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[15.] Radio commands  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bAutoTimer)
		Format(szTmp, sizeof(szTmp), "[16.] Timer starts at spawn  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[16.] Timer starts at spawn  -  Disabled"); 						
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bReplayBot)
		Format(szTmp, sizeof(szTmp), "[17.] Replay bot  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[17.] Replay bot  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bPreStrafe)
		Format(szTmp, sizeof(szTmp), "[18.] Prestrafe  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[18.] Prestrafe  -  Disabled"); 	
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bfpsCheck)
		Format(szTmp, sizeof(szTmp), "[19.] FPS check  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[19.] FPS check  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bPointSystem)
		Format(szTmp, sizeof(szTmp), "[20.] Player point system  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[20.] Player point system  -  Disabled"); 	
	AddMenuItem(adminmenu, szTmp, szTmp);			
	if (g_bCountry)
		Format(szTmp, sizeof(szTmp), "[21.] Player country tag  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[21.] Player country tag  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bPlayerSkinChange)
		Format(szTmp, sizeof(szTmp), "[22.] Allows custom models  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[22.] Allows custom models  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bNoClipS)
		Format(szTmp, sizeof(szTmp), "[23.] +noclip  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[23.] +noclip (admin/vip excluded)  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bJumpStats)
		Format(szTmp, sizeof(szTmp), "[24.] Jumpstats  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[24.] Jumpstats  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bAutoBhop)
		Format(szTmp, sizeof(szTmp), "[25.] AutoBhop (only surf_/bhop_ maps)  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[25.] AutoBhop  -  Disabled"); 				
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bAutoBan)
		Format(szTmp, sizeof(szTmp), "[26.] AntiCheat auto-ban  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[26.] AntiCheat auto-ban  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bMultiplayerBhop)
		Format(szTmp, sizeof(szTmp), "[27.] Multiplayer bunnyhop  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[27.] Multiplayer bunnyhop  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);
	if (g_bAdminClantag)
		Format(szTmp, sizeof(szTmp), "[28.] Admin clan tag  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[28.] Admin clan tag  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bVipClantag)
		Format(szTmp, sizeof(szTmp), "[29.] VIP clan tag  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[29.] VIP clan tag  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);		
	if (g_bMapEnd)
		Format(szTmp, sizeof(szTmp), "[30.] Allow map changes  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[30.] Allow map changes  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bConnectMsg)
		Format(szTmp, sizeof(szTmp), "[31.] Connect message  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[31.] Connect message  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bColoredChatRanks)
		Format(szTmp, sizeof(szTmp), "[32.] Colored chat ranks  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[32.] Colored chat ranks  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bAllowCpOnBhopPlattforms)
		Format(szTmp, sizeof(szTmp), "[33.] Checkpoints on bhop plattforms  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[33.] Checkpoints on bhop plattforms  -  Disabled"); 			
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bInfoBot)
		Format(szTmp, sizeof(szTmp), "[34.] Info bot  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[34.] Info bot  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);	
	if (g_bProMode)
		Format(szTmp, sizeof(szTmp), "[35.] Pro Mode  -  Enabled"); 	
	else
		Format(szTmp, sizeof(szTmp), "[35.] Pro Mode  -  Disabled"); 		
	AddMenuItem(adminmenu, szTmp, szTmp);			
	SetMenuExitButton(adminmenu, true);
	SetMenuOptionFlags(adminmenu, MENUFLAG_BUTTON_EXIT);	
	if (g_AdminMenuLastPage[client] < 6)
		DisplayMenuAtItem(adminmenu, client, 0, MENU_TIME_FOREVER);
	else
		if (g_AdminMenuLastPage[client] < 12)
			DisplayMenuAtItem(adminmenu, client, 6, MENU_TIME_FOREVER);	
		else
			if (g_AdminMenuLastPage[client] < 18)
				DisplayMenuAtItem(adminmenu, client, 12, MENU_TIME_FOREVER);	
			else
				if (g_AdminMenuLastPage[client] < 24)
					DisplayMenuAtItem(adminmenu, client, 18, MENU_TIME_FOREVER);	
				else
					if (g_AdminMenuLastPage[client] < 30)
						DisplayMenuAtItem(adminmenu, client, 24, MENU_TIME_FOREVER);				
					else
						if (g_AdminMenuLastPage[client] < 36)
							DisplayMenuAtItem(adminmenu, client, 30, MENU_TIME_FOREVER);	
						else
							if (g_AdminMenuLastPage[client] < 42)
								DisplayMenuAtItem(adminmenu, client, 36, MENU_TIME_FOREVER);								
}


public AdminPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		if(param2 == 0)
		{ 
			if (!g_pr_RankingRecalc_InProgress)
			{
				PrintToChat(param1, "%t", "PrUpdateStarted", MOSSGREEN,WHITE);
				g_bManualRecalc=true;
				g_pr_Recalc_AdminID=param1;
				RefreshPlayerRankTable(MAX_PR_PLAYERS);
			}
			else
			{
				g_bTop100Refresh = false;
				g_bManualRecalc = false;
				g_pr_RankingRecalc_InProgress = false;
				PrintToChat(param1, "%t", "StopRecalculation", MOSSGREEN,WHITE);
			}
		}
		if(param2 == 2)
		{ 
			SetStandingStartButton(param1);
		}
		if(param2 == 3)
		{ 
			SetStandingStopButton(param1);
		}
		if(param2 == 4)
		{ 
			DeleteButtons(param1);
			db_deleteMapButtons(g_szMapName);
			PrintToChat(param1,"[%cKZ%c] Timer buttons deleted", MOSSGREEN,WHITE,GREEN,WHITE);
		}
		if(param2 == 5)
		{
			if (!g_bEnforcer)
				ServerCommand("kz_settings_enforcer 1");
			else
				ServerCommand("kz_settings_enforcer 0");
		}
		if(param2 == 6)
		{
		
			if (!g_bgodmode)
				ServerCommand("kz_godmode 1");
			else	
				ServerCommand("kz_godmode 0");
		}		
		if(param2 == 7)
		{
			if (!g_bAllowCheckpoints)
				ServerCommand("kz_checkpoints 1");
			else
				ServerCommand("kz_checkpoints 0");
		}		
		if(param2 == 8)
		{
			if (!g_bNoBlock)
				ServerCommand("kz_noblock 1");
			else
				ServerCommand("kz_noblock 0");
		}		
		if(param2 == 9)
		{
			if (!g_bAutoRespawn)
				ServerCommand("kz_autorespawn 1");
			else
				ServerCommand("kz_autorespawn 0");
		}					
		if(param2 == 10)
		{
			if (!g_bCleanWeapons)
				ServerCommand("kz_clean_weapons 1");
			else	
				ServerCommand("kz_clean_weapons 0");
		}
		if(param2 == 11)
		{
			if (!g_bRestore)
				ServerCommand("kz_restore 1");
			else
				ServerCommand("kz_restore 0");
		}
		if(param2 == 12)
		{
			if (!g_bPauseServerside)
				ServerCommand("kz_pause 1");
			else
				ServerCommand("kz_pause 0");
		}
		if(param2 == 13)
		{
			if (!g_bGoToServer)
				ServerCommand("kz_goto 1");
			else
				ServerCommand("kz_goto 0");
		}		
		if(param2 == 14)
		{
			if (!g_bRadioCommands)
				ServerCommand("kz_radio 1");
			else
				ServerCommand("kz_radio 0");
		}
		if(param2 == 15)
		{
			if (!g_bAutoTimer)
				ServerCommand("kz_auto_timer 1");
			else
				ServerCommand("kz_auto_timer 0");
		}
		if(param2 == 16)
		{
			if (!g_bReplayBot)
				ServerCommand("kz_replay_bot 1");
			else
				ServerCommand("kz_replay_bot 0");
		}	
		if(param2 == 17)
		{
			if (!g_bPreStrafe)
				ServerCommand("kz_prestrafe 1");
			else
				ServerCommand("kz_prestrafe 0");
		}	
		if(param2 == 18)
		{
			if (!g_bfpsCheck)
				ServerCommand("kz_fps_check 1");
			else
				ServerCommand("kz_fps_check 0");
		}
		if(param2 == 19)
		{
			if (!g_bPointSystem)
				ServerCommand("kz_point_system 1");
			else
				ServerCommand("kz_point_system 0");
		}	
		if(param2 == 20)
		{
			if (!g_bCountry)
				ServerCommand("kz_country_tag 1");
			else
				ServerCommand("kz_country_tag 0");
		}	
		if(param2 == 21)
		{
			if (!g_bPlayerSkinChange)
				ServerCommand("kz_custom_models 1");
			else
				ServerCommand("kz_custom_models 0");
		}	
		if(param2 == 22)
		{
			if (!g_bNoClipS)
				ServerCommand("kz_noclip 1");
			else
				ServerCommand("kz_noclip 0");
		}
		if(param2 == 23)
		{
			if (!g_bJumpStats)
				ServerCommand("kz_jumpstats 1");
			else
				ServerCommand("kz_jumpstats 0");
		}	
		if(param2 == 24)
		{
			if (!g_bAutoBhop)
				ServerCommand("kz_auto_bhop 1");
			else
				ServerCommand("kz_auto_bhop 0");
		}			
		if(param2 == 25)
		{
			if (!g_bAutoBan)
				ServerCommand("kz_anticheat_auto_ban 1");
			else
				ServerCommand("kz_anticheat_auto_ban 0");
		}
		if(param2 == 26)
		{
			if (!g_bMultiplayerBhop)
				ServerCommand("kz_multiplayer_bhop 1");
			else
				ServerCommand("kz_multiplayer_bhop 0");
		}	
		if(param2 == 27)
		{
			if (!g_bAdminClantag)
				ServerCommand("kz_admin_clantag 1");
			else
				ServerCommand("kz_admin_clantag 0");
		}	
		if(param2 == 28)
		{
			if (!g_bVipClantag)
				ServerCommand("kz_vip_clantag 1");
			else
				ServerCommand("kz_vip_clantag 0");
		}	
		if(param2 == 29)
		{
			if (!g_bMapEnd)
				ServerCommand("kz_map_end 1");
			else
				ServerCommand("kz_map_end 0");
		}	
		if(param2 == 30)
		{
			if (!g_bConnectMsg)
				ServerCommand("kz_connect_msg 1");
			else
				ServerCommand("kz_connect_msg 0");
		}	
		if(param2 == 31)
		{
			if (!g_bColoredChatRanks)
				ServerCommand("kz_colored_chatranks 1");
			else
				ServerCommand("kz_colored_chatranks 0");
		}
		if(param2 == 32)
		{
			if (!g_bAllowCpOnBhopPlattforms)
				ServerCommand("kz_checkpoints_on_bhop_plattforms 1");
			else
				ServerCommand("kz_checkpoints_on_bhop_plattforms 0");
		}
		if(param2 == 33)
		{
			if (!g_bInfoBot)
				ServerCommand("kz_info_bot 1");
			else
				ServerCommand("kz_info_bot 0");
		}	
		if(param2 == 34)
		{
			if (!g_bProMode)
				ServerCommand("kz_pro_mode 1");
			else
				ServerCommand("kz_pro_mode 0");
		}
		g_AdminMenuLastPage[param1] = param2;
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
		CreateTimer(0.1, RefreshAdminMenu, param1,TIMER_FLAG_NO_MAPCHANGE);
	}
				
	if(action == MenuAction_Cancel)
		g_bMenuOpen[param1] = false;

	if(action == MenuAction_End)
	{
		//test
		if (IsValidClient(param1))
		{
			g_bMenuOpen[param1] = false;
			if (menu != INVALID_HANDLE)
				CloseHandle(menu);
		}
	}
}

//Drop Map from DB
public Action:Admin_DropAllMapRecords(client, args)
{
	db_dropPlayer(client);
	return Plugin_Handled;
}

public Action:Admin_DropPlayerRanks(client, args)
{
	db_dropPlayerRanks(client)
	return Plugin_Handled;
}

public Action:Admin_DropPlayerJump(client, args)
{	
	db_dropPlayerJump(client);
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET ljrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "lj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_LjRank[i] = 99999999;
			g_js_fPersonal_Lj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllWjRecords(client, args)
{
	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET wjrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "wj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_WjRank[i] = 99999999;
			g_js_fPersonal_Wj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET bhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "bhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_BhopRank[i] = 99999999;
			g_js_fPersonal_Bhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllDropBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET dropbhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "dropbhop records reseted.");	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_DropBhopRank[i] = 99999999;
			g_js_fPersonal_DropBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllMultiBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET multibhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "multibhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjBlockRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET ljblockdist=-1");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "ljblock records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}


public Action:Admin_ResetRecords(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayertimes <steamid> [<mapname>]");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 5)
		{
			db_resetPlayerRecords(client, szSteamID);
		}
		else if(args == 6)
		{
			decl String:szMapName[MAX_MAP_LENGTH];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecords2(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetRecordTp(client, args)
{
	if(args != 6)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayertptime <steamid> <mapname>");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 6)
		{
			decl String:szMapName[MAX_MAP_LENGTH];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecordTp(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetRecordPro(client, args)
{
	if(args != 6)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerprotime <steamid> <mapname>");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 6)
		{
			decl String:szMapName[MAX_MAP_LENGTH];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecordPro(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}


public Action:Admin_ResetMapRecords(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetmaptimes <mapname>");
		return Plugin_Handled;
	}
	if(args == 1)
	{
		decl String:szMapName[128];
		GetCmdArg(1, szMapName, 128);		
		db_resetMapRecords(client, szMapName);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerLjRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLjBlockRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljblockrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerLjBlockRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_DeleteProReplay(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetproreplay <mapname>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szMap[128];
		decl String:szArg[128];
		Format(szMap, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szMap, 128, "%s%s",  szMap, szArg); 
		}
		DeleteReplay(client, 0, szMap);
	}
	return Plugin_Handled;
}

public Action:Admin_DeleteTpReplay(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resettpreplay <mapname>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szMap[128];
		decl String:szArg[128];
		Format(szMap, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szMap, 128, "%s%s",  szMap, szArg); 
		}
		DeleteReplay(client, 1, szMap);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetWjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetwjrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerWJRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetPlayerJumpstats(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerjumpstats <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerJumpstats(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetDropBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetdropbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerDropBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}


public Action:Admin_ResetBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetMultiBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetmultibhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerMultiBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_GetMulitplier(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_getmultiplier <steamid>");
		return Plugin_Handled;
	}
	new String:sql_selectMutliplier[] = "SELECT multiplier FROM playerrank where steamid = '%s'"; 
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		decl String:szQuery[512];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		Format(szQuery, 512, sql_selectMutliplier, szSteamID);
		SQL_TQuery(g_hDb, sql_selectMutliplierCallback, szQuery, client);	
	}
	return Plugin_Handled;
}

public sql_selectMutliplierCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new multiplier = SQL_FetchInt(hndl, 0);
		PrintToConsole(client, "mutliplier = %i (points per multiplier %i)", multiplier,g_pr_PointUnit);
	}    
}

public Action:Admin_SetMulitplier(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_getmultiplier <steamid> <multiplier>");
		return Plugin_Handled;
	}
	
	new String:sql_updateMultiplier[] = "UPDATE playerrank SET multiplier ='%i' where steamid='%s'";
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		new multiplier;
		decl String:szQuery[512];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		GetCmdArg(6, szArg, 128);	
		multiplier = StringToInt(szArg);  
		Format(szQuery, 512, sql_updateMultiplier, multiplier, szSteamID);
		SQL_TQuery(g_hDb, sql_updateMultiplierCallback, szQuery, client);	
		PrintToConsole(client, "mutliplier changed to %s (player needs to recalc his points via his profile menu", szArg);
	}
	return Plugin_Handled;
}

public sql_updateMultiplierCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
}