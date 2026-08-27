local Tool = script.Parent
Tool.Enabled = true
local Sword = Tool.Handle

local damage = 17

local debris = game:GetService("Debris")

local slashSound 

-- Animations
local slashAnim
local scimitarWalkAnim
local swingAnim

while Tool:FindFirstChild("FireWeld") == nil do wait() end 

local fireWeld = Tool.FireWeld 

local vCharacter 
local myHumanoid
local myTorso 

local newBV

local runService = game:GetService("RunService")
local lastKeyDown = 0
local dashTime = 0

local amAnimating = false 

function slashIt(myHumanoid, myTorso)    
     
	local target = myHumanoid.TargetPoint
	local direction = (target - myTorso.Position) * Vector3.new(1, 0, 1)
	newBV = nil	
	if direction.magnitude > .01 then
		direction = direction.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = direction * 50
		newBV.Parent = myTorso
		myTorso.CFrame = CFrame.new(myTorso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, myTorso.Position.Y, 0))
	end
	wait(0.75)
	if newBV ~= nil then newBV:remove() end
	wait(0.5)	
end 

function lungeFire(key)	
	if myHumanoid == nil then
		return
	end

	print("Lunging") 
	if key == "w" then
	local t = runService.Stepped:wait()
	if (t - lastKeyDown < 0.2) then dashTime = t end
	lastKeyDown = t
	end
end 

function blow(hit)	
	local humanoid =  hit.Parent:FindFirstChild("Humanoid")	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
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
	
	if myHumanoid == nil then		
		return
	end

	local t = runService.Stepped:wait()
	if t - dashTime < 0.2 then
		swingAnim = myHumanoid:LoadAnimation(Tool.LungeSlash)
		if swingAnim then swingAnim:Play() end
		wait(0.3)
		slashIt(myHumanoid, myTorso)
		wait(0.5)
		amAnimating = false
	else
		slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
		if slashAnim then slashAnim:Play() end    
		slashSound = Sword:FindFirstChild("SlashSound")
		if slashSound then slashSound:Play() end 	
		wait(0.6)
		amAnimating = false
	end 	
	Tool.Enabled = true
end

function onEquipped(mouse)
	if fireWeld then 
		fireWeld.Parent = Tool
	end 

	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")

	scimitarWalkAnim = myHumanoid:LoadAnimation(Tool.ScimitarWalk)
	if scimitarWalkAnim then scimitarWalkAnim:Play() end

	if mouse then mouse.KeyDown:connect(lungeFire) end 
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
	if slashSound then slashSound:Stop() end
	if scimitarWalkAnim then scimitarWalkAnim:Stop() end
	if swingAnim then swingAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)