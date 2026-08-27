--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

HitScript = script:WaitForChild("HitScript")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

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

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = nil, Weight = nil, Speed = .5, Duration = .5}
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

NinjaStars = {
	Meshes = {187687161, 187687175, 187687193},
	Textures = {187687219}
}

FireRate = 0.5
Power = 100

Gravity = 196.20

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if Key == "x" and Down then
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function RandomizeStar()
	Mesh.MeshId = "http://www.roblox.com/asset?id=" .. NinjaStars.Meshes[math.random(1, #NinjaStars.Meshes)]
	Mesh.TextureId = "http://www.roblox.com/asset?id=" .. NinjaStars.Textures[math.random(1, #NinjaStars.Textures)]
end

function ThrowStar(Destination)
	if not Destination then
		return
	end
	local Star = BasePart:Clone()
	Star.Name = "Effect"
	Star.Size = Handle.Size
	Star.CanCollide = true
	local Smoke = Instance.new("Smoke")
	Smoke.Color = Color3.new((255 / 255), (255 / 255), (255 / 255))
	Smoke.Opacity = 0.125
	Smoke.RiseVelocity = 0.05
	Smoke.Size = 0.1
	Smoke.Enabled = true
	Smoke.Parent = Star
	local Fire = Instance.new("Fire")
	Fire.Color = Color3.new((0 / 255), (255 / 255), (255 / 255))
	Fire.SecondaryColor = Color3.new((0 / 255), (0 / 255), (255 / 255))
	Fire.Heat = 2
	Fire.Size = 2
	Fire.Enabled = true
	Fire.Parent = Star
	local StarMesh = Instance.new("SpecialMesh")
	StarMesh.MeshType = Enum.MeshType.FileMesh
	StarMesh.MeshId = Mesh.MeshId
	StarMesh.TextureId = Mesh.TextureId
	StarMesh.Scale = Mesh.Scale
	StarMesh.VertexColor = Mesh.VertexColor
	StarMesh.Parent = Star
	local Mass = (Star:GetMass() * Gravity)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.Parent = Star
	local Snowflake = Instance.new("StringValue")
	Snowflake.Name = "Snowflake"
	Snowflake.Parent = Star
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = Star
	local HitSound = Sounds.Hit:Clone()
	HitSound.Parent = Star
	local HitScriptClone = HitScript:Clone()
	HitScriptClone.Disabled = false
	HitScriptClone.Parent = Star
	Debris:AddItem(Star, 15)
	Star.Parent = game:GetService("Workspace")
	Star.CFrame = Handle.CFrame
	local Direction = CFrame.new(Star.Position, Destination)
	local Velocity = (Direction.lookVector  * Power)
	Star.Velocity = Velocity
	BodyVelocity.velocity = Velocity
	Star.CFrame = Direction * CFrame.Angles((math.pi / 2), 0, (math.pi / 2))
	Star.CFrame = Star.CFrame * CFrame.Angles(0, (math.pi / 2), 0)
end

function Activated()
	if Tool.Enabled and CheckIfAlive() and ToolEquipped then
		Tool.Enabled = false
		local Animation = Animations.Throw
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Throw
		end
		InvokeClient("PlayAnimation", Animation)
		Sounds.Fire:Play()
		local MousePosition = InvokeClient("MousePosition")
		ThrowStar(MousePosition)
		Handle.Transparency = 1
		wait(FireRate)
		RandomizeStar()
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
	for i ,v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

RandomizeStar()

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)