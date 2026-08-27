--Rescripted by Luckymaxer

Cloud = script.Parent
Mesh = Cloud:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Creator = script:WaitForChild("Creator")
RainDuration = script:WaitForChild("RainDuration")
Target = script:WaitForChild("Target")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Sounds = {
	Wind = Cloud:WaitForChild("Wind"),
}

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

function Random(Lower, Upper)
	return (Lower + math.random() * (Upper - Lower))
end

Sounds.Wind:Play()

local Character = Target.Value
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
if Torso then
	local BodyPosition = Create("BodyPosition"){
		Parent = Cloud,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Cloud.CFrame,
		Parent = Cloud,
	}
	local Snowflake = 1
	local NumberSnowflakes = 16
	local SnowTime = 0.2
	local SnowTimer = 0
	local StartTick = tick()
	
	while (tick() - StartTick) < RainDuration.Value do
		local Time = RunService.Heartbeat:wait()
		BodyPosition.position = (Torso.Position + Vector3.new(0, 6, 0))
		BodyGyro.cframe = (BodyGyro.cframe * CFrame.Angles(0, ((math.pi / 2) * Time), 0))
		if Mesh.Scale.X < 2.25 then
			Mesh.Scale = (Mesh.Scale + Vector3.new(1, 1, 1) * 0.8 * Time)
		end
		SnowTimer = (SnowTimer - Time)
		if SnowTimer <= 0 then
			SnowTimer = SnowTime
			local Flake = BasePart:Clone()
			Flake.Name = "Effect"
			Flake.Transparency = 0.5
			Flake.BrickColor = BrickColor.new("White")
			Flake.Size = Vector3.new(0.3, 0.3, 0.3)
			Flake.CanCollide = false
			local Force = Create("BodyForce"){
				force = Vector3.new(0, -5, 0),
				Parent = Flake,
			}
			local Mesh = Create("SpecialMesh"){
				MeshType = Enum.MeshType.Sphere,
				Parent = Flake,
			}
			Flake.Parent = Cloud
			Flake.Position = (Cloud.Position + Vector3.new(Random(-1.5, 1.5), 0, Random(-1.5, 1.5)))
			Flake.Velocity = Vector3.new(0, 0, 0)
		end
	end
	while Mesh.Scale.X > 0 do
		local Time = RunService.Heartbeat:wait()
		Mesh.Scale = (Mesh.Scale - Vector3.new(1, 1, 1) * 0.8 * Time)
	end
end