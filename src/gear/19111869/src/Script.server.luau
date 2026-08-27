--Made by Stickmasterluke
--Rescripted by StarWars

local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle
local LastUse = Tool.LastUse

local Sound = Handle.Sound
local Sparkles = Handle.Sparkles

local Character = nil
local Humanoid = nil

local COOLDOWN = 10

local BaseMenorah = Handle:Clone()
BaseMenorah.Name = "Menorah"
BaseMenorah.Friction = 1
BaseMenorah.Elasticity = 0
BaseMenorah.Transparency = 0
BaseMenorah.CanCollide = true
BaseMenorah.Velocity = Vector3.new(0, 0, 0)
BaseMenorah.RotVelocity = Vector3.new(0, 0, 0)

local BaseGyro = Instance.new("BodyGyro")
BaseGyro.Parent = BaseMenorah

local BasePart = Instance.new("Part")
BasePart.Name = "Effect"
BasePart.CanCollide = true
BasePart.Anchored = false
BasePart.Size = Vector3.new(1, 1, 1)
BasePart.BrickColor = BrickColor.new("Bright blue")
BasePart.Reflectance = 0.75
BasePart.Velocity = Vector3.new((math.random() - 0.5) * 20, 50, (math.random() - 0.5) * 20)

local BaseSparkles = Instance.new("Sparkles")
BaseSparkles.SparkleColor = Color3.fromRGB(0, 204, 255)
BaseSparkles.Parent = BasePart

function DropMenorah()
	local Menorah = BaseMenorah:Clone()
	Menorah.CFrame = Handle.CFrame + Vector3.new(0, -1, 0)	
	Menorah.Parent = workspace
	Debris:AddItem(Menorah, COOLDOWN)
	
	delay(3, function()
		for i = 1, 8 do
			wait(0.5)
			local Part = BasePart:Clone()
			Part.CFrame = Menorah.CFrame + Vector3.new(0, 4, 0)
			Part.Velocity = Vector3.new((math.random() - 0.5) * 20, 50, (math.random() - 0.5) * 20)
			Debris:AddItem(Part, COOLDOWN)
			Part.Parent = workspace
		end
	end)
end

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function OnUnequipped()
	Character = nil
	Humanoid = nil
end

function OnActivate()
	if not Tool.Enabled then return end
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end
	
	Tool.Enabled = false
	
	if Sound then
		Sound:Play()
	end
	
	if Sparkles then
		Sparkles.Enabled = true
	end
	
	LastUse.Value = tick()
	DropMenorah()
	
	wait(COOLDOWN)
	Tool.Enabled = true
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnEquipped)
Tool.Activated:Connect(OnActivate)