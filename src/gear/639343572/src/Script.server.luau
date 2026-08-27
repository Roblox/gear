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

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrrow"
BaseArrow.CanCollide = true
BaseArrow.Size = Vector3.new(0.2, 0.2, 2.5)
ArrowMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "638114738"),
	TextureId = (BaseUrl .. "638114902"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseArrow,
}

Animations = {
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	BoltThunk = Handle:WaitForChild("BoltThunk")
}

FireRate = 1.25
Range = 600
Power = 300
Rate = (1 / 30)
BarrelOffset = Vector3.new(0, 0, -1.5)
WindVec = Vector3.new(2, -1, 1).unit
Damage = 36

ToolEquipped = false

MouseDown = false

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
	
function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function DrawBeam(BeamStart, BeamEnd, Color, FadeDelay)
	local Distance = (BeamStart - BeamEnd).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	Laser.Locked = true
	Laser.CFrame = CFrame.new(BeamEnd, BeamStart) * CFrame.new(0, 0, -(Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	local Mesh = Create("CylinderMesh"){
		Scale = Vector3.new(1, (Distance * 5), 1),
		Parent = Laser,
	}
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")
	
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end
end

function CreateDisplayArrow()
	local DisplayArrow = Tool:FindFirstChild("DisplayArrow")
	if DisplayArrow then
		DisplayArrow:Destroy()
	end
	local Arrow = BaseArrow:Clone()
	Arrow.Name = "DisplayArrow"
	local ArrowWeld = Create("ManualWeld"){
		Name = "BoltWeld",
		Part0 = Handle,
		Part1 = Arrow,
		C0 = CFrame.new(0, 0, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = Arrow,
	}
	Arrow.Parent = Tool
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() or not MouseData then
		return
	end
	Tool.Enabled = false
	local StartPos = Head.Position
	local FakeStartPos = (Handle.CFrame * CFrame.new(BarrelOffset)).p
	local MousePosition = MouseData.Position
	local Vec = (MousePosition - StartPos).unit
	local Arrow = BaseArrow:Clone()		
	local Creator = Create("ObjectValue"){
		Name = "creator",
		Value = Player,
		Parent = Arrow,
	}
	local Sound = Sounds.BoltThunk:Clone()
	Sound.Parent = Arrow
	local RayHit, RayPos = CastRay(StartPos, Vec, Range, Character, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	if RayHit then
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, 1.35)
		Arrow.CFrame = NewCF
		local Weld = Create("Weld"){
			Part0 = RayHit,
			Part1 = Arrow,
			C0 = (RayHit.CFrame:inverse() * NewCF),
			C1 = (NewCF:inverse() * NewCF),
			Parent = Arrow,
		}
		Sound:Play()
		local character = RayHit.Parent
		if character:IsA("Accoutrement") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player or (player and player ~= Player and not IsTeamMate(Player, player)) then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			end
		end
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * Power)
	end
	Debris:AddItem(Arrow, 20)
	Arrow.Parent = game:GetService("Workspace")
	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.25)
	end)
	Sounds.Fire:Play()
	DisplayArrow = Tool:FindFirstChild("DisplayArrow")
	if DisplayArrow then
		DisplayArrow.Transparency = 1
	end
	wait(FireRate)
	DisplayArrow.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateDisplayArrow()
	end)
	ToolEquipped = true
end

function Unequipped()
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
	if player ~= Player or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Delay(0, (function()
	CreateDisplayArrow()
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)