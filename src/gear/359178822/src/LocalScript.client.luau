--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

AnimationTracks = {}
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputButton = Instance.new("ImageButton")
InputButton.Name = "InputButton"
InputButton.Image = ""
InputButton.BackgroundTransparency = 1
InputButton.ImageTransparency = 1
InputButton.Size = UDim2.new(1, 0, 1, 0)
InputButton.Parent = InputCheck

Sounds = {
	Wind = Handle:WaitForChild("Wind"),
}

Gravity = workspace.Gravity
Rate = (1 / 60)

Flying = false
MouseDown = false
ToolEquipped = false

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
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
				table.remove(AnimationTracks, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(AnimationTracks, i)
			end
		end
	end
end

function DisableJump(Boolean)
	if PreventJump then
		PreventJump:disconnect()
	end
	if Boolean then
		PreventJump = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			Humanoid.Jump = false
		end)
	end
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function GetTotalMass(Object)
	local Parts = GetAllConnectedParts(Object)
	local Mass = 0
	for i, v in pairs(Parts) do
		if v:IsA("BasePart") then
			Mass = (Mass + v:GetMass())
		end
	end
	Mass = (Mass * Gravity)
	return Mass
end

function MousePressed(Down)
	if Down and not MouseDown then
		local Jetpack = Tool:FindFirstChild("JetpackModel")
		if not Jetpack then
			return
		end
		MouseDown = true
		local Camera = game:GetService("Workspace").CurrentCamera
		for i, v in pairs({BodyVelocity, BodyGyro, DescendantAdded, DescendantRemoving}) do
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v and v.Parent then
				v:Destroy()
			end
		end
		DescendantAdded = Character.DescendantAdded:connect(function(Object)
			if not CheckIfAlive() then
				return
			end
			local Mass = GetTotalMass(Torso)
			BodyVelocity.P = (Mass * 10)
			BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
		end)
		DescendantRemoving = Character.DescendantRemoving:connect(function(Object)
			if not CheckIfAlive() then
				return
			end
			local Mass = GetTotalMass(Torso)
			BodyVelocity.P = (Mass * 10)
			BodyVelocity.maxForce = Vector3.new(0, BodyVelocity.P, 0)
		end)
		Flying = true
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.P = GetTotalMass(Torso) * 10
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyVelocity.velocity = Vector3.new(0, 0, 0)
		BodyVelocity.Parent = Torso
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(0, 0, 0)
		BodyGyro.D = 50
		BodyGyro.P = 10000
		BodyGyro.Parent = Torso
		Spawn(function()
			InvokeServer("BeginFlight")
		end)
		DisableJump(true)
		while Flying and MouseDown and ToolEquipped and CheckIfAlive() and Jetpack and Jetpack.Parent do
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			local CoordinateFrame = Camera.CFrame
			local RayHit, RayPos, RayNormal = CastRay(RootPart.Position, Vector3.new(0, -1, 0), (RootPart.Size.Y * 15), {Character})
			if not RayHit then
				BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
				local TorsoCFrame = RootPart.CFrame
				local Dir = (TorsoCFrame.lookVector * Vector3.new(1, 0, 1))
				local FlightDirection = Camera.CFrame.lookVector
				FlightDirection = (FlightDirection * Vector3.new(1, 0, 1))
				local FlightCFrame = (CFrame.new(RootPart.Position, (RootPart.CFrame + FlightDirection * 2).p) * CFrame.Angles(-(math.pi / 2), (math.pi * 2), 0))		
				BodyVelocity.velocity = (CoordinateFrame.lookVector * 75)
				if tostring(FlightCFrame.p.X) ~= "-1.#IND" and FlightCFrame.p.Y ~= "-1.#IND" and FlightCFrame.p.Z ~= "-1.#IND" then
					BodyGyro.cframe = FlightCFrame
				end
				if not Sounds.Wind.IsPlaying then
					Sounds.Wind:Play()
				end
			else
				BodyVelocity.maxForce = Vector3.new(0, BodyVelocity.P, 0)
				if Sounds.Wind.IsPlaying then
					Sounds.Wind:Stop()
				end
				BodyVelocity.velocity = ((CoordinateFrame.lookVector.Unit * Vector3.new(0, 1, 0)) * 50)
				BodyGyro.cframe = CoordinateFrame
			end
			wait(Rate)
		end			
		Flying = false
		DisableJump(false)
		Sounds.Wind:Stop()
		Spawn(function()
			InvokeServer("EndFlight")
		end)
		if CheckIfAlive() then
			Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
		for i, v in pairs({BodyVelocity, BodyGyro, DescendantAdded, DescendantRemoving}) do
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v and v.Parent then
				v:Destroy()
			end
		end
	elseif not Down and MouseDown then
		MouseDown = false
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	RootPart = Humanoid.RootPart
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	Mouse.Button1Down:connect(function()
		MousePressed(true)
	end)
	Mouse.Button1Up:connect(function()
		MousePressed(false)
	end)
	HumanoidDied = Humanoid.Died:connect(function()
		Unequipped()
	end)
	local LastJump = 0
	local FlightInProgress = false
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		if UserInputService.TouchEnabled then
			InputCheckClone = InputCheck:Clone()
			InputCheckClone.InputButton.InputBegan:connect(function()
				MousePressed(true)
			end)
			InputCheckClone.InputButton.InputEnded:connect(function()
				MousePressed(false)
			end)
			InputCheckClone.Parent = PlayerGui
		end
	end
--	SetAnimation("PlayAnimation", Animations.IdleMovement)
end

function Unequipped()
	Flying = false
	if CheckIfAlive() then
		Humanoid.PlatformStand = false
	end
	if InputCheckClone and InputCheckClone.Parent then
		InputCheckClone:Destroy()
	end
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({BodyVelocity, BodyGyro}) do
		if v and v.Parent then
			Debris:AddItem(v, 0.1)
		end
	end
	for i, v in pairs({HumanoidDied, DescendantAdded, DescendantRemoving, PreventJump}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v and v.Parent then
			v:Destroy()
		end
	end
	AnimationTracks = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(mode, value)
		return ServerReturn
	end)
end

function OnClientInvoke(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	end
end

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)
ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)