local Tool = script.Parent --Fix implemented by Luckymaxer

local flightPower 
local flightSpin 
local flightHold 

local camSpeedZ = 60
local camSpeedX = 40

local forwards = false
local back = false
local left = false
local right = false

local unEquipped = false

local movementHandlerCo 

local hover = -.1

local carpetActive

local myTorso
local vCharacter
local myHumanoid

function handleMovementFrame()
	local newPush = Vector3.new(0,0,0)
	local Camera = game:GetService("Workspace").CurrentCamera
	local forwardVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
	local sideVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0))

	--[[if forwards and not back then newPush = forwardVector * camSpeedZ end
	if back and not forwards then newPush = newPush + forwardVector * -camSpeedZ end
	if left and not right then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * camSpeedX end
	if right and not left then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * camSpeedX end]]

	local CoordinateFrame = Camera.CoordinateFrame
	local localControlVector = CFrame.new(Vector3.new(0,0,0),CoordinateFrame.lookVector*Vector3.new(1,0,1)):vectorToObjectSpace(myHumanoid.MoveDirection)

	newPush = newPush + ((forwardVector * camSpeedZ * -localControlVector.z) or newPush)
	newPush = newPush + ((sideVector * camSpeedX * -localControlVector.x) or newPush)

	flightSpin.cframe = CFrame.new(Vector3.new(0,0,0), forwardVector) -- have torso face forwards
	if newPush.magnitude < 1 then
		flightHold.maxForce = Vector3.new(flightHold.P, flightHold.P, flightHold.P)
		flightPower.maxForce = Vector3.new(0, 0, 0)
		if myTorso then flightHold.position = myTorso.Position end
	else
		flightHold.maxForce = Vector3.new(0, 0, 0)
		flightPower.maxForce = Vector3.new(flightPower.P*100, flightPower.P*100, flightPower.P*100)
	end
		flightPower.velocity = newPush
end

function handleMovement()	
	carpetActive = Tool:FindFirstChild("CarpetActive")
	if carpetActive then
		while carpetActive.Value == 1 do
			handleMovementFrame()
			if not unEquipped then if myHumanoid then myHumanoid.Sit = true end end
			wait()
		end
	end
end

function keyUpFunc(key)	
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		forwards = false
	elseif key == "a" then
		left = false
	elseif key == "s" then
		back = false
	elseif key == "d" then
		right = false
	end	
end

function keyDownFunc(key)	
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		forwards = true
	elseif key == "a" then
		left = true
	elseif key == "s" then
		back = true
	elseif key == "d" then
		right = true
	end	
end

function carpetActivate()	
	carpetActive = Tool:FindFirstChild("CarpetActive")
	if carpetActive then
		if carpetActive.Value == 0 then return end
	end
	local vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("HumanoidRootPart")
	if myTorso == nil then return end
	
	flightPower = myTorso:FindFirstChild("FlightPower")
	flightSpin = myTorso:FindFirstChild("FlightSpin")
	flightHold = myTorso:FindFirstChild("FlightHold")

	while flightPower == nil or flightSpin == nil or flightHold == nil do		
		Tool.Parent.HumanoidRootPart.ChildAdded:wait()
		flightPower = Tool.Parent.HumanoidRootPart:FindFirstChild("FlightPower")
		flightSpin = Tool.Parent.HumanoidRootPart:FindFirstChild("FlightSpin")
		flightHold = Tool.Parent.HumanoidRootPart:FindFirstChild("FlightHold")
	end		
	print("Handling Movement")
	movementHandlerCo = coroutine.create(handleMovement)	
	coroutine.resume(movementHandlerCo)	
end

function onEquipped(mouse)	
	print("Equipped")
	if mouse then		
		forwards = false
		back = false
		left = false
		right = false				
		mouse.KeyDown:connect(keyDownFunc)
		mouse.KeyUp:connect(keyUpFunc)				
	end
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	carpetActive = Tool:FindFirstChild("CarpetActive")
	if carpetActive then print("Connection established") carpetActive.Changed:connect(carpetActivate) end
end

function onUnequipped()
	unEquipped = true
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

print("Done")

