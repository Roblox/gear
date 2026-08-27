-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local mooseMount = InsertService:LoadAsset(2646363772)
mooseMount = mooseMount:GetChildren()[1]

gear.Class:SetMountModel(mooseMount)