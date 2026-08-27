--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Light = Handle:WaitForChild("Light")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

MonkeyModel = InsertService:LoadAsset(358832923)
Monkey = MonkeyModel:GetChildren()[1]:Clone()
Debris:AddItem(MonkeyModel, 1)

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


BaseUrl = "http://www.roblox.com/asset/?id="

HelpGui = script:WaitForChild("HelpGui")
Animate = script:WaitForChild("Animate")
Remover = script:WaitForChild("Remover")
DamageScript = script:WaitForChild("DamageScript")

Gravity = 196.20
Rate = (1 / 60)

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Animations = {}
Sounds = {}

ReloadTime = 30
MonkeyDuration = 60
MaxDistance = 60

GhostMonkies = {}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

MonkiesSpawned = false
ToolEquipped = false

Light.Enabled = false
Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function SummonGhostMonkey()
	MonkiesSpawned = true
	local SetMonkies = {
		{Radius = 5, Theta = 0, Phi = 0, Dt = 0.02, Dp = -0.01},
		{Radius = 4, Theta = (math.pi / 2), Phi = (math.pi / 2), Dt = 0.030, Dp = 0.025},
		{Radius = 3, Theta = (3 * math.pi / 2), Phi = (3 * math.pi / 2), Dt = -0.025, Dp = -0.035},
		{Radius = 3, Theta = (math.pi / 2), Phi = (math.pi / 2), Dt = 0.050, Dp = -0.045},
	}
	GhostMonkies = {}
	for i, v in pairs(SetMonkies) do
		local GhostMonkey = Monkey:Clone()
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
			{Name = "Damage", Class = "NumberValue", Value = 10},
		}
		for ii, vv in pairs(Values) do
			local Value = Create(vv.Class){
				Name = vv.Name,
				Value = vv.Value,
				Parent = GhostMonkey,
			}
		end
		for ii, vv in pairs({Animate, Remover, DamageScript}) do
			local ScriptCopy = vv:Clone()
			ScriptCopy.Disabled = false
			ScriptCopy.Parent = GhostMonkey
		end
		local MonkeyTorso = GhostMonkey:FindFirstChild("Torso")
		if MonkeyTorso then
			local BodyPosition = Create("BodyPosition"){
				maxForce = Vector3.new(math.huge, math.huge, math.huge),
				Parent = MonkeyTorso,
			}
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				Parent = MonkeyTorso,
			}
			table.insert(GhostMonkies, {Monkey = GhostMonkey, Movement = v, Torso = MonkeyTorso, BodyPosition = BodyPosition, BodyGyro = BodyGyro})
		end
	end
	local function GetMonkiesAlive()
		local MonkiesAlive = 0
		for i, v in pairs(GhostMonkies) do
			if v.Monkey and v.Monkey.Parent then
				MonkiesAlive = (MonkiesAlive + 1)
			end
		end
		return MonkiesAlive
	end
	Spawn(function()
		Light.Enabled = true
		while GetMonkiesAlive() > 0 and ToolEquipped and CheckIfAlive() do
			for i, v in pairs(GhostMonkies) do
				v.Movement.Theta = (v.Movement.Theta + v.Movement.Dt)
				v.Movement.Phi = (v.Movement.Phi + v.Movement.Dp)
				local Pos = (v.Movement.Radius * Vector3.new(math.sin(v.Movement.Theta) * math.cos(v.Movement.Phi), math.sin(v.Movement.Phi), math.cos(v.Movement.Theta) * math.cos(v.Movement.Phi)))
				if TargetPlayer then
					if not TargetPlayer.Character or not TargetPlayer.Character.Parent or not TargetPlayer.Humanoid or TargetPlayer.Humanoid.Health == 0 or (TargetPlayer.Torso.Position - Torso.Position).Magnitude > MaxDistance then
						TargetPlayer = nil
					end
				end
				local TargetTorso = ((TargetPlayer and TargetPlayer.Torso) or Torso)
				local Origin = ((TargetPlayer and TargetPlayer.Torso) or Handle)
				local MonkeyCF = CFrame.new((Pos + Origin.Position), (TargetTorso.Position + TargetTorso.CFrame.lookVector * 25))
				v.BodyPosition.position = MonkeyCF.p
				v.BodyGyro.cframe = MonkeyCF
			end
			wait(Rate)
		end
		Light.Enabled = false
		Tool.Enabled = false
		wait(ReloadTime)
		MonkiesSpawned = false
		Tool.Enabled = true
	end)
	for i, v in pairs(GhostMonkies) do
		for ii, vv in pairs(v.Monkey:GetChildren()) do
			if vv:IsA("BasePart") then
				vv.CanCollide = false
			end
		end
		v.Torso.CFrame = Handle.CFrame
		Debris:AddItem(v.Monkey, MonkeyDuration)
		v.Monkey.Parent = game:GetService("Workspace")
	end
	return GhostMonkies
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if not MonkiesSpawned then
		for i, v in pairs(GhostMonkies) do
			if v.Monkey and v.Monkey.Parent then
				v.Monkey:Destroy()
			end
		end
		GhostMonkies = {}
		SummonGhostMonkey()
	else
		local NewTarget = false
		local Target = MouseData.Target
		if Target then
			local character = Target.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 and torso and (torso.Position - Torso.Position).Magnitude <= MaxDistance then
				NewTarget = true
				TargetPlayer = {Character = character, Humanoid = humanoid, Torso = torso}
			end
		end
		if not NewTarget then
			TargetPlayer = nil
		end
	end
	wait(2)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		HelpGuiCopy = HelpGui:Clone()
		HelpGuiCopy.Parent = PlayerGui
	end
	Light.Enabled = false
	ToolEquipped = true
end

function Unequipped()
	Light.Enabled = false
	for i, v in pairs(GhostMonkies) do
		if v.Monkey and v.Monkey.Parent then
			v.Monkey:Destroy()
		end
	end
	GhostMonkies = {}
	if HelpGuiCopy and HelpGuiCopy.Parent then
		HelpGuiCopy:Destroy()
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped.Value or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)