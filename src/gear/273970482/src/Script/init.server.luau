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

PepperScript = script:WaitForChild("PepperScript")
Functions = require(script:WaitForChild("Functions"))

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

Pepper = BasePart:Clone()
Pepper.Name = "Projectile"
Pepper.Size = Vector3.new(0.25, 0.25, 1)
PepperMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	TextureId = (BaseUrl .. "272531498"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Pepper,
}

Peppers = {
	{Type = "Red", Index = 1, Mesh = 272531943},
	{Type = "Green", Index = 2, Mesh = 272531888},
	{Type = "Yellow", Index = 3, Mesh = 272532024},
}

Damage = 15
Gravity = 196.20

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
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		Tool.Enabled = true
		return
	end
	MousePosition = MousePosition.Position
	local StartPosition = (Handle.CFrame * CFrame.new(0, 0.2, -((Handle.Size.Z / 2) + 0.25)))
	local Direction = CFrame.new(StartPosition.p, MousePosition)
	local Force = 50

	local PepperChosen = Peppers[math.random(1, #Peppers)]
	local PepperCopy = Pepper:Clone()
	PepperCopy.Mesh.MeshId = (BaseUrl .. PepperChosen.Mesh)
	
	local Velocity = (Direction.lookVector * Force)
	local Mass = (PepperCopy:GetMass() * Gravity)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = PepperCopy,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
		Parent = PepperCopy,
	}
	PepperCopy.Velocity = Velocity
	PepperCopy.CFrame = Direction
	PepperCopy.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if (player and Player ~= player and not Functions.IsTeamMate(Player, player)) then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				if PepperCopy and PepperCopy.Parent then
					PepperCopy:Destroy()
				end
				humanoid:TakeDamage(Damage)
				local PepperScriptCopy = character:FindFirstChild(PepperScript.Name)
				if not PepperScriptCopy then
					PepperScriptCopy = PepperScript:Clone()
					PepperScriptCopy.Mode.Value = PepperChosen.Index
					PepperScriptCopy.Disabled = false
					PepperScriptCopy.Parent = character
				end
			end
		end
		if PepperCopy and PepperCopy.Parent then
			PepperCopy:Destroy()
		end
	end)
	Debris:AddItem(PepperCopy, 3)
	PepperCopy.Parent = game:GetService("Workspace")
	wait(2)
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