--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Camera = game:GetService("Workspace").CurrentCamera

function DestroyScript()
	Debris:AddItem(script, 2)
end

Camera.CameraType = Enum.CameraType.Custom

Player = (((script.Parent:IsA("Model") and Players:GetPlayerFromCharacter(script.Parent)) or (script.Parent:IsA("Backpack") and script.Parent.Parent)) or nil)
if Player then
	Character = Player.Character
	if Character then
		Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			Camera.CameraSubject = Humanoid
		end
	end
end

DestroyScript()