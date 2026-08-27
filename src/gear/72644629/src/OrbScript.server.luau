local Tool = script.Parent 
local Orb = Tool.Handle

local vCharacter
local myHumanoid
local myTorso 

Tool.Enabled = true 

local orbClone 

local tempTorsos = {}

local lightningDamage = 19
local lightningSound 

local debris = game:GetService("Debris")

function shootLightning()     
	local AOE = Vector3.new(14, 14, 14)
	tempTorsos= {}
	local playSound 
	if myTorso and orbClone and orbClone.Parent then
		local parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - AOE, myTorso.Position + AOE), vCharacter, 100)
		for i = 1, #parts do
			if parts and parts[i].Parent then
				local character = parts[i].Parent
				if character:FindFirstChild("Humanoid") then
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					if torso and not tempTorsos[torso] then
						playSound = true 
						character.Humanoid:TakeDamage(lightningDamage)
						character.Humanoid.Sit = true 
						tempTorsos[torso] = torso
					end
				end
			end
		end

		if playSound then 
			lightningSound = Orb:FindFirstChild("LightningSound")
			if lightningSound then lightningSound:Play() end 
		end 

		for i, v in pairs(tempTorsos) do
			local lightningPart = Instance.new("Part")
			lightningPart.Name = "Lightning"
			lightningPart.CanCollide = false 
			lightningPart.Size = Vector3.new(1, 1, 1)
			lightningPart.Anchored = true

			local lightningMesh = Instance.new("SpecialMesh")
			lightningMesh.Scale = Vector3.new(1, 0.4, 1)
			lightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
			lightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
			lightningMesh.Parent = lightningPart

			lightningPart.Size = Vector3.new(2, 2, (orbClone.Position - v.Position).magnitude + 1)
			local tempCFrame = CFrame.new(orbClone.Position, v.Position)
			lightningPart.CFrame = tempCFrame + tempCFrame:vectorToWorldSpace(Vector3.new(1, 1, 1) - lightningPart.Size/2.0)
			lightningMesh.Scale = Vector3.new(1, 1, lightningPart.Size.Z * 1/14)

			lightningPart.Parent = game.Workspace

			debris:AddItem(lightningPart, 0.75)
		end
	end
end 

function follow()          	
	local count = 0
	local stopped = false  
	local duration = 35.0
	while orbClone and orbClone.Parent and myTorso and duration > 0 do           
		tick()		
		count = count + 1
		for i = 1, 30 do      
			if orbClone then                    
				orbClone.CFrame = (CFrame.Angles(-math.pi/2, 0, math.pi) + myTorso.CFrame.p + (CFrame.Angles(0, 2 * i * math.pi/30, 0) * myTorso.CFrame.lookVector * 5.0))               
			end
			wait()
			duration = duration - wait() 
		end    
		shootLightning() 
	end   
	if orbClone then orbClone:Destroy() end 
	wait(12.5)
	Tool.Enabled = true 
	Orb.Transparency = 0.0
end


function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	if not orbClone or not orbClone.Parent then 	
		Tool.Enabled = false 
		orbClone = Orb:Clone() 
		Orb.Transparency = 1.0
		orbClone.Parent = vCharacter 
		orbClone.Anchored = true 
		coroutine.resume(coroutine.create(follow)) 	
	end 	
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end 

function onUnequipped()
	if orbClone then orbClone:Destroy() end 
	Orb.Transparency = 0.0
	if lightningSound then lightningSound:Stop() end 
	tempTorsos = {}
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
