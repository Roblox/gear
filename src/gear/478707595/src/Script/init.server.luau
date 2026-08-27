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


BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Woosh = Handle:WaitForChild("Woosh"),
	Whack = Handle:WaitForChild("Whack"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	LeftSwingFast = {Animation = Tool:WaitForChild("LeftSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	RightSwingFast = {Animation = Tool:WaitForChild("RightSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	OverheadSwing = {Animation = Tool:WaitForChild("OverheadSwing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
}

TripScript = script:WaitForChild("TripScript")

Rate = (1 / 60)

LastAttack = 0
LastSlam = 0
Swinging = false
Bashing = false
HitDelay = false
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

Handle.Transparency = 0
Tool.Enabled = true

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

ShockWave = BasePart:Clone()
ShockWave.Name = "ShockWave"
ShockWave.Transparency = 1
ShockWave.Size = Vector3.new(0.2, 4, 0.2)
ShockWave.Anchored = true
ShockWave.CanCollide = false
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Brick
Mesh.Scale = Vector3.new(1, 0, 1)
Mesh.Parent = ShockWave
for i = 1, 2 do
	local Decal = Instance.new("Decal")
	Decal.Texture = "http://www.roblox.com/asset?id=183210124"
	Decal.Transparency = 0.125
	Decal.Face = ((i == 1 and Enum.NormalId.Top) or Enum.NormalId.Bottom)
	Decal.Parent = ShockWave
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

function Burst()
	local UserPlayer = Player
	local UserCharacter = Character
	local IgnoreObjects = {UserCharacter, Tool}
	local Radius = 15
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
		if player then
			local PlayerGui = player:FindFirstChild("PlayerGui")
			if PlayerGui then
			end
		end
		local rootpart = character:FindFirstChild("rootpart")
		if rootpart then
			if (RootPart.Position - rootpart.Position).magnitude <= 25 then
				if player then
					local TripScriptClone = character:FindFirstChild(TripScript.Name)
					if not TripScriptClone then
						TripScriptClone = TripScript:Clone()
						TripScriptClone.Disabled = false
						Debris:AddItem(TripScriptClone, 0.5)
						TripScriptClone.Parent = character
						v.Sit = true
					end
				elseif not v.Sit then
					v.Sit = true
				end
				Spawn(function()
					UntagHumanoid(v)
					TagHumanoid(v, UserPlayer)
					v:TakeDamage(0.7)
				end)
			end
		end
	end
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or not Swinging or HitDelay then
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
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	if CurrentAnimation == Animations.LeftSlash or CurrentAnimation == Animations.RightSlash and math.random() <= 0.1 then
		local rootpart = character:FindFirstChild("HumanoidRootPart")
		if rootpart then
			rootpart.Velocity = (CFrame.new(RootPart.Position, rootpart.Position).lookVector * (math.random(500, 850) * 0.1))
		end
	end
	HitDelay = true
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(15)
	wait(0.1)
	HitDelay = false
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function Explode()
	if not ToolEquipped or not CheckIfAlive() or Bashing then
		return
	end
	Bashing = true
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.OverheadSwing
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration / 2)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		return
	end
	Spawn(function()
		local PushBack = 50
		local ShockWaves = {0, 3, 3}
		local DesiredRadius = 50
		if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
			return
		end
		local ShockWaveClone = ShockWave:Clone()
		local OriginalCFrame = CFrame.new(RootPart.Position)
		ShockWaveClone.CFrame = OriginalCFrame
		ShockWaveClone.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and (player == Player or IsTeamMate(Player, player)) then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local rootpart = character:FindFirstChild("HumanoidRootPart")
			if rootpart then
				rootpart.Velocity = CFrame.new(rootpart.Position, RootPart.Position).lookVector * -PushBack
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(25)
			humanoid.Sit = true
		end)
		Debris:AddItem(ShockWaveClone, 5)
		ShockWaveClone.Parent = game:GetService("Workspace")
		Spawn(function()
			local ResizeRate = 25
			for i = 1, ResizeRate do
				local ShockWaveSize = ((DesiredRadius / 25) * i)
				for ii, vv in pairs(ShockWaveClone:GetChildren()) do
					if vv:IsA("Decal") then
						vv.Transparency = ((1 * i) / ResizeRate)
					end
				end
				ShockWaveClone.Size = Vector3.new(ShockWaveSize, ShockWave.Size.Y, ShockWaveSize)
				ShockWaveClone.CFrame = OriginalCFrame
				wait(Rate)
			end
			if ShockWaveClone and ShockWaveClone.Parent then
				ShockWaveClone:Destroy()
			end
		end)
	end)
	Bashing = false
end

function Swing()
	if not ToolEquipped or not CheckIfAlive() or Swinging then
		return
	end
	Swinging = true
	Sounds.Woosh:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.LeftSwingFast, Animations.RightSwingFast}
	Attack(AttackAnims)
	Swinging = false
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack) < 0.2 and (Tick - LastSlam) >= 8 then
		LastSlam = Tick
		Explode()
	else
		Spawn(function()
			Swing()
		end)
	end
	LastAttack = Tick

	--wait(0.5)

	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
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

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)