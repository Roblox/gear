Tool = script.Parent
Sword = Tool.Handle

Tool.Enabled = true

-- damage
damage = 18
cloneDamage = 4

local swordClone

-- Sounds
local slashSound
local spinSound
--

-- Animations 
local slashAnim
local initiateCloneAnim

--connection
local connection

-- ShadowActive
local shadowActive = Tool:FindFirstChild("ShadowActive")

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			local joint = rightArm:FindFirstChild("RightGrip")
			if joint ~= nil and (joint.Part0 == Sword or joint.Part1 == Sword) then 
				tagHumanoid(humanoid, vPlayer)				
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end		
	end	
end

function cloneBlow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			local joint = rightArm:FindFirstChild("RightGrip")
			if joint ~= nil and (joint.Part0 == Sword or joint.Part1 == Sword) then 
				tagHumanoid(humanoid, vPlayer)				
				humanoid:TakeDamage(cloneDamage)
				if myHumanoid ~= nil then 
					if myHumanoid.MaxHealth > myHumanoid.Health + cloneDamage then 
						myHumanoid.Health = myHumanoid.Health + cloneDamage
					else
						myHumanoid.Health = myHumanoid.MaxHealth
					end
				end
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end		
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end			
	end
end

local debounce = true
function onActivated()

	if debounce == false then 
		return
	end
	vChar = Tool.Parent
	debounce = false
	if vChar == nil then 
		print("Character not found")
		return
	end

	myHumanoid = vChar:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		print("Humanoid not found")
		return
	end

	myTorso = vChar:FindFirstChild("Torso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end
	--Tool.Enabled = false	
	shadowActive = Tool:FindFirstChild("ShadowActive")
	if shadowActive.Value == 1 then 
		swordClone = vChar:FindFirstChild("ShadowSwordClone")		
		if connection == nil then connection = swordClone.Touched:connect(cloneBlow) print("connected") end
	end
	--Tool.Enabled = true
	debounce = true
end

function onEquipped()
end

function onUnequipped()	
	if swordClone then 
		swordClone:Remove()		
		Tool:FindFirstChild("ShadowActive").Value = 0
	end
	if connection then connection:disconnect() connection = nil end
	Sword.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)