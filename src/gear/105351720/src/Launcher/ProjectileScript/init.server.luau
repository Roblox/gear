--Rescripted by Luckymaxer

Projectile = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Projectile:WaitForChild("Creator")

ProjectileManager = script:WaitForChild("ProjectileManager")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

TemplateHole = BasePart:Clone()
TemplateHole.Name = "GroundhogHole"
TemplateHole.Transparency = 1
TemplateHole.Size = Vector3.new(5.5, 0.2, 5.5)
TemplateHole.CanCollide = false
Decal = Create("Decal"){
	Name = "Decal",
	Shiny = 20,
	Specular = 0,
	Texture = (BaseUrl .. "96622746"),
}
for i, v in pairs({"Top", "Bottom"}) do
	local Image = Decal:Clone()
	Image.Face = Enum.NormalId[v]
	Image.Parent = TemplateHole
end

function GetCreator()
	local CreatorValue = Creator.Value
	return (((CreatorValue and CreatorValue.Parent and CreatorValue:IsA("Player")) and CreatorValue) or nil)
end

function GetProjectileManager()
	local CreatorPlayer = GetCreator()
	if CreatorPlayer then
		local ProjectileModelName = (CreatorPlayer.Name .. "'sPortals")
		local ProjectileModel = game:GetService("Workspace"):FindFirstChild(ProjectileModelName)
		if not ProjectileModel then
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = CreatorPlayer},
			}
			ProjectileModel = Create("Model"){
				Name = ProjectileModelName,
			}
			local ProjectileManagerCopy = ProjectileManager:Clone()
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = ProjectileManagerCopy,
				}
			end
			ProjectileManagerCopy.Disabled = false
			ProjectileManagerCopy.Parent = ProjectileModel
			ProjectileModel.Parent = game:GetService("Workspace")
		end
		return ProjectileModel
	else
		return nil
	end
end

function FindCharacterAncestor(Object)
	if Object and Object ~= game:GetService("Workspace") then
		local Humanoid = Object:FindFirstChild("Humanoid")
		if Humanoid then
			return Object, Humanoid
		else
			return FindCharacterAncestor(Object.Parent)
		end
	end
	return nil
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
	local ProjectileNames = {"Water", "Part", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
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

function FlyProjectile(Part)
	local AlreadyHit = false
	local function PartHit(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character, humanoid = FindCharacterAncestor(Hit)
		if humanoid then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			return
		end
		AlreadyHit = true
		return true
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.Velocity.Unit, Length = (TemplateHole.Size.Z + 2)}, {Vector = Part.CFrame.lookVector, Length = (TemplateHole.Size.Z + 2)}, {Vector = Vector3.new(0, -1, 0), Length = (TemplateHole.Size.Y * 1.25)}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = (TemplateHole.Size.Z + 2)}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		local IgnoreList = {Part}
		for i, v in pairs(Players:GetPlayers()) do
			if v:IsA("Player") and v.Character then
				table.insert(IgnoreList, v.Character)
			end
		end
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, IgnoreList, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
		end
		return ((ClosestRay.Hit and ClosestRay) or nil)
	end
	local function ConnectPart(Hit)
		if AlreadyHit then
			return
		end
		local ClosestRay = CheckForContact(Hit)
		if not ClosestRay then
			return
		end
		AlreadyHit = true
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		if SuccessfullyHit then
			local Hit = ClosestRay.Hit
			if Hit then
				local Hole = TemplateHole:Clone()
				Hole.Name = "Effect"
				Part.Size = Vector3.new(0.2, 0.2, 0.2)
				Part.Transparency = 1
				Part.CanCollide = false
				Part.Anchored = true
				for i, v in pairs(Part:GetChildren()) do
					if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Light") or v:IsA("Sparkles") then
						v.Enabled = false
					elseif string.find(string.lower(v.ClassName), string.lower("Body")) then
						v:Destroy()
					elseif v:IsA("Sound") then
						v:Stop()
					end
				end
				local ProjectilePosition = ClosestRay.Pos
				local StickCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles(-(math.pi / 2), 0, 0)
				StickCFrame = (StickCFrame * CFrame.new(0, 0, (-(TemplateHole.Size.Z / 2) + 0)) * CFrame.Angles(0, math.pi, 0))
				Hole.CFrame = StickCFrame
				local Weld = Create("Motor6D"){
					Part0 = Hit,
					Part1 = Hole,
					C0 = CFrame.new(0, 0, 0),
					C1 = (StickCFrame:inverse() * Hit.CFrame),
					Parent = Hole,
				}
				Part.Name = "Effect"
				Debris:AddItem(Hole, 60)
				Hole.Parent = GetProjectileManager()
			end
		end
	end
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or AlreadyHit then
			return
		end
		ConnectPart(Hit)
	end)
	Spawn(function()
		while Part and Part.Parent and Part.Name ~= "Effect" and not AlreadyHit do
			ConnectPart()
			wait()
		end
	end)
end

FlyProjectile(Projectile)