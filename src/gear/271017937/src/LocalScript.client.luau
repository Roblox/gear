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

LastJump = 0

ToolEquipped = false

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end
	
function CheckIntangible(Object)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Object and Object.Parent then
		if CheckTableForString(ProjectileNames, Object.Name) then
			return true
		end
		local ObjectParent = Object.Parent
		local Character = ObjectParent.Parent
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid.Health > 0 and ObjectParent:IsA("Hat") then
			return true
		end
	end
	return false
end
	
function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

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

function HandleMovementFrame()
	Humanoid.WalkSpeed = 0
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	local CameraSpeed = {
		X = 30,
		Z = 40,
	}
	local NewPush = Vector3.new(0, 0, 0)
	local Camera = game:GetService("Workspace").CurrentCamera
	local CoordinateFrame = Camera.CoordinateFrame
	local ForwardVector = CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
	local SideVector = CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0))
	if Controls.Forward.Down and not Controls.Backward.Down then
		NewPush = (NewPush + (ForwardVector * CameraSpeed.Z))
	elseif Controls.Backward.Down and not Controls.Forward.Down then
		NewPush = (NewPush + (ForwardVector * -CameraSpeed.Z))
	end
	if Controls.Left.Down and not Controls.Right.Down then
		NewPush = (NewPush + (SideVector * CameraSpeed.X))
	elseif Controls.Right.Down and not Controls.Left.Down then
		NewPush = (NewPush + (SideVector * -CameraSpeed.X))
	end
	FlightSpin.cframe = CFrame.new(Vector3.new(0, Torso.Position.Y, 0), Vector3.new(ForwardVector.X, Torso.Position.Y, ForwardVector.Z))
	if NewPush.Magnitude < 1 then
		FlightPower.maxForce = Vector3.new(0, 0, 0)
	else
		FlightPower.maxForce = Vector3.new((FlightPower.P * 100), 0, (FlightPower.P * 100))
	end
	FlightPower.velocity = NewPush
end


function SetUpMovement()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	SetAnimation("PlayAnimation", Animations.Sit)
	FlightSpin = Create("BodyGyro"){
		Name = "BodyGyro",
		P = 10000,
		maxTorque = Vector3.new(1000000, 1000000, 1000000),
		Parent = Torso,
	}
	FlightPower = Create("BodyVelocity"){
		Name = "BodyVelocity",
		velocity = Vector3.new(0, 0, 0),
		maxForce = Vector3.new(1000000, 0, 1000000),
		P = 10000,
		Parent = Torso,
	}
	Spawn(function()
		while CheckIfAlive() and FlightSpin.Parent and FlightPower.Parent and ToolEquipped do
			HandleMovementFrame()
			wait()
		end
	end)
end

function KeyPress(Key, Down)
	local ByteKey = string.byte(Key)
	if Key == " " and Down then
		local Now = tick()
		if (Now - LastJump) >= 1.5 then
			local RayHit, RayPos, RayNormal = CastRay(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size * 3), {Character}, false)
			if RayHit then
				LastJump = Now
				Torso.Velocity = (Torso.Velocity * Vector3.new(1, 0, 1) + Vector3.new(0, 50, 0))
			end
		end
	else
		for i, v in pairs(Controls) do
			if v.Keys.Key == Key or v.Keys.ByteKey == ByteKey then
				v.Down = Down
			end
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
	for i, v in pairs({FlightSpin, FlightPower}) do
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