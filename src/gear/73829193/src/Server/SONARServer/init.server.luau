--SONAR for the Server side of things

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

local function weldBetween(a, b)
	--Make a new Weld and Parent it to a.
	local weld = Instance.new("ManualWeld", a)
	--Get the CFrame of b relative to a.
	weld.C0 = a.CFrame:inverse() * b.CFrame
	--Set the Part0 and Part1 properties respectively
	weld.Part0 = a
	weld.Part1 = b
	--Return the reference to the weld so that you can change it later.
	return weld
end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local BaseUrl = "http://www.roblox.com/asset/?id="

local Properties = {
	Duration = 12,
	DespawnTime = 17,
	Range = 250
}

local Character = script.Parent

local Player = Services.Players:GetPlayerFromCharacter(Character)

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Root = Character:WaitForChild("HumanoidRootPart")

local Region = require(script:WaitForChild("RegionModule",10))

if not Humanoid or Humanoid.Health <= 0 then script:Destroy() end

local SONARClient = script:WaitForChild("SONARClient",10)

local SONARTint = script:WaitForChild("SONARTint",10)

local SONARBeep = script:WaitForChild("SONARBeep",10)

local Deletables = {}

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function GetHumanoidsInRange(Range)
	local RecordedHumanoids = {}
	for _,parts in pairs(Region.new(Root.CFrame,Vector3.new(1,1,1)*Range):Cast(Character)) do
		if parts and parts.Parent and string.find(string.lower(parts.Name),"torso") or string.find(string.lower(parts.Name),"root") and (parts.CFrame.p-Root.CFrame.p).magnitude <= Range then
			local Hum = parts.Parent:FindFirstChildOfClass("Humanoid")
			if Hum and Hum.Health ~= 0 and not IsInTable(RecordedHumanoids,Hum) then
				RecordedHumanoids[#RecordedHumanoids+1] = Hum
			end
		end
	end
	return RecordedHumanoids
end

function Cleanup()
	if SONARTint then SONARTint:Destroy() end

	for _,garbage in pairs(Deletables) do
		if garbage then
			garbage:Destroy()
		end
	end
	Deletables = {}
	
	script:Destroy()
end

--SONARClient.Parent = Character
SONARTint.Parent = SONARClient
SONARClient.Disabled = false
--Deletables[#Deletables+1] = SONARClient
Deletables[#Deletables+1] = SONARTint
delay(Properties.DespawnTime,function()
	SONARClient:Destroy()
end)
--Services.Debris:AddItem(SONARClient,Properties.DespawnTime)
--Services.Debris:AddItem(SONARTint,Properties.DespawnTime)

local SONARPeri = Create("Part"){
	Name = "SONARPeri",
	Size = Vector3.new(1,0.6,5.2),
	Locked = true,
	Anchored = false,
	CanCollide = false,
	Material = Enum.Material.Plastic
}

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
	Position = (Root.CFrame * CFrame .new(0,0,-3)).p,
	D = 1250,
	P = 10^4,
	Parent = SONARPeri
}

local Gyro = Create("BodyGyro"){
	D = 500,
	P = 3000,
	MaxTorque = Vector3.new(1,1,1)*math.huge,
	CFrame = CFrame.new(Root.CFrame.p)*CFrame.Angles(math.rad(180),math.rad(90),0),
	Parent = SONARPeri
}

Services.Debris:AddItem(SONARPeri,Properties.DespawnTime)
Deletables[#Deletables+1] = SONARPeri

SONARPeri.CFrame = (CFrame.new(Root.CFrame.p)*CFrame.Angles(math.rad(90),0,0))*CFrame.new(0,0,3)
SONARPeri.Parent = workspace
SONARPeri:SetNetworkOwner(Services.Players:GetPlayerFromCharacter(Character))

local Start,End = tick(),tick()

spawn(function()
	SONARBeep.Parent = SONARPeri
	local Wave,WaveMesh,Weld
	local function CreateWave()
		Wave = Create("Part"){
			Name = "Wave",
			Size = Vector3.new(1,1,1)*0,
			Locked = true,
			Anchored = false,
			CanCollide = false,
			Material = Enum.Material.Neon,
			Transparency = 0.5,
			Color = Color3.fromRGB(255, 170, 0),
			CFrame = SONARPeri.CFrame,
			Parent = SONARPeri
		}
		
		WaveMesh = Create("SpecialMesh"){
			MeshType = Enum.MeshType.FileMesh,
			Offset = Vector3.new(0,0,0),
			Scale = Vector3.new(0,0,0),
			VertexColor = Vector3.new(1,1,0)*10^5,
			MeshId = BaseUrl.."3270017",
			TextureId = BaseUrl.."883311537",
			Parent = Wave
		}
		Weld = weldBetween(Wave,SONARPeri)
		return Wave
	end
	
	CreateWave()
	
	Deletables[#Deletables+1] = Wave
	local Rate = 60*2
	repeat
		Wave = (Wave and Wave.Parent and Weld and Weld.Parent and Wave) or CreateWave()
		spawn(function()
			local SoundClone = SONARBeep:Clone()
			SoundClone.Parent = SONARPeri
			SoundClone:Play();Services.Debris:AddItem(SoundClone,SoundClone.TimeLength+1)
		end)
		local TaggedHumanoids = {}
		for i=1,Rate,1 do
			if Wave and Wave.Parent and WaveMesh and WaveMesh.Parent then
				WaveMesh.Scale = Vector3.new((i/Rate)*Properties.Range,(i/Rate)*Properties.Range,0)
				Wave.Transparency = (i/Rate)
			end
			for _,Hum in pairs(GetHumanoidsInRange((i/Rate)*Properties.Range)) do
				if not IsInTable(TaggedHumanoids,Hum) and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
					TaggedHumanoids[#TaggedHumanoids+1] = Hum
					spawn(function()
						local RevealScript = script:WaitForChild("Reveal",10):Clone()
						RevealScript.Parent = Hum.Parent
						RevealScript.Disabled = false
					end)
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Player)
					Hum:TakeDamage(5)
					Hum.WalkSpeed = 12
				end
			end
			Services.RunService.Heartbeat:Wait()
		end
	until not SONARPeri or not SONARPeri.Parent
end)

repeat
	End = tick()
	Pos.Position = (Root.CFrame * CFrame .new(0,0,3)).p
	Gyro.CFrame = CFrame.new(0,0,0)*CFrame.Angles(math.rad(90),0,0)
	Services.RunService.Heartbeat:Wait()
until not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 or (End-Start) >= Properties.Duration or not SONARPeri or not SONARPeri.Parent

Cleanup()