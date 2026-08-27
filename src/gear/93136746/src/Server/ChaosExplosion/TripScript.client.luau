--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Character = script.Parent
Humanoid = Character:FindFirstChildOfClass("Humanoid")
if Humanoid then
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
	Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	
	Humanoid.Changed:Connect(function(Property)
		Humanoid.Jump = false
		Humanoid.Sit = true
	end)
end