local Tool = script.Parent
local Wand = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

local throwAnim

Tool.Enabled = true 

local debris = game:GetService("Debris")

function sleep(hit, WandClone)
	if hit and hit.Parent and WandClone then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent.className == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end		

		if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil and WandClone then 
			humanoid:TakeDamage(4)
			humanoid.WalkSpeed = 0.0
			if WandClone then WandClone:Remove() end
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

function shoot(direction, WandClone)
	if myTorso and myHumanoid then 
		local spawnPos = Wand.Position + direction * 4.0 
		WandClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	
		WandClone.Velocity = (direction + Vector3.new(0, 2, 0)).unit * 45.0
		WandClone.RotVelocity = Vector3.new(0, 10, 0)

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, WandClone:GetMass() * 88.1, 0)
		floatForce.Parent = WandClone 
		
		WandClone.Parent = game.Workspace
	
		WandClone.Touched:connect(function(hit)  sleep(hit, WandClone) end)

		debris:AddItem(WandClone, 2.5)
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

	local WandClone = Wand:Clone()	
	WandClone.CanCollide = true 
	WandClone.Transparency = 1.0 
	
	local sparkles = Instance.new('Sparkles')
	sparkles.Parent = WandClone
	sparkles.Color = Color3.new(math.random(), math.random(), math.random()) 
	
	Wand.Transparency = 1.0
	
	local target = myHumanoid.TargetPoint 
	local direction = (target - Wand.Position).unit 
	
	shoot(direction, WandClone)

	wait(0.25)
	Wand.Transparency = 0.0
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

Wand.Touched:connect(sleep)