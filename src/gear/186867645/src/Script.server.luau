--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Sparkles = Handle:WaitForChild("Sparkles")
PointLight = Handle:WaitForChild("PointLight")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	Activate = {Animation = Tool:WaitForChild("Activate"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 2}
}

Sounds = {}

ToolEquipped = false
AttemptingActivation = false

Duration = 30

DefaultColor = BrickColor.new("Lime green").Color

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "KeyPress" and Value then
		local Key = string.lower(Value.Key)
		local ByteKey = string.byte(Key)
		local Down = Value.Down
	end
end)

Sparkles.Enabled = false
PointLight.Enabled = false
Tool.Enabled = true

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function GetAllObjects(Parent)
	local Objects = {}
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			table.insert(Objects, v)
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

function GlowPart(Object)
	local Part, Weld, Meshes, Sparkles, Light = nil, nil, {}, nil, nil
	local Parts = {"Head", "HumanoidRootPart"}
	if Object.Parent ~= Tool and not Object.Parent:IsA("Tool") and Object.Parent.Name ~= "GlowingModel" then
		if Object:IsA("JointInstance") and Object.Name == "GlowWeld" then
			Object:Destroy()
		elseif Object:IsA("BasePart") then
			Part = Object:Clone()
			Part.Name = "GlowingPart"
			Part.Transparency = 0.5
			Part.Material = Enum.Material.Plastic
			Part.CanCollide = false
			Part.Locked = true
			Part.Anchored = false
			Light = Instance.new("PointLight")
			Light.Brightness = 50
			Light.Range = 6
			Light.Shadows = false
			Light.Enabled = false
			local Surfaces = {Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right}
			for i, v in pairs(Surfaces) do
				pcall(function()
					Part[Object.Name .. "Surface"] = Enum.SurfaceType.Smooth
				end)
			end
			Part.FormFactor = Enum.FormFactor.Custom
			Part.Size = Vector3.new(0.2, 0.2, 0.2)
			Weld = Instance.new("Weld")
			Weld.Name = "GlowWeld"
			Weld.Part0 = Object
			Weld.Part1 = Part
			Weld.C0 = CFrame.new(0, 0, 0)
			local PartUsable = false
			if not CheckTableForString(Parts, Object.Name) then
				if Object.Name == "Torso" then
					Sparkles = Instance.new("Sparkles")
					Sparkles.Enabled = false
				end
				local HasCharacterMesh = false
				for ii, vv in pairs(Object.Parent:GetChildren()) do
					if vv:IsA("CharacterMesh") and vv.BodyPart.Name == string.gsub(Object.Name, " ", "") then
						Weld.C0 = CFrame.new(0, 0.075, 0)
						Mesh = Instance.new("SpecialMesh")
						Mesh.MeshType = Enum.MeshType.FileMesh
						Mesh.MeshId = ("http://www.roblox.com/asset?id=" .. vv.MeshId)
						Mesh.TextureId = "null"
						Mesh.Scale = Vector3.new(1.1, 1.1, 1.1)
						Mesh.Parent = Part
						table.insert(Meshes, Mesh)
						PartUsable = true
						HasCharacterMesh = true
					end
				end
				if not HasCharacterMesh then
					if Object.Parent and Object.Parent:IsA("Hat") then
						for ii, vv in pairs(Part:GetChildren()) do
							if vv:IsA("DataModelMesh") then
								vv.Scale = Vector3.new((vv.Scale.X + 0.05), (vv.Scale.Y + 0.05), (vv.Scale.Z + 0.05))
								if vv.MeshType == Enum.MeshType.FileMesh then
									vv.TextureId = "http://www.roblox.com/asset?id="
								end
								table.insert(Meshes, vv)
								PartUsable = true
							end
						end
					else
						local Mesh = Instance.new("SpecialMesh")
						Mesh.MeshType = Enum.MeshType.FileMesh
						Mesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
						Mesh.TextureId = "http://www.roblox.com/asset/?ID=1361097"
						Mesh.Scale = ((Object.Size * 2) + Vector3.new(0.1, 0.1, 0.1))
						Mesh.Parent = Part
						table.insert(Meshes, Mesh)
						PartUsable = true
					end
				end
			elseif Object.Name == "Head" then
				for ii, vv in pairs(Part:GetChildren()) do
					if vv:IsA("DataModelMesh") then
						if vv.MeshType == Enum.MeshType.FileMesh then
							vv.TextureId = "http://www.roblox.com/asset?id="
							vv.Scale = Vector3.new((vv.Scale.X + 0.1), (vv.Scale.Y + 0.1), (vv.Scale.Z + 0.1))
						else
							vv.Scale = ((vv.Scale + Vector3.new(0.1, 0.1, 0.1)) * 5)
						end
						table.insert(Meshes, vv)
						PartUsable = true
					end
				end
			end
		end
	end	
	return ((Part and Weld and {Object = Object, Part = Part, Weld = Weld, Meshes = Meshes, Sparkles = Sparkles, Light = Light}) or nil)
end

function Glow(character, Color)
	if character == Tool then
		return
	end
	
	GlowingModel = Instance.new("Model")
	GlowingModel.Name = "GlowingModel"
	
	if GlowingModel and GlowingModel.Parent then
		GlowingModel:Destroy()
	end
	
	for i, v in pairs(character:GetChildren()) do
		if v.Name == GlowingModel.Name then
			v:Destroy()
		end
	end
	
	for i, v in pairs({ObjectAdded, ObjectRemoved}) do
		if v then
			v:disconnect()
		end
	end
	
	local GlowData = {}
	
	local function SetUpGlow(Table)
		Table.Part.BrickColor = BrickColor.new(Color)
		for ii, vv in pairs(Table.Part:GetChildren()) do
			if not vv:IsA("DataModelMesh") then
				vv:Destroy()
			end
		end
		for ii, vv in pairs({Table.Sparkles, Table.Light}) do
			if vv then
				pcall(function()
					vv[((vv:IsA("Sparkles") and "SparkleColor") or (vv:IsA("Light") and "Color"))] = Color
				end)
				vv.Enabled = true
				vv.Parent = Table.Part
			end
		end
		for ii, vv in pairs(Table.Meshes) do
			if vv:IsA("DataModelMesh") then
				vv.VertexColor = Vector3.new(Color.r, Color.g, Color.b)
			end
		end
		Table.Weld.Parent = Table.Part
		Table.Part.Parent = GlowingModel
	end
	
	local function GlowParts(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			local GlowTable = GlowPart(v)
			if GlowTable then
				local ObjectAlreadyUsed = false
				for ii, vv in pairs(GlowData) do
					if vv.Object and vv.Object and vv.Object == GlowTable.Object then
						ObjectAlreadyUsed = true
					end
				end
				if not ObjectAlreadyUsed then
					SetUpGlow(GlowTable)
					table.insert(GlowData, GlowTable)
				end
			end
			GlowParts(v)
		end
	end

	GlowParts(character)
	if Players:GetPlayerFromCharacter(character) then
		Debris:AddItem(GlowingModel, Duration)
		GlowingModel.Parent = character
		
		ObjectAdded = character.ChildAdded:connect(function(Child)
			if Child == Tool then
				return
			end
			wait()
			if not Child or not Child.Parent or Child.Name == GlowingModel.Name then
				return
			end
			GlowParts(Child)
		end)
		
		ObjectRemoved = character.ChildRemoved:connect(function(Child)
			if Child == Tool then
				return
			end
			wait()
			if not Child or not Child.Parent or Child.Name == GlowingModel.Name then
				return
			end
			local Objects = GetAllObjects(Child)
			for i, v in pairs(Objects) do
				for ii, vv in pairs(GlowData) do
					if v == vv.Object then
						if vv.Part and vv.Part.Parent then
							vv.Part:Destroy()
						end
						table.remove(GlowData, ii)
					end
				end
			end
		end)
		
		Spawn(function()
			local VertexColor = Color
			while GlowingModel and GlowingModel.Parent do
				for i = 1, 20 do
					local Interval = (0.05 * ((i < 11 and 1) or -1))
					VertexColor = Color3.new((VertexColor.r + Interval), VertexColor.g, VertexColor.b)
					for ii, vv in pairs(GlowData) do
						for iii, vvv in pairs(vv.Meshes) do
							if vvv:IsA("DataModelMesh") then
								vvv.VertexColor = Vector3.new(VertexColor.r, VertexColor.g, VertexColor.b)
							end
						end
						if vv.Sparkles and vv.Sparkles.Parent then
							vv.Sparkles.SparkleColor = Color3.new(VertexColor.r, VertexColor.g, VertexColor.b)
						end
					end
					wait(0.05)
				end
			end
			
			for i, v in pairs({ObjectAdded, ObjectRemoved}) do
				if v then
					v:disconnect()
				end
			end
			
		end)
		
	end
	
	return GlowingModel
end

function Activated()
	if not Tool.Enabled or AttemptingActivation or not CheckIfAlive() then
		return
	end
	AttemptingActivation = true
	local Animation = Animations.Activate
	InvokeClient("PlayAnimation", Animation)
	Sparkles.Enabled = true
	PointLight.Enabled = true
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	wait(Animation.Duration)
	if not CurrentlyEquipped then
		return
	end
	Tool.Enabled = false
	AttemptingActivation = false
	Sparkles.Enabled = false
	PointLight.Enabled = false
	local humanoid = Humanoid --Prevents glitching if the tool is dropped.
	humanoid.WalkSpeed = 24
	Spawn(function()
		Color = ((ColorBox and ColorBox.Parent and ColorBox.BackgroundColor3) or DefaultColor)
		Glow(Character, Color)
	end)
	wait(Duration)
	if GlowingModel and GlowingModel.Parent then
		GlowingModel:Destroy()
	end
	humanoid.WalkSpeed = 16
	wait((Duration / 2))
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	if PlayerGui then
		Spawn(function()
			pcall(function()
				if ColorGui and ColorGui.Parent then
					ColorGui:Destroy()
				end
				local CurrentlyEquipped = true
				if EquippedToolUnequipped then
					EquippedToolUnequipped:disconnect()
				end
				EquippedToolUnequipped = Tool.Unequipped:connect(function()
					CurrentlyEquipped = false
					if ColorGui and ColorGui.Parent then
						ColorGui:Destroy()
					end
				end)
				local Module = require(187430232)
				local PlayerReturnTable = Module.GetTable({Key = "NATMTablet", Player = Player})
				if ToolEquipped and CurrentlyEquipped and PlayerReturnTable then
					ColorGui = PlayerReturnTable.ColorGui(DefaultColor)
					ColorBox = ColorGui:FindFirstChild("Frame"):FindFirstChild("Border"):FindFirstChild("ColorBox")
					if ToolEquipped and CurrentlyEquipped then
						ColorGui.Parent = PlayerGui
					end
				end
			end)
		end)
	end
	ToolEquipped = true
end

function Unequipped()
	AttemptingActivation = false
	Sparkles.Enabled = false
	PointLight.Enabled = false
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	if ColorGui and ColorGui.Parent then
--		ColorGui:Destroy()
	end
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)