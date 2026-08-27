function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local Character = script.Parent
local Player = game.Players:GetPlayerFromCharacter(Character)
local Mouse = Player:GetMouse()

local Torso = WaitForChild(Character, "Torso")
local Neck = WaitForChild(Torso, "Neck")
local Humanoid = WaitForChild(Character, "Humanoid")

local NeckAngle = 0

local CroakSound = WaitForChild(script, 'Croak')
spawn(function() CroakSound.Parent = Torso end)
local JumpHumanoid = false
local keysDown = {}


local lastSpace = 0
function onKeyDown(key)
	key = key:lower()
	if key == " " then
		local currTime = tick()
		if currTime - lastSpace > 2 then
			lastSpace = currTime
			NeckAngle = NeckAngle + math.pi*2
			--Neck.DesiredAngle = NeckAngle
		end
	elseif key == "w" or key == "a" or key == "s" or key == "d" or (string.byte(key) == 17 and string.byte(key) == 18) then
		lastSpace = tick()
		keysDown[key] = true
		JumpHumanoid = true
	end
end

function onKeyUp(key)
	key = key:lower()
	if key == "w" or key == "a" or key == "s" or key == "d" or (string.byte(key) == 17 and string.byte(key) == 18) then
		keysDown[key] = nil
		local stopJumping = true
		for _, __ in pairs(keysDown) do
			stopJumping = false
		end
		if stopJumping then
			JumpHumanoid = false
		end
	end
end

Mouse.KeyDown:connect(onKeyDown)
Mouse.KeyUp:connect(onKeyUp)

local soundDebounce = false
while true do
	if JumpHumanoid then
		if not soundDebounce then
			soundDebounce = true
			CroakSound:Play()
			delay(1, function() soundDebounce = false end)
		end
		Humanoid.Jump = true
	end
	wait()
end
