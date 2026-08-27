local Tool = script.Parent
local Wand = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

local castSound

local wandAnim

function onActivated()
	if Tool.Enabled == false then 
		return 
	end
	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	if myTorso == nil or myHumanoid == nil then 
		return
	end

	Tool.Enabled = false

	wandAnim = myHumanoid:LoadAnimation(Tool.WandAnim)
	if wandAnim then wandAnim:Play() end

	castSound = Wand:FindFirstChild("CastSound")
	if castSound then castSound:Play() end

	local activateSpell = Tool:FindFirstChild("ActivateSpell")
	if activateSpell and activateSpell.Value == 0 then 
		activateSpell.Value = 1
	end

	wait(3.0)
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent 
end

function onUnequipped()
	if wandAnim then wandAnim:Stop() end
	if castSound then castSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
