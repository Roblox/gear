-- // Created by StarWars
local Players = game:GetService("Players")

local GearService = require(1075123174)

local Tool = script.Parent
local GearData = GearService:BindGear(Tool)
GearData:SetupRemoteFunctions()

local Handle = Tool.Handle
local CameraShutterEffect = Handle.CameraShutter

local ReloadTime = 2
GearData:SetupLocalScript("MouseIcon")

GearData:BindActivateFunction("picture_taken", function()
	for _, player in next, Players:GetPlayers() do
		GearData.ClientControls:InvokeClient(player, "CameraFlash")
	end
	CameraShutterEffect:Play()
	wait(ReloadTime)
end)