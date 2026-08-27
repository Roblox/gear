local Tool = script.Parent
Tool.Enabled = true

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer

local sparkColors = {Color3.new(1, 0, 0),
				Color3.new(0,1,0),
				Color3.new(0,0,1),
				Color3.new(1,1,0),
				Color3.new(1,0,1),
				Color3.new(0,1,1)}

local reload = 0.3

local HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

local spamArrow 

local debris = game:GetService("Debris")

local damage = 10

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player 
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid 
	end 
end 

function pierce(missile, hit)
	if hit == nil or hit.Name == "XBowArrow" or hit.Parent == nil or hit.Parent == Tool or hit.Parent == vCharacter or missile == nil or missile:FindFirstChild("ArrowWeld") then return end
	touchedYet = true
	missile.Velocity = Vector3.new(0,0,0)

	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		HitSound:Play()
		humanoid:TakeDamage(damage)
			
		tagHumanoid(humanoid, vPlayer) 

		if hit:FindFirstChild("sFire") == nil then 
			local sFire = Instance.new("Fire")
			sFire.Name = "sFire"
			sFire.Parent = hit 
			debris:AddItem(sFire, 2.5) 
			sFire.Color = Color3.new(0, 0, 1)
			coroutine.resume(coroutine.create(function()
				if humanoid then 
					humanoid:TakeDamage(10) 
					wait(1.25)
					humanoid:TakeDamage(10) 
				end 
			end)) 
		end  
	end

	local newWeld = Instance.new("Weld")
	newWeld.Name = "ArrowWeld"
	newWeld.Part0 = hit
	newWeld.Part1 = missile
	
	newWeld.C1 = missile.CFrame:inverse()*hit.CFrame
	newWeld.Parent = missile
end 

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")
	local missileMesh = Tool.Handle.Mesh:Clone()
	missileMesh.Parent = missile
	missileMesh.MeshId = "http://www.roblox.com/asset/?id=43645253"
	
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=76492321"

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*5
	dPos = dPos - dPos.unit * 5
	
	-- convert to a 2D space
	deltaXZSquared = dPos.X*dPos.X + dPos.Z*dPos.Z
	deltaXZ = math.sqrt(deltaXZSquared)
	deltaY = dPos.Y
	
	alpha = math.random()*math.pi/8 + math.pi/6	

	missile.Position = spawnPos
	missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	
	
	gravity = workspace.Gravity
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 300 then missileSpeed = 300 end
	vXZ = missileSpeed * math.cos(alpha)
	vY = missileSpeed * math.sin(alpha)
	vX = vXZ * dPos.X / deltaXZ
	vZ = vXZ * dPos.Z / deltaXZ
	missile.Velocity = Vector3.new(vX, vY, vZ)

	missile.Name = "XBowArrow"
	missile.CanCollide = false

	newBG = Instance.new("BodyGyro")
	newBG.cframe = CFrame.new(missile.Position, missile.Position+missile.Velocity) * CFrame.Angles(math.pi/2, 0, 0)
	newBG.Name = "ArrowGyro"
	newBG.P = 10000
	newBG.D = 1000
	newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
	newBG.Parent = missile

	missile.Parent = game.Workspace

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .3
		confettiBang:Play() 
	end

	missile.Touched:connect(function(hit) pierce(missile, hit) end) 
	debris:AddItem(missile, 5)
end



function gunUp()	

	for i = 1,20 do
		upAngle = math.cos(i*math.pi/60)
		downAngle = math.sin(i*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end
end

function gunDown()

	for i = 1,20 do
		upAngle = math.cos((20-i)*math.pi/60)
		downAngle = math.sin((20-i)*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end
	
end
function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onEquip()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit	

	local targetPos = humanoid.TargetPoint		
	local lookAt = targetPos - character.PrimaryPart.Position

	spamArrow = Tool:FindFirstChild("SpamArrow")
	if spamArrow and spamArrow.Value == 1 then
		local sign = -1
		for i = 1, 7 do 
			local d1 = CFrame.Angles(0, (i-1) * sign * math.pi/30, 0) * lookAt 
			sign = sign * -1
			fire(lookAt)
			wait() 
		end
		wait(5) 
	else	
		fire(lookAt) 	
	end 

	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=76492321"

	Tool.Enabled = true
end

Tool.Equipped:connect(onEquip)
Tool.Activated:connect(onActivated)
