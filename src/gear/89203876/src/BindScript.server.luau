local bind_time = 5

local Debris = Game:GetService("Debris")
local BodyPart = script.Parent
local Humanoid
do
	if BodyPart.Parent then
		for i,v in pairs(BodyPart.Parent:GetChildren()) do
			if v:IsA"Humanoid" then
				Humanoid = v
				break
			end
		end
	end
end

if Humanoid then
	local oWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0

	local bind0 = Instance.new("Part")
	bind0.Name = "CelestialMissile"
	bind0.FormFactor = 0
	bind0.TopSurface = 0
	bind0.BottomSurface = 0
	bind0.Reflectance = 0.5
	bind0.BrickColor = BrickColor.new("Bright yellow")
	bind0.Anchored = true
	bind0.CanCollide = false
	bind0.Locked = true
	bind0.Size = Vector3.new(4,4,1)
		local mesh = Instance.new("SpecialMesh",bind0)
		mesh.MeshId = "http://www.roblox.com/asset/?id=3270017"
		mesh.Scale = Vector3.new(4,4,4)
	local bind1 = bind0:Clone()
		local p = Instance.new("Sparkles",bind1)
		p.SparkleColor = Color3.new(1,1,0)
	bind0.Parent = script
	bind1.Parent = script

	local start = tick()
	local spin = 0
	while script.Parent do
		bind0.CFrame = BodyPart.CFrame * CFrame.Angles(math.rad(spin),-math.rad(spin*2),math.rad(spin))
		bind1.CFrame = BodyPart.CFrame * CFrame.Angles(-math.rad(spin),math.rad(spin),math.rad(spin))
		spin = spin + 90*wait()
		if tick()-start > bind_time then break end
	end
	for i=0,1,0.1 do
		bind0.Transparency = i
		bind1.Transparency = i
		bind0.CFrame = BodyPart.CFrame * CFrame.Angles(math.rad(spin),-math.rad(spin*2),math.rad(spin))
		bind1.CFrame = BodyPart.CFrame * CFrame.Angles(-math.rad(spin),math.rad(spin),math.rad(spin))
		spin = spin + 90*wait()
	end
	Humanoid.WalkSpeed = oWalkSpeed > 0 and oWalkSpeed or 16
	bind0:Destroy()
	bind1:Destroy()
end
script:Destroy()