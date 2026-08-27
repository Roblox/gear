--Made by Luckymaxer

Grenade = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ExplosionGui = script:WaitForChild("ExplosionGui")
DamageScript = script:WaitForChild("DamageScript")
Creator = Grenade:WaitForChild("Creator")

Sounds = {
	Explode = Grenade:WaitForChild("Explode"),
}

Rate = (1 / 60)
Damage = 60

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Explode()
	local IgnoreObjects = {Grenade}
	local Radius = 7.5
	if Creator and Creator.Value and Creator.Value.Parent then
		for i, v in pairs(Players:GetPlayers()) do
			if v ~= Creator.Value and IsTeamMate(Creator.Value, v) and v.Character then
				table.insert(IgnoreObjects, v.Character)
			end
		end
	end
	local Humanoids = {}
	local NegativePartRadius = Vector3.new(Radius, Radius, Radius)
	local PositivePartRadius = Vector3.new(Radius, Radius, Radius)
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Grenade.Position - NegativePartRadius, Grenade.Position + PositivePartRadius), IgnoreObjects, 100)
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local character = v.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not CheckTableForInstance(Humanoids, humanoid) then
				table.insert(Humanoids, humanoid)
			end
		end
	end
	for i, v in pairs(Humanoids) do
		if v and v.Parent and v.Health > 0 then
			UntagHumanoid(v)
			TagHumanoid(v, Creator)
			v:TakeDamage(Damage)
			local character = v.Parent
			local DamageScriptClone = character:FindFirstChild(DamageScript.Name)
			if not DamageScriptClone then
				DamageScriptClone = DamageScript:Clone()
				DamageScriptClone.Disabled = false
				DamageScriptClone.Parent = character
			end
		end
	end
	wait(Rate)
end


wait(3)

Grenade.Anchored = true
Grenade.CanCollide = false
Grenade.Transparency = 1

Sounds.Explode:Play()

Spawn(Explode)

Explosion = ExplosionGui:Clone()
Explosion.Size = UDim2.new(1, 0, 1, 0)
Explosion.Enabled = true
Debris:AddItem(Explosion, 2)
Explosion.Parent = Grenade
for i = 1, 7 do
	Explosion.Size = (Explosion.Size + UDim2.new(2, 0, 2, 0))
	wait(Rate)
end