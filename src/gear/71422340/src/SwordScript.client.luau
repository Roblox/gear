local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer
local rightArm

local rightGrip

Tool.Enabled = true

local runService = game:service("RunService") 

local damage = 21

local dashTime = 0 
local lastKeyDown = 0 

local debris = game:GetService("Debris")
local runService = game:service("RunService") 

local slashAnim
local throwAnim
local swordWalkAnim
local waveSlashAnim
local swordFromHolsterAnim
local twoHandedAnim

function throwHamma(key)
	key = key:lower()
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end
end 

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1)
	end 
end 

function blow(hit)
	if hit and hit.Parent then
		local humanoid 	
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)		

			if math.random() < 0.11 then 		
				hit:BreakJoints() 
			end 

			local opponent = hit.Parent:FindFirstChild("Torso") 
			wait(0.1)
			if opponent then 
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.P = 100000
				bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, bodyVelocity.P, bodyVelocity.P)
				bodyVelocity.velocity = (opponent.Position - myTorso.Position) * 8.5
				bodyVelocity.Parent = opponent 
				debris:AddItem(bodyVelocity, 0.75)
			end
		end 
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 
	
	local swordWave = Tool:FindFirstChild("SwordWave")
	--if swordWave and swordWave.Value == true then return end 

	Tool.Enabled = false 

	t = runService.Stepped:wait() 
	if Tool.Grip == CFrame.new(0.649999976, 0, 0.649999976, 0.709901273, -0, -0.704301238, -0.704301238, 0, -0.709901273, 0, 1, -0) then 
		swordHolsterAnim = myHumanoid:LoadAnimation(Tool.SwordHolsterAnim)
		if swordHolsterAnim then swordHolsterAnim:Play() end 		
		wait(0.5)
		if rightGrip then rightGrip.Part0 = rightArm end 
		Tool.Grip =  CFrame.new(0, -2.70000005, 0, 0, 0, -1, 0, 1, 0, 1, -0, 0)
		wait(0.7)
		if swordWalkAnim then swordWalkAnim:Stop() end 
		twoHandedAnim = myHumanoid:LoadAnimation(Tool.TwoHandedAnim)
		if twoHandedAnim then twoHandedAnim:Play() end 
		Tool.Enabled = true 
	else
		if t - dashTime < 0.2 then 	
			throwAnim = myHumanoid:LoadAnimation(Tool.ThrowAnim)
			if throwAnim then throwAnim:Play() end		
			if swordWave and swordWave.Value == false then swordWave.Value = true end 
		else 
			slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
			if slashAnim then slashAnim:Play() end 
			Tool.Enabled = true 
		end 
	end 
end

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	rightArm = vCharacter:FindFirstChild("Right Arm") 
	if mouse then 
		mouse.KeyDown:connect(throwHamma)   
	end 
	if myHumanoid then 
		swordWalkAnim = myHumanoid:LoadAnimation(Tool.SwordWalkAnim)
		if swordWalkAnim then swordWalkAnim:Play() end
	end 

	if rightArm then
		while rightArm:FindFirstChild("RightGrip") == nil do 
			wait() 
		end 
		rightGrip = rightArm.RightGrip
		rightGrip.Part0 = myTorso 
	end 	

	Tool.Grip = CFrame.new(0.649999976, 0, 0.649999976, 0.709901273, -0, -0.704301238, -0.704301238, 0, -0.709901273, 0, 1, -0)
end  

function onUnequipped()
	if slashAnim then slashAnim:Stop() end 
	if throwAnim then throwAnim:Stop() end 
	if swordWalkAnim then swordWalkAnim:Stop() end
	if swordHolsterAnim then swordHolsterAnim:Stop() end 
	if twoHandedAnim then twoHandedAnim:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)
