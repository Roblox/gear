--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Animations = {
	Sit = Tool:WaitForChild("Sit")
}

Sounds = {
	Fade = Handle:WaitForChild("Fade")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Gravity = 196.20
ReloadTime = 1

Speed = 100

Equipped = false

Tool.Enabled = true

CameraSpeed = {
	X = 40,
	Z = 60
}

Directions = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
}

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "w" or Key == "" then
				Directions.Forward = Down
			elseif Key == "s" or Key == "" then
				Directions.Backward = Down
			elseif Key == "a" or Key == "" then
				Directions.Left = Down
			elseif Key == "d" or Key == "" then
				Directions.Right = Down
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function Fade(Part, Invisible)
	local Pause = Instance.new("BoolValue")
	Pause.Value = false
	Spawn(function()
		local Transparency = Part.Transparency
		for i = 0, (math.abs(((Invisible and (1 - Transparency)) or (Transparency - 0))) / 0.1) do
			if Pause.Value then
				break
			end
			Part.Transparency = Part.Transparency + ((Invisible and 0.1) or -0.1)
			wait(0.1)
		end
		if not Pause.Value then
			Part.Transparency = ((Invisible and 1) or 0)
		end
	end)
	return Pause
end
function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if Carpet and Carpet.Parent then
		Carpet:Destroy()
		Handle.Transparency = 0
		InvokeClient("StopAnimation", Animations.Sit)
		if Humanoid and Humanoid.Parent then
			Humanoid.PlatformStand = false
		end
	else
		if Humanoid and Humanoid.Parent then
			Humanoid.PlatformStand = true
		end
		Handle.Transparency = 1
		Carpet = Handle:Clone()
		Carpet.Name = "GhostCarpet"
		Carpet.CanCollide = true
		Carpet.Transparency = 0
		local Weld = Instance.new("Weld")
		Weld.Part0 = Torso
		Weld.Part1 = Carpet
		Weld.C0 = CFrame.new(0, -1.5, -1)
		Weld.Parent = Carpet
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyVelocity.velocity = Vector3.new(0, 0, 0)
		BodyVelocity.Parent = Carpet
		BodyPosition = Instance.new("BodyPosition")
		BodyPosition.maxForce = Vector3.new(0, 0, 0)
		BodyPosition.position = Torso.Position
		BodyPosition.Parent = Carpet
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.Parent = Carpet
		Spawn(function()
			local MovingTick = tick()
			local Visible = true
			local Stopped = (((not Directions.Forward and not Directions.Backward and not Directions.Left and not Directions.Right) and true) or false)
			local Pause = nil
			while Equipped and CheckIfAlive() and BodyGyro and BodyGyro.Parent do
				local CoordinateFrame = InvokeClient("CoordinateFrame", nil)
				local ForwardVector = CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
				BodyGyro.cframe = CFrame.new(Vector3.new(0,0,0), ForwardVector)			
				if Directions.Forward or Directions.Backward or Directions.Left or Directions.Right then
					if Visible then
						Sounds.Fade:Play()
						if Pause then
							Pause.Value = true
						end
						Pause = Fade(Carpet, true)
						Visible = false
					end
					Stopped = false
					MovingTick = tick()
					local NewPush = Vector3.new(0, 0, 0)
					if Directions.Forward and not Directions.Backward then
						NewPush = ForwardVector * CameraSpeed.Z
					end
					if not Directions.Forward and Directions.Backward then
						NewPush = ForwardVector * -CameraSpeed.Z
					end
					if Directions.Left and not Directions.Right then
						NewPush = NewPush + CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * CameraSpeed.X
					end
					if not Directions.Left and Directions.Right then
						NewPush = NewPush + CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * CameraSpeed.X
					end
					
					local Mass = (GetTotalMass(Character) * Gravity ^ 2)
					BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
					
					BodyVelocity.velocity = NewPush
					
					BodyPosition.maxForce = Vector3.new(0, 0, 0)
				else
					BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
					if not Stopped then
						Stopped = true
						BodyPosition.position = Carpet.Position
					end
					BodyVelocity.maxForce = Vector3.new(0, 0, 0)
					if (tick() - MovingTick) >= 3 and not Visible then
						Visible = true
						if Pause then
							Pause.Value = true
						end
						Pause = Fade(Carpet, false)
					end
				end
				wait()
			end
		end)
		Carpet.CFrame = Torso.CFrame
		Carpet.Parent = Character
		InvokeClient("PlayAnimation", {Animation = Animations.Sit, FadeTime = nil, Weight = nil, Speed = nil})
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Character.Parent and Player.Parent and Humanoid.Parent and Humanoid.Health > 0 and Torso.Parent)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Equipped = true
end

function Unequipped()
	Equipped = false
	Handle.Transparency = 0
	if Humanoid and Humanoid.Parent then
		Humanoid.PlatformStand = false
	end
	if Carpet and Carpet.Parent then
		Carpet:Destroy()
	end
	for i, v in pairs(Directions) do
		Directions[i] = false
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)