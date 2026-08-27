local Tool = script.Parent
local Blade = Tool.Blade
local Anims = {}
local Player = game.Players.LocalPlayer

local SLASH_ANIM_TIME = 1.2

local Debris = game:GetService('Debris')

local InjureConnection
local SlashSound

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

local function Injure(part)
	local character = part.Parent
	if character and character ~= Tool.Parent then
		local isHat = false
		local humanoid = character:FindFirstChild('Humanoid')
		if not humanoid and character.Parent then
			humanoid = character.Parent:FindFirstChild('Humanoid')
			if humanoid then 
				isHat = true
				part:BreakJoints()
			end
		end
		if humanoid and not isHat and not part:FindFirstChild('MadMaxAxeDebounce') then
			local tag = Instance.new('ObjectValue')
			tag.Name = 'creator'
			tag.Value = Player
			Debris:AddItem(tag, 2)
			tag.Parent = humanoid
			local debounce = Instance.new('BoolValue')
			debounce.Name = 'MadMaxAxeDebounce'
			Debris:AddItem(debounce, 1)
			debounce.Parent = part
			if math.random(5) == 1 and part.Name ~= 'Head' and part.Name ~= 'Torso' then
				part:BreakJoints()
				humanoid:TakeDamage(15)
			end
			humanoid:TakeDamage(10)
		end
	end	
end

function OnActivated()
	if Tool.Enabled then
		local character = Tool.Parent
		Tool.Enabled = false
		InjureConnection = Blade.Touched:connect(Injure)
		Play('SlashAnim')
		SlashSound = Tool:FindFirstChild('SlashSound')
		if SlashSound then SlashSound:Play() end
		wait(SLASH_ANIM_TIME/2)
		if SlashSound and Tool.Parent == character then SlashSound:Play() end
		wait(SLASH_ANIM_TIME/2)
		if InjureConnection then InjureConnection:disconnect() end
		Tool.Enabled = true
	end
end

function OnEquipped()
	Tool.Enabled = true
	Play('EquipAnim')
end

function OnUnequipped()
	if InjureConnection then InjureConnection:disconnect() end
	Stop('EquipAnim')
	Stop('SlashAnim')
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
