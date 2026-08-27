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

Meshes = {
	BowWithArrow = (BaseUrl .. "276093629"),
	Bow = (BaseUrl .. "276093784"),
	Arrow = (BaseUrl .. "276093823"),
}

Grips = {
	Unequipped = CFrame.new(0, -0.125, 1.75, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.125, -0.125, 1.85, 0.638734519, -0.26884225, 0.720931351, -0.0174765736, 0.931660593, 0.362909198, -0.769228697, -0.244402036, 0.590385318),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Reload = {Animation = Tool:WaitForChild("Reload"), FadeTime = 0.5, Weight = nil, Speed = 1.25, Duration = 2},
	JumpSlash = {Animation = Tool:WaitForChild("JumpSlash"), FadeTime = 0.5, Weight = nil, Speed = 2.5, Duration = 1},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

Damage = 20
Range = 350
FireRate = 1
WindVec = Vector3.new(2, -1, 1).Unit

ShotsFired = 0

FirstClick = false
Clicks = 0

Rate = (1 / 60)

Tool.Enabled = true
Tool.Grip = Grips.Unequipped
Mesh.MeshId = Meshes.BowWithArrow

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 1.25)
BaseArrowMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = Meshes.Arrow,
	TextureId = (BaseUrl .. "276093885"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseArrow,
}
ArrowSound = Sounds.Hit:Clone()
ArrowSound.Parent = BaseArrow

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

function DrawBeam(StartPos, EndPos, Color, FadeDelay)
	local Distance = (StartPos - EndPos).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Head
	Mesh.Scale = Vector3.new(1, (Distance * 5), 1)
	Mesh.Parent = Laser
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
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

function Fire(StartPos, TargetPos)
	local FakeStartPos = StartPos
	local Vec = (TargetPos - StartPos).unit
	local Drop = false
	local RayHit, RayPos = CastRay(StartPos, Vec, Range, {Character}, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	local Arrow = BaseArrow:Clone()
	Sounds.Fire:Play()
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			if humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			else
				Drop = true
			end
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0.9 + (math.random(0, 1) * 0.4)))
		Arrow.CFrame = NewCF
		if not Drop then
			local StickWeld = RbxUtility.Create("Weld"){
				Part0 = RayHit,
				Part1 = Arrow,
				C0 = (RayHit.CFrame:inverse() * NewCF),
				C1 = (NewCF:inverse() * NewCF),
				Parent = Arrow,
			}
		else
			Arrow.Velocity = Vector3.new(0, 0, 0)
			Arrow.RotVelocity = Vector3.new(0, 0, 0)
		end
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * 300)
	end
	
	Debris:AddItem(Arrow, (10 + (math.random() * 10)))
	Arrow.Parent = game:GetService("Workspace")
	
	local HitSound = Arrow:FindFirstChild("Hit")
	if HitSound then
		HitSound:Play()
	end

	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.5)
	end)
	
end

function Blow(Part)
	local PartTouched
	local HitDebounce = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDebounce then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
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
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDebounce = true
		local PossibleDamage = {Min = 15, Max = 15}
		local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
		local HealthAfter = (humanoid.Health - DamageValue)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(DamageValue)
		wait(0.1)
		HitDebounce = false
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.2)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
			FirstClick = false
			Clicks = 0
			return
		end
		if Clicks <= 1 then
			Tool.Enabled = false
			local MousePosition = InvokeClient("MousePosition")
			if not MousePosition then
				Tool.Enabled = true
				FirstClick = false
				Clicks = 0
				return
			end
			MousePosition = MousePosition.Position
			Mesh.MeshId = Meshes.Bow
			Fire((Handle.CFrame * CFrame.new(3.5, 0.5, -1.75)).p, MousePosition)
			ShotsFired = (ShotsFired + 1)
			if ShotsFired >= 3 then
				ShotsFired = 0
				local Animation = Animations.Reload
				Spawn(function()
					InvokeClient("PlayAnimation", Animation)
				end)
				wait(Animation.Duration)
			else
				wait(FireRate)
			end
			Mesh.MeshId = Meshes.BowWithArrow
			Tool.Enabled = true
		elseif Clicks >= 2 then
			Tool.Enabled = false
			local MousePosition = InvokeClient("MousePosition")
			if not MousePosition then
				Tool.Enabled = true
				FirstClick = false
				Clicks = 0
				return
			end
			MousePosition = MousePosition.Position
			local Animation = Animations.JumpSlash
			Spawn(function()
				InvokeClient("PlayAnimation", Animation)
			end)
			wait(0.25)
			local Blades = {}
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				local Offsets = {
					CFrame.new(-0.3, 0.3, -1.5),
					CFrame.new(0.3, 0.3, -1.5),
				}
				for i, v in pairs(Offsets) do
					local Blade = BasePart:Clone()
					Blade.Name = "Blade"
					Blade.Transparency = 1
					Blade.Size = Vector3.new(0.5, 0.5, 2)
					Blade.CanCollide = false
					local BladeWeld = Create("Weld"){
						Part0 = Handle,
						Part1 = Blade,
						C0 = v,
						Parent = Blade,
					}
					Blow(Blade)
					table.insert(Blades, Blade)
					Blade.Parent = Tool
				end
			end
			wait(Animation.Duration)
			for i, v in pairs(Blades) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			Tool.Enabled = true
		end
		Clicks = 0
		FirstClick = false
	end
	Clicks = (Clicks + 1)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Clicks = 0
	ToolEquipped = true
	Tool.Grip = Grips.Equipped
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	Clicks = 0
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke