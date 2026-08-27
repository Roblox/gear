local Tool = script.Parent
local GhostScript = Tool.GhostScript

local CurrentGhost = nil
local Character = nil

local SpawnGhostEvent = Instance.new("RemoteEvent")
SpawnGhostEvent.Name = "SpawnGhost"
SpawnGhostEvent.OnServerEvent:connect(function(player)
	if CurrentGhost.Value then return end
	if Character ~= player.Character then return end	
	
	local NewModel = Instance.new("Model")
	NewModel.Name = "Ghost Pet"
	NewModel.Parent = Tool.Parent
	local NewScript = GhostScript:Clone()
	NewScript.Disabled = false
	NewScript.creator.Value = player
	NewScript.Parent = NewModel
	CurrentGhost.Value = NewModel
	
	game.Debris:AddItem(Tool, 0.1)
end)
SpawnGhostEvent.Parent = script.Parent

Tool.Equipped:connect(function()
	Character = Tool.Parent
	local Player = game.Players:GetPlayerFromCharacter(Character)
	if Player and Player:FindFirstChild("CurrentGhost") then
		CurrentGhost = Player.CurrentGhost
	elseif Player then
		CurrentGhost = Instance.new("ObjectValue")
		CurrentGhost.Name = "CurrentGhost"
		CurrentGhost.Parent = Player
	end
end)

Tool.Unequipped:connect(function()
	Character = nil
end)