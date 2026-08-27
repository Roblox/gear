--Creates dash particle effects on the client to reduce unecessary latency

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
local Seed = Random.new()


local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Tween = (game:FindService("TweenService") or game:GetService("TweenService")),
}


local Torso,pos,cframe = script:WaitForChild("Torso").Value,script:WaitForChild("EndPosition").Value,script:WaitForChild("Begin").Value
local Bats = script:WaitForChild("Bats")
local BaseLine = Create("Part"){
	CastShadow = false,
	Anchored = true,
	Massless = true,
	Size = Vector3.new(0,0,0),
	Shape = Enum.PartType.Cylinder,
	CanCollide = false,
	Locked = true,
	Transparency = 0.5,
	Material = Enum.Material.Glass,
	Name = "DashLine",
	Color = Color3.fromRGB(38, 0, 0)
}


--local Lines = {}

local BodyClone = Create("Model"){
	Name = "DashBody",
	--Parent = workspace
}
--[[local Humanoid = Create("Humanoid"){
	HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff,
	MaxHealth = 0,
	Health = 0,
	BreakJointsOnDeath = false,
	DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None,
	Parent = BodyClone
}]]

for _,part in pairs(Torso.Parent:GetDescendants()) do
	if part:IsA("BasePart") or part:IsA("CharacterMesh") then
		local Clone =  part:Clone()
		if Clone.Name == "HumanoidRootPart" then
			BodyClone.PrimaryPart = Clone
		end
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("JointInstance") or v:IsA("FaceInstance") or v:IsA("Sound") or v:IsA("ParticleEmitter") then
				v:Destroy()
			end
		end
		--[[pcall(function()
			if Clone["OverlayTextureId"] then
				--Clone["OverlayTextureId"] = ""
			end
		end)]]
		pcall(function()
			if Clone:FindFirstChildOfClass("SpecialMesh") then
				Clone:FindFirstChildOfClass("SpecialMesh").TextureId = ""
				Clone:FindFirstChildOfClass("SpecialMesh").VertexColor = Vector3.new(1,1,1)
			end
		end)
		
		if Clone:IsA("BasePart") then
			Clone.CastShadow = false
			Clone.Anchored = true 
			Clone.Massless = true
			Clone.CanCollide = false
			Clone.Material = Enum.Material.Glass
			Clone.Color = Color3.fromRGB(38, 0, 0)
			Clone.Transparency = .3
		end
		
		Clone.Parent = BodyClone
	end
end

local ObjectModel = Create("Model"){
	Name = "DashEffect",
	Parent = workspace
}
for i=0,1,1/6 do
	local DashBody = BodyClone:Clone()
	DashBody.Name = ""
	DashBody:SetPrimaryPartCFrame(cframe:lerp(CFrame.new(pos)*(cframe-cframe.p),i))
	DashBody.Parent = workspace
	local parts = DashBody:GetDescendants()
	for p=1,#parts,1 do
		if parts[p]:IsA("BasePart") or parts[p]:IsA("FaceInstance") then
			Services.Tween:Create(parts[p],TweenInfo.new(.5+(.5*i),Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Transparency = 1}):Play()
		end
	end
	DashBody.Parent = ObjectModel
	--Services.Debris:AddItem(DashBody,(3*(i*.5)))
end


for i=1,Seed:NextInteger(10,15)*math.max(Torso.Size.X,Torso.Size.Y,Torso.Size.Z),1 do -- create scattered dash lines
	local DashLine = BaseLine:Clone()
	DashLine.Size = Vector3.new((pos-cframe.p).Magnitude+(Seed:NextNumber(0,3)),0.1,0.1)
	--DashLine.CFrame = (CFrame.new(pos)*(cframe-cframe.p)) * CFrame.new(,Seed:NextNumber(-Torso.Size.X*.5,Torso.Size.X*.5),Seed:NextNumber(-Torso.Size.Y*.5,Torso.Size.Y*.5))* CFrame.Angles(math.rad(90),0,0)
	DashLine.CFrame = (CFrame.new(pos)*(cframe-cframe.p)) * CFrame.Angles(0,math.rad(90),0) * CFrame.new(-((pos-cframe.p).Magnitude*.5+(2)),Seed:NextNumber(-Torso.Size.X*2,Torso.Size.X*2),Seed:NextNumber(-Torso.Size.Y*2,Torso.Size.Y*2))
	DashLine.Parent = ObjectModel
	local Bat = Bats:Clone()
	Bat.Parent = DashLine
	Bat:Emit(Bat.Rate)
	pcall(function()
		Services.Tween:Create(DashLine,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0),{Transparency = 1}):Play()
	end)
	--Services.Debris:AddItem(DashLine,3)
end


Services.Debris:AddItem(ObjectModel,3)
