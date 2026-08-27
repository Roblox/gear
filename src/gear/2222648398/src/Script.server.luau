-- // Created by StarWars
local insertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")
gear.Class:SetMountModel(insertService:LoadAsset(2280321704):GetChildren()[1])