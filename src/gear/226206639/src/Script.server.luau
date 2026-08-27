--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

BaseSpring = BasePart:Clone()
BaseSpring.Name = "Spring"
BaseSpring.Size = Vector3.new(1, 3.25, 1.5)
SpringMesh = Instance.new("SpecialMesh")
SpringMesh.MeshType = Enum.MeshType.FileMesh
SpringMesh.MeshId = ""
SpringMesh.TextureId = (BaseUrl .. "223832174")
SpringMesh.Scale = Vector3.new(1.2, 1.05, 1)
SpringMesh.VertexColor = Vector3.new(1, 1, 1)
SpringMesh.Offset = Vector3.new(0, 0, 0)
SpringMesh.Parent = BaseSpring

Animations = {
	IdleMovement = {Animation = Tool:WaitForChild("IdleMovement"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Gravity = 196.20
JumpHeightPercentage = 0.25

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function SetGravityEffect()
	if not ToolEquipped then
		return
	end
	if not GravityEffect or not GravityEffect.Parent then
		GravityEffect = Instance.new("BodyForce")
		GravityEffect.Name = "GravityCoilEffect"
		GravityEffect.Parent = Torso
	end
	local TotalMass = 0
	local ConnectedParts = GetAllConnectedParts(Torso)
	for i, v in pairs(ConnectedParts) do
		if v:IsA("BasePart") then
			TotalMass = (TotalMass + v:GetMass())
		end
	end
	local TotalMass = (TotalMass * 196.20 * (1 - JumpHeightPercentage))
	GravityEffect.force = Vector3.new(0, TotalMass, 0)
end

function HandleGravityEffect(Enabled)
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyForce") then
			v:Destroy()
		end
	end
	for i, v in pairs({ToolUnequipped, DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	if Enabled and ToolEquipped then
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		SetGravityEffect()
		DescendantAdded = Character.DescendantAdded:connect(function()
			wait()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect()
		end)
		DescendantRemoving = Character.DescendantRemoving:connect(function()
			wait()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect()
		end)
	end
end

function ManageSprings(CreateSprings)
	
	if not CreateSprings then
		return
	end
	
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	
	if LeftLeg then
		LeftSpring = BaseSpring:Clone()
		LeftSpring.Name = "LeftSpring"
		LeftSpring.Mesh.MeshId = (BaseUrl .. "223832136")
		local LeftSpringWeld = Instance.new("Weld")
		LeftSpringWeld.Part0 = LeftLeg
		LeftSpringWeld.Part1 = LeftSpring
		LeftSpringWeld.C0 = CFrame.new()
		LeftSpringWeld.C1 = CFrame.new(0, 1.25, -0.05, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		LeftSpringWeld.Parent = LeftSpring
		LeftSpring.Parent = Tool
	end
	if RightLeg then
		RightSpring = BaseSpring:Clone()
		RightSpring.Name = "RightSpring"
		RightSpring.Mesh.MeshId = (BaseUrl .. "223832084")
		local RightSpringWeld = Instance.new("Weld")
		RightSpringWeld.Part0 = RightLeg
		RightSpringWeld.Part1 = RightSpring
		RightSpringWeld.C0 = CFrame.new()
		RightSpringWeld.C1 = CFrame.new(0, 1.25, -0.05, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		RightSpringWeld.Parent = RightSpring
		RightSpring.Parent = Tool
	end
	
	for i, v in pairs({LeftSpring, RightSpring}) do
		if v and v.Parent then
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
			end)
		end
	end
	
	Torso.CFrame = Torso.CFrame * CFrame.new(0, ((Torso.Size.Y / 2) + (BaseSpring.Size.Y / 2)), 0)
	
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.IdleMovement)
	end)
	Spawn(function()
		HumanoidDied = Humanoid.Died:connect(function()
			if GravityEffect and GravityEffect.Parent then
				GravityEffect:Destroy()
			end
		end)
		ManageSprings(true)
		HandleGravityEffect(true)
	end)
	Handle.Transparency = 1
end

function Unequipped()
	for i, v in pairs({LeftSpring, RightSpring, GravityEffect}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs({ToolUnequipped, DescendantAdded, DescendantRemoving, HumanoidDied}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
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

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)