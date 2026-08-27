local Tool = script.Parent
local Potion = Tool.Handle

local vCharacter
local myTorso

Tool.Enabled = true 

local potionSound 

local fireHand = Instance.new("Part")
fireHand.Size = Vector3.new(1, 2, 1)
fireHand.Shape = "Block"
fireHand.FormFactor = 3
fireHand.CanCollide = false
fireHand.Transparency = 1.0

fire = Instance.new("Fire")
fire.Color = Color3.new(139/255, 0, 139/255) 
fire.Heat = 1.0
fire.Size = 1.0
fire.Parent = fireHand

local leftClone
local rightClone
local w1
local w2

local damage = 15

local debris = game:GetService("Debris")

function blow(parent, hit)
	if parent then 
		if hit.Parent then 
			humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		end
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
		end		
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = player
		creator.Parent = humanoid
		debris:AddItem(creator, 1)
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	leftArm = vCharacter:FindFirstChild("Left Arm") or vCharacter:FindFirstChild("LeftHand")
	rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
	myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")
	if myTorso == nil or rightArm == nil or myHumanoid == nil then 
		return 
	end
	wait(0.75)
	myHumanoid.WalkSpeed = 24.0
	Potion.Transparency = 1.0
	leftClone = fireHand:Clone()
	leftClone.Parent = vCharacter
	leftClone.Name = "FireLeftArm"
	leftClone.Touched:connect(function(hit) blow(leftClone, hit) end)
	
	w1 = Instance.new("Weld")
	w1.Parent = leftClone
	w1.Part0 = leftArm
	w1.Part1 = leftClone
	w1.C1 = CFrame.new(Vector3.new(0, 1, 0)) 

	rightClone = fireHand:Clone()
	rightClone.Parent = vCharacter
	rightClone.Name = "FireRightArm" 
	rightClone.Touched:connect(function(hit) blow(rightClone, hit) end)
	
	w2 = Instance.new("Weld")
	w2.Parent = rightClone
	w2.Part0 = rightArm
	w2.Part1 = rightClone
	w2.C1 = CFrame.new(Vector3.new(0, 1, 0)) 
	
	wait(12.0)
	myHumanoid.WalkSpeed = 16.0
	Potion.Transparency = 0.0
	if w1 then w1:Destroy() end
	if w2 then w2:Destroy() end
	wait(5.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if potionSound then potionSound:Stop() end 
	Potion.Transparency = 0.0
	if w1 then w1:Destroy() end
	if w2 then w2:Destroy() end
	if myHumanoid then myHumanoid.WalkSpeed = 16.0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)