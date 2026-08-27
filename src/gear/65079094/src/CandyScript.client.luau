local Tool = script.Parent
local Candy = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

local throwAnim

Tool.Enabled = true 

local debris = game:GetService("Debris")

function sleep(hit, candyClone)
	if hit and hit.Parent and candyClone then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Accessory") then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end		

		if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil and candyClone then 
			humanoid:TakeDamage(4)
			humanoid.WalkSpeed = 0.0
			if candyClone then candyClone:Remove() end
			local character = humanoid.Parent 
			if character:FindFirstChild("SleepScript") == nil then 
				local cloneScript = Tool.SleepScript:Clone()
				cloneScript.Parent = character 
				cloneScript.Disabled = false 
			
				local sleepy = cloneScript:FindFirstChild("Sleepy")
				if sleepy then sleepy.Value = 1 end  
			else 
				local sleepy = character.SleepScript:FindFirstChild("Sleepy")
				if sleepy then sleepy.Value = sleepy.Value + 1 end
			end
			wait(0.1)
			humanoid.WalkSpeed = 16.0
		end
	end
end

function shoot(direction, candyClone)
	if myTorso and myHumanoid then 
		local spawnPos = Candy.Position + direction * 4.0 
		candyClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	
		candyClone.Velocity = (direction + Vector3.new(0, 2, 0)).unit * 45.0
		candyClone.RotVelocity = Vector3.new(0, 10, 0)

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, candyClone:GetMass() * 88.1, 0)
		floatForce.Parent = candyClone 
		
		candyClone.Parent = game.Workspace
	
		candyClone.Touched:connect(function(hit)  sleep(hit, candyClone) end)

		debris:AddItem(candyClone, 2.5)
	end	
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

	Tool.Enabled = false

	local candyClone = Candy:Clone()
	candyClone.CanCollide = true 
	
	Candy.Transparency = 1.0
	
	local target = myHumanoid.TargetPoint 
	local direction = (target - Candy.Position).unit 
	
	shoot(direction, candyClone)

	wait(0.25)
	Candy.Transparency = 0.0
	Tool.Enabled = true 
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

function onUnequipped()
	if throwAnim then throwAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Candy.Touched:connect(sleep)