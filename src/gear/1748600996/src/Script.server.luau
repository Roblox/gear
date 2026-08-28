-- // Created by StarWars
local runService = game:GetService("RunService")
local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle

local gear = GearService:BindGear(tool, "Sword")
gear.Class:DisableLunge()
gear:SetupLocalScript("MouseIcon")

local SWING_TIME = 2

local spinning = false
local spinStart = 0

gear:BindActivateFunction("hammerSwing", function()
	local motor6D = handle:FindFirstChild("Spinner")
	if motor6D and not spinning then
		motor6D.MaxVelocity = 0.1
		motor6D.DesiredAngle = 10000000
		spinning = true
		spinStart = tick()
	end
end)

gear:BindUnequippedFunction("hammerUnequipped", function()
	spinning = false
	local motor6D = handle:FindFirstChild("Spinner")
	if motor6D then
		motor6D.MaxVelocity = 0
	end
end)

runService.Stepped:Connect(function()
	local now = tick()
	if now - spinStart > SWING_TIME then
		spinning = false
		local motor6D = handle:FindFirstChild("Spinner")
		if motor6D then
			motor6D.MaxVelocity = 0
		end
	end
end)