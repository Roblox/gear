local Tool = script.Parent
local Wand = Tool.Handle

local vCharacter
local myHumanoid
local myTorso 
local vPlayer 

Tool.Enabled = true 

local debris = game:GetService("Debris")

local wandDamage = 5 

local ball = Instance.new("Part") 
ball.FormFactor = 3 
ball.Shape = "Block" 
ball.Size = Vector3.new(0.4, 0.4, 0.4) 
ball.CanCollide = false 
ball.Transparency = 0.0 

local bullet = Instance.new("SpecialMesh") 
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032" 
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568" 
bullet.Parent = ball 
bullet.Scale = Vector3.new(2, 2, 2) 

local ballFire = Instance.new("Fire") 
ballFire.Color = Color3.new(102/255, 0, 51/255) 
ballFire.Parent = ball 
ballFire.Size = 2.0 
ballFire.Heat = 2.0 

local snarlSound

local turkeys = {}

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		creatorTag.Value = player 
		debris:AddItem(creatorTag, 1.5) 
	end 
end

function turkify(character)	

	print("Turkifying")

	local humanoid = character:FindFirstChild("Humanoid")
	humanoid.WalkSpeed = 8.0
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

	if humanoid == nil or torso == nil then print("One is nil") return end

	local headDecal 

	print("Setting Character Stuff")
	local children = character:GetChildren()
	print(#children)
	for i = 1, #children do 		
		if children[i]:IsA("BasePart") then			
			children[i].Transparency = 1.0 
		end
		if children[i]:IsA("Accessory") or children[i]:IsA("Tool") then 
			children[i].Handle.Transparency = 1.0
			print(children[i].Handle)
		end	
		if children[i].Name == "Head" then 
			headDecal = children[i].face 
			headDecal.Parent = nil
			print("Setting Decal to nil")
		end
	end

	local turkey = game:GetService("InsertService"):LoadAsset(65943300)
	if turkey then 
		turkey = turkey:GetChildren()[1]
	end
	
	print("Setting Parent")
	turkey.Parent = game.Workspace
	turkey:MoveTo(torso.Position + Vector3.new(0, -5, 0))
	turkey.PrimaryPart.CFrame = (torso.CFrame + torso.CFrame.lookVector * -3) + Vector3.new(0, -1.35, 0)	

	local duration  = 4.5	
	
	while duration > 0 do 		
		duration = duration - wait()				
		turkey.PrimaryPart.CFrame = torso.CFrame + torso.CFrame.lookVector * -3 + Vector3.new(0, -1.35, 0)
		wait()
		local ch = character:GetChildren() 
		for i = 1, #ch do 
			if ch[i]:IsA("Tool")then 
				player = game.Players:GetPlayerFromCharacter(character)
				if player then 
					local backpack = player.Backpack 
					if backpack then ch[i].Parent = backpack end
				else  
					ch[i]:Destroy()
				end
			end
		end
	end

	local children = character:GetChildren()
	for i = 1, #children do 
		if children[i]:IsA("BasePart") and children[i].Name ~= "HumanoidRootPart" then
			children[i].Transparency = 0.0 
		end
		if children[i]:IsA("Accessory") or children[i]:IsA("Tool") then 
			children[i].Handle.Transparency = 0.0
		end	
		if children[i].Name == "Head" then 			
			headDecal.Parent = children[i]
		end
	end
	
	print("Removing Turkey")
	if turkey then turkey:Destroy() end
	humanoid.WalkSpeed = 16.0

	wait(3.0)
	turkeys[humanoid] = nil 
end

function pierce(missile, hit) 
	local humanoid 
	if missile then 
		if hit.Parent and hit then 
			if hit.className == "Hat" then 
				humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
			else 
				humanoid = hit.Parent:FindFirstChild("Humanoid") 
			end 
			if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
				if missile then missile:Destroy() end
				tagHumanoid(humanoid, vPlayer) 
				humanoid:TakeDamage(wandDamage) 			
				if turkeys[humanoid] == nil then
					turkeys[humanoid] = true 
					coroutine.resume(coroutine.create(function() turkify(humanoid.Parent) end))
				end				
			end 
		end 
	end 
end 

function shoot(direction) 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if vPlayer == nil then return end 

	local spawnPos = Wand.Position + direction * 4.0 

	local missile = ball:Clone() 
	missile.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	missile.Velocity = direction * 90.0 
	missile.RotVelocity = Vector3.new(0, 10, 0) 

	local floatForce = Instance.new("BodyForce") 
	floatForce.force = Vector3.new(0, missile:GetMass() * workspace.Gravity, 0) 
	floatForce.Parent = missile 

	missile.Parent = game.Workspace 

	missile.Touched:connect(function(hit) pierce(missile, hit) end) 

	debris:AddItem(missile, 5) 
end 

function staffUp()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function staffDown()
	Tool.GripForward = Vector3.new(0, 0.848, 0.53)	
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, -0.53, 0.848) 
end

function onActivated() 
	if Tool.Enabled == false then 
		 return 
	end 

	Tool.Enabled = false 

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myTorso == nil or myHumanoid == nil then 
		 return 
	end 

	local target = myHumanoid.TargetPoint 
	local direction = (target - Wand.Position).unit 
	staffDown()
	shoot(direction) 

	snarlSound = Tool:FindFirstChild("SnarlSound")
	if snarlSound then snarlSound:Play() end

	wait(0.9)
	staffUp()	

	wait(3.25) 
	Tool.Enabled = true 
end 

function onEquipped() 	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end 

function onUnequipped() 
	if snarlSound then snarlSound:Stop() end
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 

