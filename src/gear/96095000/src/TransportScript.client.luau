local function WaitForChild(parent, childName)
	while parent:FindFirstChild(childName) == nil do 
		wait()
	end 
	return parent[childName]
end 

local Tool = script.Parent

local FlightPower 
local FlightSpin 
local FlightHold 

local CamSpeedZ = 30
local CamSpeedX = 20

local Forwards = false
local Back = false
local Left = false
local Right = false

local MovementHandlerCo 

local Hover = -0.1

local ChairActivate

local Torso
local Character

function HandleMovementFrame()	
	local newPush = Vector3.new(0, 0, 0)
	local forwardVector = game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))

	if Forwards and not Back then newPush = forwardVector * CamSpeedZ end
	if Back and not Forwards then newPush = newPush + forwardVector * -CamSpeedZ end
	if Left and not Right then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * CamSpeedX end
	if Right and not Left then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * CamSpeedX end

	FlightSpin.cframe = CFrame.new(Vector3.new(0, 0, 0), forwardVector) -- have torso face Forwards
	if newPush.magnitude < 1 then
		FlightHold.maxForce = Vector3.new(0, 0, 0)
		FlightPower.maxForce = Vector3.new(0, 0, 0)
		if Torso then FlightHold.position = Torso.Position end
	else
		FlightHold.maxForce = Vector3.new(0, FlightHold.P/100, 0)
		FlightPower.maxForce = Vector3.new(FlightPower.P * 100, 0, FlightPower.P * 100)
	end
	FlightPower.velocity = newPush
end

function HandleMovement()		
	ChairActivate = Tool:FindFirstChild("ChairActivate")
	if ChairActivate then
		while ChairActivate.Value do
			HandleMovementFrame()
			wait()
		end
	end
end

function KeyUpFunc(key)		
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		Forwards = false
	elseif key == "a" then
		Left = false
	elseif key == "s" then
		Back = false
	elseif key == "d" then
		Right = false
	end	
end

function KeyDownFunc(key)		
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		Forwards = true
	elseif key == "a" then
		Left = true
	elseif key == "s" then
		Back = true
	elseif key == "d" then
		Right = true
	end	
end

function Transport()	
	ChairActivate = Tool:FindFirstChild("ChairActivate")
	if ChairActivate then
		if ChairActivate.Value == 0 then return end
	end
	Character = Tool.Parent
	Torso = Character:FindFirstChild("Torso")
	print(Character, Torso)
	if Torso == nil then return end
	
	FlightPower = Torso:FindFirstChild("FlightPower")
	FlightSpin = Torso:FindFirstChild("FlightSpin")
	FlightHold = Torso:FindFirstChild("FlightHold")

	while FlightPower == nil or FlightSpin == nil or FlightHold == nil do
		Torso.ChildAdded:wait()
		FlightPower = Torso:FindFirstChild("FlightPower")
		FlightSpin = Torso:FindFirstChild("FlightSpin")
		FlightHold = Torso:FindFirstChild("FlightHold")
	end		
	MovementHandlerCo = coroutine.create(HandleMovement)	
	coroutine.resume(MovementHandlerCo)	
end

function OnEquipped(mouse)			
	if mouse then		
		Forwards = false
		Back = false
		Left = false
		Right = false				
		mouse.KeyDown:connect(KeyDownFunc)
		mouse.KeyUp:connect(KeyUpFunc)				
	end
	ChairActivate = WaitForChild(Tool, "ChairActivate")
	if ChairActivate then ChairActivate.Changed:connect(Transport) end
end

Tool.Equipped:connect(OnEquipped)

