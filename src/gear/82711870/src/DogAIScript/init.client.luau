while script:FindFirstChild("Dog") == nil do 
	wait()
end

local projectile = Instance.new("Part")
projectile.FormFactor = 3
projectile.Size = Vector3.new(1, 1, 1)
projectile.Name = "Projectile"
projectile.CanCollide = false

local projectileMesh = Instance.new("SpecialMesh")
projectileMesh.MeshId = "http://www.roblox.com/asset/?id=28937301"
projectileMesh.TextureId = "http://www.roblox.com/asset/?id=28937670"
projectileMesh.Parent = projectile 

local treasureChest = Instance.new("Part")
treasureChest.FormFactor = 3 
treasureChest.Size = Vector3.new(2, 1.2, 2)
treasureChest.Name = "Treasure Chest"
treasureChest.CanCollide = true 

local chestMesh = Instance.new("SpecialMesh")
chestMesh.MeshId = "http://www.roblox.com/asset/?id=23723701"
chestMesh.TextureId = "http://www.roblox.com/asset/?id=23723666"
chestMesh.Scale = Vector3.new(0.75, 0.75, 0.75)
chestMesh.Parent = treasureChest 

local treasureAssets = {29100449, 24015579, 41457719, 59190534} 

local petDog = script.Dog

while petDog.Value == nil do 
	wait()
end 

petDog = petDog.Value

while petDog:FindFirstChild("Target") == nil do 
	wait()
end

local target = petDog.Target

if target.Value == nil then 
	--petDog:Remove()
end 

local damage = 5

-- Best part about doing this from the character 
local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

if myHumanoid then 
	myHumanoid.Died:connect(function() petDog:Destroy() end)
end 

local petDogHumanoid = petDog:FindFirstChild("Humanoid")
local petDogTorso = petDog:FindFirstChild("Torso")

local debris = game:GetService("Debris")

local enemyHumanoid = target.Value 

if petDogHumanoid then 	
	petDogHumanoid.WalkSpeed = 24.0
	
	while petDogHumanoid.MaxHealth < 350 do 
		petDogHumanoid.MaxHealth = 350 
		wait()
	end

	while petDogHumanoid.Health < 350 do 
		petDogHumanoid.Health = 350 
		wait()
	end
end 

local healCount = 0

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end 

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")	 
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then           
		tagHumanoid(humanoid, vPlayer)                    
		humanoid:TakeDamage(damage)                              
	end     
end 

function shoot(target, direction, distance)
	if petDogTorso == nil or petDogHumanoid == nil then return end
	local projectileClone = projectile:Clone()

	local speed = 50

	local upVector = Vector3.new(0, 1, 0)
	local dy = direction.Y
	direction = (direction * Vector3.new(1, 0, 1))
	local dxz = direction.magnitude
	local xzVelocity = direction.unit * speed
	local yVelocity = ((speed * dy / dxz) + ((workspace.Gravity * dxz)/(2 * speed))) * upVector

	print(dy, dxz)

	local spawnPos = petDogTorso.Position

	print(yVelocity)

	yVelocity = yVelocity * 10.0

	projectileClone.CFrame = CFrame.new(spawnPos, spawnPos + petDogTorso.CFrame.lookVector)
	projectileClone.Velocity = xzVelocity + yVelocity     
	--projectileClone.RotVelocity = Vector3.new(0, 10, 0)

	local floatForce = Instance.new("BodyForce")      
	floatForce.force = Vector3.new(0, projectileClone:GetMass() * workspace.Gravity*0.95, 0)     

	projectileClone.Parent = game.Workspace
	projectileClone.Touched:connect(blow)
	debris:AddItem(projectileClone, 4)

	wait(0.5)
	projectileClone.CanCollide = true
end 

function slash(hit)
end 

local petDogLeftArm = petDog:FindFirstChild("Left Arm")
local petDogRightArm = petDog:FindFirstChild("Right Arm")
local petDogLeftLeg = petDog:FindFirstChild("Left Leg")
local petDogRightLeg = petDog:FindFirstChild("Right Leg")

if petDogLeftArm then
	petDogLeftArm.Touched:connect(slash)
end

if petDogRightArm then 
	petDogRightArm.Touched:connect(slash)
end 

if petDogRightLeg then 
	petDogRightLeg.Touched:connect(slash)
end 

if petDogLeftLeg then 
	petDogLeftLeg.Touched:connect(slash)
end

petDogTorso.Touched:connect(slash)

local children = petDog:GetChildren()
for i = 1, #children do 
	if children[i].ClassName == "Tool" then 
		if children[i]:FindFirstChild("Handle") then 
			children[i].Handle.Touched:connect(slash) 
		end 
	end 
end 


local targetEnemy 
if enemyHumanoid then targetEnemy = enemyHumanoid.Parent end
local targetEnemyTorso 

if targetEnemy then 
	targetEnemyTorso = targetEnemy:FindFirstChild("Torso") or targetEnemy:FindFirstChild("UpperTorso")
	if targetEnemyTorso == nil then
		--petDog:Remove()
	end 
else 
	--petDog:Remove() 
end 

target.Changed:connect(function()
	if target.Value then 
		enemyHumanoid = target.Value 
		targetEnemy = enemyHumanoid.Parent 
		if targetEnemy then 
			targetEnemyTorso = targetEnemy:FindFirstChild("Torso") or targetEnemy:FindFirstChild("UpperTorso")
		end 
	end 
end) 

local animating = false

local checkAOE = Vector3.new(15, 15, 15)

local treasure = treasureChest:Clone() 

coroutine.resume(coroutine.create(function()
	wait(4.0)
	while petDog and myTorso do 		
		if math.random() < 0.25 and treasure.Parent == nil then 			
			treasure = treasureChest:Clone() 
			treasure.CFrame = myTorso.CFrame + Vector3.new(math.random(15, 25), 3, math.random(10, 35)) 
			treasure.Transparency = 1.0
			--treasure.Parent = game.Workspace 
			debris:AddItem(treasure, 15) 
			print(treasure)
		end 
		wait(6.0)
	end 
end)) 

local jumpy = false 
local licky = false 
local lickDebounce = false 

while true do     
	local ray = game.Workspace:FindPartOnRay(Ray.new(petDogTorso.Position, petDogTorso.CFrame.lookVector * 3.0), nil)
	if ray and petDogHumanoid and ray.Parent ~= targetEnemy and ray.Parent ~= vCharacter and ray.Name ~= "Treasure Chest" and not animating then		
		petDogHumanoid.Jump = true
	end     
	if math.random() < 0.05 and not jumpy then 
		jumpy = true 
		print("Jumpy")
		Spawn(function() 
			local duration = 2.0 
			while duration > 0 do 
				duration = duration - wait() 
				petDogHumanoid.Jump = true 
				wait(0.5) 
			end 
			wait(5.0)
			jumpy = false 
		end) 
	end 
	if targetEnemyTorso then           
		shoot(targetEnemyTorso.Position, (targetEnemyTorso.Position - petDogTorso.Position).unit, (targetEnemyTorso.Position - petDogTorso.Position).magnitude) 
		targetEnemyTorso = nil
		wait(0.5) 
	else
		if myTorso and not licky then 
			petDogHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
		end 
	end
	if treasure and treasure.Parent and treasure.Transparency == 1.0 then 		
		local distance = (treasure.Position - petDogTorso.Position).magnitude
		if distance < 90 then 			
			petDogHumanoid:MoveTo(treasure.Position, treasure) 
			if distance < 2 and not animating then
				local findSound = script:FindFirstChild("HereYaGo")
				if findSound then findSound:Play() end 
				treasure.Transparency = 0.0 
				local sparkles = Instance.new("Sparkles")
				sparkles.Parent = treasure 
				debris:AddItem(sparkles, 1.0) 
				animating = true 
				local liftAnim = petDogHumanoid:LoadAnimation(script.LiftAnim)
				if liftAnim then liftAnim:Play() end 
				wait(1.5) 
				animating = false
				treasure.Touched:connect(function(hit) 
					if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") and hit.Parent == vCharacter and not animating then 
						animating = true
						-- Do st00f here 
						petDogHumanoid.WalkSpeed = 0.0 
						petDogTorso.CFrame = CFrame.new(petDogTorso.Position, petDogTorso.Position + ((myTorso.Position - petDogTorso.Position) * Vector3.new(1, 0, 1) )) 
						local bowAnim = petDogHumanoid:LoadAnimation(script.BowAnim)						
						if bowAnim then bowAnim:Play() end 
						if vPlayer then 
							local backpack = vPlayer:FindFirstChild("Backpack") 
							if backpack then 
								local item = game:GetService("InsertService"):LoadAsset(treasureAssets[math.random(1, #treasureAssets)]):GetChildren()[1]
								if item then item.Parent = backpack end 
							end 
						end 
						local yaySound = script:FindFirstChild("Yay")
						if yaySound then yaySound:Play() end 
						if treasure then treasure:Destroy() end 
						wait(2.0) 						
						petDogHumanoid.WalkSpeed = 24.0
						animating = false 
					end 
				end) 
			end 
		end 	
	end 
	if math.random() < 0.25 and not licky and not lickDebounce then		
			print("LICK")
			licky = true 
			lickDebounce = true 
			if myHumanoid then 
				myHumanoid.WalkSpeed = 24.0  
				petDogHumanoid.WalkSpeed = 25.0  
				local ratio = myHumanoid.Health/myHumanoid.MaxHealth 
				myHumanoid.MaxHealth = 250 
				while myHumanoid.Health < ratio * 250 do 
					myHumanoid.Health = ratio * 250 
					wait() 
				end  
				Spawn(function()
					wait(6.0) 
					if myHumanoid then 
						myHumanoid.WalkSpeed = 16.0 
						petDogHumanoid.WalkSpeed = 22.0  
						local ratio = myHumanoid.Health/myHumanoid.MaxHealth 
						myHumanoid.MaxHealth = 100 
						while myHumanoid.Health < ratio * 100 do 
							myHumanoid.Healt = ratio * 100 
							wait() 
						end  
					end 
					licky = false 
					wait(4.0)
					lickyDebounce = true 
				end)
			end
		end 
	wait()
end 
