ConnectToGlobalDB()
{
	decl String:szError[255];
	new Handle:kv = INVALID_HANDLE;
	kv = CreateKeyValues("");
	KvSetString(kv, "driver", "mysql");
	KvSetString(kv, "host", "db4free.net");
	KvSetString(kv, "port", "3306");
	KvSetString(kv, "database", "kzmodonline");
	KvSetString(kv, "user", "abckrieger");
	KvSetString(kv, "pass", "kzleet5");       

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
	tmp =  FindPluginByFile("infinite-jumping.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload infinite-jumping.smx");
	tmp = FindPluginByFile("abner_bhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload abner_bhop.smx");
	tmp = FindPluginByFile("abner_bhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload abner_bhop.smx");
	tmp = FindPluginByFile("rfb_bhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload rfb_bhop.smx");		 
	tmp = FindPluginByFile("quake_bhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload quake_bhop.smx");			 
	tmp = FindPluginByFile("bhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload bhop.smx");	
	tmp = FindPluginByFile("bunnyhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload bunnyhop.smx");	
	tmp = FindPluginByFile("bhopcommands.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload bhopcommands.smx");	
	tmp = FindPluginByFile("autobhop.smx");
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload autobhop.smx");	
	tmp = FindPluginByFile("cPMod.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload cPMod.smx");	
	tmp = FindPluginByFile("sm_cpsaver.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload sm_cpsaver.smx");	
	tmp = FindPluginByFile("cPMod.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload cPMod.smx");	
	tmp = FindPluginByFile("timer-cpmod.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload timer-cpmod.smx");	
	tmp = FindPluginByFile("timer-checkpoints.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload timer-checkpoints.smx");		
	tmp = FindPluginByFile("timer-core.smx");	 
	if (tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running) 
		 ServerCommand("sm plugins unload timer-core.smx");			 
	if (tmp != INVALID_HANDLE)
		CloseHandle(tmp);
	return Plugin_Continue;
}
