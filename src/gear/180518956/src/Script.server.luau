--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Animations = {
	Drink = Tool:WaitForChild("Drink"),
	Morph = Tool:WaitForChild("Morph")
}

Sounds = {
	Gulp = Handle:WaitForChild("Gulp"),
	Sizzle = Handle:WaitForChild("Sizzle")
}

Monsters = require(180464321)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Duration = 30

Speed = 100

Equipped = false

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	if AssetModel and AssetModel.Parent then
		AssetModel:Destroy()
	end
	return Asset
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckTableForClass(Object, Classes)
	for i, v in pairs(Classes) do
		if Object:IsA(v) then
			return true
		end
	end
	return false
end

function GetAllAssets(Parent, Classes)
	local Assets = {}
	local function GetAssets(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v ~= Tool then
				if CheckTableForClass(v, Classes) then
					table.insert(Assets, v)
				end
				GetAssets(v)
			end
		end
	end
	GetAssets(Parent, Classes)
	return Assets
end

function CheckForProperty(Instance, Property)
	local PropertyExists = false
	pcall(function()
		local Property = Instance[Property]
		PropertyExists = true
	end)
	return PropertyExists
end

function CreateMonster(character)
	local Assets = GetAllAssets(character, {"Hat", "Decal", "CharacterMesh", "Clothing", "ShirtGraphic", "BodyColors", "DataModelMesh"})
	local Parts = GetAllAssets(character, {"BasePart"})
	local CharacterAssets = {}
	local CharacterParts = {}
	local MonsterAssets = {}
	local NewFace = false
	local NewHead = false
	for i, v in pairs(Assets) do
		if v and v.Parent then
			table.insert(CharacterAssets, {Parent = v.Parent, Object = v:Clone()})
			v:Destroy()
		end
	end
	for i, v in pairs(Parts) do
		if v and v.Parent then
			table.insert(CharacterParts, {Part = v, BrickColor = v.BrickColor, Transparency = v.Transparency})
		end
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 0
		end
	end
	local MonsterChosen = Monsters[math.random(1, #Monsters)]
	local MonsterName = MonsterChosen.Name
	for i, v in pairs(MonsterChosen.PackageParts) do
		local PackagePart = InsertAsset(v)
		if PackagePart:IsA("CharacterMesh") then
			table.insert(MonsterAssets, PackagePart)
			PackagePart.Parent = character
		end
	end
	if #MonsterChosen.Hats > 0 then
		local HatChosen = MonsterChosen.Hats[math.random(1, #MonsterChosen.Hats)]
		if (not MonsterChosen.BodyColors or #MonsterChosen.BodyColors == 0) and HatChosen.BodyColors and #HatChosen.BodyColors > 0 then
			local BodyColorsChosen = HatChosen.BodyColors[math.random(1, #HatChosen.BodyColors)]
			for i, v in pairs(BodyColorsChosen) do
				for ii, vv in pairs(character:GetChildren()) do
					if vv:IsA("BasePart") and vv.Name == v.Limb then
						vv.BrickColor = BrickColor.new(v.Color)
					end
				end
			end
		end
		if (not MonsterChosen.Clothing or #MonsterChosen.Clothing == 0) and HatChosen.Clothing and #HatChosen.Clothing > 0 then
			local ClothingChosen = HatChosen.Clothing[math.random(1, #HatChosen.Clothing)]
			for i, v in pairs(ClothingChosen) do
				local Clothing = InsertAsset(v)
				if Clothing:IsA("Clothing") then
					Clothing.Parent = character
				elseif Clothing:IsA("ShirtGraphic") then
					Clothing.Parent = character
					local torso = character:FindFirstChild("Torso")
					if torso then
						local Decal = Instance.new("Decal")
						Decal.Name = "roblox"
						Decal.Face = Enum.NormalId.Front
						Decal.Texture = Clothing.Graphic
						table.insert(MonsterAssets, Decal)
						Decal.Parent = torso
					end
				elseif Clothing:IsA("Decal") then
					Clothing.Name = "face"
					local head = character:FindFirstChild("Head")
					if head then
						NewFace = true
						table.insert(MonsterAssets, Clothing)
						Clothing.Parent = head
					end
				elseif Clothing:IsA("DataModelMesh") then
					local head = character:FindFirstChild("Head")
					if head then
						NewHead = true
						table.insert(MonsterAssers, Clothing)
						Clothing.Parent = head
					end
				end
			end
		end
		if (not MonsterChosen.Transparency or #MonsterChosen.Transparency == 0) and HatChosen.Transparency then
			for i, v in pairs(HatChosen.Transparency) do
				for ii, vv in pairs(character:GetChildren()) do
					if vv:IsA("BasePart") and vv.Name == v.Limb then
						vv.Transparency = v.Transparency
					end
				end
			end
		end
		if #HatChosen.Hats > 0 then
			for i, v in pairs(HatChosen.Hats) do
				local Hat = InsertAsset(v)
				local head = character:FindFirstChild("Head")
				local handle = Hat:FindFirstChild("Handle")
				if head and handle then
					local handle = handle:Clone()
					local MonsterMorphEffect = Instance.new("StringValue")
					MonsterMorphEffect.Name = "MonsterMorphEffect"
					MonsterMorphEffect.Value = MonsterName
					MonsterMorphEffect.Parent = handle
					handle.Name = Hat.Name
					handle.CanCollide = false
					local HeadWeld = Instance.new("Weld")
					HeadWeld.Name = "HeadWeld"
					HeadWeld.Part0 = head
					HeadWeld.Part1 = handle
					HeadWeld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					HeadWeld.C1 = CFrame.new(
						Hat.AttachmentPos.X, --Pos X
						Hat.AttachmentPos.Y, --Pos Y
						Hat.AttachmentPos.Z, --Pos Z
						math.abs(Hat.AttachmentRight.X), --R00
						Hat.AttachmentUp.X, --R01
						math.abs(Hat.AttachmentForward.X), --R02
						Hat.AttachmentRight.Y, --R10
						Hat.AttachmentUp.Y, --R11
						(math.abs(Hat.AttachmentForward.Y) * -1), --R12
						Hat.AttachmentRight.Z, --R20
						Hat.AttachmentUp.Z, --R21
						math.abs(Hat.AttachmentForward.Z) --R22
					)
					table.insert(MonsterAssets, handle)
					handle.Parent = character
					table.insert(MonsterAssets, HeadWled)
					HeadWeld.Parent = head
				end
			end
		end
	end
	if MonsterChosen.BodyColors and #MonsterChosen.BodyColors > 0 then
		local BodyColorsChosen = MonsterChosen.BodyColors[math.random(1, #MonsterChosen.BodyColors)]
		for i, v in pairs(BodyColorsChosen) do
			for ii, vv in pairs(character:GetChildren()) do
				if vv:IsA("BasePart") and vv.Name == v.Limb then
					vv.BrickColor = BrickColor.new(v.Color)
				end
			end
		end
	end
	if MonsterChosen.Transparency and #MonsterChosen.Transparency > 0 then
		for i, v in pairs(MonsterChosen.Transparency) do
			for ii, vv in pairs(character:GetChildren()) do
				if vv:IsA("BasePart") and vv.Name == v.Limb then
					vv.Transparency = v.Transparency
				end
			end
		end
	end
	if MonsterChosen.Clothing and #MonsterChosen.Clothing > 0 then
		local ClothingChosen = MonsterChosen.Clothing[math.random(1, #MonsterChosen.Clothing)]
		for i, v in pairs(ClothingChosen) do
			local Clothing = InsertAsset(v)
			if Clothing:IsA("Clothing") then
				Clothing.Parent = character
			elseif Clothing:IsA("ShirtGraphic") then
				Clothing.Parent = character
				local torso = character:FindFirstChild("Torso")
				if torso then
					local Decal = Instance.new("Decal")
					Decal.Name = "roblox"
					Decal.Face = Enum.NormalId.Front
					Decal.Texture = Clothing.Graphic
					table.insert(MonsterAssets, Decal)
					Decal.Parent = torso
				end
			elseif Clothing:IsA("Decal") then
				Clothing.Name = "face"
				local head = character:FindFirstChild("Head")
				if head then
					NewFace = true
					table.insert(MonsterAssets, Clothing)
					Clothing.Parent = head
				end
			elseif Clothing:IsA("DataModelMesh") then
				local head = character:FindFirstChild("Head")
				if head then
					NewHead = true
					table.insert(MonsterAssets, Clothing)
					Clothing.Parent = head
				end
			end
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		if head.Transparency >= 1 then
			head.Transparency = 0
			local Mesh = Instance.new("SpecialMesh")
			Mesh.Scale = Vector3.new(0, 0, 0)
			table.insert(MonsterAssets, Mesh)
			Mesh.Parent = head
		elseif not NewHead then
			local TempHead = Instance.new("SpecialMesh")
			TempHead.MeshType = Enum.MeshType.Head
			TempHead.Scale = Vector3.new(1.25, 1.25, 1.25)
			TempHead.VertexColor = Vector3.new(1, 1, 1)
			table.insert(MonsterAssets, TempHead)
			TempHead.Parent = head
		end
		if not NewFace then
			local TempFace = Instance.new("Decal")
			TempFace.Name = "face"
			TempFace.Face = Enum.NormalId.Front
			TempFace.Texture = "rbxasset://textures/face.png" --http://www.roblox.com/asset?id=12222851
			table.insert(MonsterAssets, TempFace)
			TempFace.Parent = head
		end
	end
	local BodyColors = Instance.new("BodyColors")
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			local PropertyName = (string.gsub(v.Name, " ", "") .. "Color")
			if CheckForProperty(BodyColors, PropertyName) then
				pcall(function()
					BodyColors[PropertyName] = v.BrickColor
				end)
			end
		end
	end
	BodyColors.Parent = character
	table.insert(MonsterAssets, BodyColors)
	return CharacterAssets, CharacterParts, MonsterAssets, MonsterName
end

function Transform(character)
	Tool.Enabled = false
	local Limbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
	local MonsterMorphed = Instance.new("StringValue")
	MonsterMorphed.Name = "MonsterMorphed"
	Debris:AddItem(MonsterMorphed, (Duration + 5))
	MonsterMorphed.Parent = character
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			if v:FindFirstChild("MonsterMorphEffect") then
				v:Destroy()
			elseif CheckTableForString(Limbs, v.Name) then
				local Fire = Instance.new("Fire")
				Fire.Color = Color3.new(0, 255, 0)
				Fire.SecondaryColor = Color3.new(0, 170, 0)
				Fire.Heat = 5
				Fire.Size = 10
				Fire.Enabled = true
				Debris:AddItem(Fire, 5)
				Delay(3, function()
					if Fire and Fire.Parent then
						Fire.Enabled = false
					end
				end)
				Fire.Parent = v
			end
		end
	end
	local CharacterAssets, CharacterParts, MonsterAssets, MonsterName = CreateMonster(character)
	if MonsterMorphed and MonsterMorphed.Parent then
		MonsterMorphed.Value = MonsterName
	end
	local FakeHat = Instance.new("Hat")
	FakeHat.Name = "FakeHat"
	FakeHat.Parent = character
	local FakeHatChanged = FakeHat.Changed:connect(function(Property)
		if Property == "Parent" then
			Delay(0, function()
				if FakeHat.Parent and FakeHat.Parent ~= character then
					FakeHat.Parent = character
				end
			end)
		end
	end)
	local HatAdded = character.ChildAdded:connect(function(Child)
		Delay(0, function()
			if Child:IsA("Hat") and Child.Parent and Child ~= FakeHat then
				Child.Parent = game:GetService("Workspace")
			end
		end)
	end)
	wait(Duration)
	for i, v in pairs({FakeHatChanged, HatAdded}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(MonsterAssets) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if FakeHat and FakeHat.Parent then
		FakeHat:Destroy()
	end
	for i, v in pairs(CharacterAssets) do
		if v.Object and v.Parent then
			local Object = v.Object:Clone()
			if v.Object:IsA("BasePart") then
				Object.BrickColor = v.BrickColor
				Object.Transparency = v.Transparency
			end
			Object.Parent = v.Parent
		end
	end
	for i, v in pairs(CharacterParts) do
		if v.Part and v.Part.Parent then
			v.Part.BrickColor = v.BrickColor
			v.Part.Transparency = v.Transparency
		end
	end
	if MonsterMorphed and MonsterMorphed.Parent then
		MonsterMorphed:Destroy()
	end
	Tool.Enabled = true
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or Character:FindFirstChild("MonsterMorphed") or Active then
		return
	end
	Active = true
	local character = Character
	local humanoid = Humanoid
	local CurrentlyEquipped = true
	local UnequippedConnection = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	InvokeClient("PlayAnimation", {Animation = Animations.Drink, FadeTime = 1, Weight = 1, Speed = 1})
	InvokeClient("PlaySound", Sounds.Gulp)
	wait(1.5)
	if CurrentlyEquipped then
		InvokeClient("StopSound", Sounds.Gulp)
		InvokeClient("PlaySound", Sounds.Sizzle)
		wait(1.5)
		if CurrentlyEquipped then
			if humanoid and humanoid.Parent then
				--humanoid.WalkSpeed = 0
			end
			InvokeClient("StopAnimation", Animations.Drink)
			InvokeClient("PlayAnimation", {Animation = Animations.Morph, FadeTime = 1, Weight = 1, Speed = 0.5})
			wait(1.5)
			if CurrentlyEquipped then
				Spawn(function()
					Transform(character)
				end)
				wait(3)
				if CurrentlyEquipped then
					InvokeClient("StopAnimation", Animations.Morph)				
				end
			end
		end
	end
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = 16
	end
	Active = false
end

function CheckIfAlive()
	return (Character.Parent and Player.Parent and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Equipped = true
end

function Unequipped()
	Equipped = false
	Active = false
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			InvokeClient("StopSound", v)
		end
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)