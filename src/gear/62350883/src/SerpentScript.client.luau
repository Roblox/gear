local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local storm

local slashAnim
local swordSound

Tool.Enabled = true

local firePart = Sword:FindFirstChild("FirePart")
local storeWeld = Sword:FindFirstChild("FireWeld")
while storeWeld == nil or firePart == nil do 
	firePart = Sword:FindFirstChild("FirePart")
	storeWeld = Sword:FindFirstChild("FireWeld")
	wait()
end

local anims = {Tool:FindFirstChild("RightSlash"), Tool:FindFirstChild("Slash"), Tool:FindFirstChild("ToFace"), Tool:FindFirstChild("RightSlash"), Tool:FindFirstChild("RightSlash")}

function choiceIsYours(key)
	if vCharacter == nil or myHumanoid == nil then return end 
	key = key:lower()
	if key == "q" then 
		storm = Tool:FindFirstChild("Storm")
		if storm and storm.Value == 0 then 
			storm.Value = 1
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
	local anims = {Tool:FindFirstChild("RightSlash"), Tool:FindFirstChild("Slash"), Tool:FindFirstChild("ToFace"), Tool:FindFirstChild("RightSlash"), Tool:FindFirstChild("RightSlash")}
	if myHumanoid == nil or myTorso == nil then
		return 
	end
	Tool.Enabled = false 
	tick()	
	local slashAnim = myHumanoid:LoadAnimation(anims[math.random(1, #anims)])
	if slashAnim then slashAnim:Play() end
	swordSound = Sword:FindFirstChild("SwordSound")
	wait(0.1)
	if swordSound then swordSound:Play() end
	wait(1.0)
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if storeWeld then 
		local reWeld = storeWeld:Clone()
		reWeld.Parent = Sword
	end
	if mouse then 
		mouse.KeyDown:connect(choiceIsYours)
	end
end

function onUnequipped()
	-- do nothing 	
	if slashAnim then slashAnim:Stop() end
	if swordSound then swordSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)