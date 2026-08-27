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

Grips = {
	Unequipped = CFrame.new(1.5, 1, -2.65, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(1.89999998, 1.125, -2.5999999, 0.936780334, 0.0126819406, -0.349688053, 0, 0.999343038, 0.0362426117, 0.349917948, -0.0339513645, 0.936164916),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Twig = BasePart:Clone()
Twig.Name = "Twig"
Twig.Size = Vector3.new(0.25, 0.5, 2)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "507351166"),
	TextureId = (BaseUrl .. "507351295"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Twig,
}

Gravity = 196.20
Rate = (1 / 60)

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function CraftBroom(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local BoundaryBox = BasePart:Clone()
	BoundaryBox.Name = "BoundaryBox"
	BoundaryBox.Transparency = 1
	BoundaryBox.Size = (Handle.Size * Vector3.new(2, 8.5, 1))
	BoundaryBox.CanCollide = true
	BoundaryBox.CFrame = Handle.CFrame
	Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = BoundaryBox,
		C0 = CFrame.new(0, 0, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = BoundaryBox,
	}
	BoundaryBox.Parent = Tool
	if not CreateNew or not CheckIfAlive() or not ToolEquipped then
		return
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent and Player:IsA("Player")) and true) or false)
end

function Activated()
	if not CheckIfAlive() or not ToolEquipped or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		Tool.Grip = Grips.Equipped
		CraftBroom(true)
		local LastTwig = {Time = tick(), CoolDown = (0.5 + (math.random() * 1.5))}
		while ToolEquipped and CurrentlyEquipped do
			local Now = tick()
			local Speed = RootPart.Velocity.Magnitude
			if Speed >= 10 then
				if (Now - LastTwig.Time) >= LastTwig.CoolDown then
					for i = 1, math.random(1, 4) do
						local TwigEffect = Twig:Clone()
						local TwigSize = ((math.random() * 0.5) + 0.75)
						TwigEffect.Size = (TwigEffect.Size * TwigSize)
						TwigEffect.Mesh.Scale = (TwigEffect.Mesh.Scale * TwigSize)
						TwigEffect.CFrame = ((Handle.CFrame * CFrame.new((math.random(-1, 1) * (math.random() * 2.5)), (math.random(-1, 1) * (math.random() * 2.25)), ((Handle.Size.Z / 2) + (TwigEffect.Size.Z / 2) + (0.5 + (math.random() * 1.5))))) * CFrame.Angles(math.random(), math.random(), math.random()))
						Debris:AddItem(TwigEffect, (math.random() * 3))
						TwigEffect.Parent = game:GetService("Workspace")
						LastTwig.Time = Now
						LastTwig.CoolDown = (0.2 + (math.random() * 0.7))
					end
				end
			else
				LastTwig.Time = Now
				LastTwig.CoolDown = (0.5 + (math.random() * 1.5))
			end
			wait(Rate)
		end
	end)
end

function Unequipped()
	Spawn(function()
		Tool.Grip = Grips.Unequipped
		CraftBroom(false)
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(client, action, value)
	if client ~= Player or not action or not CheckIfAlive() or not ToolEquipped then
		return
	end
end

CraftBroom(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)