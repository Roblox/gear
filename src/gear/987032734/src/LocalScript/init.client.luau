-- Made by StarWars

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Tool = script.Parent 
local Drone = require(script:WaitForChild("Drone"))

local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = Remotes:WaitForChild("ServerControl")
local ClientControl = Remotes:WaitForChild("ClientControl")

local Player = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local CurrentDrone = nil
local RenderSteppedConn = nil

local ToolEquipped = false

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function CreateDrone(model)
	CurrentDrone = Drone.new(model)
	
	RenderSteppedConn = RunService.RenderStepped:Connect(function(delta)
		if not CurrentDrone then return end 
		CurrentDrone:Update(delta)
	end)
end

function Equipped()
	ToolEquipped = true
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function Unequipped()
	ToolEquipped = false
	Character = nil
	Humanoid = nil
	if CurrentDrone then
		CurrentDrone:Destroy()
	end
	if RenderSteppedConn then
		RenderSteppedConn:Disconnect()
	end	
	
	RenderSteppedConn = nil	
	CurrentDrone = nil
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode then
		return
	end

	if mode == "SpawnDrone" then
		CreateDrone(value)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)