--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

GearModule = require(172349822)

RbxUtility = GearModule.RbxUtility

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")
ContentProvider = game:GetService("ContentProvider")

CharacterMonitor = script:WaitForChild("CharacterMonitor")
CFramePart = script:WaitForChild("CFramePart")

Display = Tool:FindFirstChild("DisplayPart")
GearModule.Destroy(Display)

BatModel = InsertService:LoadAsset(167116921)
Bat = BatModel:GetChildren()[1]:Clone()
GearModule.Destroy(BatModel)

BaseUrl = ContentProvider.BaseUrl

Cloak = GearModule.BasePart:Clone()
Cloak.Name = "Cloak"
Cloak.CanCollide = false
CloakMesh = RbxUtility.Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "asset/?id=94820260"),
	TextureId = (BaseUrl .. "asset/?id=94820166"),
	Scale = Vector3.new(1.5, 1.5, 1.5),
	Parent = Cloak
}

CloakFloatTime = 1
TouchDamage = 4

HeadWelds = {}
Clothing = {}
Limbs = {}
Motors = {}
TemporaryMotors = {}
OriginalLimbsResized = {}

Equip = false
Active = false
Transforming = false
Died = false

JumpTick = 0
Jumps = 0
JumpTime = 0.25
JumpsRequired = 2

ConsistentPlayerVariables = {
	Player = nil,
	Backpack = nil,
	Character = nil,
	Humanoid = nil,
	Head = nil,
	Torso = nil
}

Animations = {
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Base = Handle:WaitForChild("Base"),
	WindBreath = Handle:WaitForChild("WindBreath"),
	WindSqueak = Handle:WaitForChild("WindSqueak"),
	Squeak1 = Handle:WaitForChild("Squeak1"),
	Squeak2 = Handle:WaitForChild("Squeak2"),
	Squeak3 = Handle:WaitForChild("Squeak3")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or RbxUtility.Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool
})

ClientControl = (Tool:FindFirstChild("ClientControl") or RbxUtility.Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool
})

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if GearModule.CheckExistence({Player, player}) and player == Player then
		if Mode == "Button1Click" and Value then
			InvokeClient("PlaySound", Sounds.Base)
			SuperJump()
		elseif Mode == "Transform" then
			if not Transforming then
				if GearModule.CheckExistence(BatClone) and BatClone.Parent == ConsistentPlayerVariables.Character and CheckIfAlive(true) then
					Untransform()
				elseif Equipped and not Active and GearModule.CheckExistence(Character) and CheckIfAlive(false) then
					if (tick() - JumpTick) <= JumpTime or JumpTick == 0 then
						JumpTick = tick()
						Jumps = Jumps + 1
						if Jumps >= JumpsRequired then
							JumpTick = 0
							Jumps = 0
							Transform()
						end
					else
						JumpTick = tick()
						Jumps = 1
					end
				end
			end
		elseif Mode == "CFramePart" and Value then
			for i, v in pairs(Players:GetChildren()) do
				if v:IsA("Player") and v ~= ConsistentPlayerVariables.Player then
					local CFramePartClone = CFramePart:Clone()
					local PartValue = Instance.new("ObjectValue")
					PartValue.Name = "PartValue"
					PartValue.Value = Value.Part
					PartValue.Parent = CFramePartClone
					local CFrameValue = Instance.new("CFrameValue")
					CFrameValue.Name = "CFrameValue"
					CFrameValue.Value = Value.CFrame
					CFrameValue.Parent = CFramePartClone
					CFramePartClone.Disabled = false
					local PlayerBackpack = v:FindFirstChild("Backpack")
					local PlayerCharacter = v.Character
					CFramePartClone.Parent = ((PlayerBackpack and PlayerBackpack) or (PlayerCharacter and PlayerCharacter))
				end
			end
			return true
		elseif Mode == "CheckEquipped" then
			if (GearModule.CheckExistence(BatClone) and BatClone.Parent == ConsistentPlayerVariables.Character) or Equip then
				return true
			else
				return false
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(((ConsistentPlayerVariables.Player and ConsistentPlayerVariables.Player) or Player), Mode, Value)
	end)
	return ClientReturn
end

function GetAllObjects(Parent, Classes)
	local Objects = {}
	local function GetObjects(Parent, Classes)
		for i, v in pairs(Parent:GetChildren()) do
			if GearModule.CheckInstanceClass(v, Classes) then
				table.insert(Objects, v)
			end
			GetObjects(v, Classes)
		end
	end
	GetObjects(Parent, Classes)
	return Objects
end

function SuperJump()
	if (not GearModule.CheckExistence(BatClone) or BatClone.Parent ~= Character) and not GearModule.CheckExistence(CloakAntiGravity) then
		CloakAntiGravity = Instance.new("BodyForce")
		CloakAntiGravity.Name = "CloakAntiGravity"
		CloakAntiGravity.force = Vector3.new(0, (GearModule.GetTotalMass(Character) * GearModule.Gravity), 0)
		GearModule.Destroy({ChildAddedConnection, ChildRemovedConnection})
		ChildAddedConnection = Character.ChildRemoved:connect(function()
			CloakAntiGravity.force = Vector3.new(0, (GearModule.GetTotalMass(Character) * GearModule.Gravity), 0)
		end)
		ChildRemovedConnection = Character.ChildAdded:connect(function()
			CloakAntiGravity.force = Vector3.new(0, (GearModule.GetTotalMass(Character) * GearModule.Gravity), 0)
		end)
		CloakAntiGravity.Parent = Torso
		Debris:AddItem(CloakAntiGravity, CloakFloatTime)
		Delay(CloakFloatTime, function()
			GearModule.Destroy({ChildAddedConnection, ChildRemovedConnection})
		end)
	end
end

function BatTouched(Hit)
	if GearModule.CheckExistence(Hit) and Hit.Parent ~= ConsistentPlayerVariables.Character and Hit.Parent ~= BatClone then
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			GearModule.UntagHumanoid(humanoid)
			GearModule.TagHumanoid(humanoid, ConsistentPlayerVariables.Player)
			humanoid:TakeDamage(TouchDamage)
		end
	end
end

function MakeTransparent(Parent, Transparency)
	for i, v in pairs(Parent:GetChildren()) do
		if v ~= BatClone and v ~= Tool then
			pcall(function()
				if v ~= ConsistentPlayerVariables.HumanoidRootPart then
					v.Transparency = Transparency
				end
			end)
			MakeTransparent(v, Transparency)
		end
	end
end

function Die()
	if not GearModule.CheckExistence(ConsistentPlayerVariables.Character) or Died then
		return
	end
	Died = true
	if GearModule.CheckExistence(ConsistentPlayerVariables.Humanoid) then
		ConsistentPlayerVariables.Humanoid.Health = 0
	end
	ConsistentPlayerVariables.Character:BreakJoints()
end

function FunctionBat()
	local Consistency = 0.0001
	local Waiting = false
	local WingsDown = true
	local LastWingAngle = 0
	local LastRandomSqueakTime = 0
	local function IsClose(A, B, Epsilon)
		Epsilon = (Epsilon or 0.01)
		return (A <= (B + Epsilon) and (A >= (B - Epsilon)))
	end
	if not CheckIfAlive(true) then
		return
	end
	while GearModule.CheckExistence(BatClone) and BatClone.Parent == ConsistentPlayerVariables.Character and Active do
		if not CheckIfAlive(true) or not GearModule.CheckExistence({BatClone, BatBody, BatWeld, LeftShoulder, RightShoulder}) then
			Die()
			break
		end
		if not Waiting then
			local Angle = ((WingsDown and 0.5) or -0.4)
			LeftShoulder.DesiredAngle = Angle
			RightShoulder.DesiredAngle = Angle
			for i, v in pairs({LeftShoulder, RightShoulder}) do
				v.MaxVelocity = 0.075
			end
			LastWingAngle = Angle
			Waiting = true
		else
			if IsClose(LeftShoulder.CurrentAngle, LastWingAngle) or IsClose(RightShoulder.CurrentAngle, LastWingAngle) then
				WingsDown = not WingsDown
				Waiting = false
			end
		end
		local Now = time()
		if (Now - LastRandomSqueakTime) > 1 and math.random() < 0.1 then
			if #SqueakSounds > 0 then
				InvokeClient("PlaySound", SqueakSounds[math.random(1, #SqueakSounds)])
				LastRandomSqueakTime = Now
			end
		end
		wait(Consistency)
	end
end


function Transform()
	
	Transforming = true

	InvokeClient("SetCoreGuiEnabled", {Enum = Enum.CoreGuiType.Backpack, Boolean = false})
	
	ConsistentPlayerVariables.Player = Player
	ConsistentPlayerVariables.Backpack = Backpack
	ConsistentPlayerVariables.Character = Character
	ConsistentPlayerVariables.Humanoid = Humanoid
	ConsistentPlayerVariables.Head = Head
	ConsistentPlayerVariables.Torso = Torso
	ConsistentPlayerVariables.HumanoidRootPart = HumanoidRootPart
	
	BatClone = Bat:Clone()
	BatBody = BatClone:FindFirstChild("Torso")
	LeftShoulder = BatBody:FindFirstChild("Left Shoulder")
	RightShoulder = BatBody:FindFirstChild("Right Shoulder")
	
	InvokeClient("SetCamera", {Property = "CameraType", Value = Enum.CameraType.Follow})
	InvokeClient("SetCamera", {Property = "CameraSubject", Value = BatBody})
	
	for i, v in pairs({Sounds.WindSqueak, Sounds.Squeak1, Sounds.Squeak2, Sounds.Squeak3}) do
		local Sound = v:Clone()
		Sound.Parent = BatBody
	end
	
	SqueakSounds = {BatBody:FindFirstChild("Squeak1"), BatBody:FindFirstChild("Squeak2"), BatBody:FindFirstChild("Squeak3")}
	
	local WindSqueak = BatBody:FindFirstChild(Sounds.WindSqueak.Name)
	if WindSqueak then
		InvokeClient("PlaySound", WindSqueak)
	end
	
	if not CheckIfAlive(true) or not BatClone or not BatBody or not LeftShoulder or not RightShoulder then
		return
	end
	
	MakeTransparent(ConsistentPlayerVariables.Character, 1)
	GearModule.Destroy(CloakClone)
	
	local CharacterMonitorClone = game:GetService("Workspace"):FindFirstChild(ConsistentPlayerVariables.Player.Name .. CharacterMonitor.Name)
	GearModule.Destroy(CharacterMonitorClone)
	
	CharacterMonitorClone = CharacterMonitor:Clone()
	CharacterMonitorClone.Name = (ConsistentPlayerVariables.Player.Name .. CharacterMonitor.Name)
	
	local CreatorValue = RbxUtility.Create("ObjectValue"){
		Name = "Creator",
		Value = ConsistentPlayerVariables.Player,
		Parent = CharacterMonitorClone
	}
	
	local ModelValue = RbxUtility.Create("ObjectValue"){
		Name = "Model",
		Value = BatClone,
		Parent = CharacterMonitorClone
	}
	
	local ToolValue = RbxUtility.Create("ObjectValue"){
		Name = "Tool",
		Value = Tool,
		Parent = CharacterMonitorClone
	}
		
	CharacterMonitorClone.Disabled = false
	CharacterMonitorClone.Parent = game:GetService("Workspace")
	
	BatBody.Anchored = true
	for i, v in pairs(BatClone:GetChildren()) do
		if v:IsA("BasePart") then
			v.Touched:connect(BatTouched)
		end
	end
	
	for i, v in pairs(ConsistentPlayerVariables.Head:GetChildren()) do
		if v:IsA("Weld") and v.Name == "HeadWeld" then
			if v.Part0 and v.Part1 and v.Part0 == ConsistentPlayerVariables.Head and v.Part1.Name == "Handle" and v.Part1.Parent:IsA("Hat") then
				table.insert(HeadWelds, {Hat = v.Part1.Parent:Clone(), Weld = {Part0 = v.Part0, Part1 = v.Part1, C0 = v.C0, C1 = v.C1}})
				GearModule.Destroy({v, v.Part1.Parent})
			else
				GearModule.Destroy(v)
			end
		end
	end
	
	local TemporaryClothing = GetAllObjects(ConsistentPlayerVariables.Character, {"Decal", "Texture"})
	for i, v in pairs(TemporaryClothing) do
		table.insert(Clothing, {Object = v:Clone(), Parent = v.Parent})
		GearModule.Destroy(v)
	end	
	
	for i, v in pairs(ConsistentPlayerVariables.Torso:GetChildren()) do
		if v:IsA("JointInstance") and v:IsA("Motor") and v.Part0 and v.Part1 and v.Part0 == ConsistentPlayerVariables.Torso and v.Part1 ~= ConsistentPlayerVariables.Head then
			table.insert(Limbs, {Limb = {Part = v.Part1:Clone(), Parent = v.Part1.Parent}, Motor = {Name = v.Name, MaxVelocity = v.MaxVelocity, Part0 = v.Part0, Part1 = v.Part1, C0 = v.C0, C1 = v.C1, Parent = v.Parent}})
			GearModule.Destroy(v.Part1)
		end
	end
	
	local LimbsResized = {}
	for i, v in pairs({ConsistentPlayerVariables.Torso, ConsistentPlayerVariables.HumanoidRootPart}) do
		for ii, vv in pairs(v:GetChildren()) do
			if vv:IsA("JointInstance") and vv:IsA("Motor") and vv.Part0 and vv.Part1 then
				table.insert(Motors, {Name = vv.Name, MaxVelocity = vv.MaxVelocity, Part0 = vv.Part0, Part0Size = vv.Part0.Size, Part1 = vv.Part1, Part1Size = vv.Part1.Size, C0 = vv.C0, C1 = vv.C1, Parent = v})
				local Motor = RbxUtility.Create("Motor6D"){
					Name = vv.Name,
					MaxVelocity = 0,
					C0 = CFrame.new(0, 0, 0),
					C1 = CFrame.new(0, 0, 0),
					Part0 = vv.Part0,
					Part1 = vv.Part1,
				}
				for iii, vvv in pairs({vv.Part0, vv.Part1}) do
					if not GearModule.CheckTableForInstance(LimbsResized, vvv) then
						table.insert(LimbsResized, vvv)
						table.insert(OriginalLimbsResized, {Limb = vvv, Size = vvv.Size})
					end
				end
				table.insert(TemporaryMotors, {Motor = Motor, Parent = v})
			end
		end
	end
	for i, v in pairs(LimbsResized) do
		v.FormFactor = Enum.FormFactor.Custom
		v.Size = Vector3.new(0.2, 0.2, 0.2)
	end
	for i, v in pairs(TemporaryMotors) do
		v.Motor.Parent = v.Parent
	end
	
	FakeHeadWeld = RbxUtility.Create("Weld"){
		Name = "HeadWeld",
		Parent = ConsistentPlayerVariables.Head
	}
		
	BatWeld = RbxUtility.Create("Motor6D"){
		Name = "BatWeld",
		Part0 = BatBody,
		Part1 = ConsistentPlayerVariables.Torso,
		Parent = BatBody
	}
	
	BatBody.CFrame = ConsistentPlayerVariables.Torso.CFrame
	BatBody.Velocity = Vector3.new(0, 0, 0)
	BatBody.RotVelocity = Vector3.new(0, 0, 0)
	BatClone.Parent = ConsistentPlayerVariables.Character
	
	local Smoke = RbxUtility.Create("Smoke"){
		Enabled = true,
		Parent = BatBody
	}
	Delay(0.3, function()
		if GearModule.CheckExistence(Smoke) then
			Smoke.Enabled = false
		end
	end)
	Debris:AddItem(Smoke, 5)
	
	HumanoidDied = ConsistentPlayerVariables.Humanoid.Died:connect(Die)
	
	ToolAdded = ConsistentPlayerVariables.Character.ChildAdded:connect(function(Child)
		if Child:IsA("Tool") and Child ~= Tool then
			Delay(0.1, function()
				GearModule.Destroy(Child)
			end)
		end
	end)
	
	for i, v in pairs(ConsistentPlayerVariables.Character:GetChildren()) do
		if v:IsA("Tool") and v ~= Tool then
			v.Parent = ConsistentPlayerVariables.Backpack
		end
	end
	
	Active = true
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = Handle
	Weld.Part1 = ConsistentPlayerVariables.Torso
	Weld.Parent = Handle
	
	Spawn(function()
		FunctionBat()
	end)
	InvokeClient("FunctionBat", BatBody)
	
	Transforming = false
	
	return BatClone
end

function Untransform()
	
	InvokeClient("SetCoreGuiEnabled", {Enum = Enum.CoreGuiType.Backpack, Boolean = false})
		
	InvokeClient("SetCamera", {Property = "CameraType", Value = Enum.CameraType.Custom})
	InvokeClient("SetCamera", {Property = "CameraSubject", Value = ConsistentPlayerVariables.Humanoid})
	
	InvokeClient("PlaySound", Sounds.WindBreath)
	local SmokePart = GearModule.BasePart:Clone()
	SmokePart.Transparency = 1
	SmokePart.Anchored = true
	SmokePart.CanCollide = false
	local Smoke = RbxUtility.Create("Smoke"){
		Enabled = true,
		Parent = SmokePart
	}
	Delay(0.3, function()
		if GearModule.CheckExistence(Smoke) then
			Smoke.Enabled = false
		end
	end)
	Debris:AddItem(SmokePart, 5)
	SmokePart.Parent = game:GetService("Workspace")
	SmokePart.CFrame = BatBody.CFrame
	GearModule.Destroy({ToolAdded, HumanoidDied, BatClone, FakeHeadWeld, TemporaryMotors})
	local LimbsResized = {}
	TemporaryMotors = {}
	for i, v in pairs(Motors) do
		local Motor = RbxUtility.Create("Motor6D"){
			Name = v.Name,
			MaxVelocity = v.MaxVelocity,
			C0 = v.C0,
			C1 = v.C1,
			Part0 = v.Part0,
			Part1 = v.Part1,
		}
		table.insert(TemporaryMotors, {Motor = Motor, Parent = v.Parent})
	end
	for i, v in pairs(OriginalLimbsResized) do
		v.Limb.FormFactor = Enum.FormFactor.Custom
		v.Limb.Size = v.Size
	end
	for i, v in pairs(TemporaryMotors) do
		v.Motor.Parent = v.Parent
	end
	for i, v in pairs(Limbs) do
		local Limb = v.Limb.Part:Clone()
		local Motor = RbxUtility.Create("Motor6D"){
			Name = v.Motor.Name,
			MaxVelocity = v.Motor.MaxVelocity,
			C0 = v.Motor.C0,
			C1 = v.Motor.C1,
			Part0 = ConsistentPlayerVariables.Torso,
			Part1 = Limb,
			Parent = v.Motor.Parent
		}
		Limb.Parent = v.Limb.Parent
	end
	for i, v in pairs(Clothing) do
		if GearModule.CheckExistence(v.Parent) then
			local Object = v.Object:Clone()
			Object.Parent = v.Parent
		end
	end
	for i, v in pairs(HeadWelds) do
		local Hat = v.Hat:Clone()
		local handle = Hat:FindFirstChild("Handle")
		if handle then
			local Motor = RbxUtility.Create("Weld"){
				Name = "HeadWeld",
				C0 = v.Weld.C0,
				C1 = v.Weld.C1,
				Part0 = ConsistentPlayerVariables.Head,
				Part1 = handle,
				Parent = ConsistentPlayerVariables.Head
			}
			Hat.Parent = ConsistentPlayerVariables.Character
		end
	end
	HeadWelds = {}
	Clothing = {}
	Limbs = {}
	Motors = {}
	TemporaryMotors = {}
	OriginalLimbsResized = {}
	MakeTransparent(ConsistentPlayerVariables.Character, 0)
	ConsistentPlayerVariables.Torso.Velocity = Vector3.new(0, 0, 0)
	ConsistentPlayerVariables.Torso.RotVelocity = Vector3.new(0, 0, 0)
	Active = false
	Equipped()
end

function SetToolTransparency()
	local ToolParent = Tool.Parent
	local MakeTransparent = true
	if not ToolParent:IsA("Backpack") and not Players:GetPlayerFromCharacter(ToolParent) then
		for i, v in pairs(ConsistentPlayerVariables) do
			ConsistentPlayerVariables[i] = nil
		end
		Die()
		MakeTransparent = false
		Active = false
	end
	local HandlePieces = Handle:GetChildren()
	table.insert(HandlePieces, Handle)
	for i, v in pairs(HandlePieces) do
		if v:IsA("BasePart") then
			v.Transparency = ((MakeTransparent and 1) or 0)
		end
	end
end
function CheckIfAlive(Current)
	return (GearModule.CheckExistence({((Current and ConsistentPlayerVariables.Player) or Player), ((Current and ConsistentPlayerVariables.Backpack) or Backpack), ((Current and ConsistentPlayerVariables.Humanoid) or Humanoid), ((Current and ConsistentPlayerVariables.Head) or Head), ((Current and ConsistentPlayerVariables.Torso) or Torso), ((Current and ConsistentPlayerVariables.HumanoidRootPart) or HumanoidRootPart)}) and ((Current and ConsistentPlayerVariables.Humanoid.Health > 0) or Humanoid.Health > 0))
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end
	Backpack = Player:FindFirstChild("Backpack")
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive(false) then
		Unequipped()
		return
	end
	if Active then
		return
	end
	Spawn(function()
		SetToolTransparency()
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") and v.Name == Cloak.Name then
				v:Destroy()
			end
		end
		CloakClone = Cloak:Clone()
		local Weld = RbxUtility.Create("Weld"){
			Name = "CloakWeld",
			Part0 = Torso,
			Part1 = CloakClone,
			C1 = CFrame.new(0, 0.545642853, -0.638683319),
			Parent = Torso
		}
		CloakClone.Parent = Character
		--InvokeClient("PlayAnimation", Animations.Idle)
	end)
	Humanoid.WalkSpeed = 22
	Equip = true
end

function Unequipped()
	Equip = false
	if GearModule.CheckExistence(Humanoid) then
		Humanoid.WalkSpeed = 16
	end
	GearModule.Destroy({CloakClone, CloakAntiGravity, ChildAddedConnection, ChildRemovedConnection})
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	if Active then
		return
	end
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		SetToolTransparency()
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)