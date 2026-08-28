local Tool = script.Parent 
local Eagle = Tool.Handle

Tool.Enabled = true

local eagleSound

local vCharacter

local damage = 35

local connection

local eagleClone
local count = 0

local torsoFire

local AOE = Vector3.new(10, 10, 10)

local redCliffItems = {"Phoenix Bow", "Phoenix Axe", "PhoenixSword", "PhoenixClub"}

function blow(hit)	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			local joint = rightArm:FindFirstChild("RightGrip")
			if joint ~= nil and (joint.Part0 == Eagle or joint.Part1 == Eagle) then 				
				tagHumanoid(humanoid, vPlayer)				
				humanoid:TakeDamage(damage)
				if eagleClone then eagleClone:Remove() end
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end		
	end	
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end			
	end
end

function attack()
	print("Found Damage")
	if vCharacter then
		myHumanoid = vCharacter:FindFirstChild("Humanoid") 
		myTorso = vCharacter:findFirstChild("Torso")
		if myHumanoid and myHumanoid.Health >= 0 then 			
			parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - AOE, myTorso.Position + AOE), vCharacter, 100)
			for i = 1, #parts do 
				tempChar = parts[i].Parent
				tempHumanoid = tempChar:FindFirstChild("Humanoid")
				if tempHumanoid and count == 0 then 
					print("Found Enemy")

					eagleClone = Eagle:Clone()
					eagleClone.Parent = game.Workspace
					Eagle.Transparency = 1.0
					
					fire = Instance.new("Fire")
					fire.Parent = eagleClone
					eagleClone.CFrame = CFrame.new(Eagle.Position, tempChar.Head.Position)
					eagleClone.Velocity = (tempChar.Torso.Position - myTorso.Position).unit * 35.0
								
				   local eagleFloat = Instance.new("BodyForce") 
				   eagleFloat.force = Vector3.new(0.0, eagleClone:GetMass() * 196.1, 0.0) 
				   eagleFloat.Parent = eagleClone		

					count = 1
					eagleClone.Touched:connect(blow)					
				end
			end
		end
		wait(1.0)
		Eagle.Transparency = 0.0
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false 

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:findFirstChild("Humanoid")
	if myHumanoid == nil then
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then
		return
	end

	eagleSound = Tool:findFirstChild("EagleSound")
	if eagleSound then eagleSound:Play() end	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	child = vPlayer.Backpack:GetChildren()
	for i = 1, #child do 
		print(child[i].Name)
		for j = 1, #redCliffItems do 		
			if child[i].Name == redCliffItems[j] then 
				ratio = myHumanoid.Health/myHumanoid.MaxHealth
				myHumanoid.MaxHealth = 200
				myHumanoid.Health = ratio * 200
				myHumanoid.WalkSpeed = 20		
				torsoFire = Instance.new("Fire")
				torsoFire.Heat = 1.0
				torsoFire.Size = 1.0
				torsoFire.Parent = myTorso
			end
		end
	end	
	healthConnect = myHumanoid.HealthChanged:connect(attack)	
	wait(5.0)	
	if healthConnect then healthConnect:disconnect() end
	if fire then fire:Remove() end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	myHumanoid.Health = ratio * 100

	wait(2.5)
	Tool.Enabled = true
	if torsoFire then torsoFire:Remove() end
	count = 0
end

function onEquipped()
end

function onUnequipped()
	if vCharacter  then 
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then 
			ratio = myHumanoid.Health/myHumanoid.MaxHealth
			myHumanoid.MaxHealth = 100
			myHumanoid.Health = ratio * 100
			myHumanoid.WalkSpeed = 16
		end
	end
	if connection then connection:disconnect() end
	if eagleClone then eagleClone:Remove() end

	if torsoFire then torsoFire:Remove() end

	count = 0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
