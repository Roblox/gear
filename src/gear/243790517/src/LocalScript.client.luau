--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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

Animations = {
	IdleMovement = {Animation = Tool:WaitForChild("IdleMovement"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15IdleMovement = {Animation = Tool:WaitForChild("R15IdleMovement"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Gravity = 196.20
Rate = (1 / 60)

Gliding = false
Flying = false
MouseDown = false
ToolEquipped = false

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
		PreventJump = Humanoid.Changed:connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
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

function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return ((1 - t) * a + t * b)
	else
		return (((math.sin((1 - t) * om) / math.sin(om)) * a) + (math.sin(t * om) / math.sin(om)) * b)
	end
end

function Glide(dt)
	local TurnAlpha = (math.pi * 0.4)
	local MaxSpeed = 40
	local DescentSpeed = 10
	local Camera = game:GetService("Workspace").Camera
	local CoordinateFrame = Camera.CoordinateFrame
	local DesiredHeading = (CoordinateFrame * CFrame.Angles(0.2, 0, 0)).lookVector
	local ThetaBetween = math.acos(math.min(1, DesiredHeading:Dot(CurrentFlightHeading)))
	local AllowedTheta = (TurnAlpha * dt)
	if ThetaBetween < AllowedTheta then
		CurrentFlightHeading = DesiredHeading
	else
		local Frac = (AllowedTheta / ThetaBetween)
		CurrentFlightHeading = Slerp(Frac, CurrentFlightHeading, DesiredHeading)
	end
	if CurrentFlightHeading ~= CurrentFlightHeading then
		Flying = false
	end
	local SpeedMod = ((-CurrentFlightHeading.y + 1) / 2)
	local LiftMod = math.min(0, CurrentFlightHeading.y)
	local DirXZ = Vector3.new(CurrentFlightHeading.x, 0, CurrentFlightHeading.z).unit
	local Tilt = math.min(4, math.max(-4, Torso.RotVelocity.y))
	BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
	BodyVelocity.velocity = (DirXZ * SpeedMod * MaxSpeed + Vector3.new(0, LiftMod, 0) * DescentSpeed)
	BodyGyro.cframe = (CFrame.new(Vector3.new(), CurrentFlightHeading) * CFrame.Angles(0, 0, (Tilt / 8)))
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
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyVelocity.velocity = Vector3.new(0, 0, 0)
		BodyVelocity.Parent = Torso
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(0, 0, 0)
		BodyGyro.Parent = Torso
		local Velocity = 50
		Spawn(function()
			InvokeServer("BeginFlight")
		end)
		DisableJump(true)
		while Flying and MouseDown and ToolEquipped and CheckIfAlive() and Jetpack and Jetpack.Parent do
			if not Gliding then
				BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				local CoordinateFrame = Camera.CoordinateFrame
				BodyGyro.cframe = CoordinateFrame
				BodyVelocity.maxForce = Vector3.new(0, BodyVelocity.P, 0)
				BodyVelocity.velocity = Vector3.new(0, CoordinateFrame.lookVector.unit.y, 0) * Velocity
			end
			wait(Rate)
		end			
		Flying = false
		DisableJump(false)
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
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
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
	JumpRequest = UserInputService.JumpRequest:connect(function()
		LastJump = tick()
		if FlightInProgress then
			return
		end
		if MouseDown and Flying and CheckIfAlive() and ToolEquipped and BodyVelocity and BodyVelocity.Parent and BodyGyro and BodyGyro.Parent then
			FlightInProgress = true
			local TorsoCFrame = Torso.CFrame
			local Dir = Vector3.new(TorsoCFrame.lookVector.x, 0, TorsoCFrame.lookVector.z)
			CurrentFlightHeading = Dir.unit
			BodyGyro.cframe = CFrame.new(Vector3.new(), CurrentFlightHeading)
			local LastTime = tick()
			Gliding = true
			Humanoid.PlatformStand = true
			Spawn(function()
				InvokeServer("EndFlight")
			end)
			Spawn(function()
				InvokeServer("BeginGlide")
			end)
			while MouseDown and Flying and CheckIfAlive() and ToolEquipped do
				if (tick() - LastJump) > 0.25 then
					break
				end
				local ThisTime = tick()
				local dt = (ThisTime - LastTime)
				LastTime = ThisTime
				Glide(dt)
				wait(Rate)
			end 
			Humanoid.PlatformStand = false
			Gliding = false
			FlightInProgress = false
			Spawn(function()
				InvokeServer("EndGlide")
			end)
			if MouseDown and Flying and CheckIfAlive() and ToolEquipped then
				Spawn(function()
					InvokeServer("BeginFlight")
				end)
			end
		end
	end)
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
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			SetAnimation("PlayAnimation", Animations.IdleMovement)
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			SetAnimation("PlayAnimation", Animations.R15IdleMovement)
		end
	end
end

function Unequipped()
	Flying = false
	Gliding = false
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
	for i, v in pairs({HumanoidDied, JumpRequest, DescendantAdded, DescendantRemoving, PreventJump}) do
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

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)