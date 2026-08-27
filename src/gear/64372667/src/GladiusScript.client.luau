local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local connection

local debris = game:GetService("Debris")

Tool.Enabled = true

local lastAttack = 0

local r = game:service("RunService")

local damage = 28

local firePart = Instance.new("Part")
firePart.FormFactor = 3
firePart.Size = Vector3.new(0.2, 0.2, 0.2)
firePart.Transparency = 1.0
firePart.Name = "FirePart"
firePart.Parent = Sword

local fire = Instance.new("Fire")
fire.Parent = firePart 
fire.Color = Color3.new(102/255, 0, 204/255)
fire.SecondaryColor = Color3.new(128/255, 128/255, 128/255)
fire.Heat = 25
fire.Size = 2

local fireWeld = Instance.new("Weld")
fireWeld.Name = "FireWeld"
fireWeld.Part0 = Sword
fireWeld.Part1 = firePart
fireWeld.Parent = Sword

local daggerSound 

local cooldown

local speeding = false

function lunge(humanoid, torso) 	
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
	swordOut()
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
	swordUp()
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
	local damage = 28
	if hit == nil or hit.Parent == nil or vCharacter == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	if humanoid~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil then		
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then
				tagHumanoid(humanoid, vPlayer)				
				humanoid:TakeDamage(damage)								
				if damage/12 + myHumanoid.Health < myHumanoid.MaxHealth then 
					myHumanoid.Health = myHumanoid.Health + damage/12
					myHumanoid.WalkSpeed = 25.0 
					if not speeding then
						speeding = true
						coroutine.resume(coroutine.create(function() 
							wait(2.0)
							if myHumanoid then 
								myHumanoid.WalkSpeed = 16.0
							end
							wait(0.5)
							speeding = false
						end))
					end
				end
			end
		end
	end
end

function swordUp()	
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripForward = Vector3.new(1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 1, 0)				
	Tool.GripUp = Vector3.new(0, 0, 1)	
end

function swordOut()
	Tool.GripForward = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(1, 0, 0)
end

function attack()
	damage = slashDamage	
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
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

	local t = r.Stepped:wait()
	if (t - lastAttack < 0.2) then
		daggerSound = Sword:FindFirstChild("DaggerSound")
		if daggerSound then daggerSound:Play() end
		lunge(myHumanoid, myTorso)
	else
		attack()
	end
	lastAttack = t	

	Tool.Enabled = true
end

function onEquipped()
	if fireWeld then 
		local reWeld = fireWeld:Clone()
		reWeld.Parent = Sword
	end
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
end

function onUnequipped()	
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
	end
	if holdAnim then holdAnim:Stop() end
	if daggerSound then daggerSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

connection = Sword.Touched:connect(blow)