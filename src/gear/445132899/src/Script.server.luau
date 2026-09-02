--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Woosh = Handle:WaitForChild("Woosh"),
	Whack = Handle:WaitForChild("Whack"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	LeftSwingFast = {Animation = Tool:WaitForChild("LeftSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	RightSwingFast = {Animation = Tool:WaitForChild("RightSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	OverheadSwing = {Animation = Tool:WaitForChild("OverheadSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
}

WhackNoise = 0
HitDelay = false
ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Handle.Transparency = 0
Tool.Enabled = true

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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function BreakApart(Part)
	
	local PossibleColors = {"Beige", "Cool yellow", "CGA brown", "Copper", "Smoky grey", "Earth green", "Really black", "Burgundy"}
	
	local Color = PossibleColors[math.random(1, #PossibleColors)]
	
	local BrokenPiece = BasePart:Clone()
	BrokenPiece.Name = "Effect"
	BrokenPiece.BrickColor = BrickColor.new(Color) --Part.BrickColor
	BrokenPiece.Material = Enum.Material.CorrodedMetal --Part.Material
	BrokenPiece.Transparency = Part.Transparency
	BrokenPiece.Reflectance = Part.Reflectance
	BrokenPiece.Friction = 0.3
	BrokenPiece.Elasticity = 0.5
	local Size = (math.random(1000, 1500) * 0.001)
	BrokenPiece.Size = Vector3.new(0.75, 0.75, 0.75)
	
	local TotalX = Clamp(math.floor(Part.Size.X / BrokenPiece.Size.X), 0, 5)
	local TotalY = Clamp(math.floor(Part.Size.Y / BrokenPiece.Size.Y), 0, 5)
	local TotalZ = Clamp(math.floor(Part.Size.Z / BrokenPiece.Size.Z), 0, 5)
	
	local Left = (-(Part.Size.X / 2) + (BrokenPiece.Size.X / 2))
	local Top = ((Part.Size.Y / 2) - (BrokenPiece.Size.Y / 2))
	local Back = (-(Part.Size.Z / 2) + (BrokenPiece.Size.Z / 2))
	
	local BrokenPieceModel = Create("Model"){
		Name = "BrokenPieceModel",
	}
	
	for X = 1, TotalX do
		for Y = 1, TotalY do
			for Z = 1, TotalZ do
				local XPos = (((Part.Size.X - (BrokenPiece.Size.X * TotalX)) / 2) + (Left + (BrokenPiece.Size.X * (X - 1))))
				local YPos = (((Part.Size.Y - (BrokenPiece.Size.Y * TotalY)) / 2) - (Top - (BrokenPiece.Size.Y * (Y - 1))))
				local ZPos = (((Part.Size.Z - (BrokenPiece.Size.Z * TotalZ)) / 2) + (Back + (BrokenPiece.Size.Z * (Z - 1))))
				local Piece = BrokenPiece:Clone()
				Piece.CFrame = (Part.CFrame * CFrame.new(XPos, YPos, ZPos))
				Create("SpecialMesh"){
					Name = "Mesh",
					MeshType = Enum.MeshType.Brick,
					Offset = Vector3.new(0, 0, 0),
					VertexColor = Vector3.new(1, 1, 1),
					Parent = Piece
				}
				local Color = Piece.BrickColor.Color
				local r = Color.r
				local g = Color.g
				local b = Color.b
				Piece.Parent = BrokenPieceModel
			end
		end
	end
	Part:Destroy()
	Debris:AddItem(BrokenPieceModel, 10)
	BrokenPieceModel.Parent = game:GetService("Workspace")
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end
function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or not Swinging or HitDelay then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Sit = true
	else
		if Hit.Name == "Effect" or Hit.Anchored then
			return
		end
		local HitParent = Hit.Parent
		if HitParent:IsA("Hat") or HitParent:IsA("Tool") then
			return
		end
		local Now = tick()
		if (Now - WhackNoise) > 0.5 then
			WhackNoise = Now
			Sounds.Whack:Play()
			local Mass = Hit:GetMass()
			if Mass > (1 ^ 3) and Mass < (3.75 ^ 3) then
				BreakApart(Hit)
			else
				for i = 1, math.random(1, 4) do
					local ParticlePart = BasePart:Clone()
					ParticlePart.Name = "Effect"
					ParticlePart.Material = Hit.Material
					ParticlePart.BrickColor = Hit.BrickColor
					ParticlePart.Transparency = Hit.Transparency
					ParticlePart.Reflectance = Hit.Reflectance
					ParticlePart.Size = Vector3.new(0.2, 0.2, 0.2)
					ParticlePart.CanCollide = false
					local HitDir = CFrame.new(Hit.Position, Handle.Position)
					ParticlePart.CFrame = (Handle.CFrame + HitDir.lookVector * (math.random(0, (Handle.Size.Z * 100)) * 0.01))-- * CFrame.new(math.random() * 2, math.random() * 2, math.random() * 2)))
					ParticlePart.Velocity = ((HitDir.lookVector * math.random(10, 30)) + Vector3.new(0, math.random(5, 25), 0))
					Debris:AddItem(ParticlePart, 5)
					ParticlePart.Parent = game:GetService("Workspace")
				end
			end
		end
	end
	HitDelay = true
	wait(0.2)
	HitDelay = false
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Swinging = true
	Sounds.Woosh:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.LeftSwingFast, Animations.RightSwingFast, Animations.OverheadSwing}
	Attack(AttackAnims)
	Swinging = false
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)