--Made by Luckymaxer

Functions = {}

BaseColor = BrickColor.new("Really black")
Color = BaseColor.Color

Functions.DarkProperties = {
	All = {
		--BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		Transparency = 0.5,
		TextureId = "",
		--Texture = "",
		VertexColor = Vector3.new(BaseColor.Color.r, BaseColor.Color.g, BaseColor.Color.b),
		BaseTextureId = 0,
		OverlayTextureId = 0,
		ShirtTemplate = "",
		PantsTemplate = "",
		SparkleColor = BaseColor.Color,
		Color = BaseColor.Color,
		SecondaryColor = BaseColor.Color,
	},
	Class = {
		BasePart = {
			Reflectance = 0,
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

function Functions.GetAllInstances(Parent)
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

function Functions.Redesign(Parent)
	local EffectedInstances = Functions.GetAllInstances(Parent)
	local OriginalInstances = {}
	local head = nil
	local rightarm = nil
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name == "Head" then
				head = v
			elseif v.Name == "Right Arm" then
				rightarm = v
			end
			if head and rightarm then
				break
			end
		end
	end
	for i, v in pairs(EffectedInstances) do
		local NewInstance = {Object = v, FakeObjects = {}, Properties = {}, Parent = v.Parent}
		local PropertiesAltered = {}
		if v:IsA("Hat") then
			if head then
				local Object = v:Clone()
				NewInstance.Object = Object
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("BasePart") and vv.Name == "Handle" then
						local Weld = Instance.new("Weld")
						Weld.Name = "HeadWeld"
						Weld.Part0 = head
						Weld.Part1 = vv
						Weld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						Weld.C1 = v.AttachmentPoint
						Weld.Parent = head
						vv.Parent = Parent
						table.insert(NewInstance.FakeObjects, vv)
					end
				end
			end
			v:Destroy()
		elseif v:IsA("Tool") then
			if rightarm then
				local Object = v:Clone()
				NewInstance.Object = Object
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("BasePart") and vv.Name == "Handle" then
						local Weld = Instance.new("Weld")
						Weld.Name = "RightGrip"
						Weld.Part0 = rightarm
						Weld.Part1 = vv
						Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
						Weld.C1 = v.Grip
						Weld.Parent = rightarm
						vv.Parent = Parent
						table.insert(NewInstance.FakeObjects, vv)
					end
				end
			end
			v:Destroy()
		end
		if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
		elseif v:IsA("Decal") and v.Name == "face" then
		elseif v:IsA("Clothing") then
			NewInstance.Object = v:Clone()
			v:Destroy()
		else
			for ii, vv in pairs(Functions.DarkProperties.All) do
				pcall(function()
					NewInstance.Properties[ii] = v[ii]
					PropertiesAltered[ii] = true
					v[ii] = vv
				end)
			end
			for ii, vv in pairs(Functions.DarkProperties.Class) do
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
	return OriginalInstances
end

function Functions.Weld(Parent, PrimaryPart)
	local Parts = {}
	local function WeldModel(Parent, PrimaryPart)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") and v ~= PrimaryPart then
				local Weld = Instance.new("Weld")
				Weld.Name = "Weld"
				Weld.Part0 = PrimaryPart
				Weld.Part1 = v
				Weld.C0 = PrimaryPart.CFrame:inverse()
				Weld.C1 = v.CFrame:inverse()
				Weld.Parent = v
				table.insert(Parts, v)
			end
			WeldModel(v, PrimaryPart)
		end
	end
	WeldModel(Parent, PrimaryPart)
	return Parts
end

return Functions