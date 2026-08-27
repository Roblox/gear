--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
ContentProvider = game:GetService("ContentProvider")

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

Animations = {
	Scope = {Animation = Tool:WaitForChild("Scope"), FadeTime = 0.25, Weight = nil, Speed = 1, Duration = nil, Manual = true},
}

Sounds = {
	Zoom = Handle:WaitForChild("Zoom"),
}

Cursors = {
	Normal = "rbxasset://textures/GunCursor.png",
	Reloading = "rbxasset://textures/GunWaitCursor.png",
	Transparent = (BaseUrl .. "187746799"),
}

AnimationTracks = {}
LocalObjects = {}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

ScopeGui = script:WaitForChild("ScopeGui")

Rate = (1 / 60)

Zoomed = {Mode = false, Percent = 0}

ToolEquipped = false

function GetCamera()
	return game:GetService("Workspace").CurrentCamera
end

function SetCursor()
	if not PlayerMouse then
		return
	end
	if not Zoomed.Mode then
		PlayerMouse.Icon = ((Tool.Enabled and Cursors.Normal) or Cursors.Reloading)
	elseif Zoomed.Mode then
		PlayerMouse.Icon = Cursors.Transparent
	end
end

function SetLocalTransparency(Table)
	for i, v in pairs(LocalObjects) do
		if v.Object == Table.Object then
			Table.Object.LocalTransparencyModifier = Table.OriginalTransparency
			table.remove(LocalObjects, i)
		end
	end
	if not Table.Transparency then
		return
	end
	Table.OriginalTransparency = Table.Object.LocalTransparencyModifier
	table.insert(LocalObjects, Table)
	if ModifyTransparency then
		ModifyTransparency:disconnect()
	end
	ModifyTransparency = RunService.RenderStepped:connect(function()
		for i, v in pairs(LocalObjects) do
			if v.Object and v.Object.Parent then
				local CurrentTransparency = v.Object.LocalTransparencyModifier
				if ((not v.AutoUpdate and (CurrentTransparency == 1 or CurrentTransparency == 0)) or v.AutoUpdate) then
					v.Object.LocalTransparencyModifier = v.Transparency
				end
			else
				table.remove(LocalObjects, i)
			end
		end
	end)
end

function RotateCamera(RotX, RotY, SmoothRot, Duration)
	Spawn(function()
		local Camera = game:GetService("Workspace").CurrentCamera
		if SmoothRot then
			local Step = math.min(1.5 / math.max(Duration, 0), 90)
			local X = 0
			while true do
				local NewX = X + Step
				X = (NewX > 90 and 90 or NewX)
				local CamRot = (Camera.CoordinateFrame - Camera.CoordinateFrame.p)
				local CamDist = (Camera.CoordinateFrame.p - Camera.Focus.p).Magnitude
				local NewCamCF = (CFrame.new(Camera.Focus.p) * CamRot * CFrame.Angles(RotX / (90 / Step), RotY / (90 / Step), 0))
				Camera.CoordinateFrame = (CFrame.new(NewCamCF.p, NewCamCF.p + NewCamCF.lookVector) * CFrame.new(0, 0, CamDist))
				if X == 90 then
					break
				end
				RunService.Stepped:wait()
			end
		else
			local CamRot = (Camera.CoordinateFrame - Camera.CoordinateFrame.p)
			local CamDist = (Camera.CoordinateFrame.p - Camera.Focus.p).Magnitude
			local NewCamCF = (CFrame.new(Camera.Focus.p) * CamRot * CFrame.Angles(RotX, RotY, 0))
			Camera.CoordinateFrame = (CFrame.new(NewCamCF.p, NewCamCF.p + NewCamCF.lookVector) * CFrame.new(0, 0, CamDist))
		end
	end)
end

function SetMouseSensitivity(Sensitivity)
	local Camera = GetCamera()
	if MouseSensivityConnection then
		MouseSensivityConnection:disconnect()
	end
	local function EulerAnglesYX(cframe)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:components(cframe)
		return -math.asin(R12), ((math.abs(R12) > 0.99999 and -math.atan2(-R20, R00)) or -math.atan2(-R02, R22))
	end	
	local DirectionX, DirectionY = EulerAnglesYX(Camera.CoordinateFrame)	
	local function UpdateSensitivity()
		local CFrameX, CFrameY = EulerAnglesYX(Camera.CoordinateFrame)
		DirectionX = (DirectionX * (1 - Sensitivity) + (CFrameX + (math.pi * 2) * math.floor((DirectionX - CFrameX) / (math.pi * 2) + 0.5)) * Sensitivity)
		DirectionY = (DirectionY * (1 - Sensitivity) + (CFrameY + (math.pi * 2) * math.floor((DirectionY - CFrameY) / (math.pi * 2) + 0.5)) * Sensitivity)
		Camera.CoordinateFrame = (CFrame.Angles(0, DirectionY, 0) * CFrame.Angles(DirectionX, 0, 0) * CFrame.new(0, 0, 0.5) + Camera.Focus.p)
	end
	MouseSensivityConnection = RunService.RenderStepped:connect(UpdateSensitivity)
end

function Recoil()
	local StanceSway = 1
	local CurrentRecoil = 1
	local function Random(Min, Max, Accuracy)
		local Inverse = (1 / (Accuracy or 1))
		return (math.random(Min * Inverse, Max * Inverse) / Inverse)
	end
	local RecoilX = (math.rad(CurrentRecoil * Random(20, 50, 0.5)) * StanceSway)
	local RecoilY = (math.rad(CurrentRecoil * Random(0, 0, 0.5)) * StanceSway)
	RotateCamera(RecoilX, RecoilY, true, 0.06)
	Delay(0.125, function()
		--RotateCamera(-RecoilX, -RecoilY, true, 0.06)
		RotateCamera((-RecoilX / 5), (-RecoilY / 5), true,0.1)
	end)
end

function Zoom(In)
	local function Clamp(Number, Min, Max)
		return math.max(math.min(Max, Number), Min)
	end
	local function GetPercentage(Start, End, Number)
		return (((Number - Start) / (End - Start)) * 100)
	end
	local function Round(Number, RoundDecimal)
		local WholeNumber, Decimal = math.modf(Number)
		return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
	end
	local Camera = GetCamera()
	local FieldOfView = Round(Camera.FieldOfView, 0.5)
	local ClosestZoom = nil
	if type(In) == "number" then
		ClosestZoom = In
	else
		local ZoomExtents = {60, 30, 5}
		for i, v in pairs(ZoomExtents) do
			if not In and v < FieldOfView and (not ClosestZoom or math.abs(v - FieldOfView) < math.abs(ClosestZoom - FieldOfView)) then
				ClosestZoom = v
			elseif In and v > FieldOfView and (not ClosestZoom or math.abs(v - FieldOfView) < math.abs(ClosestZoom - FieldOfView)) then
				ClosestZoom = v
			end
		end
		if not ClosestZoom then
			table.sort(ZoomExtents, (function(a, b)
				return (a > b)
			end))
			ClosestZoom = ((not In and ZoomExtents[#ZoomExtents]) or ZoomExtents[1])
		end
	end
	local NewFieldOfView = Clamp((ClosestZoom or FieldOfView), 0, 70)
	local Sensitivity = ((GetPercentage(0, 60, NewFieldOfView) + 1) / 1000)
	Camera.FieldOfView = NewFieldOfView
	SetMouseSensitivity(Sensitivity)
	local ZoomPercent = Round(Clamp(GetPercentage(50, 0, NewFieldOfView), 0, 100), 0.5)
	if ScopeGuiCopy and ScopeGuiCopy.Parent then
		local ZoomPercentLabel = ScopeGuiCopy:FindFirstChild("ZoomPercent")
		if ZoomPercentLabel then
			ZoomPercentLabel.Value = tostring(ZoomPercent)
		end
		Zoomed.Percent = ZoomPercent
	end
	if Round(Camera.FieldOfView, 0.5) ~= FieldOfView then
		Sounds.Zoom:Play()
	end
end

function ResetZoom()
	Zoomed.Mode = false
	Spawn(function()
		SetAnimation("StopAnimation", Animations.Scope)
	end)
	if MouseSensivityConnection then
		MouseSensivityConnection:disconnect()
	end
	SetCursor()
	if Player then
		Player.CameraMode = Enum.CameraMode.Classic
	end
	SetLocalTransparency({Object = Handle, Transparency = nil, AutoUpdate = true})
	local Camera = GetCamera()
	Camera.FieldOfView = 70
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
end

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local function StopAnimation(Animation)
		for i, v in pairs(AnimationTracks) do
			if v.Animation == Animation then
				v.AnimationTrack:Stop(value.EndFadeTime)
				for i, v in pairs({v.KeyframeReached, v.TrackStopped}) do
					if v then
						v:disconnect()
					end
				end
				table.remove(AnimationTracks, i)
			end
		end
	end
	if mode == "PlayAnimation" then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				if value.Speed then
					v.AnimationTrack:AdjustSpeed(value.Speed)
					return
				elseif value.Weight or value.FadeTime then
					v.AnimationTrack:AdjustWeight(value.Weight, value.FadeTime)
					return
				else
					StopAnimation(value.Animation, false)
				end
			end
		end
		local AnimationMonitor = Create("Model"){}
		local TrackEnded = Create("StringValue"){Name = "Ended"}
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		local TrackStopped, KeyframeReached
		if value.PauseAt then
			KeyframeReached = AnimationTrack.KeyframeReached:connect(function(Keyframe)
				if Keyframe == value.PauseAt then
					AnimationTrack:AdjustSpeed(0)
					if KeyframeReached then
						KeyframeReached:disconnect()
					end
				end
			end)
		end
		if not value.Manual then
			TrackStopped = AnimationTrack.Stopped:connect(function()
				if TrackStopped then
					TrackStopped:disconnect()
				end
				StopAnimation(value.Animation, true)
				TrackEnded.Parent = AnimationMonitor
			end)
		end
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack, KeyframeReached = KeyframeReached, TrackStopped = TrackStopped})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
		if TrackStopped then
			AnimationMonitor:WaitForChild(TrackEnded.Name)
		end
		return TrackEnded.Name
	elseif mode == "StopAnimation" and value then
		StopAnimation(value.Animation)
	end
end

function KeyPressed(Key, Down)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if Key == "z" and Down and Tool.Enabled then
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if not PlayerGui then
			return
		end
		if Zoomed.Mode then
			Zoomed.Mode = false
			ResetZoom()
			if ScopeGuiCopy then
				Debris:AddItem(ScopeGuiCopy, 0)
			end
		elseif not Zoomed.Mode then
			Zoomed.Mode = true
			Spawn(function()
				SetAnimation("PlayAnimation", Animations.Scope)
			end)
			Humanoid.WalkSpeed = 10
			PlayerMouse.Icon = Cursors.Transparent
			SetLocalTransparency({Object = Handle, Transparency = 1, AutoUpdate = true})
			local Values = {
				{Name = "Tool", Class = "ObjectValue", Value = Tool},
				{Name = "ZoomPercent", Class = "NumberValue", Value = Tool},
			}
			ScopeGuiCopy = ScopeGui:Clone()
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = ScopeGuiCopy,
				}
			end
			ScopeGuiCopy.ScopeManager.Disabled = false
			ScopeGuiCopy.Parent = PlayerGui
			Player.CameraMode = Enum.CameraMode.LockFirstPerson
			Zoom(60)
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() then
		return
	end
	if Zoomed.Mode then
		Recoil()
	end
	local MouseData = OnClientInvoke("MousePosition")
	InvokeServer("MouseClick", {Down = true, Data = {TargetData = MouseData, ExtraData = {Zoom = Zoomed}}})
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		PlayerMouse = Mouse
		SetCursor()
		Mouse.WheelForward:connect(function()
			if Zoomed.Mode then
				Zoom(false)
			end
		end)
		Mouse.WheelBackward:connect(function()
			if Zoomed.Mode then
				Zoom(true)
			end
		end)
		Mouse.KeyDown:connect(function(Key)
			KeyPressed(Key, true)
		end)
		Mouse.KeyDown:connect(function(Key)
			KeyPressed(Key, false)
		end)
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("Animation") then
				ContentProvider:Preload(v.AnimationId)
			end
		end
	end)
end

function Unequipped()
	ResetZoom()
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	AnimationTracks = {}
	for i, v in pairs(LocalObjects) do
		if v.Object then
			v.Object.LocalTransparencyModifier = v.OriginalTransparency
		end
	end
	LocalObjects = {}
	for i, v in pairs({ModifyTransparency, MouseSensivityConnection, ScopeGuiCopy}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif v.Parent then
				Debris:AddItem(v, 0)
			end
		end
	end
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode then
		return
	end
	if mode == "PlayAnimation" and value then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	end
end

Tool.Changed:connect(function(Property)
	if Property == "Enabled" then
		SetCursor()
	end
end)

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)