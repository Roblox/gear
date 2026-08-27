-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local lionMount = InsertService:LoadAsset(2582773178)
lionMount = lionMount:GetChildren()[1]

gear.Class:SetMountModel(lionMount)