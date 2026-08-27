--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BookGui = script:WaitForChild("BookGui")

ToolEquipped = false

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not CheckIfAlive() then
		return
	end
	if BookGuiCopy and BookGuiCopy.Parent then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		BookGuiCopy = BookGui:Clone()
		BookGuiCopy.Parent = PlayerGui
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
end

function Unequipped()
	if BookGuiCopy and BookGuiCopy.Parent then
		Debris:AddItem(BookGuiCopy, 0)
	end
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)