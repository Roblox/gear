local Tool = script.Parent
local Character = nil
local Player = game.Players.LocalPlayer

local CurrentGhost = Player:WaitForChild('CurrentGhost')
local Clicked = false

local SpawnGhostEvent = script.Parent:WaitForChild("SpawnGhost")
---------------------------------------

Tool.Equipped:connect(function(mouse)
	--setup
	Character = Tool.Parent
	CurrentGhost = Player:WaitForChild('CurrentGhost', 1)

	--set mouse icon
	if CurrentGhost and not CurrentGhost.Value then
		mouse.Icon = 'http://www.roblox.com/asset/?id=89375832'
	end

	--events
	mouse.Button1Down:connect(function()
		if not Clicked then
			Clicked = true
			SpawnGhostEvent:FireServer()
		end
	end)
end)

Tool.Unequipped:connect(function()
	--teardown
	Clicked = false
	--
end)