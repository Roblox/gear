local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool, "LaserGun")
gear.Class:SetColors({Color3.fromRGB(86, 255, 248)})