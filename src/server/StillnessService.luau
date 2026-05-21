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

local function updateLeaderstat(player, points)
	local leaderstats = player:FindFirstChild("leaderstats")
	local pointsValue = leaderstats and leaderstats:FindFirstChild("Aura Points")
	if pointsValue then
		pointsValue.Value = points
	end
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
			updateLeaderstat(player, profile.points)
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
