local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter
local myHumanoid

local unholyBlast

local launchAnim 

function hellBlast(key)	
	if key:lower() == "q" then 
		unholyBlast = Tool:FindFirstChild("UnholyBlast")
		if unholyBlast and unholyBlast.Value == 0 then 
			unholyBlast.Value = 1
			launchAnim = myHumanoid:LoadAnimation(Tool.LaunchAnim)
			if launchAnim then launchAnim:Play() end
		end
	end
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then 
		mouse.KeyDown:connect(hellBlast)
	end
end


function onUnequipped()
	if blastAnim then blashAnim:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
