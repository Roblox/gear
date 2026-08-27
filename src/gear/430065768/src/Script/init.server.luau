local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local DanceScript = script:WaitForChild("DanceScript")
local ProjectileEffects = script:WaitForChild("ProjectileEffects")
local Particles = script:WaitForChild("Particles")

local BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

local BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Material = Enum.Material.Foil
BaseProjectile.TopSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.BackSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.RightSurface = Enum.SurfaceType.SmoothNoOutlines
BaseProjectile.Size = Vector3.new(0.75, 0.75, 1.5)
BaseProjectile.CanCollide = false

local Animations = {}

local Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

local ReloadTime = 4

local ToolEquipped = false

local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = Remotes:FindFirstChild("ServerControls") or Instance.new("RemoteFunction")
ServerControl.Name = "ServerControls"
ServerControl.Parent = Remotes


local ClientControl = Remotes:FindFirstChild("ClientControls") or Instance.new("RemoteFunction")
ClientControl.Name = "ClientControls"
ClientControl.Parent = Remotes

Handle.Transparency = 0
Tool.Enabled = true

function Fire(TargetPos)
	Sounds.Fire:Play()
	local Gravity = workspace.Gravity
	local Projectile = BaseProjectile:Clone()
	Projectile.Color = Color3.new(math.random(), math.random(), math.random())
	local ProjectileEffectsCopy = ProjectileEffects:Clone()
	ProjectileEffectsCopy.Disabled = false
	ProjectileEffectsCopy.Parent = Projectile
	local DanceScriptCopy = DanceScript:Clone()
	DanceScriptCopy.Disabled = false
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = Projectile

	DanceScriptCopy.Disabled = false
	DanceScriptCopy.Parent = Projectile
	for i, v in pairs(Particles:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			local Particle = v:Clone()
			Particle.Enabled = true
			Particle.Color = ColorSequence.new(Projectile.Color, Projectile.Color)
			Particle.Parent = Projectile
		end
	end
	local SpawnPos = (Handle.CFrame * CFrame.new(0, 0, -((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) + 0.5)))
	local Weight = (Projectile:GetMass() * Gravity)
	local Speed = 75
	local Direction = CFrame.new(SpawnPos.p, TargetPos)
	local Velocity = (Direction.lookVector * Speed)
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Name = "BodyGyro"
	BodyGyro.P = 3000
	BodyGyro.D = 500
	BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.CFrame = Direction
	BodyGyro.Parent = Projectile
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Name = "BodyVelocity"
	BodyVelocity.P = 1250
	BodyVelocity.MaxForce = Vector3.new(Weight, Weight, Weight)
	BodyVelocity.Velocity = Velocity
	BodyVelocity.Parent = Projectile
	
	Projectile.Velocity = Velocity
	Debris:AddItem(Projectile, 4)
	Projectile.CFrame = Direction
	Projectile.Parent = workspace
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("GetMouseData")
	if not MouseData or not MouseData.Position or not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Fire(MouseData.Position)
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)