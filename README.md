# Aura Hangout

A beginner-friendly Roblox Studio game built with Codex and Rojo.

The first playable version is a cozy Sunset Dream Island where players stand still in a glowing aura zone, earn Aura Points, and manually roll for colorful character auras.

## Current Status

Design approved. Implementation is planned in `docs/superpowers/plans/2026-05-21-roblox-aura-hangout-implementation.md`.

## Design Spec

See [docs/superpowers/specs/2026-05-21-roblox-aura-hangout-design.md](docs/superpowers/specs/2026-05-21-roblox-aura-hangout-design.md).

## Studio Setup

See [docs/studio-setup.md](docs/studio-setup.md).

## Playtesting

See [docs/playtest-checklist.md](docs/playtest-checklist.md).

## Local Checks

Run these checks from the project root:

```powershell
node scripts/smoke-check.mjs
node scripts/check-aura-definitions.mjs
node scripts/check-server-foundation.mjs
node scripts/check-roll-and-visuals.mjs
node scripts/check-world-and-loop.mjs
node scripts/check-client-ui.mjs
node scripts/check-docs.mjs
```

## Planned Workflow

1. Create a Rojo project structure.
2. Add Luau modules for aura definitions, point earning, rolling, equipping, and saving.
3. Build a simple UI for points, roll cost, current aura, and roll results.
4. Open the project in Roblox Studio and build or refine the Sunset Dream Island scene.
5. Playtest in Studio with one and two players.
