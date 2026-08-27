--Rescripted by TakeoHonorable
--Sword of Light Revamped

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

--[[local SwordMesh = Handle:WaitForChild("SwordMesh")
SwordMesh.VertexColor = Vector3.new(1,1,1) -- Keep it normal]]

local Properties = {
	Damage = 14,
	Special = true,
	SpecialReload = 30,
	SpecialActive = false,
	TimetoChange = 12,
	LightTeleport = true
}

local Sounds = {
	Lunge = Handle:WaitForChild("Lunge"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

local Remote = Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
}

local MousePos = Tool:FindFirstChildOfClass("RemoteFunction") or Create("RemoteFunction"){
	Name = "MouseInput",
	Parent = Tool
}

local function SunIsVisible(Character)
	local dir = Services.Lighting:GetSunDirection()
	if Vector3.new(0,1,0):Dot(dir) > 0 then
	-- BUG: particles block raycast
	local hit = workspace:FindPartOnRay(Ray.new(Handle.Position,dir*999),Character)
		if not hit or (hit and not hit.CanCollide)then
			return true
		end
	end
	return false
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
		Services.RunService.Stepped:Wait()
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

local function EnableParticles(Verdict)
	for _,stuff in pairs(Handle:GetDescendants()) do
		if (stuff:IsA("ParticleEmitter") and stuff.Parent ~= Handle) or stuff:IsA("Light") then
			stuff.Enabled = Verdict
		end
		if stuff:IsA("Light") then
			stuff.Range = (Verdict and 10) or 3
		end
	end
end

local function SpecialParticles(Verdict)
	for _,stuff in pairs(Handle:GetDescendants()) do
		if stuff:IsA("ParticleEmitter") and stuff.Parent == Handle then
			stuff.Enabled = Verdict
		end
		if stuff:IsA("Beam") then
			stuff.TextureSpeed = (Verdict and 1) or .1
			stuff.Color = (Verdict and ColorSequence.new(Color3.new(1,1,1)) or ColorSequence.new(Color3.new(.5,.5,.5)))
		end
	end
end



local Player,Character,Humanoid,Root

function PassiveSpecial()
	--Sword of light does healing + Damage resistance when the sun is out
	--Check if Daytime then roll with ability
	--loop until time is not daytime
	if not Humanoid or Humanoid.Health <= 0 or not Character then return end
	
	if not SunIsVisible(Character) then  
		--print("Sun is not visible")
		EnableParticles(false)
		Properties.SpecialActive = false
		if Humanoid and Tool:IsDescendantOf(Character) then
			Humanoid.WalkSpeed = 16
			Properties.Damage = 14
		end
		--[[Disable particles on sword]]
		return 
	end
	
	if Humanoid and Tool:IsDescendantOf(Character) then
		Humanoid.WalkSpeed = 25
		Properties.Damage = 20
	end
	--Trigger active particles on sword
	
	if not Character:FindFirstChild(script:WaitForChild("SoLDefense").Name) and Tool:IsDescendantOf(Character) then
		local DefenseScript = script:WaitForChild("SoLDefense"):Clone()
		local ToolRef = Create("ObjectValue"){
			Name = "ToolRef",
			Value = Tool,
			Parent = DefenseScript
		}
		DefenseScript.Parent = Character
		DefenseScript.Disabled = false
	end

	
	if Properties.SpecialActive then --[[print("On Cooldown")]] return end
	--SwordMesh.VertexColor = Vector3.new(1,1,1) * 10 -- Make the sword look all bright
	
	Properties.SpecialActive = true
	EnableParticles(true)

	
end

local Animations = {}

function ChangeTime(Time) --initiate the cool time-chaning effect!
	if not Properties.Special then return end
	--warn("Changing Time")
	Properties.Special = false
	SpecialParticles(false)
	Tool.Enabled = false
	Humanoid.WalkSpeed = 0
	Animations.Summon:Play()
	delay(3,function()
		PassiveSpecial()
		Tool.Enabled = true
		Animations.Summon:Stop()
		--Humanoid.WalkSpeed = (Humanoid.WalkSpeed <=0 and 16) or Humanoid.WalkSpeed
	end)
	delay(Properties.SpecialReload,function()
		Properties.Special = true
		SpecialParticles(true)
	end)
	local TimeChange = script:WaitForChild("TimeChange"):Clone()
	local SpawnPosition = Create("Vector3Value"){
		Name = "SpawnPosition",
		Value = Root.Position - Vector3.new(0,Root.Size.Y * 1.5,0),
		Parent = TimeChange,
	}
	local Creator = Create("ObjectValue"){
		Name = "Creator",
		Value = Player,
		Parent = TimeChange
	}
	local Time = Create("NumberValue"){
		Name = "Time",
		Value = Time,
		Parent = TimeChange
	}
	TimeChange.Parent = Services.ServerScriptService
	TimeChange.Disabled = false
end

local function LightTransport()
	local LightWarpScript = script:WaitForChild("LightWarp")
	local function IsWarping()
		local stuff = Services.ServerScriptService:GetChildren()
		for i=1,#stuff do
			if stuff[i] and stuff[i].Name == LightWarpScript.Name and stuff[i]:FindFirstChild("Character") and stuff[i]:FindFirstChild("Character").Value == Character then
				return true
			end
		end
		return false
	end
	
	if IsWarping() then return end
	
	local sucess,MousePosition = pcall(function() return MousePos:InvokeClient(Player) end)
	MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
	
	LightWarpScript = LightWarpScript:Clone()
	local CharacterTag = Create("ObjectValue"){
		Name = "Character",
		Value = Character,
		Parent = LightWarpScript
	}
	local TargetLocation = Create("Vector3Value"){
		Name = "TargetLocation",
		Value = MousePosition,
		Parent = LightWarpScript
	}
	local Range = Create("NumberValue"){
		Name = "Range",
		Value = (Properties.SpecialActive and 200) or 100,
		Parent = LightWarpScript
	}
	LightWarpScript.Parent = Services.ServerScriptService
	LightWarpScript.Disabled = false
end

local EquippedEvents = {}
local Touch



local MouseHeld = false
local CurrentMotor,RightWeld,Part0,Part1

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	
	if not Humanoid or Humanoid.Health <= 0 then return end
	
	Animations = Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Slash = Humanoid:LoadAnimation(Animations:WaitForChild("SlashAnim")),
		Stab = Humanoid:LoadAnimation(Animations:WaitForChild("StabAnim")),
		Summon = Humanoid:LoadAnimation(Animations:WaitForChild("SummonAnim")),
		Charge = Humanoid:LoadAnimation(Animations:WaitForChild("ChargeAnim")),
	}
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
		if not Hum or FF or Hum.Health <= 0 or IsTeamMate(Services.Players:GetPlayerFromCharacter(Hum.Parent),Player) or Hum.Parent == Character then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		Hum:TakeDamage(Properties.Damage)
		print(Properties.Damage)
	end)
	PassiveSpecial()
	Sounds.Unsheath:Play()
end


function Unequipped()
	MouseHeld = false
	if Touch then Touch:Disconnect();Touch = nil end
	for AnimName,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	if CurrentMotor then
		CurrentMotor:Destroy()
	end
	if Tool:IsDescendantOf(workspace) and not Tool:IsDescendantOf(Character) then		
		for index = 1,#EquippedEvents do
			if EquippedEvents[index] then 
				EquippedEvents[index]:Disconnect();EquippedEvents[index] = nil
			end 
		end
	end
end

local Seed = Random.new()

function Activated()
	if not Tool.Enabled or MouseHeld then return end
	MouseHeld = true	
	Animations.Charge:Play()
end

function Deactivated()
	if not Tool.Enabled or not MouseHeld then return end
	MouseHeld = false

	Tool.Enabled = false
	local RightLimb = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if RightLimb then
		RightWeld = RightLimb:FindFirstChildOfClass("Weld")
		if RightWeld and not CurrentMotor then
			CurrentMotor = Create'Motor6D'{
				Name = 'Grip',
				--C0 = RightWeld.C0,
				--C1 = Tool.Grip,--RightWeld.C1,
				Part0 = RightWeld.Part0,
				Part1 = Handle,
				--Parent = RightArm
			}
			CurrentMotor.Parent = RightLimb
		end
		coroutine.wrap(function()
			if RightWeld then
				Part0 = RightWeld.Part0
				Part1 = RightWeld.Part1
				RightWeld.Part0 = nil
				RightWeld.Part1 = nil
			end
		end)()
		
	end
	local AttackAnims = {--[[Animations.Slash,]]Animations.Stab}
	Sounds.Lunge:Play()
	Animations.Charge:Stop()
	local Anim = AttackAnims[Seed:NextInteger(1,#AttackAnims)]
	Anim:Play(0,nil,3);--Anim.Stopped:Wait()
	Wait(Anim.Length/3)
	if RightWeld then
		RightWeld.Part0 = Part0
		RightWeld.Part1 = Part1
	end
	if CurrentMotor then 
		CurrentMotor:Destroy();CurrentMotor = nil
	end
	Tool.Enabled = true
end


Remote.OnServerEvent:Connect(function(Client,Key)
	if Client ~= Player or not Key or not Humanoid or Humanoid.Health <= 0 or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q then
		ChangeTime(Properties.TimetoChange)
	elseif Key == Enum.KeyCode.E and Properties.LightTeleport then
		Properties.LightTeleport = false
		delay(5,function()
			Properties.LightTeleport = true
		end)
	 	LightTransport()
	end
end)

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)
Tool.Deactivated:Connect(Deactivated)

Services.Lighting.Changed:Connect(function(property)
	if property == "ClockTime" then
		PassiveSpecial()
	end
end)
EnableParticles(false)
SpecialParticles(true)
PassiveSpecial()--trigger it initially on start