local Tool = script.Parent 
local Dragon = Tool.Handle

local prevHealth = 100

local damage = 17

local healthConnect

local vCharacter
local myTorso 
local myHumanoid 

local attacking 

Tool.Enabled = true 

local connection

local debris = game:GetService("Debris")

local fireball = Instance.new("Part")
fireball.FormFactor = 3
fireball.Shape = "Ball"
fireball.Size = Vector3.new(1.1, 1.1, 1.1)
fireball.CanCollide = false
fireball.Transparency = 0.0

local bullet = Instance.new("SpecialMesh")
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032"
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568"
bullet.Parent = fireball
bullet.Scale = Vector3.new(2.5, 2.5, 2.5) 

local fire = Instance.new("Fire")
fire.Parent = fireball 
fire.Color = Color3.new(244/255, 164/255, 96/255)
fire.SecondaryColor = Color3.new(244/255, 164/255, 96/255)

Dragon:WaitForChild("LeftWing")
Dragon:WaitForChild("RightWing")
Dragon:WaitForChild("LeftWingWeld")
Dragon:WaitForChild("RightWingWeld")
Dragon:WaitForChild("LeftLegWeld")
Dragon:WaitForChild("RightLegWeld")
Dragon:WaitForChild("RightArmWeld")
Dragon:WaitForChild("LeftArmWeld")

local lWing = Dragon.LeftWing
local rWing = Dragon.RightWing 
local lWeld = Dragon.LeftWingWeld
local rWeld = Dragon.RightWingWeld 
local raWeld = Dragon.RightArmWeld 
local laWeld = Dragon.LeftArmWeld 
local llWeld = Dragon.LeftLegWeld 
local rlWeld = Dragon.RightLegWeld

local drakone = Instance.new("Model")
drakone.Name = "Drakone" 

local drakoneClone 

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
	print("Flappy")
	local lWeld 
	local rWeld
	local sign = 1 
	local count = 0 

	local initLC1 
	local initRC1

	if drakone then 
		local dragon = drakone:FindFirstChild("Dragon")
		if dragon then 
			print(1) 
			lWeld = dragon:FindFirstChild("LeftWingWeld")
			rWeld = dragon:FindFirstChild("RightWingWeld")
			if lWeld and rWeld then 
				initLC1 = lWeld.C1 
				initRC1 = rWeld.C1 
				while drakone.Parent and drakoneClone and lWeld and rWeld do					
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
end

function setTransparency(value)
	if value == nil then value = 0 end 
	Dragon.Transparency = value 
	local children = Dragon:GetChildren()
	for i = 1, #children do
		if children[i] and children[i]:IsA("BasePart") then 
			children[i].Transparency =  value
		end 
	end 
end 

function blow(fireball, hit)     
	if hit and hit.Parent and fireball then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		local vCharacter = Tool.Parent     
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)     
		local myHumanoid = vCharacter:FindFirstChild("Humanoid")     
		if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then							
			tagHumanoid(humanoid, vPlayer)                    
			humanoid:TakeDamage(damage)	  			
		end    
	end 
end

function animateBody()
	if drakone.Parent and drakoneClone then 
		local ra = drakoneClone:FindFirstChild("RightArmWeld")
		local la = drakoneClone:FindFirstChild("LeftArmWeld")
		
		local rl = drakoneClone:FindFirstChild("RightLegWeld")
		local ll = drakoneClone:FindFirstChild("LeftLegWeld")

		local initRA = ra.C1 
		local initLA = la.C1 
		local initRL = rl.C1 
		local initLL = ll.C1 

		local duration = 1.5 
		local sign = 1

		while duration do 	
			ra.C1 = ra.C1 * CFrame.Angles(sign * math.pi/360, 0, 0)
			la.C1 = la.C1 * CFrame.Angles(sign * math.pi/360, 0, 0)
			rl.C1 = rl.C1 * CFrame.Angles(-sign * math.pi/360, 0, 0)
			ll.C1 = ll.C1 * CFrame.Angles(-sign * math.pi/360, 0, 0)			
			duration = duration - wait() 		
		end 
		
		print("Resetting")
		ra.C1 = initRA 
		la.C1 = initLA
		rl.C1 = initRL 
		ll.C1 = initLL
	end 
end

function shoot(direction)
	if drakoneClone == nil then return end
	shootSound = Tool:FindFirstChild("ShootSound")
	shooting = true 
	--coroutine.resume(coroutine.create(animateBody))
	--wait(1.25)
	if shootSound then shootSound:Play() end	

	local spawnPos = drakoneClone.Position + direction * 3.0

	local fireballC = fireball:Clone()
	fireballC.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	fireballC.Velocity = direction * 60.0

	local float = Instance.new("BodyForce")
	float.force = Vector3.new(0, fireballC:GetMass() * workspace.Gravity, 0)
	float.Parent = fireballC

	local fire = Instance.new("Fire")
	fire.Parent = fireballC
	fire.Color = Color3.new(0, 153/255, 0)
	fire.SecondaryColor = Color3.new(102/255, 51/255, 0)

	fireballC.Parent = game.Workspace

	fireballC.Touched:connect(function(hit) blow(fireballC, hit) end)
	debris:AddItem(fireballC, 5.0)     
	wait(1.0)
	shooting = false 
end 

function attack()
	if myHumanoid == nil then return end
	if myHumanoid.Health < prevHealth and drakoneClone and not attacking and myTorso then
			prevHealth = myHumanoid.Health
			local tag = myHumanoid:FindFirstChild("creator")
			if tag and tag.Value then
				local playr = tag.Value
				if playr:IsA("Player") then
					local character = playr.Character
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					if character and torso then
					attacking = true
					print(1)
					if drakoneClone then 
						for i = 1, 6 do
							shoot((torso - drakoneClone.Position).unit)                         
							wait(0.2)
						end 
					end 
					attacking = false
				end
			end
		end
	end
end


function follow()     
	local stopped = false
	local bv
	if drakoneClone then bv = drakoneClone:FindFirstChild("FollowBV") end
	while drakoneClone and drakone and myTorso and bv do
		local distance = (myTorso.Position - drakoneClone.Position).magnitude
		if distance > 5.0 then      
			stopped = false
			if drakoneClone then 
				drakoneClone.CFrame = CFrame.new(drakoneClone.Position, myTorso.Position + Vector3.new(0, drakoneClone.Position.Y - myTorso.Position.Y, 0)) 			
			--	if drakoneClone then bv.Parent = drakoneClone end 
				if distance > 8.0 then
					bv.velocity = (myTorso.Position - drakoneClone.Position).unit * 20.0 + Vector3.new(0, 2, 0)
				else
					bv.velocity = (myTorso.Position - drakoneClone.Position).unit * 20.0 * (distance/24) + Vector3.new(0, 2, 0)
				end
			end 
		else                
			if not stopped then
				stopped = true
				bv.velocity = Vector3.new(0, 0, 0)
				drakoneClone.Velocity = Vector3.new(0, 0, 0)
			--	bv:Destroy()
			end
		end
		wait()
	end
	if drakone then drakone:Destroy() end 
	if drakoneClone then drakoneClone:Destroy() end 
	SetTransparency(0)
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	if drakone.Parent ~= nil and drakoneClone then 
		local target = myHumanoid.TargetPoint 
		local direction = (target - drakoneClone.Position).unit 
		shoot(direction)
	else 	

		drakone = Instance.new("Model")
		drakone.Name = "Drakone" 	

		drakoneClone = Dragon:Clone()
		drakoneClone.Name = "Dragon"
		drakoneClone.Parent = drakone 

		local floatForce = Instance.new("BodyForce") 
		floatForce.force  = Vector3.new(0, getMassOfObject(Tool) * workspace.Gravity, 0) 
		floatForce.Name = "Float"
		floatForce.Parent = drakoneClone

		local bv = Instance.new("BodyVelocity")
		bv.Name = "FollowBV"
		bv.Parent = drakoneClone
		bv.maxForce = Vector3.new(50000, 50000, 50000)
		bv.P = 50000 
			
		drakone.Parent = vCharacter 

		drakone:MoveTo(myTorso.Position + myTorso.CFrame.lookVector * 5.0) 

		setTransparency(1)

		healthConnect = myHumanoid.HealthChanged:connect(attack)    

		coroutine.resume(coroutine.create(follow))

		coroutine.resume(coroutine.create(function()
			wait(75.0)
			if drakone then 
				if drakone:FindFirstChild("Dragon") then 
					drakone.Dragon:Destroy() 
					Tool.Enabled = false 
					wait(9.0)
					Tool.Enabled = true
					setTransparency(0)
				end 
			end 
		end))

		coroutine.resume(coroutine.create(flapWings))
	end 	

	wait(4)
	Tool.Enabled = true		
end 

function onEquipped()
	-- Horrendous is the name, for these checks
	if lWeld then 
		lWeld.Parent = Dragon
	end 
	if rWeld then 
		rWeld.Parent = Dragon 
	end 

	if rlWeld then 
		rlWeld.Parent = Dragon 
	end 
	
	if llWeld then 
		llWeld.Parent = Dragon
	end 

	if raWeld then 
		raWeld.Parent = Dragon 
	end 

	if laWeld then 
		laWeld.Parent = Dragon 
	end 

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
end 

function onUnequipped()
	if drakoneClone then drakoneClone:Destroy() end
	if drakone.Parent then drakone:Destroy() end
	setTransparency(0)
	prevHealth = 100
end 

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

