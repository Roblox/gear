--[[
	By ArceusInator
--]]
local GLib = require(206209239)
local Tool = script.Parent

local Equipped = false
local Health = 200
local HealthyHumanoid

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
	
	local character, player, humanoid = GLib.GetCharacter(Tool)
	if humanoid then
		humanoid.MaxHealth = Health
		humanoid.Health = humanoid.Health/100 * Health
		HealthyHumanoid = humanoid
	end
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	if HealthyHumanoid then
		HealthyHumanoid.Health = HealthyHumanoid.Health * 100/Health
		HealthyHumanoid.MaxHealth = 100
		HealthyHumanoid = nil
	end
end)