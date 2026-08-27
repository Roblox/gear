--Made by Luckymaxer

local PackageLib = require(836581200)

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

GuiHandler = script:WaitForChild("GuiHandler")

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

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Size = Vector3.new(1.3, 0.5, 0.2)
BaseProjectile.CanCollide = false
BowTieMesh = Instance.new("SpecialMesh")
BowTieMesh.MeshType = Enum.MeshType.FileMesh
BowTieMesh.MeshId = "http://www.roblox.com/asset/?id=191294895"
BowTieMesh.TextureId = "http://www.roblox.com/asset/?id=191269030"
BowTieMesh.Scale = Vector3.new(2, 2, 2)
BowTieMesh.VertexColor = Vector3.new(1, 1, 1)
BowTieMesh.Parent = BaseProjectile

BowTie = Instance.new("Accessory")
BowTie.Name = "BlackBowTie"
BowTie.AttachmentPoint = CFrame.new(0, 1.4, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
BowTieHandle = BaseProjectile:Clone()
BowTieHandle.Name = "Handle"
BowTieHandle.CanCollide = true
BowTieHandle.Parent = BowTie

Outfits = {
	Assets = {191344083},
	Suits = {
		{
			Name = "The Londoner",
			Image = "http://www.roblox.com/asset/?id=191387352",
			Assets = {124909182, 124909333, 124909400, 124909450, 124909574, 124909603}
		},
		{
			Name = "The Crook",
			Image = "http://www.roblox.com/asset/?id=191387330",
			Assets = {116791307, 116791347, 116791368, 116791410, 116791445, 116791503}
		},
		{
			Name = "Chicago News Man",
			Image = "http://www.roblox.com/asset/?id=191387286",
			Assets = {122329350, 122329449, 122329493, 122329521, 122329554, 122329611}
		},
		{
			Name = "Basic Black Tuxedo",
			Image = "http://www.roblox.com/asset/?id=191387263",
			Assets = {14463095, 12786197, 12786204, 27112025, 27112039, 27112052, 27112056, 27112068}
		},
		{
			Name = "Basic White Tuxedo",
			Image = "http://www.roblox.com/asset/?id=191387408",
			Assets = {186956940, 188258102, 188409259, 27112025, 27112039, 27112052, 27112056, 27112068}
		}
	}
}

CurrentIndex = 1

MaxFramesDisplayed = 3
MainFrameSize = UDim2.new(0, 200, 0, 300)
FrameSize = (MainFrameSize.Y.Offset / MaxFramesDisplayed)
OutfitGui = Instance.new("ScreenGui")
OutfitGui.Name = "OutfitGui"
ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.BackgroundColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
ScrollingFrame.BorderColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
ScrollingFrame.BorderSizePixel = 2
ScrollingFrame.BackgroundTransparency = 0.35
ScrollingFrame.Size = MainFrameSize
ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
ScrollingFrame.Position = UDim2.new(0, 25, 0, 25, 0)
ScrollingFrame.ZIndex = 1
ScrollingFrame.Parent = OutfitGui
for i, v in pairs(Outfits.Suits) do
	local ImageButton = Instance.new("ImageButton")
	ImageButton.Name = v.Name
	ImageButton.Image = v.Image
	ImageButton.BackgroundColor3 = Color3.new((75 / 255), (75 / 255), (75 / 255))
	ImageButton.BorderColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
	ImageButton.BackgroundTransparency = 0.75
	ImageButton.ImageColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255))
	ImageButton.Size = UDim2.new(1, 0, 0, FrameSize)
	ImageButton.Position = UDim2.new(0, 0, 0, (FrameSize * (i - 1)))
	ImageButton.ZIndex = 2
	local Index = Instance.new("IntValue")
	Index.Name = "Index"
	Index.Value = i
	Index.Parent = ImageButton
	if i == #Outfits.Suits then
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (ImageButton.Position.Y.Offset + ImageButton.Size.Y.Offset))
	end
	ImageButton.Parent = ScrollingFrame
end

Grips = {
	Equipped = CFrame.new(0.15, -0.2, 0, 0.968230426, 0, 0.250059545, 0, 1, -0, -0.250059515, 0, 0.968230546),
	Unequipped = CFrame.new(0.15, -0.2, 0, 0.99999994, 0, 0, 0, 1, 0, 0, 0, 1)
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

Gravity = workspace.Gravity

ReloadTime = 5

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
		elseif Mode == "SetIndex" and Value then
			CurrentIndex = ((Value.Index > #Outfits.Suits and #Outfits.Suits) or (Value.Index < 0 and 1) or Value.Index)
		elseif Mode == "GetIndex" then
			return {Index = CurrentIndex}
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

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = (AssetModel:FindFirstChild("R15") and AssetModel:FindFirstChild("R6") and AssetModel:Clone()) or AssetModel:GetChildren()[1]:Clone()
	if AssetModel and AssetModel.Parent then
		AssetModel:Destroy()
	end
	return Asset
end

function GetSpecifiedClasses(Parent, Classes)
	local Instances = {}
	local function GetClasses(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			local ClassFound = false
			for ii, vv in pairs(Classes) do
				if v:IsA(vv) then
					ClassFound = true
				end
			end
			if ClassFound then
				table.insert(Instances, v)
			end
			GetClasses(v)
		end
	end
	GetClasses(Parent)
	return Instances
end

function DressCharacter(character, Objects)
	if not character or not character.Parent then
		return
	end
	local Head = character:FindFirstChild("Head")
	for i, v in pairs(Objects) do
		local Object = v:Clone()
		if v:IsA("Accessory") then
			local handle = v:FindFirstChild("Handle")
			if handle and Head then
				handle = handle:Clone()
				handle.Name = v.Name
				local FakeHat = Instance.new("StringValue")
				FakeHat.Name = "FakeHat"
				FakeHat.Parent = handle
				local HeadWeld = Instance.new("Weld")
				HeadWeld.Name = "HeadWeld"
				HeadWeld.Part0 = Head
				HeadWeld.Part1 = handle
				HeadWeld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				HeadWeld.C1 = CFrame.new(
					v.AttachmentPos.X, --Pos X
					v.AttachmentPos.Y, --Pos Y
					v.AttachmentPos.Z, --Pos Z
					math.abs(v.AttachmentRight.X), --R00
					v.AttachmentUp.X, --R01
					math.abs(v.AttachmentForward.X), --R02
					v.AttachmentRight.Y, --R10
					v.AttachmentUp.Y, --R11
					(math.abs(v.AttachmentForward.Y) * -1), --R12
					v.AttachmentRight.Z, --R20
					v.AttachmentUp.Z, --R21
					math.abs(v.AttachmentForward.Z) --R22
				)
				HeadWeld.Parent = handle
				handle.Parent = character
			end
		elseif v:IsA("Clothing") then
			Object.Parent = character
		elseif v:FindFirstChild("R15") and v:FindFirstChild("R6") then
 			PackageLib.ApplyBodyPart(character, v.R15, v.R6)
 		end
	end
end

function PositionPart(Part, X, Y, Z)
	local PartClone = Part:Clone()
	local PartCloneY = PartClone:Clone()
	PartCloneY.CFrame = PartCloneY.CFrame * CFrame.Angles(-math.rad(90), 0, 0)		
	PartCloneY.CFrame = PartCloneY.CFrame - PartCloneY.CFrame.lookVector * Y
	local PartCloneZ = PartCloneY:Clone()
	PartCloneZ.CFrame = PartCloneZ.CFrame + PartClone.CFrame.lookVector * Z
	local PartCloneX = PartCloneZ:Clone()
	PartCloneX.CFrame = PartCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX.CFrame = PartCloneX.CFrame - PartCloneX.CFrame.lookVector * X
	return PartCloneX.CFrame
end

function FireProjectile(SpawnPosition, TargetPosition)
	local Force = 150
	local Projectile = BaseProjectile:Clone()
	local Mass = (Projectile:GetMass() * Gravity)
	TargetPosition = ((not TargetPosition and (SpawnPosition + Handle.CFrame.lookVector * 2).p) or TargetPosition)
	local Direction = CFrame.new(SpawnPosition.p, TargetPosition)
	local Orientation = (Direction + Direction.lookVector * (Projectile.Size.Y * 0.5)) * CFrame.Angles(0, 0, 0)
	local Velocity = Direction.lookVector * Force
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.velocity = Velocity
	BodyVelocity.Parent = Projectile
	Projectile.Velocity = Velocity
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Orientation
	BodyGyro.Parent = Projectile
	Debris:AddItem(Projectile, 5)
	Projectile.Parent = workspace
	Projectile.CFrame = Orientation
	return Projectile
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Fire:Play()
	local SpawnPosition = PositionPart(Handle, -0.1, 0.5, ((Handle.Size.Z * 0.5) - 0.06))
	local TargetPosition = InvokeClient("MousePosition")
	local Projectile = FireProjectile(SpawnPosition, TargetPosition)
	Projectile.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		if Hit.Parent ~= Tool then
			Projectile:Destroy()
		end
		local character = Hit.Parent
		if character:IsA("Accessory") or character:IsA("Tool") and character.Parent then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
			local Outfit = Outfits.Suits[1]
			local AppearanceAssets = GetSpecifiedClasses(character, {"Accessory", "Clothing", "CharacterMesh", "MeshPart"})
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BasePart") and v:FindFirstChild("FakeHat") then
					table.insert(AppearanceAssets, v)
				end
			end
			local NewAppearanceAssets = {}
			for i, v in pairs(Outfits.Suits[CurrentIndex].Assets) do
				table.insert(NewAppearanceAssets, v)
			end
			for i, v in pairs(NewAppearanceAssets) do
				NewAppearanceAssets[i] = InsertAsset(v)
			end
			table.insert(NewAppearanceAssets, BowTie:Clone())
			DressCharacter(character, NewAppearanceAssets)
			for i, v in pairs(AppearanceAssets) do
				if v and v.Parent then
					v:Destroy()
				end
			end
		end
	end)
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			InvokeClient("PlayAnimation", Animations.R15Equip)
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			InvokeClient("PlayAnimation", Animations.Equip)
		end
	end
	
	Tool.Grip = Grips.Equipped
	if PlayerGui then
		OutfitGuiClone = OutfitGui:Clone()
		local GuiHandlerClone = GuiHandler:Clone()
		GuiHandlerClone.Disabled = false
		GuiHandlerClone.Parent = OutfitGuiClone
		local ServerControlValue = Instance.new("ObjectValue")
		ServerControlValue.Name = "ServerControl"
		ServerControlValue.Value = ServerControl
		ServerControlValue.Parent = OutfitGuiClone
		OutfitGuiClone.Parent = PlayerGui
	end
end

function Unequipped()
	if OutfitGuiClone and OutfitGuiClone.Parent then
		OutfitGuiClone:Destroy()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	Tool.Grip = Grips.Unequipped
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)