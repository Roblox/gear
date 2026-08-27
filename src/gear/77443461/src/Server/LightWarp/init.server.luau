--Cool Sword of Light transport process

local Properties = {
	TravelTime = 1,
	OrbSpread = 25
}

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

local Character = script:WaitForChild("Character").Value

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Center = Character:WaitForChild("HumanoidRootPart")

local LightEffects = script:WaitForChild("LightEffects"):GetChildren()

local TargetLocation,Range = script:WaitForChild("TargetLocation"),script:WaitForChild("Range") --Assumes this is present

local Bezier = script:WaitForChild("BezierCurves")

if not TargetLocation or not Range or not Bezier or not Center then script:Destroy() end

Range = Range.Value

TargetLocation = Center.Position + ((TargetLocation.Value + Vector3.new(0,3,0)) - Center.Position).Unit * math.clamp(((TargetLocation.Value + Vector3.new(0,3,0)) - Center.Position).Magnitude,0,Range)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService")),
	ServerStorage = (game:FindService("ServerStorage") or game:GetService("ServerStorage"))
}

Bezier = require(Bezier)

local Seed = Random.new()

local LightBall = Create("Part"){
	Locked = true,
	Anchored = true,
	CanCollide = false,
	Shape = Enum.PartType.Ball,
	Name = "Light Orb",
	Size = Vector3.new(1,1,1) * Seed:NextNumber(2,3),
	Material = Enum.Material.Neon,
	Color = Color3.fromRGB(255,255,203),
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth
}

local AttachmentA = Create("Attachment"){
	Position = Vector3.new(0,LightBall.Size.Y/2,0),
	Name = "AttachmentA",
	Parent = LightBall
}

local AttachmentB = AttachmentA:Clone()
AttachmentB.Name = "AttachmentB"
AttachmentB.Position = Vector3.new(0,-LightBall.Size.Y/2,0)
AttachmentB.Parent = AttachmentA.Parent

for i=1,#LightEffects do
	LightEffects[i].Parent = LightBall
	LightEffects[i].Enabled = true
	if LightEffects[i]:IsA("Trail") then
		LightEffects[i].Attachment0 = AttachmentA
		LightEffects[i].Attachment1 = AttachmentB
	end
end

--Begin Teleport process

--Make the character temporarily invisible & Invincible
--Make Player Camera follow one of the orbs
--(Possibly) Create sparkles splash effect
--Spawn the Character at the targeted destination

local Light_Segments = 10

local LightBallAnimations = {}

local TrackOrb,FixCam = script:WaitForChild("TrackOrb"),script:WaitForChild("FixCam")

local AffectedParts = {}
local Parts = Character:GetDescendants()
for i=1,#Parts do
	if Parts[i]:IsA("BasePart") then
		AffectedParts[#AffectedParts+1] = {Part = Parts[i], Transparency = Parts[i].Transparency,CanCollide = Parts[i].CanCollide,Anchored = Parts[i].Anchored}
		Parts[i].CanCollide = false
		Parts[i].Transparency = 1
		Parts[i].Anchored = true
	end
end

local ForceFieldExists = Character:FindFirstChildOfClass("ForceField")
local ForceField

if ForceFieldExists then
	ForceFieldExists.Visible = false
end

if not ForceFieldExists then -- give invincibility when travelling
	ForceField = Create("ForceField"){
		Name = "Invincibility",
		Visible = false,
		Parent = Character
	}
end

local HeldTool = Character:FindFirstChildOfClass("Tool")
if HeldTool then
	Humanoid:UnequipTools()
end

--Character.Parent = Services.ServerStorage

for Angle = 0, 360,(360/(Light_Segments-1)) do --Create LightBall
	local LightClone = LightBall:Clone()
	LightClone.CFrame = (Center.CFrame * CFrame.Angles(math.rad(90),math.rad(Angle),0)) * CFrame.new(0,0,1)
	LightBallAnimations[#LightBallAnimations+1] = {Start = Center.CFrame, Control = Center.CFrame:lerp((CFrame.new(TargetLocation)*(Center.CFrame-Center.CFrame.p)),.5)*CFrame.new(Seed:NextNumber(-Properties.OrbSpread,Properties.OrbSpread),Seed:NextNumber(-Properties.OrbSpread,Properties.OrbSpread),Seed:NextNumber(-Properties.OrbSpread,Properties.OrbSpread)), End = CFrame.new(TargetLocation)*(Center.CFrame-Center.CFrame.p), Object = LightClone}
	LightClone.Parent = workspace
end

local TrackedOrb = Create("ObjectValue"){
	Name = "TrackedOrb",
	Value = LightBallAnimations[1].Object,
	Parent = TrackOrb
}

--local DisableBackpack = script:WaitForChild("DisableBackpack")
if Services.Players:GetPlayerFromCharacter(Character) and Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui") then
	TrackOrb.Parent = Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui")
	TrackOrb.Disabled = false
	
	--DisableBackpack.Parent = Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui")
	--DisableBackpack.Disabled = false
end

local UnequipLoop

UnequipLoop = Character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and Services.Players:GetPlayerFromCharacter(Character) and Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("Backpack") then
		--Humanoid:UnequipTools()
		Services.RunService.Stepped:Wait() --Wait at least 1 frame or that warning will occur
		child.Parent = Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("Backpack")
	end
end)

local floor = math.floor
for i=0,floor(60*(Properties.TravelTime)),1 do
	local Precentage = (i/(60*Properties.TravelTime))*100
	for t=1,#LightBallAnimations,1 do
		Bezier.Quadratic(Precentage,LightBallAnimations[t].Start,LightBallAnimations[t].Control,LightBallAnimations[t].End,LightBallAnimations[t].Object,"CFrame")
	end
	Services.RunService.Heartbeat:Wait()
end

for t=1,#LightBallAnimations,1 do
	if LightBallAnimations[t].Object then
		if LightBallAnimations[t].Object:FindFirstChildOfClass("ParticleEmitter") then
			LightBallAnimations[t].Object:FindFirstChildOfClass("ParticleEmitter").Enabled = false
		end
		LightBallAnimations[t].Object.Size = Vector3.new(1,1,1)*0
		LightBallAnimations[t].Object.Transparency = 1
		Services.Debris:AddItem(LightBallAnimations[t].Object,2)
	end
end

--[[local EnableBackpack = script:WaitForChild("EnableBackpack")
if Services.Players:GetPlayerFromCharacter(Character) and Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui") then
	EnableBackpack.Parent = Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui")
	EnableBackpack.Disabled = false
	Services.Debris:AddItem(EnableBackpack,1)
end]]

if UnequipLoop then UnequipLoop:Disconnect();UnequipLoop = nil end

if Humanoid then
	Humanoid.Health = Humanoid.Health + 15
end

Character:SetPrimaryPartCFrame(CFrame.new(TargetLocation)*(Center.CFrame-Center.CFrame.p))

for i=1,#AffectedParts do
	for property, value in pairs(AffectedParts[i]) do
		if property ~= "Part" then
			AffectedParts[i].Part[property] = value
		end
	end
end

if ForceField then
	ForceField:Destroy()
end

if HeldTool then
	Humanoid:EquipTool(HeldTool)
end

if Services.Players:GetPlayerFromCharacter(Character) and Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui") then
	FixCam.Parent = Services.Players:GetPlayerFromCharacter(Character):FindFirstChild("PlayerGui")
	FixCam.Disabled = false
end

--DisableBackpack:Destroy()
Services.Debris:AddItem(TrackOrb,1)
Services.Debris:AddItem(FixCam,2)
script:Destroy()
