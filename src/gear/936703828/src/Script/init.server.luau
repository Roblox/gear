local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BarrelAttachment = Handle:FindFirstChildOfClass("Attachment")
local Functions = require(script:WaitForChild("Functions"))

local Character = nil
local Player = nil 
local Humanoid = nil
local RootPart = nil

local BASE_URL = "rbxassetid://"

local BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

local Configuration = {
	Accuracy = Vector3.new(0.1, 0.1, 0.1),
	Damage = {Min = 20, Max = 35},
	FireRate = 1.5,
	Range = 125,
	FadeRate = 1.25,
	MaxCharge = 2,
}

local ServerControl = Tool.Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction")
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool.Remotes

local ClientControl = Tool.Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction")
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool.Remotes

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function LaserTouched(hit)
	if not hit or not hit.Parent then
		return
	end
	local character = hit.Parent
	if character:IsA("Accessory") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	local DeterminedDamage = math.random(Configuration.Damage.Min, Configuration.Damage.Max)
	local HealthAfter = (humanoid.Health - DeterminedDamage)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DeterminedDamage)
end

function FireLaser(startPosition, endPosition)
	local Direction = CFrame.new(RootPart.Position, endPosition).lookVector
	local RayHit, RayPos, RayNormal = Functions.CastRay(RootPart.Position, Direction, Configuration.Range, {Character}, false)	
	local RayLength = (startPosition - RayPos).Magnitude
	Direction = CFrame.new(startPosition, endPosition)
	
	local Laser = BasePart:Clone()
	local FadeDuration = Configuration.FadeRate
	Laser.Name = "Laser"
	Laser.Material = Enum.Material.Neon
	Laser.Size = Vector3.new(0.2, RayLength, 0.2)
	Laser.Color = Color3.fromRGB(19, 203, 204)
	Laser.CFrame = (Direction * CFrame.new(0, 0, -(RayLength * 0.5)) * CFrame.Angles((math.pi * 0.5), 0, 0))
	Laser.Anchored = true
	Laser.CanCollide = false 
	Debris:AddItem(Laser, FadeDuration)
	Laser.Parent = workspace
	LaserTouched(RayHit)
end

function Fire()
	local TargetPosition = InvokeClient("MousePosition")
	if not TargetPosition then
		Tool.Enabled = true
		return
	end
	
	local StartPosition = BarrelAttachment.WorldPosition
	
	TargetPosition = TargetPosition.Position
	local Accuracy = Configuration.Accuracy * 100
	TargetPosition = TargetPosition + Vector3.new((math.random(-Accuracy.X, Accuracy.X) * 0.01), (math.random(-Accuracy.Y, Accuracy.Y) * 0.01), (math.random(-Accuracy.Z, Accuracy.Z) * 0.01))
	FireLaser(StartPosition, TargetPosition)	
	
	wait(Configuration.FireRate)
	Tool.Enabled = true 
end

function Activated()
	if not Tool.Enabled then return end 
	Tool.Enabled = false 
	Fire()
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
end

function Unequipped()
	Player = nil
	Character = nil
	Humanoid = nil
	RootPart = nil
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, mode, value)
	if player ~= Player or not Tool.Enabled or not CheckIfAlive() or not mode or not value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)