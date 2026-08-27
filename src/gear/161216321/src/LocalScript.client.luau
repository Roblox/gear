--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
LocalObjects = {}

Speed = {
	CurrentSpeed = 2,
	MaxSpeed = 50
}

Jumping = {
	JumpTick = 0,
	Jumps = 0,
	JumpTime = 0.25,
	JumpsRequired = 2
}

Controls = {
	Forward = {Number = 0, Numbers = {On = -1, Off = 0}, Keys = {"W", 17}},
	Backward = {Number = 0, Numbers = { On = 1, Off = 0}, Keys = {"S", 18}},
	Left = {Number = 0, Numbers = {On = -1, Off = 0}, Keys = {"A", 20}},
	Right = {Number = 0, Numbers = {On = 1, Off = 0}, Keys = {"D", 19}}
}

FlyRate = (1 / 30)

Debounce = false
Flying = false
ToolEquipped = false

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

function SetAnimation(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
	elseif Mode == "StopAnimation" and Value then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
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

function Fly()
	if Flying and Player and Torso and Humanoid and Humanoid.Health > 0 then
		local Momentum = Vector3.new(0, 0, 0)
		local LastMomentum = Vector3.new(0, 0, 0)
		local LastTilt = 0
		local CurrentSpeed = Speed.MaxSpeed
		local Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
		
		BodyVelocity.maxForce = Vector3.new(1, 1, 1) * (10 ^ 6)	
		
		BodyGyro.maxTorque = Vector3.new(BodyGyro.P, BodyGyro.P, BodyGyro.P)
		BodyGyro.cframe = Torso.CFrame
		
		while Flying and Torso and Humanoid and Humanoid.Health > 0 do
			
			if CurrentSpeed ~= Speed.MaxSpeed then
				CurrentSpeed = Speed.MaxSpeed
				Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
			end
			
			local Direction = Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(Controls.Left.Number + Controls.Right.Number, math.abs(Controls.Forward.Number) * 0.2, Controls.Forward.Number + Controls.Backward.Number))
			local Movement = Direction * Speed.CurrentSpeed
			
			Momentum = (Momentum * Inertia) + Movement
			
			local TotalMomentum = Momentum.magnitude
			
			if TotalMomentum > CurrentSpeed then
				TotalMomentum = CurrentSpeed
			end
			
			local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
			local StringTilt = tostring(Tilt)
			
			if StringTilt == "-1.#IND" or StringTilt == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or StringTilt == tostring(0 / 0) then
				Tilt = 0
			end
			
			local AbsoluteTilt = math.abs(Tilt)
			
			if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
				if math.abs(LastTilt) > 0.0001 then
					Tilt = (LastTilt * 0.9)
				else
					Tilt = 0
				end
			else
				Tilt = ((LastTilt * 0.77) + (Tilt * 0.25))
			end
			
			LastTilt = Tilt

			if TotalMomentum < 0.5 then
				Momentum = Vector3.new(0, 0, 0)
				TotalMomentum = 0
				BodyGyro.cframe = Camera.CoordinateFrame
			else
				BodyGyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Momentum) * CFrame.Angles(0, 0, (Tilt * -20)) * CFrame.Angles((math.pi * -0.5 * (TotalMomentum / CurrentSpeed)), 0, 0)
			end
			
			BodyVelocity.velocity = Momentum
			LastMomentum = Momentum
			wait(FlyRate)
			
		end
		
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyPosition.maxForce = Vector3.new(0, 0, 0)
		BodyGyro.maxTorque = Vector3.new(0, 0, 0)
		
	end
end

function StopFlying()
	Flying = false
	BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	BodyPosition.maxForce = Vector3.new(0, 0, 0)
	BodyGyro.maxTorque = Vector3.new(0, 0, 0)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
	Mouse.KeyDown:connect(function(Key)
		local Key = string.lower(Key)
		local ByteKey = string.byte(Key)
		if ByteKey == string.byte(" ") and not Debounce then
			if Flying then
				StopFlying()
			elseif not Flying then
				if (tick() - Jumping.JumpTick) <= Jumping.JumpTime or Jumping.JumpTick == 0 then
					Jumping.JumpTick = tick()
					Jumping.Jumps = Jumping.Jumps + 1
					if Jumping.Jumps >= Jumping.JumpsRequired then
						Debounce = true
						Jumping.JumpTick = 0
						Jumping.Jumps = 0
						BodyPosition.position = Torso.Position
						BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
						InvokeServer("CreateEffects")
						Debounce = false
					end
				else
					Jumping.JumpTick = tick()
					Jumping.Jumps = 1
				end
			end
		end
		for i, v in pairs(Controls) do
			for ii, vv in pairs(v.Keys) do
				v.Number = ((((string.lower(type(vv)) == string.lower("String") and Key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.On) or v.Number)
			end
		end
	end)
	Mouse.KeyUp:connect(function(Key)
		local Key = string.lower(Key)
		local ByteKey = string.byte(Key)
		for i, v in pairs(Controls) do
			for ii, vv in pairs(v.Keys) do
				v.Number = ((((string.lower(type(vv)) == string.lower("String") and Key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.Off) or v.Number)
			end
		end
	end)
	ToolEquipped = true
	while not BodyVelocity or not BodyVelocity.Parent or not BodyPosition or not BodyPosition.Parent or not BodyGyro or not BodyGyro.Parent and CheckIfAlive() and ToolEquipped do
		BodyPosition = Torso:FindFirstChild("BodyPosition")
		BodyVelocity = Torso:FindFirstChild("BodyVelocity")
		BodyGyro = Torso:FindFirstChild("BodyGyro")
		RunService.Stepped:wait()
	end
end

function Unequipped()
	LocalObjects = {}
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump}) do
		if v then
			v:disconnect()
		end
	end
	Animations = {}
	Flying = false
	ToolEquipped = false
end

function InvokeServer(Mode, Value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(Mode, Value)
		return ServerReturn
	end)
end

function OnClientInvoke(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "DisableJump" then
		DisableJump(Value)
	elseif Mode == "Fly" and not Flying then
		Flying = true
		Spawn(function()
			Fly()
		end)
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ClientControl.OnClientInvoke = OnClientInvoke