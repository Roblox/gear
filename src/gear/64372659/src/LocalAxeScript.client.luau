local Tool = script.Parent
local Axe = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true 

local anims = {}
local slashAnim

local fireWeld = Axe:FindFirstChild("FireWeld")
while fireWeld == nil do 
	wait()
	fireWeld = Axe:FindFirstChild("FireWeld")
end

local fire = Axe:FindFirstChild("Fire")

local storeWeld

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
	tick()
	local num = anims[math.random(1, #anims)]
	print(num)
	slashAnim = myHumanoid:LoadAnimation(num)
	if slashAnim then slashAnim:Play() end

	wait(1.4)
	Tool.Enabled = true
end

function onEquipped()
	if fireWeld then
		storeWeld = fireWeld:Clone()
		storeWeld.Parent = Axe
	end
	anims = {Tool:FindFirstChild("RightSlash"), Tool:FindFirstChild("Slash"), Tool:FindFirstChild("SlashAnim"), Tool:FindFirstChild("SlashAnim"), Tool:FindFirstChild("SlashAnim")}
	print(#anims)
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
