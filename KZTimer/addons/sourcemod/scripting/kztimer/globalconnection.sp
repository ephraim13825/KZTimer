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
	if (g_hDbGlobal != INVALID_HANDLE)
		SQL_FastQuery(g_hDbGlobal,"SET NAMES  'utf8'");
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
		
	//protection
	//..
	return Plugin_Continue;
}