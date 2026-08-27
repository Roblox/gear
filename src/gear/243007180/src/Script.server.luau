--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Light = Handle:WaitForChild("Light")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

CastLaser = Tool:WaitForChild("CastLaser"):Clone()

Modules = Tool:WaitForChild("Modules")
Functions = require(Modules:WaitForChild("Functions"))
BaseUrl = "http://www.roblox.com/asset/?id="

ConfigurationBin = Tool:WaitForChild("Configuration")
Configuration = {}
Configuration = Functions.CreateConfiguration(ConfigurationBin, Configuration)

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseRay = BasePart:Clone()
BaseRay.Name = "Ray"
BaseRay.BrickColor = BrickColor.new("New Yeller")
BaseRay.Material = Enum.Material.SmoothPlastic
BaseRay.Size = Vector3.new(0.2, 0.2, 0.2)
BaseRay.Anchored = true
BaseRay.CanCollide = false
BaseRayMesh = Instance.new("SpecialMesh")
BaseRayMesh.Name = "Mesh"
BaseRayMesh.MeshType = Enum.MeshType.Brick
BaseRayMesh.Scale = Vector3.new(0.2, 0.2, 1)
BaseRayMesh.Offset = Vector3.new(0, 0, 0)
BaseRayMesh.VertexColor = Vector3.new(1, 1, 1)
BaseRayMesh.Parent = BaseRay

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Light.Enabled = false
Tool.Enabled = true

function RayTouched(Hit, Position)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	local DeterminedDamage = math.random(Configuration.Damage.MinValue, Configuration.Damage.MaxValue)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DeterminedDamage)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Fire" then
		Sounds.Fire:Play()
	elseif Mode == "RayHit" then
		local RayHit = Value.Hit
		local RayPosition = Value.Position
		if RayHit and RayPosition then
			RayTouched(RayHit, RayPosition)
		end
		Light.Color = BaseRay.BrickColor.Color
		if not Light.Enabled then
			Light.Enabled = true
			Delay(0.1, function()
				Light.Enabled = false
			end)
		end
	elseif Mode == "CastLaser" then
		local StartPosition = Value.StartPosition
		local TargetPosition = Value.TargetPosition
		local RayHit = Value.RayHit
		if not StartPosition or not TargetPosition or not RayHit then
			return
		end
		for i, v in pairs(Players:GetPlayers()) do
			if v:IsA("Player") and v ~= Player then
				local Backpack = v:FindFirstChild("Backpack")
				if Backpack then
					local LaserScript = CastLaser:Clone()
					local StartPos = Instance.new("Vector3Value")
					StartPos.Name = "StartPosition"
					StartPos.Value = StartPosition
					StartPos.Parent = LaserScript
					local TargetPos = Instance.new("Vector3Value")
					TargetPos.Name = "TargetPosition"
					TargetPos.Value = TargetPosition
					TargetPos.Parent = LaserScript
					local RayHit = Instance.new("BoolValue")
					RayHit.Name = "RayHit"
					RayHit.Value = RayHit
					RayHit.Parent = LaserScript
					LaserScript.Disabled = false
					Debris:AddItem(LaserScript, 1.5)
					LaserScript.Parent = Backpack
				end
			end
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)