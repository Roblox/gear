--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players.LocalPlayer
Character = Player.Character
Mouse = Player:GetMouse()

Mouse.Icon = ""

if Character then
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Humanoid") then
			v.CameraOffset = Vector3.new(0, 0, 0)
		end
	end
end

Debris:AddItem(script, 0.5)