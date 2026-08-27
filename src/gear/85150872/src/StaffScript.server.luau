--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter
local myHumanoid
local myTorso 
local vPlayer 

Tool.Enabled = true 

local debris = game:GetService("Debris")

local staffDamage = 25 

local ball = Instance.new("Part") 
ball.FormFactor = 3 
ball.Shape = "Block" 
ball.Size = Vector3.new(0.4, 0.4, 0.4) 
ball.CanCollide = false 
ball.Transparency = 0.0 

local SnakeMesh = Instance.new("SpecialMesh") 
SnakeMesh.Name = "Mesh" 
SnakeMesh.MeshId = "http://www.roblox.com/asset/?id=49046138" 
SnakeMesh.TextureId = "http://www.roblox.com/asset/?id=49046409" 
SnakeMesh.Scale = Vector3.new(0.5, 0.5, 0.5) 
SnakeMesh.Parent = ball


local ballFire = Instance.new("Fire") 
ballFire.Color = Color3.new(0, 1, 0) 
ballFire.Parent = ball 
ballFire.Size = 2.0 
ballFire.Heat = 2.0 

local snarlSound

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		creatorTag.Value = player 
		debris:AddItem(creatorTag, 1.5) 
	end 
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
				tagHumanoid(humanoid, vPlayer) 
				humanoid:TakeDamage(staffDamage) 
				if humanoid.Parent:FindFirstChild("CobraScript") == nil then 	
					local cloneScript = Tool.CobraScript:Clone()
					cloneScript.Parent = humanoid.Parent 
					cloneScript.Disabled = false
				end
			end 
		end 
	end 
end 

function shoot(direction) 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if vPlayer == nil then return end 

	local spawnPos = Staff.Position + direction * 4.0 

	local missile = ball:Clone() 
	missile.CFrame = CFrame.new(spawnPos) * CFrame.Angles(math.pi/2, math.pi, 0) 
	missile.Velocity = direction * 90.0 
	--missile.RotVelocity = Vector3.new(0, 10, 0) 

	local floatForce = Instance.new("BodyForce") 
	floatForce.force = Vector3.new(0, missile:GetMass() * 196.1, 0) 
	floatForce.Parent = missile 

	missile.Parent = game.Workspace 

	missile.Touched:connect(function(hit) pierce(missile, hit) end) 

	debris:AddItem(missile, 5) 
end 

function staffUp()
	Tool.Grip = CFrame.new(0, -1.5, 0.200000003, 1, 0, 0, 0, 1, -0, -0, 0, 1)
end

function staffDown()
	Tool.Grip = CFrame.new(0, -1.5, 0.200000003, 1, 0, 0, 0, 0.87279582, -0.488085508, -0, 0.488085508, 0.87279582)
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
	local direction = (target - Staff.Position).unit 
	staffDown()
	shoot(direction) 

	wait(0.9)
	staffUp()

	snarlSound = Tool:FindFirstChild("SnarlSound")
	if snarlSound then snarlSound:Play() end

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

