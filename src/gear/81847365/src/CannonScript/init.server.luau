-- Assuming 0 air resistance

local Tool = script.Parent 
local Cannon = Tool.Handle 

local vCharacter
local vTorso
local vHumanoid 
local vPlayer 

local Damage = 49

Tool.Enabled = true 

local Potato = Instance.new("Part")
Potato.Name = "Potato"
Potato.FormFactor = 3 
Potato.Shape = "Block"
Potato.Size = Vector3.new(2.5, 2.5, 2.5)
Potato.CanCollide = false 

local PotatoMesh = Instance.new("SpecialMesh") 
PotatoMesh.MeshId = "http://www.roblox.com/asset/?id=81684482"
PotatoMesh.TextureId = "http://www.roblox.com/asset/?id=81684510"
PotatoMesh.Parent = Potato 
PotatoMesh.Scale = Vector3.new(2.5, 2.5, 2.5)

local RBX_Debris = game:GetService("Debris")

local Gravity = workspace.Gravity
local TimeTaken = 0
local Velocity = 300.0

local initY = 0
local oY = 0

local CannonSound 

local function blow(missile, hit, initPos)	
	if missile and hit and hit.Parent and not hit.Parent:FindFirstChild("Humanoid") then 
		--print("Maximum distance travelled - ", (missile.Position - initPos).magnitude, " studs") 
		--missile:Destroy() 
		--print("Maximum height reached - ", initY - oY, " studs") 
		--print("Time taken - ", tick() - TimeTaken, " seconds") 
	end  
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Accessory") and hit.Parent.Parent then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= vHumanoid then 
			humanoid:TakeDamage(Damage)
			local sScript = script.SplatScript:Clone()
			sScript.Parent = humanoid.Parent 
			sScript.Disabled = false 
		end 
	end 
end

function computeLaunchAngle(dx, dy, grav)	
	-- This function is nasty or what? :P 
	-- There are ways to solve launch angle of a projectile given a point in 3D space 
	-- This one solves for tan(theta) 
		
	-- Simplify the distance formula of a projectile 
	local g = math.abs(grav)
	local inRoot = (Velocity * Velocity * Velocity * Velocity) - (g * ((g * dx * dx) + (2 * dy * Velocity * Velocity)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((Velocity * Velocity) + root) / (g*dx)

	local inATan2 = ((Velocity * Velocity) - root) / (g*dx)
	local a1 = math.atan(inATan1)
	local a2 = math.atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

function fire(target)		

	local head = vCharacter:findFirstChild("Head")
	local torso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso") 
	if head == nil then return end
	
	--local direction = (target - (torso.Position - Vector3.new(0, 3, 0))).unit		
	local spawnPos = (torso.Position - Vector3.new(0, 3, 0)) 

	local toTarget = target - spawnPos	
	local dY = toTarget.Y
	toTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
	local dXZ = toTarget.magnitude
	toTarget = toTarget.unit 
	

	CannonSound = Cannon:FindFirstChild("CannonSound")
	if CannonSound then CannonSound:Play() end 

	local theta = computeLaunchAngle(dXZ, dY, Gravity)

--	print("Muzzle Velocity - ", Velocity, " studs/second") 
--	print("Gravity - ", Gravity, " studs/seconds^2")
--	print("Launch angle - ", math.deg(theta), " degrees") 

	local angleY = math.sin(theta)
	local angleXZ = math.cos(theta)

	local vY = angleY *  Velocity  
	local vX = toTarget.X * angleXZ * Velocity 
	local vZ = toTarget.Z * angleXZ * Velocity 		

	local missile = Potato:clone()        		

	missile.CFrame = CFrame.new(spawnPos)
	missile.Velocity = Vector3.new(vX, vY, vZ) 
	
	local smoke = Instance.new("Smoke")
	smoke.Parent = missile

	RBX_Debris:AddItem(smoke, 0.5)

	initPos = missile.Position 

	missile.Parent = game.Workspace	

	oY = missile.Position.Y 	
	TimeTaken =  tick() 

	RBX_Debris:AddItem(missile, 500.0)

	Spawn(function()
		initY = missile.Position.Y 
		while missile do 
			if missile.Position.Y > initY then 
				initY = missile.Position.Y
			end 
			wait() 
		end 
	end) 
	
	wait(0.25)
	missile.Touched:connect(function(hit) blow(missile, hit, initPos) end)	
	wait(0.25)
	missile.CanCollide = true 
end


local function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if vTorso == nil or vHumanoid == nil then
		return 
	end 

	Tool.Enabled = false 

	local target = vHumanoid.TargetPoint	

	fire(target)

	wait(0.5)
	Tool.Enabled = true 
end

local function onEquipped()
	vCharacter = Tool.Parent 
	vTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:playerFromCharacter(vCharacter)
end

local function onUnequipped()
	-- blah blah
	if CannonSound then CannonSound:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
workspace:GetPropertyChangedSignal("Enabled"):Connect(function()
	Gravity = workspace.Gravity
end)
