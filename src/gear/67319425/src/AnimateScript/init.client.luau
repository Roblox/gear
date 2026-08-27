local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local humanoids = {}

Tool.Enabled = true 

local damage = 17
local bg

local slashAnim 
local dashTime = 0 
local lastKeyDown = 0 
local lastAttack = 0

local animations = {}

local torsoCFrames = {}

local amAnimating = false 

local debris = game:GetService("Debris")

local firePart = Sword:FindFirstChild("FirePart")
local storeWeld = Sword:FindFirstChild("FireWeld")
while storeWeld == nil or firePart == nil do 
	firePart = Sword:FindFirstChild("FirePart")
	storeWeld = Sword:FindFirstChild("FireWeld")
	wait()
end

local runService = game:GetService("RunService")

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player 
		creatorTag.Parent = humanoid
	end 
end 

function swordUp()      
	Tool.GripUp = Vector3.new(0, 0, 1)      
	Tool.GripForward = Vector3.new(-1, 0, 0)           
	Tool.GripRight = Vector3.new(0, 1, 0)                     
	Tool.GripUp = Vector3.new(0, 0, 1)      
end 

function swordShave() 
	Tool.GripUp = Vector3.new(1, 0, 0) 
	Tool.GripForward = Vector3.new(0, 0, 1) 
	Tool.GripRight = Vector3.new(0, 1, 0) 
	Tool.GripUp = Vector3.new(1, 0, 0) 
end 

function swordOut() 
	Tool.GripForward = Vector3.new(0, -1, 0) 
	Tool.GripRight = Vector3.new(0, 0, 1) 
	Tool.GripUp = Vector3.new(1, 0, 0) 
end 

function slashIt(myHumanoid, myTorso) 	
	--[[local holdAnim = myHumanoid:LoadAnimation(Tool.HoldAnim) 
	if holdAnim then 
		holdAnim:Play() 
	else 
		Tool.Enabled = true 
		return 
	end ]]
	local target = myHumanoid.TargetPoint 
	local direction = (target - myTorso.Position) * Vector3.new(1, 0, 1) 
	newBV = nil 
	swordShave() 
	if direction.magnitude > .01 then 
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = myTorso 
		myTorso.CFrame = CFrame.new(myTorso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, myTorso.Position.Y, 0)) 
	end 
	wait(.75) 
	if newBV ~= nil then newBV:remove() end 
	wait(.5) 
	swordUp() 
end 

function onKeyDown(key) 
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myHumanoid == nil then 
		return 
	end    
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
end 

function blow(hit)
	local humanoid 
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= myHumanoid and myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)			
			if humanoid.Parent:FindFirstChild("SlowScript") == nil then 
				local cloneScript = script.SlowScript:Clone()
				cloneScript.Parent = humanoid.Parent 
				cloneScript.Disabled = false 
			end 
		end 	
		if hit then hit.BrickColor = BrickColor.new("Pastel yellow") end
	end 
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myHumanoid == nil or myTorso == nil then 
		return       
	end 

	Tool.Enabled = false 

	animations = {Tool.Slash, Tool.SlashAnim, Tool.ToFace}
	
	slashAnim = myHumanoid:LoadAnimation(animations[math.random(1, #animations)]) 

	local t = runService.Stepped:wait() 
	if t - dashTime < 0.2 then            
		slashIt(myHumanoid, myTorso) 
		wait(0.5) 
		amAnimating = false 
	else      
		if slashAnim then slashAnim:Play() end 	
		wait(0.6) 
		amAnimating = false 
	end 
	wait(0.5) 
	Tool.Enabled = true  
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then mouse.KeyDown:connect(onKeyDown)  end
	if storeWeld then 
		local reWeld = storeWeld:Clone()
		reWeld.Parent = Sword
	end
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)