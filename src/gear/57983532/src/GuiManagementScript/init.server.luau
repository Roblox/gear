function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local ScreenGui = waitForChild(script, "VolleyballScreenGui")

local PlayerList = game.Players:GetChildren()

function addGuiToPlayer(Player)
	if Player:FindFirstChild("VolleyballScreenGui") then return end
	if not Player:FindFirstChild("WantsToPlayVolleyball") then

		local GuiClone = ScreenGui:Clone()
		GuiClone.Parent = waitForChild(Player, "PlayerGui")
		waitForChild(GuiClone, "VolleyballPlayerScript").Disabled = false

	elseif Player.WantsToPlayVolleyball.Value == true then

		local GuiClone = ScreenGui:Clone()
		GuiClone.Parent = waitForChild(Player, "PlayerGui")
		waitForChild(GuiClone, "VolleyballPlayerScript").Disabled = false
	end
end

function addGuiToCharacter(char)
	addGuiToPlayer(game.Players:GetPlayerFromCharacter(char))
end

for index, Player in pairs(PlayerList) do
	addGuiToPlayer(Player)
end

game.Players.PlayerAdded:connect(function(Player) Player.CharacterAdded:connect(addGuiToCharacter) end)