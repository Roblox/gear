--Made by Luckymaxer

Tool = script.Parent 
Handle = Tool:WaitForChild("Handle")

Tool.Enabled = true 

connection = nil

BirdSounds = {152092820, 152092841, 152092862}

debris = game:GetService("Debris")

fire = Instance.new("Fire")
fire.Parent = fireball 
fire.Color = Color3.new(244/255, 164/255, 96/255)
fire.SecondaryColor = Color3.new(244/255, 164/255, 96/255)

lWing = Handle:WaitForChild("LeftWing")
rWing = Handle:WaitForChild("RightWing")

local Bird = Instance.new("Model")
Bird.Name = "Bird" 

local BirdClone 

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1) 
	end
end


function getMassOfObject(obj)
	local children 
	local mass = 0
	if type(obj) == "userdata" then 		
		children = obj:GetChildren() 	 
	elseif type(obj) == "table" then 
		children = obj 
	end 
	if children then 
		for i = 1, #children do 
			if children[i]:IsA("BasePart") then 
				mass = mass + children[i]:GetMass()
			end 
			if #children[i]:GetChildren() > 1 then 
				mass = mass + getMassOfObject(children[i])
			end 
		end 
	end  	
	return mass
end 

function flapWings()
	local lWeld 
	local rWeld
	local sign = 1 
	local count = 0 

	local initLC1 
	local initRC1

	if BirdClone then
		lWeld = BirdClone:FindFirstChild("LeftWingWeld")
		rWeld = BirdClone:FindFirstChild("RightWingWeld")
		if lWeld and rWeld then 
			initLC1 = lWeld.C1 
			initRC1 = rWeld.C1 
			while BirdClone.Parent and lWeld and rWeld do			
				lWeld.C1 = lWeld.C1 * CFrame.Angles(0, 0, -sign * math.pi/30) 
				rWeld.C1 = rWeld.C1 * CFrame.Angles(0, 0, sign * math.pi/30) 
				count = count + 1
				if count > 6 then 
					sign = sign * -1 
					count = count%6					
				end 
				wait(0.1)
			end 
		end 
	end 
end

function follow()     
	local stopped = false
	local bv
	if BirdClone then bv = BirdClone:FindFirstChild("FollowBV") end
	while BirdClone and Bird and myTorso and bv do
		local distance = (myTorso.Position - BirdClone.Position).magnitude
		if distance > 5.0 then      
			stopped = false
			if BirdClone then 
				BirdClone.CFrame = CFrame.new(BirdClone.Position, myTorso.Position + Vector3.new(0, BirdClone.Position.Y - myTorso.Position.Y, 0)) 			
				if BirdClone then bv.Parent = BirdClone end 
				if distance > 8.0 then
					bv.velocity = (myTorso.Position - BirdClone.Position).unit * 20.0 + Vector3.new(0, 2, 0)
				else
					bv.velocity = (myTorso.Position - BirdClone.Position).unit * 20.0 * (distance/24) + Vector3.new(0, 2, 0)
				end
			end 
		else                
			if not stopped then
				stopped = true
				bv.velocity = Vector3.new(0, 0, 0)
				BirdClone.Velocity = Vector3.new(0, 0, 0)
				bv.Parent = nil
			end
		end
		wait()
	end
	if Bird then Bird.Parent = nil end 
	if BirdClone then BirdClone:Destroy() end 
	Handle.Transparency = 0
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	if Bird.Parent ~= nil and BirdClone then 

	else 	

		BirdClone = Handle:Clone()
		BirdClone.Mesh.MeshId = "http://www.roblox.com/asset/?id=152053706"
		BirdClone.Name = "Bird"
		for i, v in pairs(BirdClone:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 0
			end
		end
		BirdClone.Parent = Bird

		local floatForce = Instance.new("BodyForce") 
		floatForce.force  = Vector3.new(0, getMassOfObject(Bird) * 196.1, 0) 
		floatForce.Name = "Float"
		floatForce.Parent = BirdClone

		local bv = Instance.new("BodyVelocity")
		bv.Name = "FollowBV"
		bv.Parent = BirdClone
		bv.maxForce = Vector3.new(50000, 50000, 50000)
		bv.P = 50000 
		
		Bird.Parent = vCharacter 

		Bird:MoveTo(myTorso.Position + myTorso.CFrame.lookVector * 5.0) 

		Handle.Transparency = 1  

		coroutine.resume(coroutine.create(follow))

		--[[coroutine.resume(coroutine.create(function()
			wait(75.0)
			if Bird then 
				if Bird:FindFirstChild("Bird") then 
					Bird.Bird:Destroy() 
					Bird.Enabled = false 
					wait(9.0)
					Bird.Enabled = true
					Handle.Transparency = 0
				end 
			end 
		end))]]

		coroutine.resume(coroutine.create(flapWings))
		
		local Song = BirdClone.Song
		
		Song.SoundId = "http://www.roblox.com/asset?id=" .. BirdSounds[math.random(1, #BirdSounds)]
		Song:Play()
		
		Song.Changed:connect(function()
			if not Song.IsPlaying and Song.Parent then
				Song.SoundId = "http://www.roblox.com/asset?id=" .. BirdSounds[math.random(1, #BirdSounds)]
				Song:Play()
			end
		end)
	end 	

	wait(4)
	Tool.Enabled = true		
end 

function onEquipped()
	-- Horrendous is the name, for these checks
	for i, v in pairs(Handle:GetChildren()) do
		if v:IsA("Weld") then
			v:Destroy()
		end
	end
	lWeld = Instance.new("Weld")
	lWeld.Parent = Handle
	lWeld.Name = "LeftWingWeld"
	lWeld.Part0 = Handle
	lWeld.Part1 = lWing
	lWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	lWeld.C1 = CFrame.new(0.0999999046, -0.299999952, 0.299999952, 0.939692378, -0.241844699, 0.241844699, 0.342020065, 0.664462864, -0.664462864, 0, 0.707106769, 0.707106769)
	lWeld.Parent = Handle
	rWeld = Instance.new("Weld")
	rWeld.Name = "RightWingWeld"
	rWeld.Part0 = Handle
	rWeld.Part1 = rWing
	rWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	rWeld.C1 = CFrame.new(1.1920929e-007, -0.25, 0.299999952, 0.939692378, 0.241844699, -0.241844699, -0.342020065, 0.664462864, -0.664462864, 0, 0.707106769, 0.707106769)
	rWeld.Parent = Handle

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
end 

function onUnequipped()
	if BirdClone then BirdClone:Destroy() end
	if Bird.Parent then Bird.Parent = nil end
	Handle.Transparency = 0
	prevHealth = 100
end 

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

