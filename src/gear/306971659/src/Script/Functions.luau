--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = {}

function Functions.DeathEffect(character)
	if not character then
		return
	end
	local SkeletonRemains = {
		["Head"] = {MeshId = "4770583", TextureId = "36869975", Scale = Vector3.new(3, 3, 3)},
		["Torso"] = {MeshId = "36780113", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Left Arm"] = {MeshId = "36780032", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Right Arm"] = {MeshId = "36780156", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Left Leg"] = {MeshId = "36780079", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Right Leg"] = {MeshId = "36780195", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	}
	local function Materialize(Object)
		if Object:IsA("BasePart") then
			Object.BrickColor = BrickColor.new("Institutional white")
			local Remains = SkeletonRemains[Object.Name]
			if Remains then
				for ii, vv in pairs(Object:GetChildren()) do
					if vv:IsA("DataModelMesh") or vv:IsA("Decal") or vv:IsA("Texture") then
					vv:Destroy()
					end
				end
				local NewMesh = Create("SpecialMesh"){
					Name = "Mesh",
					MeshType = Enum.MeshType.FileMesh,
					MeshId = (BaseUrl .. Remains.MeshId),
					TextureId = "",
					Scale = Remains.Scale,
					VertexColor = Vector3.new(1, 1, 1),
					Offset = Vector3.new(0, 0, 0),
					Parent = Object,
				}
			end
		elseif Object:IsA("CharacterMesh") or Object:IsA("Clothing") then
			Object:Destroy()
		end
	end
	local function Effect(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			Materialize(v)
			Effect(v)
		end
	end
	Effect(character)
end


function Functions.Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function Functions.GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Functions.Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function Functions.IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function Functions.TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function Functions.UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Functions.GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Functions.CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function Functions.CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or Functions.CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function Functions.CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal, RaySurface = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and Functions.CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal, RaySurface = Functions.CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal, RaySurface
end

return Functions