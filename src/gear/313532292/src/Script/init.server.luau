--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

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

Assets = require(script:WaitForChild("Assets"))

ClientManager = script:WaitForChild("ClientManager")
ScreenOverlayGui = script:WaitForChild("ScreenOverlayGui")
BackImage = script:WaitForChild("BackImage")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

BaseBackImagePart = BasePart:Clone()
BaseBackImagePart.Name = "BackImage"
BaseBackImagePart.Transparency = 1
BaseBackImagePart.Size = Vector3.new(1.175, 0.5, 0.2)
BaseBackImagePart.CanCollide = false
BackImageCopy = BackImage:Clone()
BackImageCopy.Adornee = BaseBackImagePart
BackImageCopy.Enabled = true
BackImageCopy.Parent = BaseBackImagePart

BaseDisk = BasePart:Clone()
BaseDisk.Name = "Disk"
BaseDisk.Size = Vector3.new(0.5, 0.5, 0.2)
BaseDisk.CanCollide = false
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. Assets.Disk.MeshId),
	TextureId = (BaseUrl .. Assets.Disk.TextureId),
	Scale = Vector3.new(3, 3, 3),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseDisk
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	InsertDisk = {Animation = Tool:WaitForChild("InsertDisk"), FadeTime = 0.125, Weight = nil, Speed = 0.375, Duration = ((1 / 0.375) / 2.5)},
	LookThrough = {Animation = Tool:WaitForChild("LookThrough"), FadeTime = 0.5, Weight = nil, Speed = nil, Duration = nil},
	HoldDisk = {Animation = Tool:WaitForChild("HoldDisk"), FadeTime = 0.5, Weight = nil, Speed = nil, Duration = nil},
	Hover = {Animation = Tool:WaitForChild("Hover"), FadeTime = 0.5, Weight = nil, Speed = 0.5, Duration = nil},
}

Grips = {
	Normal = CFrame.new(0.95, -0.5, -0.1, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Active = CFrame.new(1, 0, -0.25, 0.951802313, -0.00700343912, 0.30663237, 0.227017254, 0.688337982, -0.688951433, -0.206241682, 0.72535634, 0.656751513),
}

Sounds = {}

InView = false
ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

function DisplayBackImage()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle and v.Name == "BackImage" then
			v:Destroy()
		end
	end
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	BackImagePart = BaseBackImagePart:Clone()
	BackImageWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = BackImagePart,
		C0 = CFrame.new(0, 0, -0.1875),
		C1 = CFrame.new(0, 0, 0),
		Parent = BackImagePart
	}
	BackImagePart.Parent = Tool
end

function MakeDisk(AttachedPart, Offset)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle and v.Name == "Disk" then
			v:Destroy()
		end
	end
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Disk = BaseDisk:Clone()
	local DiskWeld = Create("Weld"){
		Part0 = AttachedPart,
		Part1 = Disk,
		C0 = Offset,
		C1 = CFrame.new(0, 0, 0),
		Parent = Disk
	}
	Disk.Parent = Tool
	return Disk, DiskWeld
end

function ManageTool()
	InView = false
	Tool.Grip = Grips.Normal
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if ScreenOverlayGuiCopy and ScreenOverlayGuiCopy.Parent then
		ScreenOverlayGuiCopy:Destroy()
	end
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("SetCameraOffset", Vector3.new(0, 0, 0))
	end)
	Humanoid.JumpPower = 50
	Humanoid.WalkSpeed = 16
end

function CreatePlayerManager(CreateNew)
	ClientManagerName = (Player.Name .. "'sViewMasterClientManager")
	ClientManagerCopy = game:GetService("Workspace"):FindFirstChild(ClientManagerName)
	if ClientManagerCopy then
		local Enabled = ClientManagerCopy:FindFirstChild("Enabled")
		if Enabled then
			Enabled.Value = false
		end
		ClientManagerCopy.Name = ""
		Debris:AddItem(ClientManagerCopy, 2)
	end
	if not CreateNew then
		return
	end
	ClientManagerCopy = ClientManager:Clone()
	ClientManagerCopy.Name = ClientManagerName
	ClientManagerCopy.Disabled = false
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
		{Name = "Enabled", Class = "BoolValue", Value = true},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = ClientManagerCopy,
		}
	end
	ClientManagerCopy.Parent = game:GetService("Workspace")
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if not InView then
		InView = true
		local Disk = MakeDisk(LeftArm, CFrame.new(0, (((LeftArm.Size.Y / 2) + (BaseDisk.Size.Y / 2)) * -1), 0))
		local Animation = Animations.LookThrough
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		local Animation = Animations.HoldDisk
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration)
		if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
			local Animation = Animations.LookThrough
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				CreatePlayerManager(true)
				Tool.Grip = Grips.Active
				Spawn(function()
					InvokeClient("PlayAnimation", Animation)
				end)
				ScreenOverlayGuiCopy = ScreenOverlayGui:Clone()
				if PlayerGui then
					local Values = {
						{Name = "Tool", Class = "ObjectValue", Value = Tool},
					}
					for i, v in pairs(Values) do
						local Value = Create(v.Class){
							Name = v.Name,
							Value = v.Value,
							Parent = ScreenOverlayGuiCopy,
						}
					end
					local LocalScript = ScreenOverlayGuiCopy:FindFirstChild("LocalScript")
					if LocalScript then
						LocalScript.Disabled = false
					end
					ScreenOverlayGuiCopy.Parent = PlayerGui
				end
				Humanoid.Sit = false
				Spawn(function()
					InvokeClient("SetCameraOffset", Vector3.new(0, 3, 0))
				end)
				Humanoid.JumpPower = 40
				Humanoid.WalkSpeed = 10
				DisplayBackImage()
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.Hover)
				end)
			end
		end
	else
		ManageTool()
		CreatePlayerManager(false)
		Spawn(function()
			InvokeClient("StopAnimation", Animations.LookThrough)
		end)
		Spawn(function()
			InvokeClient("StopAnimation", Animations.HoldDisk)
		end)
		Spawn(function()
			InvokeClient("StopAnimation", Animations.Hover)
		end)
	end
	wait(1)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and HumanoidRootPart and HumanoidRootPart.Parent and Torso and Torso.Parent and LeftArm and LeftArm.Parent and RightArm and RightArm.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	Torso = Character:FindFirstChild("Torso")
	LeftArm = Character:FindFirstChild("Left Arm")
	RightArm = Character:FindFirstChild("Right Arm")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		ManageTool()
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	ToolEquipped = true
end

function Unequipped()
	ManageTool()
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

ManageTool()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)