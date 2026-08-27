--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FunctionsLibrary = script:FindFirstChild("Functions")
ParticleScript = script:FindFirstChild("ParticleScript")
Fire = script:FindFirstChild("EffectFire")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Sounds = {
	Hit = script:FindFirstChild("Hit"),
}

FadeRate = 0.025
Rate = (1 / 15)

Removing = false

Values = {}
for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function GetCreator()
	local Creator = Values.Creator.Value
	return (((Creator and Creator.Parent and Creator:IsA("Player")) and Creator) or nil)
end

function ManageProjectile(Part)
	local AlreadyHit = false
	local Creator = GetCreator()
	local Type = Part:FindFirstChild("Type")
	local Damage = Part:FindFirstChild("Damage")
	if not Type or not Type:IsA("StringValue") or not Damage or not Damage:IsA("NumberValue") then
		return
	end
	Part.Touched:connect(function(Hit)
		local Creator = GetCreator()
		if not Hit or not Hit.Parent or not Creator or AlreadyHit or Functions.CheckIntangible(Hit) then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player or (player and player ~= Creator and not Functions.IsTeamMate(Creator, player)) then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, Creator)
				humanoid:TakeDamage(Damage.Value)
				if Type.Value == "Fire" then
					local IgniteChance = math.random(1, 2)
					if ParticleScript and Fire and IgniteChance == 1 then
						local EffectFire = Hit:FindFirstChild(Fire.Name)
						if not EffectFire then
							EffectFire = Fire:Clone()
							EffectFire.Enabled = true
							local ParticleScriptCopy = ParticleScript:Clone()
							ParticleScriptCopy.Disabled = false
							ParticleScriptCopy.Parent = EffectFire
							local Duration = Create("NumberValue"){
								Name = "Duration",
								Parent = EffectFire,
							}
						end
						local Duration = EffectFire:FindFirstChild("Duration")
						if Duration and Duration:IsA("NumberValue") then
							Duration.Value = 4
						end
						EffectFire.Parent = Hit
					end
				elseif Type.Value == "Projectile" then
				end
			end
		end
		if Type.Value == "Projectile" then
			AlreadyHit = true
			Part.Name = "Effect"
			Part.Transparency = 1
			Part.CanCollide = false
			Part.Anchored = true
			for i, v in pairs(Part:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			local Sound = Sounds.Hit
			if Sound then
				local SoundCopy = Sound:Clone()
				Debris:AddItem(SoundCopy, 1.5)
				SoundCopy.Parent = Part
				SoundCopy:Play()
			end
			Debris:AddItem(Part, 1.5)
		end
	end)
end

function RemoveModel()
	if Removing then
		return
	end
	local Parts = {}
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
		end
	end
	if #Parts == 0 then
		Removing = true
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
	end
end

if not FunctionsLibrary or not Values.Creator then
	RemoveModel()
	return
end

Functions = require(FunctionsLibrary)

Model.ChildAdded:connect(function(Child)
	if Child:IsA("BasePart") and Child.Name == "Projectile" then
		ManageProjectile(Child)
	end
end)

Model.ChildRemoved:connect(function(Child)
	RemoveModel()
end)

wait(1)

RemoveModel()