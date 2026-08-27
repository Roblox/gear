--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")

Goldify = script:WaitForChild("Goldify")

BasePart = RbxUtility.Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.3, 3.5)
ArrowMesh = RbxUtility.Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = "http://www.roblox.com/asset/?id=203344622",
	TextureId = "http://www.roblox.com/asset/?id=203344843",
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseArrow
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
	Solidify = Handle:WaitForChild("Solidify")
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.75, Weight = nil, Speed = nil, Duration = nil},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil},
	GrappleShot = {Animation = Tool:WaitForChild("GrappleShot"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Range = 350
FireRate = 1

Rate = (1 / 30)

BarrelOffset = Vector3.new(-0.05, 0.5, -1.5)
WindVec = Vector3.new(2, -1, 1).unit

BaseDamage = 15
MaxDamage = 80
MaxCharge = 3

HookShotReloading = false
HookShotReloadTime = 3

Gravity = 196.20
ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}

ChargeTable = {
	Charge = 0,
	FullyCharged = false,
	CalculatedCharge = nil,
}

MouseDown = false
ToolEquipped = false

Tool.Enabled = true

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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, IgnoreList, DelayIfHit)
	local Hit, EndPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), IgnoreList)
	if Hit and CheckIntangible(Hit) then
		if DelayIfHit then
			wait()
		end
		Hit, EndPos = CastRay((EndPos + (Vec * 0.01)), Vec, (Length - ((StartPos - EndPos).magnitude)), IgnoreList, DelayIfHit)
	end
	return Hit, EndPos
end

function DrawBeam(StartPos, EndPos, Color, FadeDelay)
	local Distance = (StartPos - EndPos).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Head
	Mesh.Scale = Vector3.new(1, (Distance * 5), 1)
	Mesh.Parent = Laser
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end
end

function CreateQuiver()
	if Quiver and Quiver.Parent then
		Quiver:Destroy()
	end
	Quiver = BasePart:Clone()
	Quiver.Name = "Quiver"
	Quiver.Size = Vector3.new(2, 3, 0.75)
	local Mesh = RbxUtility.Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = "http://www.roblox.com/asset/?id=203762962",
		TextureId = "http://www.roblox.com/asset/?id=203344843",
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Quiver
	}
	local QuiverWeld = RbxUtility.Create("Weld"){
		Part0 = Torso,
		Part1 = Quiver,
		Parent = Quiver,
		C0 = CFrame.new(-0.5, 0.5, ((Torso.Size.Z / 2) + (Quiver.Size.Z / 2))),
		Parent = Quiver,
	}
	Quiver.Parent = Character
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

function BreakRope()
	for i, v in pairs({HookShotArrow, HookedBodyVelocity}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	InvokeClient("StopAnimation", Animations.GrappleShot)
	InvokeClient("PlayAnimation", Animations.Idle)
	HookShotReloading = true
	wait(HookShotReloadTime)
	HookShotReloading = false
end

function FireHookShot(DesiredPosition)
	
	local MaxRopeDistance = 100
	
	local StartPosition = Handle.Position
	
	local Direction = CFrame.new(StartPosition, DesiredPosition)
	local Force = 250
	
	InvokeClient("StopAnimation", Animations.Idle)
	InvokeClient("PlayAnimation", Animations.GrappleShot)
	
	HookShotArrow = BaseArrow:Clone()
	HookShotArrow.Name = "GrappleHook"
	Spawn(function()
		InvokeClient("SetLocalTransparencyModifier", {Object = HookShotArrow, Transparency = 0, AutoUpdate = false})
	end)

	local Velocity = Direction.lookVector * Force	
	
	local Rope = BasePart:Clone()
	Rope.Anchored = true
	Rope.CanCollide = false
	Rope.Name = "Rope"
	Rope.BrickColor = BrickColor.new("Institutional white")
	Rope.Size = Vector3.new(0.2, 1, 0.2)
	local RopeMesh = RbxUtility.Create("CylinderMesh"){
		Scale = Vector3.new(0, 0, 0),
		Parent = Rope,
	}
	Spawn(function()
		InvokeClient("SetLocalTransparencyModifier", {Object = Rope, Transparency = 0, AutoUpdate = false})
	end)
	
	Rope.Parent = HookShotArrow
	
	local Mass = (HookShotArrow:GetMass() * Gravity)	
	
	local BodyVelocity = RbxUtility.Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = HookShotArrow,
	}
	
	HookShotArrow.Velocity = Velocity
	
	HookShotArrow.CFrame = Handle.CFrame + Direction.lookVector * ((Handle.Size.Z / 2) + (BaseArrow.Size.Z / 2))
	HookShotArrow.CFrame = CFrame.new(HookShotArrow.Position, DesiredPosition)
	
	local BodyGyro = RbxUtility.Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
		Parent = HookShotArrow,
	}
	
	local Hooked = false
	HookShotArrow.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Hit == Rope or Hooked then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		Hooked = true
		local GrappleCFrame = CFrame.new(Hit.Position)
		local C0 = Hit.CFrame:inverse() * GrappleCFrame
		local C1 = HookShotArrow.CFrame:inverse() * GrappleCFrame
		local GrappleWeld = RbxUtility.Create("Weld"){
			Part0 = Hit,
			Part1 = HookShotArrow,
			C0 = C0,
			C1 = C1,
			Parent = HookShotArrow,
		}
		local Speed = 100
		local Mass = ((GetTotalMass(Character) * Gravity) * Speed)
		HookedBodyVelocity = RbxUtility.Create("BodyVelocity"){
			maxForce = Vector3.new(Mass, Mass, Mass),
			velocity = CFrame.new(Handle.Position, HookShotArrow.Position).lookVector * Speed,
			Parent = Torso
		}
	end)	
	
	HookShotArrow.Parent = Tool
	
	local RopeDisconnected = false
	local RopeMovement
	local function DisconnectRopeMovement()
		if not RopeDisconnected then
			if RopeMovement then
				RopeMovement:disconnect()
			end
			RopeMovement = nil
			BreakRope()
		end
	end
	
	RopeMovement = RunService.Stepped:connect(function()
		local CanBreak = false
		if not HookShotArrow or not HookShotArrow.Parent or not Rope or not Rope.Parent or not ToolEquipped then
			CanBreak = true
		end
		if not CanBreak then
			local Distance = (Torso.Position - HookShotArrow.Position).magnitude
			if Distance > MaxRopeDistance or (Hooked and Distance <= 5) then
				CanBreak = true
			end
		end
		if CanBreak then
			DisconnectRopeMovement()
		end
		local StartPos = Handle.Position
		local EndPos = HookShotArrow.Position
		local Distance = (StartPos - EndPos).magnitude
		RopeMesh.Scale = Vector3.new(1, Distance, 1)
		Rope.CFrame = CFrame.new(((StartPos + EndPos) / 2), EndPos) * CFrame.Angles(-(math.pi / 2), 0, 0)
	end)

end

function CreateDisplayArrow()
	if DisplayArrow and DisplayArrow.Parent then
		DisplayArrow:Destroy()
	end
	DisplayArrow = BaseArrow:Clone()
	DisplayArrow.Name = "DisplayArrow"
	ArrowWeld = RbxUtility.Create("Weld"){
		Part0 = LeftArm,
		Part1 = DisplayArrow,
		Parent = DisplayArrow,
	}
	DisplayArrow.Parent = Tool
	Spawn(function()
		InvokeClient("SetLocalTransparencyModifier", {Object = DisplayArrow, Transparency = 0, AutoUpdate = true})
	end)
	FocusArrow = RunService.Stepped:connect(function()
		if CheckIfAlive() and ToolEquipped and DisplayArrow.Parent and ArrowWeld.Parent then
		local ArrowCFrame = CFrame.new((LeftArm.CFrame * CFrame.new(0, -1, 0)).p, (Handle.Position + Vector3.new(0.125, 0, 0))) * CFrame.new(0, 0, -1.2)
			ArrowWeld.C0 = LeftArm.CFrame:toObjectSpace(ArrowCFrame)
			if (tick() - ChargeTable.Charge) >= MaxCharge and not ChargeTable.FullyCharged then
				ChargeTable.FullyCharged = true
				local Fire = RbxUtility.Create("Fire"){
					Color = BrickColor.new("Gold").Color,
					SecondaryColor = BrickColor.new("Gold").Color,
					Heat = 10,
					Size = 3,
					Enabled = true,
					Parent = DisplayArrow,
				}
			end
		elseif FocusArrow then
			FocusArrow:disconnect()
		end
	end)
end

function Fire(StartPos, TargetPos, Damage)
	local FakeStartPos = (Handle.CFrame * CFrame.new(BarrelOffset)).p
	local Vec = (TargetPos - StartPos).unit
	local Drop = false
	local RayHit, RayPos = CastRay(StartPos, Vec, Range, {Character}, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	local Arrow = BaseArrow:Clone()
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local GoldifyScript = character:FindFirstChild("Goldify")
		if humanoid then
			if humanoid.Health > 0 and not GoldifyScript then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
				if Damage == MaxDamage then
					local SolidifySound = Sounds.Solidify:Clone()
					SolidifySound.Parent = Arrow
					SolidifySound.Pitch = (math.random(5, 25) * 0.1)
					SolidifySound:Play()
					if not GoldifyScript then
						GoldifyScript = Goldify:Clone()
						GoldifyScript.Disabled = false
						GoldifyScript.Parent = character
					end
				end
			else
				Drop = true
			end
		end
		local HitSound = Arrow:FindFirstChild("Hit")
		if HitSound then
			HitSound.Pitch = (math.random(80, 120) / 100)
			HitSound:Play()
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0.9 + (math.random(0, 1) * 0.4)))
		Arrow.CFrame = NewCF
		if not Drop then
			local StickWeld = RbxUtility.Create("Weld"){
				Part0 = RayHit,
				Part1 = Arrow,
				C0 = (RayHit.CFrame:inverse() * NewCF),
				C1 = (NewCF:inverse() * NewCF),
				Parent = Arrow,
			}
		else
			Arrow.Velocity = Vector3.new(0, 0, 0)
			Arrow.RotVelocity = Vector3.new(0, 0, 0)
		end
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * 300)
	end
	
	Debris:AddItem(Arrow, (10 + (math.random() * 10)))
	Arrow.Parent = game:GetService("Workspace")

	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.5)
	end)
	
	if DisplayArrow and DisplayArrow.Parent then
		DisplayArrow:Destroy()
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent and RightArm and RightArm.Parent and LeftArm and LeftArm.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	RightArm = Character:FindFirstChild("Right Arm")
	LeftArm = Character:FindFirstChild("Left Arm")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateQuiver()
		for i, v in pairs({RightArm, LeftArm}) do
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
			end)
		end
	end)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Idle)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({Quiver, DisplayArrow, HookShotArrow}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "KeyPress" then
			local Key = value.Key
			local ByteKey = string.byte(Key)
			local Down = value.Down
			if Key == "q" and Down and not HookShotReloading then
				if not HookShotArrow or not HookShotArrow.Parent then
					for i, v in pairs(Tool:GetChildren()) do
						if v:IsA("BasePart") and v.Name == "GrappleHook" then
							v:Destroy()
						end
					end
					local TargetPosition = InvokeClient("MousePosition")
					FireHookShot(TargetPosition)
				else
					BreakRope()
				end
			end
		elseif mode == "MouseClick" or mode == "InputChanged" then
			local Down = value.Down
			if Down and not MouseDown and Tool.Enabled then
				MouseDown = true
				InvokeClient("PlayAnimation", Animations.Hold)
				local FocusArrow
				ChargeTable.Charge = tick()
				ChargeTable.FullyCharged = false
				ChargeTable.CalculatedCharge = nil
				CreateDisplayArrow()
				while MouseDown do
					wait()
				end
				if ToolEquipped then
					Tool.Enabled = false
					if DisplayArrow and DisplayArrow.Parent then
						DisplayArrow:Destroy()
					end
					ChargeTable.CalculatedCharge = Clamp((tick() - ChargeTable.Charge), 0, MaxCharge)
					Sounds.Fire.Pitch = (0.6 + (0.8 * (ChargeTable.CalculatedCharge / MaxCharge)))
					Sounds.Fire:Play()
					local FireDamage = Round((GetPercentage(0, MaxCharge, ChargeTable.CalculatedCharge)), 0.5)
					FireDamage = Clamp(((FireDamage < BaseDamage and BaseDamage) or FireDamage), BaseDamage, MaxDamage)
					Fire(DisplayArrow.Position, InvokeClient("MousePosition"), FireDamage)
					InvokeClient("StopAnimation", Animations.Hold)
					InvokeClient("PlayAnimation", Animations.Fire)
					Spawn(function()
						wait(FireRate)
						Tool.Enabled = true
					end)
				end
			elseif not Down and MouseDown then
				MouseDown = false
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

for i, v in pairs(Tool:GetChildren()) do
	if (v:IsA("BasePart") or v:IsA("Model")) and v ~= Handle then
		v:Destroy()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ServerControl.OnServerInvoke = OnServerInvoke