#KZTimer 1.59 Final Version

Alliedmodders: https://forums.alliedmods.net/showthread.php?t=223274    
Steam group: http://steamcommunity.com/groups/KZTIMER                                                                         

**Please read the following information carefully (!!):**
- Download includes DHooks2 Extention, Cleaner Extention and latest GeoIP database
- Ranking system is based on your mapcycle.txt file (keep it always up to date)
- A very large sqlite database might cause server lags (i prefer a mysql database)
- The climbers menu of KZTimer blocks menus of other plugins. But you are able to add exceptions in addons\sourcemod\configs\kztimer\exceptions_list.txt for sourcemod commands which create menus (e.g. sm_knife)
- You can give map makers a mapper tag which allows them to get access to noclip. (addons\sourcemod\configs\kztimer\mapmakers.txt )
- Datatable warnings are harmless as long as server logging is disabled

**About KZTimer**
- SQLite & MySQL support
- Sourcebans support
- Workshop maps support
- Multi-Language support (english, chinese, french, german, russian and swedish)
- KZTimer is in the final version (only bugs will be fixed from now on!)

Changelog
=======

v1.59
- fixed a minor multibhop bug
- fixed he/flash grenade attack spamming by adding "1 he/flash counts like 9 shots" to kz_attack_spam_protection
- increased USP weapon speed to 250.0 even if kz_prestrafe is disabled
- added auto-creation of spawn points (32 per team) on map start (spawnpoints7 plugin is not longer necessary)
- added server cvar kz_bhop_multi_touching (on/off - Allows players to touch a single bhop block more than once (0 required for global records)
Addtional information: KZTimer compares your last bhop block with the current block when "disabled". If you touch a block twice you will be teleported back to the start of the section.
This function doesn't work for maps which use 1 entity for more than 1 bhop block because these blocks share the same entity/block id. Fault of the mapper.. e.g. bhop_areaportal_v1
- new native methods: KZTimer_EmulateStartButtonPress, KZTimer_EmulateStopButtonPress and KZTimer_GetCurrentTime (These methods allow players to create start and end zones with 3rd party plugins or a 'stage addon' for KZTimer)
- removed unnecessary server cvars (cleanup): kz_recalc_top100_on_mapstart, kz_pro_mode, kz_fps_check (< 120 fps check remains), kz_multiplayer_bhop, kz_colored_chatranks and kz_checkpoints_on_bhop_plattforms (colored chat ranks and multiplayer bhop hard-coded enabled and kz_checkpoints_on_bhop_plattforms hard-coded disabled from now on)
- map chooser plugin is not longer required to run KZTimer
- updated all language files
- minor performance tweaks

v1.58
- fixed missing viewmodel after somebody uses !spec
- fixed "custom entities detected" glitch
- minor bug fixes

v1.57
- fixed player freezing after round restart
- fixed the abuse of +hook to get a further longjump
- fixed the abuse of custom entities (i won't go into detail here)
- fixed a pause bug in combination with kz_auto_timer 1
- minor bug fixes

v1.56
- fixed wrong ground speed after disabling kz_prestrafe (thx to Chuckles)
- fixed vertical jump bug on multi-bhop jumps (thx to GnagarN)
- added client command !help2 (explanation of the ranking system) 
- added sourcemod/configs/kztimer/hidden_chat_commands.txt (list of hidden chat commands -> this list was hard coded)

v1.55
- fixed redundant calculation of points for challenge winners 
- fixed displaying of the top 5 challengers with 10000+ points
- fixed weapons stripper method (knife plugins should work again) 
- fixed the viewmodel of tp and pro replay bots
- added kz_attack_spam_protection (max 40 shots, +5 new/extra shots per minute)
- added log off (prevents server crashes because of datatable warnings on servers without the cleaner extention) and sv_infinite_ammo 2 to cfg/sourcemod/kztimer/main.cfg
- added client option 'start weapon' USP/Knife
- added hookmod detection 
- added low fps check (fps_max < 120 results in a kick)  - thx to HtC^w
- minor optimizations


v1.54
- added admin command sm_refreshprofile <steamid>
- added server cvar kz_ranking_extra_points_firsttime (Gives players x (tp time = x, pro time = 2 * x) extra points for finishing a map (tp and pro) for the first time) 
- renamed kz_ranking_extra_points to kz_ranking_extra_points_improvements
- added skill group to chattag of admin's and vip's

v1.53
- fixed a minor jumpstats bug
- minor optimizations

v1.52b
- removed "steamgroup" language phrase

v1.52
- fixed chat phrase "ChallengeAborted"
- fixed timer bug on bhop_areaportal (moving plattforms)
- fixed func door bunnyhop blocks (e.g. on bhop_monsterjam)

v1.51
- added multi-language support (client command: !language)
- added four new language files (german, russian by blind, chinese by pchun, french by alouette)
- added admin command sm_resetplayerchallenges <steamid> (Resets (won) challenges for given steamid - requires z flag)
- fixed jumpstats glitch on kz_olympus
- fixed vertical jump glitch on multibhops
- minor optimizations

v1.5
- added server cvar kz_ranking_extra_points (Gives players x extra points for improving their time. That makes it a easier to rank up.)
-> YOU SHOULD execute sm_ResetExtraPoints after updating from an old kztimer version(<1.49) if u wanna give extrapoints because extra points are saved in an old database field which was used otherwise and got some wrong values
- fixed two minor bugs on player profiles
- added admin command sm_ResetExtraPoints
- fixed two jumpstats bugs
- minor optimizations

v1.49
- new optional feature: DHooks extention. Dhooks prevents a wrong mimic of replay bots after teleporting! (Old replays remain broken)
- overhauled the ranking system (you should recalculate all player ranks after updating kztimer: !kzadmin -> recalculate player ranks). 
- replaced skillgroups.txt by skillgroups.cfg. The new config file allows you to change rank limits
- added MAPPER clantag (steamid's can be added in sourcemod/configs/kztimer/mapmakers.txt)
- added skill group points to !ranks command

 
v1.48
- fixed missing team join message
- minor optimizations

v1.47
- removed global records
- fixed a bug, which allowed players to abuse pause on boosters
- fixed "player joined CT/T" chat message on player disconnect
- added further strafe hack preventions
- put some server cvars from the main.cfg back into the kztimer mapstart method because they must be set anways
- --> mp_endmatch_votenextmap 0;mp_do_warmup_period 0;mp_warmuptime 0;mp_match_can_clinch 0;mp_match_end_changelevel 1;mp_match_restart_delay 10;mp_endmatch_votenextleveltime 10;mp_endmatch_votenextmap 0;mp_halftime 0;bot_zombie 1;mp_do_warmup_period 0;mp_maxrounds 1	
- added an auto. .nav file generator but only for maps in your mapcycle.txt (execuded on plugin start)
- minor bug fixes and optimizations

v1.46
- optimized prestrafe method (tickrate 64)

v1.45
- fixed a prestrafe bug
- increased refreshing of speed/keys center panel
- re-integrated dhooks extention (should fix the wrong position of the replay bots after a teleport. old replays remain broken) - dhooks is optional!


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
