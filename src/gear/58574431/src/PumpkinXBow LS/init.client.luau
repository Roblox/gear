math.randomseed(tick()); math.random()

function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent

local ProjectileScript

local myMouse
local TargetedPart

local ScreenGui
local Frame
local ModeActivated
local PressXToSwitch

local myCharacter
local myPlayer

local DefensiveModeVal = Tool:FindFirstChild("DefensiveModeOn")
if DefensiveModeVal then
	defensiveModeOn = DefensiveModeVal.Value
else
	defensiveModeOn = false
end

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	ProjectileScript = Tool:FindFirstChild("PumpkinXBowProjScript")
	if ProjectileScript then
		if DefensiveModeVal.Value then
			for i = 1, 10 do
				local NewProjectileScript = ProjectileScript:Clone()
				NewProjectileScript.Parent = Tool
				NewProjectileScript.Disabled = false
			end
			local LongDisableScript = waitForChild(script, "LongDisable"):Clone()
			LongDisableScript.Parent = Tool
			LongDisableScript.Disabled = false
		else
			TargetedPart = Tool:FindFirstChild("TargetedPart")
			if TargetedPart then
				TargetedPart.Value = myMouse.Target
			end
			ProjectileScript = ProjectileScript:Clone()
			ProjectileScript.Parent = Tool
			ProjectileScript.Disabled = false
			local ShortDisableScript = waitForChild(script, "ShortDisable"):Clone()
			ShortDisableScript.Parent = Tool
			ShortDisableScript.Disabled = false
		end
	end
end

function switchModes(key)
	if key:lower() ~= "x" then return end
	if DefensiveModeVal then
		DefensiveModeVal.Value = not DefensiveModeVal.Value
		if ModeActivated then
			if DefensiveModeVal.Value then
				ModeActivated.Text = "DEFENSIVE MODE ON"
				ModeActivated.TextColor3 = Color3.new(0, 0, 1)
			else
				ModeActivated.Text = "OFFENSIVE MODE ON"
				ModeActivated.TextColor3 = Color3.new(1, 0, 0)
			end
		end
	end
end

function onEquipped(mouse)
	if mouse then 
		myMouse = mouse 
		myMouse.KeyDown:connect(switchModes)
	end
	DefensiveModeVal = waitForChild(Tool, "DefensiveModeOn")
	ScreenGui = waitForChild(Tool, "PumpkinCrossbowGui"):Clone()
	Frame = waitForChild(ScreenGui, "Frame")
	ModeActivated = waitForChild(Frame, "ModeActivated")
	PressXToSwitch = waitForChild(Frame, "PressXToSwitch")

	if DefensiveModeVal.Value then
		ModeActivated.Text = "DEFENSIVE MODE ON"
		ModeActivated.TextColor3 = Color3.new(0, 0, 1)
	else
		ModeActivated.Text = "OFFENSIVE MODE ON"
		ModeActivated.TextColor3 = Color3.new(1, 0, 0)
	end
		
	myCharacter = Tool.Parent
	if myCharacter then
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		ScreenGui.Parent = myPlayer.PlayerGui
	end
end

function onUnequipped()
	if ScreenGui then ScreenGui:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
