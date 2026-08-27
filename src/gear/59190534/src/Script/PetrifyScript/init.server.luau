--Rescripted by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SetBackpack = script:FindFirstChild("SetBackpack")

PartColor = BrickColor.new("Medium stone grey")
Color = PartColor.Color
Material = Enum.Material.Slate
VertexColor = Vector3.new(Color.r, Color.g, Color.b)
TextureId = 58972839
Texture = ("http://www.roblox.com/asset/?id=" .. TextureId)

Properties = {
	CharacterMesh = {
		BaseTextureId = TextureId,
		OverlayTextureId = TextureId,
	},
	BasePart = {
		BrickColor = PartColor,
		Material = Material
	},
	DataModelMesh = {
		VertexColor = VertexColor
	},
	FileMesh = {
		TextureId = Texture,
		VertexColor = Vector3.new(1, 1, 1)
	},
	Shirt = {
		ShirtTemplate = Texture
	},
	Pants = {
		PantsTemplate = Texture
	}
}

function SetBackpackEnabled(player, Enabled)
	if Player and SetBackpack then
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			local SetBackpackClone = SetBackpack:Clone()
			SetBackpackClone.Disabled = false
			local Boolean = Instance.new("BoolValue")
			Boolean.Name = "Boolean"
			Boolean.Value = Enabled
			Boolean.Parent = SetBackpackClone
			Debris:AddItem(SetBackpackClone, 2)
			SetBackpackClone.Parent = PlayerGui
		end
	end
end

function Stonify(Object)
	local ObjectsStonified = {}
	local function SetProperties(Object)
		local ObjectProperties = {}
		for i, v in pairs(Properties) do
			for ii, vv in pairs(v) do
				local PropertyExists = false
				pcall(function()
					local PropertyValue = Object[ii]
					PropertyExists = true
				end)
				if PropertyExists then
					if not Object:IsA("SpecialMesh") or Object.MeshType == Enum.MeshType.FileMesh then
						table.insert(ObjectProperties, {Property = ii, Value = Object[ii]})
						Object[ii] = vv
					end
				end
			end
		end
		return ((ObjectProperties ~= {} and ObjectProperties) or nil)
	end
	local function StonifyObject(Object)
		local ObjectProperties = SetProperties(Object)
		if ObjectProperties then
			table.insert(ObjectsStonified, {Object = Object, Properties = ObjectProperties})
		end
	end
	StonifyObject(Object)
	return ObjectsStonified
end

function GetAllObjects(Parent, Classes)
	local Objects = {}
	local function CheckObjectForClass(Object, Classes)
		for i, v in pairs(Classes) do
			if Object:IsA(v) then
				return true
			end
		end
		return false
	end
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if CheckObjectForClass(v, Classes) then
				table.insert(Objects, v)
			end
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

Humanoid = script:FindFirstChild("Humanoid")

if Humanoid and Humanoid.Parent then

	Humanoid = Humanoid.Value
	Character = Humanoid.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	
	StonifiedObjects = {}
	Limbs = {}
	FakeTools = {}
	EquippedTools = {}
	
	Humanoid.WalkSpeed = 0
	
	if Player then
		SetBackpackEnabled(Player, false)
	end
	
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			table.insert(Limbs, v)
		elseif v:IsA("Tool") then
			table.insert(EquippedTools, v)
			local Tool = Instance.new("Model")
			Tool.Name = v.Name
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("BasePart") then
					local Part = vv:Clone()
					Part.Anchored = true
					Part.CFrame = vv.CFrame
					Part.Parent = Tool
				end
			end
			if #Tool:GetChildren() > 0 then
				table.insert(FakeTools, Tool)
				Debris:AddItem(Tool, 8)
				Tool.Parent = Character
			end
		end
	end
	
	for i, v in pairs(GetAllObjects(Character, {"BasePart", "Clothing", "DataModelMesh", "CharacterMesh"})) do
		table.insert(StonifiedObjects, Stonify(v))
	end
	
	Humanoid:UnequipTools()
	
	for i = 1, 5 do
		Humanoid:TakeDamage(6)
		wait(1)
	end
	
	for i, v in pairs(Limbs) do
		if v and v.Parent and v:IsA("BasePart") then
			v.Anchored = false
		end
	end
	
	for i, v in pairs(EquippedTools) do
		Humanoid:EquipTool(v)
	end
	
	for i, v in pairs(StonifiedObjects) do
		for ii, vv in pairs(v) do
			if vv.Object and vv.Object.Parent then
				for iii, vvv in pairs(vv.Properties) do
					vv.Object[vvv.Property] = vvv.Value
				end
			end
		end
	end
	
	for i, v in pairs(FakeTools) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	
	Humanoid.WalkSpeed = 16
	if Player then
		SetBackpackEnabled(Player, true)
	end
end

Debris:AddItem(script, 2)