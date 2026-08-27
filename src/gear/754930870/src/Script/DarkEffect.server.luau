--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Creator = script:FindFirstChild("Creator")

BaseColor = BrickColor.new("Really black")
DarkProperties = {
	All = {
		--BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		TextureId = "",
		--Texture = "",
		VertexColor = Vector3.new(BaseColor.Color.r, BaseColor.Color.g, BaseColor.Color.b),
		BaseTextureId = 0,
		OverlayTextureId = 0,
		Transparency = 0.3,
		ShirtTemplate = "",
		PantsTemplate = "",
		SparkleColor = BaseColor.Color,
		Color = BaseColor.Color,
		SecondaryColor = BaseColor.Color,
	},
	Class = {
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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

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

function DarkEffect()
	
	UntagHumanoid(Humanoid)
	if Creator and Creator.Value and Creator.Value:IsA("Player") then
		TagHumanoid(Humanoid, Creator.Value)
	end
	Humanoid.Health = 0
	Character:BreakJoints()
	
	local EffectedInstances = GetAllInstances(Character)
	local OriginalInstances = {}
	for i, v in pairs(EffectedInstances) do
		local Instance = {Object = v, Properties = {}}
		local PropertiesAltered = {}
		if v:IsA("Hat") or v:IsA("Tool") then
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("BasePart") then
					vv.Parent = v.Parent
				end
			end
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.CanCollide = true
			v.Anchored = true
			Debris:AddItem(v, 10)
		end
		if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
		elseif v:IsA("Decal") and v.Name == "face" then
		elseif v:IsA("Clothing") then
			v:Destroy()
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
	
	wait(0.25)
	
	for i, v in pairs(EffectedInstances) do
		if v:IsA("BasePart") then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.velocity = (Vector3.new((math.random() - 0.5), 0, (math.random() - 0.5)).Unit * 80)
			BodyVelocity.maxForce = Vector3.new(100000, 100000, 100000)
			BodyVelocity.Parent = v
			v.Anchored = false
		end
	end
	
end

DarkEffect()

script:Destroy()