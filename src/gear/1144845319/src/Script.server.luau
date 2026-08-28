-- Created by StarWars
local GearService = require(1075123174)

local GearData = GearService:BindGear(script.Parent, "LaserGun")
GearData.Class:SetColors({Color3.fromRGB(234, 0, 234), Color3.fromRGB(0, 189, 227), Color3.fromRGB(113, 230, 3), Color3.fromRGB(255, 255, 50)})
GearData.Class:SetFireSound(130113322)
GearData.Class:SetDamage(10)