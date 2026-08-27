Tool = script.Parent
Tool.Enabled = true
Sword = Tool.Handle

local damage = 5

print("RUNNING SCRIPT")

smoke = Instance.new("Smoke")
smoke.Color = Color3.new(0.0, 0.9, 0.0)
smoke.Enabled = true
smoke.Size = 0.1
smoke.Opacity = 0.05
smoke.RiseVelocity = 0.0
smoke.Parent = Tool.Handle

local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = Sword
slashSound.Volume = 1
-- Animations
local slashAnim



function blow(hit)	
	local humanoid =  hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 			
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip ~= nil and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 				
				if hit.Parent:FindFirstChild("InsertScript") == nil then
					newScript = Tool.InsertScript:Clone()
					creatorTag = Instance.new("ObjectValue")
					creatorTag.Name = "creator"
					creatorTag.Value = vPlayer
					creatorTag.Parent = newScript
					newScript.Disabled = false
					newScript.Parent = hit.Parent								
				else 
					hit.Parent.InsertScript.Poison.Value = Tool.InsertScript.Poison.Value
				end

				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)				
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end
	end
end
function onActivated()
	
	if Tool.Enabled == false then 
		return 
	end	
	Tool.Enabled = false
	
	vCharacter = Tool.Parent

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then
		print("Humanoid not found")
		return
	end
	
	slashAnim = myHumanoid:LoadAnimation(Tool.PirateSlash)
	slashAnim:Play()
	slashSound:Play()
	Tool.GripForward = Vector3.new(0.0, 0.4472, 0.8944)
	Tool.GripRight = Vector3.new(1.0, 0.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, -0.8944, 0.4472)
	wait(1.0)	
	
	Tool.GripForward = Vector3.new(1.0, 0.0, 0.0)
	Tool.GripRight = Vector3.new(0.0, -1.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
	
	wait(0.75)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
	if slashSound then slashSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)