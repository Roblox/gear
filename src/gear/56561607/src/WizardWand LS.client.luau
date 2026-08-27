math.randomseed(tick()); math.random()

local Tool = script.Parent
local Wand = Tool.Handle

local CloneScript
local ScriptToRemove
local GuiToRemove

local debris = game:GetService("Debris")

local myMouse = Tool.Mouse

local myCharacter
local myPlayer
local ScreenGui
local FakeShoulder
local Torso
local RightShoulder

local Sparkles = Instance.new("Sparkles")
Sparkles.Name = "Wizard Wand Sparkles"
Sparkles.SparkleColor = Color3.new(1, 0, 0)

local Tip = Instance.new("Part")
Tip.Name = "Wizard Wand Tip"
Tip.formFactor = Enum.FormFactor.Custom
Tip.CanCollide = false
Tip.Locked = true
Tip.Size = Vector3.new(0.2, 0.2, 0.2)
Tip.Transparency = 1.0

local TipWeld = Instance.new("Weld")
TipWeld.Name = "Wizard Wand Tip Weld"
TipWeld.Part0 = Wand
TipWeld.Part1 = Tip
TipWeld.C1 = CFrame.new(0, 0, -0.54)

local HelpGui = Tool:FindFirstChild("WizardWandHelpGui")
if HelpGui then HelpGui = HelpGui:Clone() end

local HelpedBoolValue = Instance.new("BoolValue")
HelpedBoolValue.Name = "WizardWandHelped"
HelpedBoolValue.Value = true

function instantiateTip()
	Tip.Parent = game.Workspace
	TipWeld.Parent = game.Workspace
	Sparkles.Parent = Tip
end

function changeSpell(key)
	-- You can only switch spells when you're not in the middle of casting one. This helps other
	--  users know what to prepare for.
	if not Tool.Enabled then return end
	local newKey = key:lower()
	if (newKey == "f" or newKey == "x" or newKey == "e") then
		Tool.SpellKey.Value = newKey
		if newKey == "x" then Sparkles.SparkleColor = Color3.new(0, 1, 1)
		elseif newKey == "e" then Sparkles.SparkleColor = Color3.new(75/255, 0, 130/255)
		else	--[[newKey == "f"]] Sparkles.SparkleColor = Color3.new(1, 0, 0)
		end
	end
end

function onLeftMouseDown()
	CloneScript = Tool:FindFirstChild("DrawSpell")
	if CloneScript then
		-- Changing tool's Grip:
		Tool.GripForward = Vector3.new(0, 0, 1)
		Tool.GripPos = Vector3.new(0, 0, -0.48)
		Tool.GripRight = Vector3.new(0, 1, 0)
		Tool.GripUp = Vector3.new(1, 0, 0)
		CloneScript = CloneScript:Clone()
		CloneScript.Parent = Tool
		CloneScript.Name = "RunningDrawSpell"
		CloneScript.Disabled = false
	end
end

function onEquipped(mouse)
	if mouse then
		myMouse.Value = mouse
		mouse.KeyDown:connect(changeSpell)
		mouse.Button1Down:connect(onLeftMouseDown)
	end
	-- Get references to myCharacter and RightShoulder, to be used later
	myCharacter = Tool.Parent
	if myCharacter then
		Torso = myCharacter:FindFirstChild("Torso")
		if Torso then
			RightShoulder = Torso:FindFirstChild("Right Shoulder")
		end
		-- Also display help message if necessary.
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		if myPlayer then
			if not myPlayer:FindFirstChild("WizardWandHelped") then
				HelpGui.Parent = myPlayer.PlayerGui
				debris:AddItem(HelpGui, 5)
				HelpedBoolValue.Parent = myPlayer
			end
		end
	end

	instantiateTip()
end

function onUnequipped()
	Tip.Parent = nil
	TipWeld.Parent = nil
	Sparkles.Parent = nil
	if Tool.Parent == game.Workspace then	--i.e. if the tool was backspaced, then...
		if myCharacter then
			Torso = myCharacter:FindFirstChild("Torso")
			if Torso then
				Wand.Position = Torso.Position + 8 * Torso.CFrame.lookVector + Vector3.new(0, 7, 0)
			end
		end
		if Tool:FindFirstChild("SpellKey") then Tool.SpellKey.Value = "f" end
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
