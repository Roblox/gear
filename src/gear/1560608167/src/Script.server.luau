-- // Created by StarWars
local GearService = require(1075123174)
local Gear = GearService:BindGear(script.Parent, "Sword")
Gear.Class:SetBaseDamage(0)
Gear.Class:SetSlashDamage(5)
Gear.Class:DisableLunge()
Gear.Class.Sounds.Slash.SoundId = "rbxassetid://" .. 1515630304
Gear.Class.Sounds.Unshealth.SoundId = "rbxassetid://" .. 1515630304