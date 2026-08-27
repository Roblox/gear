--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")
Torso = Character:WaitForChild("Torso")

Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)

Humanoid.Changed:connect(function(Property)
	Humanoid.Jump = false
	--Humanoid.Sit = true
end)