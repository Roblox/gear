-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
local Display = Tool:FindFirstChild("Display")
if Display then
	Display:Destroy()
end

local ElkModel = InsertService:LoadAsset(1175033237)
ElkModel = ElkModel:GetChildren()[1]

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool, "Mount")
Gear.Class:SetMountModel(ElkModel)