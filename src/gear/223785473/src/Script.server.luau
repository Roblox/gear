--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Animations = {
	Pose = {Animation = Tool:WaitForChild("Pose"), FadeTime = nil, Weight = nil, Speed = nil}
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

Wing = BasePart:Clone()
Wing.Name = "Wing"
Wing.Size = Vector3.new(4.5, 5, 0.2)
Wing.CanCollide = false
WingMesh = Instance.new("SpecialMesh")
WingMesh.MeshId = ""
WingMesh.TextureId = (BaseUrl .. "223377828")
WingMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
WingMesh.VertexColor = Vector3.new(1, 1, 1)
WingMesh.Offset = Vector3.new(0, 0, 0)
WingMesh.Parent = Wing

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Flying = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v ~= Handle and v:IsA("BasePart") then
		v:Destroy()
	end
end

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
	LeftWing = Wing:Clone()
	LeftWing.Name = "LeftWing"
	LeftWing.Mesh.MeshId = (BaseUrl .. "223377755")
	LeftWingWeld = Instance.new("Motor6D")
	LeftWingWeld.Part0 = Torso
	LeftWingWeld.Part1 = LeftWing
	LeftWingWeld.C0 = CFrame.new(0.2, 1.6, 1.2) * CFrame.Angles((math.pi / 2), 0, (math.pi / 8))
	LeftWingWeld.C1 = CFrame.new(-2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
	LeftWingWeld.Parent = LeftWing
	
	RightWing = Wing:Clone()
	RightWing.Name = "LeftWing"
	RightWing.Mesh.MeshId = (BaseUrl .. "223377796")
	RightWingWeld = Instance.new("Motor6D")
	RightWingWeld.Part0 = Torso
	RightWingWeld.Part1 = RightWing
	RightWingWeld.C0 = CFrame.new(-0.2, 1.6, 1.2) * CFrame.Angles((math.pi / 2), 0, -(math.pi / 8))
	RightWingWeld.C1 = CFrame.new(2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
	RightWingWeld.Parent = RightWing
	
	LeftWing.Parent = Tool
	RightWing.Parent = Tool
	
	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.P = (10 ^ 4)
	BodyVelocity.velocity = Vector3.new(0, 0, 0)
	BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	BodyVelocity.Parent = Torso
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = (10 ^ 6)
	BodyGyro.maxTorque = Vector3.new(0, 0, 0)
	BodyGyro.cframe = Torso.CFrame
	BodyGyro.Parent = Torso
		
	InvokeClient("DisableJump")
	
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
	Spawn(EquipWings)
	ToolEquipped = true
end

function Unequipped()
	Flying = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs({BodyVelocity, BodyGyro, LeftWing, RightWing}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v ~= Handle and v:IsA("BasePart") then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "Flying" and value then
		local Mode = value.Flying
		if Mode then
			Flying = true
			LeftWingWeld.C0 = CFrame.new(0.8, 1.6, 1.2) * CFrame.Angles((math.pi / 2), -(math.pi / 6), (math.pi / 8))
			LeftWingWeld.C1 = CFrame.new(-2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
			RightWingWeld.C0 = CFrame.new(-0.8, 1.6, 1.2) * CFrame.Angles((math.pi / 2), (math.pi / 6), -(math.pi / 8))
			RightWingWeld.C1 = CFrame.new(2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
		else
			Flying = false
			LeftWingWeld.C0 = CFrame.new(0.2, 1.6, 1.2) * CFrame.Angles((math.pi / 2), 0, (math.pi / 8))
			LeftWingWeld.C1 = CFrame.new(-2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
			RightWingWeld.C0 = CFrame.new(-0.2, 1.6, 1.2) * CFrame.Angles((math.pi / 2), 0, -(math.pi / 8))
			RightWingWeld.C1 = CFrame.new(2, -1.6, 0) * CFrame.Angles((math.pi / 2), 0, 0)
		end
	elseif mode == "SetWingSpan" then
		local Angle = value.Angle
		for i, v in pairs({LeftWingWeld, RightWingWeld}) do
			if v and v.Parent then
				v.DesiredAngle = (Angle * ((v == LeftWingWeld and -1) or 1))
				v.MaxVelocity = value.MaxVelocity
			end
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