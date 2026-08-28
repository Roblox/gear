-- Made by StarWars

local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")

local DroneModel = InsertService:LoadAsset(980213529)
DroneModel = DroneModel:GetChildren()[1]

local Tool = script.Parent 
local Handle = Tool.Handle
local RemoteController = Tool.Remote
local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction")
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

local ClientControl = Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction")
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

local Character = nil
local Player = nil
local Humanoid = nil
local RootPart = nil
local CurrentDrone = nil

local ToolEquipped = false
Tool.Enabled = true

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function SpawnNewDrone()
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	local BodyPosition = Instance.new("BodyPosition")	
	BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
	
	CurrentDrone = DroneModel:Clone()
	BodyGyro.Parent = CurrentDrone.PrimaryPart
	BodyPosition.Parent = CurrentDrone.PrimaryPart
	CurrentDrone:SetPrimaryPartCFrame(RootPart.CFrame * CFrame.new(0, 5, -5))
	BodyPosition.Position = CurrentDrone:GetPrimaryPartCFrame().p
	BodyGyro.CFrame = RootPart.CFrame * CFrame.new(0, 5, -5)
	CurrentDrone.Parent = workspace
	CurrentDrone.PrimaryPart:SetNetworkOwner(Player)	
	
	spawn(function() InvokeClient("SpawnDrone", CurrentDrone) end)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or CurrentDrone then
		return
	end 
	
	Handle.Transparency = 1
	RemoteController.Transparency = 0
	SpawnNewDrone()
end

function Equipped()
	ToolEquipped = true
	Handle.Transparency = 0
	RemoteController.Transparency = 1
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	RootPart = Character:FindFirstChild("HumanoidRootPart")
end

function Unequipped()
	Character = nil
	Player = nil
	RootPart = nil
	Humanoid = nil
	ToolEquipped = false
	if CurrentDrone then
		CurrentDrone:Destroy()
	end
	CurrentDrone = nil
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

