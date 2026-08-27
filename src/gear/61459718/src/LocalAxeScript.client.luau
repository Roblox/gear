local Tool = script.Parent
local Axe = Tool.Handle

local vCharacter
local myTorso
local myRightArm
local myHumanoid

local characterMass

local debris = game:GetService("Debris")

local jumpBV

local damage = 20

local animating

Tool.Enabled = true

local dashTime = 0 
local lastKeyDown = 0 
local runService = game:service("RunService") 

local attackType 

local newBV

local storeWeld = Tool:FindFirstChild("FireWeld")
while storeWeld == nil do 
	storeWeld = Tool:FindFirstChild("FireWeld")
	wait()
end

function computeWeight(object) 
	local totalMass = 0
	local ch
	if object == nil then return end
	if type(object) == "table" then 
		ch = object
	else
		ch = object:GetChildren()	
	end
	for i = 1, #ch do 
		if ch[i]:IsA("BasePart") then 
			totalMass = totalMass + ch[i]:GetMass()
		end		
		totalMass = totalMass + computeWeight(ch[i])		
	end	
	return totalMass
end

function slashIt(hum, torso) 	
	damage = 30
	local target = hum.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	Tool.GripUp = Vector3.new(1, 0, 0)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripForward = Vector3.new(0, 0, 1)
	newBV = nil 
	if direction.magnitude > .01 then            
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = torso 
		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0)) 
	end 
	wait(.5)       
	if newBV ~= nil then newBV:Destroy() end 
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)	
	damage = 20
	wait(.5) 
end 

function checkForLunge(key)
	attackType = Tool:FindFirstChild("AttackType")	
	if key:lower() == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	elseif key:lower() == "q" then
		if attackType then attackType.Value = 2 end
	elseif key:lower() == "e" then 
		if attackType then attackType.Value = 1 end
	end 
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1.5)
	end
end

function blow(hit)
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and myHumanoid and myHumanoid ~= humanoid then 
			local rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
			if rightArm then 
				local rightGrip = rightArm:FindFirstChild("RightGrip")
				if rightGrip and (rightGrip.Part0 == Axe or rightGrip.Part1 == Axe) then 
					tagHumanoid(humanoid, player)
					humanoid:TakeDamage(damage)
				end
			end
		end
	end
end

function destroyEverything()
	attackType = Tool:FindFirstChild("AttackType")
	drill = Tool:FindFirstChild("Drill")
	wave = Tool:FindFirstChild("Wave")
	if attackType then 
		if attackType.Value == 2 and wave and wave.Value == 0 then 
			wave.Value = 1 
			wait(10.0)
		elseif attackType.Value == 1 and drill and drill.Value == 0 then 
			drill.Value = 1
			wait(5.0)
		end
	end	
end

function onActivated()	
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myRightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myTorso == nil or myRightArm == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	print(attackType)

	t = runService.Stepped:wait() 
	if t - dashTime < 0.2 then 
		slashIt(myHumanoid, myTorso) 
		wait(0.5) 
		animating = false 
	else      
		destroyEverything()
		wait(0.6) 
		animating = false 
	end     

	wait(2.0)
	
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	characterMass = computeWeight(vCharacter)	
	if mouse then 
		mouse.KeyDown:connect(checkForLunge)
	end
	local checkWeld = Tool:FindFirstChild("FireWeld")
	if checkWeld == nil then
		checkWeld = storeWeld:Clone()
		checkWeld.Parent = Tool
	end
end

function onUnequipped()
	if jumpBV then jumpBV:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Axe.Touched:connect(blow)



