--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
UserInputService = game:GetService("UserInputService")

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


Animations = {
	Sit = {Animation = Tool:WaitForChild("Sit"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

AnimationTracks = {}

Controls = {
	Forward = {
		Down = false,
		Keys = {Key = "w", ByteKey = 17}
	},
	Backward = {
		Down = false,
		Keys = {Key = "s", ByteKey = 18}
	},
	Left = {
		Down = false,
		Keys = {Key = "a", ByteKey = 20}
	},
	Right = {
		Down = false,
		Keys = {Key = "d", ByteKey = 19}
	}
}

	
Rate = (1 / 60)
	
Gravity = 196.20

Speed = {
	Acceleration = 20,
	Deceleration = 20,
	MovementSpeed = {Min = 35, Max = 35},
	TurnSpeed = {
		Speed = {Min = 3, Max = 3},
		TurnAlpha = 0.5,
		AlphaDampening = 0.2
	},
	Pitch = {Min = 40, Max = 40}
}

MaxSpeed = { --Maximum speed which the vehicle can move and turn at.
	Movement = Speed.MovementSpeed,
	Turn = Speed.TurnSpeed.Speed,
	Pitch = Speed.Pitch,
	Acceleration = Speed.Acceleration,
	Deceleration = Speed.Deceleration
}

CurrentSpeed = { --The speed which the vehicle is moving and turning at.
	Movement = 0,
	Turn = 0,
	Pitch = 0
}

ToolEquipped = false

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(Animations, i)
			end
		end
	end
end

function ThrustUpdater()
	Humanoid.WalkSpeed = 0
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	
	if Controls.Forward.Down then --Handle acceleration
		CurrentSpeed.Pitch = math.min(MaxSpeed.Pitch.Max, (CurrentSpeed.Pitch + Speed.TurnSpeed.TurnAlpha))
	end
	if Controls.Backward.Down then --Handle deceleration, if speed is more than 0, decrease quicker.
		CurrentSpeed.Pitch = math.min(MaxSpeed.Pitch.Min, (CurrentSpeed.Pitch - Speed.TurnSpeed.TurnAlpha))
	end
	
	if Controls.Left.Down then --Handle left turn speed
		CurrentSpeed.Turn = math.min(MaxSpeed.Turn.Min, (CurrentSpeed.Turn + Speed.TurnSpeed.TurnAlpha))
	end
	if Controls.Right.Down then --Handle right turn speed
		CurrentSpeed.Turn = math.max(-MaxSpeed.Turn.Max, (CurrentSpeed.Turn - Speed.TurnSpeed.TurnAlpha))
	end
	if math.abs(CurrentSpeed.Turn) > Speed.TurnSpeed.AlphaDampening then
		CurrentSpeed.Turn = (CurrentSpeed.Turn - ((Speed.TurnSpeed.AlphaDampening) * (math.abs(CurrentSpeed.Turn) / CurrentSpeed.Turn)))
	else 
		CurrentSpeed.Turn = 0		
	end
	if math.abs(CurrentSpeed.Pitch) > Speed.TurnSpeed.AlphaDampening then
		CurrentSpeed.Pitch = (CurrentSpeed.Pitch - (Speed.TurnSpeed.AlphaDampening * (math.abs(CurrentSpeed.Pitch) / CurrentSpeed.Pitch)))
	else 
		CurrentSpeed.Pitch = 0		
	end
	local LeanAmount = (-CurrentSpeed.Turn * (math.pi / 6) / 1.5)
	local Direction = Torso.CFrame.lookVector
	local XZDirection = Vector3.new(Direction.X, 0, Direction.Z).Unit
	ThrustForce.velocity = (Direction * CurrentSpeed.Movement)
	local XZNormal = (CFrame.Angles(0, (math.pi / 2), 0) * XZDirection)
	if math.abs(Direction.Y) > 0.85 then
		RotationForce.angularvelocity = (TurnGyro.cframe * Vector3.new(0, CurrentSpeed.Turn, 0))
		CurrentSpeed.Pitch = 0
	elseif not Controls.Forward.Down and not Controls.Backward.Down and not Controls.Left.Down and not Controls.Right.Down then
		local TurnForce = (CurrentSpeed.Pitch + (math.sin(tick() * 4) * 3))
		RotationForce.angularvelocity = (TurnGyro.cframe * Vector3.new((TurnForce * XZNormal.X), CurrentSpeed.Turn, (TurnForce * XZNormal.Z)))
	else
		RotationForce.angularvelocity = (TurnGyro.cframe * Vector3.new((CurrentSpeed.Pitch * XZNormal.X), CurrentSpeed.Turn, (CurrentSpeed.Pitch * XZNormal.Z)))
	end
	TurnGyro.cframe = CFrame.Angles((LeanAmount * XZDirection.X), 0, (LeanAmount * XZDirection.Z))
	wait(Rate)
end


function SetUpMovement()
	for i, v in pairs(CurrentSpeed) do
		CurrentSpeed[i] = 0
	end
	CurrentSpeed.Movement = MaxSpeed.Movement.Max
	for i, v in pairs(Controls) do
		v.Down = false
	end
	SetAnimation("PlayAnimation", Animations.Sit)
	TurnGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		Parent = Torso,
	}
	ThrustForce = Create("BodyVelocity"){
		maxForce = Vector3.new(math.huge, math.huge, math.huge),
		velocity = Vector3.new(0, 0, 0),
		Parent = Torso,
	}
	RotationForce = Create("BodyAngularVelocity"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		angularvelocity = Vector3.new(0, 0, 0),
		Parent = Torso,
	}
	Spawn(function()
		while CheckIfAlive() and TurnGyro.Parent and ThrustForce.Parent and RotationForce.Parent and ToolEquipped do
			ThrustUpdater()
			wait()
		end
	end)
end

function KeyPress(Key, Down)
	local ByteKey = string.byte(Key)
	for i, v in pairs(Controls) do
		if v.Keys.Key == Key or v.Keys.ByteKey == ByteKey then
			v.Down = Down
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Mouse.KeyDown:connect(function(Key)
		KeyPress(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		KeyPress(Key, false)
	end)
	Spawn(SetUpMovement)
	Humanoid:ChangeState(Enum.HumanoidStateType.None)
end

function Unequipped()
	for i, v in pairs(Controls) do
		v.Down = false
	end
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({TurnGyro, ThrustForce, RotationForce}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v.Parent then
			Debris:AddItem(v, 0)
		end
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
		Humanoid.PlatformStand = false
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	AnimationTracks = {}
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)