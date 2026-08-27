local Tool = script.Parent
local Gun = Tool.Handle

Tool.Enabled = true

local vCharacter
local shieldWeld

local shieldWalkAnim
local slashAnim
local bashAnim
local lungeAnim
local time

local shieldActive
local lastAttack = 0

local bashDamage = 13
local damage = 20
local connection

local dashTime = 0
local lastKeyDown = 0

local torsoCFrames = {}

local minRange = 2 
local maxRange = 500 

local ray = Instance.new("Part") 
ray.FormFactor = 3 
ray.Shape = "Ball" 
ray.Size = Vector3.new(0.4, 0.4, 0.4) 
ray.CanCollide = false 
ray.Transparency = 0.0 

local bullet = Instance.new("SpecialMesh") 
bullet.MeshId = "http://www.roblox.com/asset/?id=65020210" 
bullet.TextureId = "http://www.roblox.com/asset/?id=65020347" 
bullet.Parent = ray 
bullet.Scale = Vector3.new(0.02, 0.02, 0.02) 

local runService = game:service("RunService")

function slashIt(myHumanoid, myTorso) 
	shieldBash = myHumanoid:LoadAnimation(Tool["ShieldBash"]) 
	if shieldBash == nil then Tool.Enabled = true return end 
	shieldBash:Play() 
	local target = myHumanoid.TargetPoint 
	local direction = (target - myTorso.Position) * Vector3.new(1, 0, 1) 
	newBV = nil 
	if direction.magnitude > .01 then            
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = myTorso 
		myTorso.CFrame = CFrame.new(myTorso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, myTorso.Position.Y, 0)) 
	end 
	wait(.5)       
	if newBV ~= nil then newBV:remove() end 
	wait(.5) 
end 

function onKeyDown(key)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	if key:lower() == "q" then 
		if vCharacter:FindFirstChild("Shield") then 
			print("Found Shield")

			local shield = vCharacter.Shield 
			connection = shield.Touched:connect(bash)

			torso = vCharacter.Torso
			shieldWeld = torso:FindFirstChild("ShieldHolder")
			leftArm = vCharacter:FindFirstChild("Left Arm")
			if shieldWeld then 
				shieldWeld.Parent = leftArm
				shieldWeld.Part0 = leftArm				
				
				shieldWalkAnim = myHumanoid:LoadAnimation(Tool.ShieldWalk)
				shieldWalkAnim:Play()

				shieldWeld.C1 = (shieldWeld.C1 + Vector3.new(-0.3, -0.1, 0)) * CFrame.Angles(-math.pi/5, math.pi, math.pi/5)	
				if Tool.ShieldActive then Tool.ShieldActive.Value = 1 end
				ratio = myHumanoid.Health/myHumanoid.MaxHealth
				print(ratio)
				myHumanoid.MaxHealth = 130			
				wait(0.2)
				myHumanoid.Health = ratio * 130				
				myHumanoid.WalkSpeed = 16.0
				
			else
				shieldWeld = leftArm:FindFirstChild("ShieldHolder")
				if shieldWeld then
					shieldWeld.Parent = torso
					shieldWeld.Part0 = torso 							
					--shieldWeld.C1 = CFrame.Angles(-math.pi/2, math.pi, 0) * CFrame.new(Vector3.new(0, 0.2, -1.1))				
					shieldWeld.C1 =  CFrame.Angles(-math.pi/2, 0, math.pi) * CFrame.new(Vector3.new(0, 0.2, -0.8))
				end
				if shieldWalkAnim then shieldWalkAnim:Stop() end
				if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end
				if myHumanoid.MaxHealth > 100 then 
					ratio = myHumanoid.Health/myHumanoid.MaxHealth 
					myHumanoid.Health = ratio * 100
					myHumanoid.MaxHealth = 100	
					myHumanoid.WalkSpeed = 16.0
				end
			end			
		end
	end
	shieldActive = Tool:FindFirstChild("ShieldActive")
	if key == "e" and shieldActive then 
		if Tool.Enabled and shieldActive.Value == 1 then 
			Tool.Enabled = false 
			shieldBash = myHumanoid:LoadAnimation(Tool.ShieldBash)
			if shieldBash then shieldBash:Play() end 	
			wait(1.0)
			Tool.Enabled = true 
		end 
	end 
	
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
end

local debris = game:GetService("Debris") 

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue") 
		creatorTag.Value = player 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1) 
	end 
end 

function bash(hit)	
	print("Bashing")
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		local opponent = hit.Parent:FindFirstChild("Torso")
		myTorso = vCharacter:FindFirstChild("Torso")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		print(1)
		if humanoid ~=nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
			print(2)
			leftArm = vCharacter:FindFirstChild("Left Arm")
			if leftArm then 
				shieldGrip = leftArm:FindFirstChild("ShieldHolder")
				if shieldGrip then
					print(3)
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(bashDamage)																															
				end
			end
		end
	end
end

function shoot(pos, target) 
	print("Shoot")
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	myTorso = vCharacter:FindFirstChild("Torso") 
	if vPlayer == nil or myTorso == nil then 
		return 
	end 

	spawnPos = myTorso.Position 
	spawnPos = spawnPos + pos.unit * 5.0 

	local rayC = ray:Clone() 
	rayC.CFrame = CFrame.new(spawnPos, spawnPos + pos) 
	rayC.Parent = game.Workspace 

	bodyForce = Instance.new("BodyForce") 
	bodyForce.force = Vector3.new(0.0, rayC:GetMass() * 196.1, 0.0) 
	bodyForce.Parent = rayC 

	rayC.Velocity = pos.unit * 450.0 

	local hit, destination = game.Workspace:FindPartOnRay(Ray.new(Gun.Position + pos*minRange, pos*maxRange), vCharacter) 

	if hit then 
		print(hit)
		if hit.Name == "Head" then damage = 35 else damage = 20 end 
		if hit.Parent.className == "Hat" then 
			damage = 30 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
		else 			
			humanoid = hit.Parent:FindFirstChild("Humanoid") 
		end 
		if humanoid and humanoid ~= myHumanoid then                      
			local character = humanoid.Parent 
			wait(0.1) 
			tagHumanoid(humanoid, vPlayer) 
			humanoid:TakeDamage(damage)        		
		end 
	end      
	debris:AddItem(rayC, 2) 
end 

function onActivatedLocal() 
	if Tool.Enabled == false then 
		return 
	end 

	Tool.Enabled = false 

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") 
	if not myTorso then 
		return 
	end 

	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if not myHumanoid then 
		return 
	end 

	t = runService.Stepped:wait() 

	shieldActive = Tool:FindFirstChild("ShieldActive")
	if t - dashTime < 0.2 and shieldActive and shieldActive.Value == 1 then 
		slashIt(myHumanoid, myTorso)
		wait(0.5)
		amAnimating = false 
	else 
		local target = myHumanoid.TargetPoint 
		local direction = (target - Gun.Position).unit 

		gunSound = Gun:FindFirstChild("GunSound") 
		if gunSound then gunSound:Play() end 

		shoot(direction, target) 
	end 
	wait(0.8) 
	Tool.Enabled = true 
end 

function onEquippedLocal(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedLocal()
	if shieldWalkAnim then shieldWalkAnim:Stop() end
	if slashAnim then slashAnim:Stop() end
	if bashAnim then bashAnim:Stop() end
	if spinAnim then spinAnim:Stop() end

	if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end

	if vCharacter then
		leftArm = vCharacter:FindFirstChild("Left Arm")
		if leftArm then 
			shield = vCharacter:FindFirstChild("Shield")
			shieldWeld = leftArm:FindFirstChild("ShieldHolder")
		end
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			ratio = myHumanoid.Health/myHumanoid.MaxHealth
			myHumanoid.Health = ratio * 100
			myHumanoid.MaxHealth = 100
			myHumanoid.WalkSpeed = 16.0
		end
	end
	if connection then connection:disconnect() end		
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
	if shieldBash then shieldBash:Stop() end 
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivatedLocal)