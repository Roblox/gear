-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Mount")

local seaDragon = InsertService:LoadAsset(2552781085)
seaDragon = seaDragon:GetChildren()[1]

gear.Class:SetMountModel(seaDragon)