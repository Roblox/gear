local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter 
local rightArm 
local holster 
local myTorso
local leftArm

function onEquipped()
	vCharacter = Tool.Parent 
	rightArm = vCharacter:FindFirstChild("Right Arm")
	leftArm = vCharacter:FindFirstChild("Left Arm")
	holster = vCharacter:FindFirstChild("Holster")
	myTorso = vCharacter:FindFirstChild("Torso")
	local myCF = myTorso.CFrame
	local duration = 0.75
	--while duration > 0 do 
		--myTorso.CFrame = myCF
		--wait()
		--duration = duration - wait()
	--end 
end 

function onUnequipped()
	if vCharacter then 
		if vCharacter:FindFirstChild("Holster") then 
			vCharacter.Holster:Remove() 
		end 
		if vCharacter:FindFirstChild("LeftSword") then 
			vCharacter.LeftSword:Remove() 
		end 
	end 
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

