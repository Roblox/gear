local Tool = script.Parent
local Kama = Tool.Handle

local vCharacter
local myHumanoid
local myTorso

local sliceAnim 
local throwAnim
local spinning

local dashTime = 0 
local lastKeyDown = 0 

local equipAnim
local holdAnim

local runService = game:service("RunService") 

local kamaAOE = Vector3.new(7, 7, 7)

local animating = false	

local torsoFrame = {}

function slashIt(myHumanoid, myTorso) 
	local throwAxes = Tool:FindFirstChild("ThrowAxes")
	if throwAxes and throwAxes.Value == false then throwAxes.Value = true end 
	if holdAnim then holdAnim:Stop() end 
	wait(5.0)
	if holdAnim then holdAnim:Play() end
end 

function sliceAndDice(key)
	key = key:lower()
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end
end

function onActivated()
	if Tool.Enabled == false then
		return 
	end
	
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid == nil or myTorso == nil then 
		return 
	end

	spinning = Tool:FindFirstChild("Spinning")
	if spinning and spinning.Value == 1 then 
		return 
	end

	t = runService.Stepped:wait() 
	if t - dashTime < 0.2 then 
		throwAnim = myHumanoid:LoadAnimation(Tool.ThrowAnim)
		if throwAnim then throwAnim:Play() end
		wait(0.4)
		slashIt(myHumanoid, myTorso) 
		wait(0.25) 
		animating = false 
	else  
		sliceAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
		if sliceAnim then sliceAnim:Play() end	
		wait(0.6) 
		animating = false 
	end 	
	wait(0.5)
	Tool.Enabled = true	
end

function onEquipped(mouse)
	if mouse then 
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		equipAnim = myHumanoid:LoadAnimation(Tool.EquipAnim)
		if equipAnim then equipAnim:Play() end
		myTorso = vCharacter:FindFirstChild("Torso")
		mouse.KeyDown:connect(sliceAndDice)

		wait(1.0)
		holdAnim = myHumanoid:LoadAnimation(Tool.HoldAnim)
		if holdAnim then holdAnim:Play() end 
	end
end

function onUnequipped()
	if sliceAnim then sliceAnim:Stop() end
	if holdAnim then print("Stopping hold Anim") holdAnim:Stop() end 
	if equipAnim then equipAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
