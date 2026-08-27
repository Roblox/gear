--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

EatScript = script:WaitForChild("EatScript")
SpicyScript = script:WaitForChild("SpicyScript")

Damage = 25
ReloadTime = 2

Projectile = Instance.new("Part")
Projectile.Name = "Projectile"
Projectile.BrickColor = BrickColor.new("Pastel Blue")
Projectile.Material = Enum.Material.Plastic
Projectile.Shape = Enum.PartType.Block
Projectile.TopSurface = Enum.SurfaceType.Smooth
Projectile.BottomSurface = Enum.SurfaceType.Smooth
Projectile.FormFactor = Enum.FormFactor.Custom
Projectile.Size = Vector3.new(0.4, 0.5, 1.125)
Projectile.Anchored = false
Projectile.Locked = true
Projectile.CanCollide = true
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Head
Mesh.MeshId  = "http://www.roblox.com/asset?id=169495579"
Mesh.TextureId = "http://www.roblox.com/asset?id=169495589"
Mesh.Scale = Vector3.new(1, 1, 1)
Mesh.Parent = Projectile

LocalControls = (Tool:FindFirstChild("LocalControls") or Instance.new("RemoteFunction"))
LocalControls.Name = "LocalControls"
LocalControls.Parent = Tool

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

function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health == 0 then
		return
	end
	local TargetPoint = nil
	pcall(function()
		TargetPoint = LocalControls:InvokeClient(Player)
	end)
	if not TargetPoint then
		return
	end
	Tool.Enabled = false
	local StartingPoint = PositionProjectile(Handle, 0, -0.4, -0.5)
	local Origin = (StartingPoint + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (Projectile.Size.Y / 2)))
	local Direction = TargetPoint
	local ProjectileClone = Projectile:Clone()
	local Mass = (ProjectileClone:GetMass() * workspace.Gravity)
	local BodyForce = Instance.new("BodyForce")
	BodyForce.force = Vector3.new(0, Mass, 0)
	BodyForce.Parent = ProjectileClone
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(9e+999, 9e+999, 9e+999)
	BodyGyro.Parent = ProjectileClone
	ProjectileClone.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Hit == Handle then
			return
		end
		if Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool") then
			Hit = Hit.Parent
		end
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and not humanoid:FindFirstChild(EatScript.Name) then
			local RightArm = Hit.Parent:FindFirstChild("Right Arm") or Hit.Parent:FindFirstChild("RightHand")
			if RightArm then
				local FoodPart = Projectile:Clone()
				RightGrip = Instance.new("Weld")
				RightGrip.Part0 = RightArm
				RightGrip.Part1 = FoodPart
				local Offset = RightArm.Name == "RightHand" and -0.2 or -1
				RightGrip.C0 = CFrame.new(0, Offset, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
				RightGrip.C1 =  CFrame.new(0.125, -0.2, -0.25) * CFrame.Angles((math.pi / 2), 0, 0)
				RightGrip.Parent = FoodPart
				local EatScriptClone = EatScript:Clone()
				local Food = Instance.new("ObjectValue")
				Food.Name = "Food"
				Food.Value = FoodPart
				Food.Parent = EatScriptClone
				EatScriptClone.Disabled = false
				Debris:AddItem(EatScriptClone, 7)
				Debris:AddItem(FoodPart, 5)
				EatScriptClone.Parent = humanoid
				FoodPart.Parent = Hit.Parent
				Delay(1.5, function()
					if FoodPart and FoodPart.Parent then
						FoodPart:Destroy()
					end
					if humanoid and humanoid.Parent and humanoid.Health > 0 then
						local SpicyChance = math.random(1, 10)
						if SpicyChance == 1 then
							local SpicyScriptClone = SpicyScript:Clone()
							SpicyScriptClone.Name = EatScript.Name
							SpicyScriptClone.Disabled = false
							Debris:AddItem(SpicyScriptClone, 7)
							SpicyScriptClone.Parent = humanoid
						else
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(Damage)
							if humanoid.Health == 0 then
								local Explosion = Instance.new("Explosion")
								Explosion.ExplosionType = Enum.ExplosionType.NoCraters
								Explosion.BlastRadius = 15
								Explosion.BlastPressure = 0
								Explosion.Position = humanoid.Parent:GetModelCFrame().p
								Explosion.Parent = game:GetService("Workspace")
							end
						end
					end
				end)
			else
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			end
		end
		if ProjectileClone and ProjectileClone.Parent then
			ProjectileClone:Destroy()
		end
	end)
	Direction = CFrame.new(Origin.p, Direction)
	BodyGyro.cframe = Direction * CFrame.Angles(0, (math.pi / 2), 0)
	Debris:AddItem(ProjectileClone, 5)
	Debris:AddItem(BodyForce, 2)
	ProjectileClone.Parent = game:GetService("Workspace")
	ProjectileClone.CFrame = Origin
	ProjectileClone.CFrame = Direction * CFrame.Angles(0, (math.pi / 2), 0)
	ProjectileClone.Velocity = Direction.lookVector * 125
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)