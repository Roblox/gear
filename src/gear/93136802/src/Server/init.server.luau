--Rescripted by TakeoHonorable
--Revamped Periastrons: The Periastron of Purple Comets (Amethyst)

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
}

local AttackAnims

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Components = {
	PeriSparkle = Handle:WaitForChild("Sparkles",10),
	PeriTrail = Handle:WaitForChild("Trail",10),
	MouseInput = Tool:WaitForChild("MouseInput",10)
}
Components.PeriSparkle.Enabled = true
Components.PeriTrail.Enabled = false
PointLight.Enabled = true

local Player,Character,Humanoid,Root,Torso

local Properties = {
	BaseDamage = 27,
	SpecialCooldown = 60,
	MeteorDuration = 10,
}

local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local Grips = {
	Normal = Tool:WaitForChild("NormalGrip").Value,
	--BackR6 = Tool:WaitForChild("BackGrip").Value,
	--BackR15 = Tool:WaitForChild("BackGrip").Value+Vector3.new(-.7,0,-.7)
}
Tool.Grip = Grips.Normal

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
		Components.PeriTrail.Enabled = true
		local MousePosition = Components.MouseInput:InvokeClient(Player)
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		delay(.5,function()
			Components.PeriTrail.Enabled = false
		end)
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
end


function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
end



local HitHumanoids = {}
function Damage(hit,TotalDamage)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <=0 or Hum == Humanoid or ForceField then return end
	
	if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	
	spawn(function()
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		HitHumanoids[#HitHumanoids+1]=Hum
		Hum:TakeDamage(TotalDamage)
		--wait(.5)
	end)
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

function PurpleComet()
	
	if Services.ServerScriptService:FindFirstChild("AmethystComet") then return end
	
	--Services.Debris:AddItem(Tag,60)
	
	Components.PeriSparkle.Enabled = false

	local CometScript = script:WaitForChild("CometScript",10):Clone()
	local Creator = Create("ObjectValue"){
		Name = "Creator",
		Value = Player,
		Parent = CometScript
	}
	
	local Comet = Create("Part"){
		Size = Vector3.new(1,1,1)*150,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
		Name = "Comet",
		Anchored = false,
		CanCollide = false,
		Locked = true,
		Transparency = 1,
		CFrame = CFrame.new((Root.CFrame * CFrame.new(600,0,0) + Vector3.new(0,500,0)).p,(Root.CFrame*CFrame.new(-2000,0,0)).p),
		Parent = workspace
	}
	Comet:SetNetworkOwner(nil)
	CometScript.Parent = Comet
	CometScript.Disabled = false
	
	repeat
		Services.RunService.Heartbeat:Wait()
		--print(CometScript,CometScript.Parent)
	until not CometScript or not CometScript.Parent or not CometScript:IsDescendantOf(workspace)

	
	wait(Properties.SpecialCooldown)
	
	Components.PeriSparkle.Enabled = true
end


local MeteorAbility = true
function MeteorShower()
	if not MeteorAbility then return end
	MeteorAbility = false
	local Done = false
	spawn(function()
		wait(Properties.MeteorDuration)
		Done = true
	end)
	spawn(function()
		repeat
			local MeteorScript = script:WaitForChild("MeteorScript",10):Clone()
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = MeteorScript
			}
			
			local Meteor = Create("Part"){
				Size = Vector3.new(1,1,1)*Seed:NextInteger(5,20),
				Material = Enum.Material.Neon,
				Shape = Enum.PartType.Ball,
				Name = "Meteor",
				Anchored = false,
				CanCollide = false,
				Locked = true,
				Transparency = 1,
				CFrame = CFrame.new((Root.CFrame*CFrame.new(Seed:NextNumber(-300,300),Seed:NextNumber(300,400),Seed:NextNumber(-300,300))).p,(Root.CFrame*CFrame.new(Seed:NextNumber(-300,300),Root.CFrame.p.y,Seed:NextNumber(-300,300))).p),
				Parent = workspace
			}
			Meteor:SetNetworkOwner(nil)
			MeteorScript.Parent = Meteor
			MeteorScript.Disabled = false
			Wait(1/2)
		until Done
		wait(35)
		MeteorAbility = true
	end)
end


Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q then
		if Components.PeriSparkle.Enabled then
			PurpleComet()
		end
	elseif Key == Enum.KeyCode.E then
		MeteorShower()
	end	
end)