local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool.Handle

local GravityModifier = 0.75
local BaseSparkles = Instance.new("Sparkles")
BaseSparkles.SparkleColor = Color3.new(0, 0.5, 0)
local Sparkles = nil

local ServerControls = Tool:FindFirstChild("ServerControls") or Instance.new("RemoteEvent")
ServerControls.Name = "ServerControls"

local Player = nil
local Character = nil
local Torso = nil

local function GetMassOfCharacter()
	if not Character then return 0 end
	local TotalMass = 0

	for i, v in ipairs(Character:GetChildren()) do 
		if v:IsA("BasePart") then
			TotalMass = TotalMass + v:GetMass()
		end
	end

	return TotalMass + Handle:GetMass()
end

function OnActivate()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	ServerControls:FireClient(Player)
	Handle.DrinkSound:Play()
	wait(0.3)
	Handle.DanceMusic:Play()
	if not Sparkles then
		Sparkles = BaseSparkles:Clone()
	end

	Sparkles.Parent = Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftFoot")
	
	local LookVector = Torso.CFrame.lookVector
	local XLook = LookVector.x / (math.abs(LookVector.x) + math.abs(LookVector.z))
	local ZLook = LookVector.z / (math.abs(LookVector.x) + math.abs(LookVector.z))
	local UnitLook = Vector2.new(XLook, ZLook).unit 

	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.Position = Vector3.new(Torso.Position.x + (-UnitLook.x * 60), Torso.Position.y + 2, Torso.Position.z + (-UnitLook.y * 60))
	BodyPosition.P = GetMassOfCharacter() * 6.7 * workspace.Gravity * GravityModifier
	BodyPosition.D = BodyPosition.P * 0.5
	BodyPosition.MaxForce = Vector3.new(BodyPosition.P, BodyPosition.P, BodyPosition.P)

	wait(0.9)
	BodyPosition.Parent = Torso
	Debris:AddItem(BodyPosition, 5.8)

	wait(6)

	Handle.WooSound:Play()

	wait(1)

	Handle.DanceMusic:Stop()
	Sparkles:Destroy()
	Sparkles = nil

	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
end

function OnUnequipped()
	Character = nil
	Player = nil
	Torso = nil
end

Tool.Activated:Connect(OnActivate)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)