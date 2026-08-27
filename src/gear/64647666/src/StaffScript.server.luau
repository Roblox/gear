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

local bullet = Instance.new("SpecialMesh") 
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032" 
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568" 
bullet.Parent = ball 
bullet.Scale = Vector3.new(2, 2, 2) 

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
			--	humanoid:TakeDamage(staffDamage) 
				if humanoid.Parent:FindFirstChild("ZombifyScript") == nil then 	
					local cloneScript = Tool.ZombifyScript:Clone()
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

