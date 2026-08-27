local Tool = script.Parent
local Cannon = Tool.Handle

local vCharacter 
local myTorso 
local myHumanoid 

function toggleRapidFire(key)
	if key:lower() == "q" then 
		local rapidFire = Tool:FindFirstChild("RapidFire") 
		if rapidFire and rapidFire.Value == false then 
			rapidFire.Value = true 
		end 
	end 
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if mouse then 
		mouse.KeyDown:connect(toggleRapidFire)
	end 
end 

Tool.Equipped:connect(onEquipped)

