--Rescripted by StarWars
local Tool = script.Parent
local Airstrike = require(script.Airstrike)

local COOL_DOWN = 20

local LastStrike = 0

local OnMouseClickEvent = Instance.new("RemoteEvent")
OnMouseClickEvent.Name = "OnMouseClick"
OnMouseClickEvent.OnServerEvent:connect(function(player, location)
	if tick() - LastStrike > COOL_DOWN then
		LastStrike = tick()
		Airstrike:Spawn(player, location)
	end
end)
OnMouseClickEvent.Parent = Tool