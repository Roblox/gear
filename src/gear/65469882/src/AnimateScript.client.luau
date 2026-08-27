local Tool = script.Parent
local Fist = Tool.Handle

local vCharacter
local myHumanoid

local playAnim

local fistAnim

while Tool:FindFirstChild("PlayAnim") == nil do 
	wait()
end

playAnim = Tool.PlayAnim
playAnim.Changed:connect(function()
	if playAnim and playAnim.Value == true then 
		fistAnim = myHumanoid:LoadAnimation(Tool.FistAnim)
		if fistAnim then fistAnim:Play() end
		wait(1.0)		
		playAnim.Value = false
	end
end)

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

function onUnequipped()
	if fistAnim then fistAnim:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
