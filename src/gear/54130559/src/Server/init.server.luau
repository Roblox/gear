--Rescripted by TakeoHonorable

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Player,Character,Humanoid,Root

local Remote = Tool:WaitForChild("Remote")

local Properties = {
	BaseDamage = 24,
	Special = true,
	MiniSpecial = true,
}

local Animations = {}

local Grips = {
	In = Tool:WaitForChild("NormalGrip").Value,
}

local Sounds = {
	SlashSound = Handle:WaitForChild("SlashSound"),
	QuakeSound = Handle:WaitForChild("QuakeSound"),
	SpecialReady = Handle:WaitForChild("SpecialReady"),
	SplashSound = Handle:WaitForChild("SplashSound")
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


local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService")),
}

WaveModel = Services.InsertService:LoadAsset(212226090)
local Wave = WaveModel:GetChildren()[1]:Clone()
Wave.Size = Vector3.new(10, 3.5, 20)*2
WaveModel:Destroy()

local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function IsInTable(Table,Value)
	for i,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
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

local Touch
function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	local AnimFolder = Tool:WaitForChild("Animations")
	local RigFolder = AnimFolder:WaitForChild(Humanoid.RigType.Name)
	 
	Animations = {
		Quake = Humanoid:LoadAnimation(RigFolder:WaitForChild("Quake")),
		Slash = Humanoid:LoadAnimation(RigFolder:WaitForChild("Slash")),
		Stab = Humanoid:LoadAnimation(RigFolder:WaitForChild("Stab"))
	}
	
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not Hum or Hum == Humanoid or Hum.Health <= 0  or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		Hum:TakeDamage(Properties.BaseDamage)
	end)
	
	if Properties.Special then
		Sounds.SpecialReady:Play()
	end
end



local Seed = Random.new()
local AttackSpeed,LastTime = 2,0

function Activated()
	if not Humanoid or Humanoid.Health <= 0 or not Tool.Enabled then return end
	Tool.Enabled = false
	Sounds.SlashSound:Play()
	local Anims = {Animations.Slash,Animations.Stab}
	local RandomAnims = Anims[Seed:NextInteger(1,#Anims)]
	if RandomAnims.Animation.Name == "Stab" then
		Properties.BaseDamage = 30
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			coroutine.wrap(function()
				for i=0,120,30 do
					Tool.Grip = (Grips.In * CFrame.new(0,-2,0)) * CFrame.Angles(math.rad(i),0,0)
					Wait(1/30)
				end	
			end)()
		else
			Tool.Grip = (Grips.In * CFrame.new(0,-2,0))
		end
	else
		Tool.Grip = (Grips.In * CFrame.new(0,-2,0)) * CFrame.Angles(math.rad(50),0,0)
	end
	RandomAnims:Play(nil,nil,AttackSpeed)
	local Start = tick()
	wait(1/AttackSpeed)
	if (Start-LastTime) <= 0.7 and Tool:IsDescendantOf(Character) and Properties.MiniSpecial then
		Properties.MiniSpecial = false
		delay(20,function()
			EnableSpecialEffects(Properties.Special,true)
			Properties.MiniSpecial = true
		end)
		--Summon Wave		
		local WavePart = Wave:Clone()
		WavePart.Material = Enum.Material.Glass
		WavePart.Transparency = .3
		WavePart.Locked = true
		WavePart.Anchored = false
		WavePart.CanCollide = false
		WavePart.CFrame = ((Root.CFrame * CFrame.new(0, -Root.Size.Y, 0))) * CFrame.Angles(0,math.rad(-90),0)
		WavePart.Color = Color3.fromRGB(0,255,204)
		WavePart.UsePartColor = true
		
		local Velo = Instance.new("BodyVelocity")
			Velo.MaxForce = Vector3.new(1,1,1)*math.huge
			Velo.Velocity = Root.CFrame.lookVector*30
			Velo.Parent = WavePart
			
		local Splash = Sounds.SplashSound:Clone()
		Splash.Parent = WavePart
			
		WavePart.Parent = workspace
		WavePart:SetNetworkOwner(nil)
		Splash:Play()
			
		Services.Debris:AddItem(WavePart,4)
		
		local AffectedHumanoids = {}
		WavePart.Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
			if not Hum or FF or  Hum == Humanoid or Hum.Health <= 0 then return end
			if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or IsInTable(AffectedHumanoids,Hum) then return end
			table.insert(AffectedHumanoids,Hum)
			--[[UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(50)]]
			Hum.Sit = true
			coroutine.wrap(function()
				local Knockback = Instance.new("BodyVelocity")
				Knockback.MaxForce = Vector3.new(1,1,1)*math.huge
				Knockback.Velocity = (hit.CFrame.p-WavePart.CFrame.p).Unit * 75
				Knockback.Parent = hit
				Services.Debris:AddItem(Knockback,.5)
			end)()
		end)
	end
	LastTime = Start
	Properties.BaseDamage = 24
	Tool.Grip = Grips.In
	Tool.Enabled = true
	
end

function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
	if Properties.Special then
		Sounds.SpecialReady:Stop()
	end
end

function EnableSpecialEffects(Verdict,Wave)
	for _,attachment in pairs(Handle:GetChildren()) do
		if attachment:IsA("Attachment") then
			if attachment.Name == "Effect" then
				local particle = attachment:FindFirstChildOfClass("ParticleEmitter")
				if particle then
					particle.Enabled = Verdict or false
				end	
			elseif attachment.Name == "SeismicWave" then
				local particle = attachment:FindFirstChildOfClass("ParticleEmitter")
				if particle and Wave then
					particle:Emit(particle.Rate)
				end	
			end
		end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)
Tool.Unequipped:Connect(Unequipped)

function Quake()
	Tool.Enabled = false
	Properties.Special = false
	EnableSpecialEffects(false)
	Sounds.SpecialReady:Stop()
	Animations.Quake:Play()
	wait(.75)
	Sounds.QuakeSound:Play()
	local QuakeScript = script:WaitForChild("QuakeScript"):Clone()
	QuakeScript.Parent = Services.ServerScriptService
	QuakeScript:WaitForChild("Creator").Value = Player
	QuakeScript:WaitForChild("Center").Value = Root.CFrame.p
	QuakeScript.Disabled = false
	
	delay(3,function()
		Tool.Enabled = true
	end)
	delay(20,function()
		Properties.Special = true
		EnableSpecialEffects(true)
		if Tool:IsDescendantOf(Character) then
			Sounds.SpecialReady:Play()
		end
	end)
end

Remote.OnServerEvent:Connect(function(Client,Key)
	if not Tool.Enabled or Client ~= Player or not Key or not Humanoid or Humanoid.Health <= 0 then return end
	if Key == Enum.KeyCode.X and Properties.Special then
		Quake()
	end
end)

EnableSpecialEffects(true)