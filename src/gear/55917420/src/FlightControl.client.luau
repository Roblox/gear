local Tool = script.Parent

local flightPower 
local flightSpin 
local flightHold 

local camSpeedZ = 60
local camSpeedX = 40

local forwards = false
local back = false
local left = false
local right = false

local movementHandlerCo 

local hover = -.1

local wingActive

local myTorso
local vCharacter

function handleMovementFrame()
	local newPush = Vector3.new(0,0,0)
	local forwardVector = game.Workspace.CurrentCamera.CFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))

	if forwards and not back then newPush = forwardVector * camSpeedZ end
	if back and not forwards then newPush = newPush + forwardVector * -camSpeedZ end
	if left and not right then newPush = newPush + game.Workspace.CurrentCamera.CFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * camSpeedX end
	if right and not left then newPush = newPush + game.Workspace.CurrentCamera.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * camSpeedX end

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
	wingActive = Tool:FindFirstChild("WingActive")
	if wingActive then
		while wingActive.Value == 1 do
			handleMovementFrame()
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

function wingActivate()	
	wingActive = Tool:FindFirstChild("WingActive")
	if wingActive then
		if wingActive.Value == 0 then return end
	end
	local vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then return end
	
	flightPower = myTorso:FindFirstChild("FlightPower")
	flightSpin = myTorso:FindFirstChild("FlightSpin")
	flightHold = myTorso:FindFirstChild("FlightHold")

	while (flightPower == nil or flightSpin == nil or flightHold == nil) and myTorso ~= nil do
		myTorso.ChildAdded:wait()
		flightPower = myTorso:FindFirstChild("FlightPower")
		flightSpin = myTorso:FindFirstChild("FlightSpin")
		flightHold = myTorso:FindFirstChild("FlightHold")
	end		
	movementHandlerCo = coroutine.create(handleMovement)	
	coroutine.resume(movementHandlerCo)	
end

function onEquipped(mouse)		
	if mouse then		
		forwards = false
		back = false
		left = false
		right = false				
		mouse.KeyDown:connect(keyDownFunc)
		mouse.KeyUp:connect(keyUpFunc)				
	end
	wingActive = Tool:FindFirstChild("WingActive")
	if wingActive then wingActive.Changed:connect(wingActivate) end
end

Tool.Equipped:connect(onEquipped)

