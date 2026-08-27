function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent
local Handle = Tool.Handle

local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local Torso = myCharacter:FindFirstChild("Torso")
if not Torso then script:Remove() end

local Volleyball = Handle:Clone()
Volleyball.Transparency = 0.0
Volleyball.CanCollide = true
Volleyball.Name = "Volleyball"

local LastHitTime

--[[local TouchSensor = Instance.new("Part")
TouchSensor.Shape = Enum.PartType.Ball
TouchSensor.Size = 2 * Volleyball.Size
TouchSensor.CanCollide = false
TouchSensor.Locked = true
TouchSensor.Transparency = 1.0
TouchSensor.Name = "VolleyballTouchSensor"


local SensorWeld = Instance.new("Weld")
SensorWeld.Part0 = Volleyball
SensorWeld.Part1 = TouchSensor
]]

function noise()
	return 2 * (Vector3.new(math.random(), math.random(), math.random()) - Vector3.new(0.5, 0.5, 0.5))
end

function randAngle()
	return 2 * math.pi * math.random()
end

wait(1.2)

local lookVector = Torso.CFrame.lookVector
Volleyball.Velocity = 60 * lookVector + Vector3.new(0, 70, 0) + 10 * noise()
local startPos = Torso.Position + 2.11*lookVector + .9 * Vector3.new(lookVector.Z, .1, -lookVector.X)
Volleyball.CFrame = CFrame.new(startPos) * CFrame.Angles(randAngle(), randAngle(), randAngle())
Volleyball.RotVelocity = noise()
--[[TouchSensor.Velocity = Volleyball.Velocity
TouchSensor.CFrame = Volleyball.CFrame
]]
Volleyball.Parent = game.Workspace
LastHitTime = waitForChild(Volleyball, "LastHitTime")
LastHitTime.Value = tick()

--[[function onTouch(hit)
	if (hit.Name == "Left Arm" and hit:FindFirstChild("CanHitVolleyball")) then
		local otherCharacter = hit.Parent	-- It must be a character or we wouldn't have found CanHitVolleyball.
		if otherCharacter then
			local otherTorso = otherCharacter:FindFirstChild("Torso")
			if otherTorso then
				lastHimTime = tick()
				local otherLookVector = otherTorso.CFrame.lookVector
				Volleyball.Velocity = 60 * otherLookVector + Vector3.new(0, 70, 0) + 10 * noise()
			end
		end
	end
end

TouchSensor.Touched:connect(onTouch)
]]
-- Remove volleyball and script if it's been a while since it's been hit.
while Volleyball do
	local currTime = tick()
	if currTime - LastHitTime.Value > 5 then
		Volleyball:Remove()
	end
	wait(1)	-- (It doesn't need to be exact.)
end

script:Remove()



