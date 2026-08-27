--Made by Luckymaxer

Projectile = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Projectile:WaitForChild("Creator")
Damage = Projectile:WaitForChild("Damage")

Sounds = {
	Splat = script:WaitForChild("Splat"),
}

BaseUrl = "http://www.roblox.com/asset/?id="

BaseColor = BrickColor.new("New Yeller")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

InkBlotch1 = BasePart:Clone()
InkBlotch1.Size = Vector3.new(1, 0.2, 1)
InkBlotch1Mesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "78575004"),
	TextureId = "",
	Scale = Vector3.new(0.75, 1, 0.75),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = InkBlotch1,
}

InkBlotch2 = BasePart:Clone()
InkBlotch2.Size = Vector3.new(1, 0.2, 1)
InkBlotch2Mesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "153993912"),
	TextureId = "",
	Scale = Vector3.new(0.75, 1, 0.75),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = InkBlotch2,
}

InkBlotches = {InkBlotch1, InkBlotch2}

Rate = (1 / 60)

IgnoreHit = false

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function Touched(RayData)
	local RayHit = RayData.RayHit
	local RayPos = RayData.RayPos
	local RayNormal = RayData.RayNormal
	if not RayHit or not RayHit.Parent or RayHit.Name == Projectile.Name or not RayPos or not RayNormal or IgnoreHit then
		return
	end
	local Player = Creator.Value
	if not Player or not Player:IsA("Player") then
		return
	end
	local Character = Player.Character
	local character = RayHit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		IgnoreHit = true
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		IgnoreHit = true
	end
	if not IgnoreHit then
		if not RayHit.Anchored and RayHit:GetMass() <= 16 then
			RayHit.BrickColor = BaseColor
			RayHit.Reflectance = 0.25
		end
		local Ink = InkBlotches[math.random(1, #InkBlotches)]:Clone()
		Ink.Name = "Effect"
		Ink.BrickColor = BaseColor
		Ink.Material = Enum.Material.Ice
		Ink.Reflectance = 0.2
		Ink.Size = Vector3.new((math.random(750, 1500) * 0.001), 0.2, (math.random(750, 1500) * 0.001))
		Ink.Mesh.Scale = (Ink.Mesh.Scale * Vector3.new(Ink.Size.X, 0, Ink.Size.Z))
		Ink.CanCollide = false
		local Sound = Sounds.Splat:Clone()
		Sound.Pitch = (math.random(2500, 4000) * 0.001)
		Sound.Parent = Ink
		local PartCFrame = CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * 2).p) * CFrame.Angles(-(math.pi / 2), (math.random(-360, 360) * 0.01), 0)
		PartCFrame = (PartCFrame * CFrame.new(0, (Ink.Size.Y / 4), 0))
		local Weld = Create("Motor"){
			Name = "Stick",
			Part0 = Ink,
			Part1 = RayHit,
			C0 = PartCFrame:inverse(),
			C1 = RayHit.CFrame:inverse(),
			Parent = Ink,
		}
		Debris:AddItem(Ink, 5)
		Ink.Parent = game:GetService("Workspace")
		Sound:Play()
	end
	IgnoreHit = true
	if Projectile and Projectile.Parent then
		Projectile:Destroy()
		Debris:AddItem(Projectile, 0)
	end
end

while not IgnoreHit do
	local Player = Creator.Value
	local Character
	if Player and Player:IsA("Player") then
		Character = Player.Character
	end
	local RayHit, RayPos, RayNormal = CastRay(Projectile.Position, Projectile.CFrame.lookVector, (Projectile.Size.Z * 4), {Character, Projectile}, false)
	if RayHit then
		Touched({RayHit = RayHit, RayPos = RayPos, RayNormal = RayNormal})
	else
		Projectile.CFrame = (Projectile.CFrame + Projectile.CFrame.lookVector * 3)
	end
	wait(Rate)
end