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

HitScript = script:WaitForChild("HitScript")
OrbExplosion = script:WaitForChild("OrbExplosion")

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 7, Max = 11},
	Hit = {Min = 16, Max = 22},
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
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.75},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},
	RiseArms = {Animation = Tool:WaitForChild("RiseArms"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
}

Specials = {
	Ring = {
		Enabled = true,
		Active = false,
		ReloadTime = 10,
	},
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
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	humanoid:TakeDamage(DamageValue)
	if humanoid.Health <= 0 then
		local OrbExplosionCopy = OrbExplosion:Clone()
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "OriginPoint", Class = "Vector3Value", Value = Handle.Position},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = OrbExplosionCopy,
			}
		end
		OrbExplosionCopy.Disabled = false
		OrbExplosionCopy.Parent = Handle
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
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
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
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
	end)
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
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
			local Special = Specials.Ring
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.RiseArms)
			end)
			local RingPieces = 8
			local Radius = 5
			local Origin = (CFrame.new(Torso.Position))-- - Vector3.new(0, (Torso.Size.Y * 1.5), 0))
			for i = 1, RingPieces do
				local Part = BasePart:Clone()
				Part.Name = "Effect"
				Part.Transparency = 1
				Part.Size = Vector3.new(6, 6, 6)
				Part.Anchored = false
				Part.CanCollide = false
				local Direction = CFrame.Angles(0, (((math.pi * 2) / RingPieces) * i), 0)
				Part.CFrame = (Origin + (Origin * Direction).lookVector * Radius)
				local Fire = Create("Fire"){
					Name = "Fire",
					Color = Color3.new((255 / 255), (37 / 255), (37 / 255)),
					SecondaryColor = Color3.new((222 / 255), (42 / 255), (42 / 255)),
					Heat = 1,
					Size = 15,
					Enabled = true,
					Parent = Part,
				}
				local Force = 75
				local Mass = (Part:GetMass() * Gravity)
				local Velocity = (Direction.lookVector * Force)
				local BodyVelocity = Create("BodyVelocity"){
					maxForce = Vector3.new(Mass, Mass, Mass),
					velocity = Velocity,
					Parent = Part,
				}
				local HitScriptCopy = HitScript:Clone()
				local Creator = Create("ObjectValue"){
					Name = "Creator",
					Value = Player,
					Parent = HitScriptCopy,
				}
				HitScriptCopy.Disabled = false
				HitScriptCopy.Parent = Part
				Debris:AddItem(Part, 5)
				Part.Parent = game:GetService("Workspace")
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