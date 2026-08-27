local Tool = script.Parent
local Bolt = Tool.Handle

local vCharacter
local myHumanoid 
local myTorso 

local activateWrathOfGod 

function unleashWrath(key)
	if key:lower() == "q" then 
		activateWrathOfGod = Tool:FindFirstChild("WrathOfGod")
		if activateWrathOfGod and activateWrathOfGod.Value == false then 
			activateWrathOfGod.Value = true 
		end 
	end 
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if mouse then 
		mouse.KeyDown:connect(unleashWrath)
	end 
end

Tool.Equipped:connect(onEquipped)

