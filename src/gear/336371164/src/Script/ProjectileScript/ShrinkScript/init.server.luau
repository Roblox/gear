--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ShrinkMonitor = script:WaitForChild("Shrink")
ShrinkMonitor.Value = false

Creator = script:FindFirstChild("Creator")
Tool = script:FindFirstChild("Tool")

ResizeModule = require(201433042)

ShrinkAmount = 0.85
ShrinkTimes = 0

UndoingShrink = false

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

function Shrink()
	if UndoingShrink then
		return
	end
	local OriginalCF = Torso.CFrame
	local ModelSize = Character:GetModelSize()
	local ModelMass = (ModelSize.X * ModelSize.Y * ModelSize.Z)
	if ModelMass > 2 then
		ShrinkTimes = (ShrinkTimes + 1)
		ResizeModule.ScaleCharacter(Character, ShrinkAmount, {ResizeModels = true, ScaleTools = true, ScaleHats = true})
		Torso.CFrame = OriginalCF
	end
end

function UndoShrink()
	if UndoingShrink then
		return
	end
	UndoingShrink = true
	for i = 1, ShrinkTimes do
		ResizeModule.ScaleCharacter(Character, (1 / ShrinkAmount), {ResizeModels = true})
	end
	script:Destroy()
end

ShrinkMonitor.Changed:connect(function()
	if ShrinkMonitor.Value then
		ShrinkMonitor.Value = false
		Shrink()
	end
end)

Shrink()

if Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") then
	local player = Creator.Value
	player.Changed:connect(function(Property)
		if Property == "Character" and not player.Character or not player.Character.Parent then
			UndoShrink()
		end
	end)
else
	wait(10)
	UndoShrink()
end

if Tool and Tool.Value and Tool.Value.Parent then
	local tool = Tool.Value
	tool.Changed:connect(function(Property)
		if Property == "Parent" and not tool.Parent or (not tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(tool.Parent)) then
			UndoShrink()
		end
	end)
end