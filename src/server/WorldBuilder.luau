local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local WorldBuilder = {}

local WORLD_FOLDER_NAME = "SunsetIsland"

local function configureLighting()
	Lighting.ClockTime = 17.8
	Lighting.Brightness = 2.2
	Lighting.EnvironmentDiffuseScale = 0.75
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 190, 140)
	Lighting.FogColor = Color3.fromRGB(255, 178, 128)
	Lighting.FogStart = 150
	Lighting.FogEnd = 560
end

local function getExistingWorld(existing)
	return {
		world = existing,
		zone = existing:FindFirstChild(AuraDefinitions.ZoneName, true),
	}
end

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

local function createLamp(parent, name, position)
	local post = createPart(
		parent,
		name,
		Vector3.new(1.2, 8, 1.2),
		CFrame.new(position),
		Color3.fromRGB(92, 66, 51),
		Enum.Material.Wood
	)

	local glow = createPart(
		parent,
		name .. "Glow",
		Vector3.new(3.2, 3.2, 3.2),
		CFrame.new(position + Vector3.new(0, 5.2, 0)),
		Color3.fromRGB(255, 197, 87),
		Enum.Material.Neon
	)
	glow.Shape = Enum.PartType.Ball
	glow.CanCollide = false

	local light = Instance.new("PointLight")
	light.Name = "WarmLight"
	light.Color = Color3.fromRGB(255, 184, 102)
	light.Brightness = 1.8
	light.Range = 24
	light.Parent = glow

	return post
end

local function createBench(parent, name, position, rotationY)
	local rotation = CFrame.Angles(0, math.rad(rotationY), 0)
	createPart(
		parent,
		name .. "Seat",
		Vector3.new(14, 1, 3),
		CFrame.new(position) * rotation,
		Color3.fromRGB(128, 88, 58),
		Enum.Material.Wood
	)
	createPart(
		parent,
		name .. "Back",
		Vector3.new(14, 4, 1),
		CFrame.new(position + Vector3.new(0, 2.1, 1.9)) * rotation,
		Color3.fromRGB(104, 70, 48),
		Enum.Material.Wood
	)
	createPart(
		parent,
		name .. "LeftLeg",
		Vector3.new(1, 2.2, 1),
		CFrame.new(position + Vector3.new(-5, -1.5, 0)) * rotation,
		Color3.fromRGB(76, 54, 44),
		Enum.Material.Wood
	)
	createPart(
		parent,
		name .. "RightLeg",
		Vector3.new(1, 2.2, 1),
		CFrame.new(position + Vector3.new(5, -1.5, 0)) * rotation,
		Color3.fromRGB(76, 54, 44),
		Enum.Material.Wood
	)
end

function WorldBuilder.build()
	configureLighting()

	local existing = workspace:FindFirstChild(WORLD_FOLDER_NAME)
	if existing and existing:FindFirstChild(AuraDefinitions.ZoneName, true) then
		return getExistingWorld(existing)
	elseif existing then
		existing:Destroy()
	end

	local world = Instance.new("Folder")
	world.Name = WORLD_FOLDER_NAME
	world.Parent = workspace

	createPart(
		world,
		"IslandSoilFoundation",
		Vector3.new(118, 10, 118),
		CFrame.new(0, -6, 0),
		Color3.fromRGB(116, 82, 55),
		Enum.Material.Ground
	)

	createPart(
		world,
		"MainGrassPlaza",
		Vector3.new(112, 4, 112),
		CFrame.new(0, 1, 0),
		Color3.fromRGB(75, 176, 103),
		Enum.Material.Grass
	)

	local zone = createPart(
		world,
		AuraDefinitions.ZoneName,
		Vector3.new(38, 0.35, 38),
		CFrame.new(0, 3.3, 0),
		Color3.fromRGB(79, 241, 204),
		Enum.Material.Neon
	)
	zone.Transparency = 0.25
	zone.CanCollide = false

	local zoneLight = Instance.new("PointLight")
	zoneLight.Name = "AuraZoneGlow"
	zoneLight.Color = Color3.fromRGB(79, 241, 204)
	zoneLight.Brightness = 3.2
	zoneLight.Range = 42
	zoneLight.Parent = zone

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 4, -42)
	spawn.Color = Color3.fromRGB(255, 231, 156)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = world

	createPart(world, "LowWallNorth", Vector3.new(76, 4, 2), CFrame.new(0, 4, -55), Color3.fromRGB(255, 214, 130), Enum.Material.SmoothPlastic)
	createPart(world, "LowWallSouth", Vector3.new(76, 4, 2), CFrame.new(0, 4, 55), Color3.fromRGB(255, 214, 130), Enum.Material.SmoothPlastic)
	createPart(world, "LowWallWest", Vector3.new(2, 4, 76), CFrame.new(-55, 4, 0), Color3.fromRGB(255, 214, 130), Enum.Material.SmoothPlastic)
	createPart(world, "LowWallEast", Vector3.new(2, 4, 76), CFrame.new(55, 4, 0), Color3.fromRGB(255, 214, 130), Enum.Material.SmoothPlastic)

	createLamp(world, "GlowLamp1", Vector3.new(-38, 5, -38))
	createLamp(world, "GlowLamp2", Vector3.new(38, 5, -38))
	createLamp(world, "GlowLamp3", Vector3.new(-38, 5, 38))
	createLamp(world, "GlowLamp4", Vector3.new(38, 5, 38))

	createBench(world, "CozyBench1", Vector3.new(-28, 5, 18), 35)
	createBench(world, "CozyBench2", Vector3.new(28, 5, 18), -35)
	createBench(world, "CozyBench3", Vector3.new(0, 5, 34), 180)

	return {
		world = world,
		zone = zone,
	}
end

return WorldBuilder
