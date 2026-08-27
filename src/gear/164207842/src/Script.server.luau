--Rescripted by Luckymaxer
--[[ alexnewtron 2014 ]]--

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Animations = {
	Slash2 = {Animation = Tool:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = nil},
	Slash3 = {Animation = Tool:WaitForChild("Slash3"), FadeTime = nil, Weight = nil, Speed = nil},
	Slash4 = {Animation = Tool:WaitForChild("Slash4"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	Hit = Handle:WaitForChild("Hit"),
	Swing = Handle:WaitForChild("Swing")
}

Pieces = {}

Force = 0.01
Spacing = 0.55
Push = -1000

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function ConstructNoodle()
	local PieceCount = 11
	for i = 1, PieceCount do
		local Piece = BasePart:Clone()
		Piece.Name = ("Piece" .. i)
		Piece.Size = Vector3.new(0.51, 0.57, 0.63)
		Piece.CanCollide = false
		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = "http://www.roblox.com/asset/?id=163291701"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=162383840"
		Mesh.Parent = Piece
		local Weld = Instance.new("Weld")
		Weld.Part0 = ((i == 1 and Handle) or Pieces[#Pieces].Piece)
		Weld.Part1 = Piece
		Weld.C0 = CFrame.new(0, 0, (Spacing - ((i == 1 and (Handle.Size.Z / 2)) or 0))) * CFrame.Angles(Force, 0, 0)
		Weld.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		Weld.Parent = Piece
		Piece.Touched:connect(Touched)
		Piece.Parent = Handle
		Spawn(function()
			InvokeClient("SetLocalTransparencyModifier", {Object = Piece, Transparency = 0, AutoUpdate = true})
		end)
		table.insert(Pieces, {Piece = Piece, Weld = Weld})
	end
	Wiggle(false)
end

function Wiggle(Delay)
	for i, v in pairs(Pieces) do
		if v and v.Piece.Parent and v.Weld.Parent then
			v.Weld.C0 = CFrame.new(0, 0, (Spacing - ((i == 1 and (Handle.Size.Z / 2)) or 0))) * CFrame.Angles(Force, 0, 0)
		else
			break
		end
		if Delay then
			wait()
		end
	end
end

function Touched(Hit)
	if not Hit or not Hit.Parent or Force <= 0.01 then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (not player.Neutral and player.TeamColor == Player.TeamColor) then
		return
	end
	if character:FindFirstChild("HitDebounce") then
		return
	end
	local Pos = Handle.Position
	local Distance = Vector3.new((Pos.X - torso.Position.X), (Pos.Y - torso.Position.Y), (Pos.Z - torso.Position.Z))
	local BodyForce = Instance.new("BodyForce")
	BodyForce.force = (Distance.unit * torso:GetMass() * Push)
	Debris:AddItem(BodyForce, 0.5)
	BodyForce.Parent = torso
	humanoid.Sit = true
	Sounds.Hit:Play()
	local Debounce = Instance.new("BoolValue")
	Debounce.Name = "HitDebounce"
	Debris:AddItem(Debounce, 3)
	Debounce.Parent = character
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local SwingAnimations = {Animations.Slash2, Animations.Slash3, Animations.Slash4}
	local SwingChosen = math.random(1, #SwingAnimations)
	InvokeClient("PlayAnimation", SwingAnimations[SwingChosen])
	Sounds.Swing:Play()
	if SwingChosen == 1 or SwingChosen == 2 then
		Force = 0.15
	elseif SwingChosen == 3 then
		Force = -0.2
	end
	Wiggle(true)
	wait(0.5)
	Force = 0.01
	Wiggle(true)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	ConstructNoodle()
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Pieces) do
		if v and v.Piece then
			v.Piece:Destroy()
		end
	end
	Pieces = {}
	Mesh.MeshId = "http://www.roblox.com/asset/?id=162383812"
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("BasePart") then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)