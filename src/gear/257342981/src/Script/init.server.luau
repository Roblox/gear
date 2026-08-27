--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

PonyModel = InsertService:LoadAsset(255278956)
Pony = PonyModel:GetChildren()[1]:Clone()
Debris:AddItem(PonyModel, 1)

AIScript = script:WaitForChild("AIScript")
Remover = script:WaitForChild("Remover")

BaseUrl = "http://www.roblox.com/asset/?id="

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Sounds = {
	Earthquake = Handle:WaitForChild("Earthquake"),
	Gallop = Handle:WaitForChild("Gallop"),
	Scream = Handle:WaitForChild("Scream"),
}

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

ReloadTime = 15

Rate = (1 / 60)

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
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

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value or not Tool.Enabled then
		return
	end
	if Mode == "SpawnStampede" then
		local ToolName = "TinyPonyStampede"
		local ModelName = (Player.Name .. "'s" .. ToolName)
		local PonyModel = game:GetService("Workspace"):FindFirstChild(ModelName)
		if PonyModel then
			return
		end
		local SpawnPoint = Value.SpawnPoint
		local Direction = Value.Direction
		local DistanceBetween = (Handle.Position - SpawnPoint).magnitude
		if not SpawnPoint or not Direction or DistanceBetween > 50 then
			return
		end
		local AreaBelow, AreaPos, AreaNormal = CastRay((CFrame.new(SpawnPoint) * CFrame.new(0, 2, 0)).p, Vector3.new(0, -1, 0), 6, {Character}, false)
		if not AreaBelow then
			return
		end
		Tool.Enabled = false
		PonyModel = Create("Model"){
			Name = ModelName,
		}
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
		}
		for i, v in pairs(Values) do
			local Value = Instance.new(v.Class)
			Value.Name = v.Name
			Value.Value = v.Value
			Value.Parent = PonyModel
		end
		for i, v in pairs({AIScript, Remover}) do
			local ScriptClone = v:Clone()
			ScriptClone.Disabled = false
			ScriptClone.Parent = PonyModel
		end
		local PonySize = Pony:GetModelSize()
		local TotalPonies = 12
		local Ponies = {}
		for x = 1, 2 do
			for z = 1, (TotalPonies / 2) do
				local PonyCopy = Pony:Clone()
				local PonyHumanoid = PonyCopy:FindFirstChild("Humanoid")
				local PonyTorso = PonyCopy:FindFirstChild("Torso")
				for i, v in pairs({Sounds.Scream, Sounds.Gallop, Sounds.Earthquake}) do
					local Sound = v:Clone()
					Sound.Parent = PonyTorso
				end
				local Values = {
					{Name = "Creator", Class = "ObjectValue", Value = Player},
					{Name = "Mode", Class = "StringValue", Value = "Follow"},
					{Name = "MaxDistance", Class = "NumberValue", Value = 300},
					{Name = "Follow", Class = "ObjectValue", Value = Player},
					{Name = "Offset", Class = "Vector3Value", Value = Vector3.new(-3, 0, -0.5)},
					{Name = "Target", Class = "ObjectValue", Value = nil},
					{Name = "TargetPos", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
					{Name = "Damage", Class = "NumberValue", Value = 15},
				}
				for i, v in pairs(Values) do
					local Value = Instance.new(v.Class)
					Value.Name = v.Name
					Value.Value = v.Value
					Value.Parent = PonyCopy
				end
				local PonyStart = (CFrame.new(AreaPos, (CFrame.new(AreaPos) + Direction.lookVector * 2).p) * CFrame.new((PonySize.X + 0.5) * ((x == 1 and -1) or 1), (PonySize.Y / 2), (-(PonySize.Z * (TotalPonies / 2)) + (((PonySize.Z / 2) + 2) * z))))
				local BodyGyro = Create("BodyGyro"){
					maxTorque = Vector3.new(math.huge, math.huge, math.huge),
					cframe = Direction,
					Parent = PonyTorso,
				}
				if PonyHumanoid and PonyHumanoid.Health > 0 and PonyTorso then
					PonyHumanoid.WalkSpeed = (16 * 4)
					PonyHumanoid.MaxHealth = 200
					PonyHumanoid.Health = PonyHumanoid.MaxHealth
					PonyTorso.CFrame = PonyStart
					PonyCopy.Parent = PonyModel
				end
				table.insert(Ponies, PonyCopy)
			end
		end
		for i, v in pairs(Ponies) do
			v.Mode.Value = "MoveTo"
			v.TargetPos.Value = (v.Torso.CFrame + v.Torso.CFrame.lookVector * 1e+5).p
		end
		Debris:AddItem(PonyModel, (60 / 2))
		PonyModel.Parent = game:GetService("Workspace")
		for i, v in pairs(Ponies) do
			local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso")
			if torso then
				for ii, vv in pairs(torso:GetChildren()) do
					if vv:IsA("Sound") then
						vv:Play()
					end
				end
			end
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end)

Tool:GetPropertyChangedSignal("Parent"):Connect(function()
	Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0))
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)