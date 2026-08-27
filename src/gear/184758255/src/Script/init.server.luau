--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

DisplayHandle = Tool:FindFirstChild("DisplayHandle")
if DisplayHandle then
	DisplayHandle:Destroy()
end

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Grips = {
	Equipped = CFrame.new(0, -0.75, 0, -1, 0, -8.10005167e-006, 0, 1, 0, 8.10005167e-006, 0, -1),
	Display = CFrame.new(3, 2.6500001, -2, 0.89442718, -0, 0.44721359, 0, 1, 0, -0.44721359, 0, 0.89442718),
}

Animations = {
}

Sounds = {
}

Controls = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false
}

Flying = false

Speed = 10

Gravity = 196.20

MovementTime = (1 / 30)
ReloadTime = 5

HotWheelsStreetHawk = require(Tool:WaitForChild("VehicleCreator"))

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Equipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			if not PlayerHotWheelsStreetHawk or not PlayerHotWheelsStreetHawk.Parent then
				if Value.Down then
					Activated()
				end
			else
				if Value.Down then
					Flying = true
				else
					Flying = false
				end
			end
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if Key == "w" or ByteKey == 17 then
				Controls.Forward = Down
			elseif Key == "s" or ByteKey == 18 then
				Controls.Backward = Down
			elseif Key == "a" or ByteKey == 20 then
				Controls.Left = Down
			elseif Key == "d" or ByteKey == 19 then
				Controls.Right = Down
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
		end
	end
	GetMass(Parent)
	return Mass
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function IsFlipped(Object)
	local Vector1 = Object.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > 1.5)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or (PlayerHotWheelsStreetHawk and PlayerHotWheelsStreetHawk.Parent) then
		return
	end
	Tool.Enabled = false
	Humanoid.WalkSpeed = 0
	local PlaneName = (Player.Name .."'s" .. HotWheelsStreetHawk.Name)
	local Plane = game:GetService("Workspace"):FindFirstChild(PlaneName)
	if Plane then
		Plane:Destroy()
	end
	PlayerHotWheelsStreetHawk = HotWheelsStreetHawk:Clone()
	PlayerHotWheelsStreetHawk.Name = PlaneName
	local RemoverClone = Remover:Clone()
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = RemoverClone
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = RemoverClone
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerHotWheelsStreetHawk
	PlaneBody = PlayerHotWheelsStreetHawk:FindFirstChild("Body")
	FrontLeftMotor = PlaneBody:FindFirstChild("FrontLeftMotor")
	FrontRightMotor = PlaneBody:FindFirstChild("FrontRightMotor")
	BackLeftMotor = PlaneBody:FindFirstChild("BackLeftMotor")
	BackRightMotor = PlaneBody:FindFirstChild("BackRightMotor")
	if PlaneBody then
		PlaneBody.Elasticity = 0.5
		PlaneBody.Friction = 0.3
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(0, 0, 0)
		TransformModel(PlayerHotWheelsStreetHawk, PlayerHotWheelsStreetHawk:GetModelCFrame(), (Handle.CFrame + Handle.CFrame.lookVector * (((Handle.Size.Z / 2) + (PlayerHotWheelsStreetHawk:GetModelSize().Z / 2) + 1.25) * -1)) * CFrame.Angles(0, math.pi, 0), true)
		BodyGyro.cframe = PlaneBody.CFrame
		BodyGyro.Parent = PlaneBody
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.P = 1250
		BodyVelocity.velocity = Vector3.new(0, 0, 0)
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyVelocity.Parent = PlaneBody
		BodyAngularVelocity = Instance.new("BodyAngularVelocity")
		BodyAngularVelocity.P = 1250
		BodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
		BodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
		BodyAngularVelocity.Parent = PlaneBody
		PlayerHotWheelsStreetHawk.Parent = game:GetService("Workspace")
		Plane = game:GetService("Workspace"):FindFirstChild(PlaneName)
		if Plane then
			InvokeClient("SetCamera", {Subject = Plane, Type = Enum.CameraType.Track})
		end
		Spawn(function()
			local Mass = (GetTotalMass(PlayerHotWheelsStreetHawk) * Gravity)
			while PlayerHotWheelsStreetHawk and PlayerHotWheelsStreetHawk.Parent do
				if not IsFlipped(PlaneBody) then
					if not Flying then
						BodyGyro.maxTorque = Vector3.new(0, 0, 0)
						if Controls.Left or Controls.Right then
							BodyAngularVelocity.maxTorque = Vector3.new(0, Mass, 0)
							BodyAngularVelocity.angularvelocity = Vector3.new(0, ((((Controls.Left and not Controls.Right) and 2) or ((Controls.Right and not Controls.Left) and -2)) or 0), 0)
						else
							BodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
							BodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
						end
						if Controls.Forward or Controls.Backward then
							BodyVelocity.maxForce = Vector3.new(Mass, (Mass / 2), Mass)
							BodyVelocity.velocity = ((((Controls.Backward and not Controls.Forward) and (PlaneBody.CFrame.lookVector * ((Speed / 2) * -1))) or ((Controls.Forward and not Controls.Backward) and (PlaneBody.CFrame.lookVector * Speed))) or Vector3.new(0, 0, 0))
						else
							BodyVelocity.maxForce = Vector3.new(0, 0, 0)
							BodyVelocity.velocity = Vector3.new(0, 0, 0)
						end
					else
						local MouseTarget = InvokeClient("MousePosition", nil)
						local Direction = CFrame.new(PlaneBody.Position, MouseTarget)
						local Velocity = Direction.lookVector * 20
						BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
						BodyGyro.cframe = Direction
						BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
						BodyVelocity.velocity = Velocity
						PlaneBody.Velocity = Velocity
					end
				else
					BodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
					BodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
					BodyVelocity.maxForce = Vector3.new(0, 0, 0)
					BodyVelocity.velocity = Vector3.new(0, 0, 0)
				end
				local WheelSpeed = (25 * ((((Controls.Backward and not Controls.Forward) and 1) or ((Controls.Forward and not Controls.Backward) and -1)) or 0))
				local DesiredAngle = (99999999999 * (-WheelSpeed / math.abs(WheelSpeed)))
				local MaxVelocity = (WheelSpeed / 250)
				for i, v in pairs({FrontLeftMotor, FrontRightMotor, BackLeftMotor, BackRightMotor}) do
					if v and v.Parent then
						v.DesiredAngle = DesiredAngle
						v.MaxVelocity = MaxVelocity
					end
				end
				wait(MovementTime)
			end
		end)
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
end

function Unequipped()
	if PlayerHotWheelsStreetHawk and PlayerHotWheelsStreetHawk.Parent then
		PlayerHotWheelsStreetHawk:Destroy()
	end
	if Humanoid and Humanoid.Parent then
		InvokeClient("SetCamera", {Subject = Humanoid, Type = Enum.CameraType.Custom})
		Humanoid.WalkSpeed = 16
	end
	Flying = false
	for i, v in pairs(Controls) do
		Controls[i] = false
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)