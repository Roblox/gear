--Rescripted by TakeoHonorable
--Revamped Periastrons: The Periastron of Holly Jolly (Festive)

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
	Jingle = Handle:WaitForChild("Jingle",10),
}

local AttackAnims

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting"))
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

local Properties = {
	BaseDamage = 27,
	SpecialCooldown = 60,
	OrnamentDuration = 20,
	OrnamentScaleRadius = 18.36,
	BaseUrl = "rbxassetid://"
}

local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local Grips = {
	Normal = Tool:WaitForChild("NormalGrip").Value,
	--BackR6 = Tool:WaitForChild("BackGrip").Value,
	--BackR15 = Tool:WaitForChild("BackGrip").Value+Vector3.new(-.7,0,-.7)
}
Tool.Grip = Grips.Normal

local SnowFlakeBase = Create("Part"){
	Anchored = false,
	Locked = true,
	CanCollide = false,
	Size = Vector3.new(0.9, 0.2, 0.9),
	Material = Enum.Material.Plastic,
	Name = "Snowflake",
}

local SnowFlakeMeshBase = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	Scale = Vector3.new(2,2,2),
}

local SnowFlake1,SnowFlake2,SnowFlake3 = SnowFlakeBase:Clone(), SnowFlakeBase:Clone(), SnowFlakeBase:Clone()

local SnowFlake1Mesh = SnowFlakeMeshBase:Clone();SnowFlake1Mesh.MeshId = Properties.BaseUrl .. "187687175";SnowFlake1Mesh.TextureId = Properties.BaseUrl .. "187687219";SnowFlake1Mesh.Parent = SnowFlake1
local SnowFlake2Mesh = SnowFlakeMeshBase:Clone();SnowFlake2Mesh.MeshId = Properties.BaseUrl .. "187687161";SnowFlake2Mesh.TextureId = Properties.BaseUrl .. "187687219";SnowFlake2Mesh.Parent = SnowFlake2
local SnowFlake3Mesh = SnowFlakeMeshBase:Clone();SnowFlake3Mesh.MeshId = Properties.BaseUrl .. "187687193";SnowFlake3Mesh.TextureId = Properties.BaseUrl .. "187687219";SnowFlake3Mesh.Parent = SnowFlake3



local SnowBank = {SnowFlake1,SnowFlake2,SnowFlake3}

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
	
	wait(1)
	
	if Tool:IsDescendantOf(Character) then
		Sounds.Jingle:Play()
	end

	PassiveConnection = Services.RunService.Heartbeat:Connect(function()
		if not Player or Debounce or not Tool:IsDescendantOf(Character) then return end
		Debounce = true
		for i=1,15,1 do
			local Scale = Seed:NextNumber(1,3)
			local Snow = SnowBank[Seed:NextInteger(1,#SnowBank)]:Clone();Snow.Size = Snow.Size * Scale
			local SnowMesh = Snow:FindFirstChildOfClass("SpecialMesh");SnowMesh.Scale = SnowMesh.Scale * Scale
			Snow.CFrame = Root.CFrame + Vector3.new(Seed:NextInteger(-60,60),Seed:NextInteger(40,60),Seed:NextInteger(-60,60))
			local BodyForce = Instance.new("BodyForce")
			BodyForce.Force = Vector3.new(0,(Snow:GetMass()*workspace.Gravity)*.95,0);BodyForce.Parent = Snow
			Snow.RotVelocity = Vector3.new(Seed:NextInteger(0,10),Seed:NextInteger(0,10),Seed:NextInteger(0,10))
			Snow.Velocity = Snow.Velocity + Vector3.new(Seed:NextInteger(-20,20),0,Seed:NextInteger(-20,20))
			Snow.Parent = workspace
			Services.Debris:AddItem(Snow,60)
			--Snow:SetNetworkOwner(nil)
			Snow:SetNetworkOwner(Player)
			Snow.Touched:Connect(function(hit)
				if not hit or not hit.Parent then return end
				local Directory = hit.Parent
				if hit:FindFirstAncestorWhichIsA("Accessory") then
					Directory = hit:FindFirstAncestorWhichIsA("Accessory")
				end
				local Hum = Directory:FindFirstChildOfClass("Humanoid")
				if Hum and Hum ~= Humanoid and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
					Hum.WalkSpeed = 10
				end
				Snow:Destroy()
			end)
		end
		wait(1)
		Debounce = false
	end) -- Snow masterpiece
end


local OrnamentBall,OrnamentControl,OrnamentTouch
function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
	if PassiveConnection then PassiveConnection:Disconnect(); PassiveConnection = nil end
	if OrnamentTouch then OrnamentTouch:Disconnect();OrnamentTouch = nil end
	Humanoid.PlatformStand = false
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
	for _,delete in pairs(Deletables) do
		if delete then
			delete:Destroy()
		end
	end
	Sounds.Jingle:Stop()
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
		HitHumanoids[#HitHumanoids+1]=Hum
		Hum:TakeDamage(TotalDamage)
		--wait(.5)
	--end)
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


function OrnamentAttack()
	Tool.Enabled = false
	UpdateSparkles(false)
	
	local OrnamentSummon = script:WaitForChild("OrnamentSummon",10):Clone()
	OrnamentSummon.Parent = Character
	OrnamentSummon.Disabled = false
	
	repeat
		Services.RunService.Heartbeat:Wait()
	until not OrnamentSummon or not OrnamentSummon:IsDescendantOf(Character)
	
	Tool.Enabled = true
	wait(Properties.SpecialCooldown)
	UpdateSparkles(true)
	
end

Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q then
		if IsPeriSparkling() then
			OrnamentAttack()
		end
	elseif Key == Enum.KeyCode.E then
		
	end	
end)