--Fixed by Luckymaxer
--Updated for R15 Avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

DamageValues = {
	BaseDamage = 10,
	SlashDamage = 12,
	LungeDamage = 24
}

Damage = DamageValues.BaseDamage

Sounds = {
	Slash = Handle:WaitForChild("SwordSlash"),
	Lunge = Handle:WaitForChild("SwordLunge"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

Animations = {
	Slash = Tool:WaitForChild("Slash"),
	R15Slash = Tool:WaitForChild("R15Slash")
}

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not Character or not Humanoid or Humanoid.Health == 0 then
		return
	end
	local humanoid = Hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if (RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle)) then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)	
		end
	end
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	local Animation = Animations.Slash
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Slash
	end
	InvokeClient("PlayAnimation", {Animation = Animation, Speed = 1.5})
end

function Lunge()
	Damage = DamageValues.LungeDamage

	Sounds.Lunge:Play()

	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Lunge"
	Anim.Parent = Tool
	
	local Force = Instance.new("BodyVelocity")
	if Torso and Torso.Parent then
		Force.velocity = Vector3.new(0, 80, 0)
		Force.maxForce = Vector3.new(0, 4000, 0)
		Debris:AddItem(Force, 0.75)
		Force.Parent = Torso
	end
	
	wait(0.25)
	
	if Torso and Torso.Parent then
		Force.velocity = (Torso.CFrame.lookVector * 120)  + Vector3.new(0, 60, 0)
	end
	
	wait(0.5)
	
	if Force and Force.Parent then
		Force:Destroy()
	end
	
	wait(0.5)

	Damage = DamageValues.SlashDamage
end

Tool.Enabled = true
LastAttack = 0

function Activated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	Tick = RunService.Stepped:wait()

	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end

	LastAttack = Tick

	--wait(0.5)

	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Sounds.Unsheath:Play()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)

Connection = Handle.Touched:connect(Blow)