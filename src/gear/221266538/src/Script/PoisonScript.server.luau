--Made by Luckymaxer

Character = script.Parent

Debris = game:GetService("Debris")

Humanoid = Character:FindFirstChild("Humanoid")

Creator = script:FindFirstChild("Creator")

BaseFire = Instance.new("Fire")
BaseFire.Color = BrickColor.new("Bright green").Color
BaseFire.SecondaryColor = BrickColor.new("Dark green").Color
BaseFire.Heat = 10
BaseFire.Size = 5
BaseFire.Enabled = true

function DestroyScript()
	Debris:AddItem(script, 1)
	script:Destroy()
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

if not Humanoid then
	DestroyScript()
	return
end

local Flames = {}

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") and v.Transparency < 1 then
		local Fire = BaseFire:Clone()
		table.insert(Flames, Fire)
		Fire.Parent = v
	end
end

Humanoid.WalkSpeed = 8

for i = 1, 6 do
	if Humanoid and Humanoid.Health > 0 then
		UntagHumanoid(Humanoid)
		if Creator and Creator.Parent then
			local CreatorPlayer = Creator.Value
			if CreatorPlayer and CreatorPlayer:IsA("Player") then
				TagHumanoid(Humanoid, CreatorPlayer)
			end
		end
		Humanoid:TakeDamage(8)
	else
		break
	end
	wait(1.2)
end

for i, v in pairs(Flames) do
	if v and v.Parent then
		v:Destroy()
	end
end

Humanoid.WalkSpeed = 16

DestroyScript()