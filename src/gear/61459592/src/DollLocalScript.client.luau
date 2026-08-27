local Tool = script.Parent
local Doll = Tool.Handle

local vCharacter
local myHumanoid

function swap(key)
	if key:lower() == "q" and myTorso then
		local dollModel = vCharacter:FindFirstChild("DollModel")
		local dollClone = vCharacter:FindFirstChild("AlienVoodoo")			
		if dollClone then 
			myTorso.CFrame = dollClone.CFrame
			dollClone:Destroy() 
		end
		if dollModel then dollModel:Destroy() end
	end
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if mouse then 
		mouse.KeyDown:connect(swap)
	end
end

Tool.Equipped:connect(onEquipped)
