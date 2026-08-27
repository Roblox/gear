--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Animations = {}


AnimationsBin = Tool:WaitForChild("Animations")
Anims = {
	R6Idle = {Animation = AnimationsBin:WaitForChild("R6Idle"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Idle = {Animation = AnimationsBin:WaitForChild("R15Idle"), FadeTime = nil, Weight = nil, Speed = nil},
}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

CamSpeedZ = 60
CamSpeedX = 40

Controls = {
	Forward = false,
	Backwardward = false,
	Left = false,
	Right = false,
}

hover = -0.1

Rate = (1 / 60)

ToolEquipped = false

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
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(Animations, i)
			end
		end
	end
end

function HandleMovementFrame()
	local NewPush = Vector3.new(0, 0, 0)
	local Camera = game:GetService("Workspace").CurrentCamera
	local ForwardVector = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))

	if Controls.Forward and not Controls.Backward then
		NewPush = (ForwardVector * CamSpeedZ)
	end
	if Controls.Backward and not Controls.Forward then
		NewPush = (NewPush + ForwardVector * -CamSpeedZ)
	end
	if Controls.Left and not Controls.Right then
		NewPush = (NewPush + Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * CamSpeedX)
	end
	if Controls.Right and not Controls.Left then
		NewPush = (NewPush + Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * CamSpeedX)
	end

	FlightSpin.cframe = CFrame.new(Vector3.new(0, 0, 0), ForwardVector) --Have torso face forward
	if NewPush.Magnitude < 1 then
		FlightHold.maxForce = Vector3.new(FlightHold.P, FlightHold.P, FlightHold.P)
		FlightPower.maxForce = Vector3.new(0, 0, 0)
		if Torso then
			FlightHold.position = Torso.Position
		end
	else
		FlightHold.maxForce = Vector3.new(0, 0, 0)
		FlightPower.maxForce = Vector3.new((FlightPower.P * 100), (FlightPower.P * 100), (FlightPower.P * 100))
	end
	FlightPower.velocity = NewPush
end

function KeyPressed(Key, Down)	
	local Key = string.lower(Key)
	if Key == "w" then
		Controls.Forward = Down
	elseif Key == "a" then
		Controls.Left = Down
	elseif Key == "s" then
		Controls.Backward = Down
	elseif Key == "d" then
		Controls.Right = Down
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
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs(Controls) do
		Controls[i] = false
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
	elseif mode == "MouseData" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
	elseif mode == "Fly" then
		local Flying = value.Flying
		if not Flying then
			if FlyLoop then
				FlyLoop:disconnect()
			end
			SetAnimation("StopAnimation", Anims.R6Idle)
			SetAnimation("StopAnimation", Anims.R15Idle)
			CurrentlyFlying = false
		elseif Flying then
			if FlyLoop then
				FlyLoop:disconnect()
			end
			CurrentlyFlying = true
			FlightPower = Torso:FindFirstChild("FlightPower")
			FlightSpin = Torso:FindFirstChild("FlightSpin")
			FlightHold = Torso:FindFirstChild("FlightHold")
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
				SetAnimation("PlayAnimation", Anims.R6Idle)
			else
				SetAnimation("PlayAnimation", Anims.R15Idle)
			end
			FlyLoop = RunService.RenderStepped:connect(function(Step)
				if not CurrentlyFlying then
					FlyLoop:disconnect()
				end
				HandleMovementFrame()
			end)
		end
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)