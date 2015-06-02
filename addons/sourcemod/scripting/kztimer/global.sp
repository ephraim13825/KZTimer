//
// GLOBAL RECORD SYSTEM
// extra protection methods: map file size check, blocking of unauthorized teleports or other quick position changes through crazy shit, 
// noclip, player slapping, m_flLaggedMovementValue, autobhop, m_flGravity and hook events
//
//

// sql statements
new String:sqlglobal_selectFilesize[] 			= "SELECT filesize, mapname FROM maplist where mapname = '%s'";
new String:sqlglobal_insertFilesize[] 			= "INSERT INTO maplist (mapname, filesize) VALUES('%s', '%i');";
new String:sqlglobal_insertBan[] 					= "INSERT INTO banlist_new (steamid, playername, playercountry, reason, stats, serverip, servername, unix_timestamp) VALUES('%s', '%s', '%s', '%s','%s','%s', '%s', '%i');";
new String:sqlglobal_deleteban1[] 				= "DELETE FROM player64 WHERE steamid = '%s'"; 
new String:sqlglobal_deleteban2[] 				= "DELETE FROM player128 WHERE steamid = '%s'"; 
new String:sqlglobal_deleteban3[] 				= "DELETE FROM player102 WHERE steamid = '%s'"; 
new String:sqlglobal_selectGlobalRecord[] 		= "SELECT player, runtime, teleports FROM player64 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectGlobalTop[] 			= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player64 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectTop5Players[] 		= "SELECT runtime, steamid FROM player64 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectPlayers[] 			= "SELECT runtime, steamid, mapname FROM player64 WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer[] 				= "DELETE FROM player64 WHERE steamid = '%s' AND mapname = '%s'"; 
new String:sqlglobal_insertPlayer[] 				= "INSERT INTO player64 (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_updatePlayer[] 				= "UPDATE player64 SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';"; 
new String:sqlglobal_selectGlobalRecord102[] 	= "SELECT player, runtime, teleports FROM player102 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectGlobalTop102[] 		= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player102 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectTop5Players102[] 	= "SELECT runtime, steamid FROM player102 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectPlayers102[] 		= "SELECT runtime, steamid, mapname FROM player102 WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer102[] 			= "DELETE FROM player102 WHERE steamid = '%s' AND mapname = '%s'"; 
new String:sqlglobal_insertPlayer102[] 			= "INSERT INTO player102 (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_updatePlayer102[] 			= "UPDATE player102 SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';"; 
new String:sqlglobal_selectGlobalRecord128[] 	= "SELECT player, runtime, teleports FROM player128 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectGlobalTop128[] 		= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player128 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectTop5Players128[] 	= "SELECT runtime, steamid FROM player128 WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 5";
new String:sqlglobal_selectPlayers128[] 		= "SELECT runtime, steamid, mapname FROM player128 WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer128[] 			= "DELETE FROM player128 WHERE steamid = '%s' AND mapname = '%s'"; 
new String:sqlglobal_insertPlayer128[] 			= "INSERT INTO player128 (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_updatePlayer128[] 			= "UPDATE player128 SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';"; 


ConnectToGlobalDB()
{
	decl String:szError[255];
	new Handle:kv = INVALID_HANDLE;
	kv = CreateKeyValues("");
	KvSetString(kv, "driver", "mysql");
	KvSetString(kv, "host", "85.10.205.173");
	KvSetString(kv, "port", "3306");
	KvSetString(kv, "database", "kzglobal");
	KvSetString(kv, "user", "kzglobal");
	KvSetString(kv, "pass", "globalkz$123");            
	g_hDbGlobal = SQL_ConnectCustom(kv, szError, sizeof(szError), true);      
	if (g_hDbGlobal != INVALID_HANDLE)
		SQL_FastQuery(g_hDbGlobal,"SET NAMES  'utf8'");
}

public GetGlobalRecord()
{
	decl String:mapPath[256];
	new bool: fileFound;
	GetCurrentMap(g_szMapName, 128);
	Format(mapPath, sizeof(mapPath), "maps/%s.bsp", g_szMapName); 	
	fileFound = FileExists(mapPath);
	//valid timestamp? [global db]
	if (fileFound && g_hDbGlobal != INVALID_HANDLE)
	{	
		g_global_MapFileSize =  FileSize(mapPath);
		//supported map tags 
		if(StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc") || StrEqual(g_szMapPrefix[0],"bkz"))
			dbCheckFileSize();
	}
}

public CheckForWorkshopMap()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	if (StrContains(g_szMapPath, "/workshop/", true) != -1)
	{
		Format(g_global_szGlobalMapName,128,"%s",g_szMapName);	
		UpdateFileSize();
	}
	/*//KREEDZ EUROPE SERVER?
	if (StrEqual(g_szServerIp, "37.187.171.52:28015"))
	{
		Format(g_global_szGlobalMapName,128,"%s",g_szMapName);	
		UpdateFileSize2();
	}*/
	
}

UpdateFileSize()
{
	//decl String:szQuery[512];
	//Format(szQuery, 512, "UPDATE maplist SET filesize = '%i' where mapname='%s'", g_global_MapFileSize,g_global_szGlobalMapName); 
	//SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	g_global_ValidFileSize = true;
	g_global_IntegratedButtons = true;		
	db_GetMapRecord_Global();
}
/*
UpdateFileSize2()
{
	decl String:szQuery[512];
	Format(szQuery, 512, "UPDATE maplist SET filesize = '%i' where mapname='%s'", g_global_MapFileSize,g_global_szGlobalMapName); 
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	g_global_ValidFileSize = true;
	g_global_IntegratedButtons = true;		
	db_GetMapRecord_Global();
}*/

public GlobalTeleportCheck(client, Float: origin[3])
{
	if (g_global_bUnauthorisedTele[client])
		return;
		
	if (IsPlayerAlive(client) && g_global_IntegratedButtons && !g_global_VersionBlocked && g_bLegitButtons[client] && g_global_EntityCheck && !g_global_SelfBuiltButtons && g_hDbGlobal != INVALID_HANDLE && g_bEnforcer && g_bAntiCheat && g_global_ValidFileSize && !g_bAutoTimer)	
	{	
		new Float:fOriginDiff = FloatAbs(GetVectorDistance(g_fLastPosition[client],origin));
		if (fOriginDiff > 100.0 && !g_bValidTeleport[client])
			g_global_bUnauthorisedTele[client] = true;	
	}
}
public Action:Client_GlobalTop(client, args)
{	
	if (IsValidClient(client))
	{
		PrintToChat(client,"[%cKZ%c]%c Loading html page.. (requires cl_disablehtmlmotd 0)", MOSSGREEN,WHITE,LIMEGREEN);
		ShowMOTDPanel(client, "globaltop" ,"http://kuala-lumpur-court-8417.pancakeapps.com/global_index.html", 2);
	}
	return Plugin_Handled;
}

public Action:Client_Join(client, args)
{	
	if (IsValidClient(client))
	{
		PrintToChat(client,"[%cKZ%c]%c Loading html page.. (requires cl_disablehtmlmotd 0)", MOSSGREEN,WHITE,LIMEGREEN);
		ShowMOTDPanel(client, "globaltop" ,"http://kuala-lumpur-court-8417.pancakeapps.com/steamgroup.html", 2);
	}
	return Plugin_Handled;
}

public Action:Client_GlobalCheck(client, args) 
{
	new reason = 0;
	if (g_global_Disabled)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records has been temporarily disabled. For more information visit the KZTimer steam group!",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	if(!StrEqual(g_szMapPrefix[0],"kz") && !StrEqual(g_szMapPrefix[0],"xc") && !StrEqual(g_szMapPrefix[0],"bkz")  && !StrEqual(g_szMapPrefix[0],"kzpro"))
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Only bkz_, kz_,kzpro_ and xc_ maps supported!",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	new bool:gbcheck=true;
	if (g_hDbGlobal == INVALID_HANDLE)
	{
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: No connection to the global database.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	if (g_bGlobalBeta)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: Map is in alpha/beta status!",MOSSGREEN,WHITE,RED,reason);
	}
	if (g_global_VersionBlocked)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: This server is running an outdated KZTimer version. Contact an admin!",MOSSGREEN,WHITE,RED,reason);
	}
	if (g_global_SelfBuiltButtons)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: Self-built climb buttons detected. (only built-in buttons supported)",MOSSGREEN,WHITE,RED,reason);
	}
	else
	{
		if (!g_global_EntityCheck)	
		{	
			reason++;
			gbcheck=false;
			PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: Custom entities/props found.",MOSSGREEN,WHITE,RED,reason);
		}
		if (!g_global_IntegratedButtons)
		{
			reason++;
			gbcheck=false;
			PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: This map does not provide built-in climb buttons.",MOSSGREEN,WHITE,RED,reason);
		}
	}
	if (!g_bEnforcer)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: kz_settings_enforcer is disabled.",MOSSGREEN,WHITE,RED,reason);
	}	
	if (!g_global_ValidFileSize && g_global_IntegratedButtons)
	{
		reason++;
		gbcheck=false;
		if (g_global_WrongMapVersion)
			PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: Wrong map version. (requires latest+offical workshop version)",MOSSGREEN,WHITE,RED,reason);	
		else
			PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i:  Wrong map file size. (requires latest+offical workshop version)",MOSSGREEN,WHITE,RED,reason);	
	}	
	if (!g_bAntiCheat)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: KZ AntiCheat is disabled.",MOSSGREEN,WHITE,RED,reason);
	}	
	if (g_bAutoTimer)
	{
		reason++;
		gbcheck=false;
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason #%i: kz_auto_timer is enabled.",MOSSGREEN,WHITE,RED,reason);
	}	
	if (gbcheck)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal records are enabled.",MOSSGREEN,WHITE,GREEN);
	}	
	return Plugin_Handled;
}

//SQL STUFF
public dbGetGlobalBanList()
{
	//clear array
	for (new i = 0; i < sizeof(g_szGlobalBanList); i++)
		Format(g_szGlobalBanList[i], sizeof(g_szGlobalBanList), "");
	if (g_hDbGlobal == INVALID_HANDLE) return;
	SQL_TQuery(g_hDbGlobal, dbGetGlobalBanListCallback, "SELECT DISTINCT steamid from banlist_new",DBPrio_Low);
}

public dbGetGlobalBanListCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	if (hndl == INVALID_HANDLE)
		return;	
	new count = 0;
	if(SQL_HasResultSet(hndl))
	{		
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, g_szGlobalBanList[count], 32);	
			count++; 
		}
	}
}
//ccc
public dbCheckFileSize()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;	
	decl String:szQuery[256];
	Format(szQuery, 256, sqlglobal_selectFilesize, g_szMapName);
	SQL_TQuery(g_hDbGlobal, sqlglobal_selectFilesizeCallback, szQuery,DBPrio_Low);
}

public sqlglobal_selectFilesizeCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	if (hndl == INVALID_HANDLE)
	{
		g_global_ValidFileSize=false;
		return;
	}
	
	Format(g_global_szGlobalMapName,128,"");		
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{		
		new filesize = SQL_FetchInt(hndl, 0);
		//map version blocked
		if (filesize == 1)
			return;
		//wrong mapname but maybe just renamed?
		if (filesize == 1337)
		{
			SQL_TQuery(g_hDbGlobal, sqlglobal_selectFilesizeCallback2, "SELECT filesize, mapname FROM maplist",DBPrio_Low);
		}
		else
		{
			//nobody should know about those exceptions :P ... reason: different versions with the same map name released
			if (StrEqual(g_szMapName,"kz_j2s_cupblock_go") || StrEqual(g_szMapName,"kz_summercliff2_go") || StrEqual(g_szMapName,"kz_bhop_lj") || StrEqual(g_szMapName,"kz_chinablock")  || StrEqual(g_szMapName,"kz_christmas"))
			{	
				g_global_ValidFileSize=true;
				Format(g_global_szGlobalMapName,128,"%s",g_szMapName);	
				g_global_IntegratedButtons = true;			
				db_GetMapRecord_Global();
			}
			else
			if (filesize == g_global_MapFileSize)
			{
				g_global_ValidFileSize=true;
				Format(g_global_szGlobalMapName,128,"%s",g_szMapName);	
				g_global_IntegratedButtons = true;			
				db_GetMapRecord_Global();
			}
			else
			{
				//minor map update? a tiny difference in the file size are pretty sure a map update with bug fixes (tolerance: 0.0596046mb)
				new diff;
				if (g_global_MapFileSize > filesize)
				{
					diff = g_global_MapFileSize - filesize;
					if (diff < 100000)
					{
						Format(g_global_szGlobalMapName,128,"%s",g_szMapName);	
						UpdateFileSize();
					}
				}
				else
				{
					g_global_ValidFileSize=false;
					CheckForWorkshopMap();
				}
			}
		}
	}
	else
	{
		if (g_hDbGlobal == INVALID_HANDLE) return;	
		SQL_TQuery(g_hDbGlobal, sqlglobal_selectFilesizeCallback2, "SELECT filesize, mapname FROM maplist",DBPrio_Low);
	}
}

public sqlglobal_selectFilesizeCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	if(SQL_HasResultSet(hndl))
	{		
		while (SQL_FetchRow(hndl))
		{
			new filesize = SQL_FetchInt(hndl, 0);
			if (filesize == g_global_MapFileSize)
			{
				SQL_FetchString(hndl, 1, g_global_szGlobalMapName, 128);	
				g_global_ValidFileSize=true;
				g_global_IntegratedButtons=true;
				db_GetMapRecord_Global();
				return;	
			}
		}
		
		//does the map contains a func_button?
		new String:classname[32];
		for (new i; i < GetEntityCount(); i++)
		{
			if (IsValidEdict(i) && GetEntityClassname(i, classname, 32) && (StrContains(classname, "player") == -1) && (StrContains(classname, "weapon") == -1) && (StrContains(classname, "predicted_viewmodel") == -1))
			{
				//its not possible to search for the targetname climb_startbutton/climb_endbutton because those func_buttons are not listed on a few maps .. dunno why
				if(StrEqual(classname, "func_button"))
				{
					g_global_IntegratedButtons=true;
					Format(g_global_szGlobalMapName,128,"%s",g_szMapName);
					dbInsertGlobalMap();
					break;
				}
			}
			new x = i+1;
			if (x == GetEntityCount())
				g_global_IntegratedButtons=false;
		}
	}	
}

public dbInsertGlobalMap()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;	
	decl String:szQuery[256];
	Format(szQuery, 256, sqlglobal_insertFilesize, g_global_szGlobalMapName,g_global_MapFileSize);
	SQL_TQuery(g_hDbGlobal, sqlglobal_insertFilesizeCallback, szQuery,DBPrio_Low);
}

public db_VersionCheck()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;	
	g_global_VersionBlocked = false;
	decl String:szQuery[128];
	Format(szQuery, 128, "select version, min_version from version");
	SQL_TQuery(g_hDbGlobal, sqlglobal_VersionCheckCallback, szQuery,DBPrio_Low);
}

public sqlglobal_VersionCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, g_global_szLatestGlobalVersion, 32);
			new version = SQL_FetchInt(hndl, 1);		
			if (PLUGIN_VERSION < version)
			{
				if (version == 999)
					g_global_Disabled=true;
				else
					g_global_Disabled=false;
				g_global_VersionBlocked = true;	
			}
		}
	}
}

public db_InsertBan(String:szSteamId[32], String:szName[64], String:szCountry[100], String:szReason[256], String:szStats[256])
{
	if (g_hDbGlobal == INVALID_HANDLE) 
		return;	
	decl String:szQuery[1024];
	ReplaceChar("'", "`", g_szServerName);
	new UnixTimestamp;
	UnixTimestamp = GetTime();
	Format(szQuery, 1024, sqlglobal_insertBan, szSteamId,szName, szCountry, szReason, szStats, g_szServerIp, g_szServerName,UnixTimestamp);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery,DBPrio_Low);
	Format(szQuery, 1024, sqlglobal_deleteban1, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery,DBPrio_Low);	
	Format(szQuery, 1024, sqlglobal_deleteban2, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery,DBPrio_Low);	
	Format(szQuery, 1024, sqlglobal_deleteban3, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery,DBPrio_Low);	
	
	for (new i = 0; i < sizeof(g_szGlobalBanList); i++)
	{
		if (StrEqual(g_szGlobalBanList[i],""))
		{
			Format(g_szGlobalBanList[i], 32, "%s", szSteamId);
			return;
		}
	}
}

public sqlglobal_insertFilesizeCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	g_global_ValidFileSize=true;
	db_GetMapRecord_Global();	
}

public db_deleteInvalidGlobalEntries()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;		
	decl String:szQuery[255];      
	if (g_Server_Tickrate==64)
		Format(szQuery, 255, sqlglobal_selectPlayers, g_global_szGlobalMapName); 
	if (g_Server_Tickrate==102)
		Format(szQuery, 255, sqlglobal_selectPlayers102, g_global_szGlobalMapName); 
	if (g_Server_Tickrate==128)
		Format(szQuery, 255, sqlglobal_selectPlayers128, g_global_szGlobalMapName); 
	SQL_TQuery(g_hDbGlobal, sqlglobal_selectPlayers2Callback, szQuery,DBPrio_Low);	
}

public sqlglobal_selectPlayers2Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	decl String:szQuery[255];
	decl String:szMapname[64];
	decl String:szSteamid[32];   
	new i=1;
	if(SQL_HasResultSet(hndl))
	{		
		while (SQL_FetchRow(hndl))
		{
			if (i>5)
			{
				SQL_FetchString(hndl, 1, szSteamid, 32);
				SQL_FetchString(hndl, 2, szMapname, 64);
				if (g_Server_Tickrate==64)
					Format(szQuery, 255, sqlglobal_deletePlayer, szSteamid,szMapname);      
				if (g_Server_Tickrate==128)
					Format(szQuery, 255, sqlglobal_deletePlayer128, szSteamid,szMapname); 
				if (g_Server_Tickrate==102)
					Format(szQuery, 255, sqlglobal_deletePlayer102, szSteamid,szMapname); 
				SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery,DBPrio_Low);	
			}
			i++;
		}
	}
}
			
public db_GetMapRecord_Global()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[255];    
	if (g_Server_Tickrate==64)
	{
		Format(szQuery, 255, sqlglobal_selectGlobalRecord, g_global_szGlobalMapName);  
		SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalCallback, szQuery,DBPrio_Low);
	}
	else
	{
		if (g_Server_Tickrate==128)
		{
			Format(szQuery, 255, sqlglobal_selectGlobalRecord128, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobal128Callback, szQuery,DBPrio_Low);
		}
		else
		{		
			Format(szQuery, 255, sqlglobal_selectGlobalRecord102, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sqlglobal_selectGlobalRecord102Callback, szQuery,DBPrio_Low);	
		}
	}
}
public sql_selectMapRecordGlobalCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			if (SQL_FetchFloat(hndl, 0) > -1.0)
			{
				SQL_FetchString(hndl, 0, g_global_RecordPlayerName64, MAX_NAME_LENGTH);
				g_global_fRecordTime64 = SQL_FetchFloat(hndl, 1);		
			}
			else
				g_global_fRecordTime64 = 9999999.0;	
		}
		else
			g_global_fRecordTime64 = 9999999.0;	

	}
}

public sqlglobal_selectGlobalRecord102Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			if (SQL_FetchFloat(hndl, 0) > -1.0)
			{		
				SQL_FetchString(hndl, 0, g_global_RecordPlayerName102, MAX_NAME_LENGTH);
				g_global_fRecordTime102 = SQL_FetchFloat(hndl, 1);		
			}
			else
				g_global_fRecordTime102 = 9999999.0;	
		}
		else
			g_global_fRecordTime102 = 9999999.0;		
	}	
}


public sql_selectMapRecordGlobal128Callback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			if (SQL_FetchFloat(hndl, 0) > -1.0)
			{
				SQL_FetchString(hndl, 0, g_global_RecordPlayerName128, MAX_NAME_LENGTH);
				g_global_fRecordTime128 = SQL_FetchFloat(hndl, 1);		
			}
			else
				g_global_fRecordTime128 = 9999999.0;	
		}
		else
			g_global_fRecordTime128 = 9999999.0;		
	}	
}

public db_selectGlobalTopClimbers(client, String:mapname[128])
{ 
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];   
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);    
	Format(szQuery, 1024, sqlglobal_selectGlobalTop, mapname);   
	if (g_hDbGlobal != INVALID_HANDLE)
	SQL_TQuery(g_hDbGlobal, sql_selectGlobalTopClimbers, szQuery, pack,DBPrio_Low);
}

public sql_selectGlobalTopClimbers(Handle:owner, Handle:hndl, const String:error[], any:data)
{   	
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	CloseHandle(pack); 
	if (g_hDbGlobal == INVALID_HANDLE) return;
	if (hndl != INVALID_HANDLE)
		if(SQL_HasResultSet(hndl))
		{		
			decl String:szValue[128];
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szSteamid[32];
			decl String:szCountry[64];
			decl String:szTeleports[32];
			new Float:time;
			new teleports;
			new Handle:menu = CreateMenu(GlobalMapMenuHandler);	
			SetMenuPagination(menu, 5);
			decl String:title[512];
			Format(title, 512, "Top 5 Global Times on %s (tickrate 64)\nType !globaltop in chat for more information\n       Time            TP's      Player", mapname);
			SetMenuTitle(menu, title);			
			new i=1;
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
				time = SQL_FetchFloat(hndl, 1); 
				teleports = SQL_FetchInt(hndl, 2);	
				SQL_FetchString(hndl, 3, szSteamid, 32);
				SQL_FetchString(hndl, 4, szCountry, 64);	
				if (teleports < 10)
					Format(szTeleports, 32, "    %i",teleports);
					else
				if (teleports < 100)
					Format(szTeleports, 32, "  %i",teleports);
				else
					Format(szTeleports, 32, "%i",teleports);
				
				decl String:szTime[32];
				FormatTimeFloat(client, time, 3,szTime,32);		
				if (time<3600.0)
					Format(szTime, 32, "   %s", szTime);				
				Format(szValue, 128, "%s  |  %s    » %s (%s, %s)", szTime, szTeleports, szName, szCountry,szSteamid);
						
				AddMenuItem(menu, szValue, szValue, ITEMDRAW_DEFAULT);
				i++;
			}
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			if (i == 1 && IsValidClient(client))
				PrintToChat(client, "%t", "NoGlobalRecords64", MOSSGREEN,WHITE, mapname);
		}	
}

public db_selectGlobalTopClimbers128(client, String:mapname[128])
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];       
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	Format(szQuery, 1024, sqlglobal_selectGlobalTop128, mapname);   
	if (g_hDbGlobal != INVALID_HANDLE)
		SQL_TQuery(g_hDbGlobal, sql_selectGlobalTopClimbers128, szQuery, pack,DBPrio_Low);
}

public sql_selectGlobalTopClimbers128(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	CloseHandle(pack);
	if (hndl != INVALID_HANDLE)
		if(SQL_HasResultSet(hndl))
		{		
			decl String:szValue[128];
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szTeleports[32];
			decl String:szSteamid[32];
			decl String:szCountry[64];
			new Float:time;
			new teleports;
			new Handle:menu = CreateMenu(GlobalMapMenuHandler);	
			SetMenuPagination(menu, 5);
			decl String:title[512];
			Format(title, 512, "Top 5 Global Times on %s (tickrate 128)\nType !globaltop in chat for more information\n       Time            TP's      Player", mapname);
			SetMenuTitle(menu, title);			
			new i=1;
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
				time = SQL_FetchFloat(hndl, 1); 
				teleports = SQL_FetchInt(hndl, 2);
				SQL_FetchString(hndl, 3, szSteamid, 32);	
				SQL_FetchString(hndl, 4, szCountry, 64);	
				if (teleports < 10)
					Format(szTeleports, 32, "    %i",teleports);
					else
				if (teleports < 100)
					Format(szTeleports, 32, "  %i",teleports);
				else
					Format(szTeleports, 32, "%i",teleports);
			
				decl String:szTime[32];
				FormatTimeFloat(client, time, 3,szTime,32);		
				if (time<3600.0)
					Format(szTime, 32, "   %s", szTime);				
				Format(szValue, 128, "%s  |  %s    » %s (%s, %s)", szTime, szTeleports, szName, szCountry,szSteamid);
						
				AddMenuItem(menu, szValue, szValue, ITEMDRAW_DEFAULT);
				i++;
			}
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			if (i == 1 && IsValidClient(client))
				PrintToChat(client, "%t", "NoGlobalRecords128", MOSSGREEN,WHITE, mapname);
		}
		
}

public db_selectGlobalTopClimbers102(client, String:mapname[128])
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	decl String:szQuery[1024];       
	Format(szQuery, 1024, sqlglobal_selectGlobalTop102, mapname);   
	if (g_hDbGlobal != INVALID_HANDLE)
		SQL_TQuery(g_hDbGlobal, sql_selectGlobalTopClimbers102, szQuery, pack,DBPrio_Low);
}

public sql_selectGlobalTopClimbers102(Handle:owner, Handle:hndl, const String:error[], any:data)
{   
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);	
	CloseHandle(pack);
	if (hndl != INVALID_HANDLE)
		if(SQL_HasResultSet(hndl))
		{		
			decl String:szValue[128];
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szTeleports[32];
			decl String:szSteamid[32];
			decl String:szCountry[64];
			new Float:time;
			new teleports;
			new Handle:menu = CreateMenu(GlobalMapMenuHandler);	
			SetMenuPagination(menu, 5);
			decl String:title[512];
			Format(title, 512, "Top 5 Global Times on %s (tickrate 102.4)\nType !globaltop in chat for more information\n       Time            TP's      Player", mapname);
			SetMenuTitle(menu, title);
			new i=1;
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
				time = SQL_FetchFloat(hndl, 1); 
				teleports = SQL_FetchInt(hndl, 2);	
				SQL_FetchString(hndl, 3, szSteamid, 32);
				SQL_FetchString(hndl, 4, szCountry, 64);	
				if (teleports < 10)
					Format(szTeleports, 32, "    %i",teleports);
					else
				if (teleports < 100)
					Format(szTeleports, 32, "  %i",teleports);
				else
					Format(szTeleports, 32, "%i",teleports);
			
				decl String:szTime[32];
				FormatTimeFloat(client, time, 3,szTime,32);			
				if (time<3600.0)
					Format(szTime, 32, "   %s", szTime);				
				Format(szValue, 128, "%s  |  %s    » %s (%s, %s)", szTime, szTeleports, szName,szCountry,szSteamid);
						
				AddMenuItem(menu, szValue, szValue, ITEMDRAW_DEFAULT);
				i++;
			}
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			if (i == 1 && IsValidClient(client))
				PrintToChat(client, "%t", "NoGlobalRecords102", MOSSGREEN,WHITE, mapname);
		}
		
}

public db_insertGlobalRecord(client)
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];
	decl String:szSteamId[32];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
		return;	
	decl String:szName[MAX_NAME_LENGTH*2+1];      
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	ReplaceChar("'", "`", g_szServerName);
	
	if (g_Tp_Final[client]<0)
		g_Tp_Final[client]=0;
	if (g_Server_Tickrate==64)
		Format(szQuery, 1024, sqlglobal_insertPlayer, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
	if (g_Server_Tickrate==128)
		Format(szQuery, 1024, sqlglobal_insertPlayer128, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
	if (g_Server_Tickrate==102)
		Format(szQuery, 1024, sqlglobal_insertPlayer102, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);

	SQL_TQuery(g_hDbGlobal, SQL_GlobalCallback, szQuery,DBPrio_Low);	

	//update name
	Format(szQuery, 1024, "UPDATE player64 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
}

public SQL_GlobalCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	db_deleteInvalidGlobalEntries();
}

public db_updateGlobalRecord(client)
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];
	decl String:szSteamId[32];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
		return;
	
	decl String:szName[MAX_NAME_LENGTH*2+1];      
	SQL_QuoteString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
	ReplaceChar("'", "`", g_szServerName);
	
	if (g_Tp_Final[client]<0)
		g_Tp_Final[client]=0;
		
	if (g_Server_Tickrate==64)
		Format(szQuery, 1024, sqlglobal_updatePlayer, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName); 
	if (g_Server_Tickrate==128)
		Format(szQuery, 1024, sqlglobal_updatePlayer128, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode,szSteamId, g_global_szGlobalMapName); 
	if (g_Server_Tickrate==102)
		Format(szQuery, 1024, sqlglobal_updatePlayer102, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode,szSteamId, g_global_szGlobalMapName); 

	SQL_TQuery(g_hDbGlobal, SQL_GlobalCallback, szQuery,DBPrio_Low);

	//update name
	Format(szQuery, 1024, "UPDATE player64 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128 SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
}

public db_GlobalRecord(client)
{
	if (g_hDbGlobal != INVALID_HANDLE)
	{
		decl String:szQuery[1024];

		if (g_Server_Tickrate==64)
			Format(szQuery, 1024, sqlglobal_selectTop5Players, g_global_szGlobalMapName);
		if (g_Server_Tickrate==128)
			Format(szQuery, 1024, sqlglobal_selectTop5Players128, g_global_szGlobalMapName);
		if (g_Server_Tickrate==102)
			Format(szQuery, 1024, sqlglobal_selectTop5Players102, g_global_szGlobalMapName);

		SQL_TQuery(g_hDbGlobal, SQL_SelectGlobalPlayersCallback, szQuery, client);	
	}
}
public SQL_SelectGlobalPlayersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{       
	new client = data;
	new Float: time;
	decl String:szSteamId[32];
	decl String:szSteamId2[32];
	new counter=0;
	new bool: newtime=false;
	new bool: newpersonalbest=false;
	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);	
		if (hndl == INVALID_HANDLE)
		{
		}
		else
		if(SQL_HasResultSet(hndl))
		{
			while (SQL_FetchRow(hndl))
			{		
				time = SQL_FetchFloat(hndl, 0);
				SQL_FetchString(hndl, 1, szSteamId2, 32);
				if (g_fFinalTime[client] < time && (!StrEqual(szSteamId,szSteamId2)))
					newtime=true;
				if (StrEqual(szSteamId,szSteamId2) && g_fFinalTime[client] < time)
					newpersonalbest=true;
				counter++;
			}
			if (newpersonalbest)
			{
				db_updateGlobalRecord(client);
			}
			else
				if (newtime || counter<5)
				{
					db_insertGlobalRecord(client);	
				}
		}
	}
}

public GlobalMapMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Cancel || action ==  MenuAction_Select)
	{
		MapTopMenu(param1,g_szMapTopName[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//REAL BHOP BLOCK..
HookTriggerPushes()
{
    // hook trigger_pushes to disable velocity calculation in these, allowing
    // the push to be applied correctly
    new index = -1;
    while ((index = FindEntityByClassname2(index, "trigger_push")) != -1) {
        SDKHook(index, SDKHook_StartTouch, Event_EntityOnStartTouch);
        SDKHook(index, SDKHook_EndTouch, Event_EntityOnEndTouch);
    }
}

FindEntityByClassname2(startEnt, const String:classname[])
{
    /* If startEnt isn't valid shifting it back to the nearest valid one */
    while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
    
    return FindEntityByClassname(startEnt, classname);
}

public Event_EntityOnStartTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = true;
    }
}

public Event_EntityOnEndTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = false;
    }
}

ResetValues(client)
{
    FloorFrames[client] = 12 + 1;
    AirSpeed[client][0] = 0.0;
    AirSpeed[client][1] = 0.0;
    AfterJumpFrame[client] = false;
    PlayerInTriggerPush[client] = false;
}