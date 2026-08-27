--Rescripted by StarWars
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Player = nil
local Humanoid = nil

local COOL_DOWN = 20
local TRAP_STAND_TIME = 120

local LastClick = 0

local function CreateDartTrap()
	local DartTrap = Handle:Clone()
	DartTrap.Name = "DartTrap"
	DartTrap.Friction = 1
	DartTrap.Elasticity = 0
	DartTrap.Transparency = 0
	DartTrap.CFrame = DartTrap.CFrame + Vector3.new(0, -1, 0)
	DartTrap.CanCollide = true
	DartTrap.Velocity = Vector3.new(0, 0, 0)
	DartTrap.RotVelocity = Vector3.new(0, 0, 0)
	
	--I don't know how I feel about this, this was from the old script.
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Parent = DartTrap	
	
	local CreatorObject = Instance.new("ObjectValue")
	CreatorObject.Value = Player
	CreatorObject.Name = "creator"
	CreatorObject.Parent = DartTrap
	
	local DartScript = script.DartScript:Clone()
	DartScript.Parent = DartTrap
	DartScript.Disabled = false	
	
	Debris:AddItem(DartTrap, TRAP_STAND_TIME)
	DartTrap.Parent = workspace
	
	wait(COOL_DOWN)
	Handle.Transparency = 0
end

local function OnActivated()
	if not Player then return end
	if not Humanoid then return end
	if tick() - COOL_DOWN > LastClick and Humanoid.Health > 0 then
		LastClick = tick()
		CreateDartTrap()
	end	
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