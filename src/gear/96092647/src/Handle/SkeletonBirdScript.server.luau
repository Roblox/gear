--SkeletonBird settings are here
local Aggressive = true --SkeletonBird will attack enemies
local SmallDamage = 15
local LargeDamage = 25 --Does more damage while tool is equipped
local AttackRange = 40
local ShortReload = 2 --Shoots faster if given an assigned area to move to
local LongReload = 3
local EquipReloadBonus = -1.25 --Shoots faster when tool is equipped
local AssignmentDuration = 11
local MaxSpeed = 90
local Acceleration = 25
local SubAcceleration = 5 --Relative speed when approaching target
--local SkeletonBirdDuration = 5*60 --Copy of value from ToolScript

local SearchRangeXZ = 35
local SearchRangeY = 15
local ChaseRange = 60


function WaitForChild(parent, child)
	local result = parent:FindFirstChild(child)
	delay(3, function() if not result then print("Probably Stuck", child) end end)
	while not result do
		parent.ChildAdded:wait()
		result = parent:FindFirstChild(child)
	end
	return result
end

local debris = game:GetService("Debris")

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



local fireball = Instance.new("Part")
fireball.FormFactor = 3
fireball.Shape = "Ball"
fireball.Size = Vector3.new(1.0, 1.0, 1.0)
fireball.CanCollide = false
fireball.Transparency = 0.0

local fireballMesh = Instance.new("SpecialMesh")
fireballMesh.MeshId = "http://www.roblox.com/asset/?id=57810032"
fireballMesh.TextureId = "http://www.roblox.com/asset/?id=57809568"
fireballMesh.Parent = fireball
fireballMesh.Scale = Vector3.new(2.0, 2.0, 2.0) 

local SkeletonBird = script.Parent
SkeletonBird.CanCollide = true

local leftWing = WaitForChild(SkeletonBird, "LeftWing")
local rightWing = WaitForChild(SkeletonBird, "RightWing") 
local leftWeld = WaitForChild(SkeletonBird, "LeftWingWeld")
local rightWeld = WaitForChild(SkeletonBird, "RightWingWeld") 
local Owner = WaitForChild(SkeletonBird, "OwnerRef") 
local TargetPoint = WaitForChild(SkeletonBird, "TargetPoint")
local Sound = WaitForChild(SkeletonBird, "Sound")
Sound:Play()

local MoveToPoint = Vector3.new(0,0,0)
local EnemyTarget = nil

local LastAssignment = tick() - 1000


function IsToolEquipped()
	local char = Owner.Value
	if char and char.Parent then
		local refObject = char:FindFirstChild("SkeletonBirdRefObject")
		local tool = char:FindFirstChild("SkeletonBirdPet")
		if refObject and refObject.Value == SkeletonBird.Parent and tool then
			return true
		end
	end
	return false
end



function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1) 
	end
end

function blow(fireball, hit)

	local damage = SmallDamage
	if IsToolEquipped() then
		damage = LargeDamage
	end

	if hit and hit.Parent and fireball then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		local vCharacter = Owner.Value   
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)     
		if humanoid ~= nil and Owner.Value ~= hit.Parent then							
			tagHumanoid(humanoid, vPlayer)                    
			humanoid:TakeDamage(damage)	  			
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

function findTargetNear(point)

end

local shooting = false

function shoot(object)
	print("shooting fireball")
	if SkeletonBird == nil or SkeletonBird.Parent == nil then return false end
	shooting = true 
	local bodyGyro = SkeletonBird:FindFirstChild("BodyGyro")
	local startPosition = SkeletonBird.Position + Vector3.new(0,2,0)
	direction = (object.Position - SkeletonBird.Position).unit
	if bodyGyro then
		bodyGyro.cframe = CFrame.new(startPosition, startPosition + direction)
	end
	wait(.5)
	
	if SkeletonBird == nil or SkeletonBird.Parent == nil or not object then return false end
	local startPosition = SkeletonBird.Position + Vector3.new(0,2,0)

	direction = (object.Position - startPosition).unit

	shootSound = SkeletonBird:FindFirstChild("Sound")
	if shootSound then 
		shootSound.Pitch = .9 
		shootSound.Volume = .8
		shootSound:Play() 
	end	
	


	local spawnPos = startPosition + direction * 4.0

	local fireballC = fireball:Clone()
	fireballC.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	fireballC.Name = "Fireball"
	fireballC.Velocity = direction * 60.0

	local float = Instance.new("BodyForce")
	float.force = Vector3.new(0, fireballC:GetMass() * 196.1, 0)
	float.Parent = fireballC

	local fire = Instance.new("Fire")
	fire.Parent = fireballC
	fire.Color = Color3.new(0, 0, 255)
	fire.SecondaryColor = Color3.new(200, 0, 0)

	debris:AddItem(fireballC, 5.0) 
	fireballC.Parent = game.Workspace
	print("fireball added")

	fireballC.Touched:connect(function(hit) blow(fireballC, hit) end)

	wait(.3)

	shooting = false 
	local reloadTime
	if tick() - LastAssignment < AssignmentDuration then
		reloadTime = ShortReload
	else
		reloadTime = LongReload
	end
	if IsToolEquipped() then
		reloadTime = reloadTime + EquipReloadBonus
	end
	wait(reloadTime - .8)
	return true
end 


function FlapWings()
	print("Flappy")
	local sign = 1 
	local count = 0 

	local initLC1 
	local initRC1

	leftWeld = SkeletonBird:FindFirstChild("LeftWingWeld")
	rightWeld = SkeletonBird:FindFirstChild("RightWingWeld")
	if leftWeld and rightWeld then 
		initLC1 = leftWeld.C1 
		initRC1 = rightWeld.C1 
		while SkeletonBird.Parent and leftWeld and rightWeld do		
			leftWeld.C1 = leftWeld.C1 * CFrame.Angles(0, -sign * math.pi/30, 0 ) 
			rightWeld.C1 = rightWeld.C1 * CFrame.Angles(0, sign * math.pi/30, 0) 
			count = count + 1
			if count > 7 then 
				sign = sign * -1 
				count = count%6					
			end 
			wait(1/15) 
		end 
	end 
end

local MoveDelay = .3
local CircleCounter = 0
function MoveToTarget()
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = SkeletonBird
	bodyVelocity.maxForce = Vector3.new(10000,20000,10000) --Its strong enough to support your weight
	local bodyGyro = Instance.new('BodyGyro')
	bodyGyro.Name = "BodyGyro"
	bodyGyro.maxTorque = Vector3.new(1500,1500,1500) 
	bodyGyro.Parent = SkeletonBird
	while SkeletonBird and SkeletonBird.Parent do
		if Owner.Value == nil or Owner.Value.Parent == nil or Owner.Value:FindFirstChild("SkeletonBirdRefObject") == nil then
			debris:AddItem(SkeletonBird.Parent, 3.5) --Kill the skeletonBird if the owner dies
			Delay(1.5, function() 
				Aggressive = false 
				SkeletonBird.Fire.Size = 10
				SkeletonBird.Fire.Heat = 25
			end)
		end
		if not shooting then
			if tick() - LastAssignment > AssignmentDuration and Owner.Value then
				local torso = Owner.Value:FindFirstChild("Torso")
				if torso then 
					MoveToPoint = torso.Position + Vector3.new(0, -2, 0) 
				end
			end
			CircleCounter = CircleCounter+1
			
			local adjustedMovePoint = MoveToPoint + CFrame.Angles(0,CircleCounter/7,0) * Vector3.new(10,6,0) 
			local moveVector = adjustedMovePoint - SkeletonBird.Position
			local targetSpeed = math.min(MaxSpeed, SubAcceleration * math.sqrt(moveVector.magnitude))
			local curMag = bodyVelocity.velocity.magnitude
			local newSpeed
			if targetSpeed > curMag then
				newSpeed = math.min(targetSpeed, curMag + Acceleration * MoveDelay)
			else
				newSpeed = math.max(targetSpeed, curMag - Acceleration * MoveDelay)
			end
			bodyVelocity.velocity = moveVector.unit * newSpeed
			--print("target, vel", MoveToPoint, bodyVelocity.velocity)
			bodyGyro.cframe = CFrame.new(SkeletonBird.Position, SkeletonBird.Position + moveVector.unit + Vector3.new(0,-3,0) )
		end
		wait(MoveDelay)
	end
end

delay(0, FlapWings)
delay(0, MoveToTarget)

TargetPoint.Changed:connect(function(val) 
	print("target updated")
	LastAssignment = tick()
	MoveToPoint = val
end)

function VisualEffect(part) -- For special ability

	local StartSphereScale=Vector3.new(.1,.1,.1)
	local EndSphereScale=Vector3.new(100,100,100)
	local EffectLength=.9

	local timeDelay = 0.2
	local sphere = Instance.new('Part')
	sphere.CanCollide = false
	sphere.Anchored = true
	sphere.Transparency = 0.5
	sphere.FormFactor = Enum.FormFactor.Custom
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(0.2, 0.2, 0.2)
	sphere.CFrame = CFrame.new(part.Position)
	sphere.TopSurface = Enum.SurfaceType.Smooth
	sphere.BottomSurface = Enum.SurfaceType.Smooth
	sphere.Name = 'water'
	sphere.BrickColor = BrickColor.new('Lavender')
	sphere.Transparency = 1
	debris:AddItem(sphere, EffectLength + timeDelay)
	sphere.Parent = Workspace
	
	local sphereMesh = Instance.new('SpecialMesh')
	sphereMesh.MeshType='Sphere'
	sphereMesh.VertexColor=Vector3.new(1,1,1)
	sphereMesh.Scale = Vector3.new(.1,.1,.1)
	sphereMesh.Parent = sphere

	wait(timeDelay)
	sphere.Transparency = 0
	local startTime=time()
	while time()-startTime<EffectLength do
		sphere.CFrame = CFrame.new(part.Position)
		sphereMesh.Scale=StartSphereScale:Lerp(EndSphereScale,(time()-startTime)/EffectLength)
		sphere.Transparency=(time()-startTime)/EffectLength
		wait(1/30)
	end
end


wait(1)


-- SkeletonBird Special Ability!
Spawn(function()
	wait(5)
	while true do
		if math.random() > 0.8 then
			local originalPosition = SkeletonBird.Position

			LastAssignment = tick()
			MoveToPoint = originalPosition + Vector3.new(0, 10, 0)

			wait(2)

			Spawn(function() VisualEffect(SkeletonBird) end)
			local sound = SkeletonBird:FindFirstChild("Sound")
			if sound then
				local soundClone = sound:Clone()
				debris:AddItem(soundClone, 5)
				soundClone.Parent = Workspace
				soundClone.Pitch = 0.7
				soundClone:Play()
			end

			local center = SkeletonBird.Position
			local diagonal = Vector3.new(75,75,75)
			local parts = Workspace:FindPartsInRegion3(Region3.new(center-diagonal,center+diagonal),Owner.Value,100)
			local humanoidsSlowed = {}
			for _, part in pairs(parts) do
				if part.Parent then
					local humanoid = part.Parent:FindFirstChild('Humanoid')
					if humanoid and not humanoidsSlowed[humanoid] then
						humanoidsSlowed[humanoid] = true
						local originalSpeed = humanoid.WalkSpeed
						humanoid.WalkSpeed = humanoid.WalkSpeed / 2
						Delay(3, function()
							if humanoid then
								humanoid.WalkSpeed = originalSpeed
							end
						end)
					end
				end
			end

			LastAssignment = tick()
			MoveToPoint = originalPosition

			wait(3)
		else
			wait(5)
		end
	end
end)



while SkeletonBird and SkeletonBird.Parent do
	if Aggressive and (not EnemyTarget or (tick() - LastAssignment < AssignmentDuration)) then
		local pxPos = SkeletonBird.Position + Vector3.new(0,-8,0)
		local searchVec = Vector3.new(SearchRangeXZ, SearchRangeY, SearchRangeXZ)
		local searchRegion = Region3.new(pxPos - searchVec, pxPos + searchVec)
		local partList = game.Workspace:FindPartsInRegion3(searchRegion, Owner.Value, 50)
		local closestPart
		local closestDistance = ChaseRange
		for i,part in pairs(partList) do
			local partDistance = (part.Position - pxPos).magnitude
			local hum = part.Parent:FindFirstChild("Humanoid")
			if partDistance < closestDistance and hum and hum:IsA("Humanoid") and hum.Health>0 then
				closestPart = part
				closestDistance = partDistance
			end
		end
		if closestPart then 
			EnemyTarget = closestPart.Parent 
			print("found attack target")
		end
	end
	if Aggressive and EnemyTarget then
		local hum = EnemyTarget:FindFirstChild("Humanoid")
		local torso = EnemyTarget:FindFirstChild("Torso")
		while EnemyTarget and hum and torso and (SkeletonBird and SkeletonBird.Parent) do
			local attackVec = torso.Position - SkeletonBird.Position
			if hum.Parent and hum.Health > 0 and attackVec.magnitude < ChaseRange then
				local success = shoot(torso)
				if not success then break end
			else
				EnemyTarget = nil
			end
			wait(.0001)
		end
	end
	
	wait(2)
end

