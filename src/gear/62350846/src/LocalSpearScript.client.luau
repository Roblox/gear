local Tool = script.Parent
local Spear = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

local slashAnim

local debris = game:GetService("Debris")

local damage = 17

local runService = game:service("RunService") 

local dashTime = 0 
local lastKeyDown = 0 

local amAnimating = false

function slashIt(humanoid, torso) 	
	local target = humanoid.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	newBV = nil 
	spearFront()
	if direction.magnitude > .01 then            
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = torso 
		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0)) 
	end 
	wait(.5)       
	if newBV ~= nil then newBV:remove() end 
	wait(.5) 
	spearUp()
end 

function charge(key)
	if myHumanoid == nil or myTorso == nil then return end
	if key:lower() == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
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
	local vPlayer = game.Players:playerFromCharacter(vCharacter)	
	if humanoid~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil then		
		local rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Spear or rightGrip.Part1 == Spear) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)				
			end
		end
	end
end

connection = Spear.Touched:connect(blow)

function spearUp()	
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripForward = Vector3.new(-1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 1, 0)				
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripPos = Vector3.new(0, 0, -2.5)
end

function spearOut()
	Tool.GripUp = Vector3.new(0, -1, 0)
	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(0, -1, 0)
	Tool.GripPos = Vector3.new(0, 0, -3.5)
end

function spearFront()
	Tool.GripUp = Vector3.new(1, 0 ,0)	
	Tool.GripForward = Vector3.new(0, 0 ,1)		
	Tool.GripRight = Vector3.new(0, 1, 0)				
	Tool.GripUp = Vector3.new(1, 0 , 0)		
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

	t = runService.Stepped:wait() 
	if t - dashTime < 0.2 then 
		slashIt(myHumanoid, myTorso) 
		wait(0.5) 
		amAnimating = false 
	else      
		slashAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
		if slashAnim then slashAnim:Play() end
		spearOut()
		wait(2.2)
		spearUp()
		amAnimating = false 
		wait(0.5)		
	end 
	
	wait(1.0)
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then 
		mouse.KeyDown:connect(charge)
	end
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
