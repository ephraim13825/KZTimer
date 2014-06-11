#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>
#include <cstrike>
#include <button>
#include <entity>
#include <setname>
#include <smlib>
#include <KZTimer>
#include <geoip>
#include <colors>
#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#include <sourcebans>

/*
- minor optimizations
*/
#define VERSION "1.35"
#define ADMIN_LEVEL ADMFLAG_UNBAN

#define WHITE 0x01
#define DARKRED 0x02
#define PURPLE 0x03
#define GREEN 0x04
#define MOSSGREEN 0x05
#define LIMEGREEN 0x06
#define RED 0x07
#define GRAY 0x08
#define YELLOW 0x09
#define QUOTE 0x22
#define PERCENT 0x25
#define CPLIMIT 30 
#define MYSQL 0
#define SQLITE 1
#define MAX_MAP_LENGTH 128
#define MAX_BUTTONS 25
#define HIDE_RADAR (1 << 12)
#define HIDE_ROUNDTIME ( 1<<13 )
#define ASSISTS_OFFSET_FROM_FRAGS 4 
#define MAX_MAPS 1000
#define MAX_PR_PLAYERS 10000
#define MAX_STRAFES 100
#define MAX_STRAFES2 5000
#define STRAFE_A 1
#define STRAFE_D 2
#define STRAFE_W 3
#define STRAFE_S 4
#define MAX_BHOPBLOCKS 5000
#define BLOCK_TELEPORT 0.1	
#define BLOCK_COOLDOWN 0.2		
#define SF_BUTTON_DONTMOVE (1<<0)		
#define SF_BUTTON_TOUCH_ACTIVATES (1<<8)	
#define SF_DOOR_PTOUCH (1<<10)		

//botmimic2
//https://forums.alliedmods.net/showthread.php?t=164148?t=164148
#define MAX_RECORD_NAME_LENGTH 64
#define BM_MAGIC 0xBAADF00D
#define BINARY_FORMAT_VERSION 0x01
#define ADDITIONAL_FIELD_TELEPORTED_ORIGIN (1<<0)
#define ADDITIONAL_FIELD_TELEPORTED_ANGLES (1<<1)
#define ADDITIONAL_FIELD_TELEPORTED_VELOCITY (1<<2)
#define FRAME_INFO_SIZE 15
#define FRAME_INFO_SIZE_V1 14
#define AT_SIZE 10
#define AT_ORIGIN 0
#define AT_ANGLES 1
#define AT_VELOCITY 2
#define AT_FLAGS 3
#define ORIGIN_SNAPSHOT_INTERVAL 100
#define FILE_HEADER_LENGTH 74

//measure plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
new g_iGlowSprite;
new Float:g_vMeasurePos[MAXPLAYERS+1][2][3];
new bool:g_bMeasurePosSet[MAXPLAYERS+1][2];
new Handle:g_hMainMenu = INVALID_HANDLE;
new Handle:g_hP2PRed[MAXPLAYERS+1] = { INVALID_HANDLE,... };
new Handle:g_hP2PGreen[MAXPLAYERS+1] = { INVALID_HANDLE,... };


//botmimic 2
//https://forums.alliedmods.net/showthread.php?t=164148?t=164148
enum FrameInfo 
{
	playerButtons = 0,
	playerImpulse,
	Float:actualVelocity[3],
	Float:predictedVelocity[3],
	Float:predictedAngles[2], 
	CSWeaponID:newWeapon,
	playerSubtype,
	playerSeed,
	additionalFields, 
	pause, 
}

//botmimic 2
//https://forums.alliedmods.net/showthread.php?t=164148?t=164148
enum AdditionalTeleport 
{
	Float:atOrigin[3],
	Float:atAngles[3],
	Float:atVelocity[3],
	atFlags
}

//botmimic 2
//https://forums.alliedmods.net/showthread.php?t=164148?t=164148
enum FileHeader 
{
	FH_binaryFormatVersion = 0,
	String:FH_Time[32],
	String:FH_Playername[32],
	FH_Checkpoints,
	FH_tickCount,
	Float:FH_initialPosition[3],
	Float:FH_initialAngles[3],
	Handle:FH_frames
}

enum VelocityOverride
{
	VelocityOvr_None = 0,
	VelocityOvr_Velocity,
	VelocityOvr_OnlyWhenNegative,
	VelocityOvr_InvertReuseVelocity
}

//macrodox
// https://forums.alliedmods.net/showthread.php?p=1678026
new aiJumps[MAXPLAYERS+1] = {0, ...};
new Float:afAvgJumps[MAXPLAYERS+1] = {1.0, ...};
new Float:afAvgSpeed[MAXPLAYERS+1] = {250.0, ...};
new Float:avVEL[MAXPLAYERS+1][3];
new aiPattern[MAXPLAYERS+1] = {0, ...};
new aiPatternhits[MAXPLAYERS+1] = {0, ...};
new Float:avLastPos[MAXPLAYERS+1][3];
new aiAutojumps[MAXPLAYERS+1] = {0, ...};
new aaiLastJumps[MAXPLAYERS+1][30];
new Float:afAvgPerfJumps[MAXPLAYERS+1] = {0.3333, ...};
new iTickCount2 = 1;
new aiIgnoreCount[MAXPLAYERS+1];
new bool:bFlagged[MAXPLAYERS+1];
new bool:bSurfCheck[MAXPLAYERS+1];
new aiLastPos[MAXPLAYERS+1] = {0, ...};
new iNumberJumpsAbove[MAXPLAYERS+1];


//anti strafe hack zipcore
enum PlayerState
{
	bool:bOn,
	nStrafes,
	nStrafesBoosted,
	nStrafeDir,
	Float:fStrafeTimeLastSync[MAX_STRAFES2],
	Float:fStrafeTimeAngleTurn[MAX_STRAFES2],
	Float:fStrafeDelay[MAX_STRAFES2],
	bool:bStrafeAngleGain[MAX_STRAFES2],
	bool:bBoosted[MAX_STRAFES2]
}
new g_PlayerStates[MAXPLAYERS + 1][PlayerState];
new Float:vLastOrigin[MAXPLAYERS + 1][3];
new Float:vLastAngles[MAXPLAYERS + 1][3];
new Float:vLastVelocity[MAXPLAYERS + 1][3];

/* Sourcebans */
new bool:bCanUseSourcebans = false;

//multiplayer bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724?p=808724
new bool:g_bLateLoaded = false;
new g_iBhopDoorList[MAX_BHOPBLOCKS];
new g_iBhopDoorTeleList[MAX_BHOPBLOCKS];
new g_iBhopDoorCount;
new Float:g_iBhopDoorSp[300];
new g_iBhopButtonList[MAX_BHOPBLOCKS];
new g_iBhopButtonTeleList[MAX_BHOPBLOCKS];
new g_iBhopButtonCount;
new g_iOffs_vecOrigin = -1;
new g_iOffs_vecMins = -1;
new g_iOffs_vecMaxs = -1;
new g_iDoorOffs_vecPosition1 = -1;
new g_iDoorOffs_vecPosition2 = -1;
new g_iDoorOffs_flSpeed = -1;
new g_iDoorOffs_spawnflags = -1;
new g_iDoorOffs_NoiseMoving = -1;
new g_iDoorOffs_sLockedSound = -1;
new g_iDoorOffs_bLocked = -1;
new g_iButtonOffs_vecPosition1 = -1;
new g_iButtonOffs_vecPosition2 = -1;
new g_iButtonOffs_flSpeed = -1;
new g_iButtonOffs_spawnflags = -1;
new Float:g_fLastJump[MAXPLAYERS+1] = {0.0, ...};
new Handle:g_hSDK_Touch = INVALID_HANDLE;

//global declarations
new g_i = 0;
new g_DbType;
new g_ReplayRecordTps;
new Handle:g_hAdminMenu;
new Handle:g_MapList = INVALID_HANDLE;
new Handle:g_hDb = INVALID_HANDLE;
new Handle:g_hDbGlobal = INVALID_HANDLE;
new Handle:hStartPress = INVALID_HANDLE;
new Handle:hEndPress = INVALID_HANDLE;
new Handle:g_hclimbersmenu[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:g_hTopJumpersMenu[MAXPLAYERS+1] = INVALID_HANDLE;

//blockstats
new bool:g_bLJBlock[MAXPLAYERS + 1];
new bool:g_bLjStarDest[MAXPLAYERS + 1];
new bool:g_bLJBlockValidJumpoff[MAXPLAYERS + 1];
new Float:g_fBlockHeight[MAXPLAYERS + 1];
new Float:g_EdgeVector[MAXPLAYERS + 1][3];
new Float:g_EdgeDist[MAXPLAYERS + 1];
new Float:g_EdgePoint[MAXPLAYERS + 1][3];
new Float:g_OriginBlock[MAXPLAYERS + 1][2][3];
new Float:g_DestBlock[MAXPLAYERS + 1][2][3];
new g_BlockDist[MAXPLAYERS + 1];
new g_Beam[2];


//cvars
new Handle:g_hWelcomeMsg = INVALID_HANDLE;
new String:g_sWelcomeMsg[512];  
new Handle:g_hReplayBotPlayerModel = INVALID_HANDLE;
new String:g_sReplayBotPlayerModel[256];  
new Handle:g_hReplayBotArmModel = INVALID_HANDLE;
new String:g_sReplayBotArmModel[256];  
new Handle:g_hPlayerModel = INVALID_HANDLE;
new String:g_sPlayerModel[256];  
new Handle:g_hArmModel = INVALID_HANDLE;
new String:g_sArmModel[256];  
new Handle:g_hdist_good_weird = INVALID_HANDLE;
new Float:g_dist_good_weird;
new Handle:g_hdist_pro_weird = INVALID_HANDLE;
new Float:g_dist_pro_weird;
new Handle:g_hdist_leet_weird = INVALID_HANDLE;
new Float:g_dist_leet_weird;
new Handle:g_hdist_good_dropbhop = INVALID_HANDLE;
new Float:g_dist_good_dropbhop;
new Handle:g_hdist_pro_dropbhop = INVALID_HANDLE;
new Float:g_dist_pro_dropbhop;
new Handle:g_hdist_leet_dropbhop = INVALID_HANDLE;
new Float:g_dist_leet_dropbhop;
new Handle:g_hdist_good_bhop = INVALID_HANDLE;
new Float:g_dist_good_bhop;
new Handle:g_hdist_pro_bhop = INVALID_HANDLE;
new Float:g_dist_pro_bhop;
new Handle:g_hdist_leet_bhop = INVALID_HANDLE;
new Float:g_dist_leet_bhop;
new Handle:g_hdist_good_multibhop = INVALID_HANDLE;
new Float:g_dist_good_multibhop;
new Handle:g_hdist_pro_multibhop = INVALID_HANDLE;
new Float:g_dist_pro_multibhop;
new Handle:g_hdist_leet_multibhop = INVALID_HANDLE;
new Float:g_dist_leet_multibhop;
new Handle:g_hBanDuration = INVALID_HANDLE;
new Float:g_fBanDuration;
new Handle:g_hdist_good_lj = INVALID_HANDLE;
new Float:g_dist_good_lj;
new Handle:g_hdist_pro_lj = INVALID_HANDLE;
new Float:g_dist_pro_lj;
new Handle:g_hdist_leet_lj = INVALID_HANDLE;
new Float:g_dist_leet_lj;
new Handle:g_hBhopSpeedCap = INVALID_HANDLE;
new Float:g_fBhopSpeedCap;
new Handle:g_hMaxBhopPreSpeed = INVALID_HANDLE;
new Float:g_fMaxBhopPreSpeed;
new Handle:g_hcvarRestore = INVALID_HANDLE;
new bool:g_bRestore;
new Handle:g_hNoClipS = INVALID_HANDLE;
new bool:g_bNoClipS;
new Handle:g_hReplayBot = INVALID_HANDLE;
new bool:g_bReplayBot;
new Handle:g_hAutoBan = INVALID_HANDLE;
new bool:g_bAutoBan;
new Handle:g_hPauseServerside = INVALID_HANDLE;
new bool:g_bPauseServerside;
new Handle:g_hAutoBhop = INVALID_HANDLE;
new bool:g_bAutoBhop;
new bool:g_bAutoBhop2;
new Handle:g_hVipClantag = INVALID_HANDLE;
new bool:g_bVipClantag;
new Handle:g_hAdminClantag = INVALID_HANDLE;
new bool:g_bAdminClantag;
new Handle:g_hConnectMsg = INVALID_HANDLE;
new bool:g_bConnectMsg;
new Handle:g_hRadioCommands = INVALID_HANDLE;
new bool:g_bRadioCommands;
new Handle:g_hGoToServer = INVALID_HANDLE;
new bool:g_bGoToServer;
new Handle:g_hPlayerSkinChange = INVALID_HANDLE;
new bool:g_bPlayerSkinChange;
new Handle:g_hJumpStats = INVALID_HANDLE;
new bool:g_bJumpStats;
new Handle:g_hCountry = INVALID_HANDLE;
new bool:g_bCountry;
new Handle:g_hMultiplayerBhop = INVALID_HANDLE;
new bool:g_bMultiplayerBhop;
new Handle:g_hAutoRespawn = INVALID_HANDLE;
new bool:g_bAutoRespawn;
new Handle:g_hAllowCheckpoints = INVALID_HANDLE;
new bool:g_bAllowCheckpoints;
new Handle:g_hcvarNoBlock = INVALID_HANDLE;
new bool:g_bNoBlock;
new Handle:g_hPointSystem = INVALID_HANDLE;
new bool:g_bPointSystem;
new Handle:g_hCleanWeapons = INVALID_HANDLE;
new bool:g_bCleanWeapons;
new Handle:g_hcvargodmode = INVALID_HANDLE;
new bool:g_bAutoTimer;
new Handle:g_hAutoTimer = INVALID_HANDLE;
new bool:g_bgodmode;
new Handle:g_hEnforcer = INVALID_HANDLE;
new bool:g_bEnforcer;
new Handle:g_hPreStrafe = INVALID_HANDLE;
new bool:g_bPreStrafe;
new Handle:g_hGlobalDB = INVALID_HANDLE;
new bool:g_bGlobalDB;
new Handle:g_hfpsCheck = INVALID_HANDLE;
new bool:g_bfpsCheck;
new Handle:g_hMapEnd = INVALID_HANDLE;
new bool:g_bMapEnd;
new Handle:g_hAutohealing_Hp = INVALID_HANDLE;
new g_Autohealing_Hp;
new Handle:g_hReplayBotProColor = INVALID_HANDLE;
new Handle:g_hReplayBotTpColor = INVALID_HANDLE;

//other decl.
new Float:g_fMapStartTime;
new Float:g_strafe_good_sync[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_strafe_frames[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_strafe_gained[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_strafe_max_speed[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_strafe_lost[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_fStartTime[MAXPLAYERS+1];
new Float:g_fFinalTime[MAXPLAYERS+1];
new Float:g_fPauseTime[MAXPLAYERS+1];
new Float:g_fLastTimeNoClipUsed[MAXPLAYERS+1];
new Float:g_fStartPauseTime[MAXPLAYERS+1];
new Float:g_fPlayerCordsLastPosition[MAXPLAYERS+1][3];
new Float:g_fPlayerLastTime[MAXPLAYERS+1];
new Float:g_fPlayerAnglesLastPosition[MAXPLAYERS+1][3];
new Float:g_fPlayerCords[MAXPLAYERS+1][CPLIMIT][3];
new Float:g_fPlayerAngles[MAXPLAYERS+1][CPLIMIT][3];
new Float:g_fPlayerCordsRestart[MAXPLAYERS+1][3]; 
new Float:g_fPlayerAnglesRestart[MAXPLAYERS+1][3]; 
new Float:g_fPlayerCordsRestore[MAXPLAYERS+1][3];
new Float:g_fPlayerAnglesRestore[MAXPLAYERS+1][3];
new Float:g_fPlayerCordsUndoTp[MAXPLAYERS+1][3];
new Float:g_fPlayerAnglesUndoTp[MAXPLAYERS+1][3];
new Float:g_fPersonalRecord[MAXPLAYERS+1];
new Float:g_fPersonalRecordPro[MAXPLAYERS+1];
new Float:g_fRecordTime=9999999.0;
new Float:g_fRecordTimePro=9999999.0;
new Float:g_fRecordTimeGlobal102=9999999.0;
new Float:g_fRecordTimeGlobal=9999999.0;
new Float:g_fRecordTimeGlobal128=9999999.0;
new Float:g_fRunTime[MAXPLAYERS+1];
new Float:g_fLastTimeButtonSound[MAXPLAYERS+1];
new Float:g_fPlayerConnectedTime[MAXPLAYERS+1];
new Float:g_fStartCommandUsed_LastTime[MAXPLAYERS+1];
new Float:g_fLastTime_DBQuery[MAXPLAYERS+1];
new Float:g_fJump_Initial[MAXPLAYERS+1][3];
new Float:g_fJump_InitialLastHeight[MAXPLAYERS+1];
new Float:g_fJump_Final[MAXPLAYERS+1][3];
new Float:g_fStartButtonPos[3];
new Float:g_fEndButtonPos[3];
new Float:g_fStartButtonAngle[3];
new Float:g_fEndButtonAngle[3];
new Float:g_fJump_DistanceX[MAXPLAYERS+1];
new Float:g_fTakeOffSpeed[MAXPLAYERS+1];
new Float:g_fJump_DistanceZ[MAXPLAYERS+1];
new Float:g_fJump_Distance[MAXPLAYERS+1];
new Float:g_fPreStrafe[MAXPLAYERS+1];
new Float:g_fJumpOffTime[MAXPLAYERS+1];
new Float:g_fDroppedUnits[MAXPLAYERS+1];
new Float:g_fMaxSpeed[MAXPLAYERS+1];
new Float:g_fLastSpeed[MAXPLAYERS+1];
new Float:g_fMaxSpeed2[MAXPLAYERS +1];
new Float:g_flastHeight[MAXPLAYERS +1];
new Float:g_fMaxHeight[MAXPLAYERS+1];
new Float:g_fLastJumpTime[MAXPLAYERS+1];
new Float:g_fLastJumpDistance[MAXPLAYERS+1];
new Float:g_fPersonalWjRecord[MAX_PR_PLAYERS]=-1.0;
new Float:g_fPersonalDropBhopRecord[MAX_PR_PLAYERS]=-1.0;
new Float:g_fPersonalBhopRecord[MAX_PR_PLAYERS]=-1.0;
new Float:g_fPersonalMultiBhopRecord[MAX_PR_PLAYERS]=-1.0;
new Float:g_fPersonalLjRecord[MAX_PR_PLAYERS]=-1.0;
new g_PersonalLjBlockRecord[MAX_PR_PLAYERS]=-1;
new Float:g_fPersonalLjBlockRecordDist[MAX_PR_PLAYERS]=-1.0;
new Float:g_PrestrafeVelocity[MAXPLAYERS+1];
new Float:g_fChallengeRequestTime[MAXPLAYERS+1];
new Float:g_fSpawnPosition[MAXPLAYERS+1][3]; 
new Float:g_good_sync[MAXPLAYERS+1];
new Float:g_sync_frames[MAXPLAYERS+1];
new Float:g_fLastPosition[MAXPLAYERS + 1][3];
new Float:g_fLastAngles[MAXPLAYERS + 1][3];
new Float:g_fSpeed[MAXPLAYERS+1];
new Float:g_pr_finishedmaps_tp_perc[MAX_PR_PLAYERS]; 
new Float:g_pr_finishedmaps_pro_perc[MAX_PR_PLAYERS]; 
new bool:g_bMapButtons;
new bool:g_bRoundEnd;
new bool:g_bglobalValidFilesize;
new g_tickrate;
new bool:g_bProReplay;
new bool:g_bTpReplay;
new bool:g_bUpdate;
new bool:g_pr_refreshingDB;
new bool:g_bAntiCheat;
new bool:g_bValidTeleport[MAXPLAYERS+1];
new bool:g_pr_Calculating[MAXPLAYERS+1];
new bool:g_bCCheckpoints[MAXPLAYERS+1];
new bool:g_bHyperscrollWarning[MAXPLAYERS+1];
new bool:g_bTopMenuOpen[MAXPLAYERS+1]; 
new bool:g_bNoClipUsed[MAXPLAYERS+1];
new bool:g_bMenuOpen[MAXPLAYERS+1];
new bool:g_bRestartCords[MAXPLAYERS+1];
new bool:g_bPause[MAXPLAYERS+1];
new bool:g_bPauseWasActivated[MAXPLAYERS+1];
new bool:g_bOverlay[MAXPLAYERS+1];
new bool:g_bchallengeConnected[MAXPLAYERS+1]=false;
new bool:g_bLastButtonJump[MAXPLAYERS+1];
new bool:g_bPlayerJumped[MAXPLAYERS+1];
new bool:g_bSpectate[MAXPLAYERS+1];
new bool:g_bTimeractivated[MAXPLAYERS+1];
new bool:g_bFirstSpawn[MAXPLAYERS+1];
new bool:g_bFirstSpawn2[MAXPLAYERS+1];
new bool:g_bMissedTpBest[MAXPLAYERS+1];
new bool:g_bMissedProBest[MAXPLAYERS+1];
new bool:g_bRestoreC[MAXPLAYERS+1]; 
new bool:g_bRestoreCMsg[MAXPLAYERS+1]; 
new bool:g_bClimbersMenuOpen[MAXPLAYERS+1]; 
new bool:g_bClimbersMenuOpen2[MAXPLAYERS+1]; 
new bool:g_bNoClip[MAXPLAYERS+1]; 
new bool:g_bMapFinished[MAXPLAYERS+1]; 
new bool:g_bRespawnPosition[MAXPLAYERS+1]; 
new bool:g_bKickStatus[MAXPLAYERS+1]; 
new bool:g_bManualRecalc; 
new bool:g_bSelectProfile[MAXPLAYERS+1]; 
new bool:g_bClimbersMenuwasOpen[MAXPLAYERS+1]; 
new bool:g_bDropJump[MAXPLAYERS+1];    
new bool:g_bInvalidGround[MAXPLAYERS+1];
new bool:g_bChallengeAbort[MAXPLAYERS+1];
new bool:g_bLastInvalidGround[MAXPLAYERS+1];
new bool:g_bMapRankToChat[MAXPLAYERS+1];
new bool:g_bChallenge[MAXPLAYERS+1];
new bool:g_bChallengeRequest[MAXPLAYERS+1];
new bool:g_strafing_aw[MAXPLAYERS+1];
new bool:g_strafing_sd[MAXPLAYERS+1];
new bool:g_pr_showmsg[MAXPLAYERS+1];
new bool:g_CMOpen[MAXPLAYERS+1];
new bool:g_brc_PlayerRank[MAXPLAYERS+1];
new bool:g_bAutoBhopWasActive[MAXPLAYERS+1];
new bool:g_bColorChat[MAXPLAYERS+1]=true;
new bool:g_bNewReplay[MAXPLAYERS+1];
new bool:g_bPositionRestored[MAXPLAYERS+1];
new bool:g_BGlobalDBConnected=false;
new bool:g_bInfoPanel[MAXPLAYERS+1]=false;
new bool:g_bClimbersMenuSounds[MAXPLAYERS+1]=true;
new bool:g_bEnableQuakeSounds[MAXPLAYERS+1]=true;
new bool:g_bShowNames[MAXPLAYERS+1]=true; 
new bool:g_bStrafeSync[MAXPLAYERS+1]=false;
new bool:g_bGoToClient[MAXPLAYERS+1]=true; 
new bool:g_bShowTime[MAXPLAYERS+1]=true; 
new bool:g_bHide[MAXPLAYERS+1]=false; 
new bool:g_bSayHook[MAXPLAYERS+1]=false; 
new bool:g_bShowSpecs[MAXPLAYERS+1]=true; 
new bool:g_bCPTextMessage[MAXPLAYERS+1]=false; 
new bool:g_bAdvancedClimbersMenu[MAXPLAYERS+1]=false;
new bool:g_bAutoBhopClient[MAXPLAYERS+1]=true;
//org
new bool:g_borg_ColorChat[MAXPLAYERS+1];
new bool:g_borg_InfoPanel[MAXPLAYERS+1];
new bool:g_borg_ClimbersMenuSounds[MAXPLAYERS+1];
new bool:g_borg_EnableQuakeSounds[MAXPLAYERS+1];
new bool:g_borg_ShowNames[MAXPLAYERS+1]; 
new bool:g_borg_StrafeSync[MAXPLAYERS+1];
new bool:g_borg_GoToClient[MAXPLAYERS+1]; 
new bool:g_borg_ShowTime[MAXPLAYERS+1]; 
new bool:g_borg_Hide[MAXPLAYERS+1]; 
new bool:g_borg_ShowSpecs[MAXPLAYERS+1]; 
new bool:g_borg_CPTextMessage[MAXPLAYERS+1]; 
new bool:g_borg_AdvancedClimbersMenu[MAXPLAYERS+1];
new bool:g_borg_AutoBhopClient[MAXPLAYERS+1];
new g_bManualRecalcClientID=-1; 
new g_unique_FileSize;
new g_maptimes_pro;
new g_maptimes_tp;
new g_pr_players;
new g_pr_players2;
new g_pr_mapcount;
new g_iBot=-1;
new g_iBot2=-1;
new ownerOffset;
new g_pr_rank_Novice; 
new g_pr_rank_Scrub; 
new g_pr_rank_Rookie;
new g_pr_rank_Skilled;
new g_pr_rank_Expert;
new g_pr_rank_Pro;
new g_pr_rank_Elite;
new g_pr_rank_Master;
new g_pr_points_finished;
new g_pr_dyn_maxpoints;
new g_pr_rowcount;
new g_pr_points[MAX_PR_PLAYERS];
new g_pr_maprecords_row_counter[MAX_PR_PLAYERS];
new g_pr_maprecords_row_count[MAX_PR_PLAYERS];
new g_pr_oldpoints[MAX_PR_PLAYERS];  
new g_pr_multiplier[MAX_PR_PLAYERS]; 
new g_pr_finishedmaps_tp[MAX_PR_PLAYERS]; 
new g_pr_finishedmaps_pro[MAX_PR_PLAYERS];
new g_ReplayBotTpColor[3];
new g_ReplayBotProColor[3];
new detailView[MAXPLAYERS+1];
new g_CBet[MAXPLAYERS+1];
new g_UspDrops[MAXPLAYERS+1];
new g_sync[MAXPLAYERS+1];
new g_maprank_tp[MAXPLAYERS+1];
new g_maprank_pro[MAXPLAYERS+1];
new g_time_type[MAXPLAYERS+1];
new g_sound_type[MAXPLAYERS+1];
new g_tprecords[MAXPLAYERS+1];
new g_prorecords[MAXPLAYERS+1];
new g_record_type[MAXPLAYERS+1];
new g_challenge_win_ratio[MAXPLAYERS+1];
new g_CountdownTime[MAXPLAYERS+1];
new g_challenge_points_ratio[MAXPLAYERS+1];
new g_ground_frames[MAXPLAYERS+1];
new g_CurrentCp[MAXPLAYERS+1];
new g_CounterCp[MAXPLAYERS+1];
new g_OverallCp[MAXPLAYERS+1];
new g_OverallTp[MAXPLAYERS+1];
new g_SpecTarget[MAXPLAYERS+1];
new g_PrestrafeFrameCounter[MAXPLAYERS+1];
new g_mouseDirOld[MAXPLAYERS+1];
new g_BhopRank[MAX_PR_PLAYERS];
new g_MultiBhopRank[MAX_PR_PLAYERS];
new g_LjRank[MAX_PR_PLAYERS];
new g_LjBlockRank[MAX_PR_PLAYERS];
new g_DropBhopRank[MAX_PR_PLAYERS];
new g_wjRank[MAX_PR_PLAYERS];
new g_LastButton[MAXPLAYERS + 1];
new g_CurrentButton[MAXPLAYERS+1];
new g_strafecount[MAXPLAYERS+1];
new g_Strafes[MAXPLAYERS+1];
new g_MVPStars[MAXPLAYERS+1];
new g_newTp[MAXPLAYERS+1];
new g_AdminMenuLastPage[MAXPLAYERS+1];
new Handle:g_hRecordingAdditionalTeleport[MAXPLAYERS+1];
new g_OptionMenuLastPage[MAXPLAYERS+1];
new g_LeetJumpDominating[MAXPLAYERS+1]; 
new g_multi_bhop_count[MAXPLAYERS+1];
new g_last_ground_frames[MAXPLAYERS+1];
new String:g_szMapTag[2][32];  
new String:g_szReplayName[128];  
new String:g_szReplayTime[128]; 
new String:g_szReplayNameTp[128];  
new String:g_szReplayTimeTp[128]; 
new String:g_szCOpponentID[MAXPLAYERS+1][32]; 
new String:g_szTimeDifference[MAXPLAYERS+1][32]; 
new String:g_szNewTime[MAXPLAYERS+1][32];
new String:g_szMapName[MAX_MAP_LENGTH];
new String:g_szMenuTitleRun[MAXPLAYERS+1][255];
new String:g_szTime[MAXPLAYERS+1][32];
new String:g_szRecordGlobalPlayer[MAX_NAME_LENGTH];
new String:g_szRecordGlobalPlayer102[MAX_NAME_LENGTH];
new String:g_szRecordGlobalPlayer128[MAX_NAME_LENGTH];
new String:g_szRecordPlayerPro[MAX_NAME_LENGTH];
new String:g_szRecordPlayer[MAX_NAME_LENGTH];
new String:g_szProfileName[MAXPLAYERS+1][MAX_NAME_LENGTH];
new String:g_szPlayerPanelText[MAXPLAYERS+1][512];
new String:g_szProfileSteamId[MAXPLAYERS+1][32];
new String:g_szCountry[MAXPLAYERS+1][100];
new String:g_szCountryCode[MAXPLAYERS+1][16]; 
new String:g_pr_rankname[MAXPLAYERS+1][32];  
new String:g_szSteamID[MAXPLAYERS+1][32];  
new String:g_pr_szrank[MAXPLAYERS+1][512];  
new String:g_pr_szName[MAX_PR_PLAYERS][64];  
new String:g_pr_szSteamID[MAX_PR_PLAYERS][32]; 
new String:g_szSkillGroups[9][32];
new const String:SKILL_GROUPS_PATH[] = "configs/kztimer/skill_groups.txt";
new const String:KZ_REPLAY_PATH[] = "data/kz_replays/";
new const String:ANTICHEAT_LOG_PATH[] = "logs/kztimer_anticheat.log";
new const String:EXCEPTION_LIST_PATH[] = "configs/kztimer/exception_list.txt";
new const String:CP_FULL_SOUND_PATH[] = "sound/quake/wickedsick.mp3";
new const String:CP_RELATIVE_SOUND_PATH[] = "*quake/wickedsick.mp3";
new const String:PRO_FULL_SOUND_PATH[] = "sound/quake/holyshit.mp3";
new const String:PRO_RELATIVE_SOUND_PATH[] = "*quake/holyshit.mp3";
new const String:RELATIVE_BUTTON_PATH[] = "*buttons/button3.wav";
new const String:LEETJUMP_FULL_SOUND_PATH[] = "sound/quake/godlike.mp3";
new const String:LEETJUMP_RELATIVE_SOUND_PATH[] = "*quake/godlike.mp3";
new const String:LEETJUMP_RAMPAGE_FULL_SOUND_PATH[] = "sound/quake/rampage.mp3";
new const String:LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH[] = "*quake/rampage.mp3";
new const String:LEETJUMP_DOMINATING_FULL_SOUND_PATH[] = "sound/quake/dominating.mp3";
new const String:LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH[] = "*quake/dominating.mp3";
new const String:PROJUMP_FULL_SOUND_PATH[] = "sound/quake/perfect.mp3";
new const String:PROJUMP_RELATIVE_SOUND_PATH[] = "*quake/perfect.mp3";

new String:RadioCMDS[][] = {"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog",
	"getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin",
	"getout", "negative","enemydown","cheer","thanks","nice","compliment"};


new String:BlockedChatText[][] = {"!help","!usp","!helpmenu","!menu","!menu ","!checkpoint","!gocheck","!unstuck", "!ljblock", "/ljblock", "!flashlight", "/flashlight",
	"!stuck","!r","!prev","!undo","!next","!start","!stop","!pause","/help","/helpmenu","/menu","/menu ","/checkpoint",
	"/gocheck","/unstuck","/stuck","/r","/prev","/undo","/next","/usp","/start","/stop","/pause",
	"!knife","!adv", "!info", "!colorchat", "!cpmessage", "!sound", "!menusound", "!hide", "!hidespecs", "!showtime", "!disablegoto", "!shownames", "!sync", "!bhop", "!speed", "!showkeys", "!goto", "!measure",
	"/knife","/adv", "/info", "/colorchat", "/cpmessage", "/sound", "/menusound", "/hide", "/hidespecs", "/showtime", "/disablegoto", "/shownames", "/sync", "/bhop", "/speed", "/showkeys", "/goto", "/measure"};

new String:EntityList[][] = {"jail_teleport","logic_timer", "team_round_timer", "logic_relay"};

// Botmimic2 Peace-Maker
// http://forums.alliedmods.net/showthread.php?t=164148
new Handle:g_hBotMimicsRecord[MAXPLAYERS+1] = {INVALID_HANDLE,...};
new Handle:g_hRecording[MAXPLAYERS+1];
new Handle:g_hLoadedRecordsAdditionalTeleport;
new Float:g_fInitialPosition[MAXPLAYERS+1][3];
new Float:g_fInitialAngles[MAXPLAYERS+1][3];
new bool:g_bValidTeleportCall[MAXPLAYERS+1];
new g_iBotMimicRecordTickCount[MAXPLAYERS+1] = {0,...};
new g_iBotActiveWeapon[MAXPLAYERS+1] = {-1,...};
new g_iCurrentAdditionalTeleportIndex[MAXPLAYERS+1];
new g_iRecordedTicks[MAXPLAYERS+1];
new g_iRecordPreviousWeapon[MAXPLAYERS+1];
new g_iOriginSnapshotInterval[MAXPLAYERS+1];
new g_iBotMimicTick[MAXPLAYERS+1] = {0,...};
new String:g_sRecordName[MAXPLAYERS+1][MAX_RECORD_NAME_LENGTH];

#include "kztimer/admin.sp"
#include "kztimer/commands.sp"
#include "kztimer/hooks.sp"
#include "kztimer/buttonpress.sp"
#include "kztimer/sql.sp"
#include "kztimer/misc.sp"
#include "kztimer/timer.sp"
#include "kztimer/replay.sp"
#include "kztimer/jumpstats.sp"
#include "kztimer/globalconnection.sp"
	
public Plugin:
myinfo = {
	name = "KZTimer",
	author = "1NutWunDeR",
	description = "",
	version = VERSION,
	url = "https://www.sourcemod.net/showthread.php?t=223274"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary("KZTimer");
	hStartPress = CreateGlobalForward("CL_OnStartTimerPress", ET_Ignore, Param_Cell);
	hEndPress = CreateGlobalForward("CL_OnEndTimerPress", ET_Ignore, Param_Cell);
	CreateNative("KZTimer_GetTimerStatus", Native_GetTimerStatus);
	CreateNative("KZTimer_StopUpdatingOfClimbersMenu", Native_StopUpdatingOfClimbersMenu);
	CreateNative("KZTimer_StopTimer", Native_StopTimer);
	g_bLateLoaded = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	g_bUpdate=false;
	new Handle:hGameConf = LoadGameConfigFile("sdkhooks.games")

	//<multibhop>
	//https://forums.alliedmods.net/showthread.php?p=808724
	if(hGameConf == INVALID_HANDLE) 
	{
		SetFailState("GameConfigFile sdkhooks.games was not found")
		return
	}

	StartPrepSDKCall(SDKCall_Entity)
	PrepSDKCall_SetFromConf(hGameConf,SDKConf_Virtual,"Touch")
	PrepSDKCall_AddParameter(SDKType_CBaseEntity,SDKPass_Pointer)
	g_hSDK_Touch = EndPrepSDKCall()
	CloseHandle(hGameConf)

	if(g_hSDK_Touch == INVALID_HANDLE) 
	{
		SetFailState("Unable to prepare virtual function CBaseEntity::Touch")
		return
	}
	//</multibhop>
	
	LoadTranslations("kztimer.phrases");	
	CreateConVar("kztimer_version", VERSION, "kztimer Version.", FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	//Tickrate
	new Float:fltickrate = 1.0 / GetTickInterval( );
	if (fltickrate > 65)
		if (fltickrate < 103)
			g_tickrate = 102;
		else
			g_tickrate = 128;
	else
		g_tickrate= 64;

	g_hConnectMsg = CreateConVar("kz_connect_msg", "1", "on/off - shows a connect message with country", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bConnectMsg     = GetConVarBool(g_hConnectMsg);
	HookConVarChange(g_hConnectMsg, OnSettingChanged);	
	
	g_hMapEnd = CreateConVar("kz_map_end", "1", "on/off - maps wont change after the time has run out if disabled. mp_ignore_round_win_conditions is set to 1 and prevents round endings (and also map endings)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bMapEnd     = GetConVarBool(g_hMapEnd);
	HookConVarChange(g_hMapEnd, OnSettingChanged);	
	
	g_hMultiplayerBhop = CreateConVar("kz_multiplayer_bhop", "1", "on/off - allows players to jump across sections of bhops without the blocks being triggered.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bMultiplayerBhop     = GetConVarBool(g_hMultiplayerBhop);
	HookConVarChange(g_hMultiplayerBhop, OnSettingChanged);
	
	g_hReplayBot = CreateConVar("kz_replay_bot", "1", "on/off - Bots mimic the local tp and pro record", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bReplayBot     = GetConVarBool(g_hReplayBot);
	HookConVarChange(g_hReplayBot, OnSettingChanged);	
	
	g_hPreStrafe = CreateConVar("kz_prestrafe", "0", "on/off - Prestrafe", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPreStrafe     = GetConVarBool(g_hPreStrafe);
	HookConVarChange(g_hPreStrafe, OnSettingChanged);	

	g_hNoClipS = CreateConVar("kz_noclip", "1", "on/off - Allow players to use noclip when they have finished the map", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bNoClipS     = GetConVarBool(g_hNoClipS);
	HookConVarChange(g_hNoClipS, OnSettingChanged);	
	
	g_hfpsCheck = 	CreateConVar("kz_fps_check", "0", "on/off - Kick players if their fps_max is 0 or bigger than 300", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bfpsCheck     = GetConVarBool(g_hfpsCheck);
	HookConVarChange(g_hfpsCheck, OnSettingChanged);	

	g_hVipClantag = 	CreateConVar("kz_vip_clantag", "1", "on/off - VIP tag", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bVipClantag     = GetConVarBool(g_hVipClantag);
	HookConVarChange(g_hVipClantag, OnSettingChanged);	
	
	g_hAdminClantag = 	CreateConVar("kz_admin_clantag", "1", "on/off - Admin tag", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAdminClantag     = GetConVarBool(g_hAdminClantag);
	HookConVarChange(g_hAdminClantag, OnSettingChanged);	
	
	g_hGlobalDB = CreateConVar("kz_global_database", "1", "on/off - Global database", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bGlobalDB     = GetConVarBool(g_hGlobalDB);
	HookConVarChange(g_hGlobalDB, OnSettingChanged);			
	
	g_hAutoTimer = CreateConVar("kz_auto_timer", "0", "on/off - Timer automatically starts when a player joins a team, dies or uses '!start' (global records are disabled if enabled)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoTimer     = GetConVarBool(g_hAutoTimer);
	HookConVarChange(g_hAutoTimer, OnSettingChanged);

	g_hGoToServer = CreateConVar("kz_goto", "1", "on/off - Teleporting to an other player", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bGoToServer     = GetConVarBool(g_hGoToServer);
	HookConVarChange(g_hGoToServer, OnSettingChanged);	
	
	g_hcvargodmode = CreateConVar("kz_godmode", "1", "on/off - Players are immortal", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bgodmode     = GetConVarBool(g_hcvargodmode);
	HookConVarChange(g_hcvargodmode, OnSettingChanged);

	g_hPauseServerside    = CreateConVar("kz_pause", "1", "on/off - Allows players to use a pause function while climbing", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPauseServerside    = GetConVarBool(g_hPauseServerside);
	HookConVarChange(g_hPauseServerside, OnSettingChanged);

	g_hcvarRestore    = CreateConVar("kz_restore", "1", "on/off - Restoring of time and last position after reconnect", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bRestore        = GetConVarBool(g_hcvarRestore);
	HookConVarChange(g_hcvarRestore, OnSettingChanged);
	
	g_hcvarNoBlock    = CreateConVar("kz_noblock", "1", "on/off - Player blocking", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bNoBlock        = GetConVarBool(g_hcvarNoBlock);
	HookConVarChange(g_hcvarNoBlock, OnSettingChanged);
	
	g_hAllowCheckpoints = CreateConVar("kz_checkpoints", "1", "on/off - Checkpoints", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAllowCheckpoints     = GetConVarBool(g_hAllowCheckpoints);
	HookConVarChange(g_hAllowCheckpoints, OnSettingChanged);	
	
	g_hEnforcer = CreateConVar("kz_settings_enforcer", "1", "on/off - KZ settings enforcer (global records are disabled if disabled)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnforcer     = GetConVarBool(g_hEnforcer);
	HookConVarChange(g_hEnforcer, OnSettingChanged);
	
	g_hAutoRespawn = CreateConVar("kz_autorespawn", "1", "on/off - Players respawn if they die", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoRespawn     = GetConVarBool(g_hAutoRespawn);
	HookConVarChange(g_hAutoRespawn, OnSettingChanged);	

	g_hRadioCommands = CreateConVar("kz_use_radio", "0", "on/off - Allows players to use radio commands", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bRadioCommands     = GetConVarBool(g_hRadioCommands);
	HookConVarChange(g_hRadioCommands, OnSettingChanged);	
	
	g_hAutohealing_Hp 	= CreateConVar("kz_autoheal", "50", "Set HP amount for autohealing (only active when kz_godmode 0)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_Autohealing_Hp     = GetConVarInt(g_hAutohealing_Hp);
	HookConVarChange(g_hAutohealing_Hp, OnSettingChanged);	
	
	g_hCleanWeapons 	= CreateConVar("kz_clean_weapons", "1", "on/off - Removing of player weapons", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bCleanWeapons     = GetConVarBool(g_hCleanWeapons);
	HookConVarChange(g_hCleanWeapons, OnSettingChanged);

	g_hJumpStats 	= CreateConVar("kz_jumpstats", "1", "on/off - Measuring of jump distances (lj,wj,bhop,dropbhop and multibhop)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bJumpStats     = GetConVarBool(g_hJumpStats);
	HookConVarChange(g_hJumpStats, OnSettingChanged);	
	
	g_hCountry 	= CreateConVar("kz_country_tag", "1", "on/off - Country tag", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bCountry     = GetConVarBool(g_hCountry);
	HookConVarChange(g_hCountry, OnSettingChanged);
	
	g_hAutoBhop 	= CreateConVar("kz_auto_bhop", "1", "on/off - AutoBhop on bhop_ and surf_ maps (climb maps are not supported)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoBhop     = GetConVarBool(g_hAutoBhop);
	HookConVarChange(g_hAutoBhop, OnSettingChanged);

	g_hBhopSpeedCap   = CreateConVar("kz_prespeed_cap", "380.0", "Limits player's pre speed", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 5000.0);
	g_fBhopSpeedCap    = GetConVarFloat(g_hBhopSpeedCap);
	HookConVarChange(g_hBhopSpeedCap, OnSettingChanged);	
	
	g_hPointSystem    = CreateConVar("kz_point_system", "1", "on/off - Player point system", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPointSystem    = GetConVarBool(g_hPointSystem);
	HookConVarChange(g_hPointSystem, OnSettingChanged);
	
	g_hPlayerSkinChange 	= CreateConVar("kz_custom_models", "1", "on/off - Allows kztimer to change the player and bot models", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPlayerSkinChange     = GetConVarBool(g_hPlayerSkinChange);
	HookConVarChange(g_hPlayerSkinChange, OnSettingChanged);
	
	g_hReplayBotPlayerModel   = CreateConVar("kz_replay_bot_skin", "models/player/tm_professional_var1.mdl", "Replay bot skin", FCVAR_PLUGIN|FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotPlayerModel,g_sReplayBotPlayerModel,256);
	HookConVarChange(g_hReplayBotPlayerModel, OnSettingChanged);	
	
	g_hReplayBotArmModel   = CreateConVar("kz_replay_bot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay bot arm skin", FCVAR_PLUGIN|FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotArmModel,g_sReplayBotArmModel,256);
	HookConVarChange(g_hReplayBotArmModel, OnSettingChanged);	
	
	g_hPlayerModel   = CreateConVar("kz_player_skin", "models/player/ctm_sas_varianta.mdl", "Player skin", FCVAR_PLUGIN|FCVAR_NOTIFY);
	GetConVarString(g_hPlayerModel,g_sPlayerModel,256);
	HookConVarChange(g_hPlayerModel, OnSettingChanged);	
	
	g_hArmModel   = CreateConVar("kz_player_arm_skin", "models/weapons/ct_arms_sas.mdl", "Player arm skin", FCVAR_PLUGIN|FCVAR_NOTIFY);
	GetConVarString(g_hArmModel,g_sArmModel,256);
	HookConVarChange(g_hArmModel, OnSettingChanged);
	
	g_hWelcomeMsg   = CreateConVar("kz_welcome_msg", "Welcome. This server is using KZ Timer","Welcome message", FCVAR_PLUGIN|FCVAR_NOTIFY);
	GetConVarString(g_hWelcomeMsg,g_sWelcomeMsg,512);
	HookConVarChange(g_hWelcomeMsg, OnSettingChanged);

	g_hReplayBotProColor   = CreateConVar("kz_replay_bot_pro_color", "0 0 255","The default pro replay bot color? Format: \"red green blue\" from 0 - 255.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotProColor, OnSettingChanged);	
	decl String:szProColor[256];
	GetConVarString(g_hReplayBotProColor,szProColor,256);
	GetRGBColor(0,szProColor);
	
	g_hReplayBotTpColor   = CreateConVar("kz_replay_bot_tp_color", "255 127 59","The default tp replay bot color? Format: \"red green blue\" from 0 - 255.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotTpColor, OnSettingChanged);	
	decl String:szTpColor[256];
	GetConVarString(g_hReplayBotTpColor,szTpColor,256);
	GetRGBColor(1,szTpColor);
	
	g_hAutoBan 	= CreateConVar("kz_anticheat_auto_ban", "0", "on/off - auto-ban (bhop hack and strafe hack) including deletion of all player records - Info: There's always an anticheat log (sourcemod/logs) even if this function is disabled", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoBan     = GetConVarBool(g_hAutoBan);
	HookConVarChange(g_hAutoBan, OnSettingChanged);	
	
	g_hBanDuration   = CreateConVar("kz_anticheat_ban_duration", "72.0", "Ban duration (hours)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 999999.0);
	
	//jump physics depend on tickrate.. therefore different defaults
	if (g_tickrate == 64)
	{
		g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "325.0", "Max counted pre speed for bhop,dropbhop (no speed limiter)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 400.0);
		g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "235.0", "Minimum distance for longjumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_pro_lj   	= CreateConVar("kz_dist_pro_lj", "243.0", "Minimum distance for longjumps to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 220.0, true, 999.0);
		g_hdist_leet_lj    	= CreateConVar("kz_dist_leet_lj", "248.0", "Minimum distance for longjumps to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 245.0, true, 999.0);	
		g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "250.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_pro_weird  = CreateConVar("kz_dist_pro_wj", "265.0", "Minimum distance for weird jumps to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_leet_weird   = CreateConVar("kz_dist_leet_wj", "275.0", "Minimum distance for weird jumps to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "240.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_pro_dropbhop  = CreateConVar("kz_dist_pro_dropbhop", "290.0", "Minimum distance for drop bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_leet_dropbhop   = CreateConVar("kz_dist_leet_dropbhop", "297.0", "Minimum distance for drop bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "240.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_pro_bhop  = CreateConVar("kz_dist_pro_bhop", "290.0", "Minimum distance for bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_leet_bhop   = CreateConVar("kz_dist_leet_bhop", "295.0", "Minimum distance for bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_pro_multibhop  = CreateConVar("kz_dist_pro_multibhop", "330.0", "Minimum distance for multi-bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_leet_multibhop   = CreateConVar("kz_dist_leet_multibhop", "340.0", "Minimum distance for multi-bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
	}
	else
	{
		if (g_tickrate == 128)
		{
			g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "360.0", "Max counted pre speed for bhop,dropbhop  (no speed limiter)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 400.0);
			g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "240.0", "Minimum distance for longjumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_lj   	= CreateConVar("kz_dist_pro_lj", "254.0", "Minimum distance for longjumps to be considered pro [JumpStats Colorchat All] prestrafe 1 = 270)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_leet_lj    	= CreateConVar("kz_dist_leet_lj", "263.0", "Minimum distance for longjumps to be considered leet [JumpStats Colorchat All] prestrafe 1 = 275", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 245.0, true, 999.0);	
			g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "255.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_weird  = CreateConVar("kz_dist_pro_wj", "280.0", "Minimum distance for weird jumps to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_weird   = CreateConVar("kz_dist_leet_wj", "285.0", "Minimum distance for weird jumps to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "275.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_dropbhop  = CreateConVar("kz_dist_pro_dropbhop", "320.0", "Minimum distance for drop bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_dropbhop   = CreateConVar("kz_dist_leet_dropbhop", "325.0", "Minimum distance for drop bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "280.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_bhop  = CreateConVar("kz_dist_pro_bhop", "320.0", "Minimum distance for bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_bhop   = CreateConVar("kz_dist_leet_bhop", "325.0", "Minimum distance for bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_pro_multibhop  = CreateConVar("kz_dist_pro_multibhop", "335.0", "Minimum distance for multi-bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_leet_multibhop   = CreateConVar("kz_dist_leet_multibhop", "343.0", "Minimum distance for multi-bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);		
			}
		else
		{
			g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "350.0", "Max counted pre speed for bhop,dropbhop (no speed limiter)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 400.0);
			g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "235.0", "Minimum distance for longjumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_lj   	= CreateConVar("kz_dist_pro_lj", "250.0", "Minimum distance for longjumps to be considered pro [JumpStats Colorchat All] (prestrafe 1 = 263)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_leet_lj    	= CreateConVar("kz_dist_leet_lj", "255.0", "Minimum distance for longjumps to be considered leet [JumpStats Colorchat All] (prestrafe 1 = 268)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 245.0, true, 999.0);	
			g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "240.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_weird  = CreateConVar("kz_dist_pro_wj", "280.0", "Minimum distance for weird jumps to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_weird   = CreateConVar("kz_dist_leet_wj", "285.0", "Minimum distance for weird jumps to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "285.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_dropbhop  = CreateConVar("kz_dist_pro_dropbhop", "315.0", "Minimum distance for drop bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_dropbhop   = CreateConVar("kz_dist_leet_dropbhop", "320.0", "Minimum distance for drop bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "280.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_pro_bhop  = CreateConVar("kz_dist_pro_bhop", "315.0", "Minimum distance for bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_leet_bhop   = CreateConVar("kz_dist_leet_bhop", "320.0", "Minimum distance for bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_pro_multibhop  = CreateConVar("kz_dist_pro_multibhop", "240.0", "Minimum distance for multi-bhops to be considered pro [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_leet_multibhop   = CreateConVar("kz_dist_leet_multibhop", "245.0", "Minimum distance for multi-bhops to be considered leet [JumpStats Colorchat All]", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 200.0, true, 9999.0);		
		}
	}	
		
	g_fBanDuration    = GetConVarFloat(g_hBanDuration);
	HookConVarChange(g_hBanDuration, OnSettingChanged);	
	
	g_fMaxBhopPreSpeed    = GetConVarFloat(g_hMaxBhopPreSpeed);
	HookConVarChange(g_hMaxBhopPreSpeed, OnSettingChanged);	
		
	g_dist_good_weird	= GetConVarFloat(g_hdist_good_weird);
	HookConVarChange(g_hdist_good_weird, OnSettingChanged);	

	g_dist_pro_weird	= GetConVarFloat(g_hdist_pro_weird);
	HookConVarChange(g_hdist_pro_weird, OnSettingChanged);	
	
	g_dist_leet_weird    = GetConVarFloat(g_hdist_leet_weird);
	HookConVarChange(g_hdist_leet_weird, OnSettingChanged);	

	g_dist_good_dropbhop	= GetConVarFloat(g_hdist_good_dropbhop);
	HookConVarChange(g_hdist_good_dropbhop, OnSettingChanged);	
	
	g_dist_pro_dropbhop	= GetConVarFloat(g_hdist_pro_dropbhop);
	HookConVarChange(g_hdist_pro_dropbhop, OnSettingChanged);	
	
	g_dist_leet_dropbhop    = GetConVarFloat(g_hdist_leet_dropbhop);
	HookConVarChange(g_hdist_leet_dropbhop, OnSettingChanged);	
		
	g_dist_good_bhop	= GetConVarFloat(g_hdist_good_bhop);
	HookConVarChange(g_hdist_good_bhop, OnSettingChanged);	
	
	g_dist_pro_bhop	= GetConVarFloat(g_hdist_pro_bhop);
	HookConVarChange(g_hdist_pro_bhop, OnSettingChanged);	
	
	g_dist_leet_bhop    = GetConVarFloat(g_hdist_leet_bhop);
	HookConVarChange(g_hdist_leet_bhop, OnSettingChanged);	
	
	g_dist_good_multibhop	= GetConVarFloat(g_hdist_good_multibhop);
	HookConVarChange(g_hdist_good_multibhop, OnSettingChanged);	
	
	g_dist_pro_multibhop	= GetConVarFloat(g_hdist_pro_multibhop);
	HookConVarChange(g_hdist_pro_multibhop, OnSettingChanged);	

	g_dist_leet_multibhop    = GetConVarFloat(g_hdist_leet_multibhop);
	HookConVarChange(g_hdist_leet_multibhop, OnSettingChanged);	
		
	g_dist_good_lj      = GetConVarFloat(g_hdist_good_lj);
	HookConVarChange(g_hdist_good_lj, OnSettingChanged);	
	
	g_dist_pro_lj      = GetConVarFloat(g_hdist_pro_lj);
	HookConVarChange(g_hdist_pro_lj, OnSettingChanged);	
	
	g_dist_leet_lj      = GetConVarFloat(g_hdist_leet_lj);
	HookConVarChange(g_hdist_leet_lj, OnSettingChanged);	
	
	db_setupDatabase();
	
	//client commands
	RegConsoleCmd("sm_accept", Client_Accept, "[KZTimer] allows you to accept a challenge request");
	RegConsoleCmd("sm_goto", Client_GoTo, "[KZTimer] teleports you to a selected player");
	RegConsoleCmd("sm_disablegoto", Client_DisableGoTo, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_showkeys", Client_InfoPanel, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_info", Client_InfoPanel, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_menusound", Client_ClimbersMenuSounds,"[KZTimer] on/off climbers menu sounds");
	RegConsoleCmd("sm_sync", Client_StrafeSync,"[KZTimer] on/off strafe sync in chat");
	RegConsoleCmd("sm_sound", Client_QuakeSounds,"[KZTimer] on/off quake sounds");
	RegConsoleCmd("sm_cpmessage", Client_CPMessage,"[KZTimer] on/off checkpoint message in chat");
	RegConsoleCmd("sm_surrender", Client_Surrender, "[KZTimer] surrender your current challenge");
	RegConsoleCmd("sm_next", Client_Next,"[KZTimer] goto next checkpoint");
	RegConsoleCmd("sm_usp", Client_Usp, "[KZTimer] spawns a usp silencer");
	RegConsoleCmd("sm_bhop", Client_AutoBhop,"[KZTimer] on/off autobhop (only mg_,surf_ and bhop_ maps supported)");
	RegConsoleCmd("sm_undo", Client_Undo,"[KZTimer] undoes your last telepoint");
	RegConsoleCmd("sm_flashlight", Client_Flashlight,"[KZTimer] on/off flashlight");
	RegConsoleCmd("sm_prev", Client_Prev,"[KZTimer] goto previous checkpoint");
	RegConsoleCmd("sm_ljblock", Client_Ljblock,"[KZTimer] registers a lj block");
	RegConsoleCmd("sm_adv", Client_AdvClimbersMenu, "[KZTimer] advanced climbers menu (additional: !next, !prev and !undo)");
	RegConsoleCmd("sm_unstuck", Client_Prev,"[KZTimer] go to previous checkpoint");
	RegConsoleCmd("sm_maptop", Client_MapTop,"[KZTimer] displays local map top for a given map");
	RegConsoleCmd("sm_stuck", Client_Prev,"[KZTimer] go to previous checkpoint");
	RegConsoleCmd("sm_checkpoint", Client_Save,"[KZTimer] save your current position");
	RegConsoleCmd("sm_gocheck", Client_Tele,"[KZTimer] go to latest checkpoint");
	RegConsoleCmd("sm_hidespecs", Client_HideSpecs, "[KZTimer] hides spectators from menu/panel");
	RegConsoleCmd("sm_compare", Client_Compare, "[KZTimer] compare your challenge results");
	RegConsoleCmd("sm_menu", Client_Kzmenu, "[KZTimer] opens kztimer climbers menu");
	RegConsoleCmd("sm_measure",Command_Menu, "[KZTimer] allows you to measure the distance between 2 points");
	RegConsoleCmd("sm_abort", Client_Abort, "[KZTimer] abort your current challenge");
	RegConsoleCmd("sm_spec", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_watch", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_spectate", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_challenge", Client_Challenge, "[KZTimer] starts a map race against someone");
	RegConsoleCmd("sm_helpmenu", Client_Help, "[KZTimer] help menu which displays all kztimer commands");
	RegConsoleCmd("sm_help", Client_Help, "[KZTimer] help menu which displays all kztimer commands");
	RegConsoleCmd("sm_profile", Client_Profile, "[KZTimer] opens a player profile");
	RegConsoleCmd("sm_rank", Client_Profile, "[KZTimer] opens a player profile");
	RegConsoleCmd("sm_options", Client_OptionMenu, "[KZTimer] opens options menu");
	RegConsoleCmd("sm_top", Client_Top, "[KZTimer] displays top rankings (Top 100 Players, Top 5 Global, Top 5 Global 128tick, Top50 overall, Top 20 Pro, Top 20 with Teleports, Top 20 LJ, Top 20 Bhop, Top 20 Multi-Bhop, Top 20 WeirdJump, Top 20 Drop Bunnyhop)");
	RegConsoleCmd("sm_topclimbers", Client_Top, "[KZTimer] displays top rankings (Top 100 Players, Top 5 Global, Top 5 Global 128tick, Top50 overall, Top 20 Pro, Top 20 with Teleports, Top 20 LJ, Top 20 Bhop, Top 20 Multi-Bhop, Top 20 WeirdJump, Top 20 Drop Bunnyhop)");
	RegConsoleCmd("sm_top15", Client_Top, "[KZTimer] displays top rankings (Top 100 Players, Top 5 Global, Top 5 Global 128tick, Top50 overall, Top 20 Pro, Top 20 with Teleports, Top 20 LJ, Top 20 Bhop, Top 20 Multi-Bhop, Top 20 WeirdJump, Top 20 Drop Bunnyhop)");
	RegConsoleCmd("sm_start", Client_Start, "[KZTimer] go back to start");
	RegConsoleCmd("sm_r", Client_Start, "[KZTimer] go back to start");
	RegConsoleCmd("sm_stop", Client_Stop, "[KZTimer] stops your timer");
	RegConsoleCmd("sm_speed", Client_InfoPanel, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_pause", Client_Pause,"[KZTimer] on/off client pause (sets your timer on hold and freezes your current position)");
	RegConsoleCmd("sm_colorchat", Client_Colorchat, "[KZTimer] on/off jumpstats messages of others in chat");
	RegConsoleCmd("sm_showsettings", Client_Showsettings,"[KZTimer] shows kztimer server settings");
	RegConsoleCmd("sm_latest", Client_Latest,"[KZTimer] shows latest map records");
	RegConsoleCmd("sm_showtime", Client_Showtime,"[KZTimer] on/off - timer text in panel/menu");	
	RegConsoleCmd("sm_shownames", Client_Shownames, "[KZTimer] on/off target name center panel");
	RegConsoleCmd("sm_hide", Client_Hide, "[KZTimer] on/off - hides other players"); 
	RegConsoleCmd("+noclip", NoClip, "[KZTimer] Player noclip on");
	RegConsoleCmd("-noclip", UnNoClip, "[KZTimer] Player noclip off");
	RegConsoleCmd("sm_bhopcheck", Command_Stats, "[KZTimer] checks bhop stats for a given player");
	RegAdminCmd("sm_kzadmin", Admin_KzPanel, ADMIN_LEVEL, "[KZTimer] Displays the kz admin panel");
	RegAdminCmd("sm_resettimes", Admin_DropAllMapRecords, ADMIN_LEVEL, "[KZTimer] Resets player times (drops table playertimes)");
	RegAdminCmd("sm_resetranks", Admin_DropPlayerRanks, ADMIN_LEVEL, "[KZTimer] Resets the player point system (drops table playerrank)");
	RegAdminCmd("sm_resetmaptimes", Admin_ResetMapRecords, ADMIN_LEVEL, "[KZTimer] Resets player times for given map");
	RegAdminCmd("sm_resetplayertimes", Admin_ResetRecords, ADMIN_LEVEL, "[KZTimer] Resets tp & pro map times for given steamid with or without given map");
	RegAdminCmd("sm_resetplayertptime", Admin_ResetRecordTp, ADMIN_LEVEL, "[KZTimer] Resets tp map time for given steamid and map");
	RegAdminCmd("sm_resetplayerprotime", Admin_ResetRecordPro, ADMIN_LEVEL, "[KZTimer] Resets pro map time for given steamid and map");
	RegAdminCmd("sm_resetjumpstats", Admin_DropPlayerJump, ADMIN_LEVEL, "[KZTimer] Resets jump stats (drops table playerjumpstats)");	
	RegAdminCmd("sm_resetallljrecords", Admin_ResetAllLjRecords, ADMIN_LEVEL, "[KZTimer] Resets all lj records");
	RegAdminCmd("sm_resetallljblockrecords", Admin_ResetAllLjBlockRecords, ADMIN_LEVEL, "[KZTimer] Resets all lj block records");
	RegAdminCmd("sm_resetallwjrecords", Admin_ResetAllWjRecords, ADMIN_LEVEL, "[KZTimer] Resets all wj records");
	RegAdminCmd("sm_resetallbhoprecords", Admin_ResetAllBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets all bhop records");
	RegAdminCmd("sm_resetalldropbhopecords", Admin_ResetAllDropBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets all drop bjop records");
	RegAdminCmd("sm_resetallmultibhoprecords", Admin_ResetAllMultiBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets all multi bhop records");
	RegAdminCmd("sm_resetljrecord", Admin_ResetLjRecords, ADMIN_LEVEL, "[KZTimer] Resets lj record for given steamid");
	RegAdminCmd("sm_resetljblockrecord", Admin_ResetLjBlockRecords, ADMIN_LEVEL, "[KZTimer] Resets lj block record for given steamid");
	RegAdminCmd("sm_resetbhoprecord", Admin_ResetBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets bhop record for given steamid");	
	RegAdminCmd("sm_resetdropbhoprecord", Admin_ResetDropBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets drop bhop record for given steamid");
	RegAdminCmd("sm_resetwjrecord", Admin_ResetWjRecords, ADMIN_LEVEL, "[KZTimer] Resets wj record for given steamid");	
	RegAdminCmd("sm_resetmultibhoprecord", Admin_ResetMultiBhopRecords, ADMIN_LEVEL, "[KZTimer] Resets multi bhop record for given steamid");
	RegAdminCmd("sm_resetplayerjumpstats", Admin_ResetPlayerJumpstats, ADMIN_LEVEL, "[KZTimer] Resets jump stats for given steamid");
	RegAdminCmd("sm_deleteproreplay", Admin_DeleteProReplay, ADMIN_LEVEL, "[KZTimer] Deletes pro replay for a given map");
	RegAdminCmd("sm_deletetpreplay", Admin_DeleteTpReplay, ADMIN_LEVEL, "[KZTimer] Deletes tp replay for a given map");	
	RegAdminCmd("sm_getmultiplier", Admin_GetMulitplier, ADMIN_LEVEL, "[KZTimer] Gets the dynamic multiplier for given player (points)");
	RegAdminCmd("sm_setmultiplier", Admin_SetMulitplier, ADMIN_LEVEL, "[KZTimer] Sets the dynamic multiplier for given player and mutliplier value (points)");	
	RegConsoleCmd("say", Say_Hook);
	RegConsoleCmd("say_team", Say_Hook);
	AutoExecConfig(true, "kztimer");
	ownerOffset = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
	
	//setskill groups
	SetSkillGroups();
	
	//measure plugin
	g_hMainMenu = CreateMenu(Handler_MainMenu)
	SetMenuTitle(g_hMainMenu,"Measure")
	AddMenuItem(g_hMainMenu,"","Point 1 (Red)")
	AddMenuItem(g_hMainMenu,"","Point 2 (Green)")
	AddMenuItem(g_hMainMenu,"","Find Distance")
	AddMenuItem(g_hMainMenu,"","Reset")
	
	//add to admin menu
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
		OnAdminMenuReady(topmenu);
	
	//hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_start",Event_OnRoundStart,EventHookMode_PostNoCopy);
	HookEvent("round_start",Event_OnRoundStart2);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_Pre);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("player_jump", Event_OnJump);
	HookEvent("player_jump", Event_OnJumpMacroDox, EventHookMode_Post);
	HookEvent("player_team", Event_OnPlayerTeamPre, EventHookMode_Pre);
	HookEvent("player_team", Event_OnPlayerTeamPost, EventHookMode_Post);
	HookEntityOutput("trigger_teleport", "OnStartTouch", Teleport_OnStartTouch);	
	HookEntityOutput("trigger_multiple", "OnStartTouch", Teleport_OnStartTouch);	
	HookEntityOutput("func_button", "OnPressed", ButtonPress);

	//mapcycle array
	new arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	g_MapList = CreateArray(arraySize);	
	
	//add command listeners	
	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_ext_Menu, "radio1");
	AddCommandListener(Command_ext_Menu, "radio2");
	AddCommandListener(Command_ext_Menu, "radio3");
	AddCommandListener(Command_ext_Menu, "sm_nominate");
	AddCommandListener(Command_ext_Menu, "sm_admin");
	AddCommandListener(Command_ext_Menu, "sm_votekick");
	AddCommandListener(Command_ext_Menu, "sm_voteban");
	AddCommandListener(Command_ext_Menu, "sm_votemenu");
	AddCommandListener(Command_ext_Menu, "sm_revote");

	for(new i; i < sizeof(RadioCMDS); i++)
		AddCommandListener(BlockRadio, RadioCMDS[i]);
	
	//botmimic 2
	CheatFlag("bot_zombie", false, true);
	g_hLoadedRecordsAdditionalTeleport = CreateTrie();
		
	//multibhop
	//https://forums.alliedmods.net/showthread.php?p=808724
	g_iOffs_vecOrigin = FindSendPropInfo("CBaseEntity","m_vecOrigin");
	g_iOffs_vecMins = FindSendPropInfo("CBaseEntity","m_vecMins");
	g_iOffs_vecMaxs = FindSendPropInfo("CBaseEntity","m_vecMaxs");
	if(g_bLateLoaded) 
		OnPluginPauseChange(false);	
}

public OnLibraryAdded(const String:name[])
{	
	if (StrEqual("sourcebans", name))
	{
		bCanUseSourcebans = true;
	}
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
		g_hAdminMenu = INVALID_HANDLE;
	if (StrEqual("sourcebans", name))
		bCanUseSourcebans = false;
}

public OnAllPluginsLoaded()
{
	if (LibraryExists("sourcebans"))
		bCanUseSourcebans = true;
}

public OnMapStart()
{	
	//zipcore anti strafe hack
	for (new i = 1; i <= MaxClients; i++)
	{
		ResetStrafes(i);
		g_PlayerStates[i][bOn] = false;
	}
	g_fMapStartTime = GetEngineTime();
	g_bMapButtons=false;
	g_fRecordTime=9999999.0;
	g_fRecordTimePro=9999999.0;
	g_fRecordTimeGlobal = 9999999.0;
	g_fRecordTimeGlobal102 = 9999999.0;
	g_fRecordTimeGlobal128 = 9999999.0;
	g_fStartButtonPos[0] = -999999.9;
	g_fStartButtonPos[1] = -999999.9;
	g_fStartButtonPos[2] = -999999.9;
	g_fEndButtonPos[0] = -999999.9;
	g_fEndButtonPos[1] = -999999.9;
	g_fEndButtonPos[2] = -999999.9;
	g_maptimes_pro = 0;
	g_maptimes_tp = 0;
	g_iBot = -1;
	g_iBot2 = -1;
	g_bAntiCheat = false;
	g_bAutoBhop2=false;
	g_bRoundEnd=false;
	
	//get mapname
	decl String:mapPath[256];
	new bool: fileFound;
	GetCurrentMap(g_szMapName, MAX_MAP_LENGTH);
	Format(mapPath, sizeof(mapPath), "maps/%s.bsp", g_szMapName); 	
	fileFound = FileExists(mapPath);
	
	//fix workshop mapname
	new String:mapPieces[6][128];
	new lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[])); 
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece-1]); 
   
	//get map tag
	ExplodeString(g_szMapName, "_", g_szMapTag, 2, 32);
	g_bglobalValidFilesize=false;

	//get local map records
	db_GetMapRecord_CP();
	db_GetMapRecord_Pro();
	
	//players count
	db_CalculatePlayerCount();
	db_CalculatePlayerCountBigger0();
	
	//map ranks count
	db_viewMapProRankCount();
	db_viewMapTpRankCount();

	InitPrecache();	
	SetCashState();
	CreateTimer(0.1, MainTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, MainTimer2, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(2.0, RespawnTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(2.0, SettingsEnforcerTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(5.0, SecretTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(2.0, SpawnButtons, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);	
	CreateTimer(1.0, CheckRemainingTime, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	new String:tmp[64];
	
	CheatFlag("bot_zombie", false, true);	
	
	//srv settings
	ServerCommand("mp_spectators_max 60;mp_limitteams 0;sv_deadtalk 1;sv_full_alltalk 1;sv_max_queries_sec 6;bot_quota 0;host_players_show 2;mp_autoteambalance 0;mp_playerid 0;mp_autoteambalance 0;mp_ignore_round_win_conditions 1;mp_do_warmup_period 0;mp_free_armor 1;sv_alltalk 1;bot_chatter off;bot_join_after_player 0;bot_zombie 1;mp_endmatch_votenextmap 0;mp_endmatch_votenextleveltime 5;mp_maxrounds 1;mp_match_end_changelevel 1;mp_match_can_clinch 0;mp_halftime 0");
	Format(tmp,64, "bot_quota_mode %cnormal%c",QUOTE,QUOTE);
	ServerCommand(tmp);
	
	if (g_bEnforcer)
		ServerCommand("sm_cvar sv_enablebunnyhopping 1");		
		
	if (g_bCleanWeapons)
		ServerCommand("sv_infinite_ammo 0");

	//valid timestamp? [global db]
	if (fileFound && g_BGlobalDBConnected && g_bGlobalDB)
	{	
		g_unique_FileSize =  FileSize(mapPath);
		//supported map tags 
		if(StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc") || StrEqual(g_szMapTag[0],"bkz"))
			dbCheckFileSize();
	}
	//g_bglobalValidFilesize=true;
	//db_GetMapRecord_Global();
	
	//BotMimic2
	LoadReplays();
	
	//AutoBhop?
	if(StrEqual(g_szMapTag[0],"surf") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"mg"))
		if (g_bAutoBhop)
			g_bAutoBhop2=true;		
			
	//anticheat
	if((StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc")  || StrEqual(g_szMapTag[0],"bkz")) || g_bAutoBhop2 == false)
		g_bAntiCheat=true;

	//get implemented map buttons
	GetButtonsPos();
	
	//multibhop
	if (g_bMultiplayerBhop)
		ResetMultiBhop();
	
	//Skillgroups
	SetSkillGroups();
}

public OnMapEnd()
{
	//https://forums.alliedmods.net/showthread.php?p=808724
	AlterBhopBlocks(true);
	g_iBhopDoorCount = 0;
	g_iBot = -1;
	g_iBot2 = -1;
	g_iBhopButtonCount = 0;
}

public OnConfigsExecuted()
{
	new String:map[128];
	new String:map2[128];
	new mapListSerial = -1;
	g_pr_mapcount=0;
	if (ReadMapList(g_MapList, 
			mapListSerial, 
			"mapcyclefile", 
			MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_NO_DEFAULT)
		== INVALID_HANDLE)
	{
		if (mapListSerial == -1)
		{
			SetFailState("Mapcycle Not Found");
		}
	}
	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (!StrEqual(map, "", false))
		{
			//fix workshop map name			
			new String:mapPieces[6][128];
			new lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[])); 
			Format(map2, sizeof(map2), "%s", mapPieces[lastPiece-1]); 
			SetArrayString(g_MapList, i, map2);
			g_pr_mapcount++;
		}
	}	
			
	//Map Points	
	g_pr_dyn_maxpoints = RoundToCeil((g_pr_mapcount*1.0)*300+(((g_pr_mapcount*1.0)*300)*0.3));
	g_pr_rank_Novice = RoundToCeil(g_pr_dyn_maxpoints * 0.001);  
	g_pr_rank_Scrub = RoundToCeil(g_pr_dyn_maxpoints * 0.1); 
	g_pr_rank_Rookie = RoundToCeil(g_pr_dyn_maxpoints * 0.3);  
	g_pr_rank_Skilled = RoundToCeil(g_pr_dyn_maxpoints * 0.65);  
	g_pr_rank_Expert = RoundToCeil(g_pr_dyn_maxpoints * 1.2);  
	g_pr_rank_Pro = RoundToCeil(g_pr_dyn_maxpoints * 1.5);  
	g_pr_rank_Elite = RoundToCeil(g_pr_dyn_maxpoints * 1.85); 
	g_pr_rank_Master = RoundToCeil(g_pr_dyn_maxpoints * 2.2); 
	g_pr_points_finished = g_pr_rank_Novice;

	//map config
	decl String:szPath[256];
	Format(szPath, sizeof(szPath), "sourcemod/kztimer/%s_.cfg",g_szMapTag[0]);
	ServerCommand("exec %s", szPath);
	
	//add kztimer tag
	SetServerTags();
	
	//AutoBhop?
	if(StrEqual(g_szMapTag[0],"surf") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"mg"))
		if (g_bAutoBhop)
			g_bAutoBhop2=true;		
	
	//cheat protection
	if((StrEqual(g_szMapTag[0],"kz") || StrEqual(g_szMapTag[0],"xc") || StrEqual(g_szMapTag[0],"bkz")) || g_bAutoBhop2 == false)
		g_bAntiCheat=true;
}


//https://forums.alliedmods.net/showthread.php?p=808724
public OnPluginPauseChange(bool:pause1) 
{
	if (pause1) 
		OnPluginEnd();
	else
		ResetMultiBhop();
}

public OnPluginEnd() 
{
	AlterBhopBlocks(true);
	g_iBhopDoorCount = 0;
	g_iBhopButtonCount = 0;
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);	
	SDKHook(client, SDKHook_PostThink, Hook_Radar);
	bFlagged[client] = false;
	if (g_bCountry)
		GetCountry(client);
		
	ResetStrafes(client);
	g_PlayerStates[client][bOn] = false;
}

public OnClientAuthorized(client)
{
	if (g_bConnectMsg)
	{
		decl String:s_Country[32];
		decl String:s_clientName[32];
		decl String:s_address[32];		
		GetClientIP(client, s_address, 32);
		GetClientName(client, s_clientName, 32);
		Format(s_Country, 100, "Unknown");
		if(!IsFakeClient(client))
		{
			GeoipCountry(s_address, s_Country, 100);     
			if(!strcmp(s_Country, NULL_STRING))
				Format( s_Country, 100, "Unknown", s_Country );
			else				
				if( StrContains( s_Country, "United", false ) != -1 || 
					StrContains( s_Country, "Republic", false ) != -1 || 
					StrContains( s_Country, "Federation", false ) != -1 || 
					StrContains( s_Country, "Island", false ) != -1 || 
					StrContains( s_Country, "Netherlands", false ) != -1 || 
					StrContains( s_Country, "Isle", false ) != -1 || 
					StrContains( s_Country, "Bahamas", false ) != -1 || 
					StrContains( s_Country, "Maldives", false ) != -1 || 
					StrContains( s_Country, "Philippines", false ) != -1 || 
					StrContains( s_Country, "Vatican", false ) != -1 )
				{
					Format( s_Country, 100, "The %s", s_Country );
				}				
			
		}	
		if (StrEqual(s_Country, "Unknown",false) || StrEqual(s_Country, "Localhost",false))
		{
			if(IsFakeClient(client))
				PrintToChatAll("BOT %s %cconnected%c.",s_clientName, GREEN,GRAY);
			else
				PrintToChatAll("Player %s %cconnected%c.",s_clientName, GREEN,GRAY);
		}
		else
			PrintToChatAll( "Player %s %cconnected from%c %s.", s_clientName, GREEN,GRAY,s_Country);
	}
}

public OnClientPostAdminCheck(client)
{	
	if (IsFakeClient(client))
		g_hRecordingAdditionalTeleport[client] = CreateArray(_:AdditionalTeleport);
	
	//set default values
	for( new i = 0; i < MAX_STRAFES; i++ )
	{
		g_strafe_good_sync[client][i] = 0.0;
		g_strafe_frames[client][i] = 0.0;
	}
	g_bValidTeleport[client]=false;
	g_bNewReplay[client] = false;
	g_pr_Calculating[client] = false;
	g_bHyperscrollWarning[client] = false;
	g_fPlayerCordsLastPosition[client][0] = 0.0;
	g_fPlayerCordsLastPosition[client][1] = 0.0;
	g_fPlayerCordsLastPosition[client][2] = 0.0;
	g_fPlayerLastTime[client] = -1.0;
	g_bTimeractivated[client] = false;	
	g_bKickStatus[client] = false;
	detailView[client]=-1;
	g_UspDrops[client] = 0;
	g_fPlayerCordsUndoTp[client][0] =0.0;
	g_fPlayerCordsUndoTp[client][1] =0.0;
	g_fPlayerCordsUndoTp[client][2] =0.0;
	g_bchallengeConnected[client] = true;
	g_challenge_win_ratio[client] = 0;
	g_challenge_points_ratio[client] = 0;
	g_bSpectate[client] = false;
	g_ground_frames[client] = 0;
	g_fPlayerConnectedTime[client]=GetEngineTime();			
	g_bFirstSpawn[client] = true;	
	g_bFirstSpawn2[client] = true;
	g_bSayHook[client] = false;
	g_CurrentCp[client] = -1;
	g_SpecTarget[client] = -1;
	g_CounterCp[client] = 0;
	g_OverallCp[client] = 0;
	g_OverallTp[client] = 0;
	g_pr_points[client] = 0;
	if (IsFakeClient(client))
		CS_SetMVPCount(client,1);	
	else
		g_MVPStars[client] = 0;
	g_LeetJumpDominating[client] = 0;
	g_bRestartCords[client] = false;
	g_bPlayerJumped[client] = false;
	g_brc_PlayerRank[client] = false;
	g_PrestrafeFrameCounter[client] = 0;
	g_PrestrafeVelocity[client] = 1.0;
	g_fRunTime[client] = -1.0;
	g_fStartTime[client] = -1.0;
	g_ground_frames[client] = 0;
	g_bPause[client] = false;
	g_bPositionRestored[client] = false;
	g_bPauseWasActivated[client]=false;
	g_bTopMenuOpen[client] = false;
	g_bRestoreC[client] = false;
	g_bRestoreCMsg[client] = false;
	g_bRespawnPosition[client] = false;
	g_bNoClip[client] = false;		
	g_bMapFinished[client] = false;
	g_last_ground_frames[client] = 11;
	g_multi_bhop_count[client] = 1;
	Format(g_szPlayerPanelText[client], 512, "");
	Format(g_pr_rankname[client], 32, "");
	g_AdminMenuLastPage[client] = 0;
	g_OptionMenuLastPage[client] = 0;	
	g_bChallenge[client] = false;
	g_bOverlay[client]=false;
	g_bChallengeRequest[client] = false;
	g_fLastTimeButtonSound[client] = 9999.9;
	g_bMapRankToChat[client] = false;
	g_fJump_InitialLastHeight[client] = -1.012345;
	g_fLastJumpDistance[client] = 0.0;		
	g_good_sync[client] = 0.0;
	g_fLastTimeNoClipUsed[client] = -1.0;
	g_sync_frames[client] = 0.0;
	g_maprank_tp[client] = 99999;
	g_maprank_pro[client] = 99999;
	g_fLastTime_DBQuery[client] = GetEngineTime();
		
	//options
	g_bInfoPanel[client]=false;
	g_bClimbersMenuSounds[client]=true;
	g_bEnableQuakeSounds[client]=true;
	g_bShowNames[client]=true; 
	g_bStrafeSync[client]=false;
	g_bGoToClient[client]=true; 
	g_bShowTime[client]=true; 
	g_bHide[client]=false; 
	g_bCPTextMessage[client]=false; 
	g_bAdvancedClimbersMenu[client]=false;
	g_bColorChat[client]=true; 
	g_bShowSpecs[client]=true;
	g_bAutoBhopClient[client]=true;

	if (IsFakeClient(client))
		return;	
		
	//DB
	GetClientAuthString(client, g_szSteamID[client], 32);	
 	db_viewPersonalRecords(client,g_szSteamID[client],g_szMapName);	
	db_viewPersonalBhopRecord(client, g_szSteamID[client]);
	db_viewPersonalMultiBhopRecord(client, g_szSteamID[client]);	
	db_viewPersonalWeirdRecord(client, g_szSteamID[client]);
	db_viewPersonalDropBhopRecord(client, g_szSteamID[client]); 
	db_viewPersonalLJBlockRecord(client, g_szSteamID[client]);
	db_viewPersonalLJRecord(client, g_szSteamID[client]);
	db_viewPlayerOptions(client, g_szSteamID[client]);	

	
	// ' char fix
	decl String:szName[64];
	decl String:szOldName[64];
	GetClientName(client,szName,64);
	Format(szOldName, 64,"%s ",szName);
	ReplaceChar("'", "`", szName);
	if (!(StrEqual(szOldName,szName)))
	{
		SetClientInfo(client, "name", szName);
		SetEntPropString(client, Prop_Data, "m_szNetname", szName);
		CS_SetClientName(client, szName);
	}


	//macrodox
	new i;
	while (i < 30)
	{
		aaiLastJumps[client][i] = -1;
		i++;
	}
	
	//Restore time and position
	if(g_bRestore)
		db_selectLastRun(client);		
			
	//console info
	PrintConsoleInfo(client);
}

public OnClientDisconnect(client)
{
	if (IsFakeClient(client) && g_hRecordingAdditionalTeleport[client] != INVALID_HANDLE)
		CloseHandle(g_hRecordingAdditionalTeleport[client]);
		
	if (client == g_iBot || client == g_iBot2)
	{
		StopPlayerMimic(client);
		if (client == g_iBot)
			g_iBot = -1;
		else
			g_iBot2 = -1;
		return;
	}	
	//Database	
	if (IsClientInGame(client))
	{
		db_insertLastPosition(client,g_szMapName);
		db_updatePlayerOptions(client);
	}	
	//stop recording
	if(g_hRecording[client] != INVALID_HANDLE)
		StopRecording(client);

	// Measure-Plugin by DaFox
	//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
	ResetPos(client);
	//Macrodox
	aiJumps[client] = 0;
	afAvgJumps[client] = 5.0;
	afAvgSpeed[client] = 250.0;
	afAvgPerfJumps[client] = 0.3333;
	aiPattern[client] = 0;
	aiPatternhits[client] = 0;
	aiAutojumps[client] = 0;
	aiIgnoreCount[client] = 0;
	bFlagged[client] = false;
	avVEL[client][2] = 0.0;
	
	//zipcore anti strafe hack
	ResetStrafes(client);
	g_PlayerStates[client][bOn] = false;
}

public OnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{	
	if(convar == g_hGoToServer)
	{
		if(newValue[0] == '1')
			g_bGoToServer = true;
		else
			g_bGoToServer = false;
	}
	if(convar == g_hfpsCheck)
	{
		if(newValue[0] == '1')
			g_bfpsCheck = true;	
		else
			g_bfpsCheck = false;
	}	
	if(convar == g_hPreStrafe)
	{
		if(newValue[0] == '1')
			g_bPreStrafe = true;
		else
			g_bPreStrafe = false;
	}	
	if(convar == g_hNoClipS)
	{
		if(newValue[0] == '1')
			g_bNoClipS = true;
		else
			g_bNoClipS = false;
	}	
	if(convar == g_hAutoBan)
	{
		if(newValue[0] == '1')
			g_bAutoBan = true;
		else
			g_bAutoBan = false;
	}		
	if(convar == g_hReplayBot)
	{
		if(newValue[0] == '1')
		{
			g_bReplayBot = true;
			LoadReplays();
		}
		else
		{		
			for (new i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))	
			{
				if (i == g_iBot2 || i == g_iBot)
				{
					StopPlayerMimic(i);
				}
				else 
				{
					if(g_hRecording[i] != INVALID_HANDLE)
						StopRecording(i);
				}
			}
			g_bReplayBot = false;	
			CreateTimer(0.0,KickBotsTimer,_,TIMER_FLAG_NO_MAPCHANGE);
		}
	}	
	if(convar == g_hGlobalDB)
	{
		if(newValue[0] == '1')
			g_bGlobalDB = true;
		else
			g_bGlobalDB = false;
	}

	if(convar == g_hAdminClantag)
	{
		if(newValue[0] == '1')
		{
			g_bAdminClantag = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i))	
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);						
		}
		else
		{
			g_bAdminClantag = false;
			for (new i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i))	
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);		
		}
	}
	
	if(convar == g_hVipClantag)
	{
		if(newValue[0] == '1')
		{
			g_bVipClantag = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i))	
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);		
		}
		else
		{
			g_bVipClantag = false;
			for (new i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i))	
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);		
		}
	}
	if(convar == g_hAutoTimer)
	{
		if(newValue[0] == '1')
			g_bAutoTimer = true;
		else
			g_bAutoTimer = false;
	}		
	if(convar == g_hPauseServerside)
	{
		if(newValue[0] == '1')
			g_bPauseServerside = true;
		else
			g_bPauseServerside = false;
	}
	if(convar == g_hAutohealing_Hp)
		g_Autohealing_Hp = StringToInt(newValue[0]);	
	
	if(convar == g_hAutoRespawn)
	{
		if(newValue[0] == '1')
			g_bAutoRespawn = true;
		else
			g_bAutoRespawn = false;
	}	
	if(convar == g_hAllowCheckpoints)
	{
		if(newValue[0] == '1')
			g_bAllowCheckpoints = true;
		else
			g_bAllowCheckpoints = false;
	}
	if(convar == g_hRadioCommands)
	{
		if(newValue[0] == '1')
			g_bRadioCommands = true;
		else
			g_bRadioCommands = false;
	}	
	if(convar == g_hcvarRestore)
	{
		if(newValue[0] == '1')
			g_bRestore = true;			
		else
			g_bRestore = false;
	}
	if(convar == g_hMapEnd)
	{
		if(newValue[0] == '1')
			g_bMapEnd = true;			
		else
			g_bMapEnd = false;
	}
	if(convar == g_hConnectMsg)
	{
		if(newValue[0] == '1')
			g_bConnectMsg = true;			
		else
			g_bConnectMsg = false;
	}
	if(convar == g_hMultiplayerBhop)
	{
		if(newValue[0] == '1')
		{
			g_bMultiplayerBhop = true;		
			ResetMultiBhop();
		}
		else
		{
			g_bMultiplayerBhop = false;
			AlterBhopBlocks(true)
			g_iBhopDoorCount = 0
			g_iBhopButtonCount = 0		
		}
	}		
	if(convar == g_hPlayerSkinChange)
	{
		if(newValue[0] == '1')
		{
			g_bPlayerSkinChange = true;
			for (new i = 1; i <= MaxClients; i++)
				if (1 <= i <= MaxClients && IsClientInGame(i) && i != g_iBot2 && i != g_iBot)	
				{
					SetEntPropString(i, Prop_Send, "m_szArmsModel", g_sArmModel);
					SetEntityModel(i,  g_sPlayerModel);
				}
		}
		else
			g_bPlayerSkinChange = false;
	}	
	if(convar == g_hPointSystem)
	{
		if(newValue[0] == '1')
		{
			g_bPointSystem = true;		
			for (new i = 1; i <= MaxClients; i++)
				if (1 <= i <= MaxClients && IsClientInGame(i))				
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);					
		}
		else
		{
			for (new i = 1; i <= MaxClients; i++)
				if (1 <= i <= MaxClients && IsClientInGame(i))
				{
					Format(g_pr_rankname[i], 32, "");
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
				}
			g_bPointSystem = false;
		}
	}	

	
	if(convar == g_hcvarNoBlock)
	{
		if(newValue[0] == '1')
		{
			g_bNoBlock = true;
			for(new client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					
		}
		else
		{	
			g_bNoBlock = false;
			for(new client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
		}
	}
	
	if(convar == g_hCleanWeapons)
	{
		if(newValue[0] == '1')
		{
			decl String:szclass[32];
			g_bCleanWeapons = true;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (1 <= i <= MaxClients && IsClientInGame(i) && IsPlayerAlive(i))
				{
					for(new j = 0; j < 4; j++)
					{
						new weapon = GetPlayerWeaponSlot(i, j);
						if(weapon != -1 && j != 2)
						{
							GetEdictClassname(weapon, szclass, sizeof(szclass));
							RemovePlayerItem(i, weapon);
							RemoveEdict(weapon);							
							new equipweapon = GetPlayerWeaponSlot(i, 2)
							if (equipweapon != -1)
								EquipPlayerWeapon(i, equipweapon); 
						}
					}
				}
			}
			
		}
		else
			g_bCleanWeapons = false;
	}
	
	if(convar == g_hEnforcer)
	{
		if(newValue[0] == '1')		
		{
			g_bEnforcer = true;
			ServerCommand("sm_cvar sv_enablebunnyhopping 1");
		}
		else
			g_bEnforcer = false;
	}	
	
	if(convar == g_hJumpStats)
	{
		if(newValue[0] == '1')		
			g_bJumpStats = true;
		else
			g_bJumpStats = false;
	}		
	
	if(convar == g_hAutoBhop)
	{
		if(newValue[0] == '1')		
		{		
			g_bAutoBhop = true;		
			if(StrEqual(g_szMapTag[0],"surf") || StrEqual(g_szMapTag[0],"bhop") || StrEqual(g_szMapTag[0],"mg"))
			{
				g_bAntiCheat	= false;
				g_bAutoBhop2 = true;
			}
		}
		else
		{
			g_bAutoBhop = false;
			g_bAutoBhop2 = false;
			g_bAntiCheat = true;
		}
	}		
		
	if(convar == g_hCountry)
	{
		if(newValue[0] == '1')
		{
			g_bCountry = true;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (1 <= i <= MaxClients && IsClientInGame(i))
				{
					GetCountry(i);
					if (g_bPointSystem)
						CreateTimer(0.5, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		else
		{
			g_bCountry = false;
			if (g_bPointSystem)
				for (new i = 1; i <= MaxClients; i++)
					if (1 <= i <= MaxClients && IsClientInGame(i))				
						CreateTimer(0.5, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);		
		}
	}	
	
	if(convar == g_hdist_good_multibhop)
		g_dist_good_multibhop = StringToFloat(newValue[0]);	
	
	if(convar == g_hdist_pro_multibhop)
		g_dist_pro_multibhop = StringToFloat(newValue[0]);			
	
	if(convar == g_hdist_leet_multibhop)
		g_dist_leet_multibhop = StringToFloat(newValue[0]);	
	
	if(convar == g_hdist_good_bhop)
		g_dist_good_bhop = StringToFloat(newValue[0]);
	
	if(convar == g_hdist_pro_bhop)
		g_dist_pro_bhop = StringToFloat(newValue[0]);		
	
	if(convar == g_hdist_leet_bhop)
		g_dist_leet_bhop = StringToFloat(newValue[0]);		

	if(convar == g_hdist_good_dropbhop)
		g_dist_good_dropbhop = StringToFloat(newValue[0]);
	
	if(convar == g_hdist_pro_dropbhop)
		g_dist_pro_dropbhop = StringToFloat(newValue[0]);		
	
	if(convar == g_hdist_leet_dropbhop)
		g_dist_leet_dropbhop = StringToFloat(newValue[0]);	

	if(convar == g_hdist_good_weird)
		g_dist_good_weird = StringToFloat(newValue[0]);
	
	if(convar == g_hdist_pro_weird)
		g_dist_pro_weird = StringToFloat(newValue[0]);		
	
	if(convar == g_hdist_leet_weird)
		g_dist_leet_weird = StringToFloat(newValue[0]);	
	
	if(convar == g_hdist_good_lj)
		g_dist_good_lj = StringToFloat(newValue[0]);
	
	if(convar == g_hdist_pro_lj)
		g_dist_pro_lj = StringToFloat(newValue[0]);
	
	if(convar == g_hdist_leet_lj)
		g_dist_leet_lj = StringToFloat(newValue[0]);
	
	if(convar == g_hBanDuration)
		g_fBanDuration = StringToFloat(newValue[0]);
		
	if(convar == g_hBhopSpeedCap)
		g_fBhopSpeedCap = StringToFloat(newValue[0]);	
	
	if(convar == g_hMaxBhopPreSpeed)
		g_fMaxBhopPreSpeed = StringToFloat(newValue[0]);	
		
	if(convar == g_hcvargodmode)
	{
		if(newValue[0] == '1')
			g_bgodmode = true;
		else
			g_bgodmode = false;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (1 <= i <= MaxClients && IsClientInGame(i))
			{	
				if (g_bgodmode)
					SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
				else
					SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	
	if(convar == g_hReplayBotPlayerModel)
	{
		Format(g_sReplayBotPlayerModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sReplayBotPlayerModel);
		if (g_iBot2 != -1)
			SetEntityModel(g_iBot2,  newValue[0]);
		if (g_iBot != -1)
			SetEntityModel(g_iBot,  newValue[0]);	
	}
	
	if(convar == g_hReplayBotArmModel)
	{
		Format(g_sReplayBotArmModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);		
		AddFileToDownloadsTable(g_sReplayBotArmModel);
		if (g_iBot2 != -1)
				SetEntPropString(g_iBot2, Prop_Send, "m_szArmsModel", newValue[0]);
		if (g_iBot != -1)
				SetEntPropString(g_iBot, Prop_Send, "m_szArmsModel", newValue[0]);	
	}
	
	if(convar == g_hPlayerModel)
	{
		Format(g_sPlayerModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);	
		AddFileToDownloadsTable(g_sPlayerModel);
		if (!g_bPlayerSkinChange)
			return;
		for (new i = 1; i <= MaxClients; i++)
			if (1 <= i <= MaxClients && IsClientInGame(i) && i != g_iBot2 && i != g_iBot)	
				SetEntityModel(i,  newValue[0]);
	}
	
	if(convar == g_hArmModel)
	{
		Format(g_sArmModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);		
		AddFileToDownloadsTable(g_sArmModel);
		if (!g_bPlayerSkinChange)
			return;
		for (new i = 1; i <= MaxClients; i++)
			if (1 <= i <= MaxClients && IsClientInGame(i) && i != g_iBot2 && i != g_iBot)	
				SetEntPropString(i, Prop_Send, "m_szArmsModel", newValue[0]);
	}
	
	if(convar == g_hWelcomeMsg)
		Format(g_sWelcomeMsg,512,"%s", newValue[0]);

	if(convar == g_hReplayBotTpColor)
	{
		decl String:color[256];
		Format(color,256,"%s", newValue[0]);
		GetRGBColor(1,color);	
	}	
	if(convar == g_hReplayBotProColor)
	{
		decl String:color[256];
		Format(color,256,"%s", newValue[0]);
		GetRGBColor(0,color);
	}	
	
}

public Native_GetTimerStatus(Handle:plugin, numParams)
{
	return g_bTimeractivated[GetNativeCell(1)];
}

public Native_StopUpdatingOfClimbersMenu(Handle:plugin, numParams)
{
	g_bMenuOpen[GetNativeCell(1)] = true;
	if (g_hclimbersmenu[GetNativeCell(1)] != INVALID_HANDLE)
	{	
		g_hclimbersmenu[GetNativeCell(1)] = INVALID_HANDLE;
	}
	if (g_bClimbersMenuOpen[GetNativeCell(1)])
		g_bClimbersMenuwasOpen[GetNativeCell(1)]=true;
	else
		g_bClimbersMenuwasOpen[GetNativeCell(1)]=false;
	g_bClimbersMenuOpen[GetNativeCell(1)] = false;		
}

public Native_StopTimer(Handle:plugin, numParams)
{
	Client_Stop(GetNativeCell(1),0);
}

//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public OnGameFrame()
{
	if (iTickCount2 > 1*MaxClients)
		iTickCount2 = 1;
	else
	{
		if (iTickCount2 % 1 == 0)
		{
			new index = iTickCount2 / 1;
			if (bSurfCheck[index] && IsClientInGame(index) && IsPlayerAlive(index))
			{	
				GetEntPropVector(index, Prop_Data, "m_vecVelocity", avVEL[index]);
				if (avVEL[index][2] < -290)
				{
					aiIgnoreCount[index] = 2;
				}
				
			}
		}
		iTickCount2++;
	}
}