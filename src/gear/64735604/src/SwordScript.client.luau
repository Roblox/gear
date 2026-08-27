local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local connection

local debris = game:GetService("Debris")

Tool.Enabled = true

local lastAttack = 0

local runService = game:service("RunService")

local damage = 17

local swordSound 

local dashTime = 0 
local lastKeyDown = 0 

local amAnimating = false 

local slashAnim

function charge(key) 
	if myHumanoid == nil or myTorso == nil then return end 
	if key:lower() == "w" then 
		local t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
end 


function lunge(humanoid, torso) 	
	local holdAnim = humanoid:LoadAnimation(Tool.DashAnim)
	if holdAnim then 
		holdAnim:Play() 
	else 
		Tool.Enabled = true
		return 
	end
	local target = humanoid.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	local newBV = nil 	
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
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then
				tagHumanoid(humanoid, vPlayer)				
				humanoid:TakeDamage(17)				
				if hit.Parent.Name == "Zombie" and myHumanoid then 
					humanoid:TakeDamage(85) 
					if humanoid and humanoid.Health == 0 then
						if myHumanoid.MaxHealth < 250 then
							myHumanoid.MaxHealth = myHumanoid.MaxHealth + 10
							myHumanoid.Health = myHumanoid.Health + 10
						end
					end
				end 				
				if myHumanoid and myHumanoid.Health + 2 < myHumanoid.MaxHealth then 
					myHumanoid.Health = myHumanoid.Health + 2
				end
			end
		end
	end
end

function swordUp()	
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripForward = Vector3.new(0, -1, 0)		
	Tool.GripRight = Vector3.new(-1, 0, 0)				
	Tool.GripUp = Vector3.new(0, 0, 1)	
end

function swordOut()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(-1, 0, 0)
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

	local t = runService.Stepped:wait()
	if (t - dashTime < 0.2) then
		print("Dashing")
		swordSound = Sword:FindFirstChild("SwordSound")
		if swordSound then swordSound:Play() end
		lunge(myHumanoid, myTorso)
	else
		slashAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
		if slashAnim then slashAnim:Play() end
	end
	--lastAttack = t	

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
		mouse.KeyDown:connect(charge)
	end
end

function onUnequipped()
	-- do nothing 	
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
	end
	if holdAnim then holdAnim:Stop() end
	if swordSound then swordSound:Stop() end

	if slashAnim then slashAnim:Stop() end

	swordUp()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

connection = Sword.Touched:connect(blow)