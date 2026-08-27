--Made by Luckymaxer

Players = game:GetService("Players")
Player = Players.LocalPlayer
Character = Player.Character
Humanoid = Character:WaitForChild("Humanoid")

Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)