local SLED_ID = 143604477
local SPAWN_OFFSET = CFrame.new(0, 0, 3)

local InsertService = Game:GetService('InsertService')

local Tool = script.Parent

local Torso = nil
local SledModel = nil

local function OnEquipped()
	local character = Tool.Parent
	Torso = character:WaitForChild('Torso')
end

local function OnActivated()
	local sledPart = SledModel and SledModel:FindFirstChild('Sled')
	if sledPart and Tool.Enabled then
		Tool.Enabled = false

		local spawnCFrame = Torso.CFrame * SPAWN_OFFSET
		SledModel:TranslateBy(spawnCFrame.p - SledModel:GetModelCFrame().p)
		SledModel.Parent = Workspace
		sledPart.CFrame = spawnCFrame

		Tool:Destroy()
	end
end

SledModel = InsertService:LoadAsset(SLED_ID):GetChildren()[1]

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
