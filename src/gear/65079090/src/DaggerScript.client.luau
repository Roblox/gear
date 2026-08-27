local Tool = script.Parent
local Dagger = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local connection

local debris = game:GetService("Debris")

Tool.Enabled = true

local lastAttack = 0

local r = game:service("RunService")

local damage = 24

local daggerSound 

local throwDagger

local lunging = false

while Tool:FindFirstChild("FireWeld") == nil do 
	wait()
end

local fireWeld = Tool.FireWeld 

function throw(key)
	key = key:lower()
	if key == "q" then 
		throwDagger = Tool:FindFirstChild("ThrowDagger")
		if throwDagger and throwDagger.Value == false then 
			throwDagger.Value = true 
		end
	end
end

function lunge(humanoid, torso) 		
	lunging = true 
	local holdAnim = humanoid:LoadAnimation(Tool.HoldAnim)
	if holdAnim then 
		holdAnim:Play() 
	else 
		Tool.Enabled = true
		return 
	end
	local target = humanoid.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	newBV = nil 
	daggerOut()
	if direction.magnitude > .01 then            
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = torso 
		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0)) 
	end 
	wait(.75)       
	if newBV ~= nil then newBV:remove() end 
	wait(.5) 
	lunging = false
	daggerUp()
end 

function tagHumanoid(humanoid, player)
	if humanoid then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit)
	if hit == nil or hit.Parent == nil or vCharacter == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	if humanoid~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil then		
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Dagger or rightGrip.Part1 == Dagger) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)	
				local torso = humanoid.Parent:FindFirstChild("Torso")
					
				if lunging and torso and humanoid.Parent:FindFirstChild("ForceScript") == nil then 
					local cloneScript = Tool.ForceScript:Clone()
					cloneScript.Parent = humanoid.Parent 					
							
					local direction = (torso.Position - Dagger.Position).unit 
					if cloneScript:FindFirstChild("Direction") then 
						cloneScript.Direction.Value = direction
					end
		
					cloneScript.Disabled = false
				end
			end
		end
	end
end

function daggerUp()	
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripForward = Vector3.new(-1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 1, 0)				
	Tool.GripUp = Vector3.new(0, 0, 1)	
end

function daggerOut()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(-1, 0, 0)
end

function attack()	
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end
 
function onActivated()	
	if Tool.Enabled == false then 
		return 
	end
	
	throwDagger = Tool:FindFirstChild("ThrowDagger")
	if throwDagger and throwDagger.Value == true then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myTorso == nil or myHumanoid == nil then 
		return
	end

	Tool.Enabled = false 	

	local t = r.Stepped:wait()
	if (t - lastAttack < 0.2) then
		daggerSound = Dagger:FindFirstChild("DaggerSound")
		if daggerSound then daggerSound:Play() end
		lunge(myHumanoid, myTorso)
	else
		attack()
	end
	lastAttack = t	

	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid then 
		myHumanoid.WalkSpeed = 20.0
	end
	
	if mouse then 
		mouse.KeyDown:connect(throw)
	end

	if fireWeld then 
		fireWeld.Parent = Tool
	end
end

function onUnequipped()
	-- do nothing 	
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
	end
	if holdAnim then holdAnim:Stop() end
	if daggerSound then daggerSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

connection = Dagger.Touched:connect(blow)