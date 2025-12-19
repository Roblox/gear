--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")
Light = Handle:WaitForChild("IlluminaLight")
Light.Enabled = true

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Up = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0),
	Out = CFrame.new(0, 0, -1.5, 0, -1, -0, -1, 0, -0, 0, 0, -1),
}

DamageValues = {
	BaseDamage = 10,
	SlashDamage = 20,
	LungeDamage = 40,
}

Damage = DamageValues.BaseDamage

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Unsheath = Handle:WaitForChild("Unsheath"),
}

IlluminaSparkles = Handle:WaitForChild("IlluminaSparkles"):Clone()

LastAttack = 0
GhostSparkles = {}
ToolEquipped = false

Tool.Enabled = true

function SwordUp()
	Tool.Grip = Grips.Up
end

function SwordOut()
	Tool.Grip = Grips.Out
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

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Slash"
	Anim.Parent = Tool
end

function Lunge()
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Lunge"
	Anim.Parent = Tool	
	local Force = Instance.new("BodyVelocity")
	Force.velocity = Vector3.new(0, 80, 0) 
	local Gravity = game:GetService("Workspace").Gravity
	local Mass = 0
	for i, v in pairs(GetAllConnectedParts(RootPart)) do
		Mass = (Mass + v:GetMass())
	end
	Force.maxForce = Vector3.new(0, (Mass * Gravity), 0)
	Debris:AddItem(Force, 0.75)
	Force.Parent = RootPart
	wait(0.25)
	Force.velocity = ((RootPart.CFrame.lookVector * 120) + Vector3.new(0, 80, 0))
	SwordOut()
	wait(0.5)
	if Force and Force.Parent then
		Force:Destroy()
	end
	wait(0.25)
	SwordUp()
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local RightArm = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
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

function RevealPlayersNearby()
	if ToolEquipped and CheckIfAlive() then
		for i, v in pairs(Players:GetPlayers()) do
			if v:IsA("Player") and v ~= Player and v.Character then
				local character = v.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local rootpart = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
				if humanoid and rootpart then
					local DistanceApart = (Handle.Position - rootpart.Position).Magnitude
					if DistanceApart < 32 then
						for ii, vv in pairs(character:GetChildren()) do
							if vv:IsA("BasePart") and vv.Transparency > 0 and vv ~= rootpart and not vv:FindFirstChild(IlluminaSparkles.Name) then
								local Sparkles = IlluminaSparkles:Clone()
								Debris:AddItem(Sparkles, 2)
								Sparkles.Parent = vv
								Delay(1.5, (function()
									Sparkles.Enabled = false
									wait(0.5)
									for iii, vvv in pairs(GhostSparkles) do
										if vvv == Sparkles then
											table.remove(GhostSparkles, iii)
											break
										end
									end
								end))
							end
						end
					end
				end
			end
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack) < 0.2 then
		Lunge()
	else
		Attack()
	end
	Damage = DamageValues.BaseDamage
	LastAttack = Tick
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
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
	Spawn(function()
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		while CheckIfAlive() and ToolEquipped and CurrentlyEquipped do
			RevealPlayersNearby()
			wait(0.25)
		end
	end)
	Sounds.Unsheath:Play()
end

function Unequipped()
	for i, v in pairs(GhostSparkles) do
		if v and v.Parent then
			v.Enabled = false
		end
		table.remove(GhostSparkles, i)
	end
	GhostSparkles = {}
	ToolEquipped = false
end

SwordUp()

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)