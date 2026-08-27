--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equip = Tool:WaitForChild("Equip")
FireSound = Handle:WaitForChild("Fire")

FireFunction = Tool:WaitForChild("FireFunction")

Equipped = false
MouseDown = false

ReloadTime = 5

Projectile = Instance.new("Part")
Projectile.Name = "Projectile"
Projectile.BrickColor = BrickColor.new("Pastel Blue")
Projectile.Material = Enum.Material.Plastic
Projectile.Shape = Enum.PartType.Block
Projectile.TopSurface = Enum.SurfaceType.Smooth
Projectile.BottomSurface = Enum.SurfaceType.Smooth
Projectile.FormFactor = Enum.FormFactor.Custom
Projectile.Size = Vector3.new(0.2, 2, 0.2)
Projectile.Anchored = false
Projectile.Locked = true
Projectile.CanCollide = false
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Head
Mesh.Scale = Vector3.new(0.5, 1, 0.5)
Mesh.Parent = Projectile
PointLight = Instance.new("PointLight")
PointLight.Brightness = 50
PointLight.Color = BrickColor.new("Really blue").Color
PointLight.Range = 8
PointLight.Shadows = false
PointLight.Enabled = true
PointLight.Parent = Projectile

function PositionProjectile(handle, x, y, z)
	local HandleClone = handle:Clone()
	local HandleCloneY = HandleClone:Clone()
	HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * y
	local HandleCloneZ = HandleCloneY:Clone()
	HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * z
	local HandleCloneX = HandleCloneZ:Clone()
	HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * x
	return HandleCloneX.CFrame
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	EquipAnim = Humanoid:LoadAnimation(Equip)
	if EquipAnim then
		EquipAnim:Play()
	end
	Mouse.Button1Down:connect(function()
		if Humanoid.Health > 0 and not MouseDown and Tool.Enabled then
			MouseDown = true
			Spawn(function()
				FireSound:Play()
				local FiringTime = tick()
				while MouseDown and Equipped and Humanoid.Health > 0 and (tick() - FiringTime) < 30 do
					local FiringPositions = {
						PositionProjectile(Handle, 0, 0.125, 0),
						PositionProjectile(Handle, 0, -0.2, 0),
						PositionProjectile(Handle, 0.14, -0.125, 0),
						PositionProjectile(Handle, -0.14, -0.125, 0),
						PositionProjectile(Handle, 0.14, 0.04, 0),
						PositionProjectile(Handle, -0.14, 0.04, 0)
					}
					for i = 1, math.random(1, 6) do
						if MouseDown and Equipped then
							local StartingPoint = FiringPositions[math.random(1, #FiringPositions)]
							table.remove(FiringPositions, i)
							FireFunction:InvokeServer((StartingPoint + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (Projectile.Size.Y / 2))), Humanoid.TargetPoint)
						end
					end
					local TimeFiring = (tick() - FiringTime)
					local ExtraWaitTime = ((TimeFiring < 5 and math.abs((5 - TimeFiring) / 5)) or 0)
					wait((0.1 + ExtraWaitTime))
				end
				FireSound:Stop()
				Tool.Enabled = false
				wait(ReloadTime)
				Tool.Enabled = true
			end)
		end
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
	MouseDown = false
	FireSound:Stop()
	if EquipAnim then
		EquipAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)