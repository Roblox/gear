local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter
local quiver
local quiverWeld
local arrows = {}

local debris = game:GetService("Debris")

Tool.Enabled = true 

arrow = Instance.new("Part")
arrow.FormFactor = 3
arrow.Shape = "Block"
arrow.Size = Vector3.new(3.0, 0.5, 0.5)
arrow.CanCollide = false 
arrow.Name = "Arrow"

arrowMesh = Instance.new("SpecialMesh")
arrowMesh.MeshId = "http://www.roblox.com/asset/?id=72029821"
arrowMesh.TextureId =  "http://www.roblox.com/asset/?id=7209808"
arrowMesh.Scale = Vector3.new(1.4, 1.4, 1.4)
arrowMesh.Parent = arrow

local damage = 40

local arrows = {}

local arrowWeld

local spamArrow 

function onTouch(arrow, hit)
	if arrow and hit and hit.Parent and hit ~= Bow then
		print(hit.Name)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")	
		if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
			tag = arrow:FindFirstChild("creator")
			if tag then tag.Parent = humanoid end
			if hit.Name == "Head" then damage = 90 end
			humanoid:TakeDamage(damage)
			damage = 40					
		end		
		if arrow and hit.Name ~= "Arrow" then arrow:Remove() end
	end
end

function shoot(arrow, direction)
	vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		return
	end
	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.Torso.Position
	spawnPos = spawnPos + direction.unit * 7.0	

	local sign = -1

	spamArrow = Tool:FindFirstChild("SpamArrow")
	if spamArrow and spamArrow.Value == 1 then 
		myHumanoid.WalkSpeed = 0.0
		for i = 1, 10 do 	
			local d1 = direction 
			arrows[i] = arrow:Clone()
			if i ~= 0 then 
				d1 = CFrame.Angles(0, (i-1) * sign * math.pi/270, 0) * direction 
			end
			local spawnPos = vCharacter.Torso.Position
			spawnPos = spawnPos + direction.unit * 7.0			
	
			arrows[i].CFrame = CFrame.new(spawnPos, spawnPos + d1) * CFrame.Angles(-math.pi/2, math.pi/2, 0)
			arrows[i].Velocity = d1 * 80.0

			local arrowFloat = Instance.new("BodyForce")
			arrowFloat.force =  Vector3.new(0.0, arrow:GetMass() * 196.1, 0.0)
			arrowFloat.Parent = arrows[i]	

			arrows[i].Name = "Arrow"

			arrows[i].CanCollide = false

			--[[local touchScript = Tool.OnTouchScript:Clone()
			touchScript.Parent = arrows[i]
			touchScript.Disabled = false ]]

			arrows[i].Parent = game.Workspace
				
			arrows[i].Touched:connect(function(hit)  onTouch(arrows[i], hit) end)
			debris:AddItem(arrows[i], 500)
			sign = sign * -1

			local fire = Instance.new("Fire")
			fire.Parent = arrows[i]
			fire.Color = Color3.new(165/255, 0, 33/255)
			fire.SecondaryColor = Color3.new(1, 1, 0)
	
			--arrows[i].Anchored = true
			wait(0.1)
		end
		myHumanoid.WalkSpeed = 16.0
	else 
		arrow.CFrame = CFrame.new(spawnPos, spawnPos + direction) * CFrame.Angles(-math.pi/2, math.pi/2, 0)

		local arrowFloat = Instance.new("BodyForce")
		arrowFloat.force =  Vector3.new(0.0, arrow:GetMass() * 196.1, 0.0)
		arrowFloat.Parent = arrow

		arrow.Velocity = direction.unit * 70.0
		arrow.RotVelocity = Vector3.new(0.0, 0.0, 0.0)
		arrow.Name = "Arrow"
		arrow.Parent = game.Workspace
		arrow.CanCollide =  false	
			
		arrow.Touched:connect(function(hit)  onTouch(arrow, hit) end)
		debris:AddItem(arrow, 5)
	end	
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end		

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if torso == nil then 
		return
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	arrowClone = arrow:Clone()

	wait(0.6)
	target = myHumanoid.TargetPoint 
	direction = (target - vCharacter.Torso.Position).unit
	shoot(arrowClone, direction)		

	wait(2.0)		
	Tool.Enabled = true
end

function onEquipped()
	print("On equip")
	vCharacter = Tool.Parent 
	torso = vCharacter:FindFirstChild("Torso")
	if torso ~= nil and vCharacter:FindFirstChild("Quiver") == nil then 
		quiver = Instance.new("Part")
		quiver.Name = "Quiver"
		quiver.Shape = "Block"
		quiver.FormFactor = 3
		quiver.Size = Vector3.new(1.2, 0.5, 2.0)
		quiver.CanCollide = false
		--quiver.Parent = vCharacter
		
		quiverMesh = Instance.new("SpecialMesh")
		quiverMesh.MeshId = "http://www.roblox.com/asset/?id=65942352"
		quiverMesh.TextureId = "http://www.roblox.com/asset/?id=65941746"
		quiverMesh.Scale = Vector3.new(1.2,1.2,1.2)		
		--quiverMesh.Parent = quiver

		quiverWeld = Instance.new("Weld")
		quiverWeld.Name = "QuiverHolder"
		quiverWeld.Part0 = torso
		quiverWeld.Part1 = quiver
		quiverWeld.C1 = CFrame.new(Vector3.new(0.0, -0.2, -0.65)) 
		--quiverWeld.Parent = torso

		rightArm = vCharacter:FindFirstChild("Right Arm")
		leftArm = vCharacter:FindFirstChild("Left Arm")
		if rightArm then rightGrip = rightArm:FindFirstChild("RightGrip") end
		if rightGrip then 
			rightGrip.Parent = leftArm
			rightGrip.Name = "LeftGrip"
			rightGrip.Part0 = leftArm
			rightGrip.Part1 = Bow
		end				
	end
end

function onUnequipped()
	if vCharacter then
		torso = vCharacter:FindFirstChild("Torso")
	end
		
	if torso then
		quiver = vCharacter:FindFirstChild("Quiver")
		quiverWeld = torso:FindFirstChild("QuiverHolder")
	end

	if quiver then quiver:Remove() end
	if quiverWeld then quiverWeld:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)