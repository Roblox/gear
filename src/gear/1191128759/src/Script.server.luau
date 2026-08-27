-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
local Display = Tool:FindFirstChild("Display")
if Display then
	Display:Destroy()
end

local RamModel = InsertService:LoadAsset(1175032663)
RamModel = RamModel:GetChildren()[1]

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool, "Mount")
Gear.Class:SetMountModel(RamModel)