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
local RollAura = remotes.rollAura
local ProfileUpdated = remotes.profileUpdated
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

	ProfileUpdated:FireClient(player, {
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

RollAura.OnServerInvoke = function(player)
	local result = rollService:roll(player)
	local profile = profilesByPlayer[player]

	if profile then
		updateLeaderstats(player, profile)
	end

	if result.ok then
		applyEquippedAura(player)
	end

	ProfileUpdated:FireClient(player, {
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
