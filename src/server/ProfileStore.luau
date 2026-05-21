local DataStoreService = game:GetService("DataStoreService")

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
