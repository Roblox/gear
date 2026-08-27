--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


DamageValues = {
	BaseDamage = 14,
	SlashDamage = 20,
	LungeDamage = 26,
}

Damage = DamageValues.BaseDamage

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Special = {
	Active = false,
	Enabled = true,
	CoolDown = 10,
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},
	Explode = {Animation = Tool:WaitForChild("Explode"), FadeTime = 0.25, Weight = nil, Speed = 2, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Grips = {
	Up = CFrame.new(0, -1.5, 0.125, 1, 0, -0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -1.5, 0, 1, 0, 0, 0, 0, -1, -0, 1, 0),
}

LastAttack = 0

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
Tool.Grip = Grips.Up
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

function ApplyDeathEffect(character)
		local SkeletonRemains = {
			["Head"] = {MeshId = "4770583", TextureId = "36869975", Scale = Vector3.new(3, 3, 3)},
			["HumanoidRootPart"] = {MeshId = "36780113", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
			["Left Arm"] = {MeshId = "36780032", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
			["Right Arm"] = {MeshId = "36780156", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
			["Left Leg"] = {MeshId = "36780079", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
			["Right Leg"] = {MeshId = "36780195", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		}
		local function Materialize(Object)
		if Object:IsA("BasePart") then
			Object.BrickColor = BrickColor.new("Brick yellow")
			local Remains = SkeletonRemains[Object.Name]
			if Remains then
				for ii, vv in pairs(Object:GetChildren()) do
					if vv:IsA("DataModelMesh") or vv:IsA("Decal") or vv:IsA("Texture") then
						vv:Destroy()
					end
				end
				local NewMesh = Create("SpecialMesh"){
					Name = "Mesh",
					MeshType = Enum.MeshType.FileMesh,
					MeshId = (BaseUrl .. Remains.MeshId),
					TextureId = "",
					Scale = Remains.Scale,
					VertexColor = Vector3.new(1, 1, 1),
					Offset = Vector3.new(0, 0, 0),
					Parent = Object,
				}
				Object.Transparency = 0
			else
				Object:Destroy()
			end
			for ii, vv in pairs(Object:GetChildren()) do
				if vv:IsA("DataModelMesh") then
					vv.VertexColor = Vector3.new(0, 0, 0)
				end
			end
		elseif Object:IsA("CharacterMesh") or Object:IsA("Clothing") then
			Object:Destroy()
		elseif Object:IsA("DataModelMesh") then
			Object.VertexColor = Vector3.new(0, 0, 0)
		end
	end
	local function Effect(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			Materialize(v)
			Effect(v)
		end
	end
	Materialize(character)
	Effect(character)
end

function DealDamage(character, damage)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootpart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health == 0 or not rootpart then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		ApplyDeathEffect(character)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Blow(Part)
	local PartTouched
	local HitDelay = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDelay then
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
		local rootpart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health == 0 or not rootpart then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		local TotalDamage = Damage
		DealDamage(character, TotalDamage)
		wait(0.05)
		HitDelay = false
	end)
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 3000, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function Explode()
	local Animation = Animations.Explode
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Explode)
	end)
	local UserPlayer = Player
	local UserCharacter = Character
	local IgnoreObjects = {UserCharacter, Tool}
	local Radius = 35
	local Objects = {}
	local Humanoids = {}
	local PlayersNearby = {}
	local NegativeRadius = (RootPart.Position - Vector3.new(Radius, (RootPart.Size.Y * 1.25), Radius))
	local PositiveRadius = (RootPart.Position + Vector3.new(Radius, (Radius / 6), Radius))
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= UserPlayer then
			local character = v.Character
			if character and character.Parent then
				table.insert(IgnoreObjects, v)
				if not IsTeamMate(v, UserPlayer) then
					local humanoid = character:FindFirstChild("Humanoid")
					local rootpart = character:FindFirstChild("HumanoidRootPart")
					if humanoid and humanoid.Health > 0 and (RootPart.Position - rootpart.Position).magnitude <= Radius then
						table.insert(Humanoids, humanoid)
					end
				end
			end
		end
	end
	local Parts = GetParts(Region3.new(NegativeRadius, PositiveRadius), 500, IgnoreObjects)
	for i, v in pairs(Parts) do
		if v and v.Parent and not CheckTableForInstance(Objects, v) then
			local character = v.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(character)
			if not CheckTableForInstance(Humanoids, humanoid) and not CheckTableForInstance(PlayersNearby, character) then
				if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
					if player and not CheckTableForInstance(PlayersNearby, player) then
						table.insert(PlayersNearby, player)
					end
				elseif (RootPart.Position - v.Position).magnitude <= Radius then
					table.insert(Objects, v)
				end
			end
		end
	end
	for i, v in pairs(Humanoids) do
		local character = v.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local rootpart = character:FindFirstChild("HumanoidRootPart")
		if rootpart then
			rootpart.Velocity = (CFrame.new(RootPart.Position, (rootpart.Position + Vector3.new(0, (math.random(500, 1000) * 0.01), 0))).lookVector * (math.random(750, 1750) * 0.1))
		end
		v.Sit = true
		DealDamage(character, 45)
		Humanoid.Health = (Humanoid.Health + 20)
	end
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	--[[local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
	}
	Debris:AddItem(Anim, 2)
	Anim.Parent = Tool]]
	local SwingAnimations = {Animations.LeftSlash, Animations.RightSlash, Animations.SideSwipe, Animations.Swing}
	local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
end

function Lunge()
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	for i, v in pairs(Animations) do
		Spawn(function()
			InvokeClient("StopAnimation", v)
		end)
	end
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Lunge",
	}
	Debris:AddItem(Anim, 2)
	Anim.Parent = Tool
	wait(0.2)
	Tool.Grip = Grips.Out
	wait(0.75)
	Tool.Grip = Grips.Up
	Damage = DamageValues.SlashDamage
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick
	--wait(0.5)
	Damage = DamageValues.BaseDamage
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		local Animation = Animations.Equip
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		ToolEquipped = true
		Humanoid.WalkSpeed = (16 * 1.5)
	end)
end

function Unequipped()
	Humanoid.WalkSpeed = 16
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPressed" then
		local Key = string.lower(value.Key)
		local Down = value.Down
		if Key == "q" and Down then
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			Explode()
			Special.Active = false
			wait(Special.CoolDown)
			Special.Enabled = true
		end
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

Blow(Handle)