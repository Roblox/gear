local GearService = require(1075123174)

local Tool = script.Parent
local Gear = GearService:BindGear(Tool, "Sword")
Gear.Class:SetLungeDamage(20)
Gear.Class:SetSlashDamage(10)