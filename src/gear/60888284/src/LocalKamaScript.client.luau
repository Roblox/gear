local Tool = script.Parent
local Kama = Tool.Handle

local vCharacter
local myHumanoid
local myTorso

local sliceAnim 
local spinAnim
local spinning

local dashTime = 0 
local lastKeyDown = 0 

local runService = game:service("RunService") 

local kamaAOE = Vector3.new(7, 7, 7)

local animating = false	

local torsoFrame = {}

function slashIt(myHumanoid, myTorso) 

	laughSound = Tool:FindFirstChild("EvilLaugh") 
	if laughSound then laughSound:Play() end 		

	bg = Instance.new("BodyGyro") 
	bg.P = 100000 
	bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P) 
	bg.Name = "BG" 

	torsoFrame[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0) 
	torsoFrame[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0) 
	torsoFrame[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0) 
	torsoFrame[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0) 
	torsoFrame[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0) 
	torsoFrame[6] = myTorso.CFrame 

	bg.Parent = myTorso 

	for i = 1, 84 do 
		local c = i%6 + 1 
		if bg then bg.cframe = torsoFrame[c] end 
		wait(0.025) 
	end      	
 	
	if bg then bg:Remove() end 
	wait(2.0) 	
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
		spinAnim = myHumanoid:LoadAnimation(Tool.SpinAnim)
		if spinAnim then spinAnim:Play() end
		slashIt(myHumanoid, myTorso) 
		wait(0.25) 
		animating = false 
	else  
	sliceAnim = myHumanoid:LoadAnimation(Tool.SliceAnim)
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
		myTorso = vCharacter:FindFirstChild("Torso")
		mouse.KeyDown:connect(sliceAndDice)
	end
end

function onUnequipped()
	if sliceAnim then sliceAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
