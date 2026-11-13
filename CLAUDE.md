# CLAUDE.md: SnakeSquad Valheim mods

Standing instructions for any Claude Code session working on the SnakeSquad Valheim mods (BepInEx + Harmony mods for the SnakeSquad Discord group's dedicated server). This repo holds the shared notes. Read this file first, then only the notes for the mod you are working on.

This repo is public. Never write credentials, tokens, email addresses, private addresses or anyone's real name here. Refer to the mods' author as **SAT**.

## Repos

Clone the ones you need next to this repo:

| Mod | Repo |
|---|---|
| Modding notes (this repo) | https://github.com/SAT155/ValheimModdingNotesForClaude |
| SnakeWood | https://github.com/SAT155/SnakeWood |
| SnakeSkills (Sailing, Ranching, Mining, Landscaping hoe, smart hammer) | https://github.com/SAT155/SnakeSailing |
| SnakeHammer (SmartBuild fork) | https://github.com/SAT155/SnakeHammer |
| SnakeTography (North Wisp, map marker) | https://github.com/SAT155/ValheimMapMarker |
| SnakeSmarterHoe (being phased out) | https://github.com/SAT155/SnakeSmarterHoe |
| SnakePolearms | https://github.com/SAT155/SnakePolearms |
| SnakewaySurfer | https://github.com/SAT155/SnakewaySurfer |
| SnakeGravityHammer | https://github.com/SAT155/SnakeGravityHammer |

Several repos use a `claude/project-thread-*` branch as their default or latest working branch. Check the branch list and open PRs before starting, and build on the latest branch named below.

## Notes workflow

- Notes live on `main` in this repo. Start notes work on a new branch from `main` and open a PR into `main`.
- Read the notes before starting work. Whenever you change a mod repo (a merged PR or pushed work), update the relevant notes here with what changed and what you learned.
- Old notes copies in the SnakeWood repo are frozen. Do not edit them.
- Ordering: if several sessions have made changes since the notes were last updated, update the notes one at a time, earliest change first. Pull the latest `main` before editing.
- Decompiled code: before decompiling, check `docs/game/` for an existing topic file. Record findings in small topic files (one per game system): class and method names, signatures, key fields, gotchas, and the game version decompiled. Link them from the main notes. Never commit raw decompiled dumps; quote only the few lines that matter.

## Notes index

Read only the files for your mod. N = `docs/VALHEIM_MODDING_NOTES_v1.40.md`, G = `docs/game/`. Update this index when the notes version changes.

| Work | Read |
|---|---|
| All work | N §1-4, §8 (setup, CI, Harmony, preferences) |
| SnakeWood | N §7; G/build-menu-and-pieces, network-objects |
| SnakeSmarterHoe / Landscaping hoe | N §7b; G/terrain-and-hoe |
| SnakePolearms | N §7c; G/attacks-and-throws, blocking-and-left-hand |
| SnakeHammer / smart hammer | N §7d, §7f; G/build-menu-and-pieces, hover-and-portal-triggers |
| ValheimMapMarker (SnakeTography) | N §7e; G/world-progress-keys, locations-and-custom-items |
| SnakeSkills (SnakeSailing repo) | N §7f; G/magic-costs-and-skills, staff-shield-and-combat-state, summons-and-dead-raiser, player-save-and-custom-skills, fishing, mist-and-demisters |
| SnakewaySurfer | N §7g; G/player-anim-input-visuals, camera-weather-terrain-look, projectiles-and-rocks, audio-zsfx; handoff `docs/SNAKEWAYSURFER_HANDOFF.md` |
| SnakeGravityHammer | its section in N |
| Other game systems | N §5, then G/README.md |

## Builds and releases

- Every mod repo uses SnakeWood-style GitHub releases: each push of mod changes builds in GitHub Actions and creates a release with the r2modman-ready Thunderstore zip attached directly, so SAT can download it and use "Import local mod" with no extract step.
- Give each test build a unique version number (the patch number is usually the Actions run number). On some repos a non-default branch only releases when the Build workflow is dispatched on it.
- **Never publish to Thunderstore.** SAT uploads there by hand when a version is ready.
- Repos are public so Actions minutes are free. If CI is refused for billing, the repo is probably still private: ask SAT to make it public.

## Rules for every mod

- **Vanilla-client safe:** some players on the server run no mods. A mod must never leave custom networked prefabs in the world that vanilla clients cannot load ("Missing prefab hash" spam). Prefer vanilla prefabs, or save custom pieces as a vanilla equivalent.
- **Valheim Plus:** the server runs Valheim Plus (building grid, Advanced Building/Editing modes; SAT's config has "no invalid placement" on). Mods must work with V+ on or off.
- **Public-facing package text:** changelogs, Thunderstore READMEs and manifests are written for players. No names, no internal notes, no talk of threads or test builds. Every Thunderstore README ends with a Feedback section using the feedback address already in the existing READMEs, and its feature list ends with a mod-specific joke that the mod can't let you dual wield spears.
- **Licences:** SAT's own mods (SnakeWood, SnakePolearms, SnakeTography, SnakewaySurfer, SnakeGravityHammer) are GPL-3.0, and new original mods should be too. SnakeHammer, SnakeSmarterHoe and SnakeSkills derive from third-party mods without an open licence: leave them unlicensed, and never upload SnakeSkills builds to Thunderstore.
- **UI:** keep it simple. SAT prefers visual and audio cues over popup text.

## Current state per mod

- **SnakeWood:** latest v1.23.167 (logs and sled under Transportation via `m_usage`).
- **SnakeSkills** (SnakeSailing repo): latest 1.28 (v1.28.108), branch `claude/project-thread-711mwk` (bubble shield autocast + HUD ready icon), stacked on 1.26 Dead Raiser and 1.25. Build further work on that branch as 1.29+. Keep skill names unchanged (skill ids are name hashes).
- **Smart hammer:** lives in SnakeSkills (`SnakeSkills/SmartBuild/`) on the vanilla hammer, always on since 1.22 (config switch, Y opens the blueprint list with pictures; 1.23 added a Blueprints tab in the vanilla build menu). There is no separate Smart Hammer item. It disables itself while SmartBuild/SnakeHammer is installed. New hammer work goes here, not in the SnakeHammer repo.
- **Hoe:** all hoe work goes in SnakeSkills' Landscaping hoe. SnakeSmarterHoe is being phased out (too many features, cluttered UI). Port only what is asked for and keep the hoe UI minimal.
- **SnakePolearms:** latest v1.1.7, released with the SnakeWood scheme.
- **SnakewaySurfer** (`surfsup` endless-runner minigame, client-only): latest v1.16.225, branch `claude/project-thread-8ph0gw`. Build further work there and dispatch Build to release. The `surftest` self-test tour and `surfkit` commands produce screenshots and a report folder for SAT to send back with LogOutput.log; always check the version line in the log first. Architecture work comes before new features. See §7g and the handoff doc.
- **SnakeGravityHammer:** standalone mod (hold a key while placing to tilt and settle pieces onto the ground), latest v1.3.5.

## Working habits

- Keep sessions lean on tokens: batch related bugs together, prefer a fresh session over a very long one, and don't start large unrequested work.
- Nearly every build ships untested and SAT is the only tester, so say what is unverified and ask for the log lines that would confirm it.
- Mod and thread titles that mention a mod end with its latest released version, e.g. "SnakeHammer v1.21.3".
