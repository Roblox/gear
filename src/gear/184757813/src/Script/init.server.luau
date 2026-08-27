--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Grips = {
	Equipped = CFrame.new(0, 0, 2, -1, -0, 8.10038e-006, -8.10038e-006, 0, -1, 0, -1, -0),
	Spin = CFrame.new(0, 0, 2, -8.10004508e-007, -1, -8.10004713e-006, 1, -8.10004565e-007, -6.5610746e-012, 0, -8.10004803e-006, 0.99999994)
}

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1.5, Damage = 15},
	SpinPose = {Animation = Tool:WaitForChild("SpinPose"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 5, Damage = 30}
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Woosh = Handle:WaitForChild("Woosh"),
	Tornado = Handle:WaitForChild("Tornado")
}

Gravity = 196.20

Damage = 5
TornadoDamage = 25

Equipped = false

Clicks = 0
FirstClick = false

SecondaryAttack = {
	Enabled = true,
	Active = false,
	ReloadTime = 5
}

CurrentAnimation = nil

Special = {
	Enabled = true,
	Active = false,
	Duration = 20,
	ReloadTime = 20,
	Damage = 10,
}

MovementRate = (1 / 30)

TransparentObjects = {}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Equipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and Equipped and CheckIfAlive() then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" and Down then
				if Special.Enabled and not Special.Active and Tool.Enabled then
					Special.Enabled = false
					Special.Active = true
					local CurrentlyEquipped = true
					if ActivatedToolUnequipped then
						ActivatedToolUnequipped:disconnect()
					end
					ActivatedToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
						if ActivatedToolUnequipped then
							ActivatedToolUnequipped:disconnect()
						end
					end)
					local CoordinateFrame = InvokeClient("CoordinateFrame", nil)
					local ForwardVector = CFrame.new(Head.Position, Vector3.new(CoordinateFrame.p.X, Head.Position.Y, CoordinateFrame.p.Z)).lookVector * 50
					local UpVector = ForwardVector + Vector3.new(0, 1, 0) * 75
					local NewCoordinateFrame = CFrame.new((Head.CFrame + UpVector).p, Head.Position) * CFrame.Angles(0, 0, 0)
					InvokeClient("SetCamera", {CameraType = Enum.CameraType.Scriptable, CoordinateFrame = NewCoordinateFrame})
					TransparentObjects = SetParentTransparency(Character, 1)
					Humanoid.AutoRotate = false
					Humanoid.WalkSpeed = 0
					InvokeClient("DisableJump", true)
					TornadoPart = BasePart:Clone()
					TornadoPart.Name = "Tornado"
					TornadoPart.Size = Vector3.new(0.2, 0.2, 0.2)
					TornadoPart.CanCollide = false
					local TornadoWeldPart = TornadoPart:Clone()
					TornadoWeldPart.Transparency = 1
					TornadoWeldPart.Name = "WeldPart"
					TornadoWeldPart.Parent = TornadoPart
					local TornadoMesh = Instance.new("SpecialMesh")
					TornadoMesh.MeshType = Enum.MeshType.FileMesh
					TornadoMesh.MeshId = "http://www.roblox.com/asset/?id=102638417"
					TornadoMesh.TextureId = "http://www.roblox.com/asset/?id=102638520"
					TornadoMesh.Scale = Vector3.new(9, 9, 9)
					TornadoMesh.VertexColor = Vector3.new(1, 1, 1)
					TornadoMesh.Parent = TornadoPart
					local TornadoMotor = Instance.new("Motor6D")
					TornadoMotor.Part0 = TornadoPart
					TornadoMotor.Part1 = TornadoWeldPart
					TornadoMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles((math.pi / 2), 0, 0)
					TornadoMotor.C1 = CFrame.new(0, 11, 0) * CFrame.Angles((math.pi / 2), 0, 0)
					TornadoMotor.MaxVelocity = 0.1
					local Weld = Instance.new("Weld")
					Weld.Part0 = TornadoWeldPart
					Weld.Part1 = Torso
					Weld.Parent = TornadoWeldPart
					local Speed = 250
					local MaxSpeed = 1000
					local DesiredAngle = (99999999999 * (-Speed / math.abs(Speed)))
					local MaxVelocity = (Speed / MaxSpeed)
					TornadoMotor.MaxVelocity = MaxVelocity
					TornadoMotor.DesiredAngle = DesiredAngle
					TornadoMotor.Parent = TornadoPart
					TornadoPart.Parent = Character
					RemoverClone = Remover:Clone()
					RemoverClone.Name = (player.Name.."'s" .. Remover.Name)
					local Creator = Instance.new("ObjectValue")
					Creator.Name = "Creator"
					Creator.Value = player
					Creator.Parent = RemoverClone
					local Model = Instance.new("ObjectValue")
					Model.Name = "Model"
					Model.Value = TornadoPart
					Model.Parent = RemoverClone
					RemoverClone.Disabled = false
					RemoverClone.Parent = game:GetService("Workspace")
					local Mass = (GetTotalMass(Character) * Gravity)
					BodyPosition = Instance.new("BodyPosition")
					BodyPosition.maxForce = Vector3.new((Mass * 10), 0, (Mass * 10))
					BodyPosition.position = Torso.Position
					BodyPosition.Parent = Torso
					BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.maxForce = Vector3.new(0, 0, 0)
					BodyVelocity.Parent = Torso
					BodyGyro = Instance.new("BodyGyro")
					BodyGyro.maxTorque = Vector3.new(math.huge, 0,  math.huge)
					BodyGyro.Parent = Torso
					local DurationTick = tick()
					Sounds.Tornado:Play()
					while (tick() - DurationTick) < Special.Duration and CurrentlyEquipped and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and TornadoPart and TornadoPart.Parent and BodyPosition and BodyPosition.Parent do
						local MousePosition = InvokeClient("MousePosition")
						BodyPosition.position = Torso.Position + CFrame.new(TornadoPart.Position, MousePosition).lookVector * 15
						local RayHit, RayPos = RayCast((Torso.CFrame - Vector3.new(0, (Torso.Size.Y / 2), 0)).p, CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z)).lookVector, (Torso.Size.Z * 3), {Character})
						if RayHit then
							BodyVelocity.maxForce = Vector3.new(0, Mass * 100, 0)
							BodyVelocity.velocity = Vector3.new(0, 12.5, 0)
						else
							BodyVelocity.maxForce = Vector3.new(0, 0, 0)
							BodyVelocity.velocity = Vector3.new(0, 0, 0)
						end
						local Humanoids = GetPlayersNearby(6, Torso, {Character})
						for i, v in pairs(Humanoids) do
							if v and v.Parent and v.Health > 0 then
								UntagHumanoid(v)
								TagHumanoid(v, Player)
								v:TakeDamage(TornadoDamage)
							end
						end
						wait(MovementRate)
					end
					if CurrentlyEquipped then
						Sounds.Tornado:Stop()
						for i, v in pairs({BodyAngularVelocity, BodyPosition, BodyVelocity, BodyGyro, TornadoPart}) do
							if v and v.Parent then
								v:Destroy()
							end
						end
						InvokeClient("DisableJump", false)
						if Humanoid and Humanoid.Parent then
							Humanoid.AutoRotate = true
							Humanoid.WalkSpeed = 16
						end
						for i, v in pairs(TransparentObjects) do
							if v.Object and v.Object.Parent then
								v.Object.Transparency = v.Transparency
							end
						end
						TransparentObjects = {}
					end
					Special.Active = false
					wait(Special.ReloadTime)
					Special.Enabled = true
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Radius, Object, Ignore)
	local Radius = (Radius / 2)
	local NegativePartRadius = Vector3.new(Radius, Radius, Radius)
	local PositivePartRadius = Vector3.new(Radius, Radius, Radius)
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Object.CFrame.p - NegativePartRadius, Object.CFrame.p + PositivePartRadius), Ignore, 100)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local character = v.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
				local ForceFieldExists = false
				for i, v in pairs(character:GetChildren()) do
					if v:IsA("ForceField") then
						ForceFieldExists = true
					end
				end
				if not ForceFieldExists then
					table.insert(Humanoids, humanoid)
				end
			end
		end
	end
	return Humanoids
end

function SetParentTransparency(Parent, Transparency)
	local Objects = {}
	local function SetTransparency(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			local TransparencyExists = false
			pcall(function()
				local Property = v["Transparency"]
				TransparencyExists = true
			end)
			if TransparencyExists then
				table.insert(Objects, {Object = v, Transparency = v.Transparency})
				v.Transparency = Transparency
			end
			SetTransparency(v)
		end
	end
	SetTransparency(Parent)
	return Objects
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

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Equipped or not CheckIfAlive() or Special.Active then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if character ~= Character and humanoid and humanoid.Health > 0 then
			local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or Damage)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
	end)
end

function Activated()
	if not Tool.Enabled or not Equipped or SecondaryAttack.Active or Special.Active then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		CurrentAnimation = (((Clicks > 1 and SecondaryAttack.Enabled and not SecondaryAttack.Active) and Animations.SpinPose) or Animations.Slash)
		if CurrentAnimation == Animations.Slash then
			Sounds.Slash:Play()
		elseif CurrentAnimation == Animations.SpinPose then
			SecondaryAttack.Enabled = false
			SecondaryAttack.Active = true
			Humanoid.AutoRotate = false
			Tool.Grip = Grips.Spin
			Sounds.Woosh:Play()
			local Mass = (GetTotalMass(Character) * Gravity * 100)
			BodyAngularVelocity = Instance.new("BodyAngularVelocity")
			BodyAngularVelocity.maxTorque = Vector3.new(0, Mass, 0)
			BodyAngularVelocity.angularvelocity = Vector3.new(0, 30, 0)
			BodyAngularVelocity.Parent = Torso
		end
		InvokeClient("DisableJump", true)
		InvokeClient("PlayAnimation", CurrentAnimation)
		wait(CurrentAnimation.Duration)
		Sounds.Woosh:Stop()
		SecondaryAttack.Active = false
		Delay(SecondaryAttack.ReloadTime, function()
			SecondaryAttack.Enabled = true
		end)
		if not CurrentlyEquipped then
			return
		end
		Tool.Grip = Grips.Equipped
		if BodyAngularVelocity and BodyAngularVelocity.Parent then
			BodyAngularVelocity:Destroy()
		end
		if Humanoid and Humanoid.Parent then
			Humanoid.AutoRotate = true
		end
		InvokeClient("DisableJump", false)
		InvokeClient("StopAnimation", CurrentAnimation)
		CurrentAnimation = nil
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end
function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:WaitForChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Sounds.Unsheath:Play()
end

function Unequipped()
	Equipped = false
	Clicks = 0
	FirstClick = false
	CurrentAnimation = nil
	if Humanoid and Humanoid.Parent then
		Humanoid.AutoRotate = true
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs(TransparentObjects) do
		if v.Object and v.Object.Parent then
			v.Object.Transparency = v.Transparency
		end
	end
	TransparentObjects = {}
	for i, v in pairs({BodyAngularVelocity, BodyPosition, BodyVelocity, BodyGyro, TornadoPart}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs({ToolUnequipped, ActivatedToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)