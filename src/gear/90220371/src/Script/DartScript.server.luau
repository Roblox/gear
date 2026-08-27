--Rescripted by StarWars
local Debris = game:GetService("Debris")

local DartTrap = script.Parent

local CHECK_RATE = 0.1
local FIRE_RATE = 3
local RANGE = 100
local DAMAGE = 45

local WIND_VECTOR = Vector3.new(2, -1, 1).Unit
local RATE = 1/20

local Creator = DartTrap:WaitForChild("creator")

local function DrawBeam(startPosition, endPosition, brickColor, fadeDelay)
	local Distance = (startPosition - endPosition).Magnitude
	local Laser = Instance.new("Part")
	Laser.Name = "Effect"
	Laser.Anchored = true
	Laser.CanCollide = false
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 1
	Laser.Material = Enum.Material.Plastic
	Laser.Locked = true
	Laser.TopSurface = Enum.SurfaceType.Smooth
	Laser.BottomSurface = Enum.SurfaceType.Smooth
	Laser.BrickColor = brickColor
	Laser.CFrame = CFrame.new(endPosition, startPosition) * CFrame.new(0, 0, -Distance * 0.5) * CFrame.Angles(math.pi * 0.5, 0, 0)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.Scale = Vector3.new(1, Distance*5, 1)
	Mesh.Parent = Laser
	Debris:AddItem(Laser, fadeDelay*3)
	
	Laser.Parent = workspace
	local Frames = math.floor(fadeDelay / RATE)
	for i = 1, Frames do
		wait(RATE)
		local Percent = i / Frames
		Laser.CFrame = Laser.CFrame + WIND_VECTOR * RATE
		Laser.Transparency = 0.5 + (Percent * 0.5)
	end
	
	wait(1)
	Laser:Destroy()
end

local function FireDart(hit, position)
	local Dart = Instance.new("Part")
	Dart.Name = "Effect"
	Dart.BrickColor = BrickColor.new("Reddish brown")
	Dart.CanCollide = false
	Dart.TopSurface = Enum.SurfaceType.Smooth
	Dart.BottomSurface = Enum.SurfaceType.Smooth
	Dart.Size = Vector3.new(0.2, 0.4, 1.6)
	
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://90114680"
	Mesh.TextureId = "rbxassetid://90023594"
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.Parent = Dart
	
	local DartCFrame = CFrame.new(position, position + DartTrap.CFrame.lookVector) * CFrame.new(0, 0, 0.5)
	Dart.CFrame = DartCFrame
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = hit
	Weld.Part1 = Dart
	Weld.C0 = hit.CFrame:inverse() * DartCFrame
	Weld.C1 = DartCFrame:inverse() * DartCFrame
	Weld.Parent = Dart
	
	Debris:AddItem(Dart, 10)
	Dart.Parent = workspace
	
	local Sound = DartTrap:FindFirstChildOfClass("Sound")
	if Sound then
		Sound:Play()
	end
	spawn(function() DrawBeam(DartTrap.Position, position, BrickColor.new("Institutional white"), 0.25) end)
	wait(FIRE_RATE - CHECK_RATE)
end

local function CheckInTangible(hit)
	if hit then
		if hit.Transparency > 0.8 or hit.Name == "Handle" or hit.Name == "Effect" or hit.Name == "Bullet" or hit.Name == "Laser" or string.lower(hit.Name) == "water" or hit.Name == "Rail" or hit.Name == "Arrow" then
			return true
		end
	end
	
	return false
end

local function CastRay(startPosition, vector, length, ignore)
	local Hit, EndPosition = workspace:FindPartOnRay(Ray.new(startPosition, vector*length), ignore)
	if Hit then
		if CheckInTangible(Hit) then
			Hit, EndPosition = CastRay(EndPosition + (vector*0.01), vector, length-((startPosition - EndPosition).Magnitude), ignore)
		end
	end
	
	return Hit, EndPosition
end

while true do
	wait(CHECK_RATE)
	local Hit, Position = CastRay(DartTrap.Position, DartTrap.CFrame.lookVector, RANGE, DartTrap)
	if Hit and Hit.Parent then
		local TargetHumanoid = Hit.Parent:FindFirstChildOfClass("Humanoid")
		if TargetHumanoid and TargetHumanoid.Health > 0 then
			local HitPlayer = game.Players:GetPlayerFromCharacter(Hit.Parent)
			if Creator.Value ~= HitPlayer then
				TargetHumanoid:TakeDamage(DAMAGE)
				FireDart(Hit, Position)
			end
		end 
	end
end