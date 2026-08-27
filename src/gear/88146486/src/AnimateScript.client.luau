-- For the purpose of animations

local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print(instance) 
		wait() 
	end 
	return parent:FindFirstChild(instance)
end 

local Tool = script.Parent 
local Handle = Tool.Handle 

local vCharacter
local vPlayer
local vTorso
local vHumanoid 

local AdvancingAnim
local LungeAnim
local IdleAnim
local HeadPosition

local OnRunConn

local origCameraType

local vMouse

local RBX_Debris = game:GetService("Debris")

local aDown = false
local dDown = false

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
	if vTorso then
		vTorso.CFrame = vTorso.CFrame * CFrame.Angles(0, 0.5 * math.pi, 0)
	end
	if not IdleAnim then
		IdleAnim = vHumanoid:LoadAnimation(Tool.IdleAnim)
	end
	if IdleAnim then
		IdleAnim:Play()
	end
	if not HeadPosition then
		HeadPosition = vHumanoid:LoadAnimation(Tool.HeadPosition)
	end
	if HeadPosition then
		HeadPosition:Play()
	end
	origCameraType = Workspace.CurrentCamera.CameraType
	Workspace.CurrentCamera.CameraType = Enum.CameraType.Attach
	OnRunConn = vHumanoid.Running:connect(onRun)


	if mouse then
		vMouse = mouse
		mouse.KeyDown:connect(onKeyDown)
		mouse.KeyUp:connect(onKeyUp)
	end


end 

function onUnequipped()	
	if AdvancingAnim then
		AdvancingAnim:Stop()
		AdvancingAnim = nil
	end
	if IdleAnim then
		IdleAnim:Stop()
		IdleAnim = nil
	end
	if HeadPosition then
		HeadPosition:Stop()
		HeadPosition = nil
	end
	if OnRunConn then
		--print('Disconnecting on run')
		OnRunConn:disconnect()
		OnRunConn = nil
	end
	aDown = false
	dDown = false
	Workspace.CurrentCamera.CameraType = origCameraType
end


function lungeAttack(backwards)
	if onCooldown then return end
	onCooldown = true
	if Tool:FindFirstChild('DoLunge') then
		Tool.DoLunge.Value = true
		wait(0.1)
		Tool.DoLunge.Value = false
	end
	if vTorso then
	wait(0.1)
		local rightVector = vTorso.CFrame.lookVector:Cross(Vector3.new(0, 1, 0))
		local jumpVel = Instance.new('BodyVelocity', vTorso)
		RBX_Debris:AddItem(jumpVel, 0.5)
		-- make them jump to the side and up a little
		jumpVel.velocity = rightVector * 45
		if backwards then
			jumpVel.velocity = jumpVel.velocity * -1
		end
		jumpVel.velocity = jumpVel.velocity --+ Vector3.new(0, 15, 0)
		jumpVel.maxForce = Vector3.new(5000000, 4500, 5000000)
		vHumanoid.Jump = true
	end
	wait(0.7)
	onCooldown = false
end

function onActivate()
	lungeAttack(false)
end

function lunge(value)
	if not value then return end
	if not LungeAnim then
		LungeAnim = vHumanoid:LoadAnimation(Tool.LungeAnim)
	end
	if LungeAnim then
		LungeAnim:Play()
	end
end


function rotateLeft()
	while aDown and Tool.Enabled do
		--print('Rotating left')
		vCharacter.Torso.CFrame = vCharacter.Torso.CFrame * CFrame.Angles(0, 0.04, 0)
		wait(0.2)
	end

end

function rotateRight()
	while dDown and Tool.Enabled do
		--print('Rotating Right')
		vCharacter.Torso.CFrame = vCharacter.Torso.CFrame * CFrame.Angles(0, -0.04, 0)
		wait(0.2)
	end
end

function onKeyUp(key)
	local keyLower = string.lower(key)
	if keyLower == 'a' or key == '' then
		aDown = false

	end
	if keyLower == 'd' or key == '' then
		dDown = false
	end

end

function onKeyDown(key)
	if string.lower(key) == 'w' or key == '' then -- 
		--rotateTorsoToMouse(vMouse)
		lungeAttack(false)
	end
	if string.lower(key) == 's' or key == '' then -- 
		--rotateTorsoToMouse(vMouse)
		lungeAttack(true)
	end
	if string.lower(key) == 'a' or key == '' then -- 
		if not aDown then		
			aDown = true
			coroutine.resume(coroutine.create(rotateLeft))
		end
	end
	if string.lower(key) =='d' or key == '' then -- 
		if not dDown then
			dDown = true
			coroutine.resume(coroutine.create(rotateRight))
		end
	end
end

function onRun(speed)
	if not AdvancingAnim then
		AdvancingAnim = vHumanoid:LoadAnimation(Tool.AdvancingAnim)
	end
	if AdvancingAnim then
		if speed == 0 then
			AdvancingAnim:Stop()
		else
			AdvancingAnim:Play()
		end
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Tool.Activated:connect(onActivate)

-- bind the lunge animation
if waitForChild(Tool, 'DoLunge') then
	Tool.DoLunge.Changed:connect(lunge)
end
