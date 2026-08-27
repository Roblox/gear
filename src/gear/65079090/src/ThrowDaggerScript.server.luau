local Tool = script.Parent
local Dagger = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer

local cloneDagger

local damage = 15

local maxDistance = 45.0

local awayFromCharacter = false 

local debris = game:GetService("Debris")

while Tool:FindFirstChild("ThrowDagger") == nil do 
	wait()
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player 
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creator, 1)
	end
end

function sleep(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent.className == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end
		if humanoid and myHumanoid and humanoid ~= myHumanoid then
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			local character = humanoid.Parent 
			if character and character:FindFirstChild("SleepScript") == nil then 
				local cloneScript = Tool.SleepScript:Clone()
				cloneScript.Parent = character 
				
				local sleepy = cloneScript:FindFirstChild("Sleepy")
				if sleepy then 
					sleepy.Value = 4 
				end

				cloneScript.Disabled = false 
			else 
				local sleepy = character.SleepScript:FindFirstChild("Sleepy")
				if sleepy then 
					sleepy.Value = sleepy.Value + 2
				end
			end
			awayFromCharacter = false
		end
	end
end

function returnToCharacter(cloneDagger)
	if cloneDagger and myTorso then 
		local distance = (cloneDagger.Position - myTorso.Position).magnitude
		local lookAt = (myTorso.Position - cloneDagger.Position).unit
		while distance > 4.0 and cloneDagger do 
			cloneDagger.Velocity = lookAt * 45.0
			if cloneDagger then 
				lookAt = (myTorso.Position - cloneDagger.Position).unit 
				distance = (myTorso.Position - cloneDagger.Position).magnitude
			end
			wait()
		end
		if cloneDagger then 
			cloneDagger:Remove() 
			cloneDagger = nil
		end
		wait(0.25)
	end
end

function throw(cloneDagger, direction)
	
	local spawnPos = Dagger.Position + direction * 4.0
	cloneDagger.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	cloneDagger.CanCollide = false 
	
	cloneDagger.Velocity = direction * 45.0
	cloneDagger.RotVelocity = Vector3.new(0, 40, 0)

	local floatForce = Instance.new("BodyForce")
	floatForce.force = Vector3.new(0, cloneDagger:GetMass() * 196.1, 0)
	floatForce.Parent = cloneDagger
	
	cloneDagger.Parent = game.Workspace 

	cloneDagger.Touched:connect(function(hit) sleep(hit) end)

	awayFromCharacter = true

	local distance = (cloneDagger.Position - spawnPos).magnitude
	while awayFromCharacter and distance < maxDistance do 
		distance = (cloneDagger.Position - spawnPos).magnitude
		wait(0.25)
	end
	awayFromCharacter = false
	returnToCharacter(cloneDagger)
end

local throwDagger = Tool.ThrowDagger 
throwDagger.Changed:connect(function() 
	if throwDagger and throwDagger.Value == true and myTorso and myHumanoid then	
		Tool.Enabled = false 
		local sign = 1
		Dagger.Transparency = 1.0 
		
		local firePart = Dagger:FindFirstChild("FirePart")
		local fire
		if firePart then 
			fire = firePart:FindFirstChild("Fire")			
		end
		if fire then fire.Enabled = false end
	
		for i = 1, 5 do 
			sign = sign * -1			
			local cloneDagger = Dagger:Clone()			
			cloneDagger.Transparency = 0.0
			local target = myHumanoid.TargetPoint 
			local direction = CFrame.Angles(0, (i-1) * sign * math.pi/18, 0) * (target - Dagger.Position).unit
			
			coroutine.resume(coroutine.create(function() throw(cloneDagger, direction) end))
		end
		wait(4.5)
		Dagger.Transparency = 0.0		
		if fire then fire.Enabled = true end
		wait(4.0)		
		Tool.Enabled = true
		throwDagger.Value = false 			
	end
end)

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

Tool.Equipped:connect(onEquipped)


