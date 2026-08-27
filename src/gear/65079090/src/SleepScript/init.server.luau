local vCharacter = script.Parent

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
local backpack = nil

if vPlayer then
	backpack = vPlayer:FindFirstChild("Backpack")
end

local sleeping = false 

local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid") 

local debris = game:GetService("Debris")

if myTorso == nil or myHumanoid == nil then 
	script:Remove()
end

while script:FindFirstChild("Sleepy") == nil do
	wait()
end

local toolInHand = nil
local backpackItems = {}
local zStorage = {}

local sleepVal = script.Sleepy
sleepVal.Changed:connect(function() 
	if sleepVal and sleepVal.Value > 5 and not sleeping then 

		local duration = 2.0
		if script:FindFirstChild("Duration") and script.Duration.Value > 0 then 
			duration = script.Duration.Value			
		end

		backpackItems = {} 
		toolInHand = nil
		sleeping = true 
		sleepVal.Value = 0 
		
		myHumanoid.WalkSpeed = 0.0 
		myTorso.Anchored = true 

		local children = vCharacter:GetChildren()
		for i = 1, #children do 
			if children[i] and children[i].className == "Tool" then 
				toolInHand = children[i]
				toolInHand.Parent = nil
			end
		end

		if backpack then 
			local bChildren = backpack:GetChildren()
			for j = 1, #bChildren do 
				if bChildren[j] then 
					table.insert(backpackItems, bChildren[j])
					bChildren[j].Parent = nil
				end
			end
		end
		

		while duration > 0 do 					
				
			local z = Instance.new("Part")				
			z.Name = "Z" 
			z.CFrame = (vCharacter.Head.CFrame + Vector3.new(0, 1, 0)) * CFrame.Angles(math.pi/2, 0, 0)
			z.CanCollide = false 
			
			local zMesh = Instance.new("SpecialMesh")
			zMesh.Parent = z
			zMesh.MeshId = "http://www.roblox.com/asset/?id=65046096"
			zMesh.TextureId = "http://www.roblox.com/asset/?id=65020347"
			zMesh.Scale = Vector3.new(0.05, 0.05, 0.05)

			local floatForce = Instance.new("BodyForce")
			floatForce.force = Vector3.new(0, z:GetMass() * 208, 0)
			floatForce.Parent = z 	
		
			z.Parent = game.Workspace

			table.insert(zStorage, z)

			coroutine.resume(coroutine.create(function() 
				while z and zMesh and #zStorage > 0 do 					
					zMesh.Scale = zMesh.Scale + Vector3.new(0.005, 0.005, 0.005)
					wait(0.05)
				end
			end)) 

			wait(0.25)
			duration = duration - 0.25	

			debris:AddItem(z, 1)			
		end

		myHumanoid.WalkSpeed = 16.0
		myTorso.Anchored = false 
		if toolInHand then toolInHand.Parent = vCharacter  end
		for a = 1, #backpackItems do 
			if backpackItems[a] then 
				backpackItems[a].Parent = backpack 
			end
		end
		zStorage = {} -- free memory
	
		wait(2.0)
		sleeping = false 
	end 
end) 

coroutine.resume(coroutine.create(function() 
	wait(60) 	
	if sleeping then
		wait(1.0)
		myHumanoid.WalkSpeed = 16.0
		myTorso.Anchored = false 
		if toolInHand then toolInHand.Parent = vCharacter  end
		for a = 1, #backpackItems do 
			if backpackItems[a] then 
				backpackItems[a].Parent = backpack 
			end
		end
		zStorage = {} -- free memory
	end
	script:Remove() 
end))
