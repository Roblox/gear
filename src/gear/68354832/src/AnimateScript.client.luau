local Tool = script.Parent 
local Staff = Tool.Handle

local vCharacter 
local myHumanoid 
local myTorso 

local fogImageId = 68343786 

local snowAssets = {68343851, 68343876, 68343890}

local sg
local fogFrame
local fogImage 

function choiceIsYours(key)
	if vCharacter == nil or myHumanoid == nil then return end 
	key = key:lower()
	if key == "q" then 
		print("Q")
		storm = Tool:FindFirstChild("Storm")
		if storm and storm.Value == false then 
			print("Changed")
			storm.Value = true
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 	
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")	
	if mouse then 
		mouse.KeyDown:connect(choiceIsYours)
	end
end

Tool.Equipped:connect(onEquipped)

