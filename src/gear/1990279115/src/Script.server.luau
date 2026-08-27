-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local sharkModel = InsertService:LoadAsset(1989544297)
sharkModel = sharkModel:GetChildren()[1]

gear.Class:SetMountModel(sharkModel)