local Tool = script.Parent
local Axe = Tool.Handle

local ThrowAnim

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Tool
UnsheathSound.Volume = 0.5

local ProjectileScript

local myCharacter
local myHumanoid

function onActivated()
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then return end

	if not Tool.Enabled then return end
	
	Tool.Enabled = false

	ThrowAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild("AxeThrow"))
	if ThrowAnim then ThrowAnim:Play() end

	-- Standard projectile weapon approach: make current handle invisible, create
	--   a cloned one, and send it flying in a separate, serverside script.
	wait(0.65)
	Axe.Transparency = 1.0
	ProjectileScript = Tool:FindFirstChild("PirateAxe Projectile Script")
	if ProjectileScript then
		ProjectileScript = ProjectileScript:Clone()
		ProjectileScript.Parent = Tool
		ProjectileScript.Disabled = false
	end
	wait(1)
	Axe.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	if UnsheathSound then UnsheathSound:Play() end
end

function onUnequipped()
	if ThrowAnim then ThrowAnim:Stop() end
	if UnsheathSound then UnsheathSound:Stop() end

	Axe.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

-- Changing Tool.Enabled to deal with the possibility of the character's backspacing the tool
--   while it's disabled.
if not Tool.Enabled then
	wait(1)
	Tool.Enabled = true
end
