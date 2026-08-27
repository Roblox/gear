--Initiating the black hole!


local Self = script

local Location,Range,Duration,Creator = Self:FindFirstChild("Location"),Self:FindFirstChild("Range"),Self:FindFirstChild("Duration"),Self:FindFirstChild("Creator")

if not Location or not Range or not Duration or not Creator then Self:Destroy() end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}


Creator = Creator.Value
Location = Location.Value
Range = Range.Value
Duration = Duration.Value

if Services.Players:GetPlayerFromCharacter(Creator) then
	Services.Players:GetPlayerFromCharacter(Creator).CharacterAdded:Connect(function(char)
		Creator = char
	end)
end

local TeamMates = {}

TeamMates[#TeamMates+1] = Services.Players:GetPlayerFromCharacter(Creator)

Services.Players.PlayerAdded:Connect(function(player)
	player.CharaterAdded:Connect(function(char)
		if IsTeamMate(Services.Players:GetPlayerFromCharacter(Creator),player) then
			TeamMates[#TeamMates+1] = char
		end
	end)
end)

Properties = {
	MaxSpeed = 80
}

local world = workspace

local Instant,Pairs,Unpack = Instance.new,pairs,unpack

local Type,huge,Vec3,FromRGB,NewColor,Reg3 = type,math.huge,Vector3.new,Color3.fromRGB,Color3.new,Region3.new

local FindPartsInRegion3 = world.FindPartsInRegion3WithIgnoreList

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
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

local Deletables = {}

local Black_Hole_Container = Create("Model"){
	Name = "Black Hole",
	Parent = world
}
Deletables[#Deletables+1] = Black_Hole_Container

local Singularity = Create("Part"){
	Locked = true,
	Anchored = true,
	CanCollide = false,
	CastShadow = false,
	Name = "Singularity",
	Material = Enum.Material.Neon,
	Shape = Enum.PartType.Ball,
	Transparency = 0,
	Size = Vec3(1,1,1) *  4,
	Color = NewColor(0,0,0),
	CFrame = Location
}
Black_Hole_Container.PrimaryPart = Singularity
Deletables[#Deletables+1] = Singularity

local Center = Create("Attachment"){
	Position = Vec3(0,0,0),
	Name = "Center",
	Parent = Singularity
}
Deletables[#Deletables+1] = Center

local Range_Indicator = Create("Part"){
	Locked = true,
	Anchored = true,
	CastShadow = false,
	CanCollide = false,
	Name = "Range_Indicator",
	Material = Enum.Material.ForceField,
	Size = Vec3(1,1,1),
	Transparency = .9,
	Color = FromRGB(170, 0, 170),
	CFrame = Location,
}
Deletables[#Deletables+1] = Range_Indicator

local Range_Mesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.Sphere,
	Scale = Vec3(1,1,1) * Range,
	Parent = Range_Indicator
}
Deletables[#Deletables+1] = Range_Mesh

local EffectsFolder = Self:WaitForChild("Effects"):GetChildren()
for i=1, #EffectsFolder,1  do
	if EffectsFolder[i] then
		EffectsFolder[i].Parent = Center
		if EffectsFolder[i]:IsA("ParticleEmitter") then
			EffectsFolder[i].Enabled = true
		elseif EffectsFolder[i]:IsA("Sound") then
			EffectsFolder[i]:Play()
		end
	end
end

Singularity.Parent = Black_Hole_Container
Range_Indicator.Parent = Black_Hole_Container

local DarkFire = Create("Fire"){
	Color = FromRGB(72, 0, 255),
	SecondaryColor = NewColor(0,0,1),
}


function IsInTable(Table,Value)
	for _,v in Pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local Touched_Parts = {}

Singularity.Touched:Connect(function(hit)
	if not hit or not hit.Parent or hit:IsDescendantOf(Creator) or IsInTable(Touched_Parts, hit) then return end
	
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"), hit.Parent:FindFirstChildOfClass("ForceField")
	
	if Hum and Hum.Parent ~= Creator and Hum.Health > 0 and not FF and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Creator),Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Services.Players:GetPlayerFromCharacter(Creator))
		Hum.Parent:BreakJoints()
	end
	
	if not Hum or Hum.Health <= 0 or not FF then
		Touched_Parts[#Touched_Parts+1] = hit
		--print(IsInTable(Touched_Parts, hit))
		hit:BreakJoints()
		DarkFire:Clone().Parent = hit
		DarkFire.Enabled = true
		hit.Color = FromRGB(98, 37, 209)
		
		local Scripts = hit:GetDescendants()
		
		for i=1,#Scripts,1 do
			if Scripts[i] and Scripts[i]:IsA("BaseScript") then
				Scripts[i]:Destroy()
			end
		end
		
		if hit:IsA("UnionOperation") then
			hit.UsePartColor = true
		end
		
		Services.Debris:AddItem(hit,1.5)
	end
	
end)

local Current_Time = 0

local Captured_Forces = {}

repeat
	
	--Place portal logic here
	
	
	local Captured_Parts = {}
	
	for i=1,#Captured_Forces,1 do --Remove parts that are not in range, otherwise update the forces/blacklist parts
		if Captured_Forces[i] and Captured_Forces[i].Parent and Captured_Forces[i].Parent:IsA("BasePart") then
			if (Captured_Forces[i].Parent.Position-Singularity.Position).Magnitude > Range then
				--Let the part free
				--print("Releasing from grasp")
				Captured_Forces[i]:Destroy()
			else
				--Captured_Forces[i].Parent.Velocity = Vec3(0,0,0)
				Captured_Forces[i].Velocity = (Singularity.Position-Captured_Forces[i].Parent.Position).Unit*(1-((Captured_Forces[i].Parent.Position-Singularity.Position).Magnitude/Range))*Properties.MaxSpeed
				Captured_Parts[#Captured_Parts+1] = Captured_Forces[i].Parent
			end
		end
	end
	
	local Region = Reg3(Singularity.Position - Vec3(1,1,1) * (Range * .5), Singularity.Position + Vec3(1,1,1) *(Range*.5))
	local Cast = FindPartsInRegion3(world,Region,{Unpack(TeamMates),Unpack(Captured_Parts)},huge)
	
	for i=1,#Cast,1 do
		if Cast[i] and not Cast[i].Anchored and Cast[i].Parent and (Cast[i].Position - Singularity.Position).Magnitude <= Range and not Cast[i]:IsDescendantOf(Creator) and (not Cast[i]:FindFirstAncestorWhichIsA("Accoutrement") and not Cast[i]:FindFirstAncestorWhichIsA("Tool")) then
			
			
			local Hum,FF = Cast[i].Parent:FindFirstChildOfClass("Humanoid"), Cast[i].Parent:FindFirstChildOfClass("ForceField")
			
			if Hum and Hum.Parent and (Hum.Health == huge or Hum.MaxHealth == huge) and not FF and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Creator),Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				--Cheating aren't ya?!
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Services.Players:GetPlayerFromCharacter(Creator))
				Hum.Parent:BreakJoints()
			end
			
			if not FF then
				
				local Forces = Cast[i]:GetChildren()
				
				for i=1,#Forces,1 do
					if Forces[i] and Forces[i]:IsA("BodyMover") then
						Forces[i]:Destroy()
					end
				end
				
				local Gravitation = Create("BodyVelocity"){
					MaxForce = Vec3(1,1,1)*huge,
					Velocity = (Singularity.Position-Cast[i].Position).Unit*(1-((Cast[i].Position-Singularity.Position).Magnitude/Range))*Properties.MaxSpeed,
					Name = "Black Hole Gravitation",
					Parent = Cast[i]
				}
				--[[if Cast[i]:CanSetNetworkOwnership() then
					Cast[i]:SetNetworkOwner(nil)
				end]]
	
				Deletables[#Deletables+1] = Gravitation
				Captured_Forces[#Captured_Forces+1] = Gravitation
			
			end
		
		end
	end
	
	Current_Time = Current_Time + Services.RunService.Heartbeat:Wait()
until Current_Time >= Duration or not Singularity or not Singularity.Parent or not Range_Indicator or not Range_Indicator.Parent

for i=1,#Deletables,1 do
	if Deletables[i] then
		Deletables[i]:Destroy()
	end
end

Deletables = {}

Self:Destroy()