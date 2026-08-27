--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Drink = Handle:WaitForChild("Drink"),
}

Grips = {
	Normal = CFrame.new(0, 1.29999995, 0, 0.217036337, 0, 0.976163626, 0, 1, -0, -0.976163507, 0, 0.217036366),
	Active = CFrame.new(0, 1.29999995, 0, 0.357813597, 0.900898635, 0.245664507, 0.932332993, -0.329962879, -0.147918284, -0.0521992147, 0.281968266, -0.958002746),
}

Gui = script:WaitForChild("GrapeGUI")
MindGrapeEffect = script:WaitForChild("MindGrapeEffect")

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Tool.Grip = Grips.Active
	Sounds.Drink:Play()
	wait(3)
	if CheckIfAlive() then
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			local Grapes = Character:FindFirstChild(MindGrapeEffect.Name) 
			if not Grapes then
				local GuiCopy = Gui:Clone()
				Gui.Parent = PlayerGui
				local EffectCopy = MindGrapeEffect:Clone()
				local Value = Instance.new("IntValue")
				Value.Name = "GrapeTroubleCountdown"
				Value.Value = 30
				Value.Parent = EffectCopy
				EffectCopy.Disabled = false
				EffectCopy.Parent = Character
			else
				Grapes.GrapeTroubleCountdown.Value = (Grapes.GrapeTroubleCountdown.Value + 15)
			end
		end
	end
	Tool.Grip = Grips.Normal
	wait(8)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)