ConnectToGlobalDB()
{
	decl String:szError[255];
	new Handle:kv = INVALID_HANDLE;
	kv = CreateKeyValues("");
	KvSetString(kv, "driver", "mysql");
	KvSetString(kv, "host", "private");
	KvSetString(kv, "port", "3306");
	KvSetString(kv, "database", "private");
	KvSetString(kv, "user", "private");
	KvSetString(kv, "pass", "private");       

	g_hDbGlobal = SQL_ConnectCustom(kv, szError, sizeof(szError), true);      
	if (g_hDbGlobal == INVALID_HANDLE && g_bGlobalDB)
	{
		//
	}
	else
		SQL_TQuery(g_hDbGlobal, sql_UpdateCallback, "SELECT latest from version");
}

public sql_UpdateCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	
	decl String:szVersion[16];
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, szVersion, 16);
		if (!StrEqual(szVersion,VERSION))
			g_bUpdate=true;
		else
			g_bUpdate=false;
	}
}

public Action:SecretTimer(Handle:timer)
{
	//AutoBhop?
	if(StrEqual(g_szMapTag[0],"surf") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"mg"))
		if (g_bAutoBhop)
			g_bAutoBhop2=true;		
	//cheat protection
	if((StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc") || StrEqual(g_szMapTag[0],"bkz")) || g_bAutoBhop2 == false)
		g_bAntiCheat=true;
		
	new Handle:tmp = FindPluginByFile("macrodox.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running)
		ServerCommand("sm plugins unload macrodox.smx");
	if (tmp != INVALID_HANDLE)
		CloseHandle(tmp);
	return Plugin_Continue;
}
