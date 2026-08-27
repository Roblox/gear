--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

LightningModelRemoval = script:WaitForChild("LightningModelRemoval")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseLightning = BasePart:Clone()
BaseLightning.Name = "Effect"
BaseLightning.Transparency = 0.1
BaseLightning.Material = Enum.Material.Neon
BaseLightning.Anchored = true
BaseLightning.CanCollide = false

Rate = 0.05

LightningBolts = {}
LastBolt = nil

function GetLightningModel()
	local LightningModelName = "LightningModel"
	local LightningModel = game:GetService("Workspace"):FindFirstChild(LightningModelName)
	if not LightningModel then
		LightningModel = Create("Model"){
			Name = LightningModelName,
		}
		local LightningModelRemovalClone = LightningModelRemoval:Clone()
		LightningModelRemovalClone.Disabled = false
		LightningModelRemovalClone.Parent = LightningModel
		LightningModel.Parent = game:GetService("Workspace")
	end
	return LightningModel
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
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Lightning", "Bullet"}
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

function Zap(Table)
	local StartPos, TargetPos, Character, Color = Table.StartPosition, Table.TargetPosition, Table.Character, Table.Color
	local Duration = (Table.Duration or 2)
	local FadeRate = (Table.FadeRate or 0.05)
	local Individualize = (Table.Individualize or false)
	local MaxRange = (Table.MaxRange or 40)
	local SegmentLength = (Table.SegmentLength or 5)
	local TimeToFade = (Table.TimeToFade or 0.5)
	local Ignore = (Table.Ignore or {})
	local Thickness = (Table.Thickness or 0.4)
	if not StartPos or not TargetPos or not Character then
		return
	end
	local LightningModel = GetLightningModel()
	for i, v in pairs({Character, LightningModel}) do
		table.insert(Ignore, v)
	end
	local LastPos = StartPos
	local Direction = CFrame.new(StartPos, TargetPos).lookVector
	local RayHit, RayPos, RayNormal = CastRay(StartPos, Direction, MaxRange, Ignore, false)
	local RayLength = (StartPos - RayPos).Magnitude
	local Struck = false
	local TotalSegments = math.ceil(RayLength / SegmentLength)
	Direction = CFrame.new(StartPos, RayPos).lookVector
	local LightningBolt = Create("Model"){
		Name = "LightningBolt",
	}
	if not Individualize then
		table.insert(LightningBolts, LightningBolt)
	end
	LastBolt = LightningBolt
	Debris:AddItem(LightningBolt, Duration)
	LightningBolt.Parent = LightningModel
	for i = 1, TotalSegments do
		if not Struck then
			local Entropy = Vector3.new(((math.random() * 0.125) - 0), ((math.random() * 0.25) - 0), 0) --Vector3.new(((math.random() * 2) - 1), ((math.random() * 2) - 1), ((math.random() * 2) - 1))
			local NewPos = (StartPos + (Direction * (RayLength * (i / TotalSegments))) + Entropy)
			local SegmentVec = (NewPos - LastPos)
			local RayHit, RayPos, RayNormal = CastRay(LastPos, SegmentVec.Unit, SegmentVec.Magnitude, {Character, LightningModel}, false) 
			local RayVec = (LastPos - RayPos)
			local LightningPart = BaseLightning:Clone()
			LightningPart.BrickColor = BrickColor.new(Color)
			LightningPart.Size = Vector3.new(0.2, 0.2, RayVec.Magnitude)
			LightningPart.CFrame = (CFrame.new(LastPos, RayPos) * CFrame.new(0, 0, -(RayVec.Magnitude / 2)))
			Debris:AddItem(LightningPart, (Duration - 0.5))
			local Light = Create("PointLight"){
				Name = "Light",
				Color = BrickColor.new(Color).Color,
				Brightness = 50,
				Range = 2,
				Shadows = false,
				Enabled = true,
				Parent = LightningPart,
			}
			--Make circular
			local CylinderMesh = Create("CylinderMesh"){
				Name = "Mesh",
				Scale = Vector3.new(Thickness, 1, Thickness),
				Parent = LightningPart,
			}
			local OrigCF = LightningPart.CFrame
			LightningPart.Size = Vector3.new(LightningPart.Size.X, LightningPart.Size.Z, LightningPart.Size.Y)
			LightningPart.CFrame = (OrigCF * CFrame.Angles((math.pi / 2), 0, 0))
			LightningPart.Parent = LightningBolt
			LastPos = NewPos
			Spawn(function()
				local FadeRate = 0.05
				local OrigTransparency = LightningPart.Transparency
				for i = 1, (TimeToFade / FadeRate) do
					wait(FadeRate)
					LightningPart.Transparency = (OrigTransparency + (i / (TimeToFade / FadeRate)))
				end
			end)
		end
	end
	return {RayHit = RayHit, RayPos = RayPos, RayNormal = RayNormal, LightningModel = LightningModel}
end

function RemoveLightning()
	for i, v in pairs(LightningBolts) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	LightningBolts = {}
end

Functions = {
	Zap = Zap,
	RemoveLightning = RemoveLightning,
}

return Functions