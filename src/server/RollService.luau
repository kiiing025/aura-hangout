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
