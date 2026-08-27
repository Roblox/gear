local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle",10)

local DrinkAnim
local DrinkSound
local ScreamSound

local EnabledScript
local SpeedScript

local myCharacter
local myHumanoid

if not Tool:FindFirstChild("ChangeEnabledCopy") then
	Tool.Enabled = true
end

function onActivated()
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
	if not myHumanoid then return end

	if not Tool.Enabled then return end
	Tool.Enabled = false

	DrinkAnim = Tool:FindFirstChild("Drink"..myHumanoid.RigType.Name)
	if DrinkAnim then DrinkAnim = myHumanoid:LoadAnimation(DrinkAnim) end
	if DrinkAnim then DrinkAnim:Play() end

	wait(0.5)

	DrinkSound = Handle:FindFirstChild("DrinkSound")
	if DrinkSound then DrinkSound:Play() end
	
	wait(1)

	ScreamSound = Handle:FindFirstChild("Yeehaw")
	if ScreamSound then ScreamSound:Play() end

	wait(1.5)

	SpeedScript = Tool:FindFirstChild("SpeedScript")
	if SpeedScript then
		SpeedScript = SpeedScript:Clone()
		SpeedScript.Parent = myCharacter
		SpeedScript.Disabled = false
	end

	EnabledScript = Tool:FindFirstChild("ChangeEnabled")	-- Using a script to change the enabled/disabled-ness of the tool, to avoid problems
	if EnabledScript then											--   when tool is backspaced in the middle of use.
		EnabledScript = EnabledScript:Clone()
		EnabledScript.Name = "ChangeEnabledCopy"
		EnabledScript.Parent = Tool
		EnabledScript.Disabled = false
	end
end

function onUnequipped()
	if DrinkAnim then DrinkAnim:Stop() end
	if DrinkSound then DrinkSound:Stop() end
	if ScreamSound then ScreamSound:Stop() end
end

Tool.Activated:Connect(onActivated)
Tool.Unequipped:Connect(onUnequipped)