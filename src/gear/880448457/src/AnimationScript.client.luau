-- animations must be run in a local script, so animation handling is delegated here

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Animations = Tool:WaitForChild("Animations")
local R15Folder = Animations:WaitForChild("R15")
local R6Folder = Animations:WaitForChild("R6")
local humanoid = nil

-- animation controllers
local standardSwing = nil
local swingRight = nil
local swingLeft = nil
local spinSwing = nil
local doubleSwing = nil
local idle = nil
local idleWalking = nil

local keyCombo = {}

local numOfKeysDown = 0

local debris = game:GetService("Debris")

local spinSound= Instance.new("Sound")
spinSound.SoundId = "http://www.roblox.com/asset/?id=28144425"
spinSound.Volume = 1
spinSound.Parent = Handle

local slashSounds = {"28144268 ","28144277","28144291","28144295"}

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
SlashSound.Parent = Handle
SlashSound.Volume = .7

function LoadR6Animations()
	standardSwing = humanoid:LoadAnimation(R6Folder:WaitForChild("staffstrike"))
	idle = humanoid:LoadAnimation(R6Folder:WaitForChild("holdstaff"))
	idleWalking = humanoid:LoadAnimation(R6Folder:WaitForChild("walkstaff"))
	swingRight = humanoid:LoadAnimation(R6Folder:WaitForChild("staffswingright"))
	swingLeft = humanoid:LoadAnimation(R6Folder:WaitForChild("staffswingleft"))
	doubleSwing = humanoid:LoadAnimation(R6Folder:WaitForChild("staffdoublehit"))
	spinSwing = humanoid:LoadAnimation(R6Folder:WaitForChild("staffspin"))
end

function LoadR15Animations()
	standardSwing = humanoid:LoadAnimation(R15Folder:WaitForChild("staffstrike"))
	idle = humanoid:LoadAnimation(R15Folder:WaitForChild("holdstaff"))
	idleWalking = humanoid:LoadAnimation(R15Folder:WaitForChild("walkstaff"))
	swingRight = humanoid:LoadAnimation(R15Folder:WaitForChild("staffswingright"))
	swingLeft = humanoid:LoadAnimation(R15Folder:WaitForChild("staffswingleft"))
	doubleSwing = humanoid:LoadAnimation(R15Folder:WaitForChild("staffdoublehit"))
	spinSwing = humanoid:LoadAnimation(R15Folder:WaitForChild("staffspin"))
end

-- load in Animations on equip
function onEquippedLocal(input)
	spinSound:Stop()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			LoadR15Animations()
		else 
			LoadR6Animations()
		end
		idle:Play()
	end
	
	input.KeyDown:connect(onKeyDown) 
	input.KeyUp:connect(onKeyUp)

end

-- Destroy animations on unequip
function onUnequippedLocal()
	humanoid = nil

	if standardSwing ~= nil then standardSwing:Stop() end
	if idle ~= nil then idle:Stop() end
	if idleWalking ~= nil then idleWalking:Stop() end
	if spinSwing ~= nil then spinSwing:Stop() end
	if doubleSwing ~= nil then doubleSwing:Stop() end
	if swingLeft ~= nil then swingLeft:Stop() end
	if swingRight ~= nil then swingRight:Stop() end

	if standardSwing ~= nil then standardSwing:Destroy() end
	if idle ~= nil then idle:Destroy() end
	if idleWalking ~= nil then idleWalking:Destroy() end
	if swingRight ~= nil then swingRight:Destroy() end
	if swingLeft ~= nil then swingLeft:Destroy() end
	if doubleSwing ~= nil then doubleSwing:Destroy() end
	if spinSwing ~= nil then spinSwing:Destroy() end
end

function animationValueChanged(value)

	if value == "standardAttack" then
		if standardSwing ~= nil then standardSwing:Play() end
	elseif value == "rightAttack" then
		if swingRight ~= nil then swingRight:Play() end
	elseif value == "leftAttack" then
		if swingLeft ~= nil then swingLeft:Play() end
	elseif value == "doubleAttack" then
		if doubleSwing ~= nil then doubleSwing:Play() end
	elseif value == "spinAttack" then
		if spinSwing ~= nil then spinSwing:Play() end
	end

end

function changeAnimationValue(value)
	Tool.AnimationValue.Value = "change"
	Tool.AnimationValue.Value = value
	keyCombo = {}
end

function spinAttack()
	if humanoid == nil then
		humanoid = Tool.Parent:FindFirstChild("Humanoid")
	end
	if humanoid == nil then return end
	local torso = humanoid.Parent:FindFirstChild("Torso")
	if torso ~= nil then
		local spinForce = Instance.new("BodyAngularVelocity")
		spinForce.P = 1000000
		spinForce.angularvelocity = Vector3.new(0,20,0)
		spinForce.maxTorque = Vector3.new(spinForce.P,spinForce.P,spinForce.P)
		spinForce.Parent = torso
		debris:AddItem(spinForce, 1)
	end
end

function onKeyDown(key) 
	if (key~=nil) then 
		local key = key:lower() 
		if (key == "w") or (key == "s") or (key == "a") or (key == "d") then
			if idleWalking ~= nil then idleWalking:Play(0) end
			numOfKeysDown = numOfKeysDown + 1
		elseif (key== "e") then
			if SlashSound ~= nil then
				SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
				SlashSound:Play()
			end
			changeAnimationValue("rightAttack")
		elseif (key=="q") then
			if SlashSound ~= nil then
				SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
				SlashSound:Play()
			end
			changeAnimationValue("leftAttack")
		elseif (key == "f") and #keyCombo < 1 then
			table.insert(keyCombo,"f")
		elseif (key == "g") and keyCombo[1] == "f" then
			table.insert(keyCombo,"g")
		elseif (key == "h") and keyCombo[2] == "g" then
			changeAnimationValue("spinAttack")
			spinAttack()
			if spinSound ~= nil then spinSound:play() end
		else
			keyCombo = {}
		end
	end
end

-- used to stop manual walking animation
function onKeyUp(key)
	if (key~=nil) then 
		local key = key:lower() 
		if (key == "w") or (key == "s") or (key == "a") or (key == "d") and (numOfKeysDown <= 1) then
			if idleWalking ~= nil then idleWalking:Stop(0) end
			numOfKeysDown = numOfKeysDown - 1
		end
	end
end
	
Tool.AnimationValue.Changed:connect(animationValueChanged)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

