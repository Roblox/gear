--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))
DeathEffect = script:FindFirstChild("DeathEffect")

Creator = script:FindFirstChild("Creator")

DisplayParts = {}

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

function DestroyScript()
	Debris:AddItem(script, 0.5)
	return
end

if not Humanoid then
	DestroyScript()
	return
end

Player = Players:GetPlayerFromCharacter(Character)

for i = 1, 5 do
	if Player then
		Humanoid:UnequipTools()
	else
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
	end
	
	local Objects = Functions.Redesign(Character)
	
	for i, v in pairs(Objects) do
		v = v.Object
		if v:IsA("BasePart") then
			if v.Transparency < 1 then
				table.insert(DisplayParts, v)
			end
		elseif v:IsA("Decal") or v:IsA("Texture") then
			if v.Transparency < 1 then
				table.insert(DisplayParts, v)
			end
		end
	end
	local SameTeam = false
	UntagHumanoid(Humanoid)
	if Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") then
		if not Player or not IsTeamMate(Creator.Value, Player) then
			TagHumanoid(Humanoid, Creator.Value)
		else
			SameTeam = true
		end
	end
	if not SameTeam then
		Humanoid:TakeDamage(8)
		if Humanoid.Health <= 0 and DeathEffect then
			local DeathEffectScript = DeathEffect:Clone()
			DeathEffectScript.Disabled = false
			DeathEffectScript.Parent = Character
		end
	end
	if Humanoid.Health > 0 then
		--wait(0.1)
		--Delay(0.1, (function()
			local FadeRate = 2
			local FadeAmount = 0.95
			for i = 1, ((1 - Functions.DarkProperties.All.Transparency) * (FadeAmount * FadeRate)) do
				for ii, vv in pairs(DisplayParts) do
					if vv and vv.Parent then
						vv.Transparency = (vv.Transparency + (FadeAmount / FadeRate))
					end
				end
				wait(Rate)
			end
			wait(0.5)
			for i = 1, ((1 - Functions.DarkProperties.All.Transparency) * (FadeAmount * FadeRate)) do
				for ii, vv in pairs(DisplayParts) do
					if vv and vv.Parent then
						vv.Transparency = (vv.Transparency - (FadeAmount / FadeRate))
					end
				end
				wait(Rate)
			end	
			for i, v in pairs(Objects) do
				local Object = v.Object
				for ii, vv in pairs(v.FakeObjects) do
					if vv and vv.Parent then
						vv:Destroy()
					end
				end
				pcall(function()
					for ii, vv in pairs(v.Properties) do
						pcall(function()
							Object[ii] = vv
						end)
					end
					Object.Parent = v.Parent
				end)
			end
		--end))
		wait(0.5)
	end
end

DestroyScript()