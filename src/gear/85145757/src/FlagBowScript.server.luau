local Tool = script.Parent
Tool.Enabled = true

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer

local fakeArrow = Tool:FindFirstChild("FakeArrow")
local fakeArrowWeld
if fakeArrow then fakeArrowWeld = fakeArrow:FindFirstChild("FakeArrowWeld") end

local sparkColors = {Color3.new(1, 0, 0),
				Color3.new(0,1,0),
				Color3.new(0,0,1),
				Color3.new(1,1,0),
				Color3.new(1,0,1),
				Color3.new(0,1,1)}

local reload = 1.25

local HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

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
	if hit == nil or hit.Name == "Arrow" or hit.Name == "Flag" or hit.Parent == nil or hit:IsDescendantOf(Tool.Parent) or missile == nil or missile:FindFirstChild("ArrowWeld") or not missile:FindFirstChild("ArrowGyro") then return end
	touchedYet = true
	missile.Velocity = Vector3.new(0,0,0)

	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		
	end

	missile.Mesh.MeshId = "http://www.roblox.com/asset/?id=85004832"

	local gyro = missile:FindFirstChild("ArrowGyro")
	if gyro then gyro:Destroy() end

	local missileDirection = missile.CFrame.lookVector
	local rayStart = missile.Position - missileDirection*4

	local ray = Ray.new(rayStart, missileDirection*8)
	local hit, position = game.Workspace:FindPartOnRay(ray, missile)
	local distance = (rayStart - position).magnitude
	print("dist",distance)
	
	local arrowDistance = 5.4
	local ammountBack = arrowDistance - distance


	mCFrame = missile.CFrame - missileDirection * ammountBack
	missile.CFrame = mCFrame

	local flag = missile:Clone()

	local newWeld = Instance.new("Weld")
	newWeld.Name = "ArrowWeld"
	newWeld.Part0 = hit
	newWeld.Part1 = missile

	print(missileDirection * ammountBack)
		
	newWeld.C0 = CFrame.new(0,0,0)
	if not hit then return end --This really shouldn't be necessary
	newWeld.C1 = mCFrame:inverse()*hit.CFrame 
	newWeld.Parent = missile


	flag.Mesh.MeshId = "http://www.roblox.com/asset/?id=85005906"
	flag.Mesh.TextureId = "http://www.roblox.com/asset/?id=85021844"
	flag.Name = "Flag"
	flag.CanCollide = false
	--flag.Anchored = true
	debris:AddItem(flag, 15)
	flag.Parent = missile
	local flagWeld = Instance.new("Weld")
	flagWeld.Part0 = flag
	flagWeld.Part1 = missile
	flagWeld.C0 = CFrame.new(0, 0, 0, 0.841478229, 1.11013651e-006, -0.540291071, -0.0704218373, 0.991469502, -0.109676696, 0.535681963, 0.130338833, 0.834300041)
	flagWeld.C1 = CFrame.new(0, -1.5, 0.5, 0.841476381, 1.1125054e-006, -0.540293932, -0.0704221725, 0.991469502, -0.109676391, 0.535684764, 0.130338773, 0.834298193)
	flagWeld.Parent = flag
end 

function makeArrow()
	local missile = Instance.new("Part")
	local missileMesh = Tool.Handle.Mesh:Clone()
	missileMesh.Parent = missile
	missileMesh.MeshId = "http://www.roblox.com/asset/?id=85005601"
	missileMesh.Scale = Vector3.new(1.4,1.4,1.4)
	missile.Name = "Arrow"
	missile.Size = Vector3.new(0,0,0)
	return missile
end

function makeFakeArrow()
	--if true then return end
	if Tool.Parent ~= game.Workspace then return end
	if fakeArrow then return end
	print("making fake arrow")
	fakeArrow = makeArrow()
	fakeArrow.CFrame = Tool.Handle.CFrame

	fakeArrow.Name = "FakeArrow"
	fakeArrow.Parent = Tool
	fakeArrow.CanCollide = false

	fakeArrowWeld = Instance.new("Weld")		
	fakeArrowWeld.Part0 = Tool.Handle
	fakeArrowWeld.Part1 = fakeArrow
	fakeArrowWeld.C1 = CFrame.new(0,0,0)
	fakeArrowWeld.Parent = fakeArrow
	fakeArrowWeld.Name = "FakeArrowWeld"
end
makeFakeArrow()


function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = makeArrow()
	
	--Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=76492321"

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*3
	dPos = dPos - dPos.unit * 3
	
	-- convert to a 2D space
	deltaXZSquared = dPos.X*dPos.X + dPos.Z*dPos.Z
	deltaXZ = math.sqrt(deltaXZSquared)
	deltaY = dPos.Y
	
	--alpha = math.random()*math.pi/8 + 2*math.pi/6	
	alpha = .31*math.pi

	missile.Position = spawnPos
	--missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	missile.Size = Vector3.new(.1,.1,.1)
	
	gravity = 196.1643
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 200 then missileSpeed = 200 end
	vXZ = missileSpeed * math.cos(alpha)
	vY = missileSpeed * math.sin(alpha)
	vX = vXZ * dPos.X / deltaXZ
	vZ = vXZ * dPos.Z / deltaXZ
	missile.Velocity = Vector3.new(vX, vY, vZ)

	missile.CanCollide = false

	newBG = Instance.new("BodyGyro")
	newBG.cframe = CFrame.new(missile.Position, missile.Position+missile.Velocity*Vector3.new(1,-1,1)) --* CFrame.Angles(math.pi/2, 0, 0)
	missile.CFrame = CFrame.new(missile.Position, missile.Position+missile.Velocity) --* CFrame.Angles(math.pi/2, 0, 0)
	newBG.Name = "ArrowGyro"
	newBG.P = 10000
	newBG.D = 1000
	newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
	newBG.Parent = missile
	delay(0,function()
		while missile and newBG and newBG.Parent do
			--Adding -.5 y so that the arrow stands up more than normal
			newBG.cframe = CFrame.new(missile.Position, missile.Position+missile.Velocity.unit+Vector3.new(0,-.7,0))
			wait(1/30)
		end
	end)

	missile.Parent = game.Workspace

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .3
		confettiBang:Play() 
	end

	missile.Touched:connect(function(hit) pierce(missile, hit) end) 
	debris:AddItem(missile, 15)
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
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if fakeArrow then fakeArrow:Destroy() fakeArrow = nil end
	if fakeArrowWeld then fakeArrowWeld:Destroy() fakeArrowWeld = nil end
end


function onUnequip()
	equipped = false

	if fakeArrow then fakeArrow:Destroy() fakeArrow = nil end
	if fakeArrowWeld then fakeArrowWeld:Destroy() fakeArrowWeld = nil end
	wait(.1)
	makeFakeArrow()
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

	fire(lookAt) 

	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	--Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=76492321"

	Tool.Enabled = true
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Tool.Activated:connect(onActivated)
