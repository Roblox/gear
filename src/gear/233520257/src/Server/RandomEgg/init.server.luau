local Egg = script.Parent



local Creator = script:WaitForChild("Creator",5)

local Particle = script:WaitForChild("Question",5)

local EggMesh = Egg:FindFirstChildOfClass("SpecialMesh")

local Touch

local stamp = tick()

local Seed = Random.new(stamp)

local RandomActions = {}

local Sounds = {
	Splatter = script:WaitForChild("Splatter",5),
	Explosion = script:WaitForChild("Explosion",5),
	Beep = script:WaitForChild("Beep",5),
	Copy = script:WaitForChild("Copy",5)
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService"))
}

for _,sounds in pairs(Sounds) do
	sounds.Parent = Egg
end

local YolkScript = script:WaitForChild("YolkScript",5)

local EggSplatModel = Services.InsertService:LoadAsset(228153674)

local EggSplat = EggSplatModel:GetChildren()[1]:Clone()

EggSplat.Size = EggSplat.Size * 3

YolkScript.Parent = EggSplat


if EggSplatModel and EggSplatModel.Parent then
	Services.Debris:AddItem(EggSplatModel, 1)
end

EggSplat.Anchored = false

local function GetGrabbableTools(Directory)
	local Tools = {}
	for _,tools in pairs(Directory:GetChildren()) do
		if tools:IsA("Tool") and tools.RequiresHandle and tools:FindFirstChild("Handle") and tools.Name ~= "JoyfulPeriastron" then
			Tools[#Tools+1] = tools
		end
	end
	return Tools
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

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end



RandomActions[1] = function()
	--print("Egg Yolk")
	Sounds.Splatter:Play()
	EggSplat.CFrame = CFrame.new(Egg.CFrame.p)
	EggSplat.Parent = workspace
	YolkScript.Disabled = false
end

RandomActions[2] = function(PartTouched)
	--print("Explosion")
	--Egg.Anchored = true
	Egg.CanCollide = false
	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = PartTouched
	Weld.Part1 = Egg
	Weld.Parent = Egg
	Egg.Parent = PartTouched.Parent
	
	for i=0,10,1 do
		EggMesh.VertexColor = ((EggMesh.VertexColor == Vector3.new(1,0,0) and Vector3.new(1,1,1)) or Vector3.new(1,0,0)) 
		if EggMesh.VertexColor == Vector3.new(1,0,0) then
			Sounds.Beep:Play()
		end
		
		wait(.1)
	end
	
	EggMesh.VertexColor = Vector3.new(1,1,1)
	
	local Explosion = Instance.new("Explosion")
	Explosion.DestroyJointRadiusPercent = 0
	Explosion.BlastPressure = 10^5.8
	Explosion.BlastRadius = 10
	Explosion.ExplosionType = Enum.ExplosionType.NoCraters
	Explosion.Position = Egg.Position
	Explosion.Parent = workspace
	
	Sounds.Explosion:Play()
	
	local HitHumanoids = {}
	Explosion.Hit:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not Hum or IsInTable(HitHumanoids,Hum) or Hum.Health <= 0 or (Hum == (Creator.Value.Character and Creator.Value.Character:FindFirstChildOfClass("Humanoid") or nil)) or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		HitHumanoids[#HitHumanoids+1] = Hum
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Creator.Value)
		Hum:TakeDamage(100)
	end)
end

RandomActions[3] = function()
	--print("RandomGear Drop")
	
	if not Creator.Value:IsA("Player") then return end
	
	local Backpack = Creator.Value:WaitForChild("Backpack",5)
	
	if not Backpack then return end
	
	local GearTable = GetGrabbableTools(Backpack)
	
	if not GearTable or #GearTable <= 0 then  return end
	
	local GearClone = GearTable[Seed:NextInteger(1,#GearTable)]:Clone()
	
	local Model = Instance.new("Model")
	GearClone.Parent = Model
	Model.PrimaryPart = GearClone:WaitForChild("Handle",5)
	Model.PrimaryPart.CanCollide = true
	Model:SetPrimaryPartCFrame(Egg.CFrame)
	GearClone.Parent = workspace
	Model:Destroy()
	
	Sounds.Copy:Play()
end



local SplatterSound = script:FindFirstChildOfClass("Sound")
if SplatterSound then
	SplatterSound.Parent = Egg
end

Touch = Egg.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	
	local Directory = hit.Parent--((hit.Parent:IsA("Accessory") and hit.Parent.Parent) or hit.Parent)
	
	local Humanoid = Directory:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then return end
	
	Touch:Disconnect()
	
	Particle.Enabled = false
	
	Seed = Random.new(tick()*stamp)
	
	RandomActions[Seed:NextInteger(1,#RandomActions)](hit)
	
	if EggMesh then
		EggMesh.MeshId = "rbxassetid://139110864"
	end
	
	--Egg.Anchored = true
	local PrevCFrame = Egg.CFrame
	Egg.Shape = Enum.PartType.Block
	Egg.CFrame = PrevCFrame
	
	--Egg.CanCollide = false
	
end)

Particle.Parent = Egg
Particle.Enabled = true

delay(15,function()
	Egg:Destroy()
end)
