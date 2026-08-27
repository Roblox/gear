--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Grips = {
	Unequipped = CFrame.new(1.25, -0.2, 0.1, 1, -0, 0, 0, 1, -0, 0, 0, 1),
	Equipped = CFrame.new(1.25, -0.2, 0.1, 0.984703243, -0, 0.17423971, 0, 1, 0, -0.174239695, 0, 0.984703362),
}

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)