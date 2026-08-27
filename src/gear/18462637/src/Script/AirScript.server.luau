--Rescripted by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Part:FindFirstChild("Creator")

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

function Touched(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	
	local CreatorPlayer = (((Creator and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
	local player = Players:GetPlayerFromCharacter(character)
	if CreatorPlayer and player and (CreatorPlayer == player or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	local WindEffect = Hit:FindFirstChild("WindEffect")
	if WindEffect then
		return
	end
		local Direction = Part.Velocity.unit

		local Gravity = 196.20
		local Force = 75
		local Mass = math.sqrt(Hit:GetMass())
		Mass = ((Mass > 64 and 64) or Mass)
		
		WindEffect = Instance.new("BodyVelocity")
		WindEffect.Name = "WindEffect"
		WindEffect.P = 125
		WindEffect.maxForce = (Vector3.new(1, 1, 1) * Gravity * Mass * 10)
		WindEffect.velocity = ((Direction * Force) + Vector3.new(0, 30, 0))
		
		Debris:AddItem(WindEffect, 0.5)
		WindEffect.Parent = Hit
		Debris:AddItem(Part, 0)
		Part:Destroy()
end

Part.Touched:connect(Touched)

Debris:AddItem(Part, 2)

