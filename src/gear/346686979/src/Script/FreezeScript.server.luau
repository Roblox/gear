--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Duration = script:FindFirstChild("Duration")

BaseColor = BrickColor.new("Pearl")
DarkProperties = {
	All = {
		--BrickColor = BaseColor,
		Material = Enum.Material.Sand,
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
		local Instance = {Object = v, Properties = {}}
		local PropertiesAltered = {}
		if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
		elseif v:IsA("Decal") and v.Name == "face" then
		else
			for ii, vv in pairs(DarkProperties.All) do
				pcall(function()
					Instance.Properties[ii] = v[ii]
					PropertiesAltered[ii] = true
					v[ii] = vv
				end)
			end
			for ii, vv in pairs(DarkProperties.Class) do
				if v:IsA(ii) then
					for iii, vvv in pairs(vv) do
						--if not PropertiesAltered[iii] then
							pcall(function()
								Instance.Properties[iii] = v[iii]
								v[iii] = vvv
							end)
						--end
					end
				end
			end
		end
		table.insert(OriginalInstances, Instance)
	end
end

function Unfreeze()
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
if Duration and Duration.Value >= 0 then
	while Duration.Value > 0 do
		wait()
	end
	Unfreeze()
end

script:Destroy()