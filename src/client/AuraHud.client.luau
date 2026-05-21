local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local sharedRoot = ReplicatedStorage:WaitForChild("Shared")
local AuraDefinitions = require(sharedRoot:WaitForChild("AuraDefinitions"))
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
panel.Position = UDim2.new(0, 20, 1, -20)
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

local function getAuraName(auraId)
	local aura = AuraDefinitions.getAuraById(auraId)
	return aura and aura.name or auraId
end

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
		currentAuraLabel.Text = `Current Aura: {getAuraName(data.equippedAura)}`
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
