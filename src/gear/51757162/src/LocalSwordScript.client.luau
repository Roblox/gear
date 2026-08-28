local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter

function onKeyDown(key)
	if key:lower() == "x" then 
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:findFirstChild("Humanoid")
		if myHumanoid ~= nil and myHumanoid.Health > 30 then 			
			berserkScript = vCharacter:FindFirstChild("BerserkerScript")
			if berserkScript == nil then 
				monsta = Instance.new("Sound") 
				monsta.Parent = Tool
				monsta.Volume = 1.0 
				monsta.SoundId = "http://www.roblox.com/asset/?id=51756494" 
				monsta.Name = "monsta" 
				berserkScript = Tool.BerserkerScript:Clone()
				berserkScript.Parent = vCharacter
				berserkScript.Disabled = false
				--if monsta then monsta:Play() end
			end
		end
	end
end

function onEquippedLocal(mouse)
	mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedLocal()
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)