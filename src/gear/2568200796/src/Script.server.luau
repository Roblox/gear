-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local turkey = InsertService:LoadAsset(2514076591)
turkey = turkey:GetChildren()[1]

gear.Class:SetMountModel(turkey)