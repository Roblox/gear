local Tool = script.Parent 
local Lantern = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

Tool.Enabled = true

local equipped = false

local activated = false 

local hauntDamage = 45

local dogSpirit

local dogPart = Instance.new("Part")
dogPart.Name = "DOGE"
dogPart.Size = Vector3.new(1, 1, 3)
dogPart.Transparency = 0.5
dogPart.CanCollide = false 
dogPart.Anchored = true 

local dragonSound

local debris = game:GetService("Debris")

local dogMesh = Instance.new("SpecialMesh")
dogMesh.MeshId = ""
dogMesh.TextureId = ""
dogMesh.Parent = dogPart 

dogSpirit = dogPart:Clone() 
dogSpirit.Mesh.MeshId = "rbxassetid://255485578"
dogSpirit.Mesh.TextureId = "rbxassetid://1405471349"

local float = Instance.new("BodyForce")
float.force = Vector3.new(0, dogPart:GetMass() * workspace.Gravity, 0) 

local radius1 = 5
local radius2 = 3
local radius3 = 4

local theta1 = 0
local theta2 = math.pi/2
local theta3 = 3*math.pi/2

local phi1 = 0
local phi2 = math.pi/2
local phi3 = 3*math.pi/2

local dt1 = 0.02
local dt2 = 0.030
local dt3 = -0.025

local dp1 = -0.01
local dp2 = 0.025
local dp3 = -0.035

function animateDogs()
	while dogSpirit and equipped do 
		if not activated then 		
			-- animate them
			theta1 = theta1 + dt1
			theta2 = theta2 + dt2
			theta3 = theta3 + dt3

			phi1 = phi1 + dp1
			phi2 = phi2 + dp2
			phi3 = phi3 + dp3

			-- calc positions
			local pos1 = radius1 * Vector3.new(math.sin(theta1) * math.cos(phi1), math.sin(phi1), math.cos(theta1) * math.cos(phi1))
			local pos2 = radius2 * Vector3.new(math.sin(theta2) * math.cos(phi2), math.sin(phi2), math.cos(theta2) * math.cos(phi2))
			local pos3 = radius3 * Vector3.new(math.sin(theta3) * math.cos(phi3), math.sin(phi3), math.cos(theta3) * math.cos(phi3))

			-- render them
			dogSpirit.CFrame = CFrame.new(pos1 + Lantern.Position, myTorso.Position + myTorso.CFrame.lookVector * 25)
		end
		wait()
	end 
end

function haunt(hit, phantom)
	local humanoid 
	if hit and hit.Parent then 
		if phantom then 
			hauntDamage = 72 
		else 
			hauntDamage = 45
		end 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			humanoid:TakeDamage(hauntDamage)
			if phantom then phantom:Destroy() end 
		end 		
	end 
end 

function findTarget(target)
	local AOE = Vector3.new(12, 12, 12)
	local parts = game.Workspace:FindPartsInRegion3(Region3.new(target - AOE, target + AOE), vCharacter, 100)
	local minDistance = math.huge
	local targetTorso = nil
	for i = 1, #parts do 
		local character = parts[i].Parent 
		if character then 
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if torso then 
				local distance = (target - torso.Position).magnitude 
				if torso and distance < minDistance then 
					minDistance = distance 
					targetTorso = torso
				end
			end 
		end 
	end 
	return targetTorso
end 

function flameIt(torso)
	if dogSpirit then 
		local s1 = dogSpirit:Clone()
		s1.Anchored = false

		dogSpirit.Transparency = 1.0
	
		local d1 = (torso.Position - s1.Position).unit

		local f1 = float:Clone()
		f1.Parent = s1

		s1.Velocity = d1 * 50.0

		s1.Parent = game.Workspace

		debris:AddItem(s1, 8)

		s1.Touched:connect(function(hit) haunt(hit, s1) end)
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

	local target = myHumanoid.TargetPoint 
	
	local targetTorso = findTarget(target)	

	if targetTorso then 
		activated = true 
		flameIt(targetTorso)
	else 
		-- Just make them go towards the target, say 50 studs distance, should they attack anyone? Not sure 
	end 

	wait(7.0)
	Tool.Enabled = true 
	activated = false
	dogSpirit.Transparency = 0.5
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	dogSpirit.Parent = vCharacter 
	equipped = true 

	dc1 = dogSpirit.Touched:connect(haunt)

	coroutine.resume(coroutine.create(animateDogs))

	dogSound = Lantern:FindFirstChild("DogSound")
	if dogSound then dogSound:Play() end 
end 

function onUnequipped()
	equipped = false
	if dogSpirit then dogSpirit.Parent = nil end	

	if dogSound then dogSound:Stop() end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


