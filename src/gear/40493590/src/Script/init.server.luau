--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PieScript = script:WaitForChild("PieScript")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

Pie = Instance.new("Part")
Pie.Name = Tool.Name
Pie.Shape = Enum.PartType.Block
Pie.Material = Enum.Material.Plastic
Pie.TopSurface = Enum.SurfaceType.Smooth
Pie.BottomSurface = Enum.SurfaceType.Smooth
Pie.FormFactor = Enum.FormFactor.Custom
Pie.Size = Vector3.new(2, 2, 1)
Pie.CanCollide = true
Pie.Locked = true
Pie.Anchored = false
Mesh:Clone().Parent = Pie
PieScript:Clone().Parent = Pie
Sounds.Hit:Clone().Parent = Pie

Loaded = true
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
	
	Handle.Transparency = 1
	
	Sounds.Fire:Play()

	local Direction = CFrame.new(Handle.Position, TargetPosition)
	
	local StartPosition = (Handle.CFrame + Direction.lookVector * 10)

	local pie = Pie:clone()
	pie.CFrame = CFrame.new(StartPosition.p)
	pie.CFrame = CFrame.new(pie.Position, TargetPosition) * CFrame.Angles(0, math.pi, 0)
	pie.Velocity = (Direction.lookVector * 50)

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, 240, 0)
	force.Parent = pie
	
	local gyro = Instance.new("BodyGyro")
	gyro.D = 5000
	gyro.maxTorque = Vector3.new(0, 0, 0)
	gyro.P = 3000
	gyro.cframe = pie.CFrame
	gyro.Parent = pie

	pie.PieScript.Disabled = false

	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Value = Player
	CreatorTag.Name = "creator"
	CreatorTag.Parent = pie
	
	Debris:AddItem(pie, 12)
	
	pie.Parent = game:GetService("Workspace")

end


function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	if Loaded then
		Loaded = false
		Fire(InvokeClient("MousePosition").Position)
		wait(0.3)
	else
		Handle.Transparency = 0
		wait(0.3)
		Loaded = true
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