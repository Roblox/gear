--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

TankModel = InsertService:LoadAsset(172079556)
Tank = TankModel:GetChildren()[1]:Clone()
if TankModel and TankModel.Parent then
	TankModel:Destroy()
end

Handle.Transparency = 0

ClientControls = (Tool:FindFirstChild("ClientControls") or Instance.new("RemoteFunction"))
ClientControls.Name = "ClientControls"
ClientControls.Parent = Tool

ServerControls = (Tool:FindFirstChild("ServerControls") or Instance.new("RemoteFunction"))
ServerControls.Name = "ServerControls"
ServerControls.Parent = Tool

Damage = 25
ReloadTime = 1.5

Controls = {
	Forward = {Speed = 25, Value = false},
	Backward = {Speed = 12.5, Value = false},
}

Gravity = 196.20

Ammo = Instance.new("Part")
Ammo.Name = "Ammo"
Ammo.Material = Enum.Material.Plastic
Ammo.Shape = Enum.PartType.Block
Ammo.TopSurface = Enum.SurfaceType.Smooth
Ammo.BottomSurface = Enum.SurfaceType.Smooth
Ammo.FormFactor = Enum.FormFactor.Custom
Ammo.Size = Vector3.new(0.75, 0.75, 1)
Ammo.CanCollide = true
Ammo.Locked = true
AmmoMesh = Instance.new("SpecialMesh")
AmmoMesh.MeshType = Enum.MeshType.FileMesh
AmmoMesh.MeshId = "http://www.roblox.com/asset/?id=28565445"
AmmoMesh.TextureId = ""
AmmoMesh.Scale = Vector3.new(2, 2, 2)
AmmoMesh.Parent = Ammo

Equipped = false

ClientControls.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player then
		return
	end
	if Mode == "Click" and PlayerTank and PlayerTank.Parent then
		if Value then
			local TargetPoint
			pcall(function()
				TargetPoint = ServerControls:InvokeClient(Player)
			end)
			if not TargetPoint or not Tool.Enabled then
				return
			end
			Tool.Enabled = false
			local Projectile = Ammo:Clone()
			local Randomize = math.random(1, 2)
			local Color = ((Randomize == 1 and BrickColor.Random()) or (Randomize == 2 and BrickColor.new(math.random(), math.random(), math.random())))
			Projectile.BrickColor = Color
			local Mass = (Projectile:GetMass() * Gravity)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.velocity = Vector3.new(0, 0, 0)
			BodyVelocity.Parent = Projectile
			Debris:AddItem(Projectile, 5)
			Projectile.Parent = game:GetService("Workspace")
			Projectile.CFrame = PositionProjectile(TankTorso, 0, -1, (TankTorso.Size.Z / 2) + (Ammo.Size.Z / 2)) * CFrame.Angles(-(math.pi / 2), 0, 0)
			BodyVelocity.velocity = CFrame.new(TankTorso.Position, TargetPoint).lookVector * 100
			Projectile.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local HitParent = Hit.Parent
				if HitParent:IsA("Hat") or HitParent:IsA("Tool") then
					HitParent = HitParent.Parent
				end
				if HitParent == PlayerTank then
					return
				end
				local humanoid = HitParent:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 and HitParent ~= Character then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
				end
				if Projectile and Projectile.Parent then
					Projectile:Destroy()
				end
			end)
			wait(ReloadTime)
			Tool.Enabled = true
		end
	elseif Mode == "Key" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "" or Key == "w" then
			Controls.Forward.Value = Down
		elseif Key == "" or Key == "s" then
			Controls.Backward.Value = Down
		end
	end
end)

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

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

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function Equipped()
	Equipped = true
	Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Humanoid.WalkSpeed = 0
	if PlayerTank and PlayerTank.Parent then
		PlayerTank:Destroy()
	end
	PlayerTank = Tank:Clone()
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = PlayerTank
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerTank
	TankHumanoid = PlayerTank:FindFirstChild("Humanoid")
	TankTorso = PlayerTank:FindFirstChild("Torso")
	TankHumanoid.MaxHealth = 200
	TankHumanoid.Health = TankHumanoid.MaxHealth
	TankHumanoid.Died:connect(function()
		if PlayerTank and PlayerTank.Parent then
			PlayerTank:Destroy()
		end
		Humanoid:UnequipTools()
	end)
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(0, math.huge, 0)
	BodyGyro.Parent = TankTorso
	local Mass = (((GetTotalMass(PlayerTank) * Gravity) * 100) / 2)
	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, 0, Mass)
	BodyVelocity.velocity = Vector3.new(0, 0, 0)
	BodyVelocity.Parent = TankTorso
	PlayerTank.Parent = game:GetService("Workspace")
	TankTorso.CFrame = Torso.CFrame + Torso.CFrame.lookVector * ((Torso.Size.Z / 2) + (TankTorso.Size.Z / 2))
	TankTorso.CFrame = TankTorso.CFrame - Vector3.new(0, (PlayerTank:GetModelSize().Y / 2), 0)
	BodyGyro.cframe = TankTorso.CFrame
	pcall(function()
		ServerControls:InvokeClient(Player, "SetCamera", TankHumanoid)
	end)
	while Equipped and PlayerTank and PlayerTank.Parent do
		local TargetPoint
		pcall(function()
			TargetPoint = ServerControls:InvokeClient(Player)
		end)
		if TargetPoint then
			BodyGyro.cframe = CFrame.new(TankTorso.Position, TargetPoint)
			if Controls.Forward.Value then
				BodyVelocity.velocity = TankTorso.CFrame.lookVector * Controls.Forward.Speed
			end
			if Controls.Backward.Value then
				BodyVelocity.velocity = TankTorso.CFrame.lookVector * -Controls.Backward.Speed
			end
			if not Controls.Forward.Value and not Controls.Backward.Value then
				BodyVelocity.velocity = Vector3.new(0, 0, 0)
			end
		end
		wait()
	end
	pcall(function()
		ServerControls:InvokeClient(Player, "SetCamera", Humanoid)
	end)
end

function Unequipped()
	Equipped = false
	Handle.Transparency = 0
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
		pcall(function()
			ServerControls:InvokeClient(Player, "SetCamera", Humanoid)
		end)
	end
	if PlayerTank and PlayerTank.Parent then
		PlayerTank:Destroy()
	end
	for i, v in pairs(Controls) do
		Controls[i].Value = false
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)