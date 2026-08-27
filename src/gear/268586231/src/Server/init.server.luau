--Make sure that the portal kills Godded people once within range

--Fixed by TakeoHonorable
	--Fixed the gravitation issue with the black hole
local Seed = Random.new()

local Wait,NextInteger,huge,Instant,Type,Pairs = wait,Seed.NextInteger,math.huge,Instance.new,type,pairs

	
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

local Remote = (Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
})

local Particle = Handle:WaitForChild("Particle")

Particle.Enabled = true

local Player,Character,Humanoid

local Sounds = {
	Equip = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

local Properties = {
	Swinging = false,
	Damage = {Touch = {Min = 7, Max = 11}, Hit = {Min = 16, Max = 22}},
	Activating = false,
	BlackHole_Duration = 15,
	BlackHole_Range = 150,
	Special_Cooldown = 40
}

local Events = {}

local Animations = {}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	InsertService = (game:FindService("InsertService") or game:GetService("InsertService"))
}


local R15BaseModel = Services.InsertService:LoadAsset(1664543044) --R15 standard Model
local R15Base = R15BaseModel:FindFirstChildOfClass("Model")
R15Base.Parent = nil
R15BaseModel:Destroy()
R15BaseModel = nil

local SkeleBase = R15Base:Clone()
if SkeleBase:FindFirstChild("Head") then
	SkeleBase:FindFirstChild("Head").Transparency = 1
end
--[[local BodyColors = Create("BodyColors"){
	HeadColor = BrickColor.new("Really black"),
	RightArmColor = BrickColor.new("Really black"),
	LeftArmColor = BrickColor.new("Really black"),
	TorsoColor = BrickColor.new("Really black"),
	RightLegColor = BrickColor.new("Really black"),
	LeftLegColor = BrickColor.new("Really black"),
	Parent = SkeleBase	
}]]

local SkeleColor = Color3.fromRGB(98, 37, 209)
local BodyColors = Create("BodyColors"){
	HeadColor3 = SkeleColor,
	RightArmColor3 = SkeleColor,
	LeftArmColor3 = SkeleColor,
	TorsoColor3 = SkeleColor,
	RightLegColor3 = SkeleColor,
	LeftLegColor3 = SkeleColor,
	Parent = SkeleBase	
}


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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


function Equipped()
	
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == huge or Humanoid.MaxHealth == huge then return end
	
	Animations = Tool:WaitForChild("Animations")
	
	Animations = {
		Equip = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Equip")), Speed = .7, Duration = .75},
		LeftSlash = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("LeftSlash")), Speed = 2, Duration = .75},
		RightSlash = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("RightSlash")), Speed = 2, Duration = .75},
		SideSwipe = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("SideSwipe")), Speed = .8, Duration = .75},
		Summon = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Summon")), Speed = .75, Duration = 1.25},
		--Swing = {Animation = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Swing")), Speed = 1, Duration = 1}
	}
	
	Animations.Equip.Animation:Play(nil,nil,Animations.Equip.Speed)
	Sounds.Equip:Play()
	
	local Current_Time = 0
	repeat
		Current_Time = Current_Time + Services.RunService.Heartbeat:Wait()
	until not Tool:IsDescendantOf(Character) or Current_Time >= Animations.Equip.Duration/Animations.Equip.Speed
	
	if not Animations.Equip or Current_Time < Animations.Equip.Duration then return end
	
	Events[#Events+1] = Tool.Activated:Connect(function()
		if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == huge or Humanoid.MaxHealth == huge then return end
			
		Tool.Enabled = false
		Properties.Swinging = true
		
		local AttackAnim = {Animations.LeftSlash,Animations.RightSlash,Animations.SideSwipe}
		AttackAnim = AttackAnim[NextInteger(Seed,1,#AttackAnim)]
		
		--print(AttackAnim.Animation.Name)
		
		if AttackAnim.Animation then
			AttackAnim.Animation:Play(nil,nil,(AttackAnim.Animation and AttackAnim.Speed) or 1)
		end
		
		Sounds.Slash.Pitch = (NextInteger(Seed,1250, 1750) * 0.001)
		Sounds.Slash:Play()
		
		Wait((AttackAnim and AttackAnim.Animation and AttackAnim.Duration) or 1)
		Properties.Swinging = false
		Tool.Enabled = true
		
	end)
	
	Events[#Events+1] = Remote.OnServerEvent:Connect(function(Client,Key)
		if not Player or not Client or Client ~= Player or not Key or not Tool.Enabled or Properties.Activating then return end
		
		if Key == Enum.KeyCode.Q and Particle.Enabled then
			Properties.Activating = true
			
			Animations.Summon.Animation:Play(nil,nil,Animations.Summon.Speed)
			Current_Time = 0
			repeat
				Current_Time = Current_Time + Services.RunService.Heartbeat:Wait()
			until not Tool:IsDescendantOf(Character) or Current_Time >= Animations.Summon.Duration/Animations.Summon.Speed
			
			
			Properties.Activating = false
			
			if not Tool:IsDescendantOf(Character) then return end
			
			--print("Placing portal here")
			
			local BlackHoleScript = Self:WaitForChild("BlackHoleScript"):Clone()
			
			Create("CFrameValue"){
				Name = "Location",
				Value = (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")).CFrame * CFrame.new(0,6,-7),
				Parent = BlackHoleScript
			}
			
			Create("NumberValue"){
				Name = "Duration",
				Value = Properties.BlackHole_Duration,
				Parent = BlackHoleScript
			}
			
			Create("ObjectValue"){
				Name = "Creator",
				Value = Character,
				Parent = BlackHoleScript
			}
			
			Create("NumberValue"){
				Name = "Range",
				Value = Properties.BlackHole_Range,
				Parent = BlackHoleScript
			}
			
			BlackHoleScript.Parent = Services.ServerScriptService
			BlackHoleScript.Disabled = false
			
			Particle.Enabled = false
			
			delay(Properties.Special_Cooldown, function()
				Particle.Enabled = true
			end)
			
			--Place Portal here
			
		end
		
	end)
	
	Events[#Events+1] = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
		
		if not Hum or Hum.Health <= 0  or FF then return end
		
		
		Hum:TakeDamage((Properties.Activating and NextInteger(Seed,Properties.Damage.Touch.Min,Properties.Damage.Touch.Max)) or NextInteger(Seed,Properties.Damage.Hit.Min,Properties.Damage.Hit.Max))
		
		if Hum.Health <= 0  and not Hum.Parent:FindFirstChild("Skeleton") then --Turn them into a Skeleton!
			
			--1. Spawn the dummy skeleton
			--2. Delete the victim's body parts
			
			local VictimCenter = Hum.Parent:FindFirstChild("HumanoidRootPart") or Hum.Parent:FindFirstChild("Torso") or Hum.Parent:FindFirstChild("UpperTorso")
			
			--print("Turning them into a skeleton")
			
			local SkeleBaseClone = SkeleBase:Clone()
			
			local SkeleScript = Self:WaitForChild("SkeleScript"):Clone()
			
			Create("ObjectValue"){
				Name = "Creator",
				Value = Character,
				Parent = SkeleScript
			}
			
			Create("BoolValue"){
				Name = "Skeleton",
				Value = true,
				Parent = SkeleBaseClone
			}
			
			if SkeleBaseClone:FindFirstChild("HumanoidRootPart") then
				SkeleBaseClone.PrimaryPart = SkeleBaseClone:FindFirstChild("HumanoidRootPart")
				SkeleBaseClone:SetPrimaryPartCFrame(VictimCenter.CFrame)
			end
			SkeleBaseClone.Name = "AzureSkeleton"
			
			SkeleScript.Parent = SkeleBaseClone
			SkeleScript.Disabled = false
			
			SkeleBaseClone.Parent = world
			
			local parts = Hum.Parent:GetDescendants()
			
			for i=1,#parts,1 do
				
				if parts[i] and (parts[i]:IsA("BasePart") or parts[i]:IsA("BaseScript")) then
					
					parts[i]:Destroy()
				
				end
			
			end
			
			if Hum and Hum.Parent and not Services.Players:GetPlayerFromCharacter(Hum.Parent) then
				Services.Debris:AddItem(Hum.Parent,5)
			end
			
		end
		
		
	end)
end


function Unequipped()
	
	for i=1,#Events do
		if Events[i] then 
			Events[i]:Disconnect()
		end
	end
	Events = {}
	
	for _,anim in Pairs(Animations) do
		--print(anim.Animation)
		if anim.Animation then 
			anim.Animation:Stop()
		end
	end
	Animations = {}
	Properties.Swinging = false
	Properties.Activating = false
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
