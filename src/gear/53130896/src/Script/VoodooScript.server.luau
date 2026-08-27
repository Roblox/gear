--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
Tag = script:FindFirstChild("Debuff")
Creator = script:FindFirstChild("creator")

Debris = game:GetService("Debris")

Duration = 5

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

if Torso then
	if Tag.Value == "Fire" then
		local Fire = Instance.new("Fire")
		Fire.Parent = Torso
		local StartTick = tick()
		while (tick() - StartTick) < Duration do
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, Creator.Value)
			Humanoid:TakeDamage(5)
			wait(1)
		end
		if Fire and Fire.Parent then
			Fire:Destroy()
		end
	else 
		local Ice = Instance.new("Fire")
		Ice.Color = Color3.new(0, 0, 0.75)
		Ice.Parent = Torso
		local StartTick = tick()
		while (tick() - StartTick) < Duration do
			Humanoid.WalkSpeed = 8
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, Creator.Value)
			Humanoid:TakeDamage(2)
			wait(1)
		end
		if Ice and Ice.Parent then
			Ice:Destroy()
		end
	end
end

Humanoid.WalkSpeed = 16

wait(1)

script:Destroy()
