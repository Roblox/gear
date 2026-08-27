-- Handle to the tool
local Tool = script.Parent
print("IN SCRIPT")

-- Culling Service
local debris = game:GetService("Debris")

local r = game:service("RunService")
Tool.Enabled = true

function shoot(pPos, missile)

	print("IN SHOOT")
--
	local vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:findFirstChild("Humanoid") == nil then 
		print("HUMANOID NOT FOUND")
		return
	end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then print("PLAYER NOT FOUND") end
	-- Spawning position of the clone potion
	local sPos = vCharacter.PrimaryPart.Position
	-- Have it spawn at a offset from the actual object position
	sPos = sPos + pPos.unit * 5.0
	print("SPAWN POS")
	-- Remove the weld with the hand from the clone object
	--missile.Weld:remove()	
	local xyz_rand = math.random(0.0, 0.1)	
	missile.CFrame = CFrame.new(sPos, sPos + pPos) * CFrame.Angles(0.0, 0.0, math.pi/2.0) 
	missile.Velocity = pPos * 30
	missile.RotVelocity = Vector3.new(0.0, 0.0, 0.0)	
	missile.Name = "ThrownPP"
	missile.CanCollide = true
	-- Give it a body force so that it stays afloat
	local missileFloat = Instance.new("BodyForce")
	-- Give it enough force to stay afloat
	missileFloat.force = Vector3.new(0.0, (missile:GetMass()) * 196.1 , 0.0)		
	-- To know who the creator of the missile was
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	-- Add the missile to the Workspace
	missile.Parent = game.Workspace
	missileFloat.Parent = missile	
	-- The potion will now be removed from the world in 5 seconds
	debris:AddItem(missile, 5)
	
	local newScript = script.Parent.OnTouchScript:clone()
	newScript.Parent = missile
	newScript.Disabled = false

	--Sound!
	ThrowSound = Tool.Handle:FindFirstChild("ThrowSound")
	if ThrowSound ~= nil then 
		ThrowSound.Volume = 1.0
		ThrowSound:Play()
	end
end

function onActivated()
	-- Tentative Lock
	if not Tool.Enabled then	
		return
	end
	Tool.Enabled = false	
	local character = Tool.Parent
	if character == nil then print("OMG! CHARACTER?") end
	local humanoid = character.Humanoid
	if humanoid == nil then 
		print("OMG! WHERE IS HUMANOID?")
		Tool.Enabled = true
		return
	end
	-- Clone the potion
	local throwPotion = Tool.Handle:Clone()	
	-- Make the the clone potion visible
	throwPotion.Transparency = 0	
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	local ThrowAnim = humanoid:LoadAnimation(Tool.Throw)
	ThrowAnim:Play()
	wait(0.2)
	-- Make the potion invisible	
	shoot(lookAt, throwPotion)	
	Tool.Handle.Transparency = 1.0
	wait(0.5)
	Tool.Handle.Transparency = 0.0
	wait(1.0)
	Tool.Enabled = true
end

function onEquipped()
	--Tool.Handle.Transparency = 0
end

function onUnequipped()
	--if throwPotion then throwPotion:remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
	