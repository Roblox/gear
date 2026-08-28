-- // Created by StarWars
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local Tool = script.Parent
local ClapboardModel = Tool:FindFirstChild("Clapboard")
local BottomPart = ClapboardModel:FindFirstChild("Bottom")
local ClapboardMotor = BottomPart:FindFirstChildOfClass("Motor6D")

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local MAX_ANGLE = math.rad(20)
local CLAP_RADIUS = 25
local CLAP_SIZE = Vector3.new(CLAP_RADIUS, CLAP_RADIUS, CLAP_RADIUS)
local CLAP_FORCE = 5.5
local RELOAD_TIME = 1

local Reloading = false

local function CreateRegion3FromLocAndSize(Position, Size)
	local SizeOffset = Size * 0.5
	local Point1 = Position - SizeOffset
	local Point2 = Position + SizeOffset
	
	return Region3.new(Point1, Point2)
end

local function PushCharacter(Character, Direction)
	local TotalMass = 0
	for _, Part in next, Character:GetDescendants() do
		if Part:IsA("BasePart") then
			TotalMass = TotalMass + Part:GetMass()
		end
	end
	
	local NewBodyForce = Instance.new("BodyForce")
	NewBodyForce.Force = Direction * (TotalMass * workspace.Gravity * CLAP_FORCE)
	NewBodyForce.Parent = Character.PrimaryPart
	Debris:AddItem(NewBodyForce, 0.2)
end

Gear:BindEquippedFunction("clapboard_equipped", function()
	if not Reloading then
		ClapboardMotor.DesiredAngle = MAX_ANGLE
		ClapboardMotor.MaxVelocity = 0.1
	end
end)

Gear:BindActivateFunction("clapboard_activate", function()
	Reloading = true
	ClapboardMotor.MaxVelocity = 0.5
	ClapboardMotor.DesiredAngle = 0
	pcall(function()
		Gear.ClientControls:InvokeClient(Gear.Player, "PlaySound", Tool.Handle.Clapboard)
	end)
	
	local PushRegion = CreateRegion3FromLocAndSize(Gear.RootPart.CFrame.p, CLAP_SIZE)
	
	local Parts = workspace:FindPartsInRegion3WithIgnoreList(PushRegion, {Gear.Character}, math.huge)
	for _, Part in next, Parts do
		if Part:IsA("BasePart") and Part.Name == "HumanoidRootPart" then
			local Humanoid = Part.Parent:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health > 0 then
				local Direction = CFrame.new(Gear.RootPart.CFrame.p, Part.CFrame.p + Vector3.new(0, 1, 0)).lookVector
				PushCharacter(Part.Parent, Direction)
			end
		end
	end

	wait(RELOAD_TIME)	
	ClapboardMotor.MaxVelocity = 0.1
	ClapboardMotor.DesiredAngle = MAX_ANGLE
	wait(0.1)
	Reloading = false
end)