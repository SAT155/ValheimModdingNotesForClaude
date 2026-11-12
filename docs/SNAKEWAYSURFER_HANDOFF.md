# SnakewaySurfer handoff (2026-11-07)

**State:** v1.16.171 (2026-11-11, branch `claude/project-thread-8ph0gw`, draft PR #6: self-test tour and raven picture, stacked on) v1.16.163 (2026-11-10, branch `claude/project-thread-jzg0yv`, draft PR #5 stacked on #1: dungeon junctions, chase cam in dungeons, health regen, star mixes, boss fixes; see notes §7g). Before that v1.16.149 (2026-11-10; a dodge roll passes labeled Block attacks and creatures, except Wall roots and vines; includes u27urh v1.16.132 Strange Portal fix; camp rest menu opens on sitting) is on branch `claude/project-thread-2zimly`, which is draft PR #1 into the default branch `claude/project-thread-9zfoi6`. A branch that isn't the default releases only when Build is dispatched on it with `workflow_dispatch`. Code is in `SnakewaySurfer/*.cs`, about 29k lines. Never publish to Thunderstore.

## Build and release
- CI is the only compiler. Each push that builds auto-releases as v1.16.N.
- Wait for CI:
  ```
  sha=$(git rev-parse HEAD); sleep 20; for i in $(seq 1 60); do r=$(gh api "repos/SAT155/SnakewaySurfer/actions/runs?head_sha=$sha" --jq '[.workflow_runs[]|select(.name=="Build")][0]|"\(.id) \(.status) \(.conclusion)"'); case "$r" in *completed*) echo $r; break;; esac; sleep 15; done
  ```
- Errors on failure:
  ```
  gh api repos/SAT155/SnakewaySurfer/actions/jobs/<jobid>/logs | grep "error CS"
  ```
  The job id comes from `actions/runs/<id>/jobs`.
- Common build errors:
  - CS0136: a local name reused in a nested scope, often `half`, `key` or `name`.
  - CS0535: a missing interface member. Hoverable needs `GetHoverOffset`.
- After each release:
  - Add a changelog line to `thunderstore/SnakewaySurfer/README.md` under "Changelog (spoilers)".
  - Add a notes bullet to `docs/VALHEIM_MODDING_NOTES_v1.40.md` (section 7g, before "## 8.").
  - Update memory in `snakewaysurfer.md` (keep it under 4 KB) and MEMORY.md.
  - Rename the thread to "SnakewaySurfer vX".
- Pushing prints "repository moved". This is harmless.

## Testing without SAT's eyes (2026-11-11)
- `surftest` in the console plays the run by itself and saves screenshots, `log.txt` and `report.txt` to `BepInEx/SnakewaySurferTest/<time>/`. Ask SAT for that folder (zipped) after each release instead of single bug reports. Details: notes section 7g, "SnakewaySurfer self-test and review".
- Every hit is in the BepInEx log as `Hit: ...`.
- Review and plan: https://claude.ai/artifact/Sa48CY9QvnaGMexzBYf9tn. Work lives on branch `claude/project-thread-8ph0gw` (PR #6, stacked on #5).

### What the first self-test run taught (2026-11-11, v1.16.171 run, fixes in v1.16.178)

- The tour works: 18 stops, 134 screenshots, no exceptions. Build contact sheets (12 per sheet) to read them cheaply.
- Attack zones (gas clouds, sweeps, boss strikes) are `Thing`s with `Threat`, `Life > 0` and no `Info`. They are warned by lane markers, so they are not "late appearances"; 1.16.178 stops counting them.
- Every lane marker now registers in `m_markerNotes` (`NoteMarker` from `MakeMarker`). The autopilot reads markers like a player (leave red, roll under blue, jump when all three are red) and parries duel swings (`m_duelLand`, `m_botBlock`). Each `Hit:` line says how long the player's lane had been marked, or "no marker on your lane": that phrase is the unfair-hit signal to look for.
- Hits that bypass `m_things` (boss chase strikes, duel swings, Yagluth's beam, sea rocks) show "in view for ?".
- The autopilot still cannot steer at sea, play the Elder's maze, hold a totem for Yagluth, or predict hares and deer that change lane.
- Storm strikes (`StormStrike` in SurfBolts.cs) whited out the screen; now smaller with capped lights. Moder's breath and Yagluth's blast still wash out the view.
- A Lox that hits fills the camera. The stage menu tiles look crooked. Dungeons show black above the walls.
- `Plugin.BuildVersion` gives the real release number (CI seds `BuildNumber` in Plugin.cs before compiling).
- Second run (v1.16.178): hits fell from 63 to 16 and none came from Eikthyr, Bonemass or the Queen, so marker reading works. Lightning no longer whites out the screen and the drawn Hugin reads clearly.
- The game log had no raven portrait lines at all: `RavenUi.Portrait` left silently because `Pictures.MeshBounds` found no active, enabled mesh. Likely cause: `RavenTemplate()` copies `Raven.m_visual` while Hugin is hidden. v1.16.183 switches the copy's renderers and their parents on and logs "Hugin's model: N meshes, M parts were switched off". Check that line in the next log; if M is 0 the cause is something else.
- A Plains start begins with the ocean crossing unless `Progress.Landed`; the tour now skips that (`Touring` in SurfBoss.cs).
- Still open from the hit list: a Blob (hurdle, gas3) hit a player 1.0 m up in a jump with no marker on the lane.
- Latest release: v1.16.225 (was v1.16.216, v1.16.196) (was v1.16.189, v1.16.183), SnakewaySurfer branch `claude/project-thread-8ph0gw` (PR #6).

### 1.16.189: biomes truer to the game (owner feedback: dungeons and biomes looked nothing like the game)

- Scenery now comes from `ZoneSystem.instance.m_vegetation` (SurfVegetation.cs): entries for the biome, weighted by count times group size, density worked out from the per-zone counts. Logs "<biome> vegetation from the game: ...". Setting: Game Vegetation.
- Mist (SurfMist.cs): a copy of the game's `ParticleMist` particle system with its script removed, emitted by hand with `ps.Emit(params, 1)` on the verges and far ahead. Logs "Mist borrowed from the game". Unverified in game.
- Ambience (SurfAmbience.cs): `EnvSetup.m_ambientLoop` of the biome's main weather on an own 2D source, random clips from `AudioMan.m_randomAmbients` matching the biome, and far creature calls (`sfx_gjall_idle_vocals` and friends; names for other biomes are guesses, the first that exists is played). Logs "<biome> ambience: ...".
- `surfkit` console command (SurfKit.cs): pictures every real dungeon room (plan and two inside views, parts list in rooms.txt) from `DungeonDB.GetRooms()`, then teleports the player to each biome's terrain spot (god and ghost mode on, midday forced with `EnvMan.m_debugTimeOfDay`), takes four screenshots and counts every ZNetView within 64 m into biomes.txt, then brings the player back. Output in BepInEx/SnakewaySurferTest/kit_<time>/.
- Next: when the kit folder comes back, rebuild the dungeons from the real room parts (roof, camera height) and tune vegetation against the census. Mistlands ground texture still to be checked against the pictures.

## Open bugs and owed items
- **Crash to desktop:** cause unknown. It happened on a retry in the Plains on v1.16.88 or older, and the log has no exception. SAT still owes the newest folder from `%userprofile%\AppData\LocalLow\IronGate\Valheim\Crashes`. v1.16.93 moved the ripple's `Camera.Render` out of OnGUI on a hunch.
- **Untested in game:**
  - Ravens:
    - The flying clip that `SurfStory.FlyClip` chooses. It's logged as "Raven flight: ...". If the log says "none", the ravens perch.
    - Whether the head-bone facing works.
    - Whether the text below Hugin is in view.
  - The dream ripple on portals (story portal, run entry, dream end).
  - Strange Portal behaviour.
  - Camp emotes and the harpoon animation.
  - The serpent tow.
- **Next feature:** coin bank and trader ability shop. Doc: https://claude.ai/artifact/PJ5gsWZaYt83pmpUDoCWHK. SAT's answers are in its comments:
  - Coins only go to the bank, and score resets each run.
  - The shops replace the life-refill stalls.
  - "Dreamify" the game's own store UI.
  - One vendor per biome on 1-star runs, two from 2 stars up.
  - Abilities last until that biome's boss.

## Where things live (open these; skip broad greps)
- **Run core:** `SurfGame.cs`. It holds state, Update and LateUpdate, `Begin()` (around line 304), ResetRun, and the GUI styles m_big, m_mid and m_small (around line 3790). It's 4k lines, so grep for the method name rather than reading it.
- **Menu, dream text, loading and ripple:** `SurfDream.cs` and `SurfMenu.cs`.
  - In SurfDream: BeginLoad, CoverNow, `CaptureWave`, `DrawWaveFrom`, `DrawHaze`, FirstRun.
  - `Fill` is in SurfMenu.
- **Ravens:**
  - World story (portal, nagging, sleep detection, `surfstory` command): `SurfStory.cs`. Line text is in `StoryLines.cs`.
  - In-run Hugin: `SurfRaven.cs`. It reuses SurfStory's static FlyClip, HoldFlight, HeadYaw and FitLive.
- **Checkpoints:** `SurfCheckpoint.cs`, with save data in `Progress.cs` (SaveResume, Resume, ClearResume).
- **Strange Portal hammer piece:** `SurfPortalPiece.cs`. It uses Harmony on ZNetScene.Awake and on ObjectDB Awake and CopyOtherDB.
- **Camp and harpoon:** `SurfCamp.cs`.
- **Rewards and timers:** `Rewards.cs`.
- **Sea:** `SurfSea.cs`, `SurfSeaFoes.cs` and `SurfHull.cs` (islands).
- **Bosses:** `SurfBoss.cs`, `SurfArena.cs` and `SurfChase.cs`.
- **Dungeons:** `SurfCrypt.cs`, `SurfCryptThemes.cs`, and `SurfCryptPlus.cs` (junctions, mud banks).
- **Configs and console commands:** `Plugin.cs`. The commands are surfsup, surfstory, surfportal and surfprogress.
- **Player data:** everything per character is in `player.m_customData`, with keys prefixed "SnakewaySurfer.". `surfprogress reset` wipes them all, including the story stage.

## Gotchas
- **Don't touch RenderSettings** around an overlay camera. Changing them makes the world's terrain lighting flicker.
- **Raven skinned bounds are bogus** (about 35 m) unless `updateWhenOffscreen` is set.
- **SAT's preferences:**
  - No popup text. Hugin speaks the messages.
  - Use Valheim's own assets.
  - Don't copy other games.
  - SAT runs Valheim Plus.
- **SAT's log:** it may not include our Info lines if it was taken at a lower log level. Ask for LogOutput.log from BepInEx.

### 1.16.196: architecture, first pieces (owner chose architecture work over small fixes)

- `SurfPlacement.cs` is Unity-free: slots (lane, from, to, need = Jump/Roll/Either/Wall) and `Passable(pace)`, a step-by-step search of what a runner can do within the game's jump, roll, cooldown and lane-change limits. `SnakewaySurfer.Tests` (net8 console) compiles the same file and checks it against hand-made cases and a simulated player on random tracks; the Build workflow runs it first ("Rule checks"). The checks caught a real bug (thin overlaps slipping between steps).
- `SurfGate.cs`: after each `SpawnRow`, the record is rebuilt from `m_things` and new things that close the track are destroyed, nearest the trouble first. Logs "Placement: took out ...". Only standing positions are known; moving creatures are recorded where they wait.
- `SurfStrike.cs`: in `Hit()`, an attack (`Threat` or `Life > 0`, labelled) is forgiven unless a marker lay on the runner's lane, or the visible attack was in view, for 0.4 s. Logs "Unwarned: ...", also into the self-test report. Next step: give each logged offender a declared warning.
- Settings: Fair Placement, Fair Warning.
- The cloud container can get a compiler with `apt-get update && apt-get install -y dotnet-sdk-8.0`, enough for Unity-free code and its checks; the mod itself still compiles only in CI.
- Plan and mind map: run loop in the middle; content tables, placement, attack records, modes, screen layout, look and sound, feedback tools, game bridge; a run builder (hand-made curated runs, about one biome long) is planned on top.

### 1.16.210 and 1.16.216: what the first run on the new builds showed (latest release v1.16.216)

- Lightning and thunder that carried on in the real world after a run: the boss weather's particle systems are instantiated onto the game's own camera and were only cleared when the weather faded, never when the run object was destroyed. `ClearWeather()` is now called from `OnDestroy`. Lesson: anything parented to a game object the mod doesn't own must be cleaned in `OnDestroy`.
- "Missing prefab hash" spam (32,000 lines in one session) was `piece_surf_strangeportal`: an old ZDO saved under the mod's own prefab name, in a game where that prefab never registered. `SurfPortalPiece.Sweep()` (every 20 s) rewrites such ZDOs to `portal_wood` plus the flag when `ZNetScene.GetPrefab(hash)` is null. Why the piece doesn't register for the owner is still unknown; the log line "Strange Portal: no wooden portal among the game's N prefabs" will say if the copy source is missing.
- `Stable hash` of a name can be computed offline to identify a missing prefab hash (the C# string hash with 5381 seeds and 1566083941 multiplier).
- surfkit results: biomes.txt census is good data (things within 64 m by prefab name). The vegetation table over-counts (Black Forest table 826 a zone, counted 229); `SurfCensus.cs` holds the counts and sets mix and density. Mistlands pictures are black (mist, no wisp light): next time switch the mist off for the shots. Room interior shots are often taken from inside a mesh; the parts lists are the useful part.
- Burial chamber rooms are not built of named pieces: groups "Walls", "Roof", "Floor" hold single stone meshes (material `stonewall`, floor `stonekit_floor_2x2`). `LoadRooms` keeps the first good stone of each as `<theme>_Walls1`, `_Roof1`, `_Floor1`.
- The Mistlands have no `m_ambientLoop` on their main weather and no entries in `AudioMan.m_randomAmbients`.
- The raven's animator switches its model off again after `Rebind`/`Update`; renderers are re-enabled after the animation is applied (unverified).
- Neither the placement gate nor the fair-warning guard fired in a full tour.

### 1.16.225: Mistlands storm and dungeon roofs (unseen in game at the time of writing)

- Mistlands storm: `UpdateMistStorm` in `SurfMist.cs` borrows the particle systems of the game's "Mistlands_thunder" weather (fallback "Queen") onto the run camera during open Mistlands stretches, not in dungeons or boss fights. `ClearMistStorm` runs in `OnDestroy`, because copies parented to the game camera otherwise outlive the run. Setting: Mistlands Storm. The log says "Mistlands storm: N effects borrowed ...".
- Roofs: the owner chose "roof on, camera lowered". `CryptRoof` in `SurfCryptPlus.cs` tiles a roof at `WallH + RoofLift` over hall legs and pockets (open for the first and last 6 m of a leg), from `CryptTheme.Roofs` with the floor pieces as fallback. `PlaceCryptCamera` caps the camera height under the roof. Setting: Dungeon Roof.
- Next: real walls and floors for the frost cave and infested mine; switch the mist off for Mistlands pictures in `surfkit`.

