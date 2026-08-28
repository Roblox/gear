-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "Sword")
gear.Class:SetLungeDamage(45)
gear.Class:SetSlashDamage(15)