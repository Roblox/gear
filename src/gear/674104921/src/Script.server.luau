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

BaseRobux = BasePart:Clone()
BaseRobux.Name = "Robuck"
BaseRobux.BrickColor = BrickColor.new("Dark green")
BaseRobux.Material = Enum.Material.Plastic
BaseRobux.Size = Vector3.new(0.2, 0.675, 1.35)
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "667285348"),
	TextureId = (BaseUrl .. "665939136"),
	Scale = Vector3.new(1.25, 1.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseRobux,
}

Animations = {}

Sounds = {
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
Tool.Enabled = true

function Fire(TargetPosition)
	local Force = {Min = 30, Max = 50}
	local UpForce = Vector3.new(0, 20, 0)
	for i = 1, math.random(2, 5) do
		local SpawnPosition = (Handle.CFrame * CFrame.new((math.random(-80, 80) * 0.01), (math.random(-80, 80) * 0.01), -((Handle.Size.Z / 2) + (BaseRobux.Size.X / 2))))
		local TargetDirection = CFrame.new(SpawnPosition.p, TargetPosition)
		local Robux = BaseRobux:Clone()
		Robux.Name = (Robux.Name .. "Effect")
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = Robux,
			}
		end
		Robux.CFrame = (SpawnPosition * CFrame.Angles(math.rad(math.random(-30, 30)), ((math.pi / 1) + math.rad(math.random(-30, 30))), math.rad(math.random(-45, 45))))
		Robux.Velocity = ((TargetDirection.lookVector * (math.random((Force.Min * 10), (Force.Max * 10)) * 0.1)) + UpForce)
		Debris:AddItem(Robux, 15)
		Robux.Parent = game:GetService("Workspace")
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	local Sound = Sounds.Launch:Clone()
	Debris:AddItem(Sound, 1.25)
	Sound.Parent = Handle
	Sound:Play()
	Fire(MouseData.Position)
	wait(ReloadTime)
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
	ToolEquipped = true
end

function Unequipped()
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