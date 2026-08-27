--Rescripted by TakeoHonorable

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
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local MousePos = Tool:WaitForChild("MousePos")

local Player,Character,Humanoid,Torso,RightHolder,RightMotor,MotorC0

local LaserPositions = {
	Handle:WaitForChild("Attack"),
	Handle:WaitForChild("Heal"),
	Handle:WaitForChild("Push")
}

local Sounds = {
	Laser = Handle:WaitForChild("Laser")
}

local LaserBase = Create("Part"){ -- helps reduce replication latency
	Locked = true,
	Anchored = true,
	CanCollide = false,
	Name = "Laser",
	Transparency = 0,
	Material = Enum.Material.Neon,
	Shape = Enum.PartType.Cylinder,--Give it a more realistic light form
	Size = Vector3.new(15,.15,.15) --Part is a cylinder, X-axis is the length, the rest are width.
}

local Face = {Enum.NormalId.Back,Enum.NormalId.Bottom,Enum.NormalId.Front,Enum.NormalId.Left,Enum.NormalId.Right,Enum.NormalId.Top}

local LaserLighting = Create("SurfaceLight"){
	Color = Color3.fromRGB(255,255,255),
	Angle = 180,
	Enabled = true,
	Brightness = 10,
	Range = 3,
	Shadows = true
}

local Colors,index = {"Really red", "Lime green", "Toothpaste"},1

local CurrentLaser

local LaserLights = {}--used for changing the lights

for _,surfaces in pairs(Face) do
	local Lighting = LaserLighting:Clone()
	Lighting.Face = surfaces
	Lighting.Parent = LaserBase
end


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end


function IsNeutral(Player1, Player2)
	return (Player1 and Player2 and Player1.Neutral and Player2.Neutral)
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

local function VisualizeRay(ray,RayLength,Color)
	local RayCast = Create("Part"){
		Material = Enum.Material.Neon,
		Color = Color or Color3.new(0,1,0),
		Size = Vector3.new(0.3,0.3,(RayLength or 5)),
		CFrame = CFrame.new(ray.Origin, ray.Origin+ray.Direction) * CFrame.new(0, 0, -(RayLength or 5) / 2),
		Anchored = true,
		CanCollide = false,
		Parent = workspace
	}
	game:GetService("Debris"):AddItem(RayCast,0.5)
	return RayCast
end


local Function = {
	function(hit)--Attack
		--print("Attack")
		local Directory = hit.Parent
		if Directory:IsA("Accoutrement") then
			Directory = Directory.Parent
		end
		local Hum = Directory:FindFirstChildOfClass("Humanoid")
		if Hum and Hum ~= Humanoid and Hum.Health ~= 0 and Hum.Health > 0 and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(.5)
		end
	end,
	function(hit)--Heal
		--print("Heal")
		local Directory = hit.Parent
		if Directory:IsA("Accoutrement") then
			Directory = Directory.Parent
		end
		local Hum = Directory:FindFirstChildOfClass("Humanoid")

		if Hum and Hum ~= Humanoid and Hum.Health ~= 0 and Hum.Health > 0 and (IsNeutral(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or not Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum.Health = Hum.Health + .5
		end
	end,
	function(hit,dir)--Push away
		--print("Push away")
		local Directory = hit.Parent
		if Directory:IsA("Accoutrement") then
			Directory = Directory.Parent
		end
		local Hum = Directory:FindFirstChildOfClass("Humanoid")
		if Hum and Hum ~= Humanoid and Hum.Health ~= 0 and Hum.Health > 0 then
			local nforce = Instance.new('BodyForce')
			nforce.Force = dir * 3000
			nforce.Parent = Hum.Parent:FindFirstChild("Torso") or Hum.Parent:FindFirstChild("UpperTorso")
			Hum.Sit = true
			game.Debris:AddItem(nforce,.2)
			delay(.2,function() Hum.Sit = false end)
		end
	end
}

local R15Anim
function Equipped()
	Character = Tool.Parent
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RightHolder = Character:FindFirstChild("Torso") or Character:FindFirstChild("RightUpperArm")
	RightMotor = RightHolder:FindFirstChildOfClass("Motor6D")
	MotorC0 = RightMotor.C0
	RightMotor.CurrentAngle = 0
	RightMotor.DesiredAngle = 0
	RightMotor.MaxVelocity = 1/3
	Sounds.Laser:Play()
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		R15Anim = Humanoid:LoadAnimation(script:WaitForChild("R15Straight"))
		R15Anim:Play()
	end
	repeat
		Sounds.Laser.PlaybackSpeed = .75+((index*.25)*3)
		Sounds.Laser.Volume = ((math.sin(tick()*3)+1)*.25)+.25
		if not CurrentLaser then
			CurrentLaser = LaserBase:Clone()
			CurrentLaser.BrickColor = BrickColor.new(Colors[index])
			LaserLights = {}
			for _,light in pairs(CurrentLaser:GetChildren()) do
				if light:IsA("SurfaceLight") then
				LaserLights[#LaserLights+1]= light
				end
			end
			CurrentLaser.Parent = Tool
		end
		local Base = CFrame.new(LaserPositions[index].WorldPosition,LaserPositions[index].WorldPosition+Handle.CFrame.lookVector)
		local LaserRay = Ray.new(Base.p,Base.lookVector*1000)
		
		local hit,pos = workspace:FindPartOnRayWithIgnoreList(LaserRay,{Character,CurrentLaser})
		local Distance = (LaserPositions[index].WorldPosition-pos).Magnitude
		CurrentLaser.BrickColor = BrickColor.new(Colors[index])
		if hit then
			Function[index](hit,(pos-LaserPositions[index].WorldPosition).Unit)
		end
		for _,light in pairs(LaserLights) do
			light.Color = BrickColor.new(Colors[index]).Color
			light.Range =((math.sin(tick()*3)+1)*1)+5
			light.Brightness =((math.sin(tick()*3)+1)*1)+1
		end
		CurrentLaser.Size = Vector3.new(Distance,.15,.15)
		CurrentLaser.CFrame = CFrame.new(LaserRay.Origin,LaserRay.Origin+LaserRay.Direction)*CFrame.Angles(0,math.rad(90),0)*CFrame.new(Distance/2,0,0)
		--CurrentLaser.CFrame = CFrame.new(LaserPositions[index].WorldPosition,LaserPositions[index].WorldPosition+Handle.CFrame.lookVector)*CFrame.new(0,0,-Distance/2)*CFrame.Angles(0,math.rad(90),0)
		Services.RunService.Heartbeat:Wait()
	until not Tool:IsDescendantOf(Character) or Humanoid.Health <= 0 or not RightMotor:IsDescendantOf(Character)
end

function Unequipped()
	--index = 1
	if R15Anim then
		R15Anim:Stop();R15Anim=nil
	end
	RightMotor.MaxVelocity = .15
	RightMotor.C0 = MotorC0
	Sounds.Laser:Stop()
	if CurrentLaser then
		CurrentLaser:Destroy()
	end
	CurrentLaser = nil
end

function Activated()
	index = (Colors[index+1] and index+1) or 1
	if CurrentLaser then
		CurrentLaser.BrickColor = BrickColor.new(Colors[index])
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

MousePos.OnServerEvent:Connect(function(Client,Pos)
	if Client ~= Player or not Tool:IsDescendantOf(Character) or not RightMotor or not Pos then return end
	local tframe = Torso.CFrame
	local Angles = ((Humanoid.RigType == Enum.HumanoidRigType.R6 and CFrame.Angles(0,math.pi/2,0)) or CFrame.Angles(0,0,0))
	tframe = tframe + tframe:vectorToWorldSpace(Vector3.new(1, 0.5, 0))
	local taim = Pos.p -(tframe.p)
	RightMotor.C0 = (CFrame.new(Vector3.new(),tframe:vectorToObjectSpace(taim))*Angles)+Vector3.new(1, 0.5, 0)
end)