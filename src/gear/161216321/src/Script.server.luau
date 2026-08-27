--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	Takeoff = {Animation = Tool:WaitForChild("Takeoff"), FadeTime = nil, Weight = nil, Speed = nil},
	Pose = {Animation = Tool:WaitForChild("Pose"), FadeTime = nil, Weight = nil, Speed = nil}
}

Sounds = {
	Wind = Handle:WaitForChild("Wind")
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

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function GetTotalMass(Parent)
	TotalMass = 0
	function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				TotalMass = TotalMass + v:GetMass()
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return TotalMass
end

function EquipWings()
	LeftWing = Instance.new("Part")
	LeftWing.Name = "LeftWing"
	LeftWing.Material = Enum.Material.Plastic
	LeftWing.Shape = Enum.PartType.Block
	LeftWing.FormFactor = Enum.FormFactor.Custom
	LeftWing.TopSurface = Enum.SurfaceType.Smooth
	LeftWing.BottomSurface = Enum.SurfaceType.Smooth
	LeftWing.Size = Vector3.new(0.2, 0.2, 0.2)
	LeftWing.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset/?id=160208252"
	Mesh.TextureId = "http://www.roblox.com/asset/?id=160208221"
	Mesh.Parent = LeftWing
	LeftWingWeld = Instance.new("Weld")
	LeftWingWeld.Part0 = LeftWing
	LeftWingWeld.Part1 = Torso
	LeftWingWeld.C0 = CFrame.new(2.5, -1.75, -2.9) * CFrame.Angles((math.pi / 10), 0, 0)
	LeftWingWeld.Parent = LeftWing
	LeftWing.Parent = Character
	RightWing = Instance.new("Part")
	RightWing.Name = "RightWing"
	RightWing.Material = Enum.Material.Plastic
	RightWing.Shape = Enum.PartType.Block
	RightWing.FormFactor = Enum.FormFactor.Custom
	RightWing.TopSurface = Enum.SurfaceType.Smooth
	RightWing.BottomSurface = Enum.SurfaceType.Smooth
	RightWing.Size = Vector3.new(0.2, 0.2, 0.2)
	RightWing.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset?id=160208275"
	Mesh.TextureId = "http://www.roblox.com/asset?id=160208221"
	Mesh.Parent = RightWing
	RightWingWeld = Instance.new("Weld")
	RightWingWeld.Part0 = RightWing
	RightWingWeld.Part1 = Torso
	RightWingWeld.C0 = CFrame.new(-2.5, -1.75, -2.9) * CFrame.Angles((math.pi / 10), 0, 0)
	RightWingWeld.Parent = RightWing
	RightWing.Parent = Character
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	InvokeClient("PlayAnimation", Animations.Pose)
	Spawn(function()
		EquipWings()
	end)
	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.P = (10 ^ 4)
	BodyVelocity.velocity = Vector3.new(0, 0, 0)
	BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	BodyVelocity.Parent = Torso
	BodyPosition = Instance.new("BodyPosition")
	BodyPosition.maxForce = Vector3.new(0, 0, 0)
	BodyPosition.Parent = Torso
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = (10 ^ 6)
	BodyGyro.maxTorque = Vector3.new(0, 0, 0)
	BodyGyro.cframe = Torso.CFrame
	BodyGyro.Parent = Torso
	InvokeClient("DisableJump")
	local WingStage = {Stage = 0, Increase = true}
	Spawn(function()
		while ((LeftWing and LeftWing.Parent and LeftWingWeld and LeftWingWeld.Parent) or (RightWing and RightWing.Parent and RightWingWeld and RightWingWeld.Parent)) and CheckIfAlive() and ToolEquipped do
			WingStage.Stage = WingStage.Stage + 1
			if (LeftWing or LeftWing.Parent and LeftWingWeld and LeftWingWeld.Parent) then
				LeftWingWeld.C0 = LeftWingWeld.C0 * CFrame.Angles(0, ((math.pi / (12 * 6)) * ((WingStage.Increase and 1) or -1)), 0)
			end
			if (RightWing and RightWing.Parent and RightWingWeld and RightWingWeld.Parent) then
				RightWingWeld.C0 = RightWingWeld.C0 * CFrame.Angles(0, ((math.pi / (12 * 6)) * ((WingStage.Increase and -1) or 1)), 0)
			end
			if WingStage.Stage >= 10 then
				WingStage.Stage = 0
				WingStage.Increase = not WingStage.Increase
			end
			wait(0.1)
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs({BodyVelocity, BodyPosition, BodyGyro, LeftWing, RightWing}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
	Sounds.Wind:Stop()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and CheckIfAlive() then
		if mode == "CreateEffects" then
			Humanoid.WalkSpeed = 0
			InvokeClient("StopAnimation", Animations.Pose)
			InvokeClient("PlayAnimation", Animations.TakeOff)
			local SmokePart = BasePart:Clone()
			SmokePart.Name = "SmokePart"
			SmokePart.Transparency = 1
			SmokePart.Anchored = true
			SmokePart.CanCollide = false
			local Smoke = Instance.new("Smoke")
			Smoke.Color = BrickColor.new("Institutional white").Color
			Smoke.Opacity = 0.5
			Smoke.RiseVelocity = 3
			Smoke.Size = 25
			Smoke.Parent = SmokePart
			Debris:AddItem(SmokePart, 5)
			SmokePart.Parent = game:GetService("Workspace")
			SmokePart.CFrame = Torso.CFrame + Vector3.new(0, -1, 0) * (Torso.Size.Y * 1.5)
			if ToolEquipped then
				Sounds.Wind:Play()
				Delay(5, function()
					Sounds.Wind:Stop()
				end)
				BodyPosition.position = Torso.Position + Vector3.new(0, 50, 0)
				BodyPosition.maxForce = Vector3.new(0, ((GetTotalMass(Character) * 196.20 * 2)), 0)
			end
			wait(2.5)
			InvokeClient("StopAnimation", Animations.Takeoff)
			InvokeClient("PlayAnimation", Animations.Pose)
			InvokeClient("Fly")
			Humanoid.WalkSpeed = 16
			BodyPosition.maxForce = Vector3.new(0, 0, 0)
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

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)