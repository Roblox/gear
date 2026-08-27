--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

ControllableTrainModel = InsertService:LoadAsset(157131091)
ControllableTrain = ControllableTrainModel:GetChildren()[1]:Clone()
ControllableTrainModel:Destroy()

CurrentCamera = game:GetService("Workspace").CurrentCamera

TrainRemoval = script:WaitForChild("TrainRemoval")

FireSound = Handle:WaitForChild("Fire")
WhistleSound = Handle:WaitForChild("Whistle")

Train = nil
TrainTorso = nil

Speed = 35
TurnSpeed = 10

Damage = 20

ShrapnelReload = 1
TrainReload = 30

LastWhistle = 0

Forward = false
Backward = false
Left = false
Right = false

TrainSpawned = false
TrainRunning = false

Shrapnel = Instance.new("Part")
Shrapnel.Name = "Shrapnel"
Shrapnel.Shape = Enum.PartType.Block
Shrapnel.FormFactor = Enum.FormFactor.Custom
Shrapnel.Material = Enum.Material.Plastic
Shrapnel.TopSurface = Enum.SurfaceType.Smooth
Shrapnel.BottomSurface = Enum.SurfaceType.Smooth
Shrapnel.Size = Vector3.new(0.25, 0.25, 0.25)
Shrapnel.CanCollide = true
Shrapnel.Locked = true
Shrapnel.Anchored = false
ShrapnelMesh = Instance.new("SpecialMesh")
ShrapnelMesh.MeshType = Enum.MeshType.FileMesh
ShrapnelMesh.MeshId = "http://www.roblox.com/asset?id=156092125"
ShrapnelMesh.TextureId = "http://www.roblox.com/asset?id=156092145"
ShrapnelMesh.Scale = Vector3.new(1, 1, 1)
ShrapnelMesh.Parent = Shrapnel

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

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

function Fire(TargetPoint, StartingPosition)
	
	Tool.Enabled = false
	
	FireSound:Play()
	
	local Projectile = Shrapnel:Clone()
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Parent = Projectile
	
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(4e+5, 4e+5, 4e+5)
	BodyGyro.Parent = Projectile
	
	Projectile.Touched:connect(function(Hit)
		if Hit and Hit.Parent and Hit.Parent ~= Train then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character and humanoid and humanoid.Health > 0 and character ~= Character then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
				Projectile:Destroy()
			end
		end
	end)
	
	Debris:AddItem(Projectile, 2)
	Projectile.Parent = game:GetService("Workspace")
	Projectile.CFrame = StartingPosition
	Projectile.CFrame = CFrame.new(StartingPosition.p, TargetPoint)
	BodyVelocity.velocity = Projectile.CFrame.lookVector * 20
	BodyGyro.cframe = Projectile.CFrame
	
	wait(ShrapnelReload)
	Tool.Enabled = true
	
end

function GetTotalMass(Parent)
	local TotalMass = 0
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			TotalMass = TotalMass + v:GetMass()
		end
		GetTotalMass(v)
	end
	return TotalMass
end

function ResetTrain()
	Forward = false
	Backward = false
	Left = false
	Right = false
	TrainRunning = false
	LastWhistle = 0
	CurrentCamera.CameraSubject = Humanoid
	Torso.Anchored = false
	if Train and Train.Parent then
		Train:Destroy()
	end
	if TrainSpawned then
		TrainSpawned = false
		Tool.Enabled = false
		wait(TrainReload)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled then
		wait(TrainReload)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled then
			Forward = false
			Backward = false
			Left = false
			Right = false
			TrainRunning = false
			if not Train or not Train.Parent then
				TrainSpawned = true
				Handle.Transparency = 1
				WhistleSound:Play()
				Train = ControllableTrain:Clone()
				TrainHumanoid = Train:FindFirstChild("Humanoid")
				TrainTorso = Train:FindFirstChild("Torso")
				TrainSmoke = Train:FindFirstChild("SmokePart"):FindFirstChild("Smoke")
				BodyGyro = Instance.new("BodyGyro")
				BodyGyro.maxTorque = Vector3.new(4e+5, 0, 4e+5)
				BodyGyro.Parent = TrainTorso
				BodyForce = Instance.new("BodyForce")
				BodyForce.Parent = TrainTorso
				BodyAngularVelocity = Instance.new("BodyAngularVelocity")
				BodyAngularVelocity.maxTorque = Vector3.new(0, 4e+5, 0)
				BodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
				BodyAngularVelocity.Parent = TrainTorso
				TrainTorso.Velocity = Vector3.new(0, 0, 0)
				local Creator = Instance.new("ObjectValue")
				Creator.Name = "Creator"
				Creator.Value = Player
				Creator.Parent = Train
				local TrainRemovalScript = TrainRemoval:Clone()
				TrainRemovalScript.Disabled = false
				TrainRemovalScript.Parent = Train
				TrainHumanoid.Died:connect(function()
					ResetTrain()
				end)
				Train.Changed:connect(function(Property)
					if not Train or not Train.Parent then
						ResetTrain()
					end
				end)
				Train.Parent = game:GetService("Workspace")
				Train:MoveTo(Torso.Position + Torso.CFrame.lookVector * ((TrainTorso.Size.Z / 2) + (Torso.Size.Z / 2) + 2))
				TrainTorso.CFrame = CFrame.new(TrainTorso.Position, Torso.Position)
				TrainTorso.CFrame = TrainTorso.CFrame * CFrame.Angles(0, math.pi, 0)
			else
				if CurrentCamera.CameraSubject ~= TrainHumanoid then
					Torso.Anchored = true
					CurrentCamera.CameraSubject = TrainHumanoid
				else
					CurrentCamera.CameraSubject = Humanoid
					Torso.Anchored = false
				end
			end
		end
	end)
	Mouse.Button2Down:connect(function()
		if Tool.Enabled and Train and Train.Parent and CurrentCamera.CameraSubject == TrainHumanoid and Humanoid.Health > 0 then
			Fire(Mouse.Hit.p, (TrainTorso.CFrame + TrainTorso.CFrame.lookVector * ((TrainTorso.Size.Z / 2))))
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Train and Train.Parent and CurrentCamera.CameraSubject == TrainHumanoid then
			if Key == "w" then
				Forward = true
				Backward = false
			elseif Key == "s" then
				Backward = true
				Forward = false
			elseif Key == "a" then
				Left = true
				Right = false
			elseif Key == "d" then
				Right = true
				Left = false
			elseif Key == "x" and Tool.Enabled then
				Train:Destroy()
				local TrainTorsoClone = TrainTorso:Clone()
				local Explosion = Instance.new("Explosion")
				Explosion.BlastPressure = 0
				Explosion.BlastRadius = 5
				Explosion.Position = TrainTorso.Position
				local HumanoidsHit = {}
				Explosion.Hit:connect(function(Hit)
					if Hit and Hit.Parent and Hit.Parent ~= Character then
						local humanoid = Hit.Parent:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 and not CheckTable(HumanoidsHit, humanoid) then
							table.insert(HumanoidsHit, humanoid)
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid.Sit = true
							humanoid:TakeDamage(50)
						end
					end
				end)
				Explosion.Parent = game:GetService("Workspace")
				local SmokePart = Instance.new("Part")
				SmokePart.Name = "SmokePart"
				SmokePart.Shape = Enum.PartType.Block
				SmokePart.FormFactor = Enum.FormFactor.Custom
				SmokePart.Material = Enum.Material.Plastic
				SmokePart.TopSurface = Enum.SurfaceType.Smooth
				SmokePart.BottomSurface = Enum.SurfaceType.Smooth
				SmokePart.Size = Vector3.new(0.2, 0.2, 0.2)
				SmokePart.CanCollide = false
				SmokePart.Locked = true
				SmokePart.Anchored = true
				local Smoke = Instance.new("Smoke")
				Smoke.Color = BrickColor.new("Dark stone grey").Color
				Smoke.Opacity = 1
				Smoke.RiseVelocity = 2.5
				Smoke.Size = 2.5
				Smoke.Parent = SmokePart
				local Hit, EndPosition = RayCast(TrainTorso.Position, Vector3.new(0, -1, 0), TrainTorso.Size.Y, {Train, Character, SmokePart})
				if Hit then
					Debris:AddItem(SmokePart, 10)
					SmokePart.Parent = game:GetService("Workspace")
					SmokePart.CFrame = CFrame.new(EndPosition)
				end
			end
			if Forward or Backward or Left or Right and not TrainRunning then
				Spawn(function()
					TrainRunning = true
					while Forward or Backward or Left or Right do
						wait()
						local ChanceToWhistle = math.random(1, 200)
						if ChanceToWhistle == 5 and (LastWhistle == 0 or ((LastWhistle - tick()) >= 5))then
							WhistleSound:Play()
						end
						if Forward or Backward then
							BodyForce.force = TrainTorso.CFrame.lookVector * (GetTotalMass(Train) * 196.20)
							local Hit, EndPosition = RayCast((TrainTorso.CFrame + TrainTorso.CFrame.lookVector * -((TrainTorso.Size.Z / 2) + 1)).p, Vector3.new(0, -1, 0), TrainTorso.Size.Y, {Train})
							if Hit then
								TrainSmoke.Enabled = true
								if Forward then
									TrainTorso.Velocity = TrainTorso.CFrame.lookVector * Speed
								elseif Backward then
									TrainTorso.Velocity = TrainTorso.CFrame.lookVector * -Speed
								else
									TrainTorso.Velocity = Vector3.new(0, 0, 0)
								end
							else
								TrainSmoke.Enabled = false
								BodyForce.force = Vector3.new(0, 0, 0)
							end
						end
						if Left then
							BodyAngularVelocity.angularvelocity = Vector3.new(0, TurnSpeed, 0)
						elseif Right then
							BodyAngularVelocity.angularvelocity = Vector3.new(0, -TurnSpeed, 0)
						else
							BodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
						end
					end
					TrainSmoke.Enabled = false
					BodyForce.force = Vector3.new(0, 0, 0)
					TrainTorso.Velocity = Vector3.new(0, 0, 0)
					TrainRunning = false
				end)
			end
		end
	end)
	Mouse.KeyUp:connect(function(Key)
		Key = Key:lower()
		if Key == "w" then
			Forward = false
		elseif Key == "s" then
			Backward = false
		elseif Key == "a" then
			Left = false
		elseif Key == "d" then
			Right = false
		end
	end)
end

function Unequipped()
	ResetTrain()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)