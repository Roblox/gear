--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FunctionsLibrary = script:FindFirstChild("Functions")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

FadeScript = script:WaitForChild("FadeScript")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Sounds = {
	Hit = script:FindFirstChild("Hit"),
}

Rate = (1 / 15)

Projectiles = {}
Removing = false

Values = {}
for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function GetCreator()
	local Creator = Values.Creator.Value
	return (((Creator and Creator.Parent and Creator:IsA("Player")) and Creator) or nil)
end

function RemoveModel()
	if Removing then
		return
	end
	local Parts = {}
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
		end
	end
	if #Parts == 0 then
		Removing = true
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
	end
end

if not FunctionsLibrary or not Values.Creator then
	RemoveModel()
	return
end

Functions = require(FunctionsLibrary)

function FlyProjectile(Part, Hit)
	if Part.Name == "Effect" then
		return
	end
	local AlreadyHit = false
	local Player = GetCreator()
	local function PartHit(Hit)
		if not Hit or not Hit.Parent or not Player or Part.Name == "Effect" then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Values.Damage.Value)
		return character
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.CFrame.lookVector, Length = (Part.Size.Z + 2)}, {Vector = Vector3.new(0, -1, 0), Length = (Part.Size.Y * 1.25)}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = (Part.Size.Z + 2)}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = Functions.CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {((Player and Player.Character) or nil), Part}, false)
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
	local ClosestRay = CheckForContact(Hit)
	if ClosestRay then
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		Part.Transparency = 1
		Part.Size = Vector3.new(0.2, 0.2, 0.2)
		Part.CanCollide = false
		Part.Anchored = true
		local Hit = ClosestRay.Hit
		local SoundPart = BasePart:Clone()
		SoundPart.Name = "Effect"
		SoundPart.Transparency = 1
		SoundPart.Anchored = true
		SoundPart.CanCollide = false
		local Sound = Sounds.Hit:Clone()
		Sound.Parent = SoundPart
		Debris:AddItem(SoundPart, 1.5)
		SoundPart.CFrame = Part.CFrame
		SoundPart.Parent = game:GetService("Workspace")
		Sound:Play()
		Part.Name = "Effect"
		local Direction = Part.Velocity.Unit
		local RayHit, RayPos, RayNormal = Functions.CastRay(Part.Position, Direction, 2.5, {}, false)
		if RayHit then
			local ImagePart = BasePart:Clone()
			ImagePart.Name = "Effect"
			ImagePart.Transparency = 1
			ImagePart.Size = (Vector3.new(8, 4.5, 0.2) * 0.5)
			ImagePart.Anchored = false
			ImagePart.CanCollide = false
			local Decal = Create("Decal"){
				Name = "Decal",
				Texture = (BaseUrl .. "515586356"),
				Transparency = 1,
				Face = Enum.NormalId.Front,
				Parent = ImagePart,
			}
			local FadeScriptClone = FadeScript:Clone()
			FadeScriptClone.Disabled = false
			FadeScriptClone.Parent = ImagePart
			local PartCFrame = CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * 2).p)
			PartCFrame = (PartCFrame * CFrame.new(0, (ImagePart.Size.Y / 4), 0))
			--[[local NewDirection = CFrame.new(SmokePart.Position, RayPos)
			local OPX, OPY, OPZ, OXX, OYX, OZX, OXY, OYY, OZY, OXZ,OYZ, OZZ = PartCFrame:components()
			local NPX, NPY, NPZ, NXX, NYX, NZX, NXY, NYY, NZY, NXZ, NYZ, NZZ = NewDirection:components()
			PartCFrame = CFrame.new(
				OPX, OPY, OPZ,
				NXX, OYX, OZX,
				OXY, OYY, OZY,
				NXZ, OYZ, OZZ
			) * CFrame.Angles(math.pi, 0, 0)]]
			local Weld = Create("Motor6D"){
				Name = "Stick",
				Part0 = ImagePart,
				Part1 = RayHit,
				C0 = PartCFrame:inverse(),
				C1 = RayHit.CFrame:inverse(),
				Parent = ImagePart,
			}
			Debris:AddItem(ImagePart, 4)
			ImagePart.Parent = game:GetService("Workspace")
		end
	end
end

Model.ChildAdded:connect(function(Child)
	if Child:IsA("BasePart") and Child.Name == "Projectile" then
		table.insert(Projectiles, Child)
		Child.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			FlyProjectile(Child, Hit)
		end)
	end
end)

Model.ChildRemoved:connect(function(Child)
	for i, v in pairs(Projectiles) do
		if v == Child then
			table.remove(Projectiles, i)
		end
	end
	RemoveModel()
end)

Spawn(function()
	while not Removing and Model and Model.Parent do
		for i, v in pairs(Projectiles) do
			if v and v.Parent and v.Name ~= "Effect" then
				FlyProjectile(v)
			end
		end
		wait()
	end
end)

wait(1)

RemoveModel()