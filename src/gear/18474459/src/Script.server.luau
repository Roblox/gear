-- // Recreated by StarWars
local Tool = script.Parent

local GearService = require(1075123174)
local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()

local Remotes = Tool:WaitForChild("Remotes")
local ClientControls = Remotes:WaitForChild("ClientControls") 
local ServerControls = Remotes:WaitForChild("ServerControls")

ServerControls.OnServerInvoke = function(player, mode, value)
	if player ~= Gear.Player then return end 
	if not mode then return end
	
	if mode == "PaintPart" and value then
		if value.Part and value.Color then
			value.Part.Color = value.Color
		end
	end
end