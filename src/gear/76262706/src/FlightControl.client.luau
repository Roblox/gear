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
local myHumanoid 
local vCharacter

local playAnim 

local blastAnim 

function handleMovementFrame()
	local newPush = Vector3.new(0,0,0)
	local forwardVector = game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))

	if forwards and not back then newPush = forwardVector * camSpeedZ end
	if back and not forwards then newPush = newPush + forwardVector * -camSpeedZ end
	if left and not right then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * camSpeedX end
	if right and not left then newPush = newPush + game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * camSpeedX end

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
	elseif key == "q" then 
		massFire = Tool:FindFirstChild("MassFire") 
		if massFire and massFire.Value == false then massFire.Value = true end 
	end	
end

function wingActivate()	
	wingActive = Tool:FindFirstChild("WingActive")
	if wingActive then
		if wingActive.Value == 0 then return end
	end
	local vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then return end
	
	flightPower = vCharacter.Torso:FindFirstChild("FlightPower")
	flightSpin = vCharacter.Torso:FindFirstChild("FlightSpin")
	flightHold = vCharacter.Torso:FindFirstChild("FlightHold")

	while flightPower == nil or flightSpin == nil or flightHold == nil do		
		Tool.Parent.Torso.ChildAdded:wait()
		flightPower = Tool.Parent.Torso:FindFirstChild("FlightPower")
		flightSpin = Tool.Parent.Torso:FindFirstChild("FlightSpin")
		flightHold = Tool.Parent.Torso:FindFirstChild("FlightHold")
	end		
	print("Handling Movement")
	movementHandlerCo = coroutine.create(handleMovement)	
	coroutine.resume(movementHandlerCo)	
end

function onEquipped(mouse)	
	print("Equipped")
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") 
	if mouse then		
		forwards = false
		back = false
		left = false
		right = false				
		mouse.KeyDown:connect(keyDownFunc)
		mouse.KeyUp:connect(keyUpFunc)				
	end
	wingActive = Tool:FindFirstChild("WingActive")
	if wingActive then print("Connection established") wingActive.Changed:connect(wingActivate) end
end

function onUnequipped()
	if blastAnim then blastAnim:Stop() end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

while Tool:FindFirstChild("PlayAnim") == nil do wait() end 
playAnim = Tool.PlayAnim
playAnim.Changed:connect(function()
	if playAnim and playAnim.Value == true then 
		-- Play the animation
		blastAnim = myHumanoid:LoadAnimation(Tool.BlastAnim)
		if blastAnim then blastAnim:Play() end 
		wait(2.0)
		playAnim.Value = false 
	end  
end) 

