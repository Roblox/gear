--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

FakeHandle = Tool:FindFirstChild("FakeHandle")
if FakeHandle then
	FakeHandle:Destroy()
	Handle.Transparency = 0
end

PenguinModel = InsertService:LoadAsset(170822767)
Penguin = PenguinModel:GetChildren()[1]:Clone()
if PenguinModel and PenguinModel.Parent then
	PenguinModel:Destroy()
end

Limbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

Gravity = 196.20

ReloadTime = 2
MaxDistance = 10

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Locked = true
BasePart.CanCollide = true

Equipped = false
InUse = false
Sliding = false

Spawn(function()
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end)

ClientControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "Click" and Player == player then
		if not InUse and Value then
			InUse = true
			Handle.Transparency = 1
			MakePenguin()
		elseif Value and not Sliding and Tool.Enabled then
			if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
				return
			end
			if not PlayerPenguin or not PlayerPenguin.Parent then
				MakePenguin()
			end
			if (Torso.Position - PenguinTorso.Position).magnitude > MaxDistance then
				return
			end
			Sliding = true
			if PlayerPenguin and PlayerPenguin.Parent then
				PlayerPenguin:Destroy()
			end
			local CharacterSizeMeasurement = Instance.new("Model")
			for i, v in pairs(Character:GetChildren()) do
				if v:IsA("BasePart") and CheckTable(Limbs, v.Name) then
					local Limb = v:Clone()
					Limb.Parent = CharacterSizeMeasurement
				end
			end
			local CharacterSize = CharacterSizeMeasurement:GetModelSize()
			SlidePart = BasePart:Clone()
			SlidePart.Name = "SlidePart"
			SlidePart.Size = Vector3.new(CharacterSize.X, 1, CharacterSize.Z)
			SlidePart.Transparency = 1
			local Weld = Instance.new("Weld")
			Weld.Part0 = SlidePart
			Weld.Part1 = Torso
			Weld.C0 = CFrame.new(0, 0, 0.5) * CFrame.Angles((math.pi / 2), 0, 0)
			Weld.Parent = SlidePart
			local PenguinScale = 2.5
			FakePenguinDisplay = BasePart:Clone()
			FakePenguinDisplay.Name = "FakePenguinDisplay"
			FakePenguinDisplay.Size = (Handle.Size * PenguinScale)
			local PenguinMesh = Mesh:Clone()
			PenguinMesh.Scale = Vector3.new(PenguinScale, PenguinScale, PenguinScale)
			PenguinMesh.Parent = FakePenguinDisplay
			local Weld = Instance.new("Weld")
			Weld.Part0 = FakePenguinDisplay
			Weld.Part1 = Torso
			Weld.C0 = CFrame.new(0, 0, -((Torso.Size.Z / 2) + (FakePenguinDisplay.Size.Z / 2) - 0.25))
			Weld.Parent = FakePenguinDisplay
			FakePenguinDisplay.Parent = Character
			BodyGyro = Instance.new("BodyGyro")
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.Parent = SlidePart
			local Mass = (GetTotalMass(Character) * Gravity)
			BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, 0, Mass)
			BodyVelocity.velocity = Vector3.new(0, 0, 0)
			BodyVelocity.Parent = SlidePart
			SlidePart.Parent = Character
			if Humanoid and Humanoid.Parent then
				Humanoid.PlatformStand = true
			end
			pcall(function()
				ServerControl:InvokeClient(Player, "Animation", true)
			end)
			while Sliding do
				local TargetPoint
				pcall(function()
					TargetPoint = ServerControl:InvokeClient(Player)
				end)
				if TargetPoint then
					BodyGyro.cframe = CFrame.new(SlidePart.Position, Vector3.new(TargetPoint.X, SlidePart.Position.Y, TargetPoint.Z)) * CFrame.Angles(math.pi, 0, 0)
					BodyVelocity.velocity = CFrame.new(SlidePart.Position, TargetPoint).lookVector * 50
				end
				wait()
			end
			for i, v in pairs({SlidePart, FakePenguinDisplay}) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			if Equipped then
				MakePenguin()
				PenguinTorso.Velocity = Vector3.new(0, 0, 0)
			end
			Torso.Velocity = Vector3.new(0, 0, 0)
		elseif Sliding and not Value then
			Tool.Enabled = false
			Sliding = false
			if Humanoid and Humanoid.Parent then
				Humanoid.PlatformStand = false
			end
			pcall(function()
				ServerControl:InvokeClient(Player, "Animation", false)
			end)
			wait(ReloadTime)
			Tool.Enabled = true
		end
	end
end)

function CheckTable(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
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

function MakePenguin()
	if PlayerPenguin and PlayerPenguin.Parent then
		PlayerPenguin:Destroy()
	end
	PlayerPenguin = Penguin:Clone()
	PenguinTorso = PlayerPenguin:FindFirstChild("Torso")
	PlayerPenguin:FindFirstChild("Creator").Value = Player
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerPenguin
	PlayerPenguin.Parent = game:GetService("Workspace")
	PenguinTorso.CFrame = Torso.CFrame - Torso.CFrame.lookVector * ((PenguinTorso.Size.Z / 2) + (Torso.Size.Z / 2) + 5)
	PenguinTorso.CFrame = PenguinTorso.CFrame - Vector3.new(0, (Torso.Size.Y / 2), 0)
end

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Handle.Transparency = 0
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
	Equipped = false
	InUse = false
	Sliding = false
	for i, v in pairs({PlayerPenguin, SlidePart, FakePenguinDisplay}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	pcall(function()
		ServerControl:InvokeClient(Player, "Animation", false)
	end)
	if Humanoid and Humanoid.Parent then
		Humanoid.PlatformStand = false
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)