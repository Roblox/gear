--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = RbxUtility.Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseCrystal = BasePart:Clone()
BaseCrystal.Name = "Crystal"
BaseCrystal.BrickColor = BrickColor.new("Lime green")
BaseCrystal.Reflectance = 0.5
BaseCrystal.Size = Vector3.new(1.35, 1.35, 1.35)
BaseCrystal.CanCollide = false
CrystalMesh = Instance.new("SpecialMesh")
CrystalMesh.MeshType = Enum.MeshType.FileMesh
CrystalMesh.MeshId = (BaseUrl .. "9756362")
CrystalMesh.TextureId = ""
CrystalMesh.Scale = Vector3.new(1, 1, 1)
CrystalMesh.VertexColor = Vector3.new(1, 1, 1)
CrystalMesh.Offset = Vector3.new(0, 0, 0)
CrystalMesh.Parent = BaseCrystal

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 2.5)
ArrowMesh = RbxUtility.Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "223061547"),
	TextureId = (BaseUrl .. "223061609"),
	Scale = Vector3.new(0.5, 0.5, 0.5),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseArrow
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.75, Weight = nil, Speed = nil, Duration = nil},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil},
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

Damage = {
	Min = 15,
	Max = 55,
	Multiplier = 1.25,
}

MaxCharge = 3

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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
		local ArrowCFrame = CFrame.new((LeftArm.CFrame * CFrame.new(0, -1, 0)).p, (Handle.CFrame * CFrame.new(0, 0, -2.25)).p) * CFrame.new(0, 0, -1.2)
			ArrowWeld.C0 = LeftArm.CFrame:toObjectSpace(ArrowCFrame)
			ArrowWeld.C1 = CFrame.new() * CFrame.Angles(math.pi, 0, (math.pi / 1))
			if (tick() - ChargeTable.Charge) >= MaxCharge and not ChargeTable.FullyCharged then
				ChargeTable.FullyCharged = true
				local Fire = RbxUtility.Create("Fire"){
					Color = BrickColor.new("Bright green").Color,
					SecondaryColor = BrickColor.new("Dark green").Color,
					Heat = 5,
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
		local player = Players:GetPlayerFromCharacter(character)
		if player and IsTeamMate(Player, player) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			if humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			else
				--Drop = true
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
			--if ChargeTable.FullyCharged then
				local CharacterStruck = character
				local CrystalCharge = {
					Min = 7,
					Max = 25,
				}
				local CrystalDamage = Round((GetPercentage(0, MaxCharge, ChargeTable.CalculatedCharge)), 0.5)
				CrystalDamage = Clamp(((CrystalDamage < CrystalCharge.Min and CrystalCharge.Min) or CrystalDamage), CrystalCharge.Min, CrystalCharge.Max)
				Delay(0.25, function()
					if Arrow and Arrow.Parent then
						local Origin = Arrow.CFrame * CFrame.new(0, 0, -(Arrow.Size.Z / 2))
						local CrystalVelocity = 25
						for i = 1, math.random(10, 20) do
							local Crystal = BaseCrystal:Clone()
							local CrystalSize = 0.2
							local CrystalHeight = 0.2
							Crystal.Size = Vector3.new(CrystalSize, CrystalHeight, CrystalSize)
							Crystal.Mesh.Scale = (BaseCrystal.Size * Crystal.Size)
							Crystal.CFrame = Origin * CFrame.Angles((math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001))
							local Direction = (Crystal.CFrame * CFrame.Angles((math.pi / 2), 0, 0)).lookVector
							local BodyGyro = Instance.new("BodyGyro")
							BodyGyro.maxTorque = Vector3.new(0, 0, 0)
							BodyGyro.cframe = Crystal.CFrame
							BodyGyro.Parent = Crystal
							local Mass = (Crystal:GetMass() * Gravity)
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.maxForce = Vector3.new(0, Mass, 0)
							BodyVelocity.velocity = (Direction * CrystalVelocity)
							BodyVelocity.Parent = Crystal
							Crystal.Velocity = (Direction * CrystalVelocity)
							Crystal.Touched:connect(function(Hit)
								if not Hit or not Hit.Parent then
									return
								end
								local character = Hit.Parent
								if character:IsA("Hat") then
									character = character.Parent
								end
								if character == Character then
									return
								end
								local player = Players:GetPlayerFromCharacter(character)
								if player and IsTeamMate(Player, player) then
									return
								end
								local humanoid = character:FindFirstChild("Humanoid")
								if not humanoid or humanoid.Health == 0 then
									return
								end
								UntagHumanoid(humanoid)
								TagHumanoid(humanoid, Player)
								humanoid:TakeDamage((CrystalDamage / ((character == CharacterStruck and 10) or 1)))
							end)
							Debris:AddItem(Crystal, 5)
							Debris:AddItem(BodyVelocity, 0.25)
							Debris:AddItem(BodyGyro, 0.25)
							Crystal.Parent = game:GetService("Workspace")
						end
					end
				end)
			--end
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
		InvokeClient("PlayAnimation", Animations.Idle)
	end)
	ToolEquipped = true
end

function Unequipped()
	if DisplayArrow and DisplayArrow.Parent then
		DisplayArrow:Destroy()
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
	end)
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "KeyPress" then
			local Key = value.Key
			local ByteKey = string.byte(Key)
			local Down = value.Down
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
					FireDamage = Clamp(((FireDamage < Damage.Min and Damage.Min) or FireDamage), Damage.Min, Damage.Max)
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