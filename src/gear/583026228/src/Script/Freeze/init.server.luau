--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Duration = script:FindFirstChild("Duration")

Sounds = {
	Solidify = script:WaitForChild("Solidify"),
	Shatter = script:WaitForChild("Shatter"),
}

BaseColor = BrickColor.new("Pastel Blue")
DarkProperties = {
	All = {
		--BrickColor = BaseColor,
		Material = Enum.Material.Ice,
		TextureId = "",
		Texture = "",
		VertexColor = Vector3.new(BaseColor.Color.r, BaseColor.Color.g, BaseColor.Color.b),
		--BaseTextureId = 0,
		--OverlayTextureId = 0,
		SparkleColor = BaseColor.Color,
		Color = BaseColor.Color,
		SecondaryColor = BaseColor.Color,
	},
	Class = {
		BasePart = {
			Reflectance = 0.5,
			Anchored = true,
		},
		ParticleEmitter = {
			Color = ColorSequence.new(BaseColor.Color, BaseColor.Color),
		},
		Sparkles = {
			Color = BaseColor.Color,
			SparkleColor = BaseColor.Color,
		},
		Decal = {
			Texture = "",
		},
	}
}

RemovedObjects = {}

function GetAllInstances(Parent)
	local Instances = {}
	local function GetInstances(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			table.insert(Instances, v)
			GetInstances(v)
		end
	end
	GetInstances(Parent)
	return Instances
end

function Freeze()
	FrozenInstances = GetAllInstances(Character)
	OriginalInstances = {}
	for i, v in pairs(FrozenInstances) do
		local NewInstance = {Object = v, Properties = {}}
		local PropertiesAltered = {}
		if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
		elseif v:IsA("CharacterMesh") then
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = ("http://www.roblox.com/asset/?id=" .. v.MeshId)
			for ii, vv in pairs(Character:GetChildren()) do
				if vv:IsA("BasePart") and v.BodyPart.Name == string.gsub(vv.Name, " ", "") then
					Mesh.Parent = vv
					table.insert(RemovedObjects, {Object = v, NewObject = Mesh, Parent = v.Parent})
					v.Parent = nil
				end
			end
		elseif v:IsA("Decal") and v.Name == "face" then
		else
			for ii, vv in pairs(DarkProperties.All) do
				pcall(function()
					NewInstance.Properties[ii] = v[ii]
					PropertiesAltered[ii] = true
					v[ii] = vv
				end)
			end
			for ii, vv in pairs(DarkProperties.Class) do
				if v:IsA(ii) then
					for iii, vvv in pairs(vv) do
						--if not PropertiesAltered[iii] then
							pcall(function()
								NewInstance.Properties[iii] = v[iii]
								v[iii] = vvv
							end)
						--end
					end
				end
			end
		end
		table.insert(OriginalInstances, NewInstance)
	end
end

function Unfreeze()
	for i, v in pairs(RemovedObjects) do
		if v then
			if v.NewObject and v.NewObject.Parent then
				v.NewObject:Destroy()
			end
			v.Object.Parent = v.Parent
		end
	end
	for i, v in pairs(OriginalInstances) do
		if v.Object then
			for ii, vv in pairs(v.Properties) do
				pcall(function()
					v.Object[ii] = vv
				end)
			end
		end
	end
end

Freeze()
if Head then
	local SolidifySound = Sounds.Solidify:Clone()
	Debris:AddItem(SolidifySound, 2.5)
	SolidifySound.Parent = Head
	SolidifySound:Play()
end
if Duration and Duration.Value >= 0 then
	wait(Duration.Value)
	Unfreeze()
	if Head then
		local ShatterSound = Sounds.Shatter:Clone()
		Debris:AddItem(ShatterSound, 2.5)
		ShatterSound.Parent = Head
		ShatterSound:Play()
	end
end

script:Destroy()