--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 7, Max = 11},
	Hit = {Min = 12, Max = 16},
}

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

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	R15LeftSlash = {Animation = Tool:WaitForChild("R15LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	R15RightSlash = {Animation = Tool:WaitForChild("R15RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	R15SideSwipe = {Animation = Tool:WaitForChild("R15SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},	
}

Flying = false
MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		v.Enabled = true
	end
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function EquipWings(MakeNew)
	
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	
	if not MakeNew then
		return
	end
	
	WingScale = Vector3.new(7.5, 7.5, 7.5)
	
	Wing = BasePart:Clone()
	Wing.Name = "Wing"
	Wing.Size = Vector3.new(4.5, 5, 0.2)
	Wing.CanCollide = false
	WingMesh = Instance.new("SpecialMesh")
	WingMesh.MeshId = ""
	WingMesh.TextureId = (BaseUrl .. "346121780") --Thanks to KarateMaster642 for this awesome texture!
	WingMesh.Scale = WingScale
	WingMesh.VertexColor = Vector3.new(1, 1, 1)
	WingMesh.Offset = Vector3.new(0, 0, 0)
	WingMesh.Parent = Wing
	
	LeftWing = Wing:Clone()
	LeftWing.Name = "LeftWing"
	LeftWing.Mesh.MeshId = (BaseUrl .. "233695211")
	LeftWingWeld = Instance.new("Motor6D")
	LeftWingWeld.Part0 = Torso
	LeftWingWeld.Part1 = LeftWing
	LeftWingWeld.C0 = CFrame.new(-0.2, 0.75, 0) * CFrame.Angles((math.pi / 2.25), -(math.pi / 16), (math.pi / 6))
	LeftWingWeld.C1 = (CFrame.new(1.75, -0.75, -2.75) + Vector3.new(-0.275, 0, 0.25)) * CFrame.Angles((math.pi / 2), 0, 0)
	LeftWingWeld.Parent = LeftWing
	
	RightWing = Wing:Clone()
	RightWing.Name = "RightWing"
	RightWing.Mesh.MeshId = (BaseUrl .. "233695097")
	RightWingWeld = Instance.new("Motor6D")
	RightWingWeld.Part0 = Torso
	RightWingWeld.Part1 = RightWing
	RightWingWeld.C0 = CFrame.new(0.1, 0.75, 0) * CFrame.Angles((math.pi / 2.25), (math.pi / 16), -(math.pi / 6))
	RightWingWeld.C1 = (CFrame.new(-1.75, -0.75, -2.75) + Vector3.new(-0.0625, 0.0625, 0.0625)) * CFrame.Angles((math.pi / 2), 0, 0)
	RightWingWeld.Parent = RightWing
	
	LeftWing.Parent = Tool
	RightWing.Parent = Tool
	
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	if HealthAfter > 0 then
		humanoid:TakeDamage(DamageValue)
	else
		humanoid:TakeDamage(math.huge)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	MouseDown = true
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.SideSwipe}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		AttackAnims = {Animations.R15LeftSlash, Animations.R15RightSlash, Animations.R15SideSwipe}
	end
	Attack(AttackAnims)
	if MouseDown then
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
	end
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
	Sounds.Unsheath:Play()
	Spawn(function()
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		local Animation = Animations.Equip
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Equip
		end
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolEquipped = true
	end)
end

function Unequipped()
	Flying = false
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({LeftWing, RightWing}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if not Down then
			MouseDown = false
		end
	elseif mode == "Flying" then
		local Mode = value.Flying
		if Mode then
			EquipWings(true)
			Flying = true
		else
			EquipWings(false)
			Flying = false
		end
	elseif mode == "SetWingSpan" then
		local Angle = value.Angle
		for i, v in pairs({LeftWingWeld, RightWingWeld}) do
			if v and v.Parent then
				v.DesiredAngle = (Angle * ((v == LeftWingWeld and -1) or 1))
				v.MaxVelocity = value.MaxVelocity
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

EquipWings(false)

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)