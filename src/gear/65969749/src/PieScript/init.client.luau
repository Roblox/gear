local Tool = script.Parent
local Pie = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

local throwAnim

Tool.Enabled = true 

local debris = game:GetService("Debris")

function sleep(hit, pumpkinClone)
	if hit and hit.Parent and pumpkinClone then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent.className == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end		
		if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil and pumpkinClone then 
			humanoid:TakeDamage(3)
			humanoid.WalkSpeed = 0.0
			if pumpkinClone then pumpkinClone:Remove() end			
			local character = humanoid.Parent 
			
			if game.Players:GetPlayerFromCharacter(character) then
				local spamScript = script:FindFirstChild("SpamScript"):Clone()
				spamScript.Parent = character 
				spamScript.Disabled = false 
			end
			
			wait(0.1)
			humanoid.WalkSpeed = 16.0
		end
	end
end

function shoot(direction, pumpkinClone)
	if myTorso and myHumanoid then 
		local spawnPos = Pie.Position + direction * 4.0 
		pumpkinClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	
		pumpkinClone.Velocity = (direction + Vector3.new(0, 1, 0)).unit * 45.0
		pumpkinClone.RotVelocity = Vector3.new(0, 10, 0)

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, pumpkinClone:GetMass() * 128.1, 0)
		floatForce.Parent = pumpkinClone 
		
		pumpkinClone.Parent = game.Workspace
	
		pumpkinClone.Touched:connect(function(hit)  sleep(hit, pumpkinClone) end)

		debris:AddItem(pumpkinClone, 2.5)
	end	
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	local pumpkinClone = Pie:Clone()
	pumpkinClone.CanCollide = true 
	
	Pie.Transparency = 1.0
	
	local target = myHumanoid.TargetPoint 
	local direction = (target - Pie.Position).unit 
	
	shoot(direction, pumpkinClone)

	wait(0.25)
	Pie.Transparency = 0.0
	Tool.Enabled = true 
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

function onUnequipped()
	if throwAnim then throwAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Pie.Touched:connect(sleep)