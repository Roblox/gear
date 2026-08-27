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

Fire = script:WaitForChild("Fire")
DeathEffect = script:WaitForChild("DeathEffect")

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Woosh = Handle:WaitForChild("Woosh"),
	Whack = Handle:WaitForChild("Whack"),
	Hit = Handle:WaitForChild("Hit"),
}

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	LeftSlash = {Animation = R6Anims:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	RightSlash = {Animation = R6Anims:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	LeftSwingFast = {Animation = R6Anims:WaitForChild("LeftSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	RightSwingFast = {Animation = R6Anims:WaitForChild("RightSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	OverheadSwing = {Animation = R6Anims:WaitForChild("OverheadSwing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	R15LeftSlash = {Animation = R15Anims:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15RightSlash = {Animation = R15Anims:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15LeftSwingFast = {Animation = R15Anims:WaitForChild("LeftSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	R15RightSwingFast = {Animation = R15Anims:WaitForChild("RightSwingFast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	R15OverheadSwing = {Animation = R15Anims:WaitForChild("OverheadSwing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},

}

Rate = (1 / 60)

SwingDamage = 15

LastAttack = 0
LastSlam = 0
LastSoundPlay = 0
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

function CreateAxePart(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	AxePart = BasePart:Clone()
	AxePart.Name = "Blade"
	AxePart.Transparency = 1
	AxePart.Size = Vector3.new(0.25, 2, 1.75)
	AxePart.CanCollide = false
	local FireEffect = Fire:Clone()
	FireEffect.Enabled = true
	FireEffect.Parent = AxePart
	Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = AxePart,
		C0 = CFrame.new(0, 2, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = AxePart,
	}
	AxePart.Parent = Tool
	return AxePart, FireEffect
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
		local Blade, Flame = CreateAxePart(true)
		Delay(0.5, (function()
			Flame.Enabled = false
		end))
		Debris:AddItem(Blade, 1.25)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function PlaySound(Sound)
	local Now = tick()
	if (Now - LastSoundPlay) < 0.5 then
		return
	end
	LastSoundPlay = Now
	Sound:Play()
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

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or not Swinging or HitDelay then
			return
		end
		local SoundPlayed = false
		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		if RightArm then
			local RightGrip = RightArm:FindFirstChild("RightGrip")
			if RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle) then
				local character = Hit.Parent
				if character == Character then
					return
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player and IsTeamMate(Player, player) then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				local rootpart = character:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health >= 0 then
					if CurrentAnimation == Animations.LeftSlash or CurrentAnimation == Animations.RightSlash and math.random() <= 0.1 then
						if rootpart then
							rootpart.Velocity = (CFrame.new(RootPart.Position, rootpart.Position).lookVector * (math.random(500, 850) * 0.1))
						end
					end
					HitDelay = true
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(SwingDamage * ((Bashing and 2) or 1))
					if humanoid.Health <= 0 and rootpart then
						local WindDir = (CFrame.new(RootPart.Position, Vector3.new(rootpart.Position.X, RootPart.Position.Y, rootpart.Position.Z)) * CFrame.Angles(0, math.pi, 0)).lookVector
						ApplyDeathEffect(character, Vector3.new(WindDir.X, 1, WindDir.Z), ((WindDir * 6.5) + Vector3.new(0, 15, 0)))
					end
					if Bashing then
						humanoid.Sit = true
					end
					PlaySound(Sounds.Whack)
					SoundPlayed = true
				end
			end
		end
		if not SoundPlayed then
			Sounds.Hit.Pitch = (math.random(500, 800) * 0.001)
			PlaySound(Sounds.Hit)
		end
		wait(0.1)
		HitDelay = false
	end)
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
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15OverheadSwing
	end
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
	Bashing = false
end

function Swing()
	if not ToolEquipped or not CheckIfAlive() or Swinging then
		return
	end
	Swinging = true
	Sounds.Woosh:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.LeftSwingFast, Animations.RightSwingFast}
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		AttackAnims = {Animations.R15LeftSlash, Animations.R15RightSlash, Animations.R15LeftSwingFast, Animations.R15RightSwingFast}
	end
	Attack(AttackAnims)
	Swinging = false
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack) < 0.2 and (Tick - LastSlam) >= 2 then
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

Delay(0, (function()
	CreateAxePart(false)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)