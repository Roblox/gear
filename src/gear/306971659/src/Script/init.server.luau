--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Sparks = Handle:WaitForChild("Sparks")

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

Functions = require(script:WaitForChild("Functions"))

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Slash1 = {Animation = Tool:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, AttackWindow = {Start = 0.2, End = 0.4}, Damage = {Min = 19, Max = 26}},
	Slash2 = {Animation = Tool:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, AttackWindow = {Start = 0.2, End = 0.4}, Damage = {Min = 19, Max = 26}},
	Slash3 = {Animation = Tool:WaitForChild("Slash3"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, AttackWindow = {Start = 0, End = 0.75}, Damage = {Min = 24, Max = 30}},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

TouchDamage = {Min = 0, Max = 0}

FirstClick = false
Clicks = 0

Gravity = 196.20
Rate = (1 / 60)

AttackEnabled = true
DashEnabled = true
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Enabled = true

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Player == player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		if not CurrentAnimation or CurrentAnimation.AttackDebounce then
			return
		end
		if CurrentAnimation.AttackWindow then
			if not CurrentAnimation.Start then
				return
			end
			local AnimationDuration = (tick() - CurrentAnimation.Start)
			if AnimationDuration < CurrentAnimation.AttackWindow.Start or AnimationDuration > CurrentAnimation.AttackWindow.End then
				return
			end
		end
		Spawn(function()
			local Animation = CurrentAnimation
			Animation.AttackDebounce = true
			wait(0.1)
			Animation.AttackDebounce = false
		end)
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)		
		local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		humanoid:TakeDamage(FinalizedDamage)
		if humanoid.Health <= 0 then
			Functions.DeathEffect(character)
		end
	end)
	return TouchedConnection
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local CurrentlyEquipped = true
		if ToolUnequipped1 then
			ToolUnequipped1:disconnect()
		end
		ToolUnequipped1 = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation.Animation
		local AttackAnimation = CurrentAnimation
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		local LeftSparks = FakeHandle:FindFirstChild("Sparks")
		for i, v in pairs({Sparks, LeftSparks}) do
			if v then
				v.Enabled = true
			end
		end
		AttackAnimation.Start = tick()
		Spawn(function()
			for i, v in pairs(Animation.Sounds) do
				if not CurrentlyEquipped then
					break
				end
				if v.Delay > 0 then
					wait(v.Delay)
				end
				if not CurrentlyEquipped then
					break
				end
				v.Sound:Play()
			end
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		if AttackAnimation.Duration and AttackAnimation.Duration > 0 then
			wait(AttackAnimation.Duration)
			AttackAnimation.Start = nil
			for i, v in pairs({Sparks, LeftSparks}) do
				if v then
					v.Enabled = false
				end
			end
			Spawn(function()
				InvokeClient("StopAnimation", AttackAnimation)
			end)
			CurrentAnimation = nil
		end
	end
end

function Dash(MousePosition)
	if not CheckIfAlive() or not ToolEquipped or not DashEnabled then
		return
	end
	DashEnabled = false
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = Functions.GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, 0, Mass),
		velocity = (Direction.lookVector * 100),
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
	}
	for i, v in pairs({BodyVelocity, BodyGyro}) do
		Debris:AddItem(v, 0.5)
		v.Parent = Torso
	end
	local AttackAnims = {
		{Animation = Animations.Slash3, Sounds = {{Delay = 0, Sound = Sounds.Slash}}}
	}
	Spawn(function()
		Attack(AttackAnims)
	end)
	--wait(Animations.Slash2.Duration)
	Spawn(function()
		wait(2)
		DashEnabled = true
	end)
end

function CreateDualWield()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if LeftArm then
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		FakeHandle.Mesh.MeshId = (BaseUrl .. "305827199")
		local LeftGrip = Create("Weld"){
			Part0 = LeftArm,
			Part1 = FakeHandle,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (Tool.Grip * CFrame.Angles(0, 0, -math.pi)),
			Parent = FakeHandle,
		}
		Blow(FakeHandle)
		FakeHandle.Parent = Tool
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.2)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		if Clicks == 1 or not DashEnabled then
			local AttackAnims = {
				{Animation = Animations.Slash1, Sounds = {{Delay = 0, Sound = Sounds.Slash}, {Delay = 0.25, Sound = Sounds.Slash}}},
				{Animation = Animations.Slash2, Sounds = {{Delay = 0, Sound = Sounds.Slash}, {Delay = 0.25, Sound = Sounds.Slash}}},
			}
			Attack(AttackAnims)
		elseif Clicks > 1 and DashEnabled then
			local MouseData = InvokeClient("MouseData")
			if MouseData and MouseData.Position then
				Dash(MouseData.Position)
			end
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		CreateDualWield()
		for i, v in pairs({"Left Arm", "Right Arm"}) do
			local Arm = Character:FindFirstChild(v)
			if Arm then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({FakeHandle, ToolUnequipped}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	Sparks.Enabled = false
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "q" then
		end
	end
end)

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)