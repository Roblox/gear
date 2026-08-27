local SLED_ID = 99259472
local SPAWN_OFFSET = CFrame.new(0, 0, -3)

local InsertService = game:GetService('InsertService')

local Tool = script.Parent

local Sled = nil
local Torso = nil

local function OnEquipped()
	local character = Tool.Parent
	Torso = character:FindFirstChild('Torso') or character:FindFirstChild("UpperTorso")
end

local function OnActivated()
	if Sled and Tool.Enabled then
		Tool.Enabled = false

		Sled.CFrame = Torso.CFrame * SPAWN_OFFSET
		Sled.Parent = workspace

		Tool:Destroy()
	end
end

Sled = InsertService:LoadAsset(SLED_ID):GetChildren()[1]

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
