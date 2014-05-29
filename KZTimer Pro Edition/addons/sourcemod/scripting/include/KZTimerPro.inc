#if defined _KZTimerPro_included
 #endinput
#endif
#define _KZTimerPro_included

/* Natives */
native bool:KZTimerPro_GetTimerStatus(client);
native KZTimerPro_StopTimer(client);
native KZTimerPro_StopUpdatingOfClimbersMenu(client);


public SharedPlugin:__pl_KZTimerPro =
{
	name = "KZTimerPro",
	file = "KZTimerPro.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_KZTimerPro_SetNTVOptional()
{
	MarkNativeAsOptional("KZTimerPro_GetTimerStatus");
	MarkNativeAsOptional("KZTimerPro_StopTimer");
	MarkNativeAsOptional("KZTimerPro_StopUpdatingOfClimbersMenu");
}