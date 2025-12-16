--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Sounds = {
	CoilSound = Handle:WaitForChild("CoilSound"),
}

Gravity = 196.20
JumpHeightPercentage = 0.25

ToolEquipped = false

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function SetGravityEffect()
	if not GravityEffect or not GravityEffect.Parent then
		GravityEffect = Instance.new("BodyForce")
		GravityEffect.Name = "GravityCoilEffect"
		GravityEffect.Parent = Torso
	end
	local TotalMass = 0
	local ConnectedParts = GetAllConnectedParts(Torso)
	for i, v in pairs(ConnectedParts) do
		if v:IsA("BasePart") then
			TotalMass = (TotalMass + v:GetMass())
		end
	end
	local TotalMass = (TotalMass * 196.20 * (1 - JumpHeightPercentage))
	GravityEffect.force = Vector3.new(0, TotalMass, 0)
end

function HandleGravityEffect(Enabled)
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyForce") then
			v:Destroy()
		end
	end
	for i, v in pairs({ToolUnequipped, DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	if Enabled then
		CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		SetGravityEffect()
		DescendantAdded = Character.DescendantAdded:connect(function()
			wait()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect()
		end)
		DescendantRemoving = Character.DescendantRemoving:connect(function()
			wait()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect()
		end)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	if HumanoidDied then
		HumanoidDied:disconnect()
	end
	HumanoidDied = Humanoid.Died:connect(function()
		if GravityEffect and GravityEffect.Parent then
			GravityEffect:Destroy()
		end
	end)
	Sounds.CoilSound:Play()
	HandleGravityEffect(true)
	ToolEquipped = true
end

function Unequipped()
	if HumanoidDied then
		HumanoidDied:disconnect()
	end
	HandleGravityEffect(false)
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)