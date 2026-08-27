--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Logo = script:WaitForChild("Logo")

ToolEquipped = false

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		LogoCopy = Logo:Clone()
		LogoCopy.Adornee = Head
		LogoCopy.Enabled = true
		Debris:AddItem(LogoCopy, 5)
		LogoCopy.Parent = Tool
	end)
	ToolEquipped = true
end

function Unequipped()
	if LogoCopy and LogoCopy.Parent then
		LogoCopy:Destroy()
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)