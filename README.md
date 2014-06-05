Alliedmodders kztimer thread: https://forums.alliedmods.net/showthread.php?t=223274

Info: KZ AntiCheat is automatically disabled if kz_auto_bhop is set to 1

Changelog
=======

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
