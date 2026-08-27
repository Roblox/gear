--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

DamageValues = {
	BaseDamage = 5,
	SwingDamage = 17
}

Damage = DamageValues.BaseDamage

Sounds = {
	Smash1 = Handle:WaitForChild("Smash1"),
	Smash2 = Handle:WaitForChild("Smash2"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	R6Swing = {Animation = R6Anims:WaitForChild("Swing"), FadeTime = 0.1, Weight = nil, Speed = 1.5, Duration = 0.75},
	R15Swing = {Animation = R15Anims:WaitForChild("Swing"), FadeTime = 0.1, Weight = nil, Speed = 1.5, Duration = 0.75},
}

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

ToolEquipped = false

Tool.Enabled = true

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
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		if Hit:GetMass() < 34 and not Tool.Enabled then
			Hit:BreakJoints()
			local Dir = (Hit.Position - RootPart.Position).unit
			Hit.Velocity = (Dir * math.random(20, 45))
		end
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)	
end


function Attack()
	Damage = DamageValues.SwingDamage
	
	local SmashSounds = {Sounds.Smash1, Sounds.Smash2}
	local Sound = SmashSounds[math.random(1, #SmashSounds)]
	Sound.Pitch = (0.9 + (math.random() * 0.2))
	Sound.Volume = (0.7 + (math.random() * 0.3))
	Sound:Play()
	local RigType = Humanoid.RigType
	local SwingAnim = Animations.R6Swing
	if RigType == Enum.HumanoidRigType.R15 then
		SwingAnim = Animations.R15Swing
	end
	Spawn(function()
		InvokeClient("PlayAnimation", SwingAnim)
	end)
	wait(SwingAnim.Duration)
end
	
function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Attack()
	Damage = DamageValues.BaseDamage
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.Unsheath:Play()
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Connection = Handle.Touched:connect(Blow)