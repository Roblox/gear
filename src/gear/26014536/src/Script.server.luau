--Made by Stickmasterluke
--Rescripted by StarWars

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool.Handle
local FireSound = Handle:FindFirstChild("Fire")

local Animations = Tool.Animations
local R6Folder = Animations.R6
local R15Folder = Animations.R15

local FIRE_RATE = 0.4
local VELOCITY = 200

local WeaponEvent = Tool:FindFirstChild("WeaponEvent") or Instance.new("RemoteEvent")
WeaponEvent.Name = "WeaponEvent"

local Player = nil
local Character = nil
local Head = nil
local Humanoid = nil

local BaseBullet = Instance.new("Part")
BaseBullet.Name = "Paintball"
BaseBullet.Size = Vector3.new(1, 1, 1) * 0.5
BaseBullet.BrickColor = BrickColor.new("Really red")
BaseBullet.Material = Enum.Material.Plastic
BaseBullet.Locked = true
BaseBullet.CanCollide = false
BaseBullet.TopSurface = Enum.SurfaceType.Smooth
BaseBullet.BottomSurface = Enum.SurfaceType.Smooth

local BaseMesh = Instance.new("SpecialMesh")
BaseMesh.MeshType = Enum.MeshType.Sphere
BaseMesh.Scale = Vector3.new(1, 1, 1)
BaseMesh.Parent = BaseBullet

Tool.ProjectileScript:Clone().Parent = BaseBullet

function Fire(player, firePos)
	if player ~= Player then return end
	if not Tool.Enabled then return end
	if not Player then return end
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end

	Tool.Enabled = false

	Tool.GripPos = Vector3.new(0, 0, 0.8)
	if FireSound then
		FireSound:Play()
	end

	local NewBullet = BaseBullet:Clone()
	local Direction = (firePos - Head.Position).unit
	NewBullet.CFrame = CFrame.new(Head.Position, Head.Position + Direction)
	NewBullet.Velocity = Direction * VELOCITY
	NewBullet.ProjectileScript.Disabled = false

	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, NewBullet:GetMass() * workspace.Gravity * 0.8, 0)
	BodyForce.Parent = NewBullet

	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = Player
	CreatorTag.Parent = NewBullet

	Debris:AddItem(NewBullet, 10)
	NewBullet.Parent = workspace

	wait(FIRE_RATE * 0.5)
	Tool.GripPos = Vector3.new(0, 0, 1)
	wait(FIRE_RATE * 0.5)

	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Head = Character:FindFirstChild("Head")
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function OnUnequipped()
	Character = nil
	Player = nil
	Head = nil
	Humanoid = nil
	if FireSound and FireSound.IsPlaying then
		FireSound:Stop()
	end
end

WeaponEvent.OnServerEvent:Connect(Fire)
--Tool.Activated:Connect(OnActivate)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)