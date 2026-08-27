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

EffectIndicator = script:WaitForChild("UnluckyEffectIndicator")
EffectsScript = script:WaitForChild("Effects")

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 7, Max = 9},
	Hit = {Min = 12, Max = 17},
}

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

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Pop = Handle:WaitForChild("Pop"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.75},
	RiseArms = {Animation = Tool:WaitForChild("RiseArms"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
}

Specials = {
	Burst = {
		Enabled = true,
		Active = false,
		ReloadTime = 30,
	},
}

EffectTypes = {
	{Value = 1, Duration = 10, Front = Vector3.new(170, 0, 255), Back = Vector3.new(170, 170, 255)}, --Purple
	{Value = 2, Duration = 8, Front = Vector3.new(0, 255, 0), Back = Vector3.new(0, 170, 0)}, --Green
	{Value = 3, Duration = 10, Front = Vector3.new(255, 170, 0), Back = Vector3.new(255, 85, 0)}, --Orange
	{Value = 4, Duration = 20, Front = Vector3.new(85, 255, 255), Back = Vector3.new(85, 170, 255)}, --Blue
}

for i, v in pairs(EffectTypes) do
	local FrontColor = (v.Front / 255)
	v.Front = Color3.new(FrontColor.X, FrontColor.Y, FrontColor.Z)
	local BackColor = (v.Back / 255)
	v.Back = Color3.new(BackColor.X, BackColor.Y, BackColor.Z)
end

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

function Skeletonize(character)
	if not character then
		return
	end
	local SkeletonRemains = {
		["Head"] = {MeshId = "4770583", TextureId = "36869975", Scale = Vector3.new(3, 3, 3)},
		["Torso"] = {MeshId = "36780113", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Left Arm"] = {MeshId = "36780032", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Right Arm"] = {MeshId = "36780156", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Left Leg"] = {MeshId = "36780079", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
		["Right Leg"] = {MeshId = "36780195", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	}
	local function Materialize(Object)
		if Object:IsA("BasePart") then
			Object.BrickColor = BrickColor.new("Institutional white")
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
			end
		elseif Object:IsA("CharacterMesh") or Object:IsA("Clothing") then
			Object:Destroy()
		end
	end
	local function Effect(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			Materialize(v)
			Effect(v)
		end
	end
	Effect(character)
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
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
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	humanoid:TakeDamage(DamageValue)
	if humanoid.Health <= 0 then
	else
		local UnluckyChance = math.random(1, 10)
		if not character:FindFirstChild(EffectIndicator.Name) and UnluckyChance == 1 then
			
			local EffectChosen = EffectTypes[math.random(1, #EffectTypes)]
			
			local EffectsScriptCopy = EffectsScript:Clone()
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Mode", Class = "IntValue", Value = EffectChosen.Value},
				{Name = "Duration", Class = "NumberValue", Value = EffectChosen.Duration},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = EffectsScriptCopy,
				}
			end
			EffectsScriptCopy.Disabled = false
			EffectsScriptCopy.Parent = character
			
			local EffectIndicatorCopy = EffectIndicator:Clone()
			EffectIndicator.Text.TextColor3 = EffectChosen.Front
			EffectIndicator.Text.TextStrokeColor3 = EffectChosen.Back
			EffectIndicator.Text.Background.TextColor3 = EffectIndicator.Text.TextStrokeColor3
			EffectIndicator.Text.Background.TextStrokeColor3 = EffectIndicator.Text.Background.TextColor3
			EffectIndicatorCopy.Enabled = true
			EffectIndicatorCopy.Adornee = head
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = EffectsScriptCopy,
				Parent = EffectIndicatorCopy,
			}
			EffectIndicatorCopy.Parent = character
			
		end
	end
end

function GetPlayersNearby(Position, Radius)
	local Humanoids = {}
	local NegativeRegion = (Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = Functions.GetParts(Region, 500, IgnoreList)
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.SideSwipe}
	Attack(AttackAnims)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
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
	if mode == "KeyPressed" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down then
			local Special = Specials.Burst
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			local CurrentlyEquipped = true
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.RiseArms)
			end)
			wait(2)
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				local PlayersNearby = GetPlayersNearby(Handle.Position, 75)
				for i, v in pairs(PlayersNearby) do
					local character = v.Parent
					local Indicator = character:FindFirstChild(EffectIndicator.Name)
					if Indicator then
						Functions.UntagHumanoid(v)
						Functions.TagHumanoid(v, Player)
						v:TakeDamage(v.MaxHealth)
						if v.Health <= 0 then
							Skeletonize(character)
							local head = character:FindFirstChild("Head")
							if head then
								local PopSound = Sounds.Pop:Clone()
								PopSound.Pitch = (math.random(750, 1000) * 0.001)
								PopSound.Parent = head
								PopSound:Play()
							end
							for ii, vv in pairs(character:GetChildren()) do
								if vv:IsA("BasePart") then
									local Outward = ((CFrame.new(vv.Position) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)).lookVector * math.random(2, 8))
									local Up = (Vector3.new(0, 1, 0) * math.random(3, 15))
									vv.Velocity = (vv.Velocity + Outward + Up)
									vv.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
								end
							end
						end
					end
				end
			end
			Special.Active = false
			wait(Special.ReloadTime)
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)