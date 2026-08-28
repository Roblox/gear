-- // Created by StarWars
local tool = script.Parent
local handle = tool.Handle

local needleMotor = handle.Needle

local SPEED_BOOST_MULTIPLIER = 1.5

local character = nil
local humanoid = nil

local cacheWalkspeed = 16

tool.Equipped:Connect(function()
	character = tool.Parent
	humanoid = character:FindFirstChildOfClass("Humanoid")
	cacheWalkspeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = cacheWalkspeed * SPEED_BOOST_MULTIPLIER
	
	needleMotor:SetDesiredAngle(1000000000)
end)

tool.Unequipped:Connect(function()
	if humanoid then
		humanoid.WalkSpeed = cacheWalkspeed
	end
	
	cacheWalkspeed = 16
	humanoid = nil
	character = nil
	
	needleMotor:SetDesiredAngle(0)
	needleMotor.CurrentAngle = 0
end)