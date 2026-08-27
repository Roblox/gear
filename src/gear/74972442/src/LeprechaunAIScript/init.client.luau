while script:FindFirstChild("Leprechaun") == nil do 
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

local petLeprechaun = script.Leprechaun

while petLeprechaun.Value == nil do 
	wait()
end 

petLeprechaun = petLeprechaun.Value

while petLeprechaun:FindFirstChild("Target") == nil do 
	wait()
end

local target = petLeprechaun.Target

if target.Value == nil then 
	--petLeprechaun:Remove()
end 

local damage = 5

-- Best part about doing this from the character 
local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

if myHumanoid then 
	myHumanoid.Died:connect(function() petLeprechaun:Destroy() end)
end 

local petLeprechaunHumanoid = petLeprechaun:FindFirstChild("Humanoid")
local petLeprechaunTorso = petLeprechaun:FindFirstChild("Torso")

local debris = game:GetService("Debris")

local enemyHumanoid = target.Value 

if petLeprechaunHumanoid then 	
	petLeprechaunHumanoid.WalkSpeed = 24.0
	
	while petLeprechaunHumanoid.MaxHealth < 350 do 
		petLeprechaunHumanoid.MaxHealth = 350 
		wait()
	end

	while petLeprechaunHumanoid.Health < 350 do 
		petLeprechaunHumanoid.Health = 350 
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
	if petLeprechaunTorso == nil or petLeprechaunHumanoid == nil then return end
	local projectileClone = projectile:Clone()

	local speed = 50

	local upVector = Vector3.new(0, 1, 0)
	local dy = direction.Y
	direction = (direction * Vector3.new(1, 0, 1))
	local dxz = direction.magnitude
	local xzVelocity = direction.unit * speed
	local yVelocity = ((speed * dy / dxz) + ((workspace.Gravity * dxz)/(2 * speed))) * upVector

	print(dy, dxz)

	local spawnPos = petLeprechaunTorso.Position

	print(yVelocity)

	yVelocity = yVelocity * 10.0

	projectileClone.CFrame = CFrame.new(spawnPos, spawnPos + petLeprechaunTorso.CFrame.lookVector)
	projectileClone.Velocity = xzVelocity + yVelocity     
	--projectileClone.RotVelocity = Vector3.new(0, 10, 0)

	local floatForce = Instance.new("BodyForce")      
	floatForce.force = Vector3.new(0, projectileClone:GetMass() * workspace.Gravity * 0.95, 0)     

	projectileClone.Parent = game.Workspace
	projectileClone.Touched:connect(blow)
	debris:AddItem(projectileClone, 4)

	wait(0.5)
	projectileClone.CanCollide = true
end 

function slash(hit)
end 

local petLeprechaunLeftArm = petLeprechaun:FindFirstChild("Left Arm")
local petLeprechaunRightArm = petLeprechaun:FindFirstChild("Right Arm")
local petLeprechaunLeftLeg = petLeprechaun:FindFirstChild("Left Leg")
local petLeprechaunRightLeg = petLeprechaun:FindFirstChild("Right Leg")

if petLeprechaunLeftArm then
	petLeprechaunLeftArm.Touched:connect(slash)
end

if petLeprechaunRightArm then 
	petLeprechaunRightArm.Touched:connect(slash)
end 

if petLeprechaunRightLeg then 
	petLeprechaunRightLeg.Touched:connect(slash)
end 

if petLeprechaunLeftLeg then 
	petLeprechaunLeftLeg.Touched:connect(slash)
end

petLeprechaunTorso.Touched:connect(slash)

local children = petLeprechaun:GetChildren()
for i = 1, #children do 
	if children[i]:IsA("Tool") then 
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
		--petLeprechaun:Remove()
	end 
else 
	--petLeprechaun:Remove() 
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
	while petLeprechaun and myTorso do 		
		if math.random() < 0.25 and treasure.Parent == nil then 			
			treasure = treasureChest:Clone() 
			treasure.CFrame = myTorso.CFrame + Vector3.new(math.random(15, 25), 3, math.random(10, 35)) 
			treasure.Transparency = 1.0
			treasure.Parent = game.Workspace 
			debris:AddItem(treasure, 15) 
			print(treasure)
		end 
		wait(6.0)
	end 
end)) 

while true do     
	local ray = game.Workspace:FindPartOnRay(Ray.new(petLeprechaunTorso.Position, petLeprechaunTorso.CFrame.lookVector * 3.0), nil)
	if ray and petLeprechaunHumanoid and ray.Parent ~= targetEnemy and ray.Parent ~= vCharacter and ray.Name ~= "Treasure Chest" and not animating then		
		petLeprechaunHumanoid.Jump = true
	end     
	if targetEnemyTorso then           
		shoot(targetEnemyTorso.Position, (targetEnemyTorso.Position - petLeprechaunTorso.Position).unit, (targetEnemyTorso.Position - petLeprechaunTorso.Position).magnitude) 
		targetEnemyTorso = nil
		wait(0.5) 
	else
		if myTorso then 
			petLeprechaunHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
		end 
	end
	if treasure and treasure.Parent and treasure.Transparency == 1.0 then 		
		local distance = (treasure.Position - petLeprechaunTorso.Position).magnitude
		if distance < 90 then 			
			petLeprechaunHumanoid:MoveTo(treasure.Position, treasure) 
			if distance < 2 and not animating then
				local findSound = script:FindFirstChild("HereYaGo")
				if findSound then findSound:Play() end 
				treasure.Transparency = 0.0 
				local sparkles = Instance.new("Sparkles")
				sparkles.Parent = treasure 
				debris:AddItem(sparkles, 1.0) 
				animating = true 
				local liftAnim = petLeprechaunHumanoid:LoadAnimation(script.LiftAnim)
				if liftAnim then liftAnim:Play() end 
				wait(1.5) 
				animating = false
				treasure.Touched:connect(function(hit) 
					if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") and hit.Parent == vCharacter and not animating then 
						animating = true
						-- Do st00f here 
						petLeprechaunHumanoid.WalkSpeed = 0.0 
						petLeprechaunTorso.CFrame = CFrame.new(petLeprechaunTorso.Position, petLeprechaunTorso.Position + ((myTorso.Position - petLeprechaunTorso.Position) * Vector3.new(1, 0, 1) )) 
						local bowAnim = petLeprechaunHumanoid:LoadAnimation(script.BowAnim)						
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
						petLeprechaunHumanoid.WalkSpeed = 24.0
						animating = false 
					end 
				end) 
			end 
		end 
	end 
	wait()
end 
