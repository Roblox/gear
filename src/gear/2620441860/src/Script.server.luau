-- // Created by StarWars
local RunService = game:GetService("RunService")

local Tool = script.Parent
local Top = Tool:WaitForChild("Top")
local Handle = Tool:WaitForChild("Handle")

local Sound = Handle:WaitForChild("Noisemaker")
local Motor = Top:FindFirstChildOfClass("Motor6D")

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool)
Gear:SetupLocalScript("MouseIcon")

local Spin = false
local SpinSpeed = 1500
local Angle = 0

Gear:BindEquippedFunction("noisemaker_equipped", function()
	Spin = false
	Angle = 0
end)

Gear:BindUnequippedFunction("noisemaker_unequipped", function()
	Spin = false
	Angle = 0
	Sound:Stop()
end)

Gear:BindActivateFunction("noisemaker_activate", function()
	Spin = true	
	Sound:Play()
	
	delay(5, function()
		Spin = false
		Sound:Stop()
	end)
	wait(6)
end)

RunService.Stepped:Connect(function(_, delta)
	if Spin == true then
		Angle = (Angle + (SpinSpeed * delta)) % 360
	end

	Motor.Transform = CFrame.Angles(0, 0, math.rad(Angle))
end)