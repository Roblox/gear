--Rescripted by TakeoHonorable
--Revamped Periastrons: The Periastron of Easter Eagerness (Joyful)

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


local Seed = Random.new(tick())

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",10)

local PointLight = Handle:WaitForChild("PointLight",10)

local Sparkles = Handle:FindFirstChildOfClass("Sparkles")

local Animations = Tool:WaitForChild("Animations",10)

local Deletables = {} --Send all deletables here

local Sounds = {
	LungeSound = Handle:WaitForChild("LungeSound",10),
	SlashSound = Handle:WaitForChild("SlashSound",10),
	Plop = Handle:WaitForChild("Plop",10),
	EggSpawn = Handle:WaitForChild("EggSpawn",10)
}

local AttackAnims

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService"))
}

local Components = {
	PeriSparkle = Handle:WaitForChild("Particle",10):GetChildren(),
	--PeriTrail = Handle:WaitForChild("Trail",10),
	MouseInput = Tool:WaitForChild("MouseInput",10)
}
--Components.PeriSparkle.Enabled = true
--Components.PeriTrail.Enabled = false
PointLight.Enabled = true


local Player,Character,Humanoid,Root,Torso


EggModel = Services.InsertService:LoadAsset(232678528)
Egg = EggModel:GetChildren()[1]:Clone()



local Properties = {
	BaseDamage = 27,
	SpecialCooldown = 40,
	BaseUrl = "rbxassetid://"
}

local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local Grips = {
	Normal = Tool:WaitForChild("NormalGrip").Value,
	--BackR6 = Tool:WaitForChild("BackGrip").Value,
	--BackR15 = Tool:WaitForChild("BackGrip").Value+Vector3.new(-.7,0,-.7)
}
Tool.Grip = Grips.Normal

local RandomEgg = Create("Part"){
	Anchored = false,
	CanCollide = true,
	Locked = true,
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1,1,1)*2,
	Color = Color3.new(1,1,1),
	Material = Enum.Material.SmoothPlastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
}
local RandomEggMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = Properties.BaseUrl.."76608021",
	TextureId = Properties.BaseUrl.."2603226228",
	Scale = Vector3.new(1,1,1)*1,
	Parent = RandomEgg
}

function RayCast(Pos, Dir, Max, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
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


local function IsPeriSparkling()
	for _,particle in pairs(Components.PeriSparkle) do
		if particle:IsA("ParticleEmitter") and particle.Enabled then
			return true
		end
	end
	return false
end

local function UpdateSparkles(verdict)
	for _,particle in pairs(Components.PeriSparkle) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = verdict
		end
	end
	if not verdict then
		delay(Properties.SpecialCooldown,function()
			for _,particle in pairs(Components.PeriSparkle) do
				if particle:IsA("ParticleEmitter") then
					particle.Enabled = true
				end
			end
		end)	
	end
end

UpdateSparkles(true)

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



local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--print("Lunge")
		Sounds.LungeSound:Play()
		--Components.PeriTrail.Enabled = true
		local MousePosition = Components.MouseInput:InvokeClient(Player)
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		--[[delay(.5,function()
			Components.PeriTrail.Enabled = false
		end)]]
		Root.CFrame = CFrame.new(Root.CFrame.p,Root.CFrame.p+Direction.lookVector)
		wait(1.5)
	else
		local SwingAnims = {AttackAnims.Slash,AttackAnims.SlashAnim,AttackAnims.RightSlash}
		local AttackAnim = SwingAnims[Seed:NextInteger(1,#SwingAnims)]
		spawn(function()
			if AttackAnim ~= AttackAnims.SlashAnim then
				Sounds.SlashSound:Play()
				else
				Sounds.SlashSound:Play()
				wait(.5)
				Sounds.SlashSound:Play()
			end	
		end)

		AttackAnim:Play()
	--wait(.4)
	end
	LastTime = CurrentTime
	Tool.Enabled = true
end

local Touch
local Debounce = false
local PassiveConnection

function Equipped(Mouse)
	Character = Tool.Parent
	Root = Character:FindFirstChild("HumanoidRootPart")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Humanoid.JumpPower = 100
	Humanoid.WalkSpeed = 32
	AttackAnims = {
		Slash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("Slash",10),
		RightSlash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("RightSlash",10),
		SlashAnim = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("SlashAnim",10),
	}
	
	for i,v in pairs(AttackAnims) do
		AttackAnims[i] = Humanoid:LoadAnimation(v)
	end
	
	Touch = Handle.Touched:Connect(function(hit)
		Damage(hit,Properties.BaseDamage,false)
	end)
	
end


function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
	for _,delete in pairs(Deletables) do
		if delete then
			delete:Destroy()
		end
	end
	Humanoid.JumpPower = 50
	Humanoid.WalkSpeed = 16
	Deletables = {}
end



local HitHumanoids = {}
function Damage(hit,TotalDamage)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <=0 or Hum == Humanoid or ForceField then return end
	
	if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	
	--spawn(function()
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)

	
	local CanBeEgged = false
	
	
	if (Hum.Health/Hum.MaxHealth)*100 <= 30 and not hit.Anchored then -- if health is or below at 30%
		CanBeEgged = true
	end
	
	local EggScript = script:FindFirstChild("EggScript")
	
	if CanBeEgged then
		local character = Hum.Parent

		local EggScriptClone = character:FindFirstChild(EggScript.Name)
		if EggScriptClone then
			return
		end
		Sounds.Plop:Play()
		Hum.MaxHealth = 9000
		Hum.Health = Hum.MaxHealth
		EggScriptClone = EggScript:Clone()
		EggScriptClone.Disabled = false
		local head = character:FindFirstChild("Head")
		if head then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("Accessory") then
					local handle = v:FindFirstChild("Handle")
					if handle then
						local HandleClone = handle:Clone()
						HandleClone.Name = "Accessory"
						HandleClone.CanCollide = false
						local HatWeld = Instance.new("Motor6D")
						HatWeld.Part0 = head
						HatWeld.Part1 = HandleClone
						HatWeld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						HatWeld.C1 = v.AttachmentPoint
						HatWeld.Parent = HandleClone
						HandleClone.Parent = character
					end
					v:Destroy()
				end
			end
		end
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if torso then
			Hum:UnequipTools()
			for i, v in pairs(Hum:GetChildren()) do
				if v:IsA("Animator") then
					v:Destroy()
				end
			end
			for i, v in pairs(torso:GetChildren()) do
				if v:IsA("Motor") then
					v.MaxVelocity = 0
					v.DesiredAngle = 0
					v.CurrentAngle = 0
				end
			end
			local Size = character:GetModelSize()
			local Position = character:GetModelCFrame()
			Size = {Size.X, Size.Y, Size.Z}
			table.sort(Size, (function(a, b)
				return a > b
			end))
			local EggSize = (Size[1] * 1.45)
			EggSize = Vector3.new((EggSize - 2), EggSize, (EggSize - 2))
			local EggClone = Egg:Clone()
			EggClone.Size = EggSize
			EggClone.Anchored = true
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.Parent = EggClone
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.maxForce = Vector3.new(math.huge, 0, math.huge)
			BodyPosition.position = Position.p
			BodyPosition.Parent = EggClone
			EggClone.CFrame = Position
			local Weld = Instance.new("Motor6D")
			Weld.Name = "Weld"
			Weld.Part0 = torso
			Weld.Part1 = EggClone
			Weld.C0 = Position:inverse()
			Weld.C1 = EggClone.CFrame:inverse()
			Weld.Parent = EggClone
			local EggValue = Instance.new("ObjectValue")
			EggValue.Name = "Egg"
			EggValue.Value = EggClone
			EggValue.Parent = EggScriptClone
			EggScriptClone.Parent = character
			EggClone.Parent = character
			EggClone.CFrame = (EggClone.CFrame + CFrame.new(Root.Position, Vector3.new(EggClone.Position.X, Root.Position.Y, EggClone.Position.Z)).lookVector * ((EggSize.X / 2) + 1))
		end
	else
		HitHumanoids[#HitHumanoids+1]=Hum
		Hum:TakeDamage(TotalDamage)
	end
	
		--wait(.5)
	--end)
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)



function SpawnRandomEggs()
	if not IsPeriSparkling() then return end
	
	UpdateSparkles(false)
	
	local EggCount = 10
	for i=1,EggCount do
		local RNGEgg = RandomEgg:Clone()
	
		local RNGEggScript = script:WaitForChild("RandomEgg",5):Clone()
		RNGEggScript.Parent = RNGEgg
		
		local CreatorTag = Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
			Parent = RNGEggScript
		}
		
		RNGEgg.CFrame = (Root.CFrame * CFrame.Angles(math.rad(0),i*math.rad(360/EggCount),math.rad(0))) * CFrame.new(0,5,0)
		
		
		RNGEgg.Anchored = false
		RNGEgg.Velocity = (Root.CFrame * CFrame.Angles(math.rad(0),i*math.rad(360/EggCount),math.rad(0))).lookVector * 10 + Vector3.new(0,50,0)
		
		RNGEgg.Parent = workspace
		RNGEgg:SetNetworkOwner(nil)
		RNGEggScript.Disabled = false
	end
	Sounds.EggSpawn:Play()
	
	
	
end



Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q then
		if IsPeriSparkling() then
			SpawnRandomEggs()
		end
	elseif Key == Enum.KeyCode.E then
		
	end	
end)
