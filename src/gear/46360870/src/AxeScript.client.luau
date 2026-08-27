-- Ice Axe --

r = game:service("RunService")

local Tool = script.Parent
local IceAxe = Tool.Handle

-- damage
local damage = 10
local swingDamage = 12

Tool.Enabled = true

--Animation
local SwingAnim

--Sounds
axeSwirl = Tool.AxeSwirl

-- On Slash
function slash(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	local MSReducer = Tool.MSReducer:Clone()
	if not MSReducer then 
		print("OMG WHERE IS IT?")
	end
	if humanoid ~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil then
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if(rightArm ~= nil) then
			local joint = rightArm:FindFirstChild("RightGrip")
			if(joint ~= nil and (joint.Part0 == IceAxe or joint.Part1 == IceAxe)) then
				if not hit.Parent:FindFirstChild("MSReducer") then
					MSReducer.Parent = hit.Parent
					MSReducer.Disabled = false
				end
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1.0)				
				untagHumanoid(humanoid)
			end			
		end
	end
end

-- Tagging and Untagging for leaderboards
function tagHumanoid (humanoid, player)
	local creatorTag = Instance.new("ObjectValue")		
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end	
end

function swing()
	damage = swingDamage	
end

local bodyRotVelocity = nil

-- On Gear Activation, this function is called
function onActivated()
	if not Tool.Enabled then 
		return
	end

	Tool.Enabled = false
	
	local character = Tool.Parent
	local myHumanoid = character:FindFirstChild("Humanoid")
	if not myHumanoid then 
		return
	end
	myTorso = character:FindFirstChild("Torso")
	if not myTorso then 
		return
	end	

	--smoke = IceAxe:FindFirstChild("Smoke")
	--if smoke then
--		smoke.Opacity = 1
		--smoke.RiseVelocity = 5
		--smoke.Size = 10  -- THIS LINE IS BREAKING IT!! (10.0 breaks it)
	--end	

	bigSmoke = Instance.new("Smoke")
	bigSmoke.Name = "BigSmoke"
	bigSmoke.Opacity = 1
	bigSmoke.RiseVelocity = 5
	bigSmoke.Size = 10
	bigSmoke.Color = Color3.new(204/255, 1.0, 1.0)
	bigSmoke.Parent = IceAxe

	smoke = IceAxe:FindFirstChild("Smoke")
	if smoke then
		smoke.Enabled = false
	end

	-- Give the player an angular velocity 
	-- He rotates about 2 full cycles with this velocity
	bodyRotVelocity = Instance.new("BodyAngularVelocity")
	bodyRotVelocity.P = 250000
	bodyRotVelocity.maxTorque = Vector3.new(bodyRotVelocity.P, bodyRotVelocity.P, bodyRotVelocity.P)
	bodyRotVelocity.angularvelocity = Vector3.new(0.0, 10.0, 0.0)
	bodyRotVelocity.Parent = myTorso
		
	SwingAnim = myHumanoid:LoadAnimation(Tool.AxeSwing)	
	SwingAnim:Play()	
	-- Axe's orientation in the players hands while rotating
	Tool.GripForward = Vector3.new(0.02866, 0.4855, -0.8738)
	Tool.GripRight = Vector3.new(-1.0, 0.01391, -0.0250)
	Tool.GripUp = Vector3.new(0.0, -0.8741, -0.40)
	
	--smoke = IceAxe:FindFirstChild("Smoke")
--	if smoke then
--		smoke.Opacity = 1
		--smoke.RiseVelocity = 5
		--smoke.Size = 10  -- THIS LINE IS BREAKING IT!! (10.0 breaks it)
	--end	
	axeSwirl:Play()
	wait(1.5)

	if smoke then
		smoke.Enabled = true
	end

	if IceAxe:FindFirstChild("BigSmoke") then	
		IceAxe.BigSmoke:remove()
	end

	-- Change rotation back to default
	Tool.GripForward = Vector3.new(0.0, -1.0, 0.0)
	Tool.GripRight = Vector3.new(-1.0, 0.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)	
--	if smoke then
--		smoke.Opacity = 0.2
--		smoke.RiseVelocity = 0
--		smoke.Size = 0.2
	--end
	if bodyRotVelocity ~= nil then bodyRotVelocity:Remove() end
	damage = 10.0
	wait(1.0)
	-- Stop the music
	axeSwirl:Stop()
	Tool.Enabled = true		
end

-- Axe Equipped
function onEquipped()
	smoke = IceAxe:FindFirstChild("Smoke")
	if smoke then smoke.Enabled = true end
	--smoke = Instance.new("Smoke")
	--smoke.Color = Color3.new(204/255, 1.0, 1.0)
	--smoke.Opacity = 0.2
	--smoke.RiseVelocity = 0.0
	--smoke.Size = 0.2
--	smoke.Parent = IceAxe
--	print("Smoke Added")
end

-- Axe Unequipped
function onUnequipped()
	if SwingAnim then 
		SwingAnim:Stop()
	end
	if axeSwirl then
		axeSwirl:Stop()
	end
	if bodyRotVelocity ~= nil then bodyRotVelocity:Remove() end

	Tool.GripForward = Vector3.new(0.0, -1.0, 0.0)
	Tool.GripRight = Vector3.new(-1.0, 0.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)	

	if IceAxe:FindFirstChild("BigSmoke") then	
		IceAxe.BigSmoke:remove()
	end
	smoke = IceAxe:FindFirstChild("Smoke")
	if smoke then smoke.Enabled = true end
end

-- Event Listeners 
Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

connection = IceAxe.Touched:connect(slash)
