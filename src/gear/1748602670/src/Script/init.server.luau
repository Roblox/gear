-- // Created by StarWars
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local tool = script.Parent
tool.Handle.Transparency = 1

local MillenniumFalcon = require(script.MillenniumFalcon)

local character = nil
local player = nil
local currentFalcon = nil

function onEquipped()
	if currentFalcon then
		currentFalcon:Destroy()
	end
	
	character = tool.Parent
	player = players:GetPlayerFromCharacter(character)
	
	if player then
		currentFalcon = MillenniumFalcon.new(player)
	end
end

function onUnequipped()
	if currentFalcon then
		currentFalcon:Destroy()
	end
	
	currentFalcon = nil
	player = nil
	character = nil
end

runService.Stepped:Connect(function()
	if currentFalcon then
		currentFalcon:Update()
	end
end)

tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)