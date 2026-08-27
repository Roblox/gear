--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


BaseUrl = "http://www.roblox.com/asset/?id="

Content = require(Tool:WaitForChild("Content"))
MeshData = Content.MeshData

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

StencilPlate = BasePart:Clone()
StencilPlate.Name = "StencilPlate"
StencilPlate.Size = Vector3.new(0.2, 0.2, 0.2)
StencilPlate.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. MeshData.Meshes.Stencil),
	TextureId = (BaseUrl .. MeshData.Texture),
	Scale = Vector3.new(0.35, 0.35, 0.35),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = StencilPlate,
}

Grips = {
	Normal = CFrame.new(-0.075, 0, 0.5, -1.87381076e-007, 0, -1, 1, 0, -1.87381133e-007, 1.5108928e-010, -1, 0),
	Tracing = CFrame.new(-0.1, 0, 0.1, 0, -0.265, -1, 1, 0.125, 0, 0.125, -1, 0.265),
	Display = CFrame.new(-0.125, -0.3, 0, 0.85, 0.2875, 0.45, -0.09486489, 0.9, -0.4, -0.525, 0.3, 0.8),
}

Animations = {
	HoldStencil = {Animation = Tool:WaitForChild("HoldStencil"), FadeTime = 0.25, Weight = nil, Speed = nil, Duration = nil},
	Trace = {Animation = Tool:WaitForChild("Trace"), FadeTime = nil, Weight = nil, Speed = 0.1, Duration = (1 / 0.1)},
}

Sounds = {}

CoolDown = 5

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Mesh.MeshId = (BaseUrl .. MeshData.Meshes.Crayon)
Mesh.Scale = Vector3.new(0.25, 0.25, 0.25)
Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function CheckUpsideDown(CFrame, Surface, MaxAngle)
	local Vector1 = CFrame:vectorToWorldSpace(Vector3.FromNormalId(Surface))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > MaxAngle)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		InvokeClient("DisableMobility", {Disabled = true})
	end)
	local Ignore = {}
	for i, v in pairs(Players:GetPlayers()) do
		if v:IsA("Player") and v.Character then
			table.insert(Ignore, v.Character)
		end
	end
	local Arm = LeftArm
	local PlatePos = ((DisplayPlate.CFrame * CFrame.Angles(0, 0, 0)))
	local RayHit, RayPos, RayNormal = CastRay(PlatePos.p, Torso.CFrame.lookVector, 1, Ignore, false)
	if RayHit then
		Tool.Grip = Grips.Tracing
		local PartCFrame = CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * 2).p)
		PartCFrame = (PartCFrame * CFrame.new(0, 0, (DisplayPlate.Size.Z / 2)) * CFrame.new(0.0265, 0, 0))
		PartCFrame = (PartCFrame * CFrame.fromEulerAnglesXYZ(0, 0, 0))
		--[[local AX, AY, AZ = DisplayPlate.CFrame:toEulerAnglesXYZ()
		local AX2, AY2, AZ2 = PartCFrame:toEulerAnglesXYZ()
		PartCFrame = CFrame.new(PartCFrame.p) * CFrame.fromEulerAnglesXYZ(AX2, AY, AZ2)]]
		local ImagePart = BasePart:Clone()
		ImagePart.Name = "Effect"
		ImagePart.Transparency = 1
		ImagePart.Size = Vector3.new(2.3, 0.3, 0.2)
		ImagePart.CanCollide = false
		local Decal = Create("Decal"){
			Name = "Logo",
			Face = Enum.NormalId.Front,
			Texture = "",
			Shiny = 20,
			Specular = 0,
			Transparency = 0,
			Parent = ImagePart,
		}
		local Weld = Create("Motor6D"){
			Name = "Stick",
			Part0 = ImagePart,
			Part1 = RayHit,
			C0 = PartCFrame:inverse(),
			C1 = RayHit.CFrame:inverse(),
			Parent = ImagePart,
		}
		Debris:AddItem(ImagePart, 20)
		ImagePart.Parent = game:GetService("Workspace")
		local Animation = Animations.Trace
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		local StartTick = tick()
		Spawn(function()
			local Images = Content.Images
			for i, v in pairs(Images) do
				wait(Animation.Duration / #Images)
				if not CurrentlyEquipped or not ToolEquipped or not CheckIfAlive() then
					break
				end
				Decal.Texture = (BaseUrl .. v)
			end
		end)
		while CurrentlyEquipped and CheckIfAlive() and (tick() - StartTick) < Animation.Duration do
			wait()
		end
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		Spawn(function()
			InvokeClient("DisableMobility", {Disabled = false})
		end)
		Tool.Grip = Grips.Normal
		wait(CoolDown)
	end
	Spawn(function()
		InvokeClient("DisableMobility", {Disabled = false})
	end)
	Tool.Enabled = true
end

function CreateDisplayPlate(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew or not CheckIfAlive() then
		return
	end
	DisplayPlate = StencilPlate:Clone()
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = LeftArm,
		Part1 = DisplayPlate,
		C0 = (CFrame.new((1.75 * 1), -(LeftArm.Size.Y / 2), -(LeftArm.Size.Z / 2)) * CFrame.Angles(0, -(math.pi / 2), 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = DisplayPlate
	}
	DisplayPlate.Parent = Tool
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent and LeftArm and LeftArm.Parent and RightArm and RightArm.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	LeftArm = Character:FindFirstChild("Left Arm")
	RightArm = Character:FindFirstChild("Right Arm")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateDisplayPlate(true)
		InvokeClient("PlayAnimation", Animations.HoldStencil)
	end)
	Tool.Grip = Grips.Normal
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Normal
	CreateDisplayPlate(false)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

CreateDisplayPlate(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)