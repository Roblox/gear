local Tool = script.Parent 
local Blade = Tool.Handle

local vCharacter 
local myTorso 
local myHumanoid 
local vPlayer 

local terror 
local throwRing 

local cloneId = 68452456

local maxDistance = 45.0 

local awayFromCharacter = false

local clone = game:GetService("InsertService"):LoadAsset(cloneId):GetChildren()[1] 
local currentClone 

local debris = game:GetService("Debris")

while Tool:FindFirstChild("ThrowRing") == nil do 
	wait()
end 

local damage = 13

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player 
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1.25)
	end 
end 

function blow(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			awayFromCharacter = false
		end 
	end 
end 

function returnToCharacter(cloneBlade) 
	if cloneBlade and myTorso then 
		local distance = (cloneBlade.Position - myTorso.Position).magnitude 
		local lookAt = (myTorso.Position - cloneBlade.Position).unit 
		while distance > 4.0 and cloneBlade do 
			cloneBlade.Velocity = lookAt * 45.0 
			if cloneBlade then 
				lookAt = (myTorso.Position - cloneBlade.Position).unit 
				distance = (myTorso.Position - cloneBlade.Position).magnitude 
			end 
			wait() 
		end 
		if cloneBlade then 
			cloneBlade:Remove() 
			cloneBlade = nil 
		end 
		wait(0.25) 
	end 
end 

function throw(cloneBlade, direction)       
	local spawnPos = Blade.Position + direction * 4.0 
	cloneBlade.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	cloneBlade.CanCollide = false 

	cloneBlade.Velocity = direction * 45.0 
	cloneBlade.RotVelocity = Vector3.new(0, 40, 0) 

	local floatForce = Instance.new("BodyForce") 
	floatForce.force = Vector3.new(0, cloneBlade:GetMass() * 196.1, 0) 
	floatForce.Parent = cloneBlade 

	cloneBlade.Parent = game.Workspace 

	cloneBlade.Touched:connect(function(hit) blow(hit) end) 

	awayFromCharacter = true 

	local distance = (cloneBlade.Position - spawnPos).magnitude 
	while awayFromCharacter and distance < maxDistance do 
		distance = (cloneBlade.Position - spawnPos).magnitude 
		wait(0.25) 
	end 
	awayFromCharacter = false 
	returnToCharacter(cloneBlade) 
end 

throwRing = Tool.ThrowRing
throwRing.Changed:connect(function()
	if throwRing and throwRing.Value == true and myHumanoid then 
		Blade.Transparency = 1.0
		local cloneBlade = Blade:Clone()                
		cloneBlade.Transparency = 0.0 
		local target = throwRing.Target.Value
		local direction = (target - Blade.Position).unit 
		coroutine.resume(coroutine.create(function() throw(cloneBlade, direction) end)) 
		Tool.Enabled = false
		wait(7.0)
		Tool.Enabled = true 
		Blade.Transparency = 0.0
		throwRing.Value = false 		
	end 
end)

while Tool:FindFirstChild("Terror") == nil do 
	wait()
end

function spawnClone(character, torso)
	if character and torso and clone then 
		local thisClone = clone:Clone() 

		thisClone.Name = vCharacter.Name .. "'s Clone" 

		local target = thisClone:FindFirstChild("Target")
		if target then 
			target.Value = character:FindFirstChild("Humanoid")
		else 
			target = Instance.new("ObjectValue")
			target.Name = "Target"
			target.Parent = thisClone
			target.Value = character:FindFirstChild("Humanoid")
		end 	

		local cloneAIScript = Tool.CloneAIScript
		cloneAIScript.Parent = vCharacter 
		
		while cloneAIScript:FindFirstChild("CloneVal") == nil do 
			wait()
		end 		
		cloneAIScript.CloneVal.Value = thisClone 		
			
		cloneAIScript.Disabled = false 
		
		thisClone.Parent = game.Workspace 
		thisClone:MoveTo(torso.Position + Vector3.new(5, 0, 5))
		debris:AddItem(cloneAIScript, 11)
		debris:AddItem(clone, 12)
	end 
end 

terror = Tool.Terror 
terror.Changed:connect(function()
	if terror and terror.Value == true then 
		local players = game.Players:GetChildren()
		for i = 1, #players do 
			if players[i] and players[i] ~= vPlayer and players[i].Character and players[i].Character:FindFirstChild("Torso") and myTorso then 
				local torso = players[i].Character.Torso
				local distance = (torso.Position - myTorso.Position).magnitude
				if distance < 35 then	
					 spawnClone(players[i].Character, torso)
				end 
			end 
		end 
		wait(45.0)
		terror.Value = false 
	end 
end) 

function dressClone()
	if vCharacter then 
		local children = vCharacter:GetChildren()
		for i = 1, #children do 
			if children[i] then 
				if children[i].ClassName == "Hat" then 
					-- Special
					local hat = Instance.new("Hat")
					local Hpart = children[i].Handle:clone()
					Hpart.Parent = hat
					Hpart.Position = clone.Head.Position
					hat.Name = children[i].Name
					hat.Parent = clone
					hat.AttachmentPos = children[i].AttachmentPos
					hat.AttachmentRight = children[i].AttachmentRight
					hat.AttachmentUp = children[i].AttachmentUp
					hat.AttachmentForward = children[i].AttachmentForward 
				elseif children[i]:IsA("BasePart") or children[i].ClassName == "ForceField" or children[i].ClassName == "Script" or children[i].ClassName == "LocalScript" then
					-- Ignore it
				else
					children[i]:Clone().Parent = clone 
				end 
			end 
		end 
	end 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	clone = game:GetService("InsertService"):LoadAsset(cloneId):GetChildren()[1] 
	dressClone()
end 

Tool.Equipped:connect(onEquipped)
