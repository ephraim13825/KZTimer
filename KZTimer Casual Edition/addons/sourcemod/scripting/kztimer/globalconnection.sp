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
		LogError("[KZ] Unable to connect to global database (%s)", szError);
	}
	else
		g_BGlobalDBConnected=true;
}

public Action:CheckPlugins(Handle:timer)
{
	//priv
}

