--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PumpkinScript = script:WaitForChild("PumpkinScript")

ReloadTime = 5
Duration = 20

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	RottenPumpkin = Handle:Clone()
	RottenPumpkin.Transparency = 0
	RottenPumpkin.Size = Vector3.new(1.5, 1.75, 1.5)
	RottenPumpkin.CanCollide = true
	RottenPumpkin:FindFirstChild("Mesh").MeshId = "http://www.roblox.com/asset?id=181316165"
	RottenPumpkin.Name = "RottenPumpkin"
	local PointLight = Instance.new("PointLight")
	PointLight.Brightness = 10
	PointLight.Color = BrickColor.new("Really red").Color
	PointLight.Enabled = false
	PointLight.Parent = RottenPumpkin
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = RottenPumpkin.CFrame
	BodyGyro.Parent = RottenPumpkin
	local PumkinScriptClone = PumpkinScript:Clone()
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = RottenPumpkin
	PumkinScriptClone.Disabled = false
	PumkinScriptClone.Parent = RottenPumpkin
	Debris:AddItem(RottenPumpkin, (Duration + 3))
	RottenPumpkin.Parent = game:GetService("Workspace")
	RottenPumpkin.CFrame = Handle.CFrame
	Debris:AddItem(RottenPumpkin, Duration)
	wait((Duration + ReloadTime))
	Handle.Transparency = 0
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	Handle.Transparency = 0
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)