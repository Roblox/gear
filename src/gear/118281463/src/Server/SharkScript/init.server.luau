--Plants the land shark into a surface and creates an illusion of ripples on the surface
--[[Land Shark mesh = 118270425
	Land Shark Texture = 118270477
--]]
--print("Planted Land shark!")

local Properties = {
	DetectionRange = 45,
	Lifetime = 60*1, --How long will the landshark stay in place before despawning
	Sink_Time = .5, --How much time is taken for the shark to go under
	Detection_Rate = .5, --How often should the shark be checking
	Shark_Speed = 80,
}

local Self = script

local world = workspace

local Deletables = {}

local PartRef,Creator,Loc = Self:FindFirstChild("PartRef"),Self:FindFirstChild("Creator"),Self:FindFirstChild("Location")

if not PartRef or not Creator or not Loc then return end

local instance,Vec3,cframe,Angles,Region = Instance.new,Vector3.new,CFrame.new,CFrame.Angles,Region3.new

local Type,rad,Seed,Wait,inf = type,math.rad,Random.new(),wait,math.huge

local FindPartsInRegion = world.FindPartsInRegion3WithIgnoreList

local NextNumber = Seed.NextNumber

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
}

local Sounds = {
	SharkSound = Self:WaitForChild("SharkSound")
}


function Create(ty)
	return function(data)
		local obj = instance(ty)
		for k, v in pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
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

PartRef = PartRef.Value
Loc = Loc.Value
Creator = Creator.Value


local SharkPart = Create("Part"){
	Locked = true,
	Size = Vec3(6,5,6),
	Anchored = true,
	Name = "Land Shark",
	CanCollide = false,
	CFrame = Loc * Angles(rad(-90),NextNumber(Seed,0,360),0)
}

Sounds.SharkSound.Parent = SharkPart

local SharkMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = "rbxassetid://118270425",
	TextureId = "rbxassetid://118270477",
	Scale = Vec3(1,1,1) * 3.5,
	Parent = SharkPart
}
Deletables[#Deletables+1] = SharkPart
Deletables[#Deletables+1] = SharkMesh

SharkPart.Parent = world

local DistanceVector = Vec3(1,1,1)*Properties.DetectionRange*.5
local Reg = Region(Loc.Position - DistanceVector , Loc.Position + DistanceVector)
local Caught = false

local CastEffect = Self:WaitForChild("RippleEffect")

if Creator:IsA("Player") then
	local Clone = CastEffect:Clone()
	
	Create("ObjectValue"){
		Name = "PartRef",
		Value = PartRef,
		Parent = Clone
	}
	
	Create("ObjectValue"){
		Name = "SharkRef",
		Value = SharkPart,
		Parent = Clone
	}
	
	Create("CFrameValue"){
		Name = "Loc",
		Value = Loc,
		Parent = Clone
	}
	
	Clone.Parent = Creator:WaitForChild("PlayerGui")
	Deletables[#Deletables+1] = Clone
	Clone.Disabled = false -- Activate the ripple effect
end

function FindFirstHumInRange()
	local Cast = FindPartsInRegion(world,Reg,{((Creator and Creator.Character) or nil)},inf)
	
	for i=1,#Cast,1 do
		
		if Cast[i] and Cast[i].Parent then
			
			local Hum,FF = Cast[i].Parent:FindFirstChildOfClass("Humanoid"),Cast[i].Parent:FindFirstChildOfClass("ForceField")
			
			if not FF and Hum and (Hum.Health > 0 or Hum.Health == inf)and not IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				
				return Hum
			
			end
			
		end
	
	end

end

SharkPart.Parent = world


local OrigCFrame = SharkPart.CFrame
local Length = Properties.Sink_Time --You only got this amount of time to move out of the area before you are completely done for!
Length = 60*Length
local Destination = OrigCFrame*cframe(0,-SharkPart.Size.Y*.75,0)
for i=1,Length,1 do
	
	if SharkPart and SharkPart.Parent and SharkPart.Anchored then
		
		SharkPart.CFrame = OrigCFrame:Lerp(Destination,i/Length)--Sink the shark in the depths of the land..
	
	end
	Services.RunService.Heartbeat:Wait()
end


local FoundHum
local Duration = 0
repeat
	FoundHum = FindFirstHumInRange()
	--print(Duration)
	if FoundHum then
		Caught = true
		--warn(FoundHum)
		break
	end
	
	Duration = Duration + Wait(Properties.Detection_Rate)
until not PartRef or not PartRef.Parent or Caught or not SharkPart or not SharkPart.Parent or Duration >= Properties.Lifetime


if FoundHum and SharkPart and SharkPart.Parent then -- Attempt to attack the character
	
	Sounds.SharkSound:Play()
	
	local Torso = FoundHum.Parent:FindFirstChild("Torso") or FoundHum.Parent:FindFirstChild("UpperTorso")
	
	if Torso then
		
		SharkPart.Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			
			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not Hum or Hum.Health <= 0 or IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or Creator == Services.Players:GetPlayerFromCharacter(Hum.Parent) then return end
			
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Creator)
			if Hum.Health == inf then
				Hum.Parent:BreakJoints()
			else
				Hum:TakeDamage(100)
			end
			
			
		end)
		
		local TorsoLoc = Torso.CFrame
		
		SharkPart.CFrame = cframe(SharkPart.CFrame.p,TorsoLoc.Position) 
		
		SharkPart.Anchored = false
		
		if SharkPart:CanSetNetworkOwnership() then
			SharkPart:SetNetworkOwner(nil)
		end
		
		SharkPart.Velocity = ((TorsoLoc.Position + Vec3(0,Torso.Size.Y,0)) - Destination.Position) * (TorsoLoc.Position - Destination.Position).Magnitude *.5 
		
		if SharkPart and SharkPart.Parent then
			
		
			local Gyro = Create("BodyGyro"){
				MaxTorque = Vec3(1,1,1) * inf,
				D = 10^3,
				CFrame = cframe(SharkPart.CFrame.Position,TorsoLoc.Position),
				Parent = SharkPart
			}
			
			repeat
				Gyro.CFrame = cframe(SharkPart.Position,SharkPart.Position + SharkPart.Velocity.Unit)
				Services.RunService.Heartbeat:Wait()
			until not SharkPart or not SharkPart.Parent
		
		end
		
	end
	
end

Wait(3.5)

if SharkPart then
	--print("Destorying Shark")
	SharkPart:Destroy()
end

Wait(1)

for i=1,#Deletables,1 do
	if Deletables[i] then
		Deletables[i]:Destroy()
	end
end

Self:Destroy()
