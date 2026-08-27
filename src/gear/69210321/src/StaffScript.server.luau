local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter
local myHumanoid
local myTorso 
local vPlayer 

Tool.Enabled = true 

local debris = game:GetService("Debris")

local staffDamage = 17 

local orb = Instance.new("Part") 
orb.FormFactor = 3 
orb.Shape = "Block" 
orb.Size = Vector3.new(0.4, 0.4, 0.4) 
orb.CanCollide = false 
orb.Transparency = 0.0 

local orbMesh = Instance.new("SpecialMesh") 
orbMesh.MeshId = "http://www.roblox.com/asset/?id=66877034" 
orbMesh.TextureId = "http://www.roblox.com/asset/?id=68915275" 
orbMesh.Parent = orb 
orbMesh.Scale = Vector3.new(2, 2, 2) 

local orbFire = Instance.new("Fire") 
orbFire.Color = Color3.new(102/255, 0, 204/255) 
orbFire.SecondaryColor = Color3.new(102/255, 0, 204/255)
orbFire.Parent = orb 
orbFire.Size = 2.0 
orbFire.Heat = 2.0 

local bg
local slowCo = nil

local torsoFrame = {}
local darknessSound


local abyss = Tool:FindFirstChild("Abyss")
while abyss ==  nil do 	
	wait()
	abyss = Tool:FindFirstChild("Abyss")
end


local firePart = Staff:FindFirstChild("FirePart")
local storeWeld = Staff:FindFirstChild("FireWeld")
while storeWeld == nil or firePart == nil do 
	firePart = Staff:FindFirstChild("FirePart")
	storeWeld = Staff:FindFirstChild("FireWeld")
	wait()
end


function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		creatorTag.Value = player 
		debris:AddItem(creatorTag, 1.5) 
	end 
end

function cyclone()	
	if myTorso == nil then return end

	bg = Instance.new("BodyGyro") 
	bg.P = 100000 
	bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P) 
	bg.Name = "BG" 

	torsoFrame[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0) 
	torsoFrame[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0) 
	torsoFrame[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0) 
	torsoFrame[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0) 
	torsoFrame[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0) 
	torsoFrame[6] = myTorso.CFrame 

	bg.Parent = myTorso 

	for i = 1, 60 do 
		local c = i%6 + 1 
		if bg then bg.cframe = torsoFrame[c] end 
		wait() 
	end     
	if bg then bg:Remove() end
end

function staffUp()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(1, 0, 0)	
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function staffDown()
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1 , 0)
end

function destroyEverything()
	local sign = 1 
	local missiles = {} 
	abyss = Tool:FindFirstChild("Abyss")
	if abyss and abyss.Value == true then 
		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid") 
		myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

		if myHumanoid == nil or myTorso == nil then            
			return 
		end 

		laughSound = Staff:FindFirstChild("Laugh") 
		if laughSound then laughSound:Play() end 
		
		myHumanoid.WalkSpeed = 0.0   
		local initDirection = myTorso.CFrame.lookVector

		coroutine.resume(coroutine.create(cyclone))

		staffDown()

		for i = 1, 40 do                 
			local direction		
			local num = i%30
			if num == 0 then 
				direction = myTorso.CFrame.lookVector
			else 
				direction = CFrame.Angles(0, (num-1) * sign * math.pi/20, 0) * myTorso.CFrame.lookVector 
			end 
			local spawnPos = (Staff.Position - Vector3.new(0, 2, 0)) + direction * 4.0 
			sign = sign * -1 

			missiles[i] = orb:Clone() 
			missiles[i].CFrame = (CFrame.new(spawnPos, spawnPos + direction)) 
			missiles[i].Velocity = direction * 70.0 
			missiles[i].RotVelocity = Vector3.new(0, 10, 0) 

			local floatForce = Instance.new("BodyForce") 
			floatForce.force = Vector3.new(0, missiles[i]:GetMass() * workspace.Gravity, 0) 
			floatForce.Parent = missiles[i] 

			missiles[i].Parent = game.Workspace           

			missiles[i].Touched:connect(function(hit) pierce(missiles[i], hit, 4) end) 
			debris:AddItem(missiles[i], 1.25)                
		end 
		-- 
		wait(0.75) 
		staffUp()
		if bg then bg:Remove() end
		myHumanoid.WalkSpeed = 16.0 		
		wait(30.0)
		abyss.Value = false
	end
end

function pierce(missile, hit, dmg) 
	local humanoid 
	if missile then 
		if hit.Parent and hit then 
			if hit:IsA("Accessory") then 
				humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
			else 
				humanoid = hit.Parent:FindFirstChild("Humanoid") 
			end 
			if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
				tagHumanoid(humanoid, vPlayer) 
				if dmg then 
					humanoid:TakeDamage(dmg) 
				else 
					humanoid:TakeDamage(staffDamage) 	
				end
				if humanoid.Parent:FindFirstChild("DarknessScript") == nil then 	
					local cloneScript = Tool.DarknessScript:Clone()
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

	local missile = orb:Clone() 
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

	darknessSound = Tool:FindFirstChild("DarknessSound")	

	wait(3.25) 
	Tool.Enabled = true 
end 

function onEquipped() 	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if storeWeld then 
		local reWeld = storeWeld:Clone()
		reWeld.Parent = Staff
	end
end 

function onUnequipped() 
	if darknessSound then darknessSound:Stop() end
	firePart = Staff:FindFirstChild("FirePart")
	storeWeld = Staff:FindFirstChild("FireWeld")
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 

abyss.Changed:connect(destroyEverything)

