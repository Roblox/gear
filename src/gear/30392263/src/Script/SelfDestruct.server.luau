--Rescripted by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Torso = Character:FindFirstChild("Torso")

Creator = Character:FindFirstChild("Creator")

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	Debris:AddItem(CreatorTag, 2)
	CreatorTag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function SelfDestruct()
	if not Humanoid or not Torso then
		return
	end
	local Explosion = Instance.new("Explosion")
	Explosion.ExplosionType = Enum.ExplosionType.NoCraters
	Explosion.BlastPressure = 15
	Explosion.BlastRadius = 15
	Explosion.DestroyJointRadiusPercent = 0
	Explosion.Position = Torso.Position
	Explosion.Hit:connect(function(Hit)
		local CreatorPlayer = GetCreator()
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local CanBreak = false
		if humanoid then
			local player = Players:GetPlayerFromCharacter(character)
			if CreatorPlayer and (player ~= CreatorPlayer and IsTeamMate(CreatorPlayer, player)) then
				return
			end
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("ForceField") then
					return
				end
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, CreatorPlayer)
			CanBreak = true
		else
			CanBreak = true
		end
		Hit:BreakJoints()
		Hit.Velocity = (CFrame.new(Explosion.Position, Hit.Position).lookVector * Explosion.BlastPressure)
	end)
	Explosion.Parent = game:GetService("Workspace")
	Debris:AddItem(Character, 3)
end

if Humanoid then
	Humanoid.Died:connect(SelfDestruct)
end