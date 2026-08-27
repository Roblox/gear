--Made by Luckymaxer
--Rescripted by StarWars
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool.Handle

local Player = nil
local Character = nil
local Humanoid = nil

local Event = Instance.new("RemoteEvent")
Event.Name = "Event"
Event.Parent = Tool

local PROJECTILE_SPEED = 100
local PROJECTILE_TIME = 1
local PROJECTILE_DAMAGE = 5

local NOOZLE_OFFSET = Vector3.new(0, 0.4, -1.1)
local MOUSE_DOWN = 0
local MOUSE_UP = 1

local Firing = false

local BaseShot = Instance.new("Part")
BaseShot.Name = "Effect"
BaseShot.Size = Vector3.new(0.2, 0.2, 3)
BaseShot.CanCollide = false
BaseShot.BrickColor = BrickColor.new("Toothpaste")
local Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
Mesh.MeshId = "rbxassetid://" .. 145815862
Mesh.TextureId = "rbxassetid://" .. 145815901
Mesh.Parent = BaseShot

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

-- Removes any old creator tags and applies new ones to the specified target
function ApplyTags(target)
	while target:FindFirstChild("creator") do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = Player
	creatorTag.Name = "creator"

	local iconTag = Instance.new("StringValue")
	iconTag.Value = Tool.TextureId
	iconTag.Name = "icon"

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	Debris:AddItem(creatorTag, 4)
end


function OnTouched(projectile, hit)	
	local BodyVelocity = projectile:FindFirstChild("BodyVelocity")
	if BodyVelocity then
		BodyVelocity:Destroy()
	end	
	
	Debris:AddItem(projectile, 10)
	
	local HitParent, HitHumanoid = FindCharacterAncestor(hit)
	
	local Weld = Instance.new("Weld")
	Weld.Part1 = projectile	
	if HitHumanoid then
		Weld.Part0 = HitParent:FindFirstChild("HumanoidRootPart") or hit
		local StickCFrame = CFrame.new(hit.CFrame.p, projectile.Position) * CFrame.new(0, 0, -1) --* CFrame.Angles((math.pi * 0.5), (math.random() * math.pi * 2), 0)
		Weld.C1 = StickCFrame:inverse() * hit.CFrame
	else
		Weld.C1 = projectile.CFrame:inverse() * hit.CFrame
		Weld.Part0 = hit
	end
	
	Weld.Parent = projectile
	
	if HitParent and HitHumanoid and HitParent ~= Character then
		ApplyTags(HitHumanoid)
		spawn(function()
			local Rate = 10
			for i = 1, 10 do
				HitHumanoid:TakeDamage(PROJECTILE_DAMAGE * 2 / Rate)
				wait(0.1)
			end
		end)
		HitHumanoid:TakeDamage(PROJECTILE_DAMAGE)
	end
end

function Fire()
	if Tool.Enabled and Humanoid and Humanoid.Health > 0 then
		Tool.Enabled = false
		
		local HandleCFrame = Handle.CFrame
		local FiringPoint = HandleCFrame.p + HandleCFrame:vectorToWorldSpace(NOOZLE_OFFSET)
		local ShotCFrame = CFrame.new(FiringPoint, Humanoid.TargetPoint)
		
		local LaserShot = BaseShot:Clone()
		LaserShot.CFrame = ShotCFrame + (ShotCFrame.lookVector * (BaseShot.Size.Z * 0.5))
		
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Velocity = ShotCFrame.lookVector * PROJECTILE_SPEED
		BodyVelocity.Parent = LaserShot
		
		local Debounce = false
		LaserShot.Touched:Connect(function(hit)
			if Debounce then return end
			Debounce = true
			local Parent, HitHumanoid = FindCharacterAncestor(hit)
			
			if hit and hit.Parent and hit.Name ~= "Effect" and Parent ~= Character then
				OnTouched(LaserShot, hit)
			end
			Debounce = false
		end)
		
		LaserShot.Parent = workspace
		Debris:AddItem(LaserShot, PROJECTILE_TIME)
		
		wait(0.25)
		Handle.Mesh.MeshId = "rbxassetid://" .. 145815874
		
		Tool.Enabled = true
	end
end

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function OnUnequipped()
	Player = nil
	Character = nil
	Humanoid = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
Event.OnServerEvent:Connect(function(player, issue)
	if Player ~= player then return end
	
	if issue == MOUSE_DOWN and not Firing then
		Firing = true
		spawn(function()
			while Firing do
				wait()
				Fire()
			end
		end)
	elseif issue == MOUSE_UP then
		Firing = false
	end
end)