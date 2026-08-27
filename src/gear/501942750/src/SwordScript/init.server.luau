--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
InsertService = game:GetService("InsertService")

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
	BaseDamage = 11,
	SlashDamage = 18,
	LungeDamage = 24,
}

BasePart = Create("Part"){
	Name = "Part",
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
}

Fire = script:WaitForChild("Fire")

Damage = DamageValues.BaseDamage

Grips = {
	Up = CFrame.new(0, -2.125, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -2.125, 0, 1, 0, 0, 0, 0, -1, -0, 1, 0)
}

Animations = {}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

Special = {
	Enabled = true,
	Active = false,
	Damage = 35,
	CoolDown = 15,
}

UpgradeHat = 1474657

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Gravity = workspace.Gravity

TransparentParts = {}

Lunging = false
ToolEquipped = false

Tool.Grip = Grips.Up
Tool.Enabled = true

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end

function CheckForUpgrade()
	local Upgrade = InsertAsset(UpgradeHat)
	return ((Character:FindFirstChild(Upgrade.Name) and true) or false)
end

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

function CreateFirePart(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local FirePart = BasePart:Clone()
	FirePart.Name = "Effect"
	FirePart.Transparency = 1
	FirePart.Size = Vector3.new(0.5, 3, 0.2)
	FirePart.CanCollide = false
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = FirePart,
		C0 = CFrame.new(0, 0.75, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = FirePart,
	}
	local FireParticle = Fire:Clone()
	FireParticle.Enabled = true
	FireParticle.Parent = FirePart
	FirePart.Parent = Tool
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
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
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage * ((Upgraded and 1.5) or 1))	
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
		Parent = Tool,
	}
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function SetTransparency(PrimaryParent, Transparency)
	local Parts = {}
	local function SetParentTransparency(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v ~= Tool then
				if v.Name ~= "HumanoidRootPart" then
					local ItemTransparent = false
					for ii, vv in pairs(TransparentParts) do
						if vv and vv.Part and vv.Part == v then
							ItemTransparent = true
						end
					end
					if not ItemTransparent then
						pcall(function()
							table.insert(Parts, {Part = v, Transparency = v.Transparency})
							v.Transparency = Transparency
						end)
					end
				end
				SetParentTransparency(v, Transparency)
			end
		end
	end
	SetParentTransparency(PrimaryParent)
	return Parts
end

function Lunge()
	Lunging = true
	local MouseData = InvokeClient("MouseData")
	if not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	local MousePosition = MouseData.Position
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Lunge",
		Parent = Tool,
	}
	Tool.Grip = Grips.Out
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	local Weight = (Mass * Gravity * 100)
	local Force = 70
	local Velocity = (Direction.lookVector * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Weight, 0, Weight),
		velocity = Velocity,
		P = 1250,
		Parent = Torso,
	}
	for i, v in pairs({BodyVelocity}) do
		Debris:AddItem(v, 0.5)
		v.Parent = Torso
	end
	wait(0.75)
	Tool.Grip = Grips.Up
	wait(0.5)
	Damage = DamageValues.SlashDamage
	Lunging = false
end

Tool.Enabled = true
LastAttack = 0

function Activated()

	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end

	Tool.Enabled = false

	Tick = RunService.Stepped:wait()

	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end

	LastAttack = Tick

	--wait(0.5)

	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		Upgraded = CheckForUpgrade()
		local BaseTransparency = ((Upgraded and 0.75) or 0.35)
		TransparentParts = SetTransparency(Character, BaseTransparency)
		ItemAdded = Character.ChildAdded:connect(function(Child)
			for i, v in pairs(SetTransparency(Child, BaseTransparency)) do
				table.insert(TransparentParts, v)
			end
		end)
		ItemRemoved = Character.ChildRemoved:connect(function(Child)
			for i, v in pairs(Child:GetChildren()) do
				for ii, vv in pairs(TransparentParts) do
					if vv.Part == v then
						vv.Part.Transparency = vv.Transparency
						table.remove(TransparentParts, ii)
					end
				end
			end
		end)
		CreateFirePart(true)
	end)
	Humanoid.WalkSpeed = (16 * ((Upgraded and 2) or 1.5))
	Humanoid.JumpPower = (50 * ((Upgraded and 2) or 1.75))
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
	if CheckIfAlive() then
		Humanoid.WalkSpeed = (16 * 1)
		Humanoid.JumpPower = (50 * 1)
	end
	Spawn(function()
		for i, v in pairs(TransparentParts) do
			if v and v.Part and v.Part.Parent then
				v.Part.Transparency = v.Transparency
			end
		end
		TransparentParts = {}
		for i, v in pairs({ItemAdded, ItemRemoved}) do
			if v then
				v:disconnect()
			end
		end
		CreateFirePart(true)
	end)
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPressed" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" then
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			local Flames = 12
			local RandomSpin = math.rad(math.random(0, 360))
			local UserPlayer = Player
			for i = 1, Flames do
				local FireBall = BasePart:Clone()
				FireBall.Transparency = 1
				FireBall.Shape = Enum.PartType.Ball
				FireBall.Size = Vector3.new(5, 5, 5)
				FireBall.CanCollide = false
				local FireParticle = Fire:Clone()
				FireParticle.LockedToPart = false
				FireParticle.Enabled = true
				FireParticle.Parent = FireBall
				FireBall.CFrame = Torso.CFrame
				local Weight = (FireBall:GetMass() * Gravity)
				local Force = 100
				local Direction = (CFrame.new(Torso.CFrame.p) * CFrame.Angles(0, (((math.pi * 2) / Flames) * i + RandomSpin), 0))
				local Velocity = (Direction.lookVector * Force)
				local BodyVelocity = Create("BodyVelocity"){
					Name = "BodyVelocity",
					maxForce = Vector3.new(Weight, Weight, Weight),
					velocity = Velocity,
					P = 1250,
					Parent = FireBall,
				}
				local AlreadyHit = false
				FireBall.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent or AlreadyHit then
						return
					end
					local character = Hit.Parent
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local player = Players:GetPlayerFromCharacter(character)
					if player and (player == UserPlayer or IsTeamMate(UserPlayer, player)) then
						return
					end
					AlreadyHit = true
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, UserPlayer)
					humanoid:TakeDamage((Special.Damage * ((Upgraded and 1.5) or 1)))
					humanoid.Sit = true
					local rootpart = character:FindFirstChild("HumanoidRootPart")
					if rootpart then
						rootpart.Velocity = (CFrame.new(FireBall.Position, rootpart.Position).lookVector * 25)
					end
				end)
				Debris:AddItem(FireBall, 4)
				FireBall.Parent = game:GetService("Workspace")
			end
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

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateFirePart(true)
end))

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)
ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Connection = Handle.Touched:connect(Blow)