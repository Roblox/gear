--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

ArtemisGui = script:WaitForChild("ArtemisGui")

Animations = {}
LocalObjects = {}

Sounds = {
	Wings = Handle:WaitForChild("WingSound"),	
}

Controls = {
	Forward = {
		Value = 0,
		DesiredValue = -1,
		Keys = {
			Key = "w",
			ByteKey = 17
		}
	},
	Backward = {
		Value = 0,
		DesiredValue = 1,
		Keys = {
			Key = "s",
			ByteKey = 18
		}
	},
	Left = {
		Value = 0,
		DesiredValue = -1,
		Keys = {
			Key = "a",
			ByteKey = 20
		}
	},
	Right = {
		Value = 0,
		DesiredValue = 1,
		Keys = {
			Key = "d",
			ByteKey = 19
		}
	}
}

Speed = {
	Current = 2,
	Max = 50
}

Inertia = (1 - (Speed.Current / Speed.Max))

Momentum = Vector3.new(0, 0, 0)
LastMomentum = Vector3.new(0, 0, 0)
TotalMomentum = 0

LastFlap = 0
LastTilt = 0

Rate = (1 / 60)

Flying = false
FireMode = 0

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

function ChangeMode(NewMode)
	FireMode = NewMode
	if Button1 and Button1.Parent and Button2 and Button2.Parent then
		pcall(function()
			if FireMode == 1 then
				Button1:FindFirstChild("Active").Visible = true
				Button1:FindFirstChild("Inactive").Visible = false
				Button2:FindFirstChild("Active").Visible = false
				Button2:FindFirstChild("Inactive").Visible = true
			else
				Button1:FindFirstChild("Active").Visible = false
				Button1:FindFirstChild("Inactive").Visible = true
				Button2:FindFirstChild("Active").Visible = true
				Button2:FindFirstChild("Inactive").Visible = false
			end
		end)
		Spawn(function()
			InvokeServer("SetMode", FireMode)
		end)
	end
end

function RemoveFlyStuff()
	for i, v in pairs(Torso:GetChildren()) do
		if v.Name == "FlightGyro" or v.Name == "FlightVelocity" then
			v:Destroy()
		end
	end
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function Fly()
	
	if not ToolEquipped or not CheckIfAlive() then
		Flying = false
	else
		Flying = not Flying
	end
	
	if Flying and ToolEquipped and CheckIfAlive() then
		
		Momentum = (Torso.Velocity + (Torso.CFrame.lookVector * 3) + Vector3.new(0, 10, 0))
		Momentum = Vector3.new(Clamp(Momentum.X, -15, 15), Clamp(Momentum.Y, -15, 15), Clamp(Momentum.Z, -15, 15))
		
		local FlightGyro = Instance.new("BodyGyro")
		FlightGyro.Name = "FlightGyro"
		FlightGyro.P = (10 ^ 6)
		FlightGyro.maxTorque = Vector3.new(FlightGyro.P, FlightGyro.P, FlightGyro.P)
		FlightGyro.cframe = Torso.CFrame
		FlightGyro.Parent = Torso
		
		local FlightVelocity = Instance.new("BodyVelocity")
		FlightVelocity.Name = "FlightVelocity"
		FlightVelocity.velocity = Vector3.new(0, 0, 0)
		FlightVelocity.P = (10 ^ 4)
		FlightVelocity.maxForce = (Vector3.new(1, 1, 1) * (10 ^ 6))
		FlightVelocity.Parent = Torso
		
		Spawn(function()
			InvokeServer("Flying", {Mode = true})
		end)
		
		for i, v in pairs(Controls) do
			Controls[i].Value = 0
		end
		
		Humanoid.AutoRotate = false
		
		while Flying and CheckIfAlive() and ToolEquipped do
			
			local CoordinateFrame = Camera.CoordinateFrame
			local Movement = (CoordinateFrame:vectorToWorldSpace(Vector3.new((Controls.Left.Value + Controls.Right.Value), (math.abs(Controls.Forward.Value) * 0.2), (Controls.Forward.Value + Controls.Backward.Value)) * Speed.Current))
			
			Momentum = ((Momentum * Inertia) + Movement)
			TotalMomentum = Momentum.magnitude
			if TotalMomentum > Speed.Max then
				TotalMomentum = Speed.Max
			end

			local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
			if tostring(Tilt) == "-1.#IND" or tostring(Tilt) == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or tostring(0 / 0) == tostring(Tilt) then
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
				FlightGyro.cframe = CoordinateFrame
			else
				FlightGyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Momentum) *CFrame.Angles(0, 0, (Tilt * -20)) * CFrame.Angles((math.pi * -0.5 * (TotalMomentum / Speed.Max)), 0, 0)
			end
			
			FlightVelocity.velocity = Momentum
			
			local GravityDelta = ((((Momentum * Vector3.new(0, 1, 0)) - Vector3.new(0, -Speed.Max, 0)).magnitude / Speed.Max) * 0.5)
			if GravityDelta > 0.45 and tick() > LastFlap then
				LastFlap = (tick() + 0.5)
				Spawn(function()
					Sounds.Wings:Play()
					Spawn(function()
						InvokeServer("SetWingSpan", {Value = -0.5})
					end)
					wait(0.25)
					Spawn(function()
						InvokeServer("SetWingSpan", {Value = 0.5})
					end)
					wait(0.25)
					Spawn(function()
						InvokeServer("SetWingSpan", {Value = 0})
					end)
				end)
			end
			LastMomentum = Momentum
			wait(Rate)
		end
		if CheckIfAlive() then
			Humanoid.AutoRotate = true
			Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
		RemoveFlyStuff()
		Spawn(function()
			InvokeServer("Flying", {Mode = false})
		end)
		Flying = false
	end
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
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
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
		OnClientInvoke("KeyPress", {Key = Key, Down = true})
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		OnClientInvoke("KeyPress", {Key = Key, Down = false})
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	Mouse.Move:connect(function()
		InvokeServer("MouseMove", {Position = Mouse.Hit.p, Target = Mouse.Target})
	end)
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			ArtemisGuiClone = ArtemisGui:Clone()
			Button1 = ArtemisGuiClone.ButtonHolder.Button1
			Button2 = ArtemisGuiClone.ButtonHolder.Button2
			Button1.MouseButton1Down:connect(function()
				ChangeMode(1)
			end)
			Button2.MouseButton1Down:connect(function()
				ChangeMode(2)
			end)
			ChangeMode(1)
			ArtemisGuiClone.Parent = PlayerGui
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	LocalObjects = {}
	Button1 = nil
	Button2 = nil
	if ArtemisGuiClone and ArtemisGuiClone.Parent then
		ArtemisGuiClone:Destroy()
	end
	RemoveFlyStuff()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerRtrurn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	elseif mode == "DisableJump" and value then
		DisableJump(value)
	elseif mode == "SetLocalTransparencyModifier" and value then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							local CurrentTransparency = v.Object.LocalTransparencyModifier
							if ((not v.AutoUpdate and (CurrentTransparency == 1 or  CurrentTransparency == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	elseif mode == "KeyPress" and value then
		local Key = value.Key
		local ByteKey = string.byte(Key)
		local Down = value.Down
		if Key == "q" and Down then
			ChangeMode(1)
		elseif Key == "e" and Down then
			ChangeMode(2)
		elseif ByteKey == 32 and Down then
			Spawn(Fly)
		else
			for i, v in pairs(Controls) do
				if v.Keys.Key == Key or v.Keys.ByteKey == ByteKey then
					v.Value = ((Down and v.DesiredValue) or 0)
				end
			end
		end
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)