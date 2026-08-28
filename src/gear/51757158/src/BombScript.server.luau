wait(0.5)



Tripmine = script.Parent
Tripmine.Transparency = 0.9

boom = Instance.new("Sound") 
boom.Parent = Tripmine
boom.Volume = 1 
boom.SoundId = "http://www.roblox.com/asset/?id=51753289" 
boom.Name = "boom" 

wait(1.5)

local humanoids = {}

local mineAOE = Vector3.new(10.0, 10.0, 10.0)

local connection

--Tripmine.CFrame = Tripmine.CFrame * CFrame.Angles(math.pi/2, 0, 0)

function blow(hit)
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then 
			if connection then connection:disconnect() end
			tag = Tripmine:FindFirstChild("creator")
			if tag then 
				tag.Parent = humanoid
			end

			if boom then boom:Play() end

			part = Instance.new("Part")
			part.Parent = game.Workspace
			part.Position = Tripmine.Position 
			part.Transparency = 1.0
			part.CanCollide = false

			fire = Instance.new("Fire")
			fire.Parent = part
			fire.Size = 25
			fire.Color = Color3.new(0.0, 0.0, 1.0)
			fire.SecondaryColor = Color3.new(0.0, 0.0, 1.0)
			fire.Heat = 30

			humanoid:TakeDamage(100)
			parts = game.Workspace:FindPartsInRegion3(Region3.new(Tripmine.Position - mineAOE, Tripmine.Position + mineAOE), nil, 100)
			for i = 1, #parts do 
				tempChar = parts[i].Parent
				tempHumanoid = tempChar:FindFirstChild("Humanoid")				
				if tempHumanoid then table.insert(humanoids, tempHumanoid) 	end
			end

			for i = 1, #humanoids do if humanoids[i] ~= humanoid then humanoids[i]:TakeDamage(12) end end
			wait(1.0)
			if tag then tag:Remove() end
			if part then part:Remove() end
			if fire then fire:Remove() end

			Tripmine:Remove() 
			
		end
	end
end

connection = Tripmine.Touched:connect(blow)


wait(120)

Tripmine:Remove() 
