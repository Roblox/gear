--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

HitScript = script:WaitForChild("HitScript")

Sounds = {
	Flying = Handle:WaitForChild("Flying"),
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function Activated()
	
	if not Tool.Enabled then
		return
	end
	
	Tool.Enabled = false
	
	local MouseData = InvokeClient("MouseData")
	
	if not MouseData or not MouseData.Position or not CheckIfAlive() then
		Tool.Enabled = true
		return
	end
	
	local Pos = MouseData.Position
	
	local Hat = Handle:clone()
	Hat.Name = "Fedora"
	Hat.Mesh.MeshId = (BaseUrl .. "549633780")
	Hat.CanCollide = true
	Hat.Transparency = 0
	Hat.Friction = 0
	local Vec = (Pos - Handle.Position).Unit
	Hat.CFrame = (CFrame.new(Handle.Position, Pos) * CFrame.new(0, 0, -6))
	Hat.Velocity = (Vec * 74)
	Hat.RotVelocity = Vector3.new(0, 30, 0)
	
	local FlyingSound = Sounds.Flying:Clone()
	FlyingSound.Parent = Hat

	local Creator = Instance.new("ObjectValue")
	Creator.Name = "creator"
	Creator.Value = Player
	Creator.Parent = Hat

	local BF = Instance.new("BodyForce")
	BF.force = Vector3.new(0, (Hat:GetMass() * 196.20), 0)
	BF.Parent = Hat
	
	local BG = Instance.new("BodyGyro")
	BG.Parent = Hat
	
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = 15},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = Hat
	end
	local HitScriptCopy = HitScript:Clone()
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = Hat
	
	Debris:AddItem(Hat, 5)
	
	Hat.Parent = game:GetService("Workspace")
	
	wait(5)
	
	Tool.Enabled = true
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value or not CheckIfAlive() or not ToolEquipped then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Changed:connect(function(Property)
	Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
end)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)