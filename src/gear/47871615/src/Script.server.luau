--Rescripted by Luckymaxer

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


Folders = Tool:WaitForChild("Folders")
AnimationsFolder = Folders:WaitForChild("Animations")
RemoteFolder = Folders:WaitForChild("Remotes")

BaseUrl = "http://www.roblox.com/asset/?id="

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

Grips = {
	Normal = CFrame.new(2.2, 0, 0.3, 0.957837284, -0.287311196, 0, 0, 0, -1, 0.287311196, 0.957837284, 0),
	Fire = CFrame.new(1.8, 0, 0.3, 0, 0, 1, 1, -0, 0, 0, 1, -0),
}

Animations = {
	Fire = {Animation = AnimationsFolder:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Shoot = Handle:WaitForChild("Shoot"),
	GuitarSound = Handle:WaitForChild("GuitarSound"),
	Boom = Handle:WaitForChild("Boom"),
}

BaseMissile = BasePart:Clone()
BaseMissile.Name = "Missile"
BaseMissile.BrickColor = BrickColor.new("Black")
BaseMissile.Shape = Enum.PartType.Ball
BaseMissile.Size = Vector3.new(1, 1, 1)
MissileMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "25674043"),
	TextureId = (BaseUrl .. "16975111"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(0, 0, 0),
	Parent = BaseMissile,
}
MissileSound = Sounds.Boom:Clone()
MissileSound.Parent = BaseMissile

Gravity = 196.20

ToolEquipped = false

ServerControl = (RemoteFolder:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = RemoteFolder,
})

ClientControl = (RemoteFolder:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = RemoteFolder,
})

Tool.Grip = Grips.Normal
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

function Fire(Direction)
	
	if not Direction then
		return
	end
	
	Sounds.Shoot:Play()
	
	local SpawnPos = Handle.CFrame
	SpawnPos = (SpawnPos + Direction * 10)
	
	local Missile = BaseMissile:Clone()
	Missile.CFrame = SpawnPos
	Missile.Velocity = (Direction * 25)
	local MissileFloat = Create("BodyForce"){
		force = Vector3.new(0, (Missile:GetMass() * Gravity), 0),
		Parent = Missile,
	}
	local Exploded = false
	Missile.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Exploded then
			return
		end
		Exploded = true
		local Explosion = Instance.new("Explosion")
		Explosion.BlastPressure = 0
		Explosion.BlastRadius = 10
		Explosion.Position = Missile.Position
		Explosion.Hit:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			if character == Character then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and IsTeamMate(Player, player) then
				return
			end
			humanoid:TakeDamage(math.huge)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
		end)
		Debris:AddItem(Explosion, 1.5)
		Explosion.Parent = game:GetService("Workspace")
		local Sound = Missile:FindFirstChild(Sounds.Boom.Name)
		if Sound then
			Sound:Play()
		end
		if Missile and Missile.Parent then
			Missile:Destroy()
			Debris:AddItem(Missile, 0)
		end
	end)
	
	Debris:AddItem(Missile, 2)
	Missile.Parent = game:GetService("Workspace")
		
end

function GetTargetDirection()
	local StartPosition = Handle.Position
	local TargetPosition = InvokeClient("MousePosition")
	if not TargetPosition then
		return
	end
	TargetPosition = TargetPosition.Position
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	return Direction
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
	
	Sounds.GuitarSound:Play()
	
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Fire)
	end)
	
	wait(3.25)
	
	Tool.Grip = Grips.Fire
	
	for i = 1, 3 do
		if CurrentlyEquipped then
			Fire(GetTargetDirection())
			wait(0.75)
		end
	end
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	wait(0.25)

	Tool.Grip = Grips.Normal
	
	wait(4)
	
	Tool.Enabled = true	
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Normal
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	Tool.Grip = Grips.Normal
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)