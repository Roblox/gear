--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Smoke = script:WaitForChild("Smoke")
Smoke.Enabled = false

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	InitialThrust = Handle:WaitForChild("InitialThrust"),
}

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

Flying = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function CreateJetpack(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("BasePart") or v:IsA("Model")) and v ~= Handle then
			v:Destroy()
		end
	end
	if Create then
		JetpackModel = Instance.new("Model")
		JetpackModel.Name = "JetpackModel"
		JetpackBody = BasePart:Clone()
		JetpackBody.Name = "Body"
		JetpackBody.Size = Vector3.new(3, 3, 0.2)
		local BodyMesh = Instance.new("SpecialMesh")
		BodyMesh.MeshType = Enum.MeshType.FileMesh
		BodyMesh.MeshId = (BaseUrl .. "358561633")
		BodyMesh.TextureId = (BaseUrl .. "358561835")
		BodyMesh.Scale = Vector3.new(1, 1, 1)
		BodyMesh.VertexColor = Vector3.new(1, 1, 1)
		BodyMesh.Offset = Vector3.new(0, 0, 0)
		BodyMesh.Parent = JetpackBody
		JetpackLeftWing = JetpackBody:Clone()
		JetpackLeftWing.Name = "LeftWing"
		JetpackLeftWing.Mesh.MeshId = (BaseUrl .. "358561494")
		JetpackLeftWing.Parent = JetpackModel
		JetpackRightWing = JetpackBody:Clone()
		JetpackRightWing.Name = "RightWing"
		JetpackRightWing.Mesh.MeshId = (BaseUrl .. "358561439")
		JetpackRightWing.Parent = JetpackModel
		LeftMotor = Instance.new("Motor6D")
		LeftMotor.Name = "LeftMotor"
		LeftMotor.Part0 = JetpackBody
		LeftMotor.Part1 = JetpackLeftWing
		LeftMotor.C0 = CFrame.new(-1.20348334, -0.147620395, -0.932994068, -1, 0, -8.74227766e-008, 0, 1, 0, 8.74227766e-008, 0, -1)
		LeftMotor.C1 = CFrame.new(1.48662543, -0.147634506, -0.742988586, -1.00000381, -3.57627869e-007, -1.1920929e-007, 4.47034836e-007, 1, -4.47034836e-008, -4.84287739e-008, 1.04308128e-007, -1.00000107)
		LeftMotor.Parent = JetpackBody
		RightMotor = Instance.new("Motor6D")
		RightMotor.Name = "RightMotor"
		RightMotor.Part0 = JetpackBody
		RightMotor.Part1 = JetpackRightWing
		RightMotor.C0 = CFrame.new(1.34692574, -0.126448825, 0.978314459, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		RightMotor.C1 = CFrame.new(-1.36299276, -0.126451492, 1.16832352, 1.00000405, -3.57627869e-007, 3.7252903e-008, 0, 1, 1.49011612e-008, 8.19563866e-008, 8.94069672e-008, 1.00000119)
		RightMotor.MaxVelocity = 0.01
		RightMotor.DesiredAngle = 0
		RightMotor.CurrentAngle = RightMotor.DesiredAngle
		RightMotor.Parent = JetpackBody
		local BodyWeld = Instance.new("Weld")
		BodyWeld.Part0 = Torso
		BodyWeld.Part1 = JetpackBody
		BodyWeld.C0 = ((CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0) * CFrame.new(1.5, 1.5, 1.5)) * CFrame.Angles((math.pi / 2), 0, 0))
		BodyWeld.C1 = Tool.Grip
		LeftMotor.MaxVelocity = 0.01
		LeftMotor.DesiredAngle = 0
		LeftMotor.CurrentAngle = LeftMotor.DesiredAngle
		BodyWeld.Parent = JetpackBody
		LeftSmokePart = BasePart:Clone()
		LeftSmokePart.Name = "LeftSmokePart"
		LeftSmokePart.Transparency = 1
		LeftSmokePart.Size = Vector3.new(0.2, 0.2, 0.2)
		LeftSmokePart.CanCollide = false
		LeftSmokePart.Parent = JetpackModel
		local LeftSmoke = Smoke:Clone()
		LeftSmoke.Parent = LeftSmokePart
		local LeftSmokeWeld = Instance.new("Weld")
		LeftSmokeWeld.Part0 = JetpackBody
		LeftSmokeWeld.Part1 = LeftSmokePart
		LeftSmokeWeld.C0 = (CFrame.new(-0.6, -1.25, -0.25) * CFrame.Angles(math.pi, 0, 0))
		LeftSmokeWeld.Parent = LeftSmokePart
		RightSmokePart = BasePart:Clone()
		RightSmokePart.Name = "RightSmokePart"
		RightSmokePart.Transparency = 1
		RightSmokePart.Size = Vector3.new(0.2, 0.2, 0.2)
		RightSmokePart.CanCollide = false
		RightSmokePart.Parent = JetpackModel
		local RightSmoke = Smoke:Clone()
		RightSmoke.Parent = RightSmokePart
		local RightSmokeWeld = Instance.new("Weld")
		RightSmokeWeld.Part0 = JetpackBody
		RightSmokeWeld.Part1 = RightSmokePart
		RightSmokeWeld.C0 = (CFrame.new(0.6, -1.25, -0.25) * CFrame.Angles(math.pi, 0, 0))
		RightSmokeWeld.Parent = RightSmokePart
		JetpackBody.Parent = JetpackModel
		JetpackModel.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	Spawn(function()
		CreateJetpack(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	Flying = false
	Handle.Transparency = 0
	CreateJetpack(false)
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode then
		return
	end
	if not JetpackModel or not JetpackModel.Parent then
		return
	end
	if Mode == "BeginFlight" and not Flying then
		Flying = true
		Sounds.InitialThrust:Play()
		for i, v in pairs({LeftSmokePart, RightSmokePart}) do
			if v and v.Parent then
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("ParticleEmitter") then
						vv.Enabled = true
					end
				end
			end
		end
		for i, v in pairs({LeftMotor, RightMotor}) do
			if v and v.Parent then
				v.DesiredAngle = 0.25
			end
		end
	elseif Mode == "EndFlight" and Flying then
		Flying = false
		for i, v in pairs({LeftSmokePart, RightSmokePart}) do
			if v and v.Parent then
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("ParticleEmitter") then
						vv.Enabled = false
					end
				end
			end
		end
		for i, v in pairs({LeftMotor, RightMotor}) do
			if v and v.Parent then
				v.DesiredAngle = 0
			end
		end
	end
end)

CreateJetpack(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)