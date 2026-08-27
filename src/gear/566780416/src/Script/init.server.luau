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

BaseUFO = BasePart:Clone()
BaseUFO.Name = "UFO"
BaseUFO.Elasticity = 0
BaseUFO.Friction = 0
BaseUFO.Size = Vector3.new(1.75, 0.75, 1.75)
BallonMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "567386808"),
	TextureId = (BaseUrl .. "567386989"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseUFO,
}

Flying = false
FlyingEnabled = true

Gravity = 196.20

Rate = (1 / 60)
ReloadTime = 5

LastClick = 0
LastShot = 0

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function ResetUFO()
	if UFO and UFO.Parent then
		UFO:Destroy()
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

function MakeUFO()
	
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() or (UFO and UFO.Parent) or not FlyingEnabled then
		return
	end
	FlyingEnabled = false
	
	LastClick = 0
	LastShot = 0
	
	Humanoid.WalkSpeed = 0
	UFO = BaseUFO:Clone()
	
	local Mass = (UFO:GetMass() * Gravity)
	
	BodyGyro = Create("BodyGyro"){
		Name = "BodyGyro",
		D = 500,
		P = 3000,
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		Parent = UFO,
	}
	
	BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		P = 1250,
		maxForce = Vector3.new(Mass, (Mass * 100), Mass),
		velocity = Vector3.new(0, 0, 0),
		Parent = UFO,
	}
	
	BodyAngularVelocity = Create("BodyAngularVelocity"){
		P = 1250,
		maxTorque = Vector3.new(Mass, Mass, Mass),
		angularvelocity = Vector3.new(0, 0.5, 0),
		Parent = UFO,
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
	RemoverCopy.Parent = UFO
	--Handle.Transparency = 1
	--Handle.CanCollide = false
	--local UFOFire = UFO.Effect.Fire
	UFO.CFrame = ((Handle.CFrame * CFrame.new(0, -(((Handle.Size.Z / 2) + (UFO.Size.Z / 2)) + 6), -2)) * CFrame.Angles(-(math.pi / 2), 0, 0))
	UFO.Parent = game:GetService("Workspace")
	Spawn(function()
		InvokeClient("SetTargetFilter", {Object = UFO})
		InvokeClient("SetCamera", {Properties = {CameraType = Enum.CameraType.Follow, CameraSubject = UFO}})
	end)
	while ToolEquipped and CheckIfAlive() and UFO and UFO.Parent do
		--UFOFire.Enabled = Flying
		if Flying then
			Spawn(function()
				local MouseData = InvokeClient("MouseData")
				if MouseData and MouseData.Position and ToolEquipped and UFO and UFO.Parent then
					local MousePosition = MouseData.Position
					local Speed = 8
					local Direction = CFrame.new(UFO.Position, MousePosition).lookVector
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
	ResetUFO()
end

function FireLaser(TargetPos)
	if not UFO or not UFO.Parent then
		return
	end
	local Laser = BasePart:Clone()
	Laser.Name = "Laser"
	Laser.Transparency = 0.25
	Laser.Size = Vector3.new(0.25, 0.25, 1.25)
	Laser.BrickColor = BrickColor.new("Teal")
	Laser.Material = Enum.Material.Neon
	Laser.CanCollide = false
	local ShootDir = CFrame.new(UFO.Position, TargetPos)
	Laser.CFrame = (ShootDir + ShootDir.lookVector * ((UFO.Size.Z / 2) + (Laser.Size.Z / 2) + 2))
	local Weight = (Laser:GetMass() * Gravity)
	local Force = 75
	local Velocity = (ShootDir.lookVector * Force)
	local BodyGyro = Create("BodyGyro"){
		Name = "BodyGyro",
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Laser.CFrame,
		Parent = Laser,
	}
	local BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		maxForce = Vector3.new(Weight, Weight, Weight),
		velocity = Velocity,
		Parent = Laser,
	}
	Laser.Velocity = Velocity
	local Creator = Player
	local AlreadyHit = false
	Laser.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or AlreadyHit then
			return
		end
		local HitPlayer = false
		local character = Hit.Parent
		if character:IsA("Accoutrement") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local player = Players:GetPlayerFromCharacter(character)
			if (not player or (player ((player ~= Creator) and not IsTeamMate(Creator, player)))) then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Creator)
				humanoid:TakeDamage(10)
				HitPlayer = true
			end
		end
		if HitPlayer or Hit.Transparency < 1 then
			Laser.Anchored = true
			Laser.Transparency = 1
			Laser.Name = "Effect"
			AlreadyHit = true
		end
	end)
	Debris:AddItem(Laser, 4)
	Laser.Parent = game:GetService("Workspace")
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	MakeUFO()
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
	ResetUFO()
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
		if not UFO or not UFO.Parent then
			if Value.Down then
				Activated()
			end
		else
			local Down = Value.Down
			local MousePos = Value.Position
			local Now = tick()
			if (Now - LastClick) <= 0.2 and Down then
				if (Now - LastShot) >= 0.4 then
					LastShot = Now
					FireLaser(MousePos)
				end
			else
				Flying = Down
			end
			LastClick = Now
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