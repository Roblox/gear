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

local firePart
local fire
local fireWeld

if Sword:FindFirstChild("FirePart") == nil then
	firePart = Instance.new("Part")
	firePart.FormFactor = 3
	firePart.Size = Vector3.new(0.2, 0.2, 0.2)
	firePart.Transparency = 1.0
	firePart.Name = "FirePart"
	firePart.Parent = Sword

	fire = Instance.new("Fire")
	fire.Parent = firePart 
	fire.Color = Color3.new(1, 0, 0)
	fire.SecondaryColor = Color3.new(128/255, 128/255, 128/255)
	fire.Heat = 25
	fire.Size = 2

	fireWeld = Instance.new("Weld")
	fireWeld.Name = "FireWeld"
	fireWeld.Part0 = Sword
	fireWeld.Part1 = firePart
	fireWeld.Parent = Sword

else 
	firePart = Sword.FirePart 
	fire = firePart:FindFirstChild("Fire")
	fireWeld = Sword.FireWeld 
end

local daggerSound 

local cooldown

local speeding = false

local dashTime = 0 
local lastKeyDown = 0 
local lastAttack = 0

function charge(key) 
	if myHumanoid == nil or myTorso == nil then return end 
	if key:lower() == "w" then 
		local t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
end 


function dash(humanoid, torso) 	
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
	swordShave()
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
	local damage = 22
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
				if humanoid.Parent:FindFirstChild("LionFireScript") == nil then 
					local cloneScript = script.LionFireScript:Clone()
					cloneScript.Parent = humanoid.Parent
					cloneScript.Disabled = false 
				end
			end
		end
	end
end

function swordUp()	
	Tool.GripUp = Vector3.new(0, -1, 0)	
	Tool.GripForward = Vector3.new(1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 0, -1)				
	Tool.GripUp = Vector3.new(0, -1, 0)	
end

function swordShave()
	Tool.GripUp =  Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0 ,0)
	Tool.GripRight = Vector3.new(0, -1, 0)
	Tool.GripUp = Vector3.new(0, 0 ,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(1, 0, 0)
end

function lunge()	
	if lungeSound then lungeSound:play() end

	local anim = Instance.new("StringValue") 
	anim.Name = "toolanim" 
	anim.Value = "Lunge" 
	anim.Parent = Tool      

	local force = Instance.new("BodyVelocity") 
	force.velocity = Vector3.new(0, 12, 0) 
	force.Parent = myTorso 

	wait(0.25) 
	swordOut() 
	wait(0.25) 
	if force then force:Remove() end 
	wait(0.5) 
	swordUp() 	
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
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myTorso == nil or myHumanoid == nil then 
		return
	end

	Tool.Enabled = false 	

	local t = runService.Stepped:wait()
	if t - dashTime < 0.2 then 
		dash(myHumanoid, myTorso)
	elseif t - lastAttack < 0.2 then
		daggerSound = Sword:FindFirstChild("SwordSound")
		if daggerSound then daggerSound:Play() end
		lunge()
	else
		attack()
	end
	lastAttack = t	

	Tool.Enabled = true
end

function onEquipped(mouse)
	if fireWeld then 
		local reWeld = fireWeld:Clone()
		reWeld.Name = "FireWeld"
		reWeld.Parent = Sword
	end
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if mouse then 
		mouse.KeyDown:connect(charge)
	end
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