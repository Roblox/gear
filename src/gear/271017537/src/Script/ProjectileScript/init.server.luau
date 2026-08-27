--Made by Luckymaxer

Projectile = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Projectile:WaitForChild("Creator")
Damage = Projectile:WaitForChild("Damage")
RageMode = Projectile:FindFirstChild("RageMode")

Sounds = {
	Splat = script:WaitForChild("Splat"),
}

BaseUrl = "http://www.roblox.com/asset/?id="

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

Images = {118259001, 118261268}

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

function SplatInk(Player)
	if not Player or not Player:IsA("Player") then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local SplatGui = Create("ScreenGui"){
		Name = "SplatGui",
	}
	for i = 1, ((RageMode and math.random(20, 40)) or math.random(3, 5)) do
		local Image = Create("ImageLabel"){
			Name = "Ink",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, math.random(350, 700), 0, math.random(350, 700)),
			Position = UDim2.new((math.random(-100, 1000) * 0.001), 0, (math.random(-100, 1000) * 0.001), 0),
			Image = (BaseUrl .. Images[math.random(1, #Images)]),
			Rotation = math.random(0, 360),
			Parent = SplatGui,
		}
	end
	Debris:AddItem(SplatGui, 5)
	SplatGui.Parent = PlayerGui
end

function Touched(Hit)
	if not Hit or not Hit.Parent or Hit.Name == Projectile.Name or IgnoreHit then
		return
	end
	local Player = Creator.Value
	if not Player or not Player:IsA("Player") then
		return
	end
	local Character = Player.Character
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player == Player then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		if not IsTeamMate(Player, player) and humanoid.Health > 0 then
			if player then
				SplatInk(player)
			end
			local Weld = Instance.new("Weld")
			Weld.Part0 = Hit
			Weld.Part1 = Projectile
			local head = character:FindFirstChild("Head")
			if head then
				local Squid = Projectile:Clone()
				Squid.Name = "Projectile"
				Squid.CanCollide = false
				for i, v in pairs(Squid:GetChildren()) do
					if not v:IsA("DataModelMesh") then
						v:Destroy()
					end
				end
				local ProjectilePosition = Vector3.new(Projectile.Position.X, ((Projectile.Position.Y < head.Position.Y and head.Position.Y) or Projectile.Position.Y), Projectile.Position.Z)
				local StickCFrame = ((CFrame.new(head.Position, ProjectilePosition) * CFrame.Angles(0, math.pi, 0)) * CFrame.new(0, 0, (Squid.Size.Z * 1)) * CFrame.Angles((math.pi / 2), 0, 0))
				local Weld = Create("Weld"){
					Part0 = head,
					Part1 = Squid,
					C0 = CFrame.new(0, 0, 0),
					C1 = (StickCFrame:inverse() * head.CFrame),
					Parent = Squid,
				}
				Debris:AddItem(Squid, 5)
				Squid.Parent = game:GetService("Workspace")
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage.Value)
		end
	end
	Sounds.Splat:Play()
	IgnoreHit = true
	if Projectile and Projectile.Parent then
		Projectile:Destroy()
		Debris:AddItem(Projectile, 0)
	end
end

Projectile.Touched:connect(Touched)