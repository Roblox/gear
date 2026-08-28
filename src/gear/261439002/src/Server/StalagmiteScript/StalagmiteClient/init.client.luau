local Pos = script:FindFirstChild("Pos")

if not Pos then return end

local Vec3,cframe = Vector3.new,CFrame.new

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	tService = (game:FindService("TweenService") or game:GetService("TweenService")),
	rService = (game:FindService("RunService") or game:GetService("RunService"))
}

Pos = Pos.Value

local StalagmiteWidth,StalagmiteHeight = 7,100

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

local StalagModel = Create("Model"){
	Name = "Stalagmite",
}

Services.Debris:AddItem(StalagModel,3)

local StalagCorners = {}
for i=0,270,90 do
	local ShatterSound = script:FindFirstChild("ShatterSound")
	local FrostSparkles = script:FindFirstChild("FrostSparkles")
	local StalagWedge = Create("CornerWedgePart"){
		Anchored = true,
		Material = Enum.Material.Glass,
		CanCollide = false,
		Locked = true,
		Size = Vec3(StalagmiteWidth,0,StalagmiteWidth),
		Reflectance = 0,
		Transparency = .5,
		Name = "StalagmiteCorner",
		Color = Color3.fromRGB(9, 137, 207),
		CFrame = cframe(Pos)*CFrame.Angles(0,math.rad(i),0)*cframe(-StalagmiteWidth*.5,0,StalagmiteWidth*.5),
		Parent = StalagModel,
		TopSurface = Enum.SurfaceType.SmoothNoOutlines,
		BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	}
	if ShatterSound then
		ShatterSound:Clone().Parent = StalagWedge
	end
	if FrostSparkles then
		FrostSparkles:Clone().Parent = StalagWedge
	end
	StalagCorners[#StalagCorners+1] = StalagWedge
end

local DeltaInc = 1
local TargetFrameRate = 60

local GoalTime = .1--(TargetFrameRate/10) * .1
local Current_Time = 0

StalagModel.Parent = workspace

for i=1,#StalagCorners,1 do
	if StalagCorners[i]:FindFirstChildWhichIsA("ParticleEmitter") then
		StalagCorners[i]:FindFirstChildWhichIsA("ParticleEmitter"):Emit(StalagCorners[i]:FindFirstChildWhichIsA("ParticleEmitter").Rate)
	end
end

local ShatterSound = StalagModel:FindFirstChild("ShatterSound", true)
if ShatterSound then ShatterSound:Play() end

repeat
	
	for i=1,#StalagCorners,1 do
		
		if StalagCorners[i] then
			
			StalagCorners[i].Size = Vec3(StalagmiteWidth,(Current_Time/GoalTime)*StalagmiteHeight,StalagmiteWidth)
			StalagCorners[i].CFrame = cframe(Pos)*(StalagCorners[i].CFrame-StalagCorners[i].CFrame.Position) * cframe(-StalagmiteWidth*.5,StalagCorners[i].Size.Y*.5,StalagmiteWidth*.5)
		end
		
	end
	DeltaInc = Services.rService.Heartbeat:Wait()
	Current_Time = Current_Time + DeltaInc
until #StalagCorners <= 0 or Current_Time >= GoalTime

for i=1,#StalagCorners,1 do
		
	if StalagCorners[i] then
			
		StalagCorners[i].Size = Vec3(StalagmiteWidth,StalagmiteHeight,StalagmiteWidth)
		StalagCorners[i].CFrame = cframe(Pos)*(StalagCorners[i].CFrame-StalagCorners[i].CFrame.Position) * cframe(-StalagmiteWidth*.5,StalagCorners[i].Size.Y*.5,StalagmiteWidth*.5)	
	end
		
end

wait(.5)

GoalTime = .5
Current_Time = .5
repeat
	
	for i=1,#StalagCorners,1 do
		
		if StalagCorners[i] then
			
			StalagCorners[i].Size = Vec3(StalagmiteWidth,(Current_Time/GoalTime)*StalagmiteHeight,StalagmiteWidth)
			StalagCorners[i].Transparency = 1-(Current_Time/GoalTime)
			StalagCorners[i].CFrame = cframe(Pos)*(StalagCorners[i].CFrame-StalagCorners[i].CFrame.Position) * cframe(-StalagmiteWidth*.5,StalagCorners[i].Size.Y*.5,StalagmiteWidth*.5)
		
		end
		
	end
	DeltaInc = Services.rService.Heartbeat:Wait()
	Current_Time = Current_Time - DeltaInc
until #StalagCorners <= 0 or Current_Time <= 0

for i=1,#StalagCorners,1 do
		
	if StalagCorners[i] then
			
		StalagCorners[i].Size = Vec3(StalagmiteWidth,0,StalagmiteWidth)
		StalagCorners[i].Transparency = 1
		StalagCorners[i].CFrame = cframe(Pos)*(StalagCorners[i].CFrame-StalagCorners[i].CFrame.Position) * cframe(-StalagmiteWidth*.5,StalagCorners[i].Size.Y*.5,StalagmiteWidth*.5)	
	end
		
end
