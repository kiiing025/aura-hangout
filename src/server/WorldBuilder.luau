local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local WorldBuilder = {}

local WORLD_FOLDER_NAME = "SunsetIsland"

local function configureLighting()
	Lighting.ClockTime = 17.8
	Lighting.Brightness = 2.2
	Lighting.EnvironmentDiffuseScale = 0.65
	Lighting.EnvironmentSpecularScale = 0.45
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 190, 140)
	Lighting.FogColor = Color3.fromRGB(255, 178, 128)
	Lighting.FogStart = 120
	Lighting.FogEnd = 520
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

	local flatCylinderCFrame = CFrame.Angles(0, 0, math.rad(90))
	local island = createPart(
		world,
		"FloatingGrassIsland",
		Vector3.new(8, 96, 96),
		CFrame.new(0, 0, 0) * flatCylinderCFrame,
		Color3.fromRGB(76, 181, 105),
		Enum.Material.Grass
	)
	island.Shape = Enum.PartType.Cylinder

	local soil = createPart(
		world,
		"IslandSoilBase",
		Vector3.new(16, 88, 88),
		CFrame.new(0, -10, 0) * flatCylinderCFrame,
		Color3.fromRGB(120, 88, 59),
		Enum.Material.Ground
	)
	soil.Shape = Enum.PartType.Cylinder

	local zone = createPart(
		world,
		AuraDefinitions.ZoneName,
		Vector3.new(1, 34, 34),
		CFrame.new(0, 4.7, 0) * flatCylinderCFrame,
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

	for index, angle in ipairs({ 0, 72, 144, 216, 288 }) do
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
