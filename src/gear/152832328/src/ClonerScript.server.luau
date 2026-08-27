local chooseEgg = script.Parent.ChooseEgg
local chosenEgg = script.Parent.ChosenEgg

chooseEgg.OnServerEvent:connect(function(player, name) 
	chosenEgg.Value = name
end)

