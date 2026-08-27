--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = {
	Touched = 3,
	Slash = 6,
	Current = 0
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
}

Grips = {
	Up = CFrame.new(0.100000001, 1.4, -0.3, -4.37113883e-008, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-008),
	Out = (CFrame.Angles(math.pi, -(math.pi / 2), 0) + Vector3.new(0, 1.5, 0)),
}

ReloadTime = 0.4

ToolEquipped = false

Damage.CurrentDamage = Damage.Touched
Tool.Grip = Grips.Up
Tool.Enabled = true

function IsTurbo()
	return Character:FindFirstChild("PaperHat")
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	
	local character = Hit.Parent
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and (IsTeamMate(Player, player) or player == Player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local FinalizedDamage = Damage.CurrentDamage
	FinalizedDamage = ((IsTurbo() and (FinalizedDamage * 2.5)) or FinalizedDamage)
	
	humanoid:TakeDamage(FinalizedDamage)
	
end

function Attack()
	Damage.CurrentDamage = Damage.Slash
	Sounds.Slash:Play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
	Tool.Grip = Grips.Out
	Damage.CurrentDamage = Damage.Slash
	wait(0.5)
	Damage.CurrentDamage = Damage.Touched
	Sounds.Slash:Stop()
	Tool.Grip = Grips.Up
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Attack()
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Slash:Play()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)