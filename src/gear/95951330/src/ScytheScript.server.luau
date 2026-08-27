-----------------
--| Constants |--
-----------------

local HIT_DAMAGE = 20
local LIMB_DEBRIS_TIME = 4 --NOTE: Should be less than respawn time

local SLASH_COOLDOWN = 0.7

local IGNORE_LIST = {torso = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local MyModel = nil
local MyPlayer = nil

-------------------------
--| Utility Functions |--
-------------------------

-- Returns a character ancestor and its Humanoid, or nil
local function FindCharacterAncestor(subject)
	if subject and subject ~= workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

-----------------------
--| Other Functions |--
-----------------------

local function OnTouched(otherPart)
	if otherPart and not IGNORE_LIST[string.lower(otherPart.Name)] then
		local character, humanoid = FindCharacterAncestor(otherPart)
		if character and humanoid and character ~= MyModel and not IsTeamMate(MyPlayer,PlayersService:GetPlayerFromCharacter(character)) then
			local FF = humanoid.Parent:FindFirstChildOfClass("ForceField")
			if FF then return end
			ApplyTags(humanoid)
			humanoid:TakeDamage(HIT_DAMAGE)
			if humanoid.Health > 0 and humanoid.RootPart then -- Cut limbs
				for _, child in pairs(character:GetDescendants()) do
					if child:IsA('JointInstance') and (child.Part0 == otherPart or child.Part1 == otherPart) then
						child:Destroy()
						DebrisService:AddItem(otherPart, LIMB_DEBRIS_TIME)
						otherPart.Parent = workspace
						otherPart.CanCollide = true
					end
				end
			end
		end
	end
end

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
end

local function OnActivated()
	if Tool.Enabled and MyModel:FindFirstChildOfClass('Humanoid') and MyModel.Humanoid.Health > 0 then
		Tool.Enabled = false --NOTE: Starts the animation

		local connection = ToolHandle.Touched:Connect(OnTouched)
		delay(0.4, function() --NOTE: Hardcoded length of animation :[
			if connection then
				connection:Disconnect()
			end
		end)

		local slashSound = ToolHandle:FindFirstChild('SwordSlash')
		if slashSound then
			slashSound:Play()
		end

		wait(SLASH_COOLDOWN)

		Tool.Enabled = true
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:Connect(OnEquipped)
Tool.Activated:Connect(OnActivated)
