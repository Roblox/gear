Tool = script.Parent

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

CameraSpeed = {
	X = 40,
	Z = 60
}

Controls = {
	Forward = {
		Mode = false,
		Keys = {Key = "w", ByteKey = 17}
	},
	Backward = {
		Mode = false,
		Keys = {Key = "s", ByteKey = 18}
	},
	Left = {
		Mode = false,
		Keys = {Key = "a", ByteKey = 20}
	},
	Right = {
		Mode = false,
		Keys = {Key = "d", ByteKey = 19}
	},
}

ToolEquipped = false

function HandleFlightControl()
	if not CheckIfAlive() then
		return
	end
	if FightMonitor then
		FightMonitor:Disconnect()
	end
	FightMonitor = Torso.ChildAdded:Connect(function(Child)
		if Flying then
			return
		end
		if Child.Name == "FlightHold" then
			local FlightSpin = Torso:FindFirstChild("FlightSpin")
			local FlightPower = Torso:FindFirstChild("FlightPower")
			local FlightHold = Torso:FindFirstChild("FlightHold")
			if not FlightSpin or not FlightPower or not FlightHold then
				return
			end
			Flying = true
			Humanoid.WalkSpeed = 0
			Humanoid.PlatformStand = true
			Humanoid.AutoRotate = false
			DisableJump(true)
			Torso.Velocity = Vector3.new(0, 0, 0)
			Torso.RotVelocity = Vector3.new(0, 0, 0)
			while Flying and FlightSpin.Parent and FlightPower.Parent and FlightHold.Parent and CheckIfAlive() do
				local NewPush = Vector3.new(0, 0, 0)
				local ForwardVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
				local SideVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0))
				NewPush = (NewPush + (((Controls.Forward.Mode and not Controls.Backward.Mode) and (ForwardVector * CameraSpeed.Z)) or ((not Controls.Forward.Mode and Controls.Backward.Mode) and (ForwardVector * CameraSpeed.Z * -1)) or NewPush))
				NewPush = (NewPush + (((Controls.Left.Mode and not Controls.Right.Mode) and (SideVector * CameraSpeed.X)) or ((not Controls.Left.Mode and Controls.Right.Mode) and (SideVector * CameraSpeed.X * -1)) or NewPush))
				FlightSpin.cframe = CFrame.new(Vector3.new(0, 0, 0), ForwardVector)
				if NewPush.magnitude < 1 then
					FlightHold.maxForce = Vector3.new(FlightHold.P, FlightHold.P, FlightHold.P)
					FlightPower.maxForce = Vector3.new(0, 0, 0)
					FlightHold.position = Torso.Position
				else
					FlightHold.maxForce = Vector3.new(0, 0, 0)
					FlightPower.maxForce = Vector3.new((FlightPower.P * 100), (FlightPower.P * 100), (FlightPower.P * 100))
				end
				FlightPower.velocity = NewPush
				wait(Rate)
			end
			Flying = false
			if CheckIfAlive() then
				Torso.Velocity = Vector3.new(0, 0, 0)
				Torso.RotVelocity = Vector3.new(0, 0, 0)
				Humanoid.WalkSpeed = 16
				Humanoid.PlatformStand = false
				Humanoid.AutoRotate = true
				DisableJump(false)
				Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end)
end

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
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
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function DisableJump(Boolean)
	if PreventJump then
		PreventJump:Disconnect()
	end
	if Boolean then
		PreventJump = Humanoid.Changed:connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function KeyPress(Key, Down)
	local Key = string.lower(Key)
	local ByteKey = string.byte(Key)
	for i, v in pairs(Controls) do
		if Key == v.Keys.Key or ByteKey == v.Keys.ByteKey then
			Controls[i].Mode = Down
		end
	end
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
	Mouse.KeyDown:Connect(function(Key)
		KeyPress(Key, true)
	end)
	Mouse.KeyUp:Connect(function(Key)
		KeyPress(Key, false)
	end)
	spawn(HandleFlightControl)
end

function Unequipped()
	Flying = false
	LocalObjects = {}
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, FightMonitor}) do
		if v then
			v:Disconnect()
		end
	end
	for i, v in pairs(Controls) do
		Controls[i].Mode = false
	end
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
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
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)