--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

GrowTree = script:WaitForChild("GrowTree")

BaseUrl = "http://www.roblox.com/asset/?id="

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseTree = BasePart:Clone()
BaseTree.Name = "ChristmasTree"
BaseTree.Size = Vector3.new(0.2, 0.2, 1.3)
BaseTree.CanCollide = true
BaseTree.Anchored = false
BaseTreeMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "329865531"),
	TextureId = (BaseUrl .. "329865575"),
	Scale = Vector3.new(0.35, 0.35, 0.5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseTree,
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

Gravity = 196.20

ReloadTime = 20

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Tool.Enabled = true

function LoadAmmo(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	CurrentTree = BaseTree:Clone()
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = CurrentTree,
		C0 = CFrame.new(0, 0, -2.175),
		C1 = CFrame.new(0, 0, 0),
		Parent = CurrentTree,
	}
	CurrentTree.Parent = Tool
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	local MousePosition = MouseData.Position
	if not CurrentTree or not CurrentTree.Parent then
		LoadAmmo(true)
	else
		Sounds.Fire:Play()
		LoadAmmo(false)
		local StartPosition = (Handle.CFrame + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (BaseTree.Size.Z / 2)))
		StartPosition = (CFrame.new(StartPosition.p) * CFrame.Angles((math.pi / 2), 0, (math.random(-360, 360) * 0.01)))
		local TargetPosition = MousePosition
		local Direction = CFrame.new(StartPosition.p, TargetPosition)
		local Tree = BaseTree:Clone()
		Tree.CanCollide = true
		Tree.Friction = 2
		Tree.Elasticity = 0
		Tree.CFrame = StartPosition
		local Mass = (Tree:GetMass() * Gravity)
		local Speed = 50
		local Velocity = (Direction.lookVector * Speed)
		local BodyVelocity = Create("BodyVelocity"){
			Name = "BodyVelocity",
			maxForce = Vector3.new((Mass * 0), (Mass * 0.85), (Mass * 0)),
			velocity = Velocity,
			Parent = Tree,
		}
		local BodyGyro = Create("BodyGyro"){
			Name = "BodyGyro",
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			cframe = StartPosition,
			Parent = Tree,
		}
		Tree.Velocity = Velocity
		local GrowTreeCopy = GrowTree:Clone()
		GrowTreeCopy.Disabled = false
		GrowTreeCopy.Parent = Tree
		Debris:AddItem(Tree, 50)
		Tree.Parent = game:GetService("Workspace")
	end
	wait(ReloadTime)
	LoadAmmo(true)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

delay(0, (function()
	LoadAmmo(true)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)