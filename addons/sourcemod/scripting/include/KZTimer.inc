#if defined _KZTimer_included
 #endinput
#endif
#define _KZTimer_included

/* Natives */
native bool:KZTimer_GetTimerStatus(client); // check if timer enabled
native KZTimer_StopTimer(client); // stop timer
native KZTimer_StopUpdatingOfClimbersMenu(client); // stops refreshing of the timer panel/menu
native KZTimer_EmulateStartButtonPress(client); // stop button alternative (global records disabled)
native KZTimer_EmulateStopButtonPress(client); // start button alternative (global records disabled)
native Float:KZTimer_GetCurrentTime(client); //current run time

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
	MarkNativeAsOptional("KZTimer_StopPanelRefreshing");
	MarkNativeAsOptional("KZTimer_EmulateStartButtonPress");	
	MarkNativeAsOptional("KZTimer_EmulateStopButtonPress");
	MarkNativeAsOptional("KZTimer_GetCurrentTime");
}