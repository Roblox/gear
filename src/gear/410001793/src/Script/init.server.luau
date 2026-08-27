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

Remover = script:WaitForChild("Remover")
Fire = script:WaitForChild("Fire")

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

BaseBalloon = BasePart:Clone()
BaseBalloon.Name = "HotAirBalloon"
BaseBalloon.Elasticity = 0
BaseBalloon.Friction = 0
BaseBalloon.Size = Vector3.new(1.5, 2.25, 1.5)
BallonMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "409314310"),
	TextureId = (BaseUrl .. "409314207"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseBalloon,
}
FirePart = BasePart:Clone()
FirePart.Name = "Effect"
FirePart.Transparency = 1
FirePart.CanCollide = false
Create("Weld"){
	Name = "Weld",
	Part0 = BaseBalloon,
	Part1 = FirePart,
	C0 = CFrame.new(0, -0.65, 0),
	C1 = CFrame.new(0, 0, 0),
	Parent = FirePart,
}
FirePart.Parent = BaseBalloon
FireParticle = Fire:Clone()
--FireParticle.Parent = FirePart

Flying = false
FlyingEnabled = true

Gravity = 196.20

Rate = (1 / 60)
ReloadTime = 5

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

function ResetBalloon()
	if Balloon and Balloon.Parent then
		Balloon:Destroy()
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Spawn(function()
			InvokeClient("SetCamera", {Properties = {CameraType = Enum.CameraType.Custom, CameraSubject = Humanoid}})
		end)
	end
	Flying = false
	FlyingEnabled = false
	Tool.Enabled = false
	wait(ReloadTime)
	--Handle.CanCollide = true
	--Handle.Transparency = 0
	FlyingEnabled = true
	Tool.Enabled = true
end

function MakeBalloon()
	
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() or (Balloon and Balloon.Parent) or not FlyingEnabled then
		return
	end
	FlyingEnabled = false
	
	Humanoid.WalkSpeed = 0
	Balloon = BaseBalloon:Clone()
	
	local Mass = (Balloon:GetMass() * Gravity)
	
	BodyGyro = Create("BodyGyro"){
		Name = "BodyGyro",
		D = 500,
		P = 3000,
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		Parent = Balloon,
	}
	
	BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		P = 1250,
		maxForce = Vector3.new(Mass, (Mass * 100), Mass),
		velocity = Vector3.new(0, 0, 0),
		Parent = Balloon,
	}
	
	BodyAngularVelocity = Create("BodyAngularVelocity"){
		P = 1250,
		maxTorque = Vector3.new(Mass, Mass, Mass),
		angularvelocity = Vector3.new(0, 0.5, 0),
		Parent = Balloon,
	}
	
	local RemoverCopy = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = RemoverCopy,
		}
	end
	RemoverCopy.Disabled = false
	RemoverCopy.Parent = Balloon
	--Handle.Transparency = 1
	--Handle.CanCollide = false
	--local BalloonFire = Balloon.Effect.Fire
	Balloon.CFrame = (Handle.CFrame * CFrame.new(0, 2, -(((Handle.Size.Z / 2) + (Balloon.Size.Z / 2)) + 2)))
	Balloon.Parent = game:GetService("Workspace")
	Spawn(function()
		InvokeClient("SetTargetFilter", {Object = Balloon})
		InvokeClient("SetCamera", {Properties = {CameraType = Enum.CameraType.Follow, CameraSubject = Balloon}})
	end)
	while ToolEquipped and CheckIfAlive() and Balloon and Balloon.Parent do
		--BalloonFire.Enabled = Flying
		if Flying then
			Spawn(function()
				local MouseData = InvokeClient("MouseData")
				if MouseData and MouseData.Position and ToolEquipped and Balloon and Balloon.Parent then
					local MousePosition = MouseData.Position
					local Speed = 8
					local Direction = CFrame.new(Balloon.Position, MousePosition).lookVector
					local Velocity = (Direction * Speed)
					BodyVelocity.velocity = Velocity
				end
			end)
		else
			BodyVelocity.velocity = (BodyVelocity.velocity * 0.98)
			if BodyVelocity.velocity.Magnitude < 0.35 then
				BodyVelocity.velocity = Vector3.new(0, 0, 0)
			end
		end
		wait(Rate)
	end
	ResetBalloon()
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	MakeBalloon()
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
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
	ResetBalloon()
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not Mode then
		return
	end
	if Mode == "MouseClick" then
		local Down = Value.Down
		if not Balloon or not Balloon.Parent then
			if Value.Down then
				Activated()
			end
		else
			Flying = Value.Down
		end
	end
end

for i, v in pairs(Tool:GetChildren()) do
	if (v:IsA("BasePart") or v:IsA("Model")) and v ~= Handle then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)