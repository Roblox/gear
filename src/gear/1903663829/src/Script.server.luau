-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool)
gear:SetupLocalScript("MouseIcon")

for _, particle in next, tool.Handle.BarrelAttachment:GetChildren() do
	if particle:IsA("ParticleEmitter") then
		particle.Enabled = false
	end
end
gear:BindActivateFunction("soakerActivate", function()
	for _, particle in next, tool.Handle.BarrelAttachment:GetChildren() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end
	
	local hit = GearService:CastRay(gear.Humanoid.RootPart.CFrame.p, gear.Humanoid.RootPart.CFrame.lookVector, 10, {gear.Character})
	if hit and hit.Parent then
		local parentTo = hit.Parent
		if parentTo:IsA("Tool") or parentTo:IsA("Accessory") then
			parentTo = parentTo.Parent
		end
		local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(5)
		end
	end 
	wait(0.5)
	for _, particle in next, tool.Handle.BarrelAttachment:GetChildren() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end
	wait(1)
end)

