--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PlayAnim = script:WaitForChild("PlayAnim")

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

Player = Players:GetPlayerFromCharacter(Character)
if Player then
	Backpack = Player:FindFirstChild("Backpack")
	if Backpack then
		Character.ChildAdded:connect(function(Child)
			wait()
			if Child and Child.Parent and Child:IsA("Tool") then
				Child.Parent = Backpack
			end
		end)
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = Backpack
			end
		end
	end
end

--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

SavedInstances = {}

function GatherAllInstances(Parent)
	local Instances = {}
	local function GatherInstances(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GatherInstances(v)
			table.insert(Instances, v)
		end
	end
	GatherInstances(Parent)
	return Instances
end

BaseColor = BrickColor.new("Really red")
for i, v in pairs(GatherAllInstances(Character)) do
	if not v.Parent:IsA("Tool") and not v.Parent.Parent:IsA("Tool") then
		if v:IsA("BasePart") then
			table.insert(SavedInstances, {v, v.Parent, v.BrickColor})
			v.BrickColor = BaseColor
		elseif v:IsA("CharacterMesh") then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			v.BaseTextureId = 0
			v.OverlayTextureId = 0
		elseif v:IsA("DataModelMesh") then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			if v:IsA("SpecialMesh") then
				v.TextureId = ""
			end
			local Color = BaseColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
		elseif v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("Decal") and v.Name ~= "face" then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			v:Destroy()
		end
	end
end

PlayAnimClone = PlayAnim:Clone()
PlayAnimClone.Disabled = false
PlayAnimClone.Parent = Humanoid

Humanoid.WalkSpeed = 25

wait(3)

for i, v in pairs(SavedInstances) do
	if v[1]:IsA("BasePart") then
		v[1].BrickColor = v[3]
	elseif v[1]:IsA("CharacterMesh") or v[1]:IsA("DataModelMesh") or v[1]:IsA("Clothing") or v[1]:IsA("ShirtGraphic") or v[1]:IsA("Decal") then
		v[1]:Destroy()
		v[3].Parent = v[2]
	end
end

Humanoid.WalkSpeed = 16

script:Destroy()