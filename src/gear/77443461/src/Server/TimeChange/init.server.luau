--Time changer for both Sword of Light & Darkness
--Cool aesthetics included

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Creator,Time,SpawnPosition,TimeSound,ChargeReady,Strike = script:WaitForChild("Creator").Value,script:WaitForChild("Time").Value,script:WaitForChild("SpawnPosition").Value,script:WaitForChild("TimeSound"),script:WaitForChild("ChargeReady"),script:WaitForChild("Strike")
local Stars,StarSplash = script:WaitForChild("Stars"),script:WaitForChild("StarSplash")

local BeamWidth,BeamHeight = 7,1000

local LightBeam = Create("Part"){
	Material = Enum.Material.Neon,
	Name = "Light Beam",
	Size = Vector3.new(0,BeamWidth,BeamWidth),
	Shape = Enum.PartType.Cylinder,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(255,255,203),
	Anchored = true,
	CanCollide = false,
	Locked = true,
}

local CelestialCircle = Create("Part"){
	Size = Vector3.new(1,.5,1),
	Anchored = true,
	CanCollide = false,
	Locked = true,
	Name = "CelestialCircle",
	Transparency = 1
}

TimeSound.Parent = CelestialCircle
ChargeReady.Parent = CelestialCircle
Strike.Parent = CelestialCircle
Stars.Parent = CelestialCircle
StarSplash.Parent = CelestialCircle

local CelestialUI = script:WaitForChild("CelestialCircle")
CelestialUI.Face = Enum.NormalId.Top
CelestialUI.Parent = CelestialCircle
CelestialUI.Enabled = true

local CelestialImage = CelestialUI:WaitForChild("Circle")
CelestialImage.ImageColor3 = Color3.fromRGB(255,255,203)

CelestialUI2 = CelestialUI:Clone()
CelestialUI2.Face = Enum.NormalId.Bottom
CelestialUI2.Parent = CelestialCircle

local CelestialImage2 = CelestialUI:WaitForChild("Circle")

CelestialCircle.CFrame = CFrame.new(SpawnPosition)
CelestialCircle.Parent = workspace
Stars.Enabled = true
ChargeReady:Play()
TimeSound:Play()

coroutine.wrap(function()
	while CelestialCircle and CelestialCircle:IsDescendantOf(workspace) do
		CelestialCircle.CFrame = CelestialCircle.CFrame * CFrame.Angles(0,math.rad(-3),0)
		Services.RunService.Heartbeat:Wait()
	end
	script:Destroy()
end)()

coroutine.wrap(function()
	--Cast large beam of light!
	LightBeam.Parent = workspace
	for i=0,60,1 do
		if LightBeam then	
			LightBeam.Size = Vector3.new((i/60)*BeamHeight,BeamWidth,BeamWidth)
			LightBeam.CFrame = (CFrame.new(SpawnPosition) + Vector3.new(0,BeamHeight-(LightBeam.Size.X/2),0)) * CFrame.Angles(0,0,math.rad(90))
		end
		Services.RunService.Heartbeat:Wait()
	end
	StarSplash:Emit(StarSplash.Rate)
	Strike:Play()
	wait(1/2)
	for i=0,45,1 do
		if LightBeam then	
			LightBeam.Size = Vector3.new(BeamHeight,BeamWidth,BeamWidth):Lerp(Vector3.new(BeamHeight,BeamWidth * 10,BeamWidth * 10),i/45)
			LightBeam.CFrame = (CFrame.new(SpawnPosition) + Vector3.new(0,BeamHeight-(LightBeam.Size.X/2),0)) * CFrame.Angles(0,0,math.rad(90))
			LightBeam.Transparency = (i/45)
		end
		Services.RunService.Heartbeat:Wait()
	end
	if LightBeam then LightBeam:Destroy() end
end)()


for i=0,50,1 do
	if CelestialCircle then
		CelestialCircle.Size = Vector3.new(i,.5,i)
		CelestialImage.ImageTransparency = (1-(i/50))
		CelestialImage2.ImageTransparency = (1-(i/50))
	end
	Services.RunService.Heartbeat:Wait()
end

Services.Lighting.GeographicLatitude = 41.733
local TimeTween = Services.TweenService:Create(Services.Lighting,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0),{ClockTime = Time})
TimeTween:Play();TimeTween.Completed:Wait()

Stars.Enabled = false
for i=50,0,-1 do
	if CelestialCircle then
		CelestialCircle.Size = Vector3.new(i,.5,i)
		CelestialImage.ImageTransparency = (1-(i/50))
		CelestialImage2.ImageTransparency = (1-(i/50))
	end
	Services.RunService.Heartbeat:Wait()
end

wait(Strike.TimeLength)

if CelestialCircle then
	CelestialCircle:Destroy()
end

script:Destroy()
