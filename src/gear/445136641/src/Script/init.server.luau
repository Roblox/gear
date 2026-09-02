--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

ExplosionScript = script:WaitForChild("ExplosionScript")

Animations = {
	Light = {Animation = Tool:WaitForChild("Light"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Fuse = Handle:WaitForChild("Fuse"),
}

Sparks = Handle:WaitForChild("Sparks")

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

BaseFirework = Handle:Clone()
BaseFirework.Name = "Firework"
BaseFirework.Transparency = 0
BaseFirework.Locked = true
BaseFirework.CanCollide = true

Rate = (1 / 60)
Gravity = 196.20

ReloadTime = 10

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Sparks.Enabled = false
Handle.Transparency = 0
Tool.Enabled = true

function FireFirework()
	Handle.Transparency = 1
	local Firework = BaseFirework:Clone()
	Firework.CFrame = Handle.CFrame
	local Force = 35
	local Mass = (Firework:GetMass() * Gravity)
	local Velocity = (Vector3.new(0, 1, 0) * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Firework,
	}
	local AngleX, AngleY, AngleZ = Handle.CFrame:toEulerAnglesXYZ()
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		cframe = CFrame.new(0, AngleY, 0),
		Parent = Firework,
	}
	Firework.Velocity = Velocity
	Debris:AddItem(Firework, (60 / 2))
	Firework.Parent = game:GetService("Workspace")
	return Firework
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Enabled = false
	Sparks.Enabled = true
	Sounds.Fuse:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Light)
	end)
	wait(2)
	if CurrentlyEquipped then
		Sparks.Enabled = false
		local Firework = FireFirework()
		local ExplosionScriptClone = ExplosionScript:Clone()
		ExplosionScriptClone.Disabled = false
		ExplosionScriptClone.Parent = Firework
		wait(ReloadTime)
		if CurrentlyEquipped then
			Handle.Transparency = 0
		end
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
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
	if player ~= Player or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)