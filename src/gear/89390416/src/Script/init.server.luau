--Rescripted by StarWars
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Player = nil
local Humanoid = nil

local OnCoolDown = false

local COOL_DOWN = 14
local AMOUNT_OF_DRONES = 9

local function CreateDrone()
	local Model = Instance.new("Model")
	Model.Name = "Arachnix Drone"
	local DronePart = Handle:Clone()
	DronePart.Name = "Torso"
	DronePart.Friction = 0.2
	DronePart.Transparency = 0 
	DronePart.CanCollide = true
	DronePart.CFrame = CFrame.new()
	local RandomDirection = Vector3.new((math.random() - 0.5) * 15, (math.random()- 0.5) * 5, (math.random() - 0.5) * 15)
	DronePart.Position = Handle.Position + RandomDirection
	DronePart.Velocity = RandomDirection
	DronePart.Parent = Model
	local Head = Instance.new("Part")
	Head.Name = "Head"
	Head.Transparency = 1
	Head.Size = Vector3.new(0, 0, 0)
	Head.Parent = Model
	local Weld = Instance.new("Weld")
	Weld.Name = "Neck"
	Weld.Part0 = DronePart
	Weld.Part1 = Head
	Weld.Parent = DronePart
	local Humanoid = Instance.new("Humanoid")
	Humanoid.MaxHealth = 5
	Humanoid.Health = 5
	Humanoid.WalkSpeed = 20
	Humanoid.Parent = Model
	local CreatorObject = Instance.new("ObjectValue")
	CreatorObject.Name = "creator"
	CreatorObject.Value = Player
	CreatorObject.Parent = Model
	local DroneScript = script.DroneScript:Clone()
	DroneScript.Parent = Model
	DroneScript.Disabled = false
	
	Debris:AddItem(Model, 20)
	Model.Parent = workspace
	DronePart.Position = Handle.Position + RandomDirection
end

local function OnActivated()
	if OnCoolDown then return end
	if not Player then return end
	if not Humanoid then return end
	if Humanoid.Health == 0 then return end
	
	OnCoolDown = true
	Handle.Transparency = 1
	for i = 1, AMOUNT_OF_DRONES do 
		CreateDrone()
	end
	wait(COOL_DOWN)
	OnCoolDown = false
end

local function OnEquipped()
	Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
end

local function OnUnequipped()
	Player = nil
	Humanoid = nil
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)