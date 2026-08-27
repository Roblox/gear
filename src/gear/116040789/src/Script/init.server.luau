-- // Rescripted by StarWars
local Debris = game:GetService("Debris")

local GearService = require(1075123174)
local Tool = script.Parent
local Handle = Tool.Handle

local Gear = GearService:BindGear(Tool)
Gear:SetupLocalScript("MouseIcon")

local COOLDOWN = 25

function CreateSpiderModel()
	local NewModel = Instance.new("Model")
	NewModel.Name = "Metatronic Spider"
	
	local NewPart = Handle:Clone()
	NewPart.Friction = 0.2
	NewPart.Name = "Torso"
	NewPart.Transparency = 0
	NewPart.CanCollide = true
	local RandomVector = Vector3.new((math.random() - 0.5) * 15, (math.random() - 0.5) * 5, (math.random() - 0.5) * 15)
	NewPart.CFrame = CFrame.new(Handle.CFrame.p) * CFrame.new(RandomVector)
	NewPart.Velocity = RandomVector
	NewPart.Parent = NewModel
	
	local Head = Instance.new("Part")
	Head.Name = "Head"
	Head.Transparency = 1
	Head.Size = Vector3.new(0,0,0)
	Head.Parent = NewModel
	
	local NeckMotor = Instance.new("Motor6D")
	NeckMotor.Name = "Neck"
	NeckMotor.Part0 = NewPart
	NeckMotor.Part1 = Head
	NeckMotor.Parent = NewPart
	
	local Humanoid = Instance.new("Humanoid")
	Humanoid.MaxHealth = 5
	Humanoid.Health = 5
	Humanoid.WalkSpeed = 20
	Humanoid.Parent = NewModel
	
	local CreatorObject = Instance.new("ObjectValue")
	CreatorObject.Value = Gear.Player
	CreatorObject.Name = "creator"
	CreatorObject.Parent = NewModel
	
	local NewScript = script.SpiderAI:Clone()
	NewScript.Parent = NewModel
	NewScript.Disabled = false
	
	Debris:AddItem(NewModel, math.random(20, 30))
	NewModel.Parent = workspace
	
	return NewModel
end

Gear:BindActivateFunction("spider_activate", function()
	CreateSpiderModel()
	wait(COOLDOWN)
end)