--Made by Luckymaxer

Model = script.Parent
Creator = script:FindFirstChild("Creator")
Duration = script:FindFirstChild("Duration")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PoisonDamage = 1

Rate = (1 / 60)

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

function DestroyModel()
	Debris:AddItem(Model, 1)
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Duration then
	DestroyModel()
	return
end

Creator = Creator.Value
Duration = Duration.Value

Character = Creator.Character

if not Character or not Character.Parent then
	DestroyModel()
	return
end

Character.Changed:connect(function()
	if not Character.Parent then
		DestroyModel()
	end
end)

Spawn(function()
	local IgnoreObjects = {Character, Model}
	while Model and Model.Parent do
		local ModelSize = Model:GetModelSize()
		local ModelCFrame = Model:GetModelCFrame()
		local Humanoids = {}
		local NegativePartRadius = Vector3.new((ModelSize.X / 2), (ModelSize.Y / 2), (ModelSize.Z / 2))
		local PositivePartRadius = Vector3.new((ModelSize.X / 2), (ModelSize.Y * 6), (ModelSize.Z / 2))
		local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(ModelCFrame.p - NegativePartRadius, ModelCFrame.p + PositivePartRadius), IgnoreObjects, 100)
		local HumanoidHit = false
		for i, v in pairs(Parts) do
			if v and v.Parent then
				local character = v.Parent
				if character:IsA("Hat") then
					character = character.Parent
				end
				local player = Players:GetPlayerFromCharacter(character)
				if not player or (player and not IsTeamMate(Creator, player)) then
					local humanoid = character:FindFirstChild("Humanoid")
					if not CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
						HumanoidHit = true
					end
				end
			end
		end
		for i, v in pairs(Humanoids) do
			if v and v.Parent and v.Health > 0 then
				UntagHumanoid(v)
				TagHumanoid(v, Creator)
				v:TakeDamage(PoisonDamage)
			end
		end
		wait(Rate)
	end
end)

wait(Duration)

DestroyModel()