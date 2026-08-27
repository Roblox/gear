--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

DamageValues = {
	BaseDamage = 10,
	SlashDamage = 11,
	LungeDamage = 22
}

for i, v in pairs(DamageValues) do
	DamageValues[i] = (v * 0.7)
end

Damage = DamageValues.BaseDamage

Sounds = {
	Slash = Handle:WaitForChild("SwordSlash"),
	Lunge = Handle:WaitForChild("SwordLunge"),
	Unsheath = Handle:WaitForChild("Unsheath"),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Lunge = {Animation = Tool:WaitForChild("Lunge"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Lunge = {Animation = Tool:WaitForChild("R15Lunge"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
	R15Slash = {Animation = Tool:WaitForChild("R15Slash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},	
}

Functions = require(script:WaitForChild("Functions"))

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

LastAttack = 0
ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function Blow(Hit)
	if not Hit or not Hit.Parent or not Character or not Humanoid or Humanoid.Health == 0 then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if (RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle)) then
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)	
	end
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	Spawn(function()
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			InvokeClient("PlayAnimation", Animations.R15Slash)
		else
			InvokeClient("PlayAnimation", Animations.Slash)
		end
	end)
end

function Lunge()
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	Spawn(function()
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			InvokeClient("PlayAnimation", Animations.R15Lunge)
		else
			InvokeClient("PlayAnimation", Animations.Lunge)
		end
	end)
	local Force = Instance.new("BodyVelocity")
	if Torso and Torso.Parent then
		Force.velocity = Vector3.new(0, 80, 0)
		Force.maxForce = Vector3.new(0, 4000, 0)
		Debris:AddItem(Force, 0.75)
		Force.Parent = Torso
	end
	wait(0.25)
	if Torso and Torso.Parent then
		Force.velocity = ((Torso.CFrame.lookVector * 120)  + Vector3.new(0, 60, 0))
	end
	wait(0.5)
	if Force and Force.Parent then
		Force:Destroy()
	end
	wait(0.5)
	Damage = DamageValues.SlashDamage
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick
	--wait(0.5)
	Tool.Enabled = true
end

function CreateDualWield(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Create and CheckIfAlive() then
		local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
		if not LeftArm then
			return
		end
		FakeHandle = Handle:Clone()
		FakeHandle.CanCollide = false
		FakeHandle.Name = "FakeHandle"
		local LeftGrip = Instance.new("Weld")
		LeftGrip.C0 = CFrame.new(0, (LeftArm.Name == "LeftHand" and -.15) or -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		LeftGrip.C1 = Tool.Grip
		LeftGrip.Part0 = LeftArm
		LeftGrip.Part1 = FakeHandle
		LeftGrip.Parent = FakeHandle
		FakeHandle.Parent = Tool
		FakeHandle.Touched:connect(Blow)
	else
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		local LeftGrip = Instance.new("Weld")
		LeftGrip.C0 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 4), 0))
		LeftGrip.C1 = CFrame.new(0, 0, 0)
		LeftGrip.Part0 = Handle
		LeftGrip.Part1 = FakeHandle
		LeftGrip.Parent = FakeHandle
		FakeHandle.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Spawn(function()
		CreateDualWield(true)
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			InvokeClient("PlayAnimation", Animations.R15Hold)
		else
			InvokeClient("PlayAnimation", Animations.Hold)
		end
	end)
	Sounds.Unsheath:Play()
end

function Unequipped()
	Spawn(function()
		CreateDualWield(false)
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

CreateDualWield(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Handle.Touched:connect(Blow)