-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local babyNessie = InsertService:LoadAsset(2431256078)
babyNessie = babyNessie:GetChildren()[1]

gear.Class:SetMountModel(babyNessie)