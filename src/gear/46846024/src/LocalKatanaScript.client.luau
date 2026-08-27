local Tool = script.Parent
Tool.Enabled = true

local r = game:GetService("RunService")

local newBV = nil
local newBG = nil
local newBAV = nil
local newBP = nil

local slashSound = Tool.Handle.SlashSound
local spinSound = Tool.Handle.SpinSound
local whackSound = Tool.Handle.WhackSound

function slashIt(hum, torso)
	nsAnim = hum:LoadAnimation(Tool["Ninja Slash"])
	if nsAnim == nil then Tool.Enabled = true return end
	
	nsAnim:Play()

	local target = hum.TargetPoint
	local dir = (target - torso.Position) * Vector3.new(1, 0, 1)
	newBV = nil
	if dir.magnitude > .01 then 
		-- make 'em dash forwards too
		dir = dir.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = dir * 50
		newBV.Parent = torso

		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0))
	end
	
	wait(.5)
	slashSound:Play()
	if newBV ~= nil then newBV:remove() end
	wait(.5)
end


function dashIt(hum, torso)

	ndAnim = hum:LoadAnimation(Tool["Ninja Dash"])
	if ndAnim == nil then Tool.Enabled = true return end

	target = hum.TargetPoint
	local dir = (target - torso.Position) * Vector3.new(1, 0, 1)
	if dir.magnitude < .01 then Tool.Enabled = true return end
	dir = dir.unit

	newBG = Instance.new("BodyGyro")
	newBG.P = 30000
	newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
	--newBG.cframe = torso.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
	local torsoPosition = torso.Position
	newBG.cframe = CFrame.new(torsoPosition, target*Vector3.new(1,0,1) + Vector3.new(0, torsoPosition.Y, 0) ) * CFrame.Angles(-math.pi/2, 0, 0)
	newBG.Parent = torso

	newBP = Instance.new("BodyPosition")
	newBP.P = 100000
	newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)
	newBP.position = torsoPosition + Vector3.new(0, 1.5, 0)
	newBP.Parent = torso

	newBAV = Instance.new("BodyAngularVelocity")
	newBAV.P = 100000
	newBAV.maxTorque = Vector3.new(newBAV.P, newBAV.P, newBAV.P)
	
	newBV = Instance.new("BodyVelocity")
	newBV.P = 100000
	newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
	newBV.velocity = dir * 64

	ndAnim:Play()
	wait(.5)
	spinSound:Play()
	newBG.maxTorque = Vector3.new(newBP.P, 0, newBP.P)
	newBP.maxForce = Vector3.new(0, newBP.P, 0)
	newBV.Parent = torso

	newBAV.angularvelocity = torso.CFrame:vectorToWorldSpace(Vector3.new(0, -30, 0))
	hum.Sit = true
	newBAV.Parent = torso

	wait(1)

	-- testing for fun
--	for i = 1, 50 do
		--target = hum.TargetPoint
		--newdir = (target - torso.Position) * Vector3.new(1, 0, 1)
		--if newdir.magnitude > .01 then 
--			dir = newdir 
			--dir = dir.unit 
			--newBV.velocity = dir * 32 
		--end

		--newBG.cframe = CFrame.new(torso.Position, target*Vector3.new(1,0,1) + Vector3.new(0, torso.Position.Y, 0) ) * CFrame.Angles(-math.pi/2, 0, 0)

		--wait(.1)
	--end
	-- end of testing for fun


	--for i = 1, 3 do
--		ndAnim:Play()
		--wait(2)
	--end

	hum.Sit = false
	if newBAV ~= nil then newBAV:remove() end
	if newBP ~= nil then newBP:remove() end
	if newBV ~= nil then newBV:remove() end

	if newBG ~= nil then newBG.cframe = CFrame.new(torsoPosition, target*Vector3.new(1,0,1) + Vector3.new(0, torsoPosition.Y, 0) ) end
	if newBG ~= nil then newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P) end
	spinSound:Stop()
	wait(.25)
	if newBG ~= nil then newBG:remove() end
end


local lastKeyDown = 0
local dashTime = 0
local lastSlash = 0
local amAnimating = false
function onActivated()
	vChar = Tool.Parent
	if vChar == nil then return end
	hum = vChar:FindFirstChild("Humanoid")
	if hum == nil then return end
	--if not Tool.Enabled then return end
	if amAnimating then return end
	Tool.Enabled = false
	amAnimating = true

	torso = vChar:FindFirstChild("Torso")
	if torso == nil then Tool.Enabled = true return end

	t = r.Stepped:wait()
	if t - dashTime < .2 then
		-- dash attack
		dashIt(hum, torso)
		wait(.5)  -- reload time
		amAnimating = false
	elseif t - lastSlash < .2 then
		-- slash attack
		slashIt(hum, torso)
		--wait(1)
		amAnimating = false
		--wait(.5)  -- reload time
	else
		-- normal attack
		whackSound:Play()
		lastSlash = t
		amAnimating = false -- here must be before the wait, to allow for double-clix
		wait(.5)
	end
	if not amAnimating then Tool.Enabled = true end
end

local keyConnection = nil
function onKeyDown(key)
	if key:lower() == "w" then
		t = r.Stepped:wait()
		if (t - lastKeyDown < .2) then dashTime = t end
		lastKeyDown = t
	end
end

function onEquippedLocal(mouse)
	slashSound.Volume = 1 
	spinSound.Volume = 1
	whackSound.Volume = 1

	keyConnection = mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedLocal()
	if keyConnection ~= nil then keyConnection:disconnect() end

	if newBV ~= nil then newBV:remove() end
	if newBG ~= nil then newBG:remove() end
	if newBAV ~= nil then newBAV:remove() end
	if newBP ~= nil then newBP:remove() end

	slashSound.Volume = 0
	spinSound.Volume = 0
	whackSound.Volume = 0
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivated)
 