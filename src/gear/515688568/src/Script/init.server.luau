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

BombScript = script:WaitForChild("BombScript"):Clone()

Sounds = {
	Release = Handle:WaitForChild("Release"),
}

MeshData = {
	Body = "515596875",
	Arm = "515596792",
	Bomb = "515596939",
	TextureId = "515597419",
}

for i, v in pairs(MeshData) do
	MeshData[i] = (BaseUrl .. v)
end

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Body = BasePart:Clone()
Body.Name = "Body"
Body.Size = Vector3.new(1.25, 0.5, 2.375)
Body.CanCollide = false
BodyMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = MeshData.Body,
	TextureId = MeshData.TextureId,
	Scale = Vector3.new(0.9, 0.9, 0.9),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Body,
}
Arm = BasePart:Clone()
Arm.Name = "Arm"
Arm.Size = Vector3.new(0.75, 0.5, 2)
Arm.CanCollide = false
ArmMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = MeshData.Arm,
	TextureId = MeshData.TextureId,
	Scale = Vector3.new(0.9, 0.9, 0.9),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Arm,
}
Weld = Create("Weld"){
	Name = "Attachment",
	Part0 = Handle,
	Part1 = Body,
	C0 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)),
	C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)),
	Parent = Body,
}
Motor = Create("Motor"){
	Name = "Release",
	Part0 = Body,
	Part1 = Arm,
	C0 = (CFrame.new(0, 0.5675, -0.62) * CFrame.Angles(0, -(math.pi / 2), 0)),
	C1 = (CFrame.new(0, -0.05, -0.75) * CFrame.Angles(0, -(math.pi / 2), 0)),
	CurrentAngle = 0,
	DesiredAngle = 0,
	MaxVelocity = 0.1,
	Parent = Body,
}

Bomb = BasePart:Clone()
Bomb.Name = "Bomb"
Bomb.Friction = 1
Bomb.Elasticity = 1
Bomb.Shape = Enum.PartType.Ball
Bomb.Size = Vector3.new(0.75, 0.75, 0.75)
Bomb.CanCollide = false
BombMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = MeshData.Bomb,
	TextureId = (BaseUrl .. "515597548"),
	Scale = Vector3.new(0.9, 0.9, 0.9),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Bomb,
}
BombWeld = Create("Weld"){
	Name = "BombWeld",
	Part0 = Arm,
	Part1 = Bomb,
	C0 = (CFrame.new(0, 0.45, 0.675) * CFrame.Angles((math.pi / 60), 0, 0)),
	C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)),
	Parent = Bomb,
}

Gravity = 196.20

Duration = 0.75
ReloadTime = 4

BombReady = true
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

Tool.Enabled = true

function CreateBomb()
	if not ToolEquipped or not CheckIfAlive() or not ArmCopy or not ArmCopy.Parent then
		return
	end
	if BombCopy and BombCopy.Parent then
		BombCopy:Destroy()
	end
	BombCopy = Bomb:Clone()
	BombWeldCopy = BombCopy.BombWeld
	BombWeldCopy.Part0 = ArmCopy
	BombWeldCopy.Part1 = BombCopy
	BombWeldCopy.Parent = BombCopy
	BombCopy.Parent = Tool
end

function ReadyCatapult(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if MakeNew then
		BodyCopy = Body:Clone()
		ArmCopy = Arm:Clone()
		
		Release = BodyCopy.Release
		Release.Part0 = BodyCopy
		Release.Part1 = ArmCopy
		
		local Attachment = BodyCopy.Attachment
		Attachment.Part0 = Handle
		Attachment.Part1 = BodyCopy
		
		BodyCopy.Parent = Tool
		ArmCopy.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or not BombReady then
		return
	end
	if not ArmCopy or not ArmCopy.Parent or not Release or not Release.Parent then
		return
	end
	Tool.Enabled = false
	BombReady = false
	Sounds.Release.Pitch = (math.random(900, 1200) * 0.001)
	Sounds.Release:Play()
	Release.DesiredAngle = (math.random(500, 750) * 0.001)
	if BombCopy and BombCopy.Parent then
		Spawn(function()
			local CurrentBomb = BombCopy
			BombCopy = nil
			local SpawnPos = CurrentBomb.Position
			local TargetPos = MouseData.Position
			
			local Direction = (TargetPos - SpawnPos)
			Direction = (Direction - Direction.unit * 5)
			
			local DeltaXZSquared = ((Direction.X ^ 2) + (Direction.Z ^ 2))
			local DeltaXZ = math.sqrt(DeltaXZSquared)
			local DeltaY = Direction.Y
			local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
			local Numerator = (-0.5 * Gravity * DeltaXZSquared)
			local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
			if Denominator == 0 then
				return
			end
			local MissileSpeed = math.sqrt(Numerator / Denominator)
			if MissileSpeed > 80 or tostring(MissileSpeed) == "-1.#IND" or tostring(MissileSpeed) == "1.#INF" then
				MissileSpeed = 80
			end
			
			local VectorXZ = (MissileSpeed * math.cos(Alpha))
			local VectorY = (MissileSpeed * math.sin(Alpha))
			local VectorX = (VectorXZ * Direction.X / DeltaXZ)
			local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
			
			if BombWeldCopy and BombWeldCopy.Parent then
				BombWeldCopy:Destroy()
			end
			
			CurrentBomb.CanCollide = true
			CurrentBomb.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
			
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "PushForce", Class = "NumberValue", Value = 40},
				{Name = "Damage", Class = "NumberValue", Value = 0},
			}
			
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = CurrentBomb,
				}
			end
			
			local BombScriptCopy = BombScript:Clone()
			BombScriptCopy.Disabled = false
			BombScriptCopy.Parent = CurrentBomb
			
			Debris:AddItem(CurrentBomb, 10)
			CurrentBomb.Parent = game:GetService("Workspace")
		end)
	end
	Delay(Duration, (function()
		Release.DesiredAngle = 0
	end))
	wait(ReloadTime)
	CreateBomb()
	BombReady = true
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = nil
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Humanoid") then
			Humanoid = v
			break
		end
	end
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		ReadyCatapult(true)
		if BombReady then
			CreateBomb()
		end
	end)
end

function Unequipped()
	Spawn(function()
		ReadyCatapult(true)
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

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

ReadyCatapult(true)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)