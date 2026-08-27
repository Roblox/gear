wait() --Fix implemented by Luckymaxer
print('Transport Script')
local function WaitForChild(parent, childName)
	print(parent, childName)
	while parent:FindFirstChild(childName) == nil do 
		wait()
	end 
	return parent[childName]
end 

local Tool = script.Parent

local FlightPower 
local FlightSpin 
local FlightHold 

local CamSpeedZ = 50
local CamSpeedX = 40

local Forwards = false
local Back = false
local Left = false
local Right = false

local MovementHandlerCo 

local Hover = -0.1

local HorseActivate

local Player = Game.Players.LocalPlayer
while Player.Character == nil do wait() end 
local Character = Player.Character
local Torso = WaitForChild(Character, 'Torso')

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
	HorseActivate = Tool:FindFirstChild("HorseActivate")
	if HorseActivate then
		while HorseActivate.Value do
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
	HorseActivate = Tool:FindFirstChild("HorseActivate")
	if HorseActivate then
		if HorseActivate.Value == 0 then return end
	end	
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
	Character = Tool.Parent 
	Torso = WaitForChild(Character, 'Torso')		
	if mouse then		
		Forwards = false
		Back = false
		Left = false
		Right = false				
		mouse.KeyDown:connect(KeyDownFunc)
		mouse.KeyUp:connect(KeyUpFunc)				
	end
	HorseActivate = WaitForChild(Tool, "HorseActivate")
	if HorseActivate then HorseActivate.Changed:connect(Transport) end
end

Tool.Equipped:connect(OnEquipped)

