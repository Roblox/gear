local Tool = script.Parent
local Wand = Tool.Handle

local vCharacter
local myHumanoid
local myTorso 
local vPlayer 

Tool.Enabled = true 

local debris = game:GetService("Debris")

local staffDamage = 17 

local flake = Instance.new("Part") 
flake.FormFactor = 3 
flake.Shape = "Block" 
flake.Size = Vector3.new(0.4, 0.4, 0.4) 
flake.CanCollide = false 
flake.Transparency = 0.0 

local flakeMesh = Instance.new("SpecialMesh") 
flakeMesh.MeshId = "http://www.roblox.com/asset/?id=66877034" 
flakeMesh.TextureId = "http://www.roblox.com/asset/?id=68344795" 
flakeMesh.Parent = flake 
flakeMesh.Scale = Vector3.new(2, 2, 2) 

local flakeFire = Instance.new("Fire") 
flakeFire.Color = Color3.new(153/255, 153/255, 1) 
flakeFire.SecondaryColor = Color3.new(153/255, 153/255, 1)
flakeFire.Parent = flake 
flakeFire.Size = 2.0 
flakeFire.Heat = 2.0 

local bg
local slowCo = nil

local torsoFrame = {}
local iceSound


local storm = Tool:FindFirstChild("Storm")
while storm ==  nil do 	
	wait()
	storm = Tool:FindFirstChild("Storm")
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

function tornado()	
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

function wandUp()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(1, 0, 0)	
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function wandDown()
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1 , 0)
end

function destroyEverything()
	local sign = 1 
	local missiles = {} 
	
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if myHumanoid == nil or myTorso == nil then            
		return 
	end 

	laughSound = Wand:FindFirstChild("Laugh") 
	if laughSound then laughSound:Play() end 
	
	myHumanoid.WalkSpeed = 0.0   
	local initDirection = myTorso.CFrame.lookVector

	wandDown()

	local players = game.Players:GetChildren() 
	print(#players)
	for i = 1, #players do 
		if players[i] and players[i].Character then 
			print(2)
			local torso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")
			if torso then 
				local distance = (torso.Position - myTorso.Position).magnitude
				if distance < 70 and players[i]:FindFirstChild("PlayerGui") and players[i].PlayerGui:FindFirstChild("CamScript") == nil then
					print(3)
					local camScript = Tool.CamScript:Clone()
					camScript.Parent = players[i].PlayerGui
					camScript.Disabled = false 
				end 
			end
		end 
	end 

	for i = 1, 40 do                 
		local direction		
		local num = i%30
		if num == 0 then 
			direction = myTorso.CFrame.lookVector
		else 
			direction = CFrame.Angles(0, (num-1) * sign * math.pi/20, 0) * myTorso.CFrame.lookVector 
		end 
		local spawnPos = (Wand.Position - Vector3.new(0, 2, 0)) + direction * 4.0 
		sign = sign * -1 

		missiles[i] = flake:Clone() 
		missiles[i].CFrame = (CFrame.new(spawnPos, spawnPos + direction)) 
		missiles[i].Velocity = direction * 70.0 
		missiles[i].RotVelocity = Vector3.new(0, 10, 0) 

		local floatForce = Instance.new("BodyForce") 
		floatForce.force = Vector3.new(0, missiles[i]:GetMass() * 196.1, 0) 
		floatForce.Parent = missiles[i] 

		missiles[i].Parent = game.Workspace           

		missiles[i].Touched:connect(function(hit) pierce(missiles[i], hit, 4) end) 
		debris:AddItem(missiles[i], 1.25)                
	end 	

	for i = 41, 80 do 
		missiles[i] = flake:Clone() 
		missiles[i].CFrame = myTorso.CFrame + Vector3.new(math.random(-1000, 1000) * 0.025, 125, math.random(-1000, 1000) * 0.025) 
		missiles[i].Velocity = Vector3.new(math.random(), missiles[i].Velocity.Y, math.random())
		missiles[i].CanCollide = true 
		missiles[i].Parent = game.Workspace           

		missiles[i].Touched:connect(function(hit) pierce(missiles[i], hit, 4) end) 
		debris:AddItem(missiles[i], 2.25)		
	end 
	-- 
	wait(0.75) 
	wandUp()
	if bg then bg:Remove() end
	myHumanoid.WalkSpeed = 16.0 			
end

function pierce(missile, hit, dmg) 
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
				if dmg then 
					humanoid:TakeDamage(dmg) 
				else 
					humanoid:TakeDamage(staffDamage) 	
				end
				if humanoid.Parent:FindFirstChild("TrapInIceScript") == nil then 	
					local cloneScript = Tool.TrapInIceScript:Clone()
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

	local spawnPos = Wand.Position + direction * 4.0 

	local missile = flake:Clone() 
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

function wandUp()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function wandDown()
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
	wandDown()
	--shoot(direction)
	destroyEverything()
	wait(0.9)
	wandUp()

	iceSound = Tool:FindFirstChild("IceSound")
	if iceSound then iceSound:Play() end

	wait(9.25) 
	Tool.Enabled = true 
end 

function onEquipped() 	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
end 

function onUnequipped() 
	if iceSound then iceSound:Stop() end	
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 

--storm.Changed:connect(destroyEverything)

