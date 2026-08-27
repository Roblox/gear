--Made by TakeoHonorable

local Properties = {
	DetectionRange = 75,
	Damage = 15,
	RefreshRate = 1/10,
	Attack_Speed = .3
}

local Self = script

local world = workspace

local Char = Self.Parent

local Hum = Char:FindFirstChildOfClass("Humanoid")

Hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
Hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
Hum.NameOcclusion = Enum.NameOcclusion.NoOcclusion
Hum.NameDisplayDistance = 0
Hum.MaxHealth = 500
Hum.Health = Hum.MaxHealth

local Root = Char:WaitForChild("HumanoidRootPart")

local Creator = Self:FindFirstChild("Creator")

if not Hum or not Creator then Self:Destroy() end

Creator = Creator.Value

local Invincibility = Instance.new("ForceField")
Invincibility.Visible = false
Invincibility.Parent = Char

local Seed = Random.new()

local NextNumber = Seed.NextNumber

local Pcall,Pairs,Type,remove,wrap,Wait,Vec3,Delay,huge,ray,HumanEnums = pcall,pairs,type,table.remove,coroutine.wrap,wait,Vector3.new,delay,math.huge,Ray.new,Enum.HumanoidStateType

local FindPartOnRay = world.FindPartOnRayWithIgnoreList

local Services = {
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService"))
}

local Accessory = 36883367

local SkeleColor = Color3.fromRGB(0,0,0)

local _,Hat = Pcall(function() return Services.InsertService:LoadAsset(Accessory) end)

if Type(Hat) == "userdata" then
	local Skull = Hat:FindFirstChildOfClass("Accessory")
	if Skull then
		local Mesh = Skull:FindFirstChildWhichIsA("SpecialMesh",true)
		if Mesh then
			Mesh.Parent.Color = SkeleColor
			--Mesh.VertexColor = Vec3(170/255,0/255,170/255)
			Mesh.TextureId = ""
		end
		Hum:AddAccessory(Skull)
	end
	Hat:Destroy()
end


local Packages = {36781407,36781447,36781481,36781518,36781360}

for i=1,#Packages do
	local _,SkelePackages = Pcall(function() return Services.InsertService:LoadAsset(Packages[i]) end)
	if Type(SkelePackages) == "userdata" then
		local R15 = SkelePackages:FindFirstChild("R15",true)
		if R15 then
			for _,part in Pairs(R15:GetChildren()) do
				if part:IsA("BasePart") then
					if part:IsA("MeshPart") then
						part.TextureID = ""
					end
					local LimbtoReplace = Hum:GetBodyPartR15(Char:FindFirstChild(part.Name))
					if LimbtoReplace then
						Hum:ReplaceBodyPartR15(LimbtoReplace,part)
					end
				end
			end
		end
		SkelePackages:Destroy()
	end
end

local Animations = {
	Idle = Hum:LoadAnimation(Self:WaitForChild("Idle")),
	Run = Hum:LoadAnimation(Self:WaitForChild("Run")),
	Jump = Hum:LoadAnimation(Self:WaitForChild("Jump")),
	Swim = Hum:LoadAnimation(Self:WaitForChild("Swim")),
	Walk = Hum:LoadAnimation(Self:WaitForChild("Walk")),
	Fall = Hum:LoadAnimation(Self:WaitForChild("Fall")),
	Climb = Hum:LoadAnimation(Self:WaitForChild("Climb"))
}



Animations.Idle:Play(nil,nil,NextNumber(Seed,.5,1))

Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)

Services.Debris:AddItem(Invincibility,2)

delay(60,function()
	Char:Destroy()
	if Self then
		Self:Destroy()
	end
end)

local CurrentTarget = nil

local HitHumanoids = {}

local TouchConnections = {}


local function StopAllAnimations()
	for _,v in Pairs(Animations) do
		if v then
			v:Stop()
		end
	end
end

function IsInTable(Table,Value)
	for _,v in Pairs(Table) do
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
	for i, v in Pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function FindClosestPlayer(Location,Range)
	local ClosestPlayer,ClosestTorso,ClosestRange = nil,nil,(Range or huge)
	local players = Services.Players:GetPlayers()
	for i=1,#players do
		if players[i] and players[i].Character and players[i] ~= Services.Players:GetPlayerFromCharacter(Creator) and Root then
			local Hum,FF,Torso = players[i].Character:FindFirstChildOfClass("Humanoid"),players[i].Character:FindFirstChildOfClass("ForceField"),(players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso"))
			if Torso and Torso.Transparency <= .5 then
				local distance = (Root.Position-Torso.Position).Magnitude
				if Hum and Hum.Health > 0 and not FF and distance < ClosestRange then
					ClosestRange = distance
					ClosestPlayer = players[i]
					ClosestTorso = Torso
				end
			end
		end
	end
	return ClosestPlayer,ClosestTorso
end

local function IsAttackable(Character) --Is this Character a teammate,the creator or another zombie that the creator is in possesion?
	--Will fill in on this later...	
	if Hum.Health <= 0 then 
		return false 
	end
	
	local Hum = Character:FindFirstChildOfClass("Humanoid")
	if not Hum or Hum.Health <= 0 then
		return false
	end
	if IsTeamMate(Services.Players:GetPlayerFromCharacter(Character),Services.Players:GetPlayerFromCharacter(Creator)) then
		return false
	end
	
	local CreatorTag = Character:FindFirstChild("Creator",true)
	if CreatorTag and (CreatorTag.Value == Creator or CreatorTag.Value == Services.Players:GetPlayerFromCharacter(Creator)) then
		return false
	end
	
	if Hum.Parent == Creator then
		return false
	end

	return true
end

local SkeleParts = Char:GetDescendants()
local Particle = Self:WaitForChild("Particle"):Clone()
for i=1,#SkeleParts do
	if SkeleParts[i] and SkeleParts[i]:IsA("BasePart") then
		local ParticleClone = Particle:Clone()
		ParticleClone.Parent = SkeleParts[i]
		ParticleClone.Enabled = true
		SkeleParts[i].Anchored = false
		if SkeleParts[i]:CanSetNetworkOwnership() then
			SkeleParts[i]:SetNetworkOwner(nil)
		end	
	end
end

for i=1,#SkeleParts do
	if SkeleParts[i] and SkeleParts[i]:IsA("BasePart") then
		TouchConnections[#TouchConnections+1] = SkeleParts[i].Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			local Humanoid,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
			if not Humanoid or Humanoid.Health <= 0 or FF or not IsAttackable(hit.Parent) or IsInTable(HitHumanoids,Humanoid) then return end
			--print(IsInTable(HitHumanoids,Humanoid))
			HitHumanoids[#HitHumanoids+1] = Humanoid
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid,Services.Players:GetPlayerFromCharacter(Creator))
			--print(Properties.Damage)
			Humanoid:TakeDamage(Properties.Damage)
			Delay(Properties.Attack_Speed,function()
				for ii=1,#HitHumanoids do
					if HitHumanoids[ii] and HitHumanoids[ii] == Humanoid then
						remove(HitHumanoids,ii)
					end
				end
			end)
		end)
	end
end

Hum.Changed:Connect(function(property) --Make it look more realistic
	if property == "WalkSpeed" then
		if Animations.Run.IsPlaying then
			Animations.Run:AdjustSpeed(Hum.WalkSpeed/16)
		end
	elseif property == "Sit" then
		Delay(3,function() -- Will get up after X Seconds
			Hum.Sit = false
		end)
	end
end)

Hum.StateChanged:Connect(function(old,new)
	
	if old == HumanEnums.Swimming then
		Animations.Swim:Stop()
	elseif old == HumanEnums.Jumping then
		Animations.Jump:Stop()
	elseif old == HumanEnums.Freefall then
		Animations.Fall:Stop()
	elseif old == HumanEnums.Climbing then
		Animations.Climb:Stop()
	end
	
	if new == HumanEnums.Swimming then
		Animations.Swim:Play(nil,2,Hum.WalkSpeed/16)
	elseif new == HumanEnums.Jumping then
		Animations.Jump:Play(nil,2,1)
	elseif new == HumanEnums.Freefall then
		Animations.Fall:Play(nil,2,1)
	elseif new == HumanEnums.Climbing then
		Animations.Climb:Play(nil,2,1)
	end
	
end)



local CurrentTarget

wrap(function()
	repeat
		local hit,pos,nor = FindPartOnRay(world,ray(Root.Position,Root.Velocity),{Char,(CurrentTarget and CurrentTarget.Parent) or nil},false,true)
		if hit and not Hum.Jump then
			Hum.Jump = true
		end
		Services.RunService.Heartbeat:Wait()
	until not Hum or not Hum.Parent or Hum.Health <= 0
end)()

repeat
	local TargetPlayer,TargetTorso = FindClosestPlayer(Root.Position,Properties.DetectionRange)
	for i=1,#SkeleParts do
		if SkeleParts[i] and SkeleParts[i]:IsA("BasePart") then
			if SkeleParts[i]:CanSetNetworkOwnership() then
				SkeleParts[i]:SetNetworkOwner(nil)
			end	
		end
	end
	--print(TargetPlayer,TargetTorso)
	if TargetPlayer and TargetTorso then
		--Pursue the target
		Hum:MoveTo(TargetTorso.Position,TargetTorso)
		if not Animations.Run.IsPlaying then
			StopAllAnimations()
			Hum.WalkSpeed = 30
			Animations.Run:Play(nil,nil,Hum.WalkSpeed/16)
		end
	else
		--No Target Found
		if CurrentTarget then
			Hum:MoveTo(Root.Position,Root)
			if not Animations.Idle.IsPlaying then
				StopAllAnimations()
				Animations.Idle:Play(nil,nil,NextNumber(Seed,.5,1))
			end
			
		else
			--roam to a random spot
			Wait(Seed:NextInteger(1,2))
			if not Animations.Walk.IsPlaying then
				StopAllAnimations()
				Hum:MoveTo(Root.Position+Vec3(NextNumber(Seed,-20,20),0,NextNumber(Seed,-20,20)))
				Hum.WalkSpeed = Seed:NextInteger(8,16)
				Animations.Walk:Play(nil,nil,Hum.WalkSpeed/16)
				wrap(function()
					Hum.MoveToFinished:Wait()
					StopAllAnimations()
					Animations.Idle:Play(nil,nil,Seed:NextNumber(.5,1))
				end)()
				
			end
		end
		
	end
	CurrentTarget = TargetTorso
	Wait(Properties.RefreshRate)
until not Char or not Char.Parent or not Hum or Hum.Health <= 0

for i=1,#TouchConnections,1 do
	if TouchConnections[i] then
		TouchConnections[i]:Disconnect()
	end
end

Services.Debris:AddItem(Char,5)
Self:Destroy()--Making sure this doesn't linger