--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))
Remover = script:WaitForChild("Remover")

Damage = 5
MaxEnemyDistance = 100

Boundaries = {
	Target = Ray.new(Vector3.new(-10, -3, -10), Vector3.new(10, 7, 10)),
	Follow = Ray.new(Vector3.new(-10, 14, -10), Vector3.new(10, 18, 10)),
}

Gravity = 196.20

Seagulls = {}

SeagullTarget = nil
SeagullBoundaries = nil

BaseSeagull = Handle:Clone()
BaseSeagull.Name = "Seagull"
BaseSeagull.Transparency = 0
BaseSeagull.Size = Vector3.new(2.75, 0.25, 0.5625)
BaseSeagull.Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
BaseSeagull.CanCollide = false

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

function SetTarget(Object)
	if not Object or not Object.Parent then
		return
	end
	if TargetRemoved then
		TargetRemoved:disconnect()
	end
	TargetRemoved = Object.Changed:connect(function(Property)
		if Property == "Parent" and not Object.Parent then
			SetTarget(((Head and Head.Parent) and Head) or nil)
		end
	end)
	SeagullTarget = Object
	SeagullBoundaries = ((SeagullTarget == Head and Boundaries.Follow) or Boundaries.Target)
end

function CreateSeagulls()
	for i = 1, 8 do
		local Seagull = BaseSeagull:Clone()
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.Parent = Seagull
		local Mass = (Seagull:GetMass() * Gravity * 1.25)
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.D = 10000
		BodyPosition.P = 20000
		BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyPosition.Parent = Seagull
		Seagull.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or not ToolEquipped or not CheckIfAlive() then
				return
			end
			local character = Hit.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			if character ~= SeagullTarget.Parent then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and (player == Player or Functions.IsTeamMate(Player, player)) then
				return
			end
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)
		end)
		table.insert(Seagulls, {Seagull = Seagull, BodyGyro = BodyGyro, BodyPosition = BodyPosition, Origin = {CFrame = nil, Nearby = false, Traveling = false}, TargetPoint = nil})
	end
end

function PlaceSeagulls()
	if SeagullModel and SeagullModel.Parent then
		SeagullModel:Destroy()
	end
	SeagullModel = Instance.new("Model")
	SeagullModel.Name = Player.Name .. "'s Seagulls"
	local RemoverClone = Remover:Clone()
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = RemoverClone
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = RemoverClone
	RemoverClone.Disabled = false
	RemoverClone.Parent = SeagullModel
	for i, v in pairs(Seagulls) do
		if v.Seagull and v.BodyGyro and v.BodyPosition then
			PositionSeagulls(SeagullTarget)
			v.Seagull.Transparency = 0
			v.Seagull.Parent = SeagullModel
		end
	end
	SeagullModel.Parent = game:GetService("Workspace")
	for i, v in pairs(Seagulls) do
		v.Seagull.CFrame = v.Origin.CFrame --Enables Seagulls to appear flying around already when you equip this tool
		v.Seagull.Anchored = false
	end
	SeagullsReady = false
	SeagullsReady = true
end

function PositionSeagulls(Origin)
	for i, v in pairs(Seagulls) do
		if (not v.Origin.Nearby and not v.Traveling) or not v.Origin.CFrame then
			v.Origin.Traveling = true
			local TargetPoint = (Origin.CFrame * CFrame.new(math.random(SeagullBoundaries.Origin.X, SeagullBoundaries.Direction.X), math.random(SeagullBoundaries.Origin.Y, SeagullBoundaries.Direction.Y), math.random(SeagullBoundaries.Origin.Z, SeagullBoundaries.Direction.Z)) * CFrame.Angles(math.random(-math.pi, math.pi), math.random(-math.pi, math.pi), math.random(-math.pi, math.pi)))
			TargetPoint = TargetPoint * CFrame.Angles(((Functions.IsFlipped(TargetPoint) and math.pi) or 0), 0, 0)
			v.Origin.CFrame = TargetPoint
			v.BodyGyro.cframe = CFrame.new(v.Seagull.Position, TargetPoint.p)
			v.BodyPosition.position = (v.Seagull.Position + (CFrame.new(v.Seagull.Position, TargetPoint.p).lookVector * ((SeagullTarget ~= Head and 25) or 15)))
			if v.Origin.CFrame and (v.Seagull.Position - v.Origin.CFrame.p).magnitude <= 6 then
				v.Traveling = false
				v.Origin.Nearby = true
			end
		else
			v.Origin.Nearby = false
		end
	end
end

function FunctionSeagulls()
	while SeagullModel and SeagullModel.Parent do
		if not SeagullTarget then
			SetTarget(Head)
		elseif SeagullTarget ~= Head then
			local character = SeagullTarget.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local Distance = (Head.Position - SeagullTarget.Position).magnitude
			if not humanoid or humanoid.Health == 0 or Distance > MaxEnemyDistance then
				SetTarget(Head)
			end
		end
		PositionSeagulls(SeagullTarget)
		wait(0.25)
	end
end

function SetUpSeagulls()
	Spawn(function()
		if SeagullModel and SeagullModel.Parent then
			SeagullModel:Destroy()
		end
		for i, v in pairs(Seagulls) do
			if v.Seagull and v.Seagull.Parent then
				v.Seagull:Destroy()
			end
		end
		Seagulls = {}
		SetTarget(Head)
		CreateSeagulls()
		PlaceSeagulls()
		FunctionSeagulls()
	end)
end

function CheckIfAlive(Current)
	return (((Character and Character.Parent and Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Handle.Transparency = 1
	Spawn(SetUpSeagulls)
end

function Unequipped()
	if SeagullModel and SeagullModel.Parent then
		SeagullModel:Destroy()
	end
	Seagulls = {}
	SeagullTarget = nil
	SeagullBoundaries = nil
	SeagullsReady = false
	Handle.Transparency = 0
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not SeagullsReady or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		local Target = Value.Target
		if Down then
			if not Target or not Target.Parent then return end
			local character = Target.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				character = character.Parent
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and (player == Player or Functions.IsTeamMate(Player, player)) then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local head = character:FindFirstChild("Head")
			if humanoid and humanoid.Health > 0 and head and (head.Position - Head.Position).magnitude <= MaxEnemyDistance then
				SetTarget(head)
			else
				SetTarget(Head)
			end
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)