--Fluffy AI Controller

local Fluffy = script.Parent

local RotationSpeed = 2
local BobSpeed = 1
local RotationDist = Vector3.new(3, 1, 0)


local dt = 0
local currentTime = 0

while true do
		
	
	local parentPos = Fluffy.Parent.CFrame
	--Rotate Fluffy around the player's head
	local rotation = CFrame.Angles(0 , RotationSpeed * currentTime, 0)
	local bob = Vector3.new(0, BobSpeed * math.sin(currentTime), 0)

	Fluffy.CFrame =  ((parentPos + bob)  + (rotation * RotationDist))
	local Sparkles = Fluffy.FluffyTrail

	--Change Fluffy's particle color
	local r = (math.sin(currentTime) + 1) / 2
	local g = (math.cos(currentTime) + 1) / 2
	local b = ((math.cos(currentTime) * math.sin(currentTime)) + 1) / 2
	Sparkles.SparkleColor = Color3.new(r, g, b)

	--Wait some time so we aren't going plaid
	dt, currentTime = wait(1/40)
	
end


