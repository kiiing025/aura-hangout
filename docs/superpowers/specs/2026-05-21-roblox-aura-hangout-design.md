# Roblox Aura Hangout Design

Date: 2026-05-21

## Summary

Build a first playable Roblox Studio game called a cozy AFK aura hangout. The game takes place on a small Sunset Dream Island where players earn Aura Points by standing still inside a glowing aura zone, then spend those points on a manual Roll button to unlock colorful character auras.

The first version focuses on one clear loop: stand still, earn points, roll an aura, equip it, and show it off. It intentionally avoids trading, pets, quests, combat, shops, and complex progression until the core loop feels good.

## Research Basis

The design is based on current Roblox player and platform signals:

- Roblox reports 132 million daily active users and 31 billion hours engaged for Q1 2026, and describes itself as one of the top online entertainment platforms for audiences under 18 by monthly visits and time spent.
- Roblox's 2025 Replay describes avatar self-expression as foundational, with 274 million daily avatar updates. Gen Z survey respondents reported changing avatars to express creativity, stand out, try a new identity, or match their mood.
- Roblox Creator documentation recommends teaching the core loop quickly, getting players to the fun fast, giving starter items or soft currency, and rewarding the loop with currency, items, and visible feedback.
- Popular Roblox aura/RNG experiences such as Sol's RNG and Magic RNG emphasize manual rolling, rare auras, luck, collection, and flexing rare rewards with friends.

Sources:

- Roblox Investor Relations: https://ir.roblox.com/overview/default.aspx
- Roblox 2025 Replay: https://about.roblox.com/newsroom/2025/12/roblox-replay-decoded-search-style
- Roblox Creator Hub onboarding docs: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/game-design/onboarding.md
- Roblox Creator Hub retention docs: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/retention.md
- Sol's RNG Roblox page: https://www.roblox.com/games/15532962292/Sols-RNG
- Magic RNG Roblox page: https://www.roblox.com/games/17250334236/Magic-RNG

## Goals

- Create a small first Roblox game that can be understood and tested quickly.
- Teach a beginner-friendly but real Roblox workflow using Studio plus Rojo-managed Luau files.
- Give players an immediate reward moment within the first few minutes.
- Make rewards visible on the avatar so collecting feels social.
- Keep the design safe for younger players by avoiding paid pressure, chat-dependent mechanics, or complicated social systems in the first version.

## Non-Goals

- No combat, enemies, or enemy AI.
- No trading system.
- No pet system.
- No quests or story missions.
- No premium purchases or monetization in v1.
- No complex shop or crafting system.
- No auto-roll in the first playable build.

## Player Experience

When a player joins, they spawn on a warm floating island with sunset lighting, soft grass, ocean or sky edges, and a clear glowing aura circle. A simple UI shows their Aura Points, roll cost, current aura, and Roll button.

The player enters the aura circle and stands still. While they remain in the zone and avoid moving, they earn Aura Points at the stillness bonus rate. When they have enough points, they press Roll. The server chooses one aura based on rarity weights, subtracts points, adds the aura to the player's inventory, equips it, and shows a result popup.

The aura appears around the player's character immediately using Roblox particle emitters, lights, attachments, or simple effects. Other players can see the aura, which gives the game its social flex moment.

## Core Loop

1. Enter the island.
2. Stand still in the aura zone.
3. Earn Aura Points.
4. Press Roll to spend points.
5. Receive a random aura.
6. Equip and show the aura.
7. Repeat to chase rarer auras.

## First Playable Features

- Aura zone that detects when players are inside it.
- Stillness detector that rewards players faster when they are not moving.
- Aura Points leaderstat or profile value.
- Manual Roll button.
- Weighted aura table with 8 to 10 starter auras.
- Equipped aura effect visible on the player character.
- Basic inventory data for owned auras.
- Simple UI for points, roll cost, current aura, and roll result.
- DataStore saving for points, owned aura IDs, and equipped aura ID.
- Studio setup notes for the island, aura zone, spawn, lighting, and starter props.

## Starter Aura Set

Use a small set so v1 is easy to test:

- Common: Sunrise, Seafoam, Golden Dust
- Uncommon: Rose Spark, Azure Breeze
- Rare: Solar Ring, Rainbow Drift
- Epic: Celestial Glow
- Legendary: Sunset Crown

The exact colors, weights, and effects can be tuned during implementation. Early rolls should be affordable so new players experience the reward loop quickly.

## Architecture

Use a beginner-friendly Rojo project inside the workspace.

Roblox service layout:

- `ReplicatedStorage`: shared aura definitions, rarity data, RemoteEvents, and RemoteFunctions.
- `ServerScriptService`: server-owned point earning, stillness checks, roll logic, equip logic, and DataStore persistence.
- `StarterPlayerScripts`: client controller for roll button requests and UI feedback.
- `StarterGui`: UI for point counter, roll button, current aura, and result popup.
- `Workspace`: Studio-built island, aura zone part, spawn point, lighting props, and optional aura preview podiums.

The server is authoritative. The client can request actions and display results, but it cannot decide point totals, roll outcomes, or owned auras.

## Data Model

Each player profile stores:

- `points`: current Aura Points.
- `ownedAuras`: list or dictionary of aura IDs the player has unlocked.
- `equippedAura`: aura ID currently displayed on the character.

The server loads this profile when the player joins, saves it when the player leaves, and periodically autosaves during play.

## Roll Logic

The client sends a roll request through a RemoteEvent or RemoteFunction. The server checks:

- Player profile is loaded.
- Player has enough Aura Points.
- Roll is not on cooldown.

If valid, the server subtracts the roll cost, chooses an aura from the weighted table, records the aura as owned, equips it, and returns the result. If invalid, the server returns a clear reason such as not enough points or profile not ready.

## Error Handling

The UI should show short, calm messages:

- Not enough points.
- Profile loading, try again.
- Roll failed, try again.

DataStore failures should not crash the server. If loading fails, the player can use a safe default profile for the session, and the server should attempt saving again later.

## Testing Plan

Use Roblox Studio playtesting:

- Join the game and confirm points start at the expected value.
- Enter the aura zone and confirm points increase.
- Move inside the zone and confirm stillness bonus pauses or slows.
- Leave the zone and confirm point earning stops.
- Press Roll without enough points and confirm an error message.
- Press Roll with enough points and confirm points subtract, an aura is awarded, and the aura appears.
- Roll many times and confirm rarity weights feel plausible.
- Rejoin and confirm saved points, owned auras, and equipped aura restore.
- Test with two players and confirm each player has independent points and aura state.

## Future Expansion

Good next updates after the first playable version:

- Auto-roll toggle after players understand manual rolling.
- More auras and seasonal variants.
- Aura inventory screen.
- Luck boosts earned through play.
- Social bonus for standing near friends.
- Simple leaderboard for rarest aura or total rolls.
- More island decorations and aura preview displays.

## Approval

The user approved:

- Sunset Dream Island visual direction.
- Colorful auras as the first collectible reward.
- Stillness bonus for earning Aura Points.
- Manual roll for the first playable version.
- Beginner-friendly Rojo project approach.
- First playable feature scope.
- Simple DataStore-backed profile saving.
