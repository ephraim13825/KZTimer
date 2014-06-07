Alliedmodders kztimer thread: https://forums.alliedmods.net/showthread.php?t=223274

Info: 
- KZTimer is designed as Kreedz/Climb plugin!
- KZ AntiCheat is automatically disabled if kz_auto_bhop is set to 1
- PRO VERSION CURRENTLY NOT AVAILABLE


do you wanna test kztimer before?
176.57.141.133:27032 [UG] KREEDZ EUROPE



Changelog
=======

v1.33 standard edition
- code optimization (contains a lot smaller bug fixes)
- added client commands !ljblock and !flashlight
- added longjump block stats
- db table playerjumpstats3 replaces playerjumpstats2 

--> how to port jumpstats data from the old table into the new table: 
- install the new version of kztimer
- start the server and stop it then again (kztimer  creates automatically the new db table playerjumpstats3)
- use navicat lite (or some other db front end) and export the data from playerjumpstats2 into a .txt file. (format doenst matter)
- Afterwards u have to import the file in playerjumpstats3 --> DONE







v1.32 standard/pro
- fixed a tp glitch (thx 2 x3ro)
- optimized wall touch method to prevent fail detections (jumpstats)
- added a chat message for players if they missed their personal best 
- minor optimizations

v1.31 casual
- fixed dropbhop glitch
- fixed wrong rank promotion after earning points
- fixed a minor jumpstats glitch
- changed global database password

v1.30 standard / v1.31 pro
- changed replay bot names: -TYPE- REPLAY BOT -NAME- (-TIME-)
- adjusted the replay panel
- removed db_deleteInvalidGlobalEntries from MapEnd method (*watchdog*)
- fixed some minor issues for workshop maps
- -> fixed: Exception list is not loaded.
- -> fixed: Timer freezes, gets stuck and when you stop the time it sometimes takes 10 seconds to register.
