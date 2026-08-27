local Tool = script.Parent 
local Cannon = Tool.Handle

local vCharacter 
local myTorso 
local myHumanoid 

local cannonWalkAnim 

local chargeCannon

function charge(key)
	if key:lower() == "q" then 
		chargeCannon = Tool:FindFirstChild("ChargeCannon")
		if chargeCannon and chargeCannon.Value == false then chargeCannon.Value = true end 
	end 
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myHumanoid  then 
		cannonWalkAnim = myHumanoid:LoadAnimation(Tool.WalkAnim)
		if cannonWalkAnim then cannonWalkAnim:Play() end 
	end 
	if mouse then 
		mouse.KeyDown:connect(charge)
	end 
end 

function onUnequipped()
	if cannonWalkAnim then cannonWalkAnim:Stop() end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped) 




