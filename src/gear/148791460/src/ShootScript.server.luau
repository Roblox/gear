--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
FireSound = Handle:WaitForChild("Fire")
ProjectileScript = Tool:WaitForChild("ProjectileScript")
OutfitScript = Tool:WaitForChild("OutfitScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Velocity = 50

local Pellet = Instance.new("Part")
Pellet.FormFactor = Enum.FormFactor.Custom
Pellet.Size = Vector3.new(0.5, 3, 0.5)
Pellet.BrickColor = BrickColor.new("Bright orange")
Pellet.Material = Enum.Material.SmoothPlastic
Pellet.TopSurface = Enum.SurfaceType.Smooth
Pellet.BottomSurface = Enum.SurfaceType.Smooth
Pellet.Locked = true
Pellet.Name = "Pellet"
local Mesh = Instance.new("SpecialMesh")
Mesh.Parent = Pellet

local LooperSound = Instance.new("Sound")
LooperSound.Name = "RaySound"
LooperSound.SoundId = "http://www.roblox.com/asset/?id=28912822"
LooperSound.Looped = true
LooperSound.Parent = Pellet

ProjectileScript:Clone().Parent = Pellet
OutfitScript:Clone().Parent = Pellet

function Fire(v, ShootDirect)

	FireSound:Play()
	
	local Launch = Handle.Position + 5 * v
	
	local Missile = Pellet:clone()
	Missile.CFrame = CFrame.new(Launch, ShootDirect) * CFrame.Angles((math.pi / 2),0,0)
	Missile.Position = Launch
	Missile.Velocity = v * 200
	
	local creator = Instance.new("ObjectValue")
	creator.Name = "creator"
	creator.Value = Player
	creator.Parent = Missile

	local Force = Instance.new("BodyForce")
	Force.force = Vector3.new(0, (Pellet:GetMass() * 9.81 * 20), 0)
	Force.Parent = Missile

	Missile.ProjectileScript.Disabled = false
	Missile.RaySound:Play()

	Debris:AddItem(Missile, 5)
	Missile.Parent = game:GetService("Workspace")

end

function onEquipped()
	FireSound:Stop()
end

function onUnequipped()
	FireSound:Stop()
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


function OnActivated()
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not Character or not Humanoid or not Player or not Tool.Enabled then
		return
	end
	
	local TargetPos = Humanoid.TargetPoint
	local LookAt = (TargetPos - Handle.Position).unit
	
	Fire(LookAt, TargetPos)
	
	Tool.Enabled = false
	
	wait(0.6)

	Tool.Enabled = true

end

Tool.Activated:connect(OnActivated)
