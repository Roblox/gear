Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Bristles = Tool:WaitForChild("Bristles")

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


BaseUrl = "rbxassetid://"

Grips = {
	Unequipped = CFrame.new(1.5, 1, -2.65, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(1.9, 1, -0.6, 0.936780334, 0.0126819406, -0.349688053, 0, 0.999343038, 0.0362426117, 0.349917948, -0.0339513645, 0.936164916),
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

Gravity = workspace.Gravity
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

Smoke = Bristles.Smoke
RunSound = Handle.Run
RevvandRunSound = Handle.RevvandRun
RevvandRunSound.Ended:Connect(function()
	RunSound:Play()
end)

function CraftBroom(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle and v ~= Bristles then
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
	Create("Motor6D"){
		Name = "Motor6D",
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
	spawn(function()
		Tool.Grip = Grips.Equipped
		CraftBroom(true)

		local Angle = 0
		while ToolEquipped and CurrentlyEquipped do	
			Angle = (Angle + (1 * Bristles.BristleMotor.MaxVelocity)) % 360
			Bristles.BristleMotor.DesiredAngle = Angle
			Bristles.BristleMotor.CurrentAngle = Angle
			game:GetService("RunService").Stepped:wait()
		end
	end)
	
	RevvandRunSound:Play()
end

function Unequipped()
	spawn(function()
		Tool.Grip = Grips.Unequipped
		CraftBroom(false)
	end)
	ToolEquipped = false
	RevvandRunSound:Stop()
	RunSound:Stop()
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
	
	if action == "UpdateSmokeVelocity" then
		Smoke.Rate = value or 20
	end
end

CraftBroom(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)