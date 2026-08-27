-----------------
--| Constants |--
-----------------

local DAMAGE = 55

local SWORD_COOLDOWN = 0.5

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local SwordSlashAnimation = WaitForChild(script, 'LeftySlash')
local SlashSound = WaitForChild(script, 'Slash')
local CrunchSound = WaitForChild(script, 'Crunch')
local HitSparkles = WaitForChild(script, 'HitSparkles')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local MyModel = nil
local MyPlayer = nil
local MyHumanoid = nil

local Sword = nil
local Shield = nil

local CreatorTag = nil

local HitTable = {}

local SwordSlashTrack = nil

-----------------
--| Functions |--
-----------------

local function MakeWeapons(character)
	local leftArm = character:FindFirstChild('Left Arm')
	if leftArm then
		Sword = Instance.new('Part')
		Sword.Name = "Sword"
		Sword.FormFactor = Enum.FormFactor.Custom
		Sword.Size = Vector3.new(0.5, 3.75, 0.5)
		Sword.CanCollide = false
		local mesh = Instance.new('SpecialMesh')
		mesh.MeshId = 'http://www.roblox.com/asset/?id=103730924'
		mesh.TextureId = 'http://www.roblox.com/asset/?id=103731151'
		mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
		mesh.Parent = Sword
		local weld = Instance.new('Weld')
		weld.Name = "SwordGrip"
		weld.Part0 = leftArm
		weld.Part1 = Sword
		weld.C1 = CFrame.new(0, -1.5, 1, 1, 0, 0, 0, 0, -1, 0, 1, 0)
		weld.Parent = Sword
		Sword.Parent = character
	end

	local rightArm = character:FindFirstChild('Right Arm')
	if rightArm then
		Shield = Instance.new('Part')
		Shield.Name = "Shield"
		Shield.FormFactor = Enum.FormFactor.Custom
		Shield.Size = Vector3.new(1, 4, 0.2)
		Shield.CanCollide = false
		local mesh = Instance.new('SpecialMesh')
		mesh.MeshId = 'http://www.roblox.com/asset/?id=103731465'
		mesh.TextureId = 'http://www.roblox.com/asset/?id=103731509'
		mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
		mesh.Parent = Shield
		local weld = Instance.new('Weld')
		weld.Name = "ShieldGrip"
		weld.Part0 = rightArm
		weld.Part1 = Shield
		weld.C1 = CFrame.new(0, -0.8, 1, 1, 0, 0, 0, 0, -1, 0, 1, 0)
		weld.Parent = Shield
		Shield.Parent = character
	end
end

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

local function ApplyTag(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	CreatorTag:Clone().Parent = target
end

local function OnHit(otherPart)
	if otherPart then
		local character, humanoid = FindCharacterAncestor(otherPart.Parent)
		if character and character ~= MyModel and humanoid.Health > 0 and not HitTable[character] then
			local player = PlayersService:GetPlayerFromCharacter(character)
			if player and not MyPlayer.Neutral and (not player.Neutral and player.TeamColor == MyPlayer.TeamColor) then
				return
			end
			HitTable[character] = 1

			-- Hit effects
			CrunchSound:Play()

			local sparkles = HitSparkles:Clone()
			DebrisService:AddItem(sparkles, 0.39)
			sparkles.Parent = otherPart

			-- Tag and damage the victim
			local hitBindable = humanoid:FindFirstChild('Hit')
			if hitBindable then
				hitBindable:Invoke(DAMAGE, CreatorTag)
			else
				print("Could not find BindableFunction 'Hit'")
				ApplyTag(humanoid)
				humanoid:TakeDamage(DAMAGE)
			end
		end
	end
end

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	MyHumanoid = WaitForChild(MyModel, 'Humanoid')
	SwordSlashTrack = MyHumanoid:LoadAnimation(SwordSlashAnimation)

	Spawn(function()
		MakeWeapons(MyModel)

		SlashSound:Clone().Parent = Sword
		CrunchSound:Clone().Parent = Sword
	end)
end

local function OnActivated()
	if MyHumanoid.Health > 0 and Tool.Enabled and Sword then
		Tool.Enabled = false

		SwordSlashTrack:Play(0.1, 1, 4.5)
		Spawn(function()
			wait(0.2)
			SlashSound:Play()
		end)

		local connection = Sword.Touched:connect(OnHit)
		local mesh = Sword:FindFirstChild('Mesh')
		if mesh then
			mesh.VertexColor = Vector3.new(1, 0, 0)
		end

		Spawn(function()
			wait(0.44) -- Wait for animation to finish
			connection:disconnect()
			if mesh then
				mesh.VertexColor = Vector3.new(1, 1, 1)
			end
		end)

		wait(SWORD_COOLDOWN)

		HitTable = {}

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	if Sword then
		Sword:Destroy()
	end
	if Shield then
		Shield:Destroy()
	end
end

--------------------
--| Script Logic |--
--------------------

-- Hide the fake sword
ToolHandle.Transparency = 1
local handleMesh = ToolHandle:FindFirstChild('Mesh')
if handleMesh then
	handleMesh:Destroy()
end

CreatorTag = Instance.new('ObjectValue')
CreatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
CreatorTag.Value = MyPlayer

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)

Tool.Enabled = true
