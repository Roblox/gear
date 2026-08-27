--Rescripted by Luckymaxer
--Made by Stickmasterluke
--// Fixed for R15 avatars by StarWars
-- Fixed by Stickmasterluke to support mobile

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

AnimationTracks = {}
LocalObjects = {}

Animations = {
	CoastingPose = {Animation = Tool:WaitForChild("CoastingPose"), FadeTime = 0.5, Weight = nil, Speed = nil},
	LeftTurn = {Animation = Tool:WaitForChild("LeftTurn"), FadeTime = 0.5, Weight = nil, Speed = nil},
	RightTurn = {Animation = Tool:WaitForChild("RightTurn"), FadeTime = 0.5, Weight = nil, Speed = nil},
	
	R15CoastingPose = {Animation = Tool:WaitForChild("R15CoastingPose"), FadeTime = 0.5, Weight = nil, Speed = nil},
	R15LeftTurn = {Animation = Tool:WaitForChild("R15LeftTurn"), FadeTime = 0.5, Weight = nil, Speed = nil},
	R15RightTurn = {Animation = Tool:WaitForChild("R15RightTurn"), FadeTime = 0.5, Weight = nil, Speed = nil},	
}

Sounds = {
	Wind = Handle:WaitForChild("Wind"),	
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

LastTilt = 0
LastAnimUsed = nil

Rate = (1 / 60)

Flying = false

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

function RemoveFlyStuff()
	if CheckIfAlive() then
		Humanoid.AutoRotate = true
		Humanoid.PlatformStand = false
	end
	LastAnimUsed = nil
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
			Debris:AddItem(v, 0)
		end
	end
	for i, v in pairs(Animations) do
		SetAnimation("StopAnimation", v)
	end
	spawn(function()
		InvokeServer("ToggleSound", false)
	end)
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
		
		local Cloud = InvokeServer("Fly", {Flying = true})
		
		Momentum = (Torso.Velocity + (Torso.CFrame.lookVector * 10) + Vector3.new(0, 3, 0))
		Momentum = Vector3.new(Clamp(Momentum.X, -15, 15), Clamp(Momentum.Y, -15, 15), Clamp(Momentum.Z, -15, 15))
		
		local FlightGyro = Instance.new("BodyGyro")
		FlightGyro.Name = "FlightGyro"
		FlightGyro.P = (10 ^ 4.5)
		FlightGyro.maxTorque = Vector3.new(FlightGyro.P, FlightGyro.P, FlightGyro.P)
		FlightGyro.cframe = Torso.CFrame
		FlightGyro.Parent = Torso
		
		local FlightVelocity = Instance.new("BodyVelocity")
		FlightVelocity.Name = "FlightVelocity"
		FlightVelocity.velocity = Vector3.new(0, 0, 0)
		FlightVelocity.P = (10 ^ 4)
		FlightVelocity.maxForce = (Vector3.new(1, 1, 1) * (10 ^ 6))
		FlightVelocity.Parent = Torso
		
		for i, v in pairs(Controls) do
			Controls[i].Value = 0
		end
		
		Humanoid.AutoRotate = false
		Humanoid.PlatformStand = true
		
		spawn(function()
			InvokeServer("ToggleSound", true)
		end)
		
		while Flying and CheckIfAlive() and ToolEquipped do

			--print(Humanoid.MoveDirection)
			
			local Camera = game:GetService("Workspace").CurrentCamera
			
			local CoordinateFrame = Camera.CoordinateFrame
			local Movement = Vector3.new(0, 0, 0)
			--[[local ControlVector = Vector3.new((Controls.Left.Value + Controls.Right.Value), (math.abs(Controls.Forward.Value) * 0.2), (Controls.Forward.Value + Controls.Backward.Value))
			if ControlVector.Magnitude > 0 then
				Movement = CoordinateFrame:vectorToWorldSpace(ControlVector.Unit * Speed.Current)
			end]]
			if Humanoid.MoveDirection.magnitude > 0 then
				local localControlVector = CFrame.new(Vector3.new(0,0,0),CoordinateFrame.lookVector*Vector3.new(1,0,1)):vectorToObjectSpace(Humanoid.MoveDirection+Vector3.new(0,.2,0))
				Movement = CoordinateFrame:vectorToWorldSpace(localControlVector.Unit * Speed.Current)
			end
			Momentum = ((Momentum * Inertia) + Movement)
			TotalMomentum = math.min(Momentum.Magnitude, Speed.Max)
			local MomentumPercent = (TotalMomentum / Speed.Max)
			if TotalMomentum > Speed.Max then
				TotalMomentum = Speed.Max
			end
			if Cloud then
				local Mesh = Cloud:FindFirstChild("Mesh")
				if Mesh then
					spawn(function()
						InvokeServer("SetMesh", MomentumPercent)
					end)
				end
			end
			spawn(function()
				InvokeServer("SetSound", MomentumPercent)
			end)
			local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
			if tostring(Tilt) == "-1.#IND" or tostring(Tilt) == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or tostring(0 / 0) == tostring(Tilt) then
				Tilt = 0
			end			
			local AbsoluteTilt = math.abs(Tilt)
			if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
				if math.abs(LastTilt) > 0.0001 then
					Tilt = (LastTilt * 0.96)
				else
					Tilt = 0
				end
			else
				Tilt = ((LastTilt * 0.9) + (Tilt * 0.1))
			end
			LastTilt = Tilt
			if Tilt > 0.01 then
				local Animation = Animations.RightTurn
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15RightTurn
				end
				if LastAnimUsed ~= Animation then
					SetAnimation("StopAnimation", LastAnimUsed)
					SetAnimation("PlayAnimation", Animation)
					LastAnimUsed = Animation
				end
			elseif Tilt < -0.01 then
				local Animation = Animations.LeftTurn
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15LeftTurn
				end				
				if LastAnimUsed ~= Animation then
					SetAnimation("StopAnimation", LastAnimUsed)
					SetAnimation("PlayAnimation", Animation)
					LastAnimUsed = Animation
				end
			else
				local Animation = Animations.CoastingPose
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15CoastingPose
				end							
				if LastAnimUsed ~= Animation then
					SetAnimation("StopAnimation", LastAnimUsed)
					SetAnimation("PlayAnimation", Animation)
					LastAnimUsed = Animation
				end
			end
			if TotalMomentum < 0.5 then
				Momentum = Vector3.new(0, 0, 0)
				TotalMomentum = 0
				FlightGyro.cframe = (CFrame.new(Vector3.new(0,0,0), (Camera.CoordinateFrame.lookVector * Vector3.new(1, 0, 1))) * CFrame.Angles(0, -(math.pi / 2), 0))
			else
				FlightGyro.cframe = (CFrame.new(Vector3.new(0,0,0), Momentum) * CFrame.Angles(0, -(math.pi / 2), 0) * CFrame.Angles((Tilt * -20),0,0))
			end
			FlightVelocity.velocity = Momentum
			local GravityDelta = ((((Momentum * Vector3.new(0, 1, 0)) - Vector3.new(0, -Speed.Max, 0)).magnitude / Speed.Max) * 0.5)
			if GravityDelta > 0.45 then
			end
			LastMomentum = Momentum
			wait(Rate)
		end
		if CheckIfAlive() then
			Humanoid.AutoRotate = true
			Humanoid.PlatformStand = false
			Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
		local Cloud = InvokeServer("Fly", {Flying = false})
		RemoveFlyStuff()
		Flying = false
	end
end

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
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
		PreventJump:Disconnect()
	end
	if Boolean then
		PreventJump = Humanoid.Changed:Connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Activated()
	Spawn(Fly)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild('HumanoidRootPart')
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.KeyDown:Connect(function(Key)
		OnClientInvoke("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:Connect(function(Key)
		OnClientInvoke("KeyPress", {Key = Key, Down = false})
	end)
	Spawn(function()
		RemoveFlyStuff()
	end)
	ToolEquipped = true
end

function Unequipped()
	LocalObjects = {}
	RemoveFlyStuff()
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, ObjectLocalTransparencyModifier}) do
		if v then
			v:Disconnect()
		end
	end
	AnimationTracks = {}
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
					ObjectLocalTransparencyModifier:Disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:Connect(function()
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
		for i, v in pairs(Controls) do
			if v.Keys.Key == Key or v.Keys.ByteKey == ByteKey then
				v.Value = ((Down and v.DesiredValue) or 0)
			end
		end
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)