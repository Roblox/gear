--Scripted by TakeoHonorable
--Kick your victim into a coffin >:3

local Target,Creator = script:FindFirstChild("Target"), script:FindFirstChild("Creator")

if not Target or not Target.Value or not Creator or not Creator.Value then script:Destroy() end

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

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	--Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
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
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}
Target, Creator,CreatorCharacter = Target.Value, Services.Players:GetPlayerFromCharacter(Creator.Value),Creator.Value
local TargetHumanoid,CreatorHumanoid = Target:FindFirstChildOfClass("Humanoid"),CreatorCharacter:FindFirstChildOfClass("Humanoid")
TargetHumanoid.BreakJointsOnDeath = false
UntagHumanoid(TargetHumanoid)
TagHumanoid(TargetHumanoid,Creator) -- So they won't call in for cheap shots C:

local CoffinModel = Services.InsertService:LoadAsset(179174097)
if CoffinModel and CoffinModel:FindFirstChild("Part",true) then -- Removes the hidden watermark
	CoffinModel:FindFirstChild("Part",true):Destroy()
end

if not CoffinModel then script:Destroy() end

local Invincibility = Create("ForceField"){
	Visible = false,
	Parent = CreatorHumanoid.Parent
}
Services.Debris:AddItem(Invincibility,7)--Safety Catch

local Coffin = CoffinModel:WaitForChild("Coffin")

local PoofSmoke = script:WaitForChild("PoofSmoke")

local SummonSound = script:FindFirstChild("Summon")

Coffin.PrimaryPart = Coffin:WaitForChild("CoffinBottom")
PoofSmoke.Parent = Coffin.PrimaryPart
--Coffin:SetPrimaryPartCFrame((Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso") or Target:FindFirstChild("UpperTorso")).CFrame)
local CreatorTorso = (CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso"))
CreatorTorso.Anchored = true
local TargetTorso = (Target:FindFirstChild("Torso") or Target:FindFirstChild("UpperTorso"))
local Size = Target:GetExtentsSize()
local X,Y,Z = Size.X,Size.Y,Size.Z
local Scale = math.max(X,Y,Z) / 5

Coffin.PrimaryPart.Size = Coffin.PrimaryPart.Size * Scale
Coffin:WaitForChild("CoffinCover"):WaitForChild("CoffinTop").Size = Coffin:WaitForChild("CoffinCover"):WaitForChild("CoffinTop").Size * Scale

Coffin:SetPrimaryPartCFrame(CreatorTorso.CFrame*CFrame.new(0,TargetTorso.Size.Y*.7,-20*Scale))

Coffin:WaitForChild("CoffinCover"):WaitForChild("CoffinTop").CFrame = Coffin.PrimaryPart.CFrame*CFrame.Angles(math.rad(90),0,math.rad(-90))*CFrame.new(-4*Scale,3*Scale,0)

local FinishScript = script:WaitForChild("Finish")
Create("ObjectValue"){
	Name = "Target",
	Value = TargetHumanoid.Parent,
	Parent = FinishScript
}
FinishScript.Parent = Services.ServerScriptService
FinishScript.Disabled = false

Coffin.Parent = workspace

if SummonSound then
	SummonSound.Parent = Coffin.PrimaryPart
	SummonSound:Play()
end

PoofSmoke:Emit(100*Scale)

CoffinModel:Destroy() -- We don't need this anymore

TargetTorso.Anchored = true
TargetTorso.CFrame = CFrame.new((CreatorTorso.CFrame*CFrame.new(0,0,-3*Scale)).p, CreatorTorso.CFrame.p)


CreatorTorso.CFrame = CFrame.new(CreatorTorso.Position, TargetTorso.Position)

coroutine.wrap(function()
	CreatorTorso.Anchored = false
	CreatorTorso.CFrame = CFrame.new(CreatorTorso.Position, TargetTorso.Position)
	CreatorTorso.Anchored = true
	Services.RunService.Heartbeat:Wait()
end)()

wait(2)

local KickAnim = CreatorHumanoid:LoadAnimation(script:FindFirstChild("Kick"..CreatorHumanoid.RigType.Name))

KickAnim:Play(nil,nil,8)

--wait(1)

local KickSound,Scream,Slam = script:FindFirstChild("KickSound"),script:FindFirstChild("Scream"),script:FindFirstChild("Slam")
if KickSound then
	KickSound.Parent = Coffin.PrimaryPart
	KickSound:Play()
end

if Scream then
	Scream.Parent = Coffin.PrimaryPart
	Scream:Play()
end

TargetTorso.Anchored = false
if TargetTorso:CanSetNetworkOwnership() then
	TargetTorso:SetNetworkOwner(nil)
end

local Velo
local function Attach(hit)
	if --[[not hit or not hit.Parent or]] not hit:IsDescendantOf(Target) then return end
	if TargetTorso then
		TargetTorso.CFrame = Coffin.PrimaryPart.CFrame*CFrame.Angles(0,math.rad(180),0)
		TargetTorso.Anchored = false
		weldBetween(TargetTorso,Coffin.PrimaryPart)
		if Velo then Velo:Destroy() end
	end
	wait(.5)
	Coffin:WaitForChild("CoffinCover"):WaitForChild("CoffinTop").CFrame = Coffin.PrimaryPart.CFrame*CFrame.Angles(math.rad(90),0,0)*CFrame.new(0,1.3,0)
	weldBetween(Coffin.PrimaryPart,Coffin:WaitForChild("CoffinCover"):WaitForChild("CoffinTop"))
	
	if Slam and Slam.Parent ~= Coffin.PrimaryPart then
		Slam.Parent = Coffin.PrimaryPart
		Slam:Play()
	end
	
	for _,part in pairs(Coffin:GetDescendants()) do
		if part and part:IsA("BasePart") then
			part.Anchored = false
			if part:CanSetNetworkOwnership() then
				part:SetNetworkOwner(nil)
			end
		end
	end
	Coffin.PrimaryPart.RotVelocity = Coffin.PrimaryPart.CFrame:vectorToWorldSpace(Vector3.new(math.random(-15,-10),0,0)) --Tip the coffin over
end
Coffin.PrimaryPart.Touched:Connect(function(hit)
	Attach(hit)
end)


Velo = Create("BodyVelocity"){
	MaxForce = Vector3.new(1,1,1)*math.huge,
	Velocity = (Coffin.PrimaryPart.Position-TargetTorso.Position).Unit*math.sqrt((Coffin.PrimaryPart.Position-TargetTorso.Position).Magnitude)*10,
	Parent = TargetTorso
}
--TargetTorso.Velocity = (Coffin.PrimaryPart.Position-TargetTorso.Position)*math.sqrt((Coffin.PrimaryPart.Position-TargetTorso.Position).Magnitude)



if TargetHumanoid then
	UntagHumanoid(TargetHumanoid)
	TagHumanoid(TargetHumanoid,Creator) -- So they won't call in for cheap shots C:
	TargetHumanoid.Health = 0 --FINISH THEM!!
end

wait((KickAnim and KickAnim.Length/8) or 2)



CreatorTorso.Anchored = false

delay(3,function()
	Attach(TargetTorso)--Do it anyway
	if Invincibility then Invincibility:Destroy() end
	wait(10)
	if TargetTorso and TargetTorso.Parent then -- Make sure they're cleaned up
		for _,v in pairs(TargetTorso:GetDescendants()) do
			if v and v:IsA("BasePart") then
				v:Destroy()
			end
		end
	end
	if Coffin then
		for i=0,60,1 do
			for _,v in pairs(Coffin:GetDescendants()) do
				if v and v:IsA("BasePart") then
					v.Transparency = i/60
				end
			end
			Services.RunService.Heartbeat:Wait()
		end
		if Coffin then
			Coffin:Destroy()
		end
	end
	script:Destroy()
end)










