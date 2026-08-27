local Tool = script.Parent
local Board = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local spin

local slashAnim
local slamSound

Tool.Enabled = true

function choiceIsYours(key)
	if vCharacter == nil or myHumanoid == nil then return end 
	key = key:lower()
	if key == "q" then 
		spin = Tool:FindFirstChild("Spin")
		if spin and spin.Value == 0 then 
			spin.Value = 1
		end
	end
end

function onActivated()	
	if Tool.Enabled == false then 
		return 
	end
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")	
	if myHumanoid == nil or myTorso == nil then
		return 
	end
	Tool.Enabled = false 
	tick()	
	local slashAnim = myHumanoid:LoadAnimation(Tool.RightSlash)
	if slashAnim then slashAnim:Play() end
	slamSound = Board:FindFirstChild("SlamSound")
	wait(0.1)
	if slamSound then slamSound:Play() end
	wait(1.0)
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")	
	if mouse then 
		mouse.KeyDown:connect(choiceIsYours)
	end
end

function onUnequipped()
	-- do nothing 	
	if slashAnim then slashAnim:Stop() end
	if slamSound then slamSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)