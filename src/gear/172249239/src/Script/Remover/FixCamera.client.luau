--Made by Luckymaxer

Parent = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Camera = game:GetService("Workspace").CurrentCamera

PossiblePlayer = Players:GetPlayerFromCharacter(Parent)

Player = ((Parent:IsA("Backpack") and Parent.Parent) or (PossiblePlayer and PossiblePlayer))
Character = Player.Character
Humanoid = Character:FindFirstChild("Humanoid")

Camera.CameraSubject = Humanoid

Debris:AddItem(script, 2)