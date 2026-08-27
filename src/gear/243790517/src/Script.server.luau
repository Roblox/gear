--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

ParticlesModel = InsertService:LoadAsset(228304820)
Particles = ParticlesModel:GetChildren()[1]:Clone()
Debris:AddItem(ParticlesModel, 1)
Smoke = Particles:WaitForChild("Smoke"):Clone()
Smoke.Enabled = false

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	InitialThrust = Handle:WaitForChild("InitialThrust"),
	Thrusting = Handle:WaitForChild("Thrusting"),
	Wind = Handle:WaitForChild("Wind"),
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
		JetpackBody.Size = Vector3.new(2.25, 2.5, 1)
		local BodyMesh = Instance.new("SpecialMesh")
		BodyMesh.MeshType = Enum.MeshType.FileMesh
		BodyMesh.MeshId = (BaseUrl .. "243182627")
		BodyMesh.TextureId = (BaseUrl .. "243182721")
		BodyMesh.Scale = Vector3.new(1, 1, 1)
		BodyMesh.VertexColor = Vector3.new(1, 1, 1)
		BodyMesh.Offset = Vector3.new(0, 0, 0)
		BodyMesh.Parent = JetpackBody
		JetpackLeftWing = BasePart:Clone()
		JetpackLeftWing.Name = "LeftWing"
		JetpackLeftWing.Size = Vector3.new(1.75, 2.75, 0.5)
		local LeftWingMesh = Instance.new("SpecialMesh")
		LeftWingMesh.MeshType = Enum.MeshType.FileMesh
		LeftWingMesh.MeshId = (BaseUrl .. "243182691")
		LeftWingMesh.TextureId = (BaseUrl .. "243182721")
		LeftWingMesh.Scale = Vector3.new(1, 1, 1)
		LeftWingMesh.VertexColor = Vector3.new(1, 1, 1)
		LeftWingMesh.Offset = Vector3.new(0, 0, 0)
		LeftWingMesh.Parent = JetpackLeftWing
		JetpackLeftWing.Parent = JetpackModel
		JetpackRightWing = BasePart:Clone()
		JetpackRightWing.Name = "RightWing"
		JetpackRightWing.Size = Vector3.new(1.75, 2.75, 0.5)
		local RightWingMesh = Instance.new("SpecialMesh")
		RightWingMesh.MeshType = Enum.MeshType.FileMesh
		RightWingMesh.MeshId = (BaseUrl .. "243182674")
		RightWingMesh.TextureId = (BaseUrl .. "243182721")
		RightWingMesh.Scale = Vector3.new(1, 1, 1)
		RightWingMesh.VertexColor = Vector3.new(1, 1, 1)
		RightWingMesh.Offset = Vector3.new(0, 0, 0)
		RightWingMesh.Parent = JetpackRightWing
		JetpackRightWing.Parent = JetpackModel
		LeftMotor = Instance.new("Motor6D")
		LeftMotor.Name = "LeftMotor"
		LeftMotor.Part0 = JetpackBody
		LeftMotor.Part1 = JetpackLeftWing
		LeftMotor.C0 = CFrame.new(-0.443515807, 1.27921724, 0.211530849, 0.707106829, 0.707106829, -2.98023224e-008, -0.707106769, 0.707106769, -4.6675524e-023, -4.47034836e-008, -4.47034836e-008, 1.00000036)
		LeftMotor.C1 = CFrame.new(0.624865592, 1.14753079, -0.0690159127, 0.707122684, 0.70710206, -1.10630299e-006, -0.707098246, 0.707118154, -8.09781397e-007, 2.47147113e-007, -1.18336413e-006, 1.00000405)
		LeftMotor.Parent = JetpackBody
		RightMotor = Instance.new("Motor6D")
		RightMotor.Name = "RightMotor"
		RightMotor.Part0 = JetpackBody
		RightMotor.Part1 = JetpackRightWing
		RightMotor.C0 = CFrame.new(0.406484276, 1.27921724, 0.211530849, 0.707106829, 0.707106829, -2.98023224e-008, -0.707106769, 0.707106769, -4.74819039e-023, -4.47034836e-008, -4.47034836e-008, 1.00000036)
		RightMotor.C1 = CFrame.new(-0.655302703, 1.15451002, -0.0682646558, 0.707122326, 0.707101941, -9.23872562e-007, -0.707098186, 0.707118332, -8.12114422e-007, 3.87430077e-007, -1.10268604e-006, 1.00000238)
		RightMotor.MaxVelocity = 0.005
		RightMotor.DesiredAngle = 0
		RightMotor.Parent = JetpackBody
		local BodyWeld = Instance.new("Weld")
		BodyWeld.Part0 = Torso
		BodyWeld.Part1 = JetpackBody
		BodyWeld.C0 = ((CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0) * CFrame.new(1.5, 1.5, 1.5)) * CFrame.Angles((math.pi / 2), 0, 0))
		BodyWeld.C1 = Tool.Grip
		LeftMotor.MaxVelocity = 0.005
		LeftMotor.DesiredAngle = 0
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
		LeftSmokeWeld.C0 = (CFrame.new(-0.9, -1.25, -0.25) * CFrame.Angles(math.pi, 0, 0))
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
		RightSmokeWeld.C0 = (CFrame.new(0.9, -1.25, -0.25) * CFrame.Angles(math.pi, 0, 0))
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
	elseif Mode == "EndFlight" and Flying then
		Flying = false
		Sounds.Thrusting:Stop()
		for i, v in pairs({LeftSmokePart, RightSmokePart}) do
			if v and v.Parent then
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("ParticleEmitter") then
						vv.Enabled = false
					end
				end
			end
		end
	elseif Mode == "BeginGlide" then
		Sounds.Wind:Play()
		for i, v in pairs({LeftMotor, RightMotor}) do
			if v and v.Parent then
				v.DesiredAngle = (0.25 * ((string.find(string.lower(v.Name), "left") and -1) or 1))
			end
		end
	elseif Mode == "EndGlide" then
		Sounds.Wind:Stop()
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