--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Size = {
	Wall = Vector3.new(60, 25, 2),
	Brick = Vector3.new(6, 4, 2),
}

Grips = {
	Up = CFrame.new(-0.3, 0, 0.3, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(-0.3, 0, 0.3, 0.194998264, 0.975938141, -0.0975725725, -0.980757415, 0.194987625, -0.00973754004, 0.00952220801, 0.0975938067, 0.995180845),
}

Sounds = {
	Use = Handle:WaitForChild("Use"),
}

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

Colors = {"Medium Blue", "Pastel light blue", "Light blue", "Cyan", "Pastel blue", "Bright violet", "Institutional white"}
Materials = {"Marble", "Granite", "Foil"}

MaxDistance = 64
Speed = 0.01

Duration = 120
ReloadTime = 5

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Up
Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end
	
function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet", --[["IceBlock"]]}
	if Hit and Hit.Parent then
		for i, v in pairs(Hit.Parent:GetChildren()) do
			if v:IsA("Humanoid") then
				return true
			end
		end
		if CheckTableForString(ProjectileNames, Hit.Name) or not Hit.CanCollide then
			return true
		end
	end
	return false
end
	
function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function PlaceBrick(Origin, Position, Parent)
	local Part = BasePart:Clone()
	Part.Name = "IceBlock"
	Part.Size = Vector3.new(Size.Brick.X, Size.Brick.Y, Size.Brick.Z)
	Part.BrickColor = BrickColor.new(Colors[math.random(1, #Colors)])
	Part.Friction = 0.01
	Part.Elasticity = 0.5
	Part.CFrame = (Origin * CFrame.new(Position + Part.Size / 2))
	if math.random() > 0.5 then
		Part.Material = Materials[math.random(1, #Materials)]
	else
		Part.Transparency = (0.1 + (math.random(1, 4) / 10))
	end
	Debris:AddItem(Part, Duration)
	Part.Parent = Parent
	Part:MakeJoints()
	return Part, (Position + Part.Size)
end

function BuildWall(Origin)
	local Parts = {}
	if Size.Wall.X < 0 or Size.Wall.Y < 0 then
		return
	end
	local ConjoinableParts = {Vector3.new(0, -1, 0), Vector3.new(0, 1, 0)}
	local RayOffsets = {Vector3.new(0, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, -1), Vector3.new(0, 0, 1), Vector3.new(-1, 0, -1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(1, 0, 1)}
	local WallSize = Vector2.new(math.ceil(Size.Wall.X / Size.Brick.X), math.ceil(Size.Wall.Y / Size.Brick.Y))
	local Model = Instance.new("Model")
	Model.Name = "IceWall"
	Debris:AddItem(Model, (Duration + (Speed * (WallSize.X * WallSize.Y)) + 5))
	Model.Parent = game:GetService("Workspace")
	for Y = 1, WallSize.Y do
		for X = 1, WallSize.X do
			local Part, Position = PlaceBrick(Origin, Vector3.new((-(Size.Wall.X / 2) + (Size.Brick.X * (X - 1))), ((Size.Brick.Y * (Y - 1))), 0), Model)
			local PartCFrame = Part.CFrame
			if Y == 1 then
				local RayHit, RayPos, RayNormal
				for i, v in pairs(RayOffsets) do
					RayHit, RayPos, RayNormal = CastRay((Part.CFrame * CFrame.new(v * Vector3.new(((Size.Brick.X / 2) - 0.1), 0, ((Size.Brick.Z / 2) - 0.1)))).p, Vector3.new(0, -1, 0), ((Size.Brick.Y / 2) + 0.1), {}, false)
					if RayHit then
						break
					end
				end
				if RayHit and RayHit:IsGrounded() then
					local Weld = Instance.new("Weld")
					Weld.Name = "Weld"
					Weld.Part0 = RayHit
					Weld.Part1 = Part
					Weld.C0 = RayHit.CFrame:inverse()
					Weld.C1 = PartCFrame:inverse()
					Weld.Parent = Part
				end
			end
			for i, v in pairs(Parts) do
				for ii, vv in pairs(ConjoinableParts) do
					local BrickOffset = CFrame.new(vv * Vector3.new(Size.Brick.X, Size.Brick.Y, 0))
					local PartPosition = (PartCFrame * BrickOffset)
					PartPosition = Vector3.new(math.floor(PartPosition.X), math.floor(PartPosition.Y), math.floor(PartPosition.Z))
					local OtherPartPosition = v.Position
					OtherPartPosition = Vector3.new(math.floor(OtherPartPosition.X), math.floor(OtherPartPosition.Y), math.floor(OtherPartPosition.Z))
					if OtherPartPosition == PartPosition then
						if v.Part:IsGrounded() or #v.Part:GetConnectedParts() > 1 then
							local Weld = Instance.new("Weld")
							Weld.Part0 = Part
							Weld.Part1 = v.Part
							Weld.C0 = BrickOffset
							Weld.Parent = v.Part
						end
					end
				end
			end
			table.insert(Parts, {Part = Part, Position = Part.CFrame})
			wait(Speed)
		end
	end
	return Parts
end

function Snap(Vector)
	return ((math.abs(Vector.X) > math.abs(Vector.Z) and ((Vector.X > 0 and Vector3.new(1, 0, 0)) or Vector3.new(-1, 0, 0))) or ((Vector.Z > 0 and Vector3.new(0, 0, 1)) or Vector3.new(0, 0, -1)))
end

function Activated()
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	MousePosition = MousePosition.Position
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() or (MousePosition - Handle.Position).magnitude > MaxDistance then
		return
	end
	Tool.Enabled = false
	local Direction = Snap((MousePosition - Handle.Position).unit)
	local Origin = CFrame.new(MousePosition, (MousePosition + Direction))
	Tool.Grip = Grips.Out
	Sounds.Use:Play()
	BuildWall(Origin)
	Tool.Grip = Grips.Up
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)