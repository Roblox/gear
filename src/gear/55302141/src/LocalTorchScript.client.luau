local Tool = script.Parent
local Torch = Tool.Handle

local vCharacter
local myHumanoid

local storeWeld = Torch:FindFirstChild("FireWeld")

Tool.Enabled = true

function inAwe(hit)
	if hit.Parent then humanoid = hit.Parent:FindFirstChild("Humanoid") end
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Torch or rightGrip.Part1 == Torch) then 
				humanoid.WalkSpeed = 0.0
				wait(2.0)
				humanoid.WalkSpeed = 16.0
			end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then return end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then return end

	waveAnim = myHumanoid:LoadAnimation(Tool.WaveAnim)
	waveSound = Torch:FindFirstChild("WaveSound")
	if waveAnim then waveAnim:Play() end
	if waveSound then waveSound:Play() end

	wait(5.0)
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 500
		myHumanoid.Health = ratio * 500
		myHumanoid.WalkSpeed = 24.0
	end
	
	checkWeld = Torch:FindFirstChild("FireWeld")
	if checkWeld == nil then checkWeld = storeWeld:Clone() checkWeld.Parent = Torch end
end

function onUnequipped()
	if waveSound then waveSound:Stop() end
	if waveAnim then waveAnim:Stop() end

	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		myHumanoid.Health = ratio * 100
		myHumanoid.WalkSpeed = 16.0
	end	
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
Tool.Equipped:connect(onEquipped)

Torch.Touched:connect(inAwe)
