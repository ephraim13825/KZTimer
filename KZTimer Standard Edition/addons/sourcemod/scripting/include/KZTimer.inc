#if defined _KZTimer_included
 #endinput
#endif
#define _KZTimer_included

/* Natives */
native bool:KZTimer_GetTimerStatus(client);
native KZTimer_StopTimer(client);
native KZTimer_StopUpdatingOfClimbersMenu(client);

public SharedPlugin:__pl_KZTimer =
{
	name = "KZTimer",
	file = "KZTimer.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_KZTimer_SetNTVOptional()
{
	MarkNativeAsOptional("KZTimer_GetTimerStatus");
	MarkNativeAsOptional("KZTimer_StopTimer");
	MarkNativeAsOptional("KZTimer_StopUpdatingOfClimbersMenu");
}