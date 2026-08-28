-- // Created by StarWars
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Sword")

tool.Open.Transparency = 1
tool.Close.Transparency = 0

gear:BindActivateFunction("umbrellaSwing", function()
	tool.Open.Transparency = 0
	tool.Close.Transparency = 1
	for _, player in next, players:GetPlayers() do
		if player ~= gear.Player and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.RootPart then
				local direction = (gear.Humanoid.RootPart.CFrame.p - humanoid.RootPart.CFrame.p).Unit
				humanoid.RootPart.Velcoity = direction * 50
			end
		end
	end
	delay(1, function()
		tool.Open.Transparency = 1
		tool.Close.Transparency = 0
	end)
end)
