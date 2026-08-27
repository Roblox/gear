-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local tiger = InsertService:LoadAsset(2713350844)
tiger = tiger:GetChildren()[1]

gear.Class:SetMountModel(tiger)