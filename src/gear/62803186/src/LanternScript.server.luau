local Tool = script.Parent
local Jack = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true 

local jackClone
local jackFire

local jackSound

local jackCo
local spookCo

local spookSound

local spookAOE = Vector3.new(15, 15, 15)

local laughing = false

function creep()
	local bvs = {}
	tick()
	local soundTable = {Jack:FindFirstChild("JackLaughSound"), Jack:FindFirstChild("JackBehindSound")}
	spookSound = soundTable[math.random(1, #soundTable)]
	if spookSound then spookSound:Play() end
	if jackClone and myTorso then
		print("here")
		local parts = game.Workspace:FindPartsInRegion3(Region3.new(jackClone.Position - spookAOE, jackClone.Position + spookAOE), vCharacter, 100)
		print(#parts)
		for i = 1, #parts do 
			if parts[i] and parts[i].Parent and parts[i].Parent:FindFirstChild("Torso") then 
				local torso = parts[i].Parent.Torso 				
				if torso:FindFirstChild("BV") == nil then					
					local humanoid = parts[i].Parent:FindFirstChild("Humanoid")	
					if humanoid then humanoid:TakeDamage(40) end
					local bv = Instance.new("BodyVelocity")
					bv.P = 500000
					bv.maxForce = Vector3.new(bv.P, bv.P, bvP)
					bv.velocity = (torso.Position - myTorso.Position).unit * 100.0
					bv.Name = "BV"
					bv.Parent = torso
					print("Velocity Set")
				end
			end
		end
		wait(2.0)
		for i = 1, #parts do 
			local torso = parts[i].Parent and (parts[i].Parent:FindFirstChild("Torso") or parts[i].Parent:FindFirstChild("UpperTorso"))
			if parts[i] and parts[i]:FindFirstChild("BV") then
				parts[i].BV:Destroy()
			end
			if parts[i] and parts[i].Parent and torso and torso:FindFirstChild("BV") then 
				torso.BV:Destroy()
			end
		end
	end
	wait(7.0)
	laughing = false
end

function follow()	
	local stopped = false
	local bv
	if jackClone then bv = jackClone:FindFirstChild("FollowBV") end
	while jackClone and myTorso and bv do 
		local distance = (myTorso.Position - jackClone.Position).magnitude
		if distance > 5.0 then 	
			stopped = false
			jackClone.CFrame = CFrame.new(jackClone.Position, myTorso.Position + Vector3.new(0, jackClone.Position.Y - myTorso.Position.Y, 0))  * CFrame.Angles(-math.pi/2, 0, 0)
			bv.Parent = jackClone
			if distance > 8.0 then 
				bv.velocity = (myTorso.Position - jackClone.Position).unit * 20.0 + Vector3.new(0, 2, 0)
			else 
				bv.velocity = (myTorso.Position - jackClone.Position).unit * 20.0 * (distance/24) + Vector3.new(0, 2, 0)
			end
		else 			
			if not stopped then 
				stopped = true
				bv.velocity = Vector3.new(0, 0, 0)
				jackClone.Velocity = Vector3.new(0, 0, 0)
				bv.Parent = nil
			end
		end
		wait()
		if not laughing then 
			laughing = true
			spookCo = coroutine.create(creep)
			coroutine.resume(spookCo)
		end
	end
	Jack.Transparency = 0.0
end


function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return
	end

	myHumanoid.WalkSpeed = 20.0

	if jackClone == nil then	
		Tool.Enabled = false 
		jackSound = Jack:FindFirstChild("JackSound")
		if jackSound then jackSound:Play() end

		jackClone = Jack:Clone()
		jackClone.CanCollide = false 
		--jackClone.Parent = vCharacter 
		jackClone.Parent = game.Workspace
		jackClone.Name = "UDONTKNOWJACK"
		
		Jack.Transparency = 1.0

		jackFire = Instance.new("Fire")
		jackFire.Parent  = jackClone
		jackFire.Color = Color3.new(204/255, 51/255, 0)
		jackFire.SecondaryColor = Color3.new(153/255, 0, 51/255)
		jackFire.Heat = -10
		jackFire.Size = 2

		local jackFloat = Instance.new("BodyForce")
		jackFloat.force = Vector3.new(0, jackClone:GetMass() * 196.1, 0)
		jackFloat.Parent = jackClone
		jackFloat.Name = "JackFloat"
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FollowBV"
		bv.Parent = jackClone
		bv.maxForce = Vector3.new(50000, 50000, 50000)
		bv.P = 50000
	
		jackCo = coroutine.create(follow)
		coroutine.resume(jackCo)
	end

	wait(5.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	Jack.Transparency = 0.0
	if jackClone then jackClone:Destroy() jackClone = nil end
	if jackSound then jackSound:Stop() end
	if spookSound then spookSound:Stop() end
	myHumanoid.WalkSpeed = 16.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)