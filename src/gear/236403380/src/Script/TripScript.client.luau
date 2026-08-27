--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
if Humanoid then
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
	Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	
	Humanoid.Changed:connect(function(Property)
		Humanoid.Jump = false
		--Humanoid.Sit = true
	end)
end