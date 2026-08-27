--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

VineModel = InsertService:LoadAsset(178364498)
Vine = VineModel:GetChildren()[1]:Clone()

for i, v in pairs({VineModel}) do
	if v and v.Parent then
		v:Destroy()
	end
end

Sounds = {
	Equip = Handle:WaitForChild("EquipSound"),
	Plant = Handle:WaitForChild("PlantSound")
}

Animations = {
	StaffUp = Tool:WaitForChild("StaffUp"),
	R15StaffUp = Tool:WaitForChild("R15StaffUp")
}

ReloadTime = 3
Duration = 9
Damage = 0

Sparkles = Handle:WaitForChild("Sparkles")
Sparkles.Enabled = false

BodyRotation = Instance.new("BodyAngularVelocity")
BodyRotation.P = 150000
BodyRotation.angularvelocity = Vector3.new(0, 25, 0)
BodyRotation.maxTorque = Vector3.new(BodyRotation.P, BodyRotation.P, BodyRotation.P)

BasePart = Instance.new("Part")
BasePart.Name = "Part"
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		end
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		local ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
		return ClientReturn
	end)
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function TransformModel(Parent, NewCFrame)
	Parent:MoveTo(NewCFrame.p)
	local Origins = {}
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			Origins[v] = Parent:GetModelCFrame():toObjectSpace(v.CFrame)
		end
	end
	for i, v in pairs(Origins) do
		i.CFrame = NewCFrame:toWorldSpace(v)
	end
end

function CreateVine(VineModel, Center, Pos)
	local VineClone = Vine:Clone()
	VineClone.Parent = VineModel
	Pos = CFrame.new(Pos.p, Center) * CFrame.Angles(0, (math.pi / 2), 0)
	Pos = Pos + Vector3.new(0, ((VineClone:GetModelSize().Y / 2) - (Torso.Size.Y * 1.5)), 0)
	TransformModel(VineClone, Pos)
	return VineClone
end

function SpawnVine(Center)
	
	local VineModel = Instance.new("Model")
	VineModel.Name = "Vines"
	Debris:AddItem(VineModel, Duration)
	VineModel.Parent = game:GetService("Workspace")
	
	local NumberOfVines = 16
	local Increment = ((math.pi * 2) / NumberOfVines)
	local LookVector = CFrame.new(Center).lookVector
	local PosX = (12.5 * LookVector.x)
	local PosZ = (12.5 * LookVector.z)
	local Pos = Vector3.new((Center.x + PosX), Center.y, (Center.z + PosZ))
	local Vines = {}

	for i = 1, NumberOfVines do
		local Vine = CreateVine(VineModel, Center, CFrame.new(Pos))
 		local Angle = (Increment * i)
		ScriptIt(Vine)
		table.insert(Vines, Vine)
		Pos = Vector3.new(((Pos.x - Center.x) * math.cos(Angle)) - ((Pos.z - Center.z) * math.sin(Angle)) + Center.x, Center.y, ((Pos.x - Center.x) * math.sin(Angle)) + ((Pos.z - Center.z) * math.cos(Angle)) + Center.z)
	end

end

function ScriptIt(Parent)
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			Touched(v)
		end
	end
end

function WeldTo(PrimaryPart, SecondaryPart)
	if not PrimaryPart or not SecondaryPart then
		return
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = PrimaryPart
	Weld.Part1 = SecondaryPart
	Weld.C0 = PrimaryPart.CFrame:inverse()
	Weld.C1 = SecondaryPart.CFrame:inverse()
	Weld.Parent = PrimaryPart
	return Weld
end

function Touched(Part)
	local CurrentPlayer = Player
	local CurrentHumanoid = Humanoid
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Hit.Anchored then
			return
		end
		local humanoid = Hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid == CurrentHumanoid or humanoid.Health == 0 then
			return
		end
		local Weld = WeldTo(Part, Hit)
		Debris:AddItem(Weld, 3)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, CurrentPlayer)
		humanoid:TakeDamage(Damage)
	end)
end

function StaffUp()
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)
end

function StaffOut()
	Tool.GripForward = Vector3.new(0.0976, 0.00976, -0.995)
	Tool.GripRight = Vector3.new(0.195, -0.981, 0.00952)
	Tool.GripUp = Vector3.new(0.976, 0.195, 0.0976)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	local RayHit, RayHitPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 4), {Character})
	if not RayHit then
		return
	end

	Tool.Enabled = false
	
	StaffOut()
	
	Sparkles.Enabled = true
	
	Sounds.Plant:Play()
	
	local Animation = Animations.StaffUp
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15StaffUp
	end 
	InvokeClient("PlayAnimation", {Animation = Animation, FadeTime = 0.1, Weight = 1, Speed = 2})
	Delay(0.85, function()
		InvokeClient("StopAnimation", Animation)
	end)
	
	local BodyRotationClone = BodyRotation:Clone()
	Debris:AddItem(BodyRotationClone, 0.5)
	BodyRotationClone.Parent = Torso
	
	SpawnVine(RayHitPos)
	
	wait(0.5)
	
	StaffUp()

	wait(Duration)
	
	Sparkles.Enabled = false
	
	wait(ReloadTime)

	Tool.Enabled = true

end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Equip:Play()
end

function Unequipped()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)