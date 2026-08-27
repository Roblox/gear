--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = {
	ThrowDamage = 16,
	HitDamage = 22
}

Animations = {
	Tool:WaitForChild("Slash"),
	Tool:WaitForChild("SlashV2")
}

MaxDistance = 45

AwayFromCharacter = false

BladeThrowable = true

Equipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "MouseClick" and Value.Down then
		Click()
	elseif Mode == "KeyPress" and Value.Key == "q" and Value.Down then
		ThrowBlade(Value.Position)
	end
end)

Handle.Transparency = 0
Tool.Enabled = true

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

function Click()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local Animation = Animations[math.random(1, #Animations)]
	InvokeClient("PlayAnimation", {Animation = Animation, Speed = 1})
	wait(1.25)
	Tool.Enabled = true
end

function ThrowBlade(TargetPos)
	if not Tool.Enabled then
		return
	end
	if BladeThrowable and CheckIfAlive() then
		Handle.Transparency = 1
		local CloneBlade = Handle:Clone()
		CloneBlade.Name = "Blade"
		CloneBlade.Transparency = 0
		local Direction = (TargetPos - Handle.Position).unit
		Spawn(function()
			Throw(CloneBlade, Direction)
		end)
		Tool.Enabled = false
		wait(5)
		Handle.Transparency = 0
		BladeThrowable = true
		Tool.Enabled = true
	end 
end

function Blow(Hit, damage)
	if not Hit or not Hit.Parent then
		return
	end
	local humanoid = Hit.Parent:FindFirstChild("Humanoid")
	if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(damage)
		AwayFromCharacter = false
	end 
end 

function ReturnToCharacter(CloneBlade)
	if CloneBlade and CheckIfAlive() then
		local Distance = (CloneBlade.Position - Torso.Position).magnitude 
		local LookAt = (Torso.Position - CloneBlade.Position).unit 
		while Distance > 4 and CloneBlade do 
			CloneBlade.Velocity = LookAt * 45
			if CloneBlade then 
				LookAt = (Torso.Position - CloneBlade.Position).unit 
				Distance = (Torso.Position - CloneBlade.Position).magnitude 
			end 
			wait()
		end 
		if CloneBlade and CloneBlade.Parent then
			CloneBlade:Destroy()
		end
		wait(0.25) 
	end 
end 

function Throw(CloneBlade, Direction)       
	local SpawnPos = Handle.Position + Direction * 4
	CloneBlade.CFrame = CFrame.new(SpawnPos, (SpawnPos + Direction)) * CFrame.Angles((math.pi / 2), 0, 0) 
	CloneBlade.CanCollide = false

	CloneBlade.Velocity = (Direction * 45)
	CloneBlade.RotVelocity = Vector3.new(0, 40, 0)

	local FloatForce = Instance.new("BodyForce") 
	FloatForce.force = Vector3.new(0, (CloneBlade:GetMass() * 196.20), 0) 
	FloatForce.Parent = CloneBlade 

	Debris:AddItem(CloneBlade, 10)
	CloneBlade.Parent = game:GetService("Workspace") 

	CloneBlade.Touched:connect(function(Hit)
		Blow(Hit, Damage.ThrowDamage)
	end)

	AwayFromCharacter = true

	local Distance = (CloneBlade.Position - SpawnPos).magnitude 
	while AwayFromCharacter and Distance < MaxDistance do 
		Distance = (CloneBlade.Position - SpawnPos).magnitude 
		wait(0.25)
	end 
	AwayFromCharacter = false 
	ReturnToCharacter(CloneBlade) 
end

function SpinBlade()
	Spawn(function()
		local Theta = (math.pi / 6)
		while Equipped do 			
			Tool.GripForward = Vector3.new(math.cos(Theta), math.sin(Theta), 0)			
			Tool.GripUp = Vector3.new(-math.sin(Theta), math.cos(Theta), 0) 
			Theta = (Theta + (math.pi / 6))
			wait()
		end
		Tool.Grip = CFrame.new(0, 0, 0, 0, 0, -1, 0, 1, 0, 1, -0, 0)
	end)
end

function CheckIfAlive()
	return (Player and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Equipped = true
	SpinBlade()
end

function Unequipped()
	Equipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Handle.Touched:connect(function(Hit)
	Blow(Hit, Damage.HitDamage)
end)