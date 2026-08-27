local Character = script.Parent

local Human = Character:FindFirstChildOfClass("Humanoid")

local IgnoreHealthChange = false
local CurrentHealth = Human.Health
		Human.Changed:Connect(function(Property) -- Based on Azure Periastron
			local NewHealth = Human.Health
			if not IgnoreHealthChange and NewHealth ~= Human.MaxHealth then
				if NewHealth < CurrentHealth then
					local DamageDealt = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					Human.Health = Human.Health + (DamageDealt * .25)
					--print((HasPeri("Azure") and "Has Azure") or "Does not have Azure")
					IgnoreHealthChange = false
				end
			end
			CurrentHealth = NewHealth
		end)

local Region = require(script:WaitForChild("RegionModule",5))

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

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


function IsInTable(Table,Value)
	for index,v in pairs(Table) do
		if v == Value then
			return true,index
		end
	end
	return false
end

local function GetNearestTorso(MarkedPosition,TorsoPopulationTable)
	local ClosestDistance = math.huge
	local ClosestTorso
	for i=1,#TorsoPopulationTable do
		local distance = (TorsoPopulationTable[i].CFrame.p-MarkedPosition).magnitude
		if TorsoPopulationTable[i] and  distance < ClosestDistance then
			ClosestDistance = distance
			ClosestTorso = TorsoPopulationTable[i]
		end
	end
	--warn("The Closest Person is: "..ClosestTorso.Parent.Name)
	return ClosestTorso
end

local function TrackCharacters(Center,Range)
	local Characters = {}
	local Players = {}
	local NegativeRegion = (Center.Position - Vector3.new(Range, Range, Range))
	local PositiveRegion = (Center.Position + Vector3.new(Range, Range, Range))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local Parts = workspace:FindPartsInRegion3(Region,Character,math.huge)
	local TaggedHumanoids = {}
		for _,hit in pairs(Parts) do
			if string.find(string.lower(hit.Name),"torso") then
				local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
				local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
				if Hum and Hum.Parent and Hum.Health > 0 and Hum ~= Character:FindFirstChildOfClass("Humanoid") and not IsInTable(TaggedHumanoids,Hum) and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Character),Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not ForceField then
					TaggedHumanoids[#TaggedHumanoids+1] = Hum
					if Services.Players:GetPlayerFromCharacter(Hum.Parent) then
						--print("Is a Player")
						Players[#Players+1] = hit
					else
						--print("Is an NPC")
						Characters[#Characters+1] = hit
					end
				end
			end
		end
	return Characters,Players
end


local function GetOwnerOfProjectile(obj)
	local Owner
	--First stage check for network ownership
	Owner = (obj:CanSetNetworkOwnership() and obj:GetNetworkOwner()) or nil
	
	if not Owner then
		for _,tags in pairs(obj:GetDescendants()) do
			if tags:IsA("ObjectValue") and tags.Value then
				Owner = tags.Value
				tags.Value = Services.Players:GetPlayerFromCharacter(Character)
			end
		end
	end
	
	if Owner and Owner:IsA("Player") and Owner.Character ~= Character then
		Owner = Owner.Character
	else
		Owner = nil
	end

	return Owner
end



local BaseUrl = "http://www.roblox.com/asset/?id="

local Properties = {
	CurrentRadius = 45
}



local Center = (Character:FindFirstChild("HumanoidRootPart"))

if not Center then script:Destroy() end

local Shield = Create("Part"){
	Transparency = 0.5,
	Shape = Enum.PartType.Ball,
	Material = Enum.Material.Neon,
	Locked = true,
	CanCollide = false,
	Anchored = false,
	Size = Vector3.new(1,1,1)*1,
	CFrame = Center.CFrame,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(0,128,0),
}

local ShieldMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.Sphere,
	Offset = Vector3.new(0,0,0),
	Scale = Vector3.new(0,0,0),
	VertexColor = Vector3.new(0,1,0)*10^5,
	--TextureId = BaseUrl.."883311537",
	Parent = Shield
}

local WeldConstraint = Create("WeldConstraint"){
	Part0 = Center,
	Part1 = Shield,
	Parent = Shield
}
Shield.CFrame = Center.CFrame
Shield.Parent = Character
--Shield:SetNetworkOwner(Services.Players:GetPlayerFromCharacter(Character))

--[[local CenterAttachment = Create("Attachment"){
	Position = Vector3.new(0,0,0),
	Name = "Center",
	Parent = Center
}]]

--[[local ShieldAttachment = Create("Attachment"){
	Position = Vector3.new(0,0,0),
	Name = "Shield",
	Parent = Shield
}]]


delay(10,function()
	Shield:Destroy()
	script:Destroy()
end)
--Services.Debris:AddItem(Shield,10)
--Services.Debris:AddItem(script,10)


local Deflected = {}
spawn(function()
	repeat
	spawn(function()
		--[[local NegativeRegion = (Center.Position - Vector3.new(ShieldMesh.Scale.X, ShieldMesh.Scale.Y, ShieldMesh.Scale.Z))
		local PositiveRegion = (Center.Position + Vector3.new(ShieldMesh.Scale.X, ShieldMesh.Scale.Y, ShieldMesh.Scale.Z))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local Parts = workspace:FindPartsInRegion3(Region,Character,math.huge)]]
		local Parts = Region.new(Center.CFrame,Vector3.new(1,1,1)*math.max(ShieldMesh.Scale.X,ShieldMesh.Scale.Y,ShieldMesh.Scale.Z)):Cast(Character)
		
		for _,hit in pairs(Parts) do
			--print(hit.Name)
			local ProjOwner
			
			if Services.Players:GetPlayerFromCharacter(hit.Parent) and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Character),Services.Players:GetPlayerFromCharacter(hit.Parent)) then
				local Knockback = Create("BodyVelocity"){
					MaxForce = Vector3.new(1,1,1)*math.huge,
					Velocity = ((hit.CFrame.p-Shield.CFrame.p).Unit*100)+Vector3.new(0,0,0),
					Name = "Knockback",
					Parent = hit
				}
				Services.Debris:AddItem(Knockback,.1)
			end
			
			local Reflectable = true 
			for _,parts in pairs(hit:GetConnectedParts(true)) do
				if parts.Anchored then
					Reflectable = false
				end
			end
			
			
			if hit and hit.Parent and not hit.Anchored and (hit.CFrame.p-Shield.CFrame.p).magnitude <= Properties.CurrentRadius and (hit:FindFirstChildOfClass("RocketPropulsion") or hit:FindFirstChildOfClass("TouchTransmitter")) and not hit:FindFirstChildOfClass("JointInstance") and hit.Name ~= "Chartreuse Laser" and not IsInTable(Deflected,hit) and not hit.Parent:IsA("Tool") and Reflectable then
				local ReflectSound = script:WaitForChild("Reflect",5):Clone()
				ReflectSound.Parent = Shield
				ReflectSound:Play()
				delay(ReflectSound.TimeLength,function()
					ReflectSound:Destroy()
				end)
				
				spawn(function()
					Deflected[#Deflected+1] = hit
					wait(1)
					for index,v in pairs(Deflected) do
						if v == hit then
							table.remove(Deflected,index)
						end
					end
				end)
				
				ProjOwner = GetOwnerOfProjectile(hit)
				
				if not ProjOwner then
					local NPCs,Players = TrackCharacters(Shield,500)
					local PriorityTorso = GetNearestTorso(Shield.CFrame.p,{unpack(NPCs),unpack(Players)})
					ProjOwner = (PriorityTorso and PriorityTorso.Parent ~= Character and PriorityTorso.Parent) or nil
				end
				
				
				for _,forces in pairs(hit:GetDescendants()) do
						
						if forces:IsA("BodyVelocity") then
						 	if ProjOwner then
								forces.Velocity = CFrame.new(hit.CFrame.p,(ProjOwner:FindFirstChild("HumanoidRootPart") or ProjOwner:FindFirstChild("Torso") or ProjOwner:FindFirstChild("UpperTorso")).CFrame.p).lookVector * forces.Velocity.magnitude --((forces.Velocity.magnitude < 10 and 50) or forces.Velocity.magnitude) * 2
							else -- Reflect back the opposite direction instead
								forces.Velocity =  forces.Velocity.unit * -forces.Velocity.magnitude
							end
						elseif forces:IsA("BodyGyro") then
							if ProjOwner then
								forces.CFrame = CFrame.new(hit.CFrame.p,(ProjOwner:FindFirstChild("HumanoidRootPart") or ProjOwner:FindFirstChild("Torso") or ProjOwner:FindFirstChild("UpperTorso")).CFrame.p)
							else -- Reflect back the opposite direction instead
								forces.CFrame = CFrame.new(hit.CFrame.p,hit.CFrame.p + hit.Velocity)
							end				
						elseif forces:IsA("RocketPropulsion") then
							if forces.Target and ProjOwner then
								forces.Target = ProjOwner:FindFirstChild("HumanoidRootPart") or ProjOwner:FindFirstChild("Torso") or ProjOwner:FindFirstChild("UpperTorso")
								forces.MaxSpeed = forces.MaxSpeed --* 2
								forces:Fire()
							else
								forces:Destroy() -- nothing to do with the rocket force
							end
						else
							if forces:IsA("BodyMover") then
								forces:Destroy()
							end
						end
						end
						

			--hit.Size =  hit.Size * 2
			--[[for _,meshes in pairs(hit:GetDescendants()) do
				if meshes:IsA("DataModelMesh") then
					meshes.Scale = meshes.Scale * 2
				end
			end	]]	
			
			if ProjOwner then
				--print("Has an owner Named "..ProjOwner.Name,hit.Velocity.magnitude)
				hit.CFrame = CFrame.new(hit.CFrame.p,(ProjOwner:FindFirstChild("HumanoidRootPart") or ProjOwner:FindFirstChild("Torso") or ProjOwner:FindFirstChild("UpperTorso")).CFrame.p)
				hit.Velocity = CFrame.new(hit.CFrame.p,(ProjOwner:FindFirstChild("HumanoidRootPart") or ProjOwner:FindFirstChild("Torso") or ProjOwner:FindFirstChild("UpperTorso")).CFrame.p).lookVector * hit.Velocity.magnitude--((hit.Velocity.magnitude < 10 and 50) or hit.Velocity.magnitude) * 2
			else
				--print("Does not have an owner",hit.Velocity.magnitude)
				hit.CFrame = CFrame.new(hit.CFrame.p,hit.CFrame.p + hit.Velocity.unit)
				hit.Velocity = hit.Velocity.unit * -hit.Velocity.magnitude
			end
			
			end
			
		

			
		
		end
	end)





	Services.RunService.Stepped:Wait()
	--Services.RunService.Heartbeat:Wait()
	until not Shield or not Shield.Parent
end)

local CharacterHumanoid = Character:FindFirstChildOfClass("Humanoid")

local DeploySound = script:WaitForChild("Deploy",5)
DeploySound.Parent = Shield
DeploySound:Play()


spawn(function()
	repeat
		CharacterHumanoid.Health = CharacterHumanoid.Health + .5
		Services.RunService.Heartbeat:Wait()
	until not Shield or not Shield.Parent or not CharacterHumanoid or not CharacterHumanoid.Parent
end)


for i=1,30,1 do
	if Shield and Shield.Parent and Center and Center.Parent then
		ShieldMesh.Scale = Vector3.new(0,0,0):Lerp(Vector3.new(1,1,1)*Properties.CurrentRadius,i/30)
		Services.RunService.Heartbeat:Wait()	
	end
end


