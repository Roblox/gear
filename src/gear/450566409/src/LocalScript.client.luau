--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


Animations = {}

AnimationObjs = {
	Fly = {Animation = Tool:WaitForChild("Fly"), FadeTime = 0.3, Weight = nil, Speed = nil},
	--Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Fly = {Animation = Tool:WaitForChild("R15Fly"), FadeTime = 0.3, Weight = nil, Speed = nil},
}

Rate = (1 / 60)

IND = tostring(0 / 0)

Flying = false
ToolEquipped = false

function BeginFlight()
	local Camera = game:GetService("Workspace").CurrentCamera
	Humanoid.Jump = true
	wait(0.2)
	if Flying then
		return
	end
	if Character then
		local RightArm = Character:FindFirstChild('Right Arm') or Character:FindFirstChild('RightHand')
		if RightArm then
			local RightGrip = RightArm:FindFirstChild('RightGrip')
			if RightGrip then
				RightGrip.C1 = Handle.RightGripAttachment.CFrame
			end
		end
	end
	Flying = true
	Camera.CameraSubject = Handle
	Camera.CameraType = Enum.CameraType.Track
	Humanoid.Sit = true
	FlyingGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(0, 0, 0),
		cframe = Torso.CFrame,
		Parent = Torso,
	}
	FlyingForce = Create("BodyForce"){
		force = Vector3.new(0, 0, 0),
		Parent = Torso,
	}
	for i = 0, 1, 0.1 do
		FlyingGyro.maxTorque = Vector3.new((i * 10000), (i * 10000), (i * 10000))
	end
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			SetAnimation("PlayAnimation", AnimationObjs.R15Fly)
		else
			SetAnimation("PlayAnimation", AnimationObjs.Fly)
		end
	end
	DesiredFlightCFrame = (Torso.CFrame * CFrame.Angles(0, 0, 0.01))
	Gui.Frame.Message.Text =
		"Click and Hold to direct yourself.\n"..
		"Jump to stop gliding."
end

function EndFlight()
	Flying = false
	local Camera = game:GetService("Workspace").CurrentCamera
	Camera.CameraSubject = Character
	Camera.CameraType = Enum.CameraType.Custom
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			SetAnimation("StopAnimation", AnimationObjs.R15Fly)
		else
			SetAnimation("StopAnimation", AnimationObjs.Fly)
		end
	end
	if Character then
		local RightArm = Character:FindFirstChild('Right Arm') or Character:FindFirstChild('RightHand')
		if RightArm then
			local RightGrip = RightArm:FindFirstChild('RightGrip')
			if RightGrip then
				RightGrip.C1 = Tool.Grip
			end
		end
	end	
	Humanoid.Sit = false
	for i, v in pairs({FlyingGyro, FlyingForce}) do
		if v and v.Parent then
			Debris:AddItem(v, 0)
		end
	end
	--Torso.Velocity = Vector3.new(0,0,0)
	Torso.RotVelocity = Vector3.new(0,0,0)
	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	Gui.Frame.Message.Text = "Click to Glide."
end

Handle.Touched:connect(function(part)
	if ToolEquipped and not part:IsDescendantOf(Character) and Flying then
		EndFlight()
	end
end)

function GetMassOf(model)
	if model:IsA("BasePart") then
		return model:GetMass()
	else
		local mass = 0
		for _, ch in pairs(model:GetChildren()) do
			mass = mass + GetMassOf(ch)
		end
		return mass
	end
end

function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return ((1 - t) * a + t * b)
	else
		return ((math.sin((1 - t) * om ) / math.sin(om)) * a + (math.sin(t * om) / math.sin(om)) * b)
	end
end

function SetAnimation(mode, value)
	if not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" and value and ToolEquipped then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(Animations, i)
			end
		end
	end
end

function KeyPressed(Key, Down)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	PlayerGui = Player:FindFirstChild("PlayerGui")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	PlayerMouse.KeyDown:connect(function(Key)
		KeyPressed(Key, true)
	end)
	PlayerMouse.KeyUp:connect(function(Key)
		KeyPressed(Key, false)
	end)
	--SetAnimation("PlayAnimation", AnimationObjs.Hold)
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local MouseDown = false
	local KeyState
	PlayerMouse.Button1Down:connect(function()
		MouseDown = true
		if not Flying then
			BeginFlight()
		end
	end)
	PlayerMouse.Button1Up:connect(function()
		MouseDown = false
	end)
	PlayerMouse.KeyDown:connect(function(key)
		if key == " " then
			if Flying then
				EndFlight()
			end
		end
	end)
	--
	Gui = Create("ScreenGui"){
		Create("Frame"){
			Name = "Frame",
			Style = "RobloxRound",
			Position = UDim2.new(0.5, -125, 1, -170),
			Size = UDim2.new(0, 250, 0, 80),
			Create("TextLabel"){
				Name = "Message",
				TextWrapped = true,
				BackgroundTransparency = 1,
				Font = Enum.Font.Arial,
				FontSize = Enum.FontSize.Size14,
				TextColor3 = Color3.new(0.9, 0.9, 0.9),
				Text = "Click to Glide",
				Size = UDim2.new(1, 0, 1, 0),
			},
		},
	}
	if PlayerGui then
		Gui.Parent = PlayerGui
	end
	--
	local LastTime = tick()
	local Origin = Vector3.new(0, 0, 0)
	while ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
		local Now = tick()
		local dt = Now - LastTime
		LastTime = Now
		--
		if Flying then
			local Camera = game:GetService("Workspace").CurrentCamera
			local moveDir = (Camera.CFrame * CFrame.Angles(0.6, 0.6, 0.6))
			moveDir = CFrame.new(moveDir.p, Mouse.Hit.p)
			if MouseDown then
				local theta = math.acos(DesiredFlightCFrame.lookVector:Dot(moveDir.lookVector))
				local frac = math.min(1, (1.5 * dt / theta))
				unit = Slerp(frac, DesiredFlightCFrame.lookVector, moveDir.lookVector)
				DesiredFlightCFrame = CFrame.new(Camera.CFrame.p, PlayerMouse.Hit.p)
			end
			if tostring(unit.X) == IND or tostring(unit.Y) == IND or tostring(unit.Z) == IND then
			else
				--
				local velo = Torso.Velocity
				local veloXZ = (velo - Vector3.new(0, velo.y, 0))
				--
				local dir = DesiredFlightCFrame.lookVector
				local dirXZ = (dir - Vector3.new(0, dir.y, 0)).unit
				--
				FlyingGyro.cframe = DesiredFlightCFrame *
				CFrame.Angles(0, 0, Torso.RotVelocity.y/3 * (1-math.abs(dir.y)^2))*
				CFrame.Angles(-math.pi/2, 0, 0)
				--
				local headingForceFactor = -dir.y -- heading up => negative force
				local liftForceFactor = dir.y --hading up => positive lift
				--
				local forwardsSpeed = math.max(0, velo.magnitude)
				--
				local weight = (GetMassOf(Character) * 20 * 9.81)
				--
				local dragForce = ((velo.magnitude/10)^2 * weight)
				local dragForceY = ((velo.y/15)^2 * weight)
				local dragForceXZ = ((veloXZ.magnitude/35)^2 * weight)
				--
				local suspendFactor = 0
				if dir.y < 0 then
					suspendFactor = (-dir.y)^2
				end
				--
				local force = Vector3.new(0, weight*(1.0 - suspendFactor + 0.3*liftForceFactor), 0)
				+ (dirXZ * (weight*1.0 * math.max(0, (0.5*headingForceFactor+0.6))))
				- (veloXZ.unit * dragForceXZ)
				- (Vector3.new(0, velo.y, 0).unit * dragForceY)
				if tostring(force.X) == IND or tostring(force.Y) == IND or tostring(force.Z) == IND then
				else
					FlyingForce.force = force
				end
			end
		end
		RunService.RenderStepped:wait()
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	if Flying then
		EndFlight()
	end
	if Gui then
		Gui:Destroy()
	end
	Animations = {}
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)