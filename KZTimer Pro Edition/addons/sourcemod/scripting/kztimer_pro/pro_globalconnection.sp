ConnectToGlobalDB()
{
	decl String:szError[255];
	new Handle:kv = INVALID_HANDLE;
	kv = CreateKeyValues("");
	KvSetString(kv, "driver", "mysql");
	KvSetString(kv, "host", "private");
	KvSetString(kv, "port", "private");
	KvSetString(kv, "database", "private");
	KvSetString(kv, "user", "private");
	KvSetString(kv, "pass", "private");      
      
	g_hDbGlobal = SQL_ConnectCustom(kv, szError, sizeof(szError), true);      
	if (g_hDbGlobal == INVALID_HANDLE && g_bGlobalDB)
	{
		LogError("[KZPro] Unable to connect to global database");
	}
	else
	{
		g_BGlobalDBConnected=true;
	}
}

public Action:SecretTimer(Handle:timer)
{
	//private
}
