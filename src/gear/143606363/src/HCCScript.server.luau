------------------------
--|     Variables    |--
------------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Player = nil
local Character = nil
local ChocolateClone = nil
local HitConnection = nil
Tool.Enabled = true

------------------------
--|     Constants    |--
------------------------
local RELOAD_TIME = 0.5
local SHOT_DAMAGE = 50
local SHOT_SPEED = 150
local NOZZLE_OFFSET = Vector3.new(0, 0.4, -1.1)

------------------------
--|     Services     |--
------------------------
local DebrisService = game:GetService('Debris')
local PlayerService = game:GetService('Players')

------------------------
--|      Sounds      |--
------------------------
local FireSound = Handle:WaitForChild('FireSound')
local HitSounds = {"19326853", "19326880", "19326891"}
local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=" .. HitSounds[math.random(1, #HitSounds)]
HitSound.Parent = Bullet
HitSound.Volume = 1

------------------------
--|      Images      |--
------------------------
local Flakes = { "142929731", "142929867", "142929927", "142929980", "142930028", "142930087", "142930132" }
local Globs = { '142930231', '142930294', '142930324 ' }

------------------------
--| Helper Functions |--
------------------------
-- Returns a character ancestor and its Humanoid, or nil
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = Player
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

local function createGui(player)
	local guiMain = Instance.new('GuiMain') 
	guiMain.Parent = player.PlayerGui
	
	local mainFrame = Instance.new('Frame') 
	mainFrame.Name = 'FaceEffect'
	mainFrame.Position = UDim2.new(0, 0, 0, 0) 
	mainFrame.Size = UDim2.new(1, 0, 1, 0) 
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	mainFrame.Parent = guiMain

	DebrisService:AddItem(guiMain, 5)

	--- big glob
	local glob = Instance.new('ImageLabel')
	local size = (math.random() * 0.2) + 0.5
	glob.Size = UDim2.new(size, 0, size, 0)
	glob.Position = UDim2.new(math.random() - (size * 0.5), 0, math.random() - (size * 0.5), 0)
	glob.SizeConstraint = Enum.SizeConstraint.RelativeXX
	glob.Transparency = 1
	glob.Image = "http://www.roblox.com/asset/?id=" .. Globs[math.random(1, #Globs)]
	glob.Parent = mainFrame

	DebrisService:AddItem(glob, 5 + (math.random() * 2))

	--Flakes
	for i=1, 20 do
		local smGlob = Instance.new('ImageLabel')
		local smSize = (math.random() * 0.05) + 0.05
		smGlob.Size = UDim2.new(smSize, 0, smSize, 0)
		smGlob.Position = UDim2.new(math.random() - (smSize * 0.5), 0, math.random() - (smSize * 0.5), 0)
		smGlob.SizeConstraint = Enum.SizeConstraint.RelativeXX
		smGlob.Transparency = 1
		smGlob.Image = "http://www.roblox.com/asset/?id=" .. Flakes[math.random(1, #Flakes)]
		smGlob.Parent = mainFrame
		DebrisService:AddItem(smGlob, 3 + (math.random() * 6))
	end
end

local function explode(velocity, position)
	local count = 5

	for i=1, count do
		local part = Instance.new('Part')
		part.BrickColor = BrickColor.new('Brown')
		part.FormFactor = Enum.FormFactor.Custom
		part.Size = Vector3.new(0.4, 0.4, 0.4)
		part.Material = Enum.Material.CorrodedMetal
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		
		part.Velocity = velocity * ((math.random() * 2))
		part.RotVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		part.Position = position + (velocity * math.random() * 0.05) + Vector3.new(0, math.random() * 3, 0)
		part.Parent = Workspace

		DebrisService:AddItem(part, 2)
	end
end

local function onBulletHit(bullet, hit, velocity)
	Spawn(function()
		error(hit.Name)
	end)
	HitSound:Play()

	if hit.Parent then
		local hitCharacter, hitHumanoid = FindCharacterAncestor(hit)
		if hitCharacter == Character then return end
		if hitHumanoid and hitHumanoid.Health > 0 then
			local hitPlayer = PlayerService:GetPlayerFromCharacter(hitCharacter)
			if hitPlayer then
				ApplyTags(hitHumanoid)
				hitHumanoid:TakeDamage(SHOT_DAMAGE)
				createGui(hitPlayer)
			end
		end
	end
	
	local pos = bullet.Position
	bullet:Destroy()
	explode(velocity, pos)
end

local function getChocolate()
	local part = Instance.new('Part')
	part.CanCollide = false
	part.FormFactor = Enum.FormFactor.Custom
	part.Size = Vector3.new(0.4, 0.4, 1.2)
	part.BrickColor = BrickColor.new('Brown')
	part.Material = Enum.Material.CorrodedMetal
	part.TopSurface = 0
	part.BottomSurface = 0	
	
	return part
end

ChocolateClone = getChocolate()

local function shootChocolate(position, target)
	local newChocolate = ChocolateClone:Clone()
	local handleCFrame = Handle.CFrame
	local firingPoint = handleCFrame.p + handleCFrame:vectorToWorldSpace(NOZZLE_OFFSET)
	newChocolate.CFrame = CFrame.new(firingPoint, target)
	
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = (target - position).unit * SHOT_SPEED
	bodyVelocity.Parent = newChocolate
	
	newChocolate.Touched:connect(function (hit)
		onBulletHit(newChocolate, hit, bodyVelocity.velocity)
	end)
	
	DebrisService:AddItem(newChocolate, 2)
	newChocolate.Parent = Tool
end

------------------------
--|       Events     |--
------------------------
local function onActivated()
	if not Tool.Enabled then return end
	
	Tool.Enabled = false
	
	if Tool.Parent then
		local character = Tool.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		local torso = character:FindFirstChild('Torso')
		if humanoid and humanoid.Health > 0 and torso then
			shootChocolate(Handle.Position, humanoid.TargetPoint)
			FireSound:Play()
			wait(RELOAD_TIME)
		end
	end
	
	Tool.Enabled = true
end

local function onEquipped()
	Character = Tool.Parent
	Player = PlayerService:GetPlayerFromCharacter(Character)
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
