-- Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "LaserGun")
gear.Class:SetColors({Color3.fromRGB(90, 143, 222)})
