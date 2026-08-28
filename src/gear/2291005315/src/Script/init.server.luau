-- // Created by StarWars
local debris = game:GetService("Debris")

local GearService = require(1075123174)

local particleEmitter = script.ParticleEmitter

local tool = script.Parent
local gear = GearService:BindGear(tool, "LaserGun")

gear.Class.OnLaserFired:Connect(function(laserPart)
	local newPart = laserPart:Clone()	
	newPart.Transparency = 1
	
	local newSmoke = particleEmitter:Clone()
	newSmoke.Parent = newPart
	newSmoke.Enabled = true	
	
	newPart.Parent = workspace
	wait(0.2)
	newSmoke.Enabled = false
	debris:AddItem(newPart, 10)
end)