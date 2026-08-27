--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ShiverScript = script:WaitForChild("ShiverScript")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)

IceCube = BasePart:Clone()
IceCube.Name = "IceCube"
IceCube.BrickColor = BrickColor.new("Pastel light blue")
IceCube.TopSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.RightSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.BackSurface = Enum.SurfaceType.SmoothNoOutlines
IceCube.Material = Enum.Material.Ice
IceCube.Transparency = 0.25
IceCube.Reflectance = 0.5
IceCube.CanCollide = true
IceCube.Locked = true

DisplayIceCube = IceCube:Clone()
DisplayIceCube.CanCollide = false
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Brick
Mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
Mesh.Parent = DisplayIceCube

FriendlyFire = false --Set to true and it will not effect your teammates

Gravity = 196.20

ReloadTime = 5

Grips = {
	Normal = CFrame.new(0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0)
}

Animations = {
	Throw = {
		Animation = Tool:WaitForChild("Throw"),
		FadeTime = nil,
		Weight = nil,
		Speed = 0.75,
		Duration = 1,
		GripPoses = {
			{Delay = 0, Offset = CFrame.new(0, 0.4, -0.5, 0, 0.25, 0.967595875, 1, 0, 0, 0, 0.967595875, -0.25250414)},
			{Delay = 1.5, Offset = CFrame.new(0, 0.4, -0.5, 0, 0.25, 0.967595875, 1, 0, 0, 0, 0.967595875, -0.25250414)},
			{Delay = 0.1, Offset = CFrame.new(0, 0.4, -0.5, 0, 0.75, 0.967595875, 1, 0, 0, 0, 0.967595875, -0.25250414)},
			{Delay = 0.1, Offset = CFrame.new(0, 0.4, -0.5, 0, 1, 0.967595875, 1, 0, 0, 0, 0.967595875, -0.25250414)},
		},
		Functions = {
			{Delay = 2, Function = (function()
				ThrowIce(nil)
			end)}
		},
	},
	SelfThrow = {
		Animation = Tool:WaitForChild("SelfThrow"),
		FadeTime = nil,
		Weight = nil,
		Speed = 0.5,
		Duration = 1,
		GripPoses = {
			{Delay = 0, Offset = CFrame.new(0, 0.4, 1, -0.707106769, 0, 0.707106769, 0.707106769, 0, 0.707106769, 0, 1, 0)},
			{Delay = 1.25, Offset = CFrame.new(0, 0.4, 1, -0.241894811, -0.423094213, 0.873200059, 0.914493918, 0.201392844, 0.350915611, -0.324326575, 0.883420765, 0.338201225)},
			{Delay = 0.05, Offset = CFrame.new(0, 0.4, 1, -0.186186075, -0.682537436, 0.70673728, 0.904170096, 0.162443921, 0.395080298, -0.384462237, 0.712569118, 0.586885095)},
			{Delay = 0.05, Offset = CFrame.new(0, 0.4, 1, -0.145259723, -0.813898623, 0.562555432, 0.898794413, 0.129138589, 0.418917537, -0.413604081, 0.566473484, 0.712768853)},
			{Delay = 0.9, Offset = Grips.Normal}
		},
		Functions = {
			{Delay = 1.75, Function = (function()
				ThrowIce(Player)
			end)}
		},
	}
}

Sounds = {
	IceCollision = Handle:WaitForChild("IceCollision")
}

ToolActive = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Normal
Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function PositionPart(cframe, x, y, z)
	local PartCloneY = cframe
	PartCloneY = cframe * CFrame.Angles(-math.rad(90), 0, 0)
	PartCloneY = PartCloneY - PartCloneY.lookVector * y
	local PartCloneZ = PartCloneY + cframe.lookVector * z
	local PartCloneX = PartCloneZ * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX = PartCloneX - PartCloneX.lookVector * x
	return PartCloneX * CFrame.Angles((math.pi / 2), 0, (math.pi / 2))
end

function ThrowIce(player)
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local IceCubes = {}
	local IceCubeConnections = {}
	local HandleCFrame = Handle.CFrame
	for i = 1, math.random(25, 50) do
		local Ice = IceCube:Clone()
		Ice.CanCollide = false
		Delay(0.25, function()
			Ice.CanCollide = true
		end)
		local SpawnRadius = 2
		local SpawnOffset = (Vector3.new(math.random(-SpawnRadius, SpawnRadius), (0.25 + math.random(0, (SpawnRadius / 2))), math.random(-SpawnRadius, SpawnRadius)) * 0.1)
		local IceCFrame = PositionPart(HandleCFrame, SpawnOffset.X, ((Handle.Size.Y / 2) + (Ice.Size.Y / 2)), SpawnOffset.Z) * CFrame.Angles(0, math.pi, 0)
		Ice.CFrame = IceCFrame
		local IceVelocity = Ice.CFrame.lookVector * 25
		IceVelocity = IceVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		IceVelocity = (IceVelocity / 2)
		Ice.Velocity = IceVelocity
		table.insert(IceCubes, Ice)
		Debris:AddItem(Ice, 10)
		Ice.Parent = game:GetService("Workspace")
	end
	for i = 1, math.random(25, 40) do --Display ice cubes which don't collide with other bricks
		local Ice = DisplayIceCube:Clone()
		local SpawnRadius = 2
		local SpawnOffset = (Vector3.new(math.random(-SpawnRadius, SpawnRadius), (0.25 + math.random(0, (SpawnRadius / 2))), math.random(-SpawnRadius, SpawnRadius)) * 0.1)
		local IceCFrame = PositionPart(HandleCFrame, SpawnOffset.X, ((Handle.Size.Y / 2) + (Ice.Size.Y / 2)), SpawnOffset.Z) * CFrame.Angles(0, math.pi, 0)
		Ice.CFrame = IceCFrame
		local IceVelocity = Ice.CFrame.lookVector * 25
		IceVelocity = IceVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		Ice.Velocity = IceVelocity
		table.insert(IceCubes, Ice)
		Debris:AddItem(Ice, 3)
		Ice.Parent = game:GetService("Workspace")
	end
	local PlayersHit = {}
	for i, v in pairs(IceCubes) do
		local IceCubeConnection
		IceCubeConnection = v.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or Hit.Name == "IceCube" then
				return
			end
			local character = Hit.Parent
			if not character then
				return
			end
			local PlayerHit = Players:GetPlayerFromCharacter(character)
			if Player ~= PlayerHit and IsTeamMate(Player, PlayerHit) and FriendlyFire then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local BodyVelocity = v:FindFirstChild("BodyVelocity")
			if BodyVelocity then
				BodyVelocity:Destroy()
			end
			if PlayerHit and ((player and player == Player and PlayerHit == Player) or (not player and PlayerHit ~= Player)) then
				local ForceField = false
				for i, v in pairs(character:GetChildren()) do
					if v:IsA("ForceField") then
						ForceField = true
					end
				end
				if ForceField then
					return
				end
				local PlayerInTable = PlayersHit[PlayerHit]
				if not PlayerInTable then
					PlayersHit[PlayerHit] = {}
					if not CheckTable(PlayersHit[PlayerHit], v) then
						table.insert(PlayersHit[PlayerHit], v)
					end
				end
			end
		end)
	end
	Sounds.IceCollision.Pitch = (math.random(500, 650) * 0.01)
	Sounds.IceCollision:Play()
	Delay(0.4, function()
		for i, v in pairs(IceCubeConnections) do
			if v then
				v:disconnect()
			end
		end
		table.sort(PlayersHit, (function(Player1, Player2)
			return Player1 > Player2
		end))
		local PlayerHitMost
		for i, v in pairs(PlayersHit) do
			PlayerHitMost = i
			break
		end
		if PlayerHitMost and PlayerHitMost.Parent then
			if PlayerHitMost == Player and Torso and Torso.Parent then
				Torso.Velocity = Vector3.new(0, 0, 0)
			end
			local character = PlayerHitMost.Character
			if character and not character:FindFirstChild(ShiverScript.Name) then
				local ShiverScriptClone = ShiverScript:Clone()
				ShiverScriptClone.Disabled = false
				ShiverScriptClone.Parent = character
			end
		end
	end)
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated(Animation)
	if not Tool.Enabled or ToolActive or not CheckIfAlive() or Character:FindFirstChild(ShiverScript.Name) then
		return
	end
	ToolActive = true
	local CurrentlyEquipped = true
	local ToolUnequipped
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local DelayTime = {
		GripPoses = 0,
		Functions = 0
	}
	InvokeClient("PlayAnimation", Animation)
	for i, v in pairs(Animation.GripPoses) do
		DelayTime.GripPoses = (DelayTime.GripPoses + v.Delay)
	end
	for i, v in pairs(Animation.Functions) do
		DelayTime.Functions = (DelayTime.Functions + v.Delay)
	end
	Spawn(function()
		for i, v in pairs(Animation.GripPoses) do
			wait(v.Delay)
			if not CurrentlyEquipped then
				break
			end
			Tool.Grip = v.Offset
			if not CurrentlyEquipped then
				break
			end
		end
	end)
	Spawn(function()
		for i, v in pairs(Animation.Functions) do
			wait(v.Delay)
			if not CurrentlyEquipped then
				break
			end
			pcall(function()
				v.Function()
			end)
			if not CurrentlyEquipped then
				break
			end
		end
	end)
	wait((DelayTime.GripPoses > DelayTime.Functions and DelayTime.GripPoses) or DelayTime.Functions)
	if not CurrentlyEquipped then
		return
	end
	wait(Animation.Duration)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Tool.Grip = Grips.Normal
	ToolActive = false
end

function Equipped(Mouse)
	Tool.Grip = Grips.Normal
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightArm = Character:FindFirstChild("Right Arm")
		for i, v in pairs({LeftArm, RightArm}) do
			if v then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Normal
	ToolActive = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	if mode == "MouseClick" then
		local Down = value.Down
		if Down then
			Activated(Animations.Throw)
		end
	elseif mode == "KeyPress" then
		local Down = value.Down
		local Key = value.Key
		local ByteKey = string.byte(Key)
		if Key == "q" and Down then
			Activated(Animations.SelfThrow)
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)