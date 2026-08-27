Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

CurrentFuel = Tool:WaitForChild("CurrentFuel")
StandStill = Tool:WaitForChild("StandStill")
FuelGui = Tool:WaitForChild("FuelGui")

Animations = {
	StandStill = {Animation = Tool:WaitForChild("StandStill"), FadeTime = nil, Weight = nil, Speed = nil},
	R15StandStill = {Animation = Tool:WaitForChild("R15StandStill"), FadeTime = nil, Weight = nil, Speed = nil}
}

Sounds = {
	EngineFail = Handle:WaitForChild("EngineFail"),
	InitialThrust = Handle:WaitForChild("InitialThrust"),
	LowFuelWarning = Handle:WaitForChild("LowFuelWarning"),
	Thrusting = Handle:WaitForChild("Thrusting")
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Mass = 0
EqualizingForce = 236 / 1.2 -- amount of force required to levitate a mass
Gravity = 0.80 -- things float at > 1

MaxFuel = 1300

Fuel = CurrentFuel.Value
Gui = nil
Anim = nil
JetPack = nil
Regen = false

ToolEquipped = false

Force = Instance.new("BodyVelocity")
Force.velocity = Vector3.new(0, 0, 0)

BodyGyro = Instance.new("BodyGyro")
BodyGyro.P = 20000
BodyGyro.D = 8000     
BodyGyro.maxTorque = Vector3.new(BodyGyro.P, BodyGyro.P, BodyGyro.P)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

CurrentFuel.Value = CurrentFuel.MaxValue

function UpdateGui()
	if Gui then
		local Frame = Gui:FindFirstChild("Frame")
		if Frame then
			Frame.Size = UDim2.new(0, 32, 0.45 * (CurrentFuel.Value / MaxFuel), 0)
			Frame.Position = UDim2.new(0.903, 0, 0.2 + (0.45 * (1 - CurrentFuel.Value / MaxFuel)), 0)
		end
	end 
end

function Thrust()
	if Fuel > 0 then
		Thrusting = true
		Force.Parent = Torso
--		Fire.Enabled = true
--		LeftSmoke.Enabled = true
--		RightSmoke.Enabled = true
		for _, attachment in pairs(JetPack:GetChildren()) do
			if attachment:IsA("Attachment") then
				attachment.Fire.Enabled = true
				attachment.Smoke.Enabled = true
			end
		end
		Sounds.InitialThrust:Play()
		BodyGyro.Parent = Torso
		while Thrusting do
			local CoordinateFrame = InvokeClient("GetCamera", {Property = "CoordinateFrame"})
			BodyGyro.cframe = CoordinateFrame
			Force.velocity = Vector3.new(0, CoordinateFrame.lookVector.unit.y, 0) * 50
			Fuel = Fuel - 1
			CurrentFuel.Value = Fuel
			if Fuel <= 0 then
				Sounds.EngineFail:Play()
				CutEngine()
			end
			UpdateGui()
			wait()
			Sounds.Thrusting:Play()
			if Fuel <= 200 then
				Sounds.LowFuelWarning:Play()
			end
		end
		Sounds.Thrusting:Stop()
		Sounds.LowFuelWarning:Stop()
	end
end

function CutEngine()
	Thrusting = false
--	Fire.Enabled = false
--	LeftSmoke.Enabled = false
--	RightSmoke.Enabled = false
	for _, attachment in pairs(JetPack:GetChildren()) do
		if attachment:IsA("Attachment") then
			attachment.Fire.Enabled = false
			attachment.Smoke.Enabled = false
		end
	end
	Force.velocity = Vector3.new(0, 0, 0)
	Force.Parent = nil
	BodyGyro.Parent = nil
end

function RecursiveGetLift(Parent)
	local TotalMass = 0
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			if Head and Head.Parent and (v.Position - Head.Position).magnitude < 10 then
				TotalMass = TotalMass + (v:GetMass() * EqualizingForce * 1)
			else
				TotalMass = TotalMass + (v:GetMass() * EqualizingForce * Gravity)
			end
		end
		TotalMass = TotalMass + RecursiveGetLift(v)
	end
	return TotalMass
end

function RegenFuel()
	while Regen do
		if Fuel < MaxFuel then
			Fuel = Fuel + 1
			CurrentFuel.Value = Fuel
			UpdateGui()
		end
		wait(0.2)
	end
end

function EquipJetPack()

	JetPack = Handle:clone()
	JetPack.CanCollide = false
	JetPack.Name = "JetPack"

	Handle.Transparency = 1

	local Weld = Instance.new("Motor6D")
	Weld.Part0 = JetPack
	Weld.Part1 = Torso
	Weld.C0 = CFrame.new(Vector3.new(0, 0, 0.35)) * CFrame.Angles(0, 0, 0)
	Weld.Parent = JetPack

--	FirePart = BasePart:Clone()
--	FirePart.Name = "FirePart"
--	FirePart.Transparency = 1
--	FirePart.Size = Vector3.new(1, 0.4, 1)
--	FirePart.CanCollide = false
--	FirePart.Parent = JetPack
--
--	Fire = Instance.new("Fire")
--	Fire.Heat = -12
--	Fire.Size = 4
--	Fire.Enabled = false
--	Fire.Parent = FirePart
--
--	local FireWeld = Instance.new("Weld")
--	FireWeld.Part0 = FirePart
--	FireWeld.Part1 = JetPack
--	FireWeld.C0 = CFrame.new(Vector3.new(0, 2, -1))
--	FireWeld.Parent = FirePart
--	
--	LeftSmokePart = BasePart:Clone()
--	LeftSmokePart.Name = "LeftSmokePart"
--	LeftSmokePart.Transparency = 1
--	LeftSmokePart.Size = Vector3.new(1, 0.4, 1)
--	LeftSmokePart.CanCollide = false
--	LeftSmokePart.Parent = JetPack
--
--	LeftSmoke = Instance.new("Smoke")
--	LeftSmoke.Color = BrickColor.new("Institutional white").Color
--	LeftSmoke.Opacity = 0.25
--	LeftSmoke.RiseVelocity = 0
--	LeftSmoke.Size = 0.1
--	LeftSmoke.Enabled = false
--	LeftSmoke.Parent = LeftSmokePart
--
--	local LeftSmokeWeld = Instance.new("Weld")
--	LeftSmokeWeld.Part0 = LeftSmokePart
--	LeftSmokeWeld.Part1 = JetPack
--	LeftSmokeWeld.C0 = CFrame.new(Vector3.new(1.25, 1.5, 0))
--	LeftSmokeWeld.Parent = LeftSmokePart
--	
--	RightSmokePart = LeftSmokePart:Clone()
--	RightSmokePart.Name = "RightSmokePart"
--	RightSmokePart.Parent = JetPack
--
--	RightSmoke = LeftSmoke:Clone()
--	RightSmoke.Parent = RightSmokePart
--
--	local RightSmokeWeld = Instance.new("Weld")
--	RightSmokeWeld.Part0 = RightSmokePart
--	RightSmokeWeld.Part1 = JetPack
--	RightSmokeWeld.C0 = CFrame.new(Vector3.new(-1.25, 1.5, 0))
--	RightSmokeWeld.Parent = RightSmokePart
	
	JetPack.Parent = Character
	
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
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
	Spawn(function()
		EquipJetPack()
	end)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		Gui = FuelGui:Clone()
		Gui.Parent = PlayerGui
		UpdateGui()
	end
	Mass = RecursiveGetLift(Character)
	Force.P = Mass * 10
	Force.maxForce = Vector3.new(0, Force.P, 0)
	local anim = Animations.StandStill
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		anim = Animations.R15StandStill
	end
	Spawn(function()
		InvokeClient("PlayAnimation", anim)
	end)
	Regen = true
	Spawn(function()
		RegenFuel()
	end)
	ToolEquipped = true
end

function Unequipped()
	Regen = false
	for i, v in pairs({Force, BodyGyro, JetPack, Gui}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	local anim = Animations.StandStill
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		anim = Animations.R15StandStill
	end	
	InvokeClient("StopAnimation", anim)
	Handle.Transparency = 0
	Thrusting = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "MouseClick" and value then
		local Down = value.Down
		if Down and not Thrusting then
			Thrust()
		elseif not Down and Thrusting then
			Thrusting = false
			CutEngine()
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

UpdateGui()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)