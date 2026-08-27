local Tool = script.Parent
local Catapult = Tool.Handle

local vCharacter 
local myTorso 
local myHumanoid

local breakAnim

function breakIt(key)
	if key:lower() == "q" then 
		local breakC = Tool:FindFirstChild("BreakCatapult")
		if breakC and breakC.Value == false then 
			breakAnim = myHumanoid:LoadAnimation(Tool.BreakAnim)
			if breakAnim then breakAnim:Play() end 
			breakC.Value = true 
		end
	end 
end 

function onEquipped(mouse)
	if mouse then 
		vCharacter = Tool.Parent 
		myTorso = vCharacter:FindFirstChild("Torso")
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		mouse.KeyDown:connect(breakIt) 
	end 
end 

function onUnequipped()
	if breakAnim then breakAnim:Stop() end
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
