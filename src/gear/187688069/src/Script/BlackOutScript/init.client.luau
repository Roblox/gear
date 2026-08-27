--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")
Torso = Character:WaitForChild("Torso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

KnockOut = script:WaitForChild("KnockOut")

Player = Players:GetPlayerFromCharacter(Character)
if Player then
	PlayerGui = Player:FindFirstChild("PlayerGui")
	BlackOutGui = Instance.new("ScreenGui")
	BlackOutGui.Name = "BlackOutGui"
	Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = BrickColor.new("Really black").Color
	Frame.Size = UDim2.new(1.1, 0, 1.1, 0)
	Frame.Position = UDim2.new(-0.05, 0, -0.05, 0)
	Frame.Parent = BlackOutGui
	for i, v in pairs(PlayerGui:GetChildren()) do
		if v.Name == BlackOutGui.Name then
			v:Destroy()
		end
	end
	Debris:AddItem(BlackOutGui, 15)
	BlackOutGui.Parent = PlayerGui
end

Humanoid.WalkSpeed = 0

KnockOutAnimation = Humanoid:LoadAnimation(KnockOut)
KnockOutAnimation:Play()

wait(5)

for i = 1, (50 - 1) do
	Frame.Transparency = (Frame.Transparency + 0.025)
	wait(0.01)
end
	
if BlackOutGui and BlackOutGui.Parent then
	BlackOutGui:Destroy()
end
if KnockOutAnimation then
	KnockOutAnimation:Stop()
end

Humanoid.WalkSpeed = 16

script:Destroy()