local Self = script

local world = workspace

local Target,Duration = Self:FindFirstChild("Target"),Self:FindFirstChild("Duration")


if not Target or not Duration then Self:Destroy() end

local Instant,Type,Vec3,random,cframe,Angles,Wait,rad,huge = Instance.new,type,Vector3.new,math.random,CFrame.new,CFrame.Angles,wait,math.rad,math.huge

local Pcall,Wrap,SmoothSurface = pcall,coroutine.wrap,Enum.SurfaceType.Smooth

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}


function Create(ty)
	return function(data)
		local obj = Instant(ty)
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
	local Creator_Tag = Instant("ObjectValue")
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


Target = Target.Value
Duration = Duration.Value

local Torso = Target:FindFirstChild("HumanoidRootPart")
local Humanoid = Target:FindFirstChildOfClass("Humanoid")

if not Torso or not Humanoid then Self:Destroy() end



local Invincibility = Create("ForceField"){
	Visible = false,
	Parent = Target
}

local PoofSmoke = Self:WaitForChild("PoofSmoke")
PoofSmoke.Parent = Torso
local PoofSound = Self:WaitForChild("PoofSound")
PoofSound.Parent = Torso

Humanoid.JumpPower = 0
Humanoid.AutoRotate = false
Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

function Damage(hit,Damage)	
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or FF or Hum == Humanoid or IsTeamMate(Services.Players:GetPlayerFromCharacter(Target),Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Services.Players:GetPlayerFromCharacter(Target))
	Hum:TakeDamage(Damage)
end


if Services.Players:GetPlayerFromCharacter(Target) then
	local Disable = Self:WaitForChild("DisableBackpack")
	Disable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Disable.Disabled = false
	Services.Debris:AddItem(Disable,1)
	Services.Players:GetPlayerFromCharacter(Target).CharacterRemoving:Connect(function(Char)--keeps people from a hidden inventory
		local Enable = Self:WaitForChild("EnableBackpack")
		Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
		Enable.Disabled = false
		Services.Debris:AddItem(Enable,1)
	end)
end

Humanoid:UnequipTools()

local Deletables = {}
Deletables[#Deletables+1] = Invincibility


local meshes = {63693995, 63694839, 63694853}

local Sounds = {
	Self:WaitForChild("Squeak1"),
	Self:WaitForChild("Squeak2"),
	Self:WaitForChild("Squeak3")
}


local Offset = {Vec3(0,0,0),Vec3(0, 0, -0.31),Vec3(0, 0, 0.2)}

--[[local bat = Create("Part"){
	Size = Vec3(0.6, 0.6, 0.6),
	CanCollide = true,
	Anchored = false,
	CastShadow = true,
	Locked = true,
	Transparency = 0.0,
	Name = "Bat"
}]]

local batMesh = Create("SpecialMesh"){
	MeshId = "http://www.roblox.com/asset/?id=63693995", -- front, 63694839  --back, 63694853  
	TextureId = "http://www.roblox.com/asset/?id=63694777",
	Scale = Vec3(1, 1, 1) * 4,
	Parent = Torso
}
Deletables[#Deletables+1] = batMesh

local Gyro = Create("BodyGyro"){
	MaxTorque = Vec3(1,1,1)*huge,
	D = 100,
	P = 10^5,
	CFrame = Torso.CFrame,
	Parent = Torso
}
Deletables[#Deletables+1] = Gyro
local Velo = Create("BodyVelocity"){
	MaxForce = Vec3(1,1,1)*huge,
	Velocity = Vec3(0,0,0),
	Parent = Torso
}
Deletables[#Deletables+1] = Velo

local Parts = Target:GetDescendants()

for i=1,#Parts do
	if Parts[i] and Parts[i] ~= Torso then
		Pcall(function()
			Parts[i].Transparency = 1
		end)
	end
end

Torso.Transparency = 0

PoofSound:Play()
PoofSmoke:Emit(PoofSmoke.Rate)


local MiniBats = {}
local Stop = false
MiniBats[#MiniBats+1] = PoofSound
MiniBats[#MiniBats+1] = PoofSmoke

for i=1,#Sounds do
	Sounds[i].Parent = Torso
	MiniBats[#MiniBats+1] = Sounds[i]
end

Wrap(function()
	repeat
		for i=1,#Sounds do
			if Sounds[i] then
				Sounds[i]:Play();Sounds[i].Ended:Wait()
				Wait(random(.1,.5))	
			end
		end
	until Stop
end)()

Wrap(function()
	for i=1,10,1 do
		--print("Creating minibat#.."..i)
		local MiniBat = Create("Part"){
			Locked = true,
			CanCollide = false,
			Anchored = false,
			Size = Vec3(2,2,2),
			TopSurface = SmoothSurface,
			Name = "MiniBat",
			BottomSurface = SmoothSurface,
			CFrame = Torso.CFrame,
			--Parent = world
		}
		MiniBats[#MiniBats+1] = MiniBat
		--Deletables[#Deletables+1] = MiniBat
		local BatMesh = batMesh:Clone()
		BatMesh.Parent = MiniBat
		BatMesh.Scale = Vec3(1,1,1)*1.5
		
		local BatVelo = Velo:Clone()
		BatVelo.Velocity = Vec3(0,0,0)
		BatVelo.Parent = MiniBat
		MiniBat.Parent = world
		if MiniBat:CanSetNetworkOwnership() then
			MiniBat:SetNetworkOwner(nil)
		end
		
		MiniBat.Touched:Connect(function(hit)
			Damage(hit,5)
		end)
		Services.RunService.Heartbeat:Wait()
		--print(MiniBat.Parent)
		Wrap(function()
			repeat
				for i=1,#meshes do
					if BatMesh and BatMesh.Parent then
						BatMesh.MeshId = "http://www.roblox.com/asset/?id="..meshes[i]
						BatMesh.Offset = Offset[i]
						Wait(1/15)
					end
				end
				Services.RunService.Heartbeat:Wait()
			until not BatMesh or not BatMesh.Parent
		end)()
	
		Wrap(function()
			repeat
				if MiniBat and Torso then
					BatVelo.Velocity = cframe(MiniBat.Position,Torso.Position + Vec3(random(-5,5),random(-5,5),random(-5,5))).LookVector * 45--(Torso.Position-MiniBat.Position).Unit * 50
					MiniBat.RotVelocity = Vec3(random(-5,5),random(-5,5),random(-5,5))
				end
				Wait(.5)
			until not MiniBat or not Torso or Stop
		end)()
	end
	
	Wrap(function()
		repeat
			for i=1,#meshes do
				if batMesh and batMesh.Parent then
					batMesh.MeshId = "http://www.roblox.com/asset/?id="..meshes[i]
					batMesh.Offset = Offset[i]
					Wait(1/15)
				end
			end
			Services.RunService.Heartbeat:Wait()
		until not batMesh or not batMesh.Parent
	end)()
end)()
local Controls = Self:WaitForChild("BatControls")

Create("ObjectValue"){
	Name = "Velo",
	Value = Velo,
	Parent = Controls
}
Create("ObjectValue"){
	Name = "Gyro",
	Value = Gyro,
	Parent = Controls
}

Controls.Parent = Target

Controls.Disabled = false
Deletables[#Deletables+1] = Controls

Torso.Touched:Connect(function(hit)
	Damage(hit,10)
end)

--Wait(Duration)
local Current_Time = 0

local FindTool = Target.FindFirstChildOfClass

repeat
	Current_Time = Current_Time + Services.RunService.Heartbeat:Wait()
until Current_Time >= Duration or FindTool(Target,"Tool")

if Services.Players:GetPlayerFromCharacter(Target) then	
	local Enable = Self:WaitForChild("EnableBackpack")
	Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Enable.Disabled = false
	Services.Debris:AddItem(Enable,1)
end

for i=1,#Parts do
	if Parts[i] and Parts[i].Name ~= "HumanoidRootPart" then
		Pcall(function()
			Parts[i].Transparency = 0
		end)
	end
end

Torso.Transparency = 1

for i=1,#Deletables do
	if Deletables[i] then
		Deletables[i]:Destroy()
	end
end
Deletables = {}

Humanoid.JumpPower = 50
Humanoid.AutoRotate = true
Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
PoofSound:Play()
PoofSmoke:Emit(PoofSmoke.Rate)
--Humanoid.WalkSpeed = 16
Stop = true
for i=1,#MiniBats do
	if MiniBats[i] and Torso then
		if MiniBats[i]:FindFirstChildOfClass("BodyVelocity") then
			MiniBats[i].CFrame = Torso.CFrame * Angles(rad(random(1,360)),rad(random(1,360)),rad(random(1,360)))
			MiniBats[i]:FindFirstChildOfClass("BodyVelocity").Velocity = cframe(Torso.Position,Torso.Position + Vec3(random(-1,1),random(-1,1),random(-1,1))).lookVector * 75
		end
		Services.Debris:AddItem(MiniBats[i],5)
	end
end
Wait(6)
Self:Destroy()

