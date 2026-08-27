local Creator,Center = script:WaitForChild("Creator").Value,script:WaitForChild("Center").Value

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
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
}

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local shockw = Instance.new("Part")
shockw.CanCollide = false
shockw.Shape = "Ball"
shockw.Size = Vector3.new(3, 3, 3)
shockw.Transparency = 0.5

local shockMesh = Instance.new("SpecialMesh")
shockMesh.MeshId = "http://www.roblox.com/asset/?id=54068514"
shockMesh.TextureId = "http://www.roblox.com/asset/?id=54068645"
shockMesh.Scale = Vector3.new(2, 2, 2)
shockMesh.Parent = shockw

local shockw2 = Instance.new("Part")
shockw2.CanCollide = false
shockw2.Shape = "Ball"
shockw2.Size = Vector3.new(3, 3, 3)
shockw2.Transparency = 0.5

local shockMesh2= Instance.new("SpecialMesh")
shockMesh2.MeshId = "http://www.roblox.com/asset/?id=54068569"
shockMesh2.TextureId = "http://www.roblox.com/asset/?id=54068645"
shockMesh2.Scale = Vector3.new(2, 2, 2)
shockMesh2.Parent = shockw2

local float = Instance.new("BodyForce")
float.force = Vector3.new(0, shockw:GetMass() * workspace.Gravity, 0)
float.Name = "Float"
float.Parent = shockw

local float2 = float:Clone()
float2.Parent = shockw2

local sw = shockw:Clone()		
	sw.Position = Center
	sw.Parent = workspace
	sw.RotVelocity = Vector3.new(0, 10, 0)	
	sw:SetNetworkOwner(nil)	
		
local sw2 = shockw2:Clone()		
	sw2.Position = Center	
	sw2.Parent = workspace
	sw2.RotVelocity = Vector3.new(0, -10, 0)
	sw2:SetNetworkOwner(nil)
	
local SizeInc = .5

--[[local QuakeBox = Create("Part"){
	CanCollide = false,
	Transparency = 0.5,
	Position = Center,
	Size = Vector3.new(1,1,1)*(180),
	Anchored = true,
	Color = Color3.fromRGB(0,255,0),
	Shape = Enum.PartType.Ball,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Parent = workspace
}
Services.Debris:AddItem(QuakeBox,.5)]]

local Seed = Random.new()

local Neg,Pos = Center - Vector3.new(1,1,1) * 250, Center + Vector3.new(1,1,1) * 250

local QuakeRegion = Region3.new(Neg,Pos)
local QuakedHumanoids = {}

for _,part in pairs(workspace:FindPartsInRegion3WithIgnoreList(QuakeRegion,{Creator.Character},1500)) do
	if part and part.Parent and (part.Position-Center).Magnitude <= 200/2 then
		local Hum,FF,Center = part.Parent:FindFirstChildOfClass("Humanoid"),part.Parent:FindFirstChildOfClass("ForceField"),part.Parent:FindFirstChild("HumanoidRootPart") or part.Parent:FindFirstChild("Torso") or part.Parent:FindFirstChild("UpperTorso")
		if Hum and not FF and not IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(QuakedHumanoids,Hum) then
			QuakedHumanoids[#QuakedHumanoids+1] = Hum
			Hum.Sit = true
			if Center then
				local Spin = Create("BodyAngularVelocity"){
					MaxTorque = Vector3.new(1,1,1) * math.huge,
					AngularVelocity = Vector3.new(Seed:NextNumber(-20,20),Seed:NextNumber(-10,10),Seed:NextNumber(-20,20)) ,
					Parent = Center,
				}
				Services.Debris:AddItem(Spin, 6)
			end
			local player = Services.Players:GetPlayerFromCharacter(Hum.Parent)
			if player then
				if player:FindFirstChild("PlayerGui") and not player:FindFirstChild("PlayerGui"):FindFirstChild("CameraShake") then
					local QuakeScript = script:WaitForChild("CameraShake"):Clone()
					QuakeScript.Parent = player:FindFirstChild("PlayerGui")
					QuakeScript.Disabled = false
					Services.Debris:AddItem(QuakeScript, 6)
				end
				if not Hum.Parent:FindFirstChild("TripScript") then
					local TripScript = script:WaitForChild("TripScript"):Clone()
					TripScript.Parent = Hum.Parent
					TripScript.Disabled = false
					Services.Debris:AddItem(TripScript, 6)
				end
			end
		end
	end
end

coroutine.wrap(function()
	for i = 1, 20,.5 do 
		sw.Mesh.Scale = sw.Mesh.Scale + Vector3.new(1, 1, 1)*SizeInc
		sw2.Mesh.Scale = sw2.Mesh.Scale + Vector3.new(1, 1, 1)*SizeInc
		local Neg,Pos = Center - Vector3.new(1,1,1) * sw.Mesh.Scale * 5.5, Center + Vector3.new(1,1,1) * sw.Mesh.Scale * 5.5
		local Region = Region3.new(Neg,Pos)
		local CapHumanoids = {}
		--[[local HitBox = Create("Part"){
				CanCollide = false,
				Transparency = 0.5,
				Position = Center,
				Size = Vector3.new(1,1,1)*(sw.Mesh.Scale*5.5),
				Anchored = true,
				Color = Color3.fromRGB(255,0,0),
				Shape = Enum.PartType.Ball,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = workspace
			}
		Services.Debris:AddItem(HitBox,.5)]]
		for _,part in pairs(workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Character},500)) do
			if part and part.Parent and (part.Position-Center).Magnitude <= (sw.Mesh.Scale.X*5.5)/2 then
				local Hum,FF = part.Parent:FindFirstChildOfClass("Humanoid"),part.Parent:FindFirstChildOfClass("ForceField")
				if Hum and not FF and not IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(CapHumanoids,Hum) then
					CapHumanoids[#CapHumanoids+1]=Hum
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Creator)
					Hum:TakeDamage(10-((part.Position-Center).Magnitude/((sw.Mesh.Scale.X*5.5)/2)))
					local Knockback = Create("BodyVelocity"){
						MaxForce = Vector3.new(1,1,1)*math.huge,
						Velocity = (part.Position-Center).Unit * Seed:NextNumber(100,150),
						Name = "Knockback",
						Parent = part
					}
					Services.Debris:AddItem(Knockback,.1)
				end
			end
		end
		Wait(1/30)
	end
end)()

for i = 1, 20,1 do 			
	sw.RotVelocity = sw.RotVelocity * i
	sw2.RotVelocity = sw.RotVelocity * i
	Wait(.25)			
end			
		
if sw then sw:Destroy() end
if sw2 then sw2:Destroy() end

script:Destroy()