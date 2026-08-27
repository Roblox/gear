--Made by Luckymaxer

Star = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Star:WaitForChild("Creator")
HitSound = Star:WaitForChild("HitSound")

Damage = 25
Stuck = false

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

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

Star.Touched:connect(function(Hit)
	if Hit and Hit.Parent and not Stuck then
		local Character, Humanoid = FindCharacterAncestor(Hit.Parent)
		if ((Character and Character ~= Creator.Value.Character and Humanoid and Humanoid.Health > 0) or not Character) then
			if Hit.Name ~= "Handle" and Hit.Name ~= "Effect" then
				Stuck = true
				local Weld = Instance.new("Weld")
				Weld.Part0 = Hit
				Weld.Part1 = Star
				Weld.C0 = Hit.CFrame:toObjectSpace(Star.CFrame)
				Weld.Parent = Star
				local BodyForce = Star:FindFirstChild("BodyForce")
				if BodyForce then
					BodyForce:Destroy()
				end
				HitSound:Play()
				if Character and Character ~= Creator.Value.Character and Humanoid and Humanoid.Health > 0 then
					UntagHumanoid(Humanoid)
					TagHumanoid(Humanoid, Creator.Value)
					Humanoid:TakeDamage(Damage)
				end
				wait(5)
				Star:Destroy()
			end
		end
	end
end)