--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

StarScript = script:WaitForChild("BoltScript")

Velocity = 50

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

BaseUrl = "http://www.roblox.com/asset/?id="

Bolt = Instance.new("Part")
Bolt.Name = "CrossbowBolt"
Bolt.Shape = Enum.PartType.Block
Bolt.Material = Enum.Material.Plastic
Bolt.TopSurface = Enum.SurfaceType.Smooth
Bolt.BottomSurface = Enum.SurfaceType.Smooth
Bolt.FormFactor = Enum.FormFactor.Custom
Bolt.Size = Vector3.new(1, 0.4, 2)
Bolt.CanCollide = true
Bolt.Locked = true
Bolt.Anchored = false
BoltMesh = Instance.new("SpecialMesh")
BoltMesh.MeshType = Enum.MeshType.FileMesh
BoltMesh.MeshId = (BaseUrl .. "15887356")
BoltMesh.TextureId = (BaseUrl .. "15886781")
BoltMesh.Scale = Vector3.new(1, 1, 1)
BoltMesh.Parent = Bolt
StarScript:Clone().Parent = Bolt
Sounds.Hit:Clone().Parent = Bolt

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function Fire(TargetPosition)
	
	Sounds.Fire:Play()
	
	local StartPosition = (Handle.CFrame + CFrame.new(Handle.Position, TargetPosition).lookVector * ((Handle.Size.Z / 2) + (Bolt.Size.Z / 2)))

	local Direction = CFrame.new(StartPosition.p, TargetPosition)
	
	StartPosition = (StartPosition + Direction.lookVector * 2)

	Direction = CFrame.new(StartPosition.p, TargetPosition)
	
	local bolt = Bolt:clone()
	bolt.CFrame = Direction * CFrame.Angles(0, math.pi, 0)
	bolt.Velocity = (Direction.lookVector * 40)

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, 150, 0)
	force.Parent = bolt
	
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge,  math.huge, math.huge)
	BodyGyro.cframe = bolt.CFrame
	BodyGyro.Parent = bolt

	bolt.BoltScript.Disabled = false

	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Value = Player
	CreatorTag.Name = "creator"
	CreatorTag.Parent = bolt
	
	Debris:AddItem(bolt, 20)
	
	bolt.Parent = game:GetService("Workspace")

end


function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local BoltDisplay = Tool:FindFirstChild("BoltDisplay")
	Tool.Enabled = false
	if BoltDisplay then
		BoltDisplay.Transparency = 1
	end
	Fire(InvokeClient("MousePosition").Position)
	wait(2)
	if BoltDisplay then
		BoltDisplay.Transparency = 0
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)