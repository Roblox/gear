--Rescripted by TakeoHonorable



local Properties = {
	BaseDamage = 20,
	MiniSpecial = true,
}

local Instant,Pairs,Type,Tick,wrap,Delay,Wait,Pcall = Instance.new,pairs,type,tick,coroutine.wrap,delay,wait,pcall

local Cframe,rad,Angles,Vec3,huge = CFrame.new,math.rad,CFrame.Angles,Vector3.new,math.huge

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Self = script

local world = workspace

local Tool = Self.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Smog = Handle:WaitForChild("Smog")
Smog.Enabled = true

local Player,Character,Humanoid,Root

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})

local Animations = {}

local Grips = {
	In = Tool:WaitForChild("NormalGrip").Value,
}

local Sounds = {
	SlashSound = Handle:WaitForChild("SlashSound"),
}



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

local function Wait(para) -- bypasses the latency
	local Initial = Tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until Tick()-Initial >= para
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function IsInTable(Table,Value)
	for i,v in Pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instant("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in Pairs(humanoid:GetChildren()) do
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
		Stab = Humanoid:LoadAnimation(RigFolder:WaitForChild("Stab")),
		Throw = Humanoid:LoadAnimation(RigFolder:WaitForChild("Throw"))
	}
	
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent or not Properties.MiniSpecial then return end
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
	if not Humanoid or Humanoid.Health <= 0 or not Tool.Enabled or not Properties.MiniSpecial then return end
	Tool.Enabled = false
	Sounds.SlashSound:Play()

	local Start = Tick()
	
	if (Start-LastTime) <= 0.7 and Tool:IsDescendantOf(Character) and Properties.MiniSpecial then
		Properties.MiniSpecial = false
		
		Animations.Throw:Play()
		

		--Throw the trident	
		
		
		Wait(.55)
		
		if not Tool:IsDescendantOf(Character) then Tool.Enabled = true; Properties.MiniSpecial = true return end
		
		Delay(10,function()
			Handle.Transparency = 0
			Smog.Enabled = true
			Properties.MiniSpecial = true
		end)
		
		local sucess,MousePosition = Pcall(function() return MouseInput:InvokeClient(Player) end)
		MousePosition = (sucess and MousePosition) or Vec3(0,0,0)
		
		local TridentClone = Handle:Clone()
		
		TridentClone.Massless = true
		TridentClone.Anchored = false
		
		TridentClone.CFrame = Cframe( TridentClone.Position , MousePosition ) * Angles(rad(180),0,0)
		
		--TridentClone.Velocity = (MousePosition - TridentClone.Position).Unit * 300
		
		--[[local Velo = Create("BodyVelocity"){
			MaxForce = Vec3(1,1,1) * huge,
			Velocity = (MousePosition - TridentClone.Position).Unit * 300,
			Parent = TridentClone
		}]]
		
		local TridentScript = Self:WaitForChild("TridentThrow"):Clone()
		TridentScript.Parent = TridentClone
		
		Create("ObjectValue"){
			Name = "Creator",
			Value = Character,
			Parent = TridentScript
		}
		
		Create("ObjectValue"){
			Name = "CreatorHumanoid",
			Value = Humanoid,
			Parent = TridentScript
		}
		
		Create("Vector3Value"){
			Name = "Direction",
			Value = (MousePosition - TridentClone.Position).Unit * 300,
			Parent = TridentScript
		}
		
		TridentScript.Disabled = false
		
		TridentClone.Parent = world
		
		if TridentClone:CanSetNetworkOwnership() then
			TridentClone:SetNetworkOwner(nil)
		end
		Smog.Enabled = false
		
		Handle.Transparency = 1
	else
		
		local Anims = {Animations.Slash,Animations.Stab}
		local RandomAnims = Anims[Seed:NextInteger(1,#Anims)]
		
		if RandomAnims.Animation.Name == "Stab" then
			Properties.BaseDamage = 25
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
				wrap(function()
					for i=0,120,30 do
						Tool.Grip = (Grips.In * Cframe(0,-2,0)) * Angles(rad(i),0,0)
						Wait(1/30)
					end	
				end)()
			else
				Tool.Grip = (Grips.In * Cframe(0,-2,0))
			end
		else
			Tool.Grip = (Grips.In * Cframe(0,-2,0)) * Angles(rad(50),0,0)
		end
		
		RandomAnims:Play(nil,nil,AttackSpeed)

	end
	Wait(1/AttackSpeed)
	LastTime = Start
	Properties.BaseDamage = 20
	Tool.Grip = Grips.In
	Tool.Enabled = true
	
end

function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
end


Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)
Tool.Unequipped:Connect(Unequipped)

