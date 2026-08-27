local Part = script.Parent

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local DancifyScript = script:WaitForChild("Dancify")

local Creator = Part:FindFirstChild("Creator")

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function Dancify(Character)
	local DancifyScriptCopy = Character:FindFirstChild(DancifyScript.Name)
	if DancifyScriptCopy then
		return
	end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	DancifyScriptCopy = DancifyScript:Clone()
	local Animations = {
		{Id = (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 and 1379429069) or 429678251, Speed = 0.6},
		{Id = (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 and 1379430180) or 429681631, Speed = 0.8},
		{Id = (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 and 507771019) or 429699657, Speed = 0.65},
		{Id = (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 and 1379432998) or 429703734, Speed = 1},
		{Id = (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 and 1379434463) or 429730430, Speed = 1},
	}
	local AnimationChosen = Animations[math.random(1, #Animations)]
	local Values = {
		{Name = "AnimationId", Class = "IntValue", Value = AnimationChosen.Id},
		{Name = "Speed", Class = "NumberValue", Value = AnimationChosen.Speed},
		{Name = "Duration", Class = "NumberValue", Value = 10},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = DancifyScriptCopy
	end
	DancifyScriptCopy.Disabled = false
	DancifyScriptCopy.Parent = Character
end

function Touched(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local creator = GetCreator()
	local character = Hit.Parent
	if character:IsA("Accessory") or character:IsA("Tool") then
		character = character.Parent
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and player == creator then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if creator and humanoid and humanoid.Health > 0 then
		Dancify(character)
	end
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	Debris:AddItem(Part, 1.5)
end

Part.Touched:Connect(Touched)