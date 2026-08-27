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

local currentSound

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
local elfSound

while Doll:FindFirstChild("S4") == nil do wait() end
local playfulSounds = {Doll:FindFirstChild("S1"), Doll:FindFirstChild("S2"), Doll:FindFirstChild("S3"), Doll:FindFirstChild("S4")}

while Doll:FindFirstChild("TradingSystem") == nil do wait() end 
local angrySounds = {Doll:FindFirstChild("StopClicking"), Doll:FindFirstChild("TradingSystem")}


local attacking = false

function blow(ray, hit)
	if ray and hit and hit.Parent and hit.Parent ~= vCharacter then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then 
			humanoid:TakeDamage(30)
			if myHumanoid and myHumanoid.Health + 5 <=  myHumanoid.MaxHealth then 
				myHumanoid.Health = myHumanoid.Health + 5
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
	fire.Color = Color3.new(0, 153/255, 0)
	fire.SecondaryColor = Color3.new(102/255, 51/255, 0)

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
				if character then 
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					if torso then
						attacking = true
						print(1)
						shoot(torso)					
						attacking = false
					end
				end
			end
		end
	end
end

local clickCount = 0
local riding = true 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end
	
	playfulSounds = {Doll:FindFirstChild("S1"), Doll:FindFirstChild("S2"), Doll:FindFirstChild("S3"), Doll:FindFirstChild("S4")}
	angrySounds = {Doll:FindFirstChild("StopClicking"), Doll:FindFirstChild("TradingSystem")}

	clickCount = clickCount + 1

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end		
	
	if currentSound and currentSound.IsPlaying then return end
	
	Tool.Enabled = false

	if clickCount > 10 then 
		currentSound = angrySounds[math.random(1, #angrySounds)] 
		if currentSound then currentSound:Play() end
		clickCount = clickCount - 7
	elseif not riding then 
		riding = true
		if math.random() < 0.5 then 
			Tool.GripPos = Vector3.new(2.8, 1.5, -1.7)
		else 
			Tool.GripPos = Vector3.new(0, 1.5, -1.7)
		end 
		currentSound = playfulSounds[math.random(1, #playfulSounds)] 
		if currentSound then currentSound:Play() end		
	else 
		riding = false 		
		Tool.GripPos = Vector3.new(0.3, 0, -1.2)
		Tool.GripRight = Vector3.new(1, 0, 0)
		Tool.GripUp = Vector3.new(0, 0, 1)
		currentSound = playfulSounds[math.random(1, #playfulSounds)] 
		if currentSound then currentSound:Play() end
	end 
	Tool.Enabled = true
	coroutine.resume(coroutine.create(function() wait(3.0) if currentSound then currentSound:Stop() end end))
	wait(10.0)
	clickCount = clickCount - 1	
end

function onEquipped()
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myHumanoid then myHumanoid.HealthChanged:connect(attack) end
end

function onUnequipped()
	clickCount = 0
	if connection then connection:disconnect() end
	if shootSound then shootSound:Stop() end
	if currentSound then currentSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
