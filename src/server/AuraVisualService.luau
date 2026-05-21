local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AuraDefinitions"))

local AuraVisualService = {}

local AURA_MARKER = "AuraHangoutAura"

local function getRootPart(character)
	return character:FindFirstChild("HumanoidRootPart")
end

function AuraVisualService.clearAura(character)
	for _, descendant in character:GetDescendants() do
		if descendant:GetAttribute(AURA_MARKER) == true then
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
	attachment.Name = AURA_MARKER
	attachment:SetAttribute(AURA_MARKER, true)
	attachment.Parent = rootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "AuraParticles"
	particle:SetAttribute(AURA_MARKER, true)
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
	light:SetAttribute(AURA_MARKER, true)
	light.Color = aura.color
	light.Brightness = aura.lightBrightness
	light.Range = 8
	light.Parent = attachment

	return true
end

return AuraVisualService
