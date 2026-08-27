local Tool = script.Parent 
local Catapult = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

local debris = game:GetService("Debris")

Tool.Enabled = true 

local catapultHealth = 600

local catapultActive = false
local myCatapult
local catapultWeld

local frontAxleWeld
local backAxleWeld

local damage = 50

local projectile = Instance.new("Part")
projectile.FormFactor = 3 
projectile.Size = Vector3.new(2.4, 2.4, 2.4)
projectile.Name = "Projectile" 
projectile.CanCollide = false

local projectileMesh = Instance.new("SpecialMesh")
projectileMesh.MeshId = "http://www.roblox.com/asset/?id=1290033"
projectileMesh.TextureId = "http://www.roblox.com/asset/?id=1290030"
projectileMesh.Parent = projectile

local fire = Instance.new("Fire")
fire.Parent = projectile

local antiFloatForce = Instance.new("BodyForce")
antiFloatForce.force = Vector3.new(0, -90000, 0)
antiFloatForce.Parent = myTorso

local lightForce = Instance.new("BodyForce") 

local jumpConnection
local runningConnection

function destroyCatapult()
	Catapult.Transparency = 0.0
	if myCatapult then myCatapult:Remove() end 
	if catapultWeld then catapultWeld:Remove() end 
	catapultActive = false 
	if myHumanoid then
		myHumanoid.WalkSpeed = 16
		local ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.Health = ratio * 100 
		myHumanoid.MaxHealth = 100
	end 
	if jumpConnection then jumpConnection:disconnect() end 
	if runningConnection then runningConnection:disconnect() end
	if antiFloatingForce then antiFloatingForce:Remove() end
end

function boom(hit)
	if hit and hit.Parent then 
		if hit.Parent:IsA("Tool") then 
			local tool = hit.Parent 		
			local character = tool.Parent 
			local player = game.Players:GetPlayerFromCharacter(player)
			if player then 
				catapultHealth = catapultHealth - 75 
				if catapultHealth < 0 then 
					destroyCatapult() 
				end 
			end
		else		
			if hit.Parent == game.Workspace and hit.Velocity.magnitude > 30 then  -- It might be a projectile, lets just do damage
				catapultHealth = catapultHealth - 60 
				if catapultHealth < 0 then 
					destroyCatapult()
				end 
			end 
		end 
	end 
end 

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 		
		tagHumanoid(humanoid, vPlayer)				
		humanoid:TakeDamage(damage)						
	end	
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag,  1)
	end
end

function shoot(target, direction, distance)
	if myTorso == nil or myHumanoid == nil then return end 
	local projectileClone = projectile:Clone()

	local speed = 50

	local upVector = Vector3.new(0, 1, 0)
	local dy = direction.Y
	direction = (direction *  Vector3.new(1, 0, 1))
	local dxz = direction.magnitude 
	local xzVelocity = direction.unit * speed
	local yVelocity = ((speed * dy / dxz) + ((196.1 * dxz)/(2 * speed))) * upVector
	
	print(dy, dxz)
	
	local spawnPos = myTorso.Position 
		
	projectileClone.CFrame = CFrame.new(spawnPos, spawnPos + myTorso.CFrame.lookVector)
	projectileClone.Velocity = xzVelocity + yVelocity	
	projectileClone.RotVelocity = Vector3.new(0, 10, 0)

	local floatForce = Instance.new("BodyForce") 	
	floatForce.force = Vector3.new(0, projectileClone:GetMass() * 190, 0)	
	
	projectileClone.Parent = game.Workspace 
	projectileClone.Touched:connect(blow)
	debris:AddItem(projectileClone, 7) 
	
	wait(0.5)
	projectileClone.CanCollide = true 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	if catapultActive == false then 

		Tool.Enabled = false 
		catapultActive = true 

		myCatapult = game:GetService("InsertService"):LoadAsset(69939157):GetChildren()[1] 
		if myCatapult and myCatapult:FindFirstChild("Base") then 
			Catapult.Transparency = 1.0 

			myCatapult.Parent = game.Workspace

			myCatapult:MoveTo(myTorso.Position + myTorso.CFrame.lookVector * 5.0) 

			if myCatapult:FindFirstChild("Base") then 
				myCatapult.Base.CFrame = CFrame.new(myCatapult.Base.Position, myCatapult.Base.Position + myTorso.CFrame.lookVector) * CFrame.Angles(-math.pi/2, 0, 0)
				local children = myCatapult:GetChildren() 
				local mass = 0
				for i = 1, #children do 
					if children[i]:IsA("BasePart") then 
						mass = mass + children[i]:GetMass() -- Not used!
					end 
				end 		
								
				myCatapult.Base.Touched:connect(boom) 				
			end 			

			wait(0.5)
			
			catapultWeld = Instance.new("Weld")
			catapultWeld.Parent = myTorso 
			catapultWeld.Part0 = myTorso 
			catapultWeld.Part1 = myCatapult.Base
			catapultWeld.C1 = CFrame.new(0, -5, 0, 1, 0, -2.18556949e-007, -2.18556949e-007, 9.55342796e-015, -1, 0, 1, 9.55342711e-015)

			myHumanoid.WalkSpeed = 4.0
			myTorso.Anchored = false

			catapultHealth = 600
 
			local ratio = myHumanoid.Health/myHumanoid.MaxHealth 
			myHumanoid.MaxHealth = 300 
			while myHumanoid.MaxHealth < 300 do 
				myHumanoid.MaxHealth = 300 
			end 
			while myHumanoid.Health < ratio * 300 do 
				myHumanoid.Health = myHumanoid.Health * 300 
			end 

			jumpConnection = myHumanoid.Jumping:connect(function()				
				if myTorso and myTorso:FindFirstChild("BF") == nil  then					
					local antigravForce = Instance.new("BodyForce")
					antigravForce.force = Vector3.new(0, -990001, 0)
					antigravForce.Name = "BF"
					antigravForce.Parent = myTorso
					wait(0.7)
					if antigravForce then antigravForce:Remove() end 
				end 					
			end)
		
			if myCatapult and myCatapult:FindFirstChild("Base") then 
				local base = myCatapult.Base 
				if base:FindFirstChild("FrontAxleWeld") and base:FindFirstChild("BackAxleWeld")  then 
					frontAxleWeld = base.FrontAxleWeld 
					backAxleWeld = base.BackAxleWeld
				end 
			end 

			runningConnection = myHumanoid.Running:connect(function()
				if frontAxleWeld and backAxleWeld then 
					frontAxleWeld.C1 = CFrame.Angles(math.pi/8, 0, 0) * frontAxleWeld.C1 
					backAxleWeld.C1 = CFrame.Angles(math.pi/8, 0, 0) * backAxleWeld.C1
				end 
				if myTorso and myTorso:FindFirstChild("BV") == nil then 				
				end 
			end)

			coroutine.resume(coroutine.create(function()
				wait(90)
				destroyCatapult()
			end)) 

			wait(2.0)
			Tool.Enabled = true
		else 
			Tool.Enabled = true 
		end 
	else 		
		local base = myCatapult:FindFirstChild("Base") 
		if base then			
			local distance = (myTorso.Position - base.Position).magnitude
			print(distance)
			if distance < 12 then
				Tool.Enabled = false
				-- Shoot warrocks
				coroutine.resume(coroutine.create(function() 
					if myCatapult and myCatapult:FindFirstChild("Base") then 
						local base = myCatapult.Base 
						local lWeld = base:FindFirstChild("LauncherWeld")
						if lWeld then 
							local frames = 9	
							local initCFrame = lWeld.C1 
							while frames > 0 do 
								if frames < 5 then 
									-- snap back
									lWeld.C1 = lWeld.C1 * CFrame.Angles(math.pi/16, 0, 0)
								else 
									lWeld.C1 = lWeld.C1 * CFrame.Angles(-math.pi/20, 0, 0)
								end 
								frames = frames - 1
								wait(0.15)
							end 
							lWeld.C1 = initCFrame
						end 	
					end 
				end)) 
				local target = myHumanoid.TargetPoint
				wait(0.90)				
				local direction = (target - myTorso.Position)
				local distance = (target - myTorso.Position).magnitude
				shoot(target, direction, distance) 
				wait(3.0) 
				Tool.Enabled = true
			end 
		end 
	end 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	
	Catapult.Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripPos = Vector3.new(0, -0.4, -1)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function onUnequipped()
	destroyCatapult()
	catapultHealth = 600
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

local breakIt = Tool:FindFirstChild("BreakCatapult")
while breakIt == nil do 
	breakIt = Tool:FindFirstChild("BreakCatapult")
end 

breakIt.Changed:connect(function()
	if breakIt and breakIt.Value == true and catapultActive and myCatapult and myCatapult:FindFirstChild("Base") then 
		if catapultWeld then catapultWeld:Remove() end 
		wait(0.35)
		myCatapult.Base.CFrame = myCatapult.Base.CFrame + Vector3.new(1, 3.5, 0)
		myCatapult.Base.Anchored = true
		wait(0.6)
		myCatapult.Base.Anchored = false 
		if myCatapult then myCatapult:BreakJoints() end 
		if myTorso and myTorso:FindFirstChild("CatapultWeld") then 
			myTorso.CatapultWeld:Remove()
		end

		debris:AddItem(myCatapult, 3)				
		catapultActive = false 
		if myHumanoid then
			myHumanoid.WalkSpeed = 16
			local ratio = myHumanoid.Health/myHumanoid.MaxHealth
			myHumanoid.Health = ratio * 100 
			myHumanoid.MaxHealth = 100
		end 

		if jumpConnection then jumpConnection:disconnect() end 
		if runningConnection then runningConnection:disconnect() end

		local players = game.Players:GetChildren()
		for i = 1, #players do
			if players[i] and players[i].Character and players[i].Character:FindFirstChild("Humanoid") and players[i].Character:FindFirstChild("Torso") and players[i] ~= vPlayer then 
				local torso = players[i].Character.Torso 
				local humanoid = players[i].Character.Humanoid 
				local distance = (torso.Position - myTorso.Position).magnitude
				if distance < 12 then 
					humanoid.Sit = true 
					humanoid:TakeDamage(40)
				end 
			end 
		end 

		Catapult.Transparency = 0.0
		
		wait(9.0)
		breakIt.Value = false 		
	else 
		wait(5.0)
		breakIt.Value = false 
	end 
end) 
