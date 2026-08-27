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

Functions = require(script:WaitForChild("Functions"))

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

BaseJet = Handle:Clone()
BaseJet.Name = "Jet"
BaseJet.Transparency = 0

BaseMissile = BasePart:Clone()
BaseMissile.Name = "Missile"
BaseMissile.Size = Vector3.new(0.5, 0.5, 0.75)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "94690081"),
	TextureId = (BaseUrl .. "94689966"),
	Scale = Vector3.new(0.65, 0.65, 0.65),
	VertexColor = Vector3.new(1, 0.85, 0.85),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseMissile,
}

ToolEquipped = false

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

Damage = 30
CoolDown = 3

AttackRadius = 30
AttackSpeed = 100
AttackTimeMax = 3

OrbitRadius = 5
OrbitVerticalOffset = 5
OrbitSpeedFactor = 2
OrbitGyroTorque = Vector3.new(400, 400, 400)

MaxJets = 3
JetLaunchDelay = 1

Jets = {}
TimeToLive = 30

Gravity = 196.20
OneStep = (1 / 30)

NumberOfOrbitingJets = 0

Handle.Transparency = 0
Tool.Enabled = true

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 500, IgnoreList)
end

function FindClosestHumanoid(Position, MaxRadius)
	if not Position then
		return
	end
	local MaxRadius = (MaxRadius or 75)
	local NearbyObjects = GetNearbyObjects(Region3.new((Torso.Position - Vector3.new(MaxRadius, MaxRadius, MaxRadius)), (Torso.Position + Vector3.new(MaxRadius, MaxRadius, MaxRadius))))
	local HumanoidsHit = {}
	local HumanoidsNearby = {}
	local PlayersNearby = {}
	for i, v in pairs(NearbyObjects) do
		local character = v.Parent
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(HumanoidsHit, humanoid) then
				local player = Players:GetPlayerFromCharacter(character)
				if player then
					table.insert(PlayersNearby, player)
				end
				local DistanceApart = (Position - torso.Position).Magnitude
				table.insert(HumanoidsHit, humanoid)
				table.insert(HumanoidsNearby, {Distance = DistanceApart, Player = (player or nil), Character = character, Humanoid = humanoid, Torso = torso})
			end
		end
	end
	table.sort(HumanoidsNearby, (function(a, b) --Sort nearby humanoids so that closest is first in the table.
		return a.Distance < b.Distance
	end))
	if #HumanoidsNearby == 0 then --If no humanoids were found, return nothing
		return nil
	else
		if #PlayersNearby > 0 then --Return closest player
			for i, v in pairs(HumanoidsNearby) do
				if v.Player then
					return v
				end
			end
		end
		return HumanoidsNearby[1] --No player, return closest humanoid
	end
end

function JetLogic(Jet, BodyPosition, BodyGyro, JetNumber)
	local ShootReload = {Min = 4, Max = 8}
	local SelectedReload = math.random(ShootReload.Min, ShootReload.Max)
	local LastShot = (tick() - (math.random(-(math.random(ShootReload.Min, ShootReload.Max) * 1000), 0) * 0.001))
	local JustShot = false
	while Jet and Jet.Parent and ToolEquipped and CheckIfAlive() do
		local Now = tick()
		--Update Orbit
		local Theta = ((tick() * OrbitSpeedFactor) + (JetNumber * (2 * math.pi / MaxJets)))
		local Offset = Vector3.new(OrbitRadius * math.cos(Theta), OrbitVerticalOffset, OrbitRadius * math.sin(Theta))
		BodyPosition.position = (Torso.Position + Offset)
		if not JustShot then
			BodyGyro.cframe = CFrame.new(Jet.Position, BodyPosition.position)
			--Check for targets
			if (Now - LastShot) > SelectedReload then
				local Target = FindClosestHumanoid(Jet.Position)
				if Target then
					if ToolEquipped and CheckIfAlive() then --Attack
						local TargetTorso = Target.Torso
						local DistanceApart = (TargetTorso.Position - Torso.Position).Magnitude
						if DistanceApart < AttackRadius then
							LastShot = Now
							local SpawnPosition = (Jet.CFrame * CFrame.new(0, -((Jet.Size.Y / 2) + (BaseMissile.Size.X / 2)), 0)).p
							local Missile = BaseMissile:Clone()
							local Mass = (Missile:GetMass() * Gravity)
							local ShootDirection = CFrame.new(SpawnPosition, TargetTorso.Position)
							local Force = 30
							local Velocity = (ShootDirection.lookVector * Force)
							JustShot = true
							BodyGyro.cframe = CFrame.new(Jet.Position, TargetTorso.Position)
							local BodyVelocity = Create("BodyVelocity"){
								maxForce = Vector3.new(Mass, Mass, Mass),
								velocity = Velocity,
								Parent = Missile,
							}
							local BodyGyro = Create("BodyGyro"){
								maxTorque = Vector3.new(math.huge, math.huge, math.huge),
								cframe = ShootDirection,
								Parent = Missile,
							}
							local Fire = Create("Fire"){
								Color = Color3.new((236 / 255), (139 / 255), (70 / 255)),
								SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255)),
								Heat = 2,
								Size = 2,
								Enabled = true,
								Parent = Missile,
							}
							local AlreadyHit = false
							Missile.Touched:connect(function(Hit)
								if not Hit or not Hit.Parent or Hit == Jet or AlreadyHit or Functions.CheckTableForInstance(Jets, Hit) then
									return
								end
								local character = Hit.Parent
								if character:IsA("Hat") or character:IsA("Accoutrement") or character:IsA("Tool") then
									character = character.Parent
								end
								local humanoid = character:FindFirstChild("Humanoid")
								if humanoid and humanoid.Health > 0 then
									local player = Players:GetPlayerFromCharacter(character)
									if (not player or (player and not Functions.IsTeamMate(Player, player))) then
										Functions.UntagHumanoid(humanoid)
										Functions.TagHumanoid(humanoid, Player)
										humanoid:TakeDamage(22)
									end
								end
								AlreadyHit = true
								Missile.Name = "Effect"
								Missile.Transparency = 1
								Missile.Anchored = true
								Missile.CanCollide = false
								Fire.Enabled = false
								local Explosion = Create("Explosion"){
									ExplosionType = Enum.ExplosionType.NoCraters,
									BlastPressure = 0,
									BlastRadius = 2,
									Position = Missile.Position,
									Parent = game:GetService("Workspace"),
								}
								Debris:AddItem(Missile, 1.5)
							end)
							Debris:AddItem(Missile, 5)
							Missile.CanCollide = false
							Missile.CFrame = ShootDirection
							Missile.Parent = game:GetService("Workspace")
							Missile.Velocity = Velocity
							Delay(1, (function()
								JustShot = false
							end))
						end
					end
				end
			end
		end
		wait(OneStep)
	end
	if Jet and Jet.Parent then
		Jet:Destroy()
	end
end

function AddNewJet(JetNumber)
	local Jet = BaseJet:Clone()
	Jet.CanCollide = true
	Jet.CFrame = Handle.CFrame
	local Mass = ((Jet:GetMass() * Gravity) * 100)
	local BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		position = Handle.Position,
		Parent = Jet,
	}
	local BodyGyro = Create("BodyGyro"){
		MaxTorque = OrbitGyroTorque,
		Parent = Jet,
	}
	Jet.Changed:connect(function(Property)
		if not Jet or not Jet.Parent then
			NumberOfOrbitingJets = (NumberOfOrbitingJets - 1)
		end
	end)
	table.insert(Jets, Jet)
	Debris:AddItem(Jet, TimeToLive)
	Jet.Parent = game:GetService("Workspace")
	Spawn(function()
		JetLogic(Jet, BodyPosition, BodyGyro, JetNumber)
	end)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Jets = {}
	NumberOfOrbitingJets = 0
	for i = 1, (MaxJets - NumberOfOrbitingJets) do
		AddNewJet(NumberOfOrbitingJets)
		NumberOfOrbitingJets = (NumberOfOrbitingJets + 1)
		wait(JetLaunchDelay)
	end
	wait(CoolDown)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)