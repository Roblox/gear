-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
local Display = Tool:FindFirstChild("Display")
if Display then
	Display:Destroy()
end

local PinataModel = InsertService:LoadAsset(1664679743)
PinataModel = PinataModel:GetChildren()[1]

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool, "Mount")
Gear.Class:SetMountModel(PinataModel)