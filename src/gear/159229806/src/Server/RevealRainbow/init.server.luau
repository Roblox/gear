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

local Character = script.Parent

local Hum = Character:FindFirstChildOfClass("Humanoid")

local Center = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("HumanoidRootPart")

if not Center then script:Destroy() end

local Creator = script:WaitForChild("Creator",5)

local Tool = script:WaitForChild("Tool",5)


local Range = script:WaitForChild("Range",5)

if not Creator or not Tool or not Range then script:Destroy() return end

Creator = Creator.Value
Tool = Tool.Value
Range = Range.Value

local CreatorTorso = Creator:FindFirstChild("HumanoidRootPart") or Creator:FindFirstChild("Torso") or Creator:FindFirstChild("UpperTorso")

local Services = {
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local SONARPeri = Create("Part"){
	Name = "SONARPeri",
	Size = Vector3.new(1,0.6,5.2),
	Locked = true,
	Anchored = false,
	CanCollide = false,
	Material = Enum.Material.Plastic
}

local BaseUrl = "http://www.roblox.com/asset/?id="

local SONARPeriMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	Offset = Vector3.new(0,0,0),
	Scale = Vector3.new(1,1,1),
	VertexColor = Vector3.new(1,1,1),
	MeshId = BaseUrl.."80557857",
	TextureId = BaseUrl.."73816926",
	Parent = SONARPeri
}

local Pos = Create("BodyPosition"){
	MaxForce = Vector3.new(1,1,1)*math.huge,
	Position = (Center.CFrame * CFrame .new(0,0,-3)).p,
	D = 1250,
	P = 10^4,
	Parent = SONARPeri
}


local Beep = script:WaitForChild("SONARBeep",5)
Beep.Parent = Center
Beep:Play()

SONARPeri.CFrame = CFrame.new(Center.CFrame.p+Vector3.new(0,10,0))*CFrame.Angles(math.rad(90),0,0)
Pos.Position = Center.CFrame.p + Vector3.new(0,10,0)
SONARPeri.Parent = Character

local Speed = Hum.WalkSpeed

for i=25,0,-1 do
	SONARPeri.Transparency = (i/60)
	Services.RunService.Heartbeat:Wait()
end

repeat
Pos.Position = Center.CFrame.p + Vector3.new(0,10,0)
Services.RunService.Heartbeat:Wait()
--print(Center)
until (Center.CFrame.p-CreatorTorso.CFrame.p).Magnitude > Range or not Tool:IsDescendantOf(Creator) or not Tool:IsDescendantOf(workspace) or Hum.WalkSpeed ~= Speed or Hum.Health <= 0 or not Center or not Center:IsDescendantOf(workspace) or not Character or not Character:IsDescendantOf(workspace)

for i=0,25,1 do
	SONARPeri.Transparency = (i/60)
	Services.RunService.Heartbeat:Wait()
end


SONARPeri:Destroy()
script:Destroy()