--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Rate = (1 / 60)

CameraSpeed = {
	X = 20,
	Z = 25,
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

Flight = {
	JumpCount = 0,
	LastJump = 0,
	Active = false,
}

ToolEquipped = false

function InitiateFlight()
	Flight.JumpCount = 0
	Flight.LastJump = 0
	Flight.Active = true
	
	FlightSpin = Instance.new("BodyGyro")
	FlightSpin.Name = "FlightSpin"
	FlightSpin.P = 1000000
	FlightSpin.maxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
	FlightSpin.cframe = RootPart.CFrame
	
	FlightPower = Instance.new("BodyVelocity")
	FlightPower.Name = "FlightPower"
	FlightPower.velocity = Vector3.new(0, 0, 0)
	FlightPower.P = 1000000
	FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
	FlightPower.P = 10000
	
	FlightHold = Instance.new("BodyPosition")
	FlightHold.Name = "FlightHold"
	FlightHold.P = 100000
	FlightHold.maxForce = Vector3.new(0, 0, 0)
	FlightHold.position = RootPart.Position
	
	FlightSpin.Parent = RootPart
	FlightPower.Parent = RootPart
	FlightHold.Parent = RootPart
	
	local Camera = game:GetService("Workspace").CurrentCamera
	Camera.CameraType = Enum.CameraType.Track
	Flying = true
	Humanoid.WalkSpeed = 0
	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false
	DisableJump(true)
	RootPart.Velocity = Vector3.new(0, 0, 0)
	RootPart.RotVelocity = Vector3.new(0, 0, 0)
	local IsMoving = false
	while Flight.Active and FlightSpin.Parent and FlightPower.Parent and FlightHold.Parent and CheckIfAlive() do
		local NewPush = Vector3.new(0, 0, 0)
		local ForwardVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
		local SideVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0))
		NewPush = (NewPush + (((Controls.Forward.Mode and not Controls.Backward.Mode) and (ForwardVector * CameraSpeed.Z)) or ((not Controls.Forward.Mode and Controls.Backward.Mode) and (ForwardVector * CameraSpeed.Z * -1)) or NewPush))
		NewPush = (NewPush + (((Controls.Left.Mode and not Controls.Right.Mode) and (SideVector * CameraSpeed.X)) or ((not Controls.Left.Mode and Controls.Right.Mode) and (SideVector * CameraSpeed.X * -1)) or NewPush))
		FlightSpin.cframe = CFrame.new(Vector3.new(0, 0, 0), ForwardVector)
		if NewPush.magnitude < 1 then
			FlightHold.maxForce = Vector3.new((FlightHold.P * 100), (FlightHold.P * 100), (FlightHold.P * 100))
			FlightPower.maxForce = Vector3.new(0, 0, 0)
			if IsMoving then
				FlightHold.position = RootPart.Position
			end
			IsMoving = false
		else
			IsMoving = true
			FlightHold.maxForce = Vector3.new(0, 0, 0)
			FlightPower.maxForce = Vector3.new((FlightPower.P * 100), (FlightPower.P * 100), (FlightPower.P * 100))
		end
		FlightPower.velocity = NewPush
		wait(Rate)
	end
	if CheckIfAlive() then
		EndFlight()
	end
end

function EndFlight()
	Flight.JumpCount = 0
	Flight.LastJump = 0
	Flight.Active = false
	for i, v in pairs({FlightSpin, FlightPower, FlightHold}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	local Camera = game:GetService("Workspace").CurrentCamera
	Camera.CameraType = Enum.CameraType.Custom
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
		DisableJump(false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
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

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function KeyPress(Key, Down)
	local Key = string.lower(Key)
	local ByteKey = string.byte(Key)
	if Key == " " and Down then
		if Flight.Active then
			EndFlight()
		else
			local Now = tick()
			Flight.JumpCount = (Flight.JumpCount + 1)
			if (Now - Flight.LastJump) <= 0.5 then
				if Flight.JumpCount >= 2 then
					InitiateFlight()
				else
					Flight.JumpCount = 0
				end
			end
			Flight.LastJump = Now
		end
	else
		for i, v in pairs(Controls) do
			if Key == v.Keys.Key or ByteKey == v.Keys.ByteKey then
				Controls[i].Mode = Down
			end
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	Mouse.KeyDown:connect(function(Key)
		KeyPress(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		KeyPress(Key, false)
	end)
end

function Unequipped()
	for i, v in pairs({PreventJump}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Controls) do
		Controls[i].Mode = false
	end
	Spawn(function()
		EndFlight()
	end)
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)