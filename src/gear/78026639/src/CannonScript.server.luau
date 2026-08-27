local Tool = script.Parent 
local RHead = Tool.Handle

Tool.Enabled = true

local vCharacter
local vTorso
local vHead 
local vHumanoid 
local vPlayer

local Rocket = Instance.new("Part")
Rocket.Size = Vector3.new(0.5, 3, 0.5)
Rocket.Transparency = 0.0
Rocket.Shape = "Block"
Rocket.FormFactor = 3
Rocket.Name = "RocketClone"
Rocket.CanCollide = false

local RocketMesh = Instance.new("SpecialMesh")
RocketMesh.MeshType = "FileMesh"
RocketMesh.Name = "Mesh"
RocketMesh.MeshId = "http://www.roblox.com/asset/?id=74333739"
RocketMesh.TextureId = "http://www.roblox.com/asset/?id=74320150"
RocketMesh.Scale = Vector3.new(2, 2, 2)
RocketMesh.Parent = Rocket

local RBX_Debris = game:GetService("Debris")

function blow(part, hit)
	if hit.Name ~= "RocketClone" and hit.Parent ~= vCharacter and hit.Parent ~= Tool and part then     		
		humanoid = hit.Parent:FindFirstChild("Humanoid")          
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 9999999
		e.BlastRadius = 3.5
		e.Position = part.Position          
		e.Parent = game.Workspace
		RBX_Debris:AddItem(e, 1.0)                    
		vCharacter = Tool.Parent
		if part then part:Remove() end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and vPlayer then
			tagHumanoid(humanoid, vPlayer)			
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		RBX_Debris:AddItem(creatorTag, 1)
	end
end 

local function shoot(direction)
	if not vHead then return end 
	local spawnPos = vHead.Position + direction * 4.0
	
	local missile = Rocket:Clone() 
	missile.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	
	local floatForce = Instance.new("BodyForce")
	floatForce.Name = "Float"
	floatForce.force = Vector3.new(0, missile:GetMass() * 196.2, 0)
	floatForce.Parent = missile 
	
	missile.Velocity = direction * 120.0 
	missile.Parent = game.Workspace 
	
	RBX_Debris:AddItem(missile, 5.5)
	wait(0.1)
	missile.Touched:connect(function(hit) 
		blow(missile, hit)
	end)  
end 


local function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if vTorso == nil or vHumanoid == nil or vHead == nil then
		return
	end 

	Tool.Enabled = false 

	local target = vHumanoid.TargetPoint 
	local direction = (target - vHead.Position).unit

	shoot(direction)

	wait(2.0)
	Tool.Enabled = true 
end

local function onEquipped()
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vTorso = vCharacter:FindFirstChild("Torso")
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vHead = vCharacter:FindFirstChild("Head")

	local charChildren = vCharacter:GetChildren()
	for i = 1, #charChildren do 
		if charChildren[i]:IsA("Hat") then 
			local hatHandle = charChildren[i]:FindFirstChild("Handle")
			if hatHandle then 
				hatHandle.Transparency = 1.0
			end 
		end 
	end 
	vCharacter.ChildRemoved:connect(function(child)
		if child:IsA("Hat") and child:FindFirstChild("Handle") then 
			child.Handle.Transparency = 0.0
		end 
	end) 
	while vCharacter:FindFirstChild("Right Arm") == nil do wait() print("still waiting") end 
	local rightArm = vCharacter:FindFirstChild("Right Arm")
	if  rightArm and rightArm:FindFirstChild("RightGrip") then
		local rGrip = rightArm.RightGrip
		rGrip.Part0 = vHead 
		rGrip.Part1 = RHead
		rGrip.C1 = CFrame.new(0, -0.0500000007, -1.25, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		rGrip.Parent = vHead 
	end 
end

local function onUnequipped()
	if vCharacter then
		local charChildren = vCharacter:GetChildren()
		for i = 1, #charChildren do 
			if charChildren[i]:IsA("Hat") then 
				local hatHandle = charChildren[i]:FindFirstChild("Handle")
				if hatHandle then 
					hatHandle.Transparency = 0.0
				end 
			end 
		end 
	end
	if vHumanoid then vHumanoid.WalkSpeed = 16.0 end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

while Tool:FindFirstChild("RapidFire") == nil do wait() end 

local rFire = Tool.RapidFire
rFire.Changed:connect(function()
	if rFire.Value == true then
		Tool.Enabled = false
		vHumanoid.WalkSpeed = 8.0 
		for i = 1, math.random(9, 11) do 				
			local target = vHumanoid.TargetPoint 
			local direction = CFrame.Angles(math.random()/50, math.random()/50, math.random()/50) * (target - vHead.Position).unit 
			shoot(direction) 
			wait(0.05)
		end  
		wait(1.0)
		vHumanoid.WalkSpeed = 16.0
		wait(5.0)
		Tool.Enabled = true 		
		wait(3.0)
		rFire.Value = false 
	end 
end) 



