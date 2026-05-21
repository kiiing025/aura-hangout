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
