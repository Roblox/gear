--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Gravity = 196.2

Floating = false

ConnectedParts = {}
Connections = {}

Animations = { --Animations by Stickmasterluke
	Hold = {Animation = Tool:WaitForChild("Hold"), Speed = 1},
	Float1 = {Animation = Tool:WaitForChild("Float1"), Speed = 1},
	Float2 = {Animation = Tool:WaitForChild("Float2"), Speed = 0.85}
}

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Grips = {
	Equipped = CFrame.new(-0.4, -0.5, -0.25, 1, 0, 0, 0, 0, -1, 0, 1, 0),
	Unequipped = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Tool.Enabled = true
Tool.Grip = Grips.Unequipped

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("BodyForce") then
		v:Destroy()
	end
end

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetAllPartsConnected(BasePart)
	local PartsConnected = {}
	local function GetPartsConnected(BasePart)
		local ConnectedParts = BasePart:GetConnectedParts()
		if #ConnectedParts > 0 then
			if not CheckTable(PartsConnected, BasePart) then
				table.insert(PartsConnected, BasePart)
				for i, v in pairs(ConnectedParts) do
					GetPartsConnected(v)
				end
			end
		end
	end
	GetPartsConnected(BasePart)
	return PartsConnected
end

function ManageConnectedParts()
	for i, v in pairs(Connections) do
		if v then
			v:disconnect()
		end
	end
	Connections = {}
	ConnectedParts = GetAllPartsConnected(Character.PrimaryPart)
	for i, v in pairs(ConnectedParts) do
		local ChildAdded = v.ChildAdded:connect(function(Child)
			if Child == Handle then
				return
			end
			ManageConnectedParts()
		end)
		local ChildRemoved = v.ChildRemoved:connect(function()
			if Child == Handle then
				return
			end
			ManageConnectedParts()
		end)
		table.insert(Connections, ChildAdded)
		table.insert(Connections, ChildRemoved)
	end
	ManageForce(ConnectedParts)
end

function ManageForce(Parts)
	if BodyForce and BodyForce.Parent then
		BodyForce.force = Vector3.new(0, (GetTotalMass(Parts) * 1.05), 0)
	end
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(((type(Parent) == "table" and Parent) or Parent:GetChildren())) do
			if v:IsA("BasePart") then
				Mass = (Mass + (v:GetMass() * Gravity))
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function FreeFall(Falling)
	if not Equipped then
		return
	end
	if Falling then
		InvokeClient("PlayAnimation", Animations.Float2)
	else
		InvokeClient("PlayAnimation", Animations.Hold)
	end
end

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Tool.Grip = Grips.Equipped
	InvokeClient("PlayAnimation", Animations.Hold)
	BodyForce = Instance.new("BodyForce")
	BodyForce.force = Vector3.new(0, 0, 0)
	BodyForce.Parent = Handle
	ManageConnectedParts()
	local HumanoidState = Humanoid:GetState()
	if HumanoidState == Enum.HumanoidStateType.Freefall then
		FreeFall(true)
	end
	if Equipped then
		HumanoidFalling = Humanoid.FreeFalling:connect(function(Falling)
			FreeFall(Falling)
		end)
	end
end

function Unequipped()
	Equipped = false
	Tool.Grip = Grips.Unequipped
	InvokeClient(nil, "StopAnimation", nil)
	if BodyForce and BodyForce.Parent then
		BodyForce:Destroy()
	end
	if HumanoidFalling then
		HumanoidFalling:disconnect()
	end
end

Tool.Unequipped:connect(Unequipped)
Tool.Equipped:connect(Equipped)