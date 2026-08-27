local Tool = script.Parent
local Doll = Tool.Handle

local vCharacter
local myHumanoid
local myTorso

Tool.Enabled = true 

local dollClone
local dollFire
local dollModel

local prevHealth = 100

local connection

local ray = Instance.new("Part")
ray.FormFactor = 3
ray.Shape = "Ball"
ray.Size = Vector3.new(0.4, 0.4, 0.4)
ray.CanCollide = false
ray.Transparency = 0.0

local bullet = Instance.new("SpecialMesh")
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032"
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568"
bullet.Parent = ray
bullet.Scale = Vector3.new(4, 4, 4)

local debris = game:GetService("Debris")

local shootSound
local alienSound

local attacking = false

local allSounds = {}
local playSound 

function follow()		
	allSounds = {Doll:FindFirstChild("V1"), Doll:FindFirstChild("V2"), Doll:FindFirstChild("V3"), Doll:FindFirstChild("V4")}
	local count = 0
	local stopped = false	
	while dollClone and dollModel and myTorso do  		
		tick()
		if count %7 == 0 then 
			playSound = allSounds[math.random(1, #allSounds)]
			if playSound then playSound:Play() end
		end
		count = count +  1
		for i = 1, 30 do 	
			if dollClone then				
				dollClone.CFrame = (CFrame.Angles(-math.pi/2, 0, math.pi) + myTorso.CFrame.p + (CFrame.Angles(0, 2 * i * math.pi/30, 0) * myTorso.CFrame.lookVector * 5.0))			
			end
			wait()
		end		
	end	
	Doll.Transparency = 0.0
end

function deal(hit)
	if hit and hit.Parent and myHumanoid then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and myHumanoid ~= humanoid then 
			humanoid:TakeDamage(10)
		end
	end
end

function blow(ray, hit)
	if ray and hit and hit.Parent and hit.Parent ~= vCharacter then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then 
			humanoid:TakeDamage(30)
			if myHumanoid and myHumanoid.Health + 3 <=  myHumanoid.MaxHealth then 
				myHumanoid.Health = myHumanoid.Health + 3
			end
		end
	end
end

function shoot(torso)
	if dollClone == nil then return end
	shootSound = Tool:FindFirstChild("ShootSound")
	if shootSound then shootSound:Play() end
	local direction = (torso.Position - dollClone.Position).unit 
	
	local spawnPos = dollClone.Position + direction * 3.0

	local rayC = ray:Clone()
	rayC.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	rayC.Velocity = direction * 50.0

	local float = Instance.new("BodyForce")
	float.force = Vector3.new(0, rayC:GetMass() * workspace.Gravity, 0)
	float.Parent = rayC
	
	local fire = Instance.new("Fire")
	fire.Parent = rayC
	fire.Color = Color3.new(1, 1, 1)
	fire.SecondaryColor = Color3.new(1, 51/255, 0)

	rayC.Parent = game.Workspace

	rayC.Touched:connect(function(hit) blow(rayC, hit) end)
	debris:AddItem(rayC, 5.0)	
end

function attack()
	if myHumanoid == nil then return end
	if myHumanoid.Health < prevHealth and dollClone and not attacking then 
		prevHealth = myHumanoid.Health
		local tag = myHumanoid:FindFirstChild("creator")
		if tag and tag.Value then 
			local playr = tag.Value 
			if playr:IsA("Player") then 
				local character = playr.Character
				if character and (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")) then 
					attacking = true
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					print(1)
					shoot(torso)					
					attacking = false
				end
			end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	connection = myHumanoid.HealthChanged:connect(attack)
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	if dollClone == nil  then 

		Tool.Enabled = false

		alienSound = Tool:FindFirstChild("AlienSound")
		if alienSound then alienSound:Play() end

		dollModel = Instance.new("Model")
		dollModel.Name = "DollModel"

		dollClone = Doll:Clone()
		dollClone.CanCollide = false 
		dollClone.Parent = dollModel
		dollClone.Name = "AlienVoodoo"
		dollModel.Parent = vCharacter

		Doll.Transparency = 1.0

		dollFire = Instance.new("Fire")
		dollFire.Parent  = dollClone
		dollFire.Color = Color3.new(0, 0, 102/255)
		dollFire.SecondaryColor = Color3.new(255, 0, 0)
		dollFire.Heat = -1
		dollFire.Size = 4			

		dollClone.Anchored = true

		--local dollFloat = Instance.new("BodyForce")
		--dollFloat.Name = "DollFloat"
		--dollFloat.Parent = dollClone
		--dollFloat.force = Vector3.new(0, dollClone:GetMass() * 196, 0)			
		
		dollCo = coroutine.create(follow)
		coroutine.resume(dollCo)

		dollClone.Touched:connect(deal)		
	end

	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if dollClone then dollClone:Destroy() dollClone = nil end
	if dollModel then dollModel:Destroy() dollModel = nil end	
	Doll.Transparency = 0.0
	if connection then connection:disconnect() end
	if shootSound then shootSound:Stop() end
	if playSound then playSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
