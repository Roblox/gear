--Made by Luckymaxer

Sphere = script.Parent

Creator = script:WaitForChild("creator")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Sound = Instance.new("Sound")
Sound.Looped = true
Sound.Volume = 0.5
Sound.Pitch = 1
Sound.SoundId = "http://www.roblox.com/asset?id=152092907"
Sound.Parent = Sphere

Sphere.Touched:connect(function(Hit)
	if Hit and Hit.Parent then
		local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
		local Torso = Hit.Parent:FindFirstChild("Torso")
		local Player = Players:GetPlayerFromCharacter(Hit.Parent)

		if ((Player and Player ~= Creator.Value) or not Player) and Humanoid and Humanoid.Health > 0 and Torso then
			
			Humanoid.Sit = true
			Torso.Velocity = CFrame.new(Sphere.Position, Torso.Position).lookVector * 50
			
			for i, v in pairs(Humanoid:GetChildren()) do
				if v:IsA("ObjectValue") and v.Name == "creator" then
					v:Destroy()
				end
			end
			
			local creator = Creator:Clone()
			creator.Value = Creator.Value
			Debris:AddItem(creator, 2)
			creator.Parent = Humanoid
			
			Humanoid:TakeDamage(10)
			
		else
			
			local HitName = string.lower(Hit.Name)
			if (HitName == "bullet" or HitName == "projectile" or HitName == "paintball" or HitName == "pellet" or HitName == "rocket") and Hit:GetMass() < Sphere:GetMass() then

				if Hit and Hit.Parent then
					Hit:Destroy()
				end
				
			end
			
		end
	end
end)

Sound:Play()