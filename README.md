# Valheim modding notes for Claude

Working notes for building and maintaining the SnakeSquad Valheim mods with Claude. They are written for an AI assistant picking up the work cold, but anyone modding Valheim with BepInEx and Harmony may find the game-system notes useful.

## Where to start

- [`docs/VALHEIM_MODDING_NOTES_v1.40.md`](docs/VALHEIM_MODDING_NOTES_v1.40.md): the main notes. Sections 1 to 4 and 8 cover setup, CI, Harmony and working preferences; section 7 has one part per mod.
- [`docs/game/`](docs/game/README.md): one small file per game system (attacks, terrain, mist, projectiles, audio and so on), with the class and method names that matter, their gotchas, and the game version they were read from.
- [`docs/SNAKEWAYSURFER_HANDOFF.md`](docs/SNAKEWAYSURFER_HANDOFF.md): a short handoff for the SnakewaySurfer mod.

## How these notes are kept

- Read only the parts for the mod you are working on.
- After changing a mod, add what changed and what you learned to its section.
- Findings from decompiled game code go in a `docs/game/` topic file: names, signatures, key fields and gotchas, with only the few lines that matter quoted. No raw dumps.
- Refer to the mods' author as SAT. Never write anyone's real name in these notes.
- Never put credentials, tokens or private addresses in these notes. This repository is public.

These notes were kept in the SnakeWood repository until 2026-11-11.
