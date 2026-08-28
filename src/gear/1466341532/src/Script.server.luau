local GearService = require(1075123174)

local Tool = script.Parent

local Gear = GearService:BindGear(Tool, "Sword")
Gear.Class:DisableLunge()
Gear.Class.Sounds.Unshealth.SoundId = ""
Gear.Class.Sounds.Slash.SoundId = ""