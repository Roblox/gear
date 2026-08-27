local Tool = script.Parent
local JackMass = Tool.Handle:GetMass()

local humanoid = nil
while humanoid == nil do
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	wait(1)
end

local oldHealth = humanoid.Health

function CreateGUI()
	local p = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	print("Power for Player: " .. p.Name)
	script.JackGUI.Parent = p.PlayerGui
end


function HealthChanged(health)
	UpdateGUI(health)
end

function UpdateGUI(health)
	local pgui = game.Players:GetPlayerFromCharacter(humanoid.Parent).PlayerGui
	local tray = pgui.JackGUI.Tray
	
	wait(.5)

--	tray.HealthBar.Size = UDim2.new(0.2, 0, 0.8 * (health / humanoid.MaxHealth), 0) 
--	tray.HealthBar.Position = UDim2.new(0.4, 0, 0.8 * (1-  (health / humanoid.MaxHealth)) , 0) 

	powerValue = Tool.Power.Value
	if health == 98231 then -- hack to avoid rewriting function for subtracting 10
		if powerValue < 10 then powerValue = 0
		else powerValue = powerValue - 10 end
	end

	--powerLevel = 1 - 1/(math.sqrt(math.sqrt(1+powerValue))) 
	if powerValue > 30 then powerValue = 30+(powerValue-30)*.1 end
	if powerValue > 40 then powerValue = 40 end
	powerLevel = powerValue / 40
	tray.HealthBar.Size = UDim2.new(0.2, 0, 0.8 * powerLevel, 0) 
	tray.HealthBar.Position = UDim2.new(0.4, 0, 0.8 * (1-powerLevel), 0) 
end


CreateGUI()
UpdateGUI(0)
humanoid.HealthChanged:connect(HealthChanged)


Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	vCharacter = Tool.Parent
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil or Tool.Power.Value < 5 then Tool.Enabled = true return end
	rArm = vCharacter:FindFirstChild("Right Arm")
	lArm = vCharacter:FindFirstChild("Left Arm")
	rLeg = vCharacter:FindFirstChild("Right Leg")
	lLeg = vCharacter:FindFirstChild("Left Leg")
	if rArm == nil then rArmMass = 0 else rArmMass = rArm:GetMass() end
	if lArm == nil then lArmMass = 0 else lArmMass = lArm:GetMass() end
	if rLeg == nil then rLegMass = 0 else rLegMass = rLeg:GetMass() end
	if lLeg == nil then lLegMass = 0 else lLegMass = lLeg:GetMass() end

	UpdateGUI(98231)

	charChilds = vCharacter:GetChildren()
	hatMass = 0
	for i = 1, #charChilds do
		if charChilds[i].className == "Hat" then
			hatMass = hatMass + charChilds[i].Handle:GetMass()
		end
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35966712"
		magicSound.Name = "MagicSound"
	end
	magicSound:Play()

	mass = vCharacter.Head:GetMass() + vCharacter.Torso:GetMass() + lArmMass + rArmMass + lLegMass + rLegMass + JackMass + hatMass
	oldWalkSpeed = humanoid.WalkSpeed
	powerLevel = 1 - 1/(math.sqrt(math.sqrt(1+Tool.Power.Value)))  -- goes from 0 to 1 s.t. it takes 15 candies to get to .5
	print("PowerLevel:")
	print(powerLevel)
	timeToGo = 2 + powerLevel*15
	humanoid.WalkSpeed = oldWalkSpeed + 60*powerLevel
	antiGrav = Instance.new("BodyForce")
	antiGrav.force = Vector3.new(0, powerLevel*196*mass*.8, 0)
	antiGrav.Name = "JackUp"
	antiGrav.Parent = vCharacter.Torso
	healingFactor = 3*powerLevel
	for i = 1, math.floor(timeToGo) do
		newHealth = humanoid.Health + healingFactor
		if newHealth > humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth
		else humanoid.Health = newHealth end
		wait(1)
	end
	timeLeft = timeToGo - math.floor(timeToGo)
	wait(timeLeft)
	antiGrav.Parent = nil
	humanoid.WalkSpeed = oldWalkSpeed
	if Tool.Power.Value < 10 then Tool.Power.Value = 0
	else Tool.Power.Value = Tool.Power.Value - 10 end
	Tool.Enabled = true
end

function onEquipped()
	jGUI = script:FindFirstChild("JackGUI")
	if jGUI ~= nil then jGUI.Parent = game.Players:GetPlayerFromCharacter(humanoid.Parent).PlayerGui end

	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35966712"
		magicSound.Name = "MagicSound"
	end
	UpdateGUI(0)
end

function onUnequipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound:Stop()
		magicSound.Parent = nil 
	end

	pgui = game.Players:GetPlayerFromCharacter(humanoid.Parent).PlayerGui
	JackGUI = pgui:FindFirstChild("JackGUI")
	if JackGUI ~= nil then
		JackGUI.Parent = script
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

-- any damage gets added to the power :)
while true do
	if humanoid.Health < oldHealth then
		Tool.Power.Value = Tool.Power.Value + (oldHealth - humanoid.Health)/4
		
		magicSound = Tool.Handle:FindFirstChild("MagicSound")
		if magicSound == nil then
			magicSound = Instance.new("Sound")
			magicSound.Parent = Tool.Handle
			magicSound.Volume = 1
			magicSound.SoundId = "http://www.roblox.com/asset/?id=35966712"
			magicSound.Name = "MagicSound"
		end
		magicSound:Play()
		wait(.4)
		magicSound:Stop()
	end
	oldHealth = humanoid.Health
	wait(.4)
end

