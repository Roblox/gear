--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

DoubleJump = Tool:WaitForChild("DoubleJump")

JumpSound = Handle:WaitForChild("JumpSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BodyParts = {
	{Name = "Head", Color = "Black"},
	{Name = "Torso", Color = "Black"},
	{Name = "Left Arm", Color = "Medium stone grey"},
	{Name = "Right Arm", Color = "Medium stone grey"},
	{Name = "Left Leg", Color = "Black"},
	{Name = "Right Leg", Color = "Black"}
}

HatId = 81724957

PackageParts = {
	HeadMesh = {BodyPart = Enum.BodyPart.Head, MeshId = 6340213, BaseTextureId = 0, OverlayTextureId = 0},
	TorsoMesh = {BodyPart = Enum.BodyPart.Torso, MeshId = 71440868, BaseTextureId = 0, OverlayTextureId = 71440926},
	LeftArmMesh = {BodyPart = Enum.BodyPart.LeftArm, MeshId = 71440752, BaseTextureId = 0, OverlayTextureId = 71440926},
	RightArmMesh = {BodyPart = Enum.BodyPart.RightArm, MeshId = 71440800, BaseTextureId = 0, OverlayTextureId = 71440926},
	LeftLegMesh = {BodyPart = Enum.BodyPart.LeftLeg, MeshId = 71440777, BaseTextureId = 0, OverlayTextureId = 71440926},
	RightLegMesh = {BodyPart = Enum.BodyPart.RightLeg, MeshId = 71440824, BaseTextureId = 0, OverlayTextureId = 71440926}
}

OriginalBrickColors = {}
OriginalAssets = {}
TransparentObjects = {}
TemporaryAssets = {}

DoubleJumpEnabled = false
SpaceBar = false
CanDoubleJump = false
TimeLeftGround = 0
TimeOnGround = 0

Duration = 45
ReloadTime = 15

Active = false

function GetTransparentObjects(Table)
	local Objects = {}
	for i, v in pairs(Table) do
		local CheckTransparency = pcall(function()
			return ((v["Transparency"] and true) or false)
		end)
		if CheckTransparency then
			table.insert(Objects, v)
		end
	end
	return Objects
end

function TransformCharacter()
	for i, v in pairs(BodyParts) do
		local BodyPart = Character:FindFirstChild(v.Name)
		if BodyPart then
			table.insert(OriginalBrickColors, {Object = BodyPart, BrickColor = BodyPart.BrickColor})
			BodyPart.BrickColor = BrickColor.new(v.Name)
		end
	end
	local Parts = GetAllTransparentObjects(Character)
	TransparentObjects =  GetTransparentObjects(Parts)
	for i, v in pairs(Parts) do
		if CheckTransparency then
			table.insert(TransparentObjects, v)
		end
		if v:IsA("CharacterMesh") or v:IsA("Hat") or v:IsA("Clothing") then
			table.insert(OriginalAssets, {Object = v:Clone(), Parent = v.Parent})
			v:Destroy()
		end
	end
	local HatModel = InsertService:LoadAsset(HatId)
	local Hat = HatModel:GetChildren()[1]:Clone()
	HatModel:Destroy()
	table.insert(TemporaryAssets, Hat)
	Hat.Parent = Character
	table.insert(TransparentObjects, Hat:FindFirstChild("Handle"))
	for i, v in pairs(PackageParts) do
		local CharacterMesh = Instance.new("CharacterMesh")
		CharacterMesh.Name = i
		CharacterMesh.BodyPart = v.BodyPart
		CharacterMesh.MeshId = v.MeshId
		CharacterMesh.BaseTextureId = v.BaseTextureId
		CharacterMesh.OverlayTextureId = v.OverlayTextureId
		table.insert(TemporaryAssets, CharacterMesh)
		CharacterMesh.Parent = Character
	end
	AntiGravityForce = Instance.new("BodyForce")
	AntiGravityForce.Name = "LowGravity"
	AntiGravityForce.force = Vector3.new(0, 2000, 0)
	AntiGravityForce.Parent = Torso
end

function GetAllTransparentObjects(Parent)
	local Parts = {}
	local function GetTransparentObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v ~= Tool and v ~= Handle and v.Name ~= "HumanoidRootPart" then
				table.insert(Parts, v)
			end
			GetTransparentObjects(v)
		end
	end
	GetTransparentObjects(Parent)
	return Parts
end

function FadeTo(Parent, a, b, c)
	Spawn(function()
		for transparency = a, b, c do
			if not Active then
				break
			end
			for i, v in pairs(Parent) do
				if v.Name ~= "HumanoidRootPart" then
					v.Transparency = transparency
				end
			end
			wait(0.1)
		end
	end)
end

function TagHumanoid(humanoid, player)
	local creator = Instance.new("ObjectValue")
	creator.Parent = humanoid
	creator.Value = player
	creator.Name = "creator"
	Debris:AddItem(creator, 1)
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function InitializeDoubleJump()
	if TimeLeftGround ~= 0 and CanDoubleJump and TimeOnGround > 0.1 then
		local Smoke = {}
		for i = 1, 6 do
			local smoke = Instance.new("Smoke",workspace)
			smoke.Parent = Torso
			smoke.Size = 25
			smoke.Color = Color3.new(0.3, 0.3, 0.3)
			table.insert(Smoke, smoke)
			Debris:AddItem(smoke, 4)
		end
		
		Humanoid.WalkSpeed = 0
		Humanoid.Sit = true
		
		wait()
		
		CanDoubleJump = false
		TimeLeftGround = 0
		Anim = Humanoid:LoadAnimation(DoubleJump)
		Anim:Play()
		wait(0.35)
		
		wait()
		
		local JumpForce = Instance.new("BodyVelocity")
		JumpForce.P = 50000
		JumpForce.maxForce = Vector3.new(JumpForce.P, JumpForce.P, JumpForce.P) 
		JumpSound:play()
		JumpForce.Parent = Torso
		wait(0.5)
		JumpForce:Destroy() 
		Humanoid.WalkSpeed = 16
		wait(1)
		for i, v in pairs(Smoke) do
			if v and v.Parent then
				v:Destroy()
			end
		end
	end
end

function FreeFall(Falling)
	if Active then
		if Falling then
			TimeLeftGround = tick()
			TimeOnGround = (tick() - TimeOnGround)
			CanDoubleJump = true
		else
			TimeLeftGround = 0
			TimeOnGround = tick()
			CanDoubleJump = false
		end
	end
end

function CleanUp()
	if AntiGravityForce and AntiGravityForce.Parent then 
		AntiGravityForce:Destroy()
	end
	DoubleJumpEnabled = false
	for i, v in pairs(TemporaryAssets) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(OriginalAssets) do
		if v.Parent and v.Parent.Parent then
			v.Object.Parent = v.Parent
		end
		for i, v in pairs(OriginalBrickColors) do
			if v.Object and v.Object.Parent then
				v.Object.BrickColor = v.BrickColor
			end
		end
	end
	for i, v in pairs(TransparentObjects) do
		if v and v.Parent then
			v.Transparency = 0
		end
	end
	OriginalBrickColors = {}
	OriginalAssets = {}
	TemporaryAssets = {}
	TransparentObjects = {}
end

function Activated()
	if Tool.Enabled and not Active then
		Active = true
		Tool.Enabled = false
		DoubleJumpEnabled = true
		Handle.Transparency = 1
		TransformCharacter()
		FadeTo(TransparentObjects, 0.0,0.8,0.05)
		local StartTime = tick()
		while Active and (tick() - StartTime) < Duration do
			wait(0.1)
		end
		if Active then
			CleanUp()
			wait(ReloadTime)
			Tool.Enabled = true
			Active = false
		end
	end
end

function KeyDown(Key)	
	local Key = Key:lower()
	if Key == string.char(32) then
		if not SpaceBar and CanDoubleJump then 
			SpaceBar = true
			InitializeDoubleJump()
		end
	end
end

function KeyUp(Key)	
	local Key = Key:lower()
	if Key == string.char(32) then 
		SpaceBar = false
	end 
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	FreeFallingConnection = Humanoid.FreeFalling:connect(FreeFall)
	Mouse.Button1Down:connect(Activated)
	Mouse.KeyDown:connect(KeyDown)
	Mouse.KeyUp:connect(KeyUp)
end

function Unequipped()
	Active = false
	Handle.Transparency = 0
	if FreeFallingConnection then
		FreeFallingConnection:disconnect()
	end
	SpaceBar = false
	CleanUp()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
