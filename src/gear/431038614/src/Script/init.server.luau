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
	BaseDamage = 0,
	SlashDamage = 17,
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

BaseTrailPart = BasePart:Clone()
BaseTrailPart.Name = "LaserTrail"
BaseTrailPart.Transparency = 0.2
BaseTrailPart.Size = Vector3.new(0.2, 5, 3)
BaseTrailPart.Material = Enum.Material.SmoothPlastic
BaseTrailPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.RightSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.BackSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.Anchored = true
BaseTrailPart.CanCollide = false
TrailLight = Instance.new("PointLight")
TrailLight.Name = "Light"
TrailLight.Brightness = 10
TrailLight.Range = 8
TrailLight.Shadows = false
TrailLight.Enabled = true
TrailLight.Parent = BaseTrailPart

Rate = (1 / 60)

DeathEffect = script:WaitForChild("DeathEffect")

Sparkles = Handle:WaitForChild("Sparkles")
Sparkles.Enabled = false

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	R6LeftSlash = {Animation = R6Anims:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R6RightSlash = {Animation = R6Anims:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R6SideSwipe = {Animation = R6Anims:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.5},
	R15LeftSlash = {Animation = R15Anims:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15RightSlash = {Animation = R15Anims:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15SideSwipe = {Animation = R15Anims:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.5},

}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

ToolEquipped = false

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function ApplyDeathEffect(character, Direction, Force)
	local Direction = (Direction or Vector3.new(0, 0, 0))
	local Force = (Force or Vector3.new(0, 0, 0))
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local DeathEffectCopy = character:FindFirstChild(DeathEffect.Name)
	if DeathEffectCopy then
		return
	end
	DeathEffectCopy = DeathEffect:Clone()
	DeathEffectCopy.WindDirection.Value = Direction
	DeathEffectCopy.Force.Value = Force
	DeathEffectCopy.Disabled = false
	DeathEffectCopy.Parent = character
end

function DealDamage(character, damage)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootpart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not rootpart then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		local WindDir = (CFrame.new(RootPart.Position, Vector3.new(rootpart.Position.X, RootPart.Position.Y, rootpart.Position.Z)) * CFrame.Angles(0, math.pi, 0)).lookVector
		ApplyDeathEffect(character, Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))--Vector3.new(WindDir.X, 1, WindDir.Z), ((WindDir * 6.5) + Vector3.new(0, 15, 0)))
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
		local RightArm = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
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
		Spawn(function()
			if Sparkles.Enabled then
				return
			end
			Sparkles.Enabled = true
			wait(0.5)
			Sparkles.Enabled = false
		end)
		HitDelay = true
		local TotalDamage = Damage
		DealDamage(character, TotalDamage)
		local Now = tick()
		wait(0.05)
		HitDelay = false
	end)
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
	local SwingAnimations = ((Humanoid.RigType == Enum.HumanoidRigType.R6 and {Animations.R6LeftSlash, Animations.R6RightSlash, Animations.R6SideSwipe})
	or (Humanoid.RigType == Enum.HumanoidRigType.R15 and {Animations.R15LeftSlash, --[[Animations.R15RightSlash,]] Animations.R15SideSwipe}))
	local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Attack()
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)