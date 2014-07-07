Alliedmodders kztimer thread: https://forums.alliedmods.net/showthread.php?t=223274

Info: 
- KZTimer is designed as Kreedz/Climb plugin!
- tickrate 102.4 is optimal for kreedzing (start parameter: -tickrate 102.4)
- The point system is based on the mapcycle.txt of cs:go. That is why you should keep your mapcycle always up to date!
- keep also your database clean and delete player times from maps which are not longer in your mapcycle because map records on those maps are still counted in the top pro/tp climbers list (!resetmaptimes <map>)
- datatable warnings are harmless
- Log "error": [SDKTOOLS] "FindEntityByClassname" not supported by this mod, falling back to IServerTools method.
-> https://forums.alliedmods.net/showthread.php?t=235737
- KZ AntiCheat is automatically disabled when kz_auto_bhop is set to 1
- globalconnections.sp doenst contain the correct login data
- Global map record requirements (Global record top5 appears on all servers which are using KZ Timer):
>kz_checkpoints_on_bhop_plattforms 0, kz_auto_timer 0, kz_settings_enforcer 1 and
>only kz_, bkz_ and xc_ maps with integrated climb buttons are supported

- Known bug:
The prestrafe method doenst work for a very (very very!) small amount of players. Reason: Unkown and probably cliend-side

Changelog
=======

v1.44
- changed global database login (new host ip)
- database admin commands requires root flag now

v1.43
- added <"SET NAMES  'utf8'"> (global database)
- divided kz_replay_bot_skin in kz_replay_tpbot_skin and kz_replay_probot_skin
- divided kz_replay_bot_arm_skin in kz_replay_tpbot_arm_skin and kz_replay_probot_arm_skin
- added colors tags in all center/hint messages

v1.42
- added cfg/sourcemod/kztimer/main.cfg (these server cvars were hard-coded) (don't forget to add this file. very important!)
- moved the map type configs to cfg/sourcemod/kztimer/map_types/ (u have to update your folder structure!)
- added server cvar kz_info_bot: provides information about nextmap and timeleft in his player name
- added server cvar kz_recalc_top100_on_mapstart: on/off - starts a recalculation of top 100 player ranks at map start.
- added server cvar kz_pro_mode: (!) EXPERIMENTAL (!) on/off - jump penalty, prespeed cap at 300.0, own global top, prestrafe and server settings which feels much more 
like in 1.6. This makes maps which requires multibhops (> 280 units) impossible. Also only tickrate 102.4 supported
additional info: Those were the features of the kztimer pro version
- fixed team selection bug (only windows servers were affected. MAJOR FIX)
- fixed sm_deleteproreplay command (file access was blocked through a handle)
- removed target name panel (replaced by weapon_reticle_knife_show)
- added jumpstats support for scalable ljblocks (func_movelinear entities)
- fixed a noclip bug (thx 2 AXO) 
- optimized the ranking system
- minor optimizations

v1.41
- fixed a "undo tp" bug which occurs in combination with bunnyhop plattforms (thx 2 skill vs luck)
- added "unfinished maps" to player profile
- changed global database password
- minor optimizations

v1.4
- fixed timer bug (thx 2 skill vs luck) 
- minor optimizations

v1.39
- fixed a timer bug on bhop_eazy_csgo
- fixed chat spam of remaining time if mp_timelimit is set to 0
- fixed team selection overlay glitch (windows only)

v1.38
- fixed random map end crashes (major fix)
- fixed a jumpstats glitch (thx 2 x3ro)
- added color support for kz_welcome_msg
- added "start" to adv climbers menu
- added kz_checkpoints_on_bhop_plattforms (on/off checkpoints on bhop plattforms)
- minor code optimizations
- *knife plugin updated

v1.37
- removed ljtop sql message in console
- fixed a noclip glitch (thx 2 umbrella)
- kzadmin menu optimized

v1.36
- added server cvar kz_colored_ranks (on/off - colored chat ranks)
- added client command !ranks (prints available player ranks into cha)
- minor optimizations

v1.35
- renamed default skill groups
- minor optimizations

v1.34 
- fixed surf glitch
- fixed replay bot panel

v1.33 
- code optimization (contains a lot smaller bug fixes)
- added client commands !ljblock and !flashlight
- added longjump block stats
- db table playerjumpstats3 replaces playerjumpstats2 

--> how to port jumpstats data from the old table into the new table: 
- install the new version of kztimer
- start the server and stop it then again (kztimer  creates automatically the new db table playerjumpstats3)
- use navicat lite (or some other db front end) and export the data from playerjumpstats2 into a .txt file. (format doenst matter)
- Afterwards u have to import the file in playerjumpstats3 --> DONE


v1.32 
- fixed a tp glitch (thx 2 x3ro)
- optimized wall touch method to prevent fail detections (jumpstats)
- added a chat message for players if they missed their personal best 
- minor optimizations

v1.31 
- fixed dropbhop glitch
- fixed wrong rank promotion after earning points
- fixed a minor jumpstats glitch
- changed global database password

v1.30 
- changed replay bot names: -TYPE- REPLAY BOT -NAME- (-TIME-)
- adjusted the replay panel
- removed db_deleteInvalidGlobalEntries from MapEnd method (*watchdog*)
- fixed some minor issues for workshop maps
- -> fixed: Exception list is not loaded.
- -> fixed: Timer freezes, gets stuck and when you stop the time it sometimes takes 10 seconds to register.
