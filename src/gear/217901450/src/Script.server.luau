--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

EggModule = require(225918694)

ToolEquipped = false

function DisplayGui()
	if not CheckIfAlive() or (TomeOfEggsGuiCopy and TomeOfEggsGuiCopy.Parent) or not ToolEquipped then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		TomeOfEggsGuiCopy = TomeOfEggsGui:Clone()
		TomeOfEggsGuiCopy.LocalScript.Disabled = false
		TomeOfEggsGuiCopy.Parent = PlayerGui
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	DisplayGui()
end

function GetVariables(Player)
	local Gear = EggModule.GetGear({Key = "TheTomeOfEggs", Player = Player})
	TomeOfEggsGui = Gear.Book:Clone()
end

function Equipped()
	Character = Tool.Parent
	Humanoid = nil
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Humanoid") then
			Humanoid = v
			break
		end
	end
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		GetVariables(Player)
		DisplayGui()
	end)
end

function Unequipped()
	if TomeOfEggsGuiCopy and TomeOfEggsGuiCopy.Parent then
		TomeOfEggsGuiCopy:Destroy()
	end
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)