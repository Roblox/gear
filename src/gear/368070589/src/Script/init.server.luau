--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ResizeScript = script:WaitForChild("ResizeScript")
BlimpScript = script:WaitForChild("BlimpScript")

DelayWait = 2
Duration = 45
ReloadTime = 15

Grips = {
	Unequipped = CFrame.new(0, -2.5, 1.5, 0.875, -0, 0.5, 0, 1, 0, -0.5, 0, 0.875),
	Equipped = CFrame.new(0, -1, 0, 1, 0, -0, -0, 1, -0, 0, 0, 1),
}

ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Mesh.Scale = Vector3.new(1, 1, 1)
Handle.Transparency = 0
Tool.Grip = Grips.Equipped
Tool.Enabled = true

function Transform()
	local ResizeScriptClone = Character:FindFirstChild(ResizeScript.Name)
	if not ToolEquipped or not CheckIfAlive() or ResizeScriptClone then
		return
	end
	Handle.Transparency = 1
	local Blimp = Handle:Clone()
	Blimp.Name = "Blimp"
	Blimp.Transparency = 0
	Blimp.CanCollide = false
	Blimp.Size = (Blimp.Size * 3)
	local BlimpMesh = Blimp:FindFirstChild("Mesh")
	if BlimpMesh then
		BlimpMesh.Scale = (BlimpMesh.Scale * 3)
	end
	local Gravity = 196.20
	local Mass = (Blimp:GetMass() * Gravity)
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.D = 1000
	BodyPosition.P = 10000
	BodyPosition.maxForce = Vector3.new((Mass * 10), (Mass * 5), (Mass * 10))
	BodyPosition.position = Blimp.Position
	BodyPosition.Parent = Blimp
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Blimp.CFrame
	BodyGyro.Parent = Blimp
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Duration", Class = "NumberValue", Value = (Duration + DelayWait + 3)},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = Blimp
	end
	local BlimpScriptCopy = BlimpScript:Clone()
	BlimpScriptCopy.Disabled = false
	BlimpScriptCopy.Parent = Blimp
	Blimp.CFrame = ((Handle.CFrame + Torso.CFrame.lookVector * 2) + Vector3.new(0, 3, 0))
	Blimp.Parent = game:GetService("Workspace")
	local ResizeScriptClone = ResizeScript:Clone()
	local Values = {
		{Name = "Delay", Class = "NumberValue", Value = DelayWait},
		{Name = "Duration", Class = "NumberValue", Value = Duration},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = ResizeScriptClone
	end
	local DurationValue = Instance.new("NumberValue")
	DurationValue.Name = "Duration"
	DurationValue.Value = Duration
	DurationValue.Parent = ResizeScriptClone
	ResizeScriptClone.Disabled = false
	ResizeScriptClone.Parent = Character
	wait(Duration)
	if Blimp and Blimp.Parent then
		Blimp:Destroy()
	end
	Handle.Transparency = 0
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Transform()
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)