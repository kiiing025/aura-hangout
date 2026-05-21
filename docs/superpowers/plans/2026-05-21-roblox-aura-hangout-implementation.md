# Aura Hangout First Playable Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable Roblox Studio version of Aura Hangout: Sunset Dream Island, stillness-based Aura Points, manual aura rolls, equipped colorful auras, saving, and beginner-friendly Studio setup docs.

**Architecture:** Use a Rojo project where file-based Luau syncs into Roblox services. Server scripts own points, stillness checks, rolling, saving, and aura visuals; the client script only creates UI and requests server actions. A server-side world builder creates the starter island scene so the first prototype can run without hand-building every part in Studio.

**Tech Stack:** Roblox Studio, Luau, Rojo project format, DataStoreService, RemoteFunction, RemoteEvent, Node.js smoke checks.

---

## Scope Check

The approved spec covers one first playable game loop, not multiple independent subsystems. This can stay as one implementation plan because each task builds toward a single testable Roblox prototype.

## File Structure

- Create `default.project.json`: Rojo service mapping for `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayer.StarterPlayerScripts.Client`.
- Create `scripts/smoke-check.mjs`: local Node check for the Rojo scaffold.
- Create `scripts/check-aura-definitions.mjs`: local Node check for starter aura data.
- Create `scripts/check-server-foundation.mjs`: local Node check for profile and remote modules.
- Create `scripts/check-roll-and-visuals.mjs`: local Node check for roll and visual modules.
- Create `scripts/check-world-and-loop.mjs`: local Node check for world, stillness, and server bootstrap modules.
- Create `scripts/check-client-ui.mjs`: local Node check for the client HUD.
- Create `scripts/check-docs.mjs`: local Node check for setup and playtest docs.
- Create `src/shared/AuraDefinitions.luau`: shared aura data, roll cost, point tuning, and weighted roll helper.
- Create `src/server/ProfileStore.luau`: server profile loading/saving and owned aura helpers.
- Create `src/server/RemoteBuilder.luau`: server creation of remotes used by client UI.
- Create `src/server/RollService.luau`: server-side roll validation and weighted aura awarding.
- Create `src/server/AuraVisualService.luau`: server-side character aura effect creation.
- Create `src/server/WorldBuilder.luau`: server-side creation of Sunset Dream Island starter scene.
- Create `src/server/StillnessService.luau`: server-side point earning loop for players standing still in the aura zone.
- Create `src/server/init.server.luau`: server bootstrap tying profiles, world, remotes, rolling, saving, and visuals together.
- Create `src/client/AuraHud.client.luau`: client UI for points, current aura, roll button, and result messages.
- Create `docs/studio-setup.md`: beginner steps for opening/syncing in Roblox Studio.
- Create `docs/playtest-checklist.md`: manual Studio test checklist mapped to the approved spec.
- Modify `README.md`: add local verification and Studio workflow.

## Verification Strategy

Local verification uses Node.js smoke checks because this machine currently has Node available but not Rojo, Rokit, Lune, or a local Luau runtime. Roblox behavior will be verified in Studio with the playtest checklist after files are created. Rojo installation/sync instructions are documented rather than assumed.

---

### Task 1: Rojo Project Scaffold

**Files:**
- Create: `scripts/smoke-check.mjs`
- Create: `default.project.json`
- Create directories: `src/shared`, `src/server`, `src/client`

- [ ] **Step 1: Write the failing scaffold check**

Create `scripts/smoke-check.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();

function assert(condition, message) {
  if (!condition) {
    console.error(`FAIL: ${message}`);
    process.exitCode = 1;
  }
}

function readJson(filePath) {
  try {
    return JSON.parse(readFileSync(filePath, "utf8"));
  } catch (error) {
    console.error(`FAIL: Could not parse ${filePath}: ${error.message}`);
    process.exitCode = 1;
    return null;
  }
}

const requiredPaths = [
  "default.project.json",
  "src/shared",
  "src/server",
  "src/client",
];

for (const relativePath of requiredPaths) {
  assert(existsSync(path.join(root, relativePath)), `${relativePath} should exist`);
}

const projectPath = path.join(root, "default.project.json");
if (existsSync(projectPath)) {
  const project = readJson(projectPath);
  if (project) {
    assert(project.name === "Aura Hangout", "project name should be Aura Hangout");
    assert(project.tree?.$className === "DataModel", "project root should be a DataModel");
    assert(Boolean(project.tree?.ReplicatedStorage?.Shared?.$path), "ReplicatedStorage.Shared should map to src/shared");
    assert(Boolean(project.tree?.ServerScriptService?.Server?.$path), "ServerScriptService.Server should map to src/server");
    assert(
      Boolean(project.tree?.StarterPlayer?.StarterPlayerScripts?.Client?.$path),
      "StarterPlayerScripts.Client should map to src/client"
    );
  }
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

console.log("PASS: Rojo scaffold is present");
```

- [ ] **Step 2: Run the scaffold check to verify it fails**

Run:

```powershell
node scripts/smoke-check.mjs
```

Expected: FAIL messages for missing `default.project.json`, `src/shared`, `src/server`, and `src/client`.

- [ ] **Step 3: Create the Rojo project file and source folders**

Create directories:

```powershell
New-Item -ItemType Directory -Force -Path src/shared, src/server, src/client | Out-Null
```

Create `default.project.json`:

```json
{
  "name": "Aura Hangout",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/shared"
      }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Server": {
        "$path": "src/server"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Client": {
          "$path": "src/client"
        }
      }
    }
  }
}
```

- [ ] **Step 4: Run the scaffold check to verify it passes**

Run:

```powershell
node scripts/smoke-check.mjs
```

Expected: `PASS: Rojo scaffold is present`

- [ ] **Step 5: Commit the scaffold**

Run:

```powershell
git add default.project.json scripts/smoke-check.mjs src
git commit -m "Add Rojo project scaffold"
```

---

### Task 2: Shared Aura Definitions

**Files:**
- Create: `scripts/check-aura-definitions.mjs`
- Create: `src/shared/AuraDefinitions.luau`

- [ ] **Step 1: Write the failing aura definition check**

Create `scripts/check-aura-definitions.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const filePath = "src/shared/AuraDefinitions.luau";

function fail(message) {
  console.error(`FAIL: ${message}`);
  process.exitCode = 1;
}

if (!existsSync(filePath)) {
  fail(`${filePath} should exist`);
  process.exit(process.exitCode);
}

const source = readFileSync(filePath, "utf8");
const auraIds = [...source.matchAll(/id = "([^"]+)"/g)].map((match) => match[1]);
const requiredAuraIds = [
  "sunrise",
  "seafoam",
  "golden_dust",
  "rose_spark",
  "azure_breeze",
  "solar_ring",
  "rainbow_drift",
  "celestial_glow",
  "sunset_crown",
];

for (const auraId of requiredAuraIds) {
  if (!auraIds.includes(auraId)) {
    fail(`missing aura id ${auraId}`);
  }
}

const requiredSnippets = [
  "AuraDefinitions.RollCost = 25",
  "AuraDefinitions.EarnTickSeconds = 2",
  "AuraDefinitions.PointsPerStillTick = 5",
  "AuraDefinitions.MovementThreshold = 0.75",
  "AuraDefinitions.RollCooldownSeconds = 1.5",
  "function AuraDefinitions.getAuraById",
  "function AuraDefinitions.getTotalWeight",
  "function AuraDefinitions.roll",
];

for (const snippet of requiredSnippets) {
  if (!source.includes(snippet)) {
    fail(`missing snippet: ${snippet}`);
  }
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

console.log("PASS: aura definitions are complete");
```

- [ ] **Step 2: Run the aura definition check to verify it fails**

Run:

```powershell
node scripts/check-aura-definitions.mjs
```

Expected: FAIL because `src/shared/AuraDefinitions.luau` does not exist yet.

- [ ] **Step 3: Add shared aura definitions**

Create `src/shared/AuraDefinitions.luau`:

```lua
local AuraDefinitions = {}

AuraDefinitions.RollCost = 25
AuraDefinitions.EarnTickSeconds = 2
AuraDefinitions.PointsPerStillTick = 5
AuraDefinitions.MovementThreshold = 0.75
AuraDefinitions.RollCooldownSeconds = 1.5
AuraDefinitions.ZoneName = "AuraZone"
AuraDefinitions.DefaultAuraId = "sunrise"

AuraDefinitions.Auras = {
	{
		id = "sunrise",
		name = "Sunrise",
		rarity = "Common",
		weight = 280,
		color = Color3.fromRGB(255, 190, 92),
		secondaryColor = Color3.fromRGB(255, 242, 176),
		lightBrightness = 1.2,
		particleRate = 10,
	},
	{
		id = "seafoam",
		name = "Seafoam",
		rarity = "Common",
		weight = 250,
		color = Color3.fromRGB(91, 226, 196),
		secondaryColor = Color3.fromRGB(185, 255, 239),
		lightBrightness = 1.1,
		particleRate = 10,
	},
	{
		id = "golden_dust",
		name = "Golden Dust",
		rarity = "Common",
		weight = 220,
		color = Color3.fromRGB(255, 222, 89),
		secondaryColor = Color3.fromRGB(255, 248, 190),
		lightBrightness = 1.15,
		particleRate = 12,
	},
	{
		id = "rose_spark",
		name = "Rose Spark",
		rarity = "Uncommon",
		weight = 120,
		color = Color3.fromRGB(255, 105, 180),
		secondaryColor = Color3.fromRGB(255, 204, 232),
		lightBrightness = 1.35,
		particleRate = 14,
	},
	{
		id = "azure_breeze",
		name = "Azure Breeze",
		rarity = "Uncommon",
		weight = 90,
		color = Color3.fromRGB(80, 166, 255),
		secondaryColor = Color3.fromRGB(195, 225, 255),
		lightBrightness = 1.35,
		particleRate = 14,
	},
	{
		id = "solar_ring",
		name = "Solar Ring",
		rarity = "Rare",
		weight = 28,
		color = Color3.fromRGB(255, 132, 56),
		secondaryColor = Color3.fromRGB(255, 238, 120),
		lightBrightness = 1.8,
		particleRate = 18,
	},
	{
		id = "rainbow_drift",
		name = "Rainbow Drift",
		rarity = "Rare",
		weight = 10,
		color = Color3.fromRGB(170, 110, 255),
		secondaryColor = Color3.fromRGB(100, 255, 214),
		lightBrightness = 2,
		particleRate = 20,
	},
	{
		id = "celestial_glow",
		name = "Celestial Glow",
		rarity = "Epic",
		weight = 2,
		color = Color3.fromRGB(138, 91, 255),
		secondaryColor = Color3.fromRGB(255, 255, 255),
		lightBrightness = 2.4,
		particleRate = 26,
	},
	{
		id = "sunset_crown",
		name = "Sunset Crown",
		rarity = "Legendary",
		weight = 1,
		color = Color3.fromRGB(255, 82, 82),
		secondaryColor = Color3.fromRGB(255, 226, 94),
		lightBrightness = 3,
		particleRate = 34,
	},
}

function AuraDefinitions.getAuraById(auraId)
	for _, aura in AuraDefinitions.Auras do
		if aura.id == auraId then
			return aura
		end
	end

	return nil
end

function AuraDefinitions.getTotalWeight()
	local totalWeight = 0

	for _, aura in AuraDefinitions.Auras do
		totalWeight += aura.weight
	end

	return totalWeight
end

function AuraDefinitions.roll(rng)
	local random = rng or Random.new()
	local totalWeight = AuraDefinitions.getTotalWeight()
	local ticket = random:NextInteger(1, totalWeight)
	local runningWeight = 0

	for _, aura in AuraDefinitions.Auras do
		runningWeight += aura.weight
		if ticket <= runningWeight then
			return aura
		end
	end

	return AuraDefinitions.Auras[1]
end

return AuraDefinitions
```

- [ ] **Step 4: Run the aura definition check to verify it passes**

Run:

```powershell
node scripts/check-aura-definitions.mjs
```

Expected: `PASS: aura definitions are complete`

- [ ] **Step 5: Commit shared aura definitions**

Run:

```powershell
git add scripts/check-aura-definitions.mjs src/shared/AuraDefinitions.luau
git commit -m "Add shared aura definitions"
```

---

### Task 3: Server Profiles And Remotes

**Files:**
- Create: `scripts/check-server-foundation.mjs`
- Create: `src/server/ProfileStore.luau`
- Create: `src/server/RemoteBuilder.luau`

- [ ] **Step 1: Write the failing server foundation check**

Create `scripts/check-server-foundation.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/ProfileStore.luau",
    snippets: [
      "DataStoreService:GetDataStore",
      "function ProfileStore.load",
      "function ProfileStore.save",
      "function ProfileStore.markOwned",
      "ownedAuras",
      "equippedAura",
    ],
  },
  {
    file: "src/server/RemoteBuilder.luau",
    snippets: [
      "AuraHangoutRemotes",
      "RollAura",
      "ProfileUpdated",
      "RemoteFunction",
      "RemoteEvent",
      "function RemoteBuilder.build",
    ],
  },
];

let failed = false;

for (const check of checks) {
  if (!existsSync(check.file)) {
    console.error(`FAIL: ${check.file} should exist`);
    failed = true;
    continue;
  }

  const source = readFileSync(check.file, "utf8");
  for (const snippet of check.snippets) {
    if (!source.includes(snippet)) {
      console.error(`FAIL: ${check.file} missing snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: server profile and remote foundation is complete");
```

- [ ] **Step 2: Run the server foundation check to verify it fails**

Run:

```powershell
node scripts/check-server-foundation.mjs
```

Expected: FAIL because `ProfileStore.luau` and `RemoteBuilder.luau` do not exist yet.

- [ ] **Step 3: Add profile storage module**

Create `src/server/ProfileStore.luau`:

```lua
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local AuraDefinitions = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local ProfileStore = {}

local STORE_NAME = "AuraHangoutPlayerProfilesV1"
local playerStore = DataStoreService:GetDataStore(STORE_NAME)

local function cloneDefaultProfile()
	return {
		points = 0,
		ownedAuras = {
			[AuraDefinitions.DefaultAuraId] = true,
		},
		equippedAura = AuraDefinitions.DefaultAuraId,
	}
end

local function normalizeProfile(rawProfile)
	local profile = cloneDefaultProfile()

	if typeof(rawProfile) ~= "table" then
		return profile
	end

	if typeof(rawProfile.points) == "number" and rawProfile.points >= 0 then
		profile.points = math.floor(rawProfile.points)
	end

	if typeof(rawProfile.ownedAuras) == "table" then
		for auraId, isOwned in rawProfile.ownedAuras do
			if typeof(auraId) == "string" and isOwned == true and AuraDefinitions.getAuraById(auraId) then
				profile.ownedAuras[auraId] = true
			end
		end
	end

	if typeof(rawProfile.equippedAura) == "string" and profile.ownedAuras[rawProfile.equippedAura] then
		profile.equippedAura = rawProfile.equippedAura
	end

	return profile
end

local function profileKey(player)
	return `player_{player.UserId}`
end

function ProfileStore.load(player)
	if RunService:IsStudio() then
		local success, data = pcall(function()
			return playerStore:GetAsync(profileKey(player))
		end)

		if success then
			return normalizeProfile(data), nil
		end

		warn(`Aura Hangout profile load failed in Studio for {player.Name}: {data}`)
		return cloneDefaultProfile(), data
	end

	local success, data = pcall(function()
		return playerStore:GetAsync(profileKey(player))
	end)

	if success then
		return normalizeProfile(data), nil
	end

	warn(`Aura Hangout profile load failed for {player.Name}: {data}`)
	return cloneDefaultProfile(), data
end

function ProfileStore.save(player, profile)
	if typeof(profile) ~= "table" then
		return false, "profile missing"
	end

	local saveProfile = normalizeProfile(profile)
	local success, errorMessage = pcall(function()
		playerStore:SetAsync(profileKey(player), saveProfile)
	end)

	if not success then
		warn(`Aura Hangout profile save failed for {player.Name}: {errorMessage}`)
	end

	return success, errorMessage
end

function ProfileStore.markOwned(profile, auraId)
	if typeof(profile) ~= "table" then
		return false
	end

	if not AuraDefinitions.getAuraById(auraId) then
		return false
	end

	profile.ownedAuras[auraId] = true
	return true
end

return ProfileStore
```

- [ ] **Step 4: Add remote builder module**

Create `src/server/RemoteBuilder.luau`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteBuilder = {}

local REMOTE_FOLDER_NAME = "AuraHangoutRemotes"

local function getOrCreate(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

function RemoteBuilder.build()
	local folder = getOrCreate(ReplicatedStorage, "Folder", REMOTE_FOLDER_NAME)
	local rollAura = getOrCreate(folder, "RemoteFunction", "RollAura")
	local profileUpdated = getOrCreate(folder, "RemoteEvent", "ProfileUpdated")

	return {
		folder = folder,
		rollAura = rollAura,
		profileUpdated = profileUpdated,
	}
end

return RemoteBuilder
```

- [ ] **Step 5: Run the server foundation check to verify it passes**

Run:

```powershell
node scripts/check-server-foundation.mjs
```

Expected: `PASS: server profile and remote foundation is complete`

- [ ] **Step 6: Commit profiles and remotes**

Run:

```powershell
git add scripts/check-server-foundation.mjs src/server/ProfileStore.luau src/server/RemoteBuilder.luau
git commit -m "Add server profiles and remotes"
```

---

### Task 4: Roll Service And Aura Visuals

**Files:**
- Create: `scripts/check-roll-and-visuals.mjs`
- Create: `src/server/RollService.luau`
- Create: `src/server/AuraVisualService.luau`

- [ ] **Step 1: Write the failing roll and visuals check**

Create `scripts/check-roll-and-visuals.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/RollService.luau",
    snippets: [
      "function RollService.new",
      "function service:roll",
      "AuraDefinitions.RollCost",
      "AuraDefinitions.RollCooldownSeconds",
      "AuraDefinitions.roll",
      "ProfileStore.markOwned",
      "not_enough_points",
    ],
  },
  {
    file: "src/server/AuraVisualService.luau",
    snippets: [
      "function AuraVisualService.applyAura",
      "function AuraVisualService.clearAura",
      "ParticleEmitter",
      "PointLight",
      "AuraHangoutAura",
    ],
  },
];

let failed = false;

for (const check of checks) {
  if (!existsSync(check.file)) {
    console.error(`FAIL: ${check.file} should exist`);
    failed = true;
    continue;
  }

  const source = readFileSync(check.file, "utf8");
  for (const snippet of check.snippets) {
    if (!source.includes(snippet)) {
      console.error(`FAIL: ${check.file} missing snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: roll service and aura visuals are complete");
```

- [ ] **Step 2: Run the roll and visuals check to verify it fails**

Run:

```powershell
node scripts/check-roll-and-visuals.mjs
```

Expected: FAIL because `RollService.luau` and `AuraVisualService.luau` do not exist yet.

- [ ] **Step 3: Add roll service**

Create `src/server/RollService.luau`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local RollService = {}

function RollService.new(profilesByPlayer)
	local service = {
		profilesByPlayer = profilesByPlayer,
		lastRollByUserId = {},
		rng = Random.new(),
	}

	function service:roll(player)
		local profile = self.profilesByPlayer[player]
		if not profile then
			return {
				ok = false,
				reason = "profile_not_ready",
				message = "Profile loading, try again.",
			}
		end

		local now = os.clock()
		local lastRoll = self.lastRollByUserId[player.UserId] or 0
		if now - lastRoll < AuraDefinitions.RollCooldownSeconds then
			return {
				ok = false,
				reason = "roll_cooldown",
				message = "Rolling too fast.",
			}
		end

		if profile.points < AuraDefinitions.RollCost then
			return {
				ok = false,
				reason = "not_enough_points",
				message = "Not enough points.",
				points = profile.points,
				rollCost = AuraDefinitions.RollCost,
			}
		end

		self.lastRollByUserId[player.UserId] = now
		profile.points -= AuraDefinitions.RollCost

		local aura = AuraDefinitions.roll(self.rng)
		ProfileStore.markOwned(profile, aura.id)
		profile.equippedAura = aura.id

		return {
			ok = true,
			auraId = aura.id,
			auraName = aura.name,
			rarity = aura.rarity,
			points = profile.points,
			rollCost = AuraDefinitions.RollCost,
			message = `Rolled {aura.name}!`,
		}
	end

	return service
end

return RollService
```

- [ ] **Step 4: Add aura visual service**

Create `src/server/AuraVisualService.luau`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local AuraVisualService = {}

local AURA_FOLDER_NAME = "AuraHangoutAura"

local function getRootPart(character)
	return character:FindFirstChild("HumanoidRootPart")
end

function AuraVisualService.clearAura(character)
	for _, descendant in character:GetDescendants() do
		if descendant:GetAttribute(AURA_FOLDER_NAME) == true then
			descendant:Destroy()
		end
	end
end

function AuraVisualService.applyAura(character, auraId)
	local aura = AuraDefinitions.getAuraById(auraId)
	if not aura then
		return false
	end

	local rootPart = getRootPart(character)
	if not rootPart then
		return false
	end

	AuraVisualService.clearAura(character)

	local attachment = Instance.new("Attachment")
	attachment.Name = AURA_FOLDER_NAME
	attachment:SetAttribute(AURA_FOLDER_NAME, true)
	attachment.Parent = rootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "AuraParticles"
	particle:SetAttribute(AURA_FOLDER_NAME, true)
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, aura.color),
		ColorSequenceKeypoint.new(1, aura.secondaryColor),
	})
	particle.LightEmission = 0.65
	particle.Rate = aura.particleRate
	particle.Lifetime = NumberRange.new(1.2, 1.8)
	particle.Speed = NumberRange.new(0.4, 1.4)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1, 0),
	})
	particle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1),
	})
	particle.Parent = attachment

	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light:SetAttribute(AURA_FOLDER_NAME, true)
	light.Color = aura.color
	light.Brightness = aura.lightBrightness
	light.Range = 8
	light.Parent = attachment

	return true
end

return AuraVisualService
```

- [ ] **Step 5: Run the roll and visuals check to verify it passes**

Run:

```powershell
node scripts/check-roll-and-visuals.mjs
```

Expected: `PASS: roll service and aura visuals are complete`

- [ ] **Step 6: Commit roll service and visuals**

Run:

```powershell
git add scripts/check-roll-and-visuals.mjs src/server/RollService.luau src/server/AuraVisualService.luau
git commit -m "Add aura rolling and visuals"
```

---

### Task 5: World Builder, Stillness Loop, And Server Bootstrap

**Files:**
- Create: `scripts/check-world-and-loop.mjs`
- Create: `src/server/WorldBuilder.luau`
- Create: `src/server/StillnessService.luau`
- Create: `src/server/init.server.luau`

- [ ] **Step 1: Write the failing world and loop check**

Create `scripts/check-world-and-loop.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "src/server/WorldBuilder.luau",
    snippets: [
      "function WorldBuilder.build",
      "AuraZone",
      "SpawnLocation",
      "Lighting.ClockTime",
      "SunsetIsland",
    ],
  },
  {
    file: "src/server/StillnessService.luau",
    snippets: [
      "function StillnessService.new",
      "function service:start",
      "AuraDefinitions.EarnTickSeconds",
      "AuraDefinitions.PointsPerStillTick",
      "AuraDefinitions.MovementThreshold",
      "profile.points +=",
    ],
  },
  {
    file: "src/server/init.server.luau",
    snippets: [
      "Players.PlayerAdded",
      "Players.PlayerRemoving",
      "game:BindToClose",
      "RollAura.OnServerInvoke",
      "ProfileUpdated:FireClient",
      "leaderstats",
    ],
  },
];

let failed = false;

for (const check of checks) {
  if (!existsSync(check.file)) {
    console.error(`FAIL: ${check.file} should exist`);
    failed = true;
    continue;
  }

  const source = readFileSync(check.file, "utf8");
  for (const snippet of check.snippets) {
    if (!source.includes(snippet)) {
      console.error(`FAIL: ${check.file} missing snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: world builder, stillness loop, and server bootstrap are complete");
```

- [ ] **Step 2: Run the world and loop check to verify it fails**

Run:

```powershell
node scripts/check-world-and-loop.mjs
```

Expected: FAIL because `WorldBuilder.luau`, `StillnessService.luau`, and `init.server.luau` do not exist yet.

- [ ] **Step 3: Add world builder**

Create `src/server/WorldBuilder.luau`:

```lua
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local WorldBuilder = {}

local WORLD_FOLDER_NAME = "SunsetIsland"

local function createPart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function WorldBuilder.build()
	local existing = workspace:FindFirstChild(WORLD_FOLDER_NAME)
	if existing then
		existing:Destroy()
	end

	Lighting.ClockTime = 17.8
	Lighting.Brightness = 2.2
	Lighting.EnvironmentDiffuseScale = 0.65
	Lighting.EnvironmentSpecularScale = 0.45
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 190, 140)
	Lighting.FogColor = Color3.fromRGB(255, 178, 128)
	Lighting.FogStart = 120
	Lighting.FogEnd = 520

	local world = Instance.new("Folder")
	world.Name = WORLD_FOLDER_NAME
	world.Parent = workspace

	local island = createPart(
		world,
		"FloatingGrassIsland",
		Vector3.new(96, 8, 96),
		CFrame.new(0, 0, 0),
		Color3.fromRGB(76, 181, 105),
		Enum.Material.Grass
	)
	island.Shape = Enum.PartType.Cylinder

	local soil = createPart(
		world,
		"IslandSoilBase",
		Vector3.new(88, 16, 88),
		CFrame.new(0, -10, 0),
		Color3.fromRGB(120, 88, 59),
		Enum.Material.Ground
	)
	soil.Shape = Enum.PartType.Cylinder

	local zone = createPart(
		world,
		AuraDefinitions.ZoneName,
		Vector3.new(34, 1, 34),
		CFrame.new(0, 4.7, 0),
		Color3.fromRGB(255, 210, 100),
		Enum.Material.Neon
	)
	zone.Shape = Enum.PartType.Cylinder
	zone.Transparency = 0.45
	zone.CanCollide = false

	local zoneLight = Instance.new("PointLight")
	zoneLight.Name = "AuraZoneGlow"
	zoneLight.Color = Color3.fromRGB(255, 197, 87)
	zoneLight.Brightness = 2.5
	zoneLight.Range = 32
	zoneLight.Parent = zone

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 5.5, -28)
	spawn.Color = Color3.fromRGB(255, 231, 156)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = world

	for index, angle in { 0, 72, 144, 216, 288 } do
		local radians = math.rad(angle)
		local x = math.cos(radians) * 34
		local z = math.sin(radians) * 34
		local palm = createPart(
			world,
			`GlowPalm{index}`,
			Vector3.new(3, 12, 3),
			CFrame.new(x, 10, z),
			Color3.fromRGB(124, 88, 52),
			Enum.Material.Wood
		)
		local lamp = Instance.new("PointLight")
		lamp.Color = Color3.fromRGB(255, 179, 93)
		lamp.Brightness = 0.8
		lamp.Range = 14
		lamp.Parent = palm
	end

	return {
		world = world,
		zone = zone,
	}
end

return WorldBuilder
```

- [ ] **Step 4: Add stillness service**

Create `src/server/StillnessService.luau`:

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local StillnessService = {}

local function getRootPart(player)
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function isInsidePart(part, worldPosition)
	local localPosition = part.CFrame:PointToObjectSpace(worldPosition)
	local halfSize = part.Size * 0.5

	return math.abs(localPosition.X) <= halfSize.X
		and math.abs(localPosition.Y) <= halfSize.Y + 5
		and math.abs(localPosition.Z) <= halfSize.Z
end

function StillnessService.new(profilesByPlayer, remotes, zonePart)
	local service = {
		profilesByPlayer = profilesByPlayer,
		remotes = remotes,
		zonePart = zonePart,
		lastPositions = {},
		accumulator = 0,
		connection = nil,
	}

	function service:evaluatePlayer(player)
		local profile = self.profilesByPlayer[player]
		local rootPart = getRootPart(player)

		if not profile or not rootPart or not self.zonePart then
			self.lastPositions[player] = nil
			return
		end

		if not isInsidePart(self.zonePart, rootPart.Position) then
			self.lastPositions[player] = rootPart.Position
			return
		end

		local previousPosition = self.lastPositions[player]
		self.lastPositions[player] = rootPart.Position

		if not previousPosition then
			return
		end

		local movement = (rootPart.Position - previousPosition).Magnitude
		if movement <= AuraDefinitions.MovementThreshold then
			profile.points += AuraDefinitions.PointsPerStillTick
			self.remotes.profileUpdated:FireClient(player, {
				points = profile.points,
				equippedAura = profile.equippedAura,
				rollCost = AuraDefinitions.RollCost,
				message = `+{AuraDefinitions.PointsPerStillTick} Aura Points`,
			})
		end
	end

	function service:start()
		if self.connection then
			return
		end

		self.connection = RunService.Heartbeat:Connect(function(deltaTime)
			self.accumulator += deltaTime
			if self.accumulator < AuraDefinitions.EarnTickSeconds then
				return
			end

			self.accumulator = 0
			for _, player in Players:GetPlayers() do
				self:evaluatePlayer(player)
			end
		end)
	end

	function service:forget(player)
		self.lastPositions[player] = nil
	end

	return service
end

return StillnessService
```

- [ ] **Step 5: Add server bootstrap**

Create `src/server/init.server.luau`:

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedRoot = ReplicatedStorage:WaitForChild("Shared")
local AuraDefinitions = require(sharedRoot:WaitForChild("AuraDefinitions"))

local ProfileStore = require(script:WaitForChild("ProfileStore"))
local RemoteBuilder = require(script:WaitForChild("RemoteBuilder"))
local RollService = require(script:WaitForChild("RollService"))
local AuraVisualService = require(script:WaitForChild("AuraVisualService"))
local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local StillnessService = require(script:WaitForChild("StillnessService"))

local profilesByPlayer = {}
local remotes = RemoteBuilder.build()
local world = WorldBuilder.build()
local rollService = RollService.new(profilesByPlayer)
local stillnessService = StillnessService.new(profilesByPlayer, remotes, world.zone)

local function updateLeaderstats(player, profile)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local points = leaderstats:FindFirstChild("Aura Points")
	if not points then
		points = Instance.new("IntValue")
		points.Name = "Aura Points"
		points.Parent = leaderstats
	end

	points.Value = profile.points
end

local function sendProfile(player, message)
	local profile = profilesByPlayer[player]
	if not profile then
		return
	end

	remotes.profileUpdated:FireClient(player, {
		points = profile.points,
		equippedAura = profile.equippedAura,
		rollCost = AuraDefinitions.RollCost,
		message = message,
	})
end

local function applyEquippedAura(player)
	local profile = profilesByPlayer[player]
	local character = player.Character
	if not profile or not character then
		return
	end

	AuraVisualService.applyAura(character, profile.equippedAura)
end

local function onPlayerAdded(player)
	local profile = ProfileStore.load(player)
	profilesByPlayer[player] = profile
	updateLeaderstats(player, profile)

	player.CharacterAdded:Connect(function()
		task.wait(0.25)
		applyEquippedAura(player)
	end)

	sendProfile(player, "Welcome to Aura Hangout.")
end

local function saveAndForgetPlayer(player)
	local profile = profilesByPlayer[player]
	if profile then
		ProfileStore.save(player, profile)
	end

	profilesByPlayer[player] = nil
	stillnessService:forget(player)
end

remotes.rollAura.OnServerInvoke = function(player)
	local result = rollService:roll(player)
	local profile = profilesByPlayer[player]

	if profile then
		updateLeaderstats(player, profile)
	end

	if result.ok then
		applyEquippedAura(player)
	end

	remotes.profileUpdated:FireClient(player, {
		points = result.points or (profile and profile.points) or 0,
		equippedAura = profile and profile.equippedAura or AuraDefinitions.DefaultAuraId,
		rollCost = AuraDefinitions.RollCost,
		message = result.message,
		lastRoll = result,
	})

	return result
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(saveAndForgetPlayer)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

stillnessService:start()

task.spawn(function()
	while task.wait(60) do
		for player, profile in profilesByPlayer do
			ProfileStore.save(player, profile)
		end
	end
end)

game:BindToClose(function()
	for player, profile in profilesByPlayer do
		ProfileStore.save(player, profile)
	end
end)
```

- [ ] **Step 6: Run the world and loop check to verify it passes**

Run:

```powershell
node scripts/check-world-and-loop.mjs
```

Expected: `PASS: world builder, stillness loop, and server bootstrap are complete`

- [ ] **Step 7: Commit world, stillness, and server bootstrap**

Run:

```powershell
git add scripts/check-world-and-loop.mjs src/server/WorldBuilder.luau src/server/StillnessService.luau src/server/init.server.luau
git commit -m "Add world and stillness game loop"
```

---

### Task 6: Client Roll UI

**Files:**
- Create: `scripts/check-client-ui.mjs`
- Create: `src/client/AuraHud.client.luau`

- [ ] **Step 1: Write the failing client UI check**

Create `scripts/check-client-ui.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const file = "src/client/AuraHud.client.luau";

if (!existsSync(file)) {
  console.error(`FAIL: ${file} should exist`);
  process.exit(1);
}

const source = readFileSync(file, "utf8");
const snippets = [
  "AuraHangoutRemotes",
  "RollAura",
  "ProfileUpdated",
  "RollButton",
  "PointsLabel",
  "CurrentAuraLabel",
  "ResultLabel",
  "rollAura:InvokeServer",
  "profileUpdated.OnClientEvent",
];

let failed = false;
for (const snippet of snippets) {
  if (!source.includes(snippet)) {
    console.error(`FAIL: ${file} missing snippet: ${snippet}`);
    failed = true;
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: client aura HUD is complete");
```

- [ ] **Step 2: Run the client UI check to verify it fails**

Run:

```powershell
node scripts/check-client-ui.mjs
```

Expected: FAIL because `src/client/AuraHud.client.luau` does not exist yet.

- [ ] **Step 3: Add client HUD script**

Create `src/client/AuraHud.client.luau`:

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("AuraHangoutRemotes")
local rollAura = remotes:WaitForChild("RollAura")
local profileUpdated = remotes:WaitForChild("ProfileUpdated")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AuraHangoutHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.fromOffset(20, -20)
panel.Size = UDim2.fromOffset(290, 172)
panel.BackgroundColor3 = Color3.fromRGB(35, 28, 42)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 14)
padding.PaddingBottom = UDim.new(0, 14)
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Aura Hangout"
title.TextColor3 = Color3.fromRGB(255, 226, 165)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, 0, 0, 24)
title.LayoutOrder = 1
title.Parent = panel

local pointsLabel = Instance.new("TextLabel")
pointsLabel.Name = "PointsLabel"
pointsLabel.BackgroundTransparency = 1
pointsLabel.Font = Enum.Font.Gotham
pointsLabel.Text = "Aura Points: 0"
pointsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pointsLabel.TextSize = 16
pointsLabel.TextXAlignment = Enum.TextXAlignment.Left
pointsLabel.Size = UDim2.new(1, 0, 0, 22)
pointsLabel.LayoutOrder = 2
pointsLabel.Parent = panel

local currentAuraLabel = Instance.new("TextLabel")
currentAuraLabel.Name = "CurrentAuraLabel"
currentAuraLabel.BackgroundTransparency = 1
currentAuraLabel.Font = Enum.Font.Gotham
currentAuraLabel.Text = "Current Aura: Sunrise"
currentAuraLabel.TextColor3 = Color3.fromRGB(221, 244, 255)
currentAuraLabel.TextSize = 15
currentAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
currentAuraLabel.Size = UDim2.new(1, 0, 0, 22)
currentAuraLabel.LayoutOrder = 3
currentAuraLabel.Parent = panel

local resultLabel = Instance.new("TextLabel")
resultLabel.Name = "ResultLabel"
resultLabel.BackgroundTransparency = 1
resultLabel.Font = Enum.Font.GothamMedium
resultLabel.Text = "Stand still in the glow zone."
resultLabel.TextColor3 = Color3.fromRGB(255, 225, 130)
resultLabel.TextSize = 14
resultLabel.TextXAlignment = Enum.TextXAlignment.Left
resultLabel.TextWrapped = true
resultLabel.Size = UDim2.new(1, 0, 0, 34)
resultLabel.LayoutOrder = 4
resultLabel.Parent = panel

local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.BackgroundColor3 = Color3.fromRGB(255, 169, 76)
rollButton.BorderSizePixel = 0
rollButton.Font = Enum.Font.GothamBold
rollButton.Text = "Roll Aura (25)"
rollButton.TextColor3 = Color3.fromRGB(35, 24, 18)
rollButton.TextSize = 16
rollButton.Size = UDim2.new(1, 0, 0, 38)
rollButton.LayoutOrder = 5
rollButton.Parent = panel

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = rollButton

local rolling = false

local function updateHud(data)
	if typeof(data) ~= "table" then
		return
	end

	if typeof(data.points) == "number" then
		pointsLabel.Text = `Aura Points: {data.points}`
	end

	if typeof(data.rollCost) == "number" then
		rollButton.Text = `Roll Aura ({data.rollCost})`
	end

	if typeof(data.equippedAura) == "string" then
		currentAuraLabel.Text = `Current Aura: {data.equippedAura}`
	end

	if typeof(data.lastRoll) == "table" and data.lastRoll.ok then
		currentAuraLabel.Text = `Current Aura: {data.lastRoll.auraName}`
		resultLabel.Text = `{data.lastRoll.rarity}: {data.lastRoll.auraName}`
	elseif typeof(data.message) == "string" then
		resultLabel.Text = data.message
	end
end

rollButton.Activated:Connect(function()
	if rolling then
		return
	end

	rolling = true
	rollButton.AutoButtonColor = false
	rollButton.Text = "Rolling..."

	local success, result = pcall(function()
		return rollAura:InvokeServer()
	end)

	if success then
		updateHud(result)
	else
		resultLabel.Text = "Roll failed, try again."
	end

	rolling = false
	rollButton.AutoButtonColor = true
end)

profileUpdated.OnClientEvent:Connect(updateHud)
```

- [ ] **Step 4: Run the client UI check to verify it passes**

Run:

```powershell
node scripts/check-client-ui.mjs
```

Expected: `PASS: client aura HUD is complete`

- [ ] **Step 5: Commit client UI**

Run:

```powershell
git add scripts/check-client-ui.mjs src/client/AuraHud.client.luau
git commit -m "Add aura roll HUD"
```

---

### Task 7: Studio Setup And Playtest Docs

**Files:**
- Create: `scripts/check-docs.mjs`
- Create: `docs/studio-setup.md`
- Create: `docs/playtest-checklist.md`
- Modify: `README.md`

- [ ] **Step 1: Write the failing docs check**

Create `scripts/check-docs.mjs`:

```js
import { existsSync, readFileSync } from "node:fs";

const checks = [
  {
    file: "docs/studio-setup.md",
    snippets: [
      "Roblox Studio",
      "Rojo",
      "default.project.json",
      "AuraZone",
      "Enable Studio Access to API Services",
    ],
  },
  {
    file: "docs/playtest-checklist.md",
    snippets: [
      "One-player test",
      "Two-player test",
      "DataStore save test",
      "stillness bonus",
      "manual roll",
    ],
  },
  {
    file: "README.md",
    snippets: [
      "Local Checks",
      "Studio Setup",
      "node scripts/smoke-check.mjs",
      "docs/playtest-checklist.md",
    ],
  },
];

let failed = false;

for (const check of checks) {
  if (!existsSync(check.file)) {
    console.error(`FAIL: ${check.file} should exist`);
    failed = true;
    continue;
  }

  const source = readFileSync(check.file, "utf8");
  for (const snippet of check.snippets) {
    if (!source.includes(snippet)) {
      console.error(`FAIL: ${check.file} missing snippet: ${snippet}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("PASS: Studio setup and playtest docs are complete");
```

- [ ] **Step 2: Run the docs check to verify it fails**

Run:

```powershell
node scripts/check-docs.mjs
```

Expected: FAIL because `docs/studio-setup.md` and `docs/playtest-checklist.md` do not exist yet, and README is missing workflow sections.

- [ ] **Step 3: Add Studio setup guide**

Create `docs/studio-setup.md`:

````markdown
# Studio Setup

This project is designed for Roblox Studio plus Rojo. Codex edits the Luau files in this repo. Rojo syncs those files into Roblox Studio.

## Install Rojo

Follow the official Rojo installation guide:

https://rojo.space/docs/v7/getting-started/installation/

Install both:

- Rojo command line tool
- Rojo Roblox Studio plugin

## Start The Rojo Server

From this project folder, run:

```powershell
rojo serve default.project.json
```

Keep that terminal open while working in Roblox Studio.

## Connect Roblox Studio

1. Open Roblox Studio.
2. Create a new Baseplate place.
3. Open the Rojo plugin.
4. Connect the plugin to the running Rojo server.
5. Confirm these folders/scripts appear:
   - `ReplicatedStorage.Shared.AuraDefinitions`
   - `ServerScriptService.Server`
   - `StarterPlayer.StarterPlayerScripts.Client.AuraHud`

## Enable DataStore Testing

Saving uses Roblox DataStores. In Studio:

1. Open Game Settings.
2. Open Security.
3. Enable Studio Access to API Services.
4. Publish the place once before relying on DataStore saves.

If DataStore loading fails during early testing, the server uses a safe default profile for that session.

## Expected World Objects

When the game starts, `WorldBuilder` creates:

- `Workspace.SunsetIsland`
- `Workspace.SunsetIsland.FloatingGrassIsland`
- `Workspace.SunsetIsland.AuraZone`
- `Workspace.SunsetIsland.SpawnLocation`

The important object for point earning is `AuraZone`.
````

- [ ] **Step 4: Add playtest checklist**

Create `docs/playtest-checklist.md`:

```markdown
# Playtest Checklist

Use Roblox Studio Play mode after syncing with Rojo.

## One-player test

- [ ] Player spawns on Sunset Dream Island.
- [ ] HUD appears with Aura Points, current aura, message, and Roll button.
- [ ] `AuraZone` is visible as a glowing circle.
- [ ] Standing inside the aura zone increases points by the stillness bonus.
- [ ] Moving inside the aura zone pauses or slows point gain.
- [ ] Leaving the aura zone stops point gain.
- [ ] Pressing the manual roll button with fewer than 25 points shows "Not enough points."
- [ ] Pressing the manual roll button with at least 25 points subtracts 25 points.
- [ ] Successful roll shows an aura name and rarity.
- [ ] Successful roll equips a visible aura effect on the character.

## Two-player test

- [ ] Both players have separate Aura Points.
- [ ] Each player can roll independently.
- [ ] One player's aura does not overwrite the other player's aura.
- [ ] Auras are visible to the other player.

## DataStore save test

- [ ] Enable Studio Access to API Services.
- [ ] Publish the place once.
- [ ] Earn points and roll an aura.
- [ ] Stop the session.
- [ ] Start a new session with the same test account.
- [ ] Confirm saved points and equipped aura restore.

## Rarity feel test

- [ ] Roll at least 50 times in a test session with temporary extra points.
- [ ] Common auras appear often.
- [ ] Uncommon auras appear sometimes.
- [ ] Rare, Epic, and Legendary auras feel noticeably harder to get.
```

- [ ] **Step 5: Update README with verification and Studio links**

Replace `README.md` with:

````markdown
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
````

- [ ] **Step 6: Run all local checks**

Run:

```powershell
node scripts/smoke-check.mjs
node scripts/check-aura-definitions.mjs
node scripts/check-server-foundation.mjs
node scripts/check-roll-and-visuals.mjs
node scripts/check-world-and-loop.mjs
node scripts/check-client-ui.mjs
node scripts/check-docs.mjs
```

Expected:

```text
PASS: Rojo scaffold is present
PASS: aura definitions are complete
PASS: server profile and remote foundation is complete
PASS: roll service and aura visuals are complete
PASS: world builder, stillness loop, and server bootstrap are complete
PASS: client aura HUD is complete
PASS: Studio setup and playtest docs are complete
```

- [ ] **Step 7: Commit docs and README updates**

Run:

```powershell
git add README.md docs/studio-setup.md docs/playtest-checklist.md scripts/check-docs.mjs
git commit -m "Add Studio setup and playtest docs"
```

---

### Task 8: Final Local Verification And GitHub Push

**Files:**
- Modify only if previous checks reveal a concrete issue.

- [ ] **Step 1: Run full git status**

Run:

```powershell
git status --short
```

Expected: no uncommitted files.

- [ ] **Step 2: Run all local checks again**

Run:

```powershell
node scripts/smoke-check.mjs
node scripts/check-aura-definitions.mjs
node scripts/check-server-foundation.mjs
node scripts/check-roll-and-visuals.mjs
node scripts/check-world-and-loop.mjs
node scripts/check-client-ui.mjs
node scripts/check-docs.mjs
```

Expected:

```text
PASS: Rojo scaffold is present
PASS: aura definitions are complete
PASS: server profile and remote foundation is complete
PASS: roll service and aura visuals are complete
PASS: world builder, stillness loop, and server bootstrap are complete
PASS: client aura HUD is complete
PASS: Studio setup and playtest docs are complete
```

- [ ] **Step 3: Push the implementation branch**

Run:

```powershell
git push origin main
```

Expected: push succeeds to `https://github.com/kiiing025/aura-hangout.git`.

- [ ] **Step 4: Hand off Studio playtesting**

Run no command. Tell the user:

```text
Implementation files are pushed. Next, open Roblox Studio, connect Rojo, and run through docs/playtest-checklist.md.
```
