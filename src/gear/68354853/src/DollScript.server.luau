local Tool = script.Parent 
local Doll = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 

local activeSound

local equipped

local assetAwarded = false 

local debris = game:GetService("Debris")

function returnToDefault()
	wait(4.0)
	Tool.GripPos = Vector3.new(0, 0, -1)    
end 

local dog = Instance.new("Part")
dog.Name = "Dog"
dog.FormFactor = 3
dog.Size = Vector3.new(1.5, 1.5, 1.5)
dog.CanCollide = true 

local dogMesh = Instance.new("SpecialMesh")
dogMesh.MeshId = "http://www.roblox.com/asset/?id=68340830"
dogMesh.TextureId = "http://www.roblox.com/asset/?id=68331520"
dogMesh.Parent = dog 

local float = Instance.new("BodyForce")
float.force = Vector3.new(0, dog:GetMass() * 102, 0)
float.Parent = dog 

local activeSound

function blow(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")	
		if humanoid and myHumanoid and humanoid ~= humanoid then 
			humanoid:TakeDamage(15)
		end 
		local fire = Instance.new("Fire")
		fire.Parent = hit 
		debris:AddItem(fire, 5)
	end 
end 

-- He likes to throw things 
function annoy()
	while equipped and myTorso and myHumanoid do 
		tick()		
		local randomElement = math.random(1, 100)	
		print(randomElement)
		local foundPlayer = false 
		if randomElement < 40 then
			-- Throw a dog! 
			activeSound = Doll:FindFirstChild("ItsaDog") 
			if activeSound and math.random() < 0.33 then activeSound:Play() end 
			local players = game.Players:GetChildren() 
			for i = 1, #players do 
				if players[i] and players[i].Character and players[i].Character:FindFirstChild("Torso") and players[i] ~= vPlayer then 
					local torso = players[i].Character.Torso 
					local distance = (torso.Position - myTorso.Position).magnitude 
					if distance < 25 then 			
						foundPlayer = false 
						local dogClone = dog:Clone()						
						dogClone.Parent = game.Workspace 
						dogClone.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
						dogClone.Handle.Velocity = (torso.Position - myTorso.Position).unit * 40.0 
						debris:AddItem(dogClone, 5)		
						break 
					end 
				end
			end
			if foundPlayer == false then 
				local dogClone = dog:Clone()						
				dogClone.Parent = game.Workspace 
				dogClone.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
				dogClone.Velocity = myTorso.CFrame.lookVector * 30.0 								
				debris:AddItem(dogClone, 10)		
			end 
		else		
			local players = game.Players:GetChildren() 
			for i = 1, #players do 
				if players[i] and players[i].Character and players[i] ~= vPlayer then 
					local torso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")
					if torso then 
						local distance = (torso.Position - myTorso.Position).magnitude 
						if distance < 25 then 
							foundPlayer = true 
							local asset = game:GetService("InsertService"):LoadAsset(29939404):GetChildren()[1]
							print(asset, #asset:GetChildren())
							if asset and asset:FindFirstChild("Handle") then 
								asset = asset.Handle
								asset.Parent = game.Workspace
								asset.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
								asset.Velocity = (torso.Position - myTorso.Position).unit * 40.0 
								local fire = Instance.new("Fire")
								fire.Parent = asset
								local ff = float:Clone()
								ff.force = Vector3.new(0, asset:GetMass() * 102, 0)
								ff.Parent = asset
								if randomElement > 73 then 
									asset.Touched:connect(blow) 
									activeSound = Doll:FindFirstChild("LightFire")
									if activeSound and math.random() < 0.3 then activeSound:Play() end 
								else 
									activeSound = Doll:FindFirstChild("HereItGoes")
									if activeSound and math.random() < 0.3 then activeSound:Play() end 
								end 
								debris:AddItem(asset, 5)						 
								break 
							end 						
						end 
					end 
				end
			end
			if foundPlayer == false then 			
				local asset = game:GetService("InsertService"):LoadAsset(29939404):GetChildren()[1]
				print(asset, #asset:GetChildren())
				if asset and asset:FindFirstChild("Handle") then 	
					asset = asset.Handle
					asset.Parent = game.Workspace
					asset.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
					asset.Velocity = myTorso.CFrame.lookVector * 30.0 
					local fire = Instance.new("Fire")
					fire.Parent = asset
					local ff = float:Clone()
					ff.force = Vector3.new(0, asset:GetMass() * 102, 0)
					ff.Parent = asset					
					if randomElement > 73 then 
						asset.Touched:connect(blow) 
						activeSound = Doll:FindFirstChild("LightFire")
						if activeSound and math.random() < 0.3 then activeSound:Play() end 
					else 
						activeSound = Doll:FindFirstChild("HereItGoes")
						if activeSound and math.random() < 0.3 then activeSound:Play() end 
					end 
					debris:AddItem(asset, 5)
				end 
			end 
		end 			
		wait(7.5)
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	tick()

	if math.random() < 0.33 then 
		Tool.GripPos = Vector3.new(1.5, 1.5, -2.75)
	elseif math.random() < 0.67 then 
		Tool.GripPos = Vector3.new(0, 1.8, -1.7)
	else 
		Tool.GripPos = Vector3.new(3, 1.8, -1.7)
	end 

	if math.random() < 0.65 then 
		activeSound = Doll:FindFirstChild("Airhorn")
		if activeSound then activeSound:Play() end
	end 

	coroutine.resume(coroutine.create(returnToDefault))

	wait(6.0)
	Tool.Enabled = true 
end

function onEquipped()
	equipped = true
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	coroutine.resume(coroutine.create(annoy))
end

function onUnequipped()
	if activeSound then activeSound:Stop() end
	equipped = false 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)