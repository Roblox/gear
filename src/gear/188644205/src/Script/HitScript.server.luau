--Made by Luckymaxer

Star = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Creator = Star:WaitForChild("Creator")
HitSound = Star:WaitForChild("Hit")

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

Damage = {
	Min = 5,
	Max = 10
}

IceCubeDuration = 20

Stuck = false

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetAllConnectedParts(Parent)
	local Parts = {}
	local function GetConnectedParts(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				for ii, vv in pairs(v:GetConnectedParts()) do
					if vv:IsA("BasePart") and not CheckTableForInstance(Parts, vv) then
						table.insert(Parts, vv)
					end
				end
			end
			GetConnectedParts(v)
		end
	end
	GetConnectedParts(Parent)
	return Parts
end

Star.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or Stuck or Hit.Name == "Handle" or Hit.Name == "Effect" then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local Player = Creator.Value
	Player = Players:GetPlayerFromCharacter(character)
	if Player and Player.Character and Player.Character == character then
		return
	end
	Stuck = true
	local Weld = Instance.new("Weld")
	Weld.Part0 = Hit
	Weld.Part1 = Star
	Weld.C0 = Hit.CFrame:toObjectSpace(Star.CFrame)
	Weld.Parent = Star
	Star.Velocity = Vector3.new(0, 0, 0)
	Star.RotVelocity = Vector3.new(0, 0, 0)
	local BodyVelocity = Star:FindFirstChild("BodyVelocity")
	if BodyVelocity then
		BodyVelocity:Destroy()
	end
	local Fire = Star:FindFirstChild("Fire")
	if Fire then
		Fire.Enabled = false
	end
	Star.CanCollide = false
	HitSound:Play()
	if humanoid and humanoid.Health > 0 then
		TagHumanoid(humanoid, Creator.Value)
		local DeterminedDamage = (math.random((Damage.Min * 1000), (Damage.Max * 1000)) * 0.001)
		humanoid:TakeDamage(DeterminedDamage)
		local ConnectedParts = GetAllConnectedParts(character)
		local Stars = {}
		if not character:FindFirstChild("SnowflakeEffect") then
			for i, v in pairs(ConnectedParts) do
				if v:IsA("BasePart") and v.Name == Star.Name and v:FindFirstChild("Snowflake") then
					table.insert(Stars, v)
				end
			end
			if #Stars >= 5 then
				local SnowflakeEffect = Instance.new("StringValue")
				SnowflakeEffect.Name = "SnowflakeEffect"
				Debris:AddItem(SnowflakeEffect, (IceCubeDuration + 3))
				SnowflakeEffect.Parent = character
				for i, v in pairs(Stars) do
					if v and v.Parent then
						for ii, vv in pairs(v:GetChildren()) do
							if vv:IsA("Fire") then
								vv.Enabled = true
							end
						end
					end
				end
				local torso = character:FindFirstChild("Torso")
				wait(2)
				for i, v in pairs(Stars) do
					if v and v.Parent then
						for ii, vv in pairs(v:GetChildren()) do
							if vv:IsA("Fire") then
								vv.Enabled = false
							end
						end
					end
				end
				if torso then
					local CharacterSize = character:GetModelSize()
					local IceCube = BasePart:Clone()
					IceCube.Name = "IceCube"
					IceCube.BrickColor = BrickColor.new("Bright blue")
					IceCube.Transparency = 0.25
					IceCube.Material = Enum.Material.Ice
					IceCube.Size = (Vector3.new(CharacterSize.Y, CharacterSize.Y, CharacterSize.Y) + Vector3.new(1.5, 1.5, 1.5))
					IceCube.Anchored = true
					IceCube.CFrame = torso.CFrame
					local Weld = Instance.new("Weld")
					Weld.Part0 = IceCube
					Weld.Part1 = torso
					Weld.Parent = IceCube
					Debris:AddItem(IceCube, IceCubeDuration)
					IceCube.Parent = game:GetService("Workspace")
				end
			end
		end
	end
	wait(5)
	Star:Destroy()
end)

RunService.RenderStepped:connect(function()
	if not Stuck then
		Star.RotVelocity = (Star.CFrame * CFrame.Angles(math.pi/2, 0, 0)).lookVector * 100
	end
	wait()
end)