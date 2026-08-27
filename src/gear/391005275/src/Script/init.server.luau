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

Grips = {
	Loaded = CFrame.new(0, -0.25, 1.125, 1, 3.39938189e-009, 0, 0, 1, -8.11696282e-007, 0, 8.11689176e-007, 1),
	Unloaded = CFrame.new(0, -0.25, 1.05, 1, 3.39938189e-009, 0, 0, 1, -8.11696282e-007, 0, 8.11689176e-007, 1),
}

HitScript = script:WaitForChild("HitScript")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

BaseTicket = BasePart:Clone()
BaseTicket.Name = "Ticket"
BaseTicket.BrickColor = BrickColor.new("Bright yellow")
BaseTicket.Material = Enum.Material.Plastic
BaseTicket.Size = Vector3.new(0.2, 0.6, 1.1)--Vector3.new(1.125, 0.2, 0.65)
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "383200694"),
	TextureId = (BaseUrl .. "383200798"),
	Scale = Vector3.new(1.25, 1.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseTicket,
}
--[[for i, v in pairs({"Top", "Bottom"}) do
	Create("Decal"){
		Name = "Decal",
		Face = Enum.NormalId[v],
		Texture = (BaseUrl .. "19354292"),
		Transparency = 0,
		Parent = BaseTicket,
	}
end]]

BaseRobux = BasePart:Clone()
BaseRobux.Name = "Robuck"
BaseRobux.BrickColor = BrickColor.new("Dark green")
BaseTicket.Material = Enum.Material.Plastic
BaseRobux.Size = Vector3.new(1.125, 0.2, 0.65)
for i, v in pairs({"Top", "Bottom"}) do
	Create("Decal"){
		Name = "Decal",
		Face = Enum.NormalId[v],
		Texture = (BaseUrl .. "16658163"),
		Transparency = 0,
		Parent = BaseRobux,
	}
end

Meshes = {
	LoadedGun = 383200751,
	Gun = 383200608,
}

Animations = {}

Sounds = {
	ChaChing = Handle:WaitForChild("ChaChing"),
	Launch = Handle:WaitForChild("Launch"),
}

Rate = (1 / 60)

ReloadTime = 2

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Mesh.MeshId = (BaseUrl .. Meshes.LoadedGun)
Tool.Grip = Grips.Loaded
Tool.Enabled = true

function IsABuildersClubMember()
	return (Player.MembershipType ~= Enum.MembershipType.None)
end

function Fire(TargetPosition)
	local Force = {Min = 75, Max = 135}
	local UpForce = Vector3.new(0, 20, 0)
	for i = 1, math.random(4, 7) do
		local SpawnPosition = (Handle.CFrame * CFrame.new((math.random(-80, 80) * 0.01), (math.random(-80, 80) * 0.01), -((Handle.Size.Z / 2) + (BaseTicket.Size.X / 2))))
		local TargetDirection = CFrame.new(SpawnPosition.p, TargetPosition)
		local Ticket = BaseTicket:Clone()
		local Damage = 0
		if IsABuildersClubMember() and ((math.random() * 100) <= 5) then
			Ticket = BaseRobux:Clone()
			Damage = (Damage * 4)
		end
		Ticket.Name = (Ticket.Name .. "Effect")
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Damage", Class = "NumberValue", Value = Damage},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = Ticket,
			}
		end
		local HitScriptCopy = HitScript:Clone()
		HitScriptCopy.Disabled = false
		HitScriptCopy.Parent = Ticket
		Ticket.CFrame = (SpawnPosition * CFrame.Angles(math.rad(math.random(-30, 30)), ((math.pi / 1) + math.rad(math.random(-30, 30))), math.rad(math.random(-45, 45))))
		Ticket.Velocity = ((TargetDirection.lookVector * (math.random((Force.Min * 10), (Force.Max * 10)) * 0.1)) + UpForce)
		Debris:AddItem(Ticket, 15)
		Ticket.Parent = game:GetService("Workspace")
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	Tool.Grip = Grips.Unloaded
	Mesh.MeshId = (BaseUrl .. Meshes.Gun)
	local Sound = Sounds.Launch:Clone()
	Debris:AddItem(Sound, 1.25)
	Sound.Parent = Handle
	Sound:Play()
	Fire(MouseData.Position)
	wait(ReloadTime)
	Mesh.MeshId = (BaseUrl .. Meshes.LoadedGun)
	Tool.Grip = Grips.Loaded
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Loaded
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Loaded
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)