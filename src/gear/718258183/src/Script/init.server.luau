--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

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

Anims = Tool:WaitForChild("Animations")
R6Anims = Anims:WaitForChild("R6")
R15Anims = Anims:WaitForChild("R15")
Animations = {
	R6 = {
		Swing = {Animation = R6Anims:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	},
	R15 = {
		Swing = {Animation = R15Anims:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	}
}

Particles = Tool:WaitForChild("Particles")

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

HitScript = script:WaitForChild("HitScript")

TennisBall = BasePart:Clone()
TennisBall.Name = "TennisBall"
TennisBall.Size = Vector3.new(0.5, 0.5, 0.5)
TennisBallMesh = Instance.new("SpecialMesh")
TennisBallMesh.MeshType = Enum.MeshType.FileMesh
TennisBallMesh.MeshId = (BaseUrl .. "717279425")
TennisBallMesh.TextureId = (BaseUrl .. "717279859")
TennisBallMesh.Scale = Vector3.new(2.5, 2.5, 2.5)
TennisBallMesh.VertexColor = Vector3.new(1, 1, 1)
TennisBallMesh.Offset = Vector3.new(0, 0, 0)
TennisBallMesh.Parent = TennisBall
HitSound = Sounds.Hit:Clone()
HitSound.Parent = TennisBall

ToolEquipped = false

Remotes = (Tool:FindFirstChild("Remotes") or Instance.new("Folder"))
Remotes.Name = "Remotes"
Remotes.Parent = Tool

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	local MousePos = MouseData.Position
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local SwingAnims = {Animations.R6.Swing}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		SwingAnims = {Animations.R15.Swing}
	end
	local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
	SlashSounds[math.random(1, #SlashSounds)]:Play()
	CurrentAnimation = SwingAnims[math.random(1, #SwingAnims)]
	Spawn(function()
		InvokeClient("PlayAnimation", CurrentAnimation)
	end)
	wait(CurrentAnimation.Duration / 4)
	if not CurrentlyEquipped then
		return
	end
	local SpawnOffset = CFrame.new(-((Handle.Size.X / 2) + (TennisBall.Size.Z / 2)), ((Handle.Size.Y / 4) * -0.5), 0)
	local SpawnPos = (Handle.CFrame * SpawnOffset)
	local HitDirection = CFrame.new(SpawnPos.p, MousePos).lookVector
	local TennisBallCopy = TennisBall:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = math.random(17, 26)},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = TennisBallCopy
	end
	--[[local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Transparency = 1
	EffectPart.Size = Vector3.new(0.2, 1, 1)
	EffectPart.CanCollide = false
	local Weld = Instance.new("Weld")
	Weld.Part0 = Handle
	Weld.Part1 = EffectPart
	Weld.C0 = SpawnOffset
	Weld.C1 = CFrame.new(0, 0, 0)
	Weld.Parent = EffectPart
	EffectPart.CFrame = SpawnPos]]
	local Fire = {}
	for i, v in pairs(Particles:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			for ii, vv in pairs({TennisBallCopy}) do
				local Particle = v:Clone()
				Particle.Enabled = true
				table.insert(Fire, Particle)
				Particle.Parent = vv
			end
		end
	end
	Delay(0.1, (function()
		for i, v in pairs(Fire) do
			v.Enabled = false
		end
	end))
	--Debris:AddItem(EffectPart, 0.7)
	local HitScriptCopy = HitScript:Clone()
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = TennisBallCopy
	TennisBallCopy.CFrame = (SpawnPos + HitDirection * 0.75)
	local Force = math.random(150, 250)
	TennisBallCopy.Velocity = (HitDirection * Force)
	Debris:AddItem(TennisBallCopy, 2)
	TennisBallCopy.Parent = game:GetService("Workspace")
	wait((CurrentAnimation.Duration / 4) * 3)
	CurrentAnimation = nil
	wait(0.5)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)