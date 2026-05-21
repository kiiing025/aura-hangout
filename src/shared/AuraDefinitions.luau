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
