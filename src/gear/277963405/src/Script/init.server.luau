--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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
		JetpackBody.Size = Vector3.new(2.25, 2.5, 1)
		local BodyMesh = Instance.new("SpecialMesh")
		BodyMesh.MeshType = Enum.MeshType.FileMesh
		BodyMesh.MeshId = (BaseUrl .. "277873557")
		BodyMesh.TextureId = (BaseUrl .. "277873878")
		BodyMesh.Scale = Vector3.new(2.5, 2.5, 2.5)
		BodyMesh.VertexColor = Vector3.new(1, 1, 1)
		BodyMesh.Offset = Vector3.new(0, 0, 0)
		BodyMesh.Parent = JetpackBody
		JetpackLeftWing = JetpackBody:Clone()
		JetpackLeftWing.Name = "LeftWing"
		JetpackLeftWing.Size = Vector3.new(1.75, 2.75, 0.5)
		JetpackLeftWing.Mesh.MeshId = (BaseUrl .. "277873487")
		JetpackLeftWing.Parent = JetpackModel
		JetpackRightWing = JetpackBody:Clone()
		JetpackRightWing.Name = "RightWing"
		JetpackRightWing.Size = Vector3.new(1.75, 2.75, 0.5)
		JetpackRightWing.Mesh.MeshId = (BaseUrl .. "277873654")
		JetpackRightWing.Parent = JetpackModel
		LeftMotor = Instance.new("Motor6D")
		LeftMotor.Name = "LeftMotor"
		LeftMotor.Part0 = JetpackBody
		LeftMotor.Part1 = JetpackLeftWing
		LeftMotor.C0 = CFrame.new(-0.258692503, 0.674243927, -0.188276291, 0.707105398, 0.707105577, -2.98077794e-008, -0.707106888, 0.707107544, -7.27595761e-010, -4.46598278e-008, -4.49217623e-008, 1.00000322)
		LeftMotor.C1 = CFrame.new(1.7955997, 0.416337013, -0.0686846972, 0.724684656, 0.689077854, -7.25473365e-006, -0.689079225, 0.724686801, -0.000323855231, -0.000217969035, 0.000239625399, 1.00000322)
		LeftMotor.Parent = JetpackBody
		RightMotor = Instance.new("Motor6D")
		RightMotor.Name = "RightMotor"
		RightMotor.Part0 = JetpackBody
		RightMotor.Part1 = JetpackRightWing
		RightMotor.C0 = CFrame.new(0.191435337, 0.684299469, -0.188274205, 0.707105458, 0.707105637, -2.98077794e-008, -0.707106888, 0.707107484, -6.98491931e-010, -4.46598278e-008, -4.49217623e-008, 1.0000031)
		RightMotor.C1 = CFrame.new(-1.87413609, 0.414978325, -0.0680331811, 0.707113981, 0.707096994, -3.06452694e-006, -0.707098365, 0.707116067, -8.22707079e-007, 1.52000575e-006, 2.68215081e-006, 1.00000322)
		RightMotor.MaxVelocity = 0.01
		RightMotor.DesiredAngle = -0.65
		RightMotor.CurrentAngle = RightMotor.DesiredAngle
		RightMotor.Parent = JetpackBody
		local BodyWeld = Instance.new("Weld")
		BodyWeld.Part0 = Torso
		BodyWeld.Part1 = JetpackBody
		BodyWeld.C0 = ((CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0) * CFrame.new(1.5, 1.5, 1.5)) * CFrame.Angles((math.pi / 2), 0, 0))
		BodyWeld.C1 = Tool.Grip
		LeftMotor.MaxVelocity = 0.01
		LeftMotor.DesiredAngle = 0.65
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
				v.DesiredAngle = (0.25 * ((string.find(string.lower(v.Name), "left") and -1) or 1))
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
				v.DesiredAngle = (0.65 * ((string.find(string.lower(v.Name), "left") and 1) or -1))
			end
		end
	end
end)

CreateJetpack(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)