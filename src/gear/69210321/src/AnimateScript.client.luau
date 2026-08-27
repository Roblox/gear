local Tool = script.Parent 
local Staff = Tool.Handle

local vCharacter 
local myHumanoid 
local myTorso 


local firePart = Staff:FindFirstChild("FirePart")
local storeWeld = Staff:FindFirstChild("FireWeld")
while storeWeld == nil or firePart == nil do 
	firePart = Staff:FindFirstChild("FirePart")
	storeWeld = Staff:FindFirstChild("FireWeld")
	wait()
end


function choiceIsYours(key)
	if vCharacter == nil or myHumanoid == nil then return end 
	key = key:lower()
	if key == "q" then 
		print("Q")
		abyss = Tool:FindFirstChild("Abyss")
		if abyss and abyss.Value == false then 			
			abyss.Value = true
		end
	end
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")	
	if mouse then 
		mouse.KeyDown:connect(choiceIsYours)
	end
	if storeWeld then 
		local reWeld = storeWeld:Clone()
		reWeld.Parent = Staff
	end
end

Tool.Equipped:connect(onEquipped)

