--Made by Luckymaxer

Self = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
StarterGui = game:GetService("StarterGui")

Camera = game:GetService("Workspace").CurrentCamera

Player = (Self:IsA("Backpack") and Self.Parent) or (Players:GetPlayerFromCharacter(Self))

if Player then
	Character = Player.Character
	if Character then
		Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
			Camera.CameraSubject = Humanoid
			Camera.CameraType = Enum.CameraType.Custom
		end
	end
end

Debris:AddItem(script, 1)