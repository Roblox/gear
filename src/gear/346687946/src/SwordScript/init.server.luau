--Made by Luckymaxer
--Updated for R15 avatars by StarWars

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

Functions = require(script:WaitForChild("Functions"))

ParticleScript = script:WaitForChild("ParticleScript")
FireEffect = script:WaitForChild("Fire")

Fire = Handle:WaitForChild("Fire")

DeathEffect = script:WaitForChild("DeathEffect")

LastAttack = 0
Lunging = false

Grips = {
	Up = CFrame.new(0, 0, 1.5, 1, 0, 0, -0, 8.05986318e-008, 1, 0, -1, 8.05986318e-008),
	Out = CFrame.new(0, 0, 1.5, 1, 0, -0, -0, 1, 0, 0, -0.0079997452, 1),
}

--For R15 avatars
Animations = {
	R15Slash = 522635514,
	R15Lunge = 522638767
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
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

Gravity = 196.20

SwordDamage = 20

Abilities = {
	Bind = {
		Enabled = true,
		Active = false,
		ReloadTime = 20,
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

Tool.Grip = Grips.Up
Tool.Enabled = true

function DealDamage(humanoid, damage)
	if not humanoid or humanoid.Health == 0 or not damage then
		return
	end
	local character = humanoid.Parent
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		local DeathEffectCopy = character:FindFirstChild(DeathEffect.Name)
		if not DeathEffectCopy then
			DeathEffectCopy = DeathEffect:Clone()
			DeathEffectCopy.Disabled = false
			DeathEffectCopy.Parent = character
		end
	end
end

function Blow(Part, Damage)
	local PartTouched
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
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
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not humanoid or humanoid.Health == 0 and torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local HealthAfter = (humanoid.Health - Damage)
		DealDamage(humanoid, Damage)
	end)
	return PartTouched
end

function Lunge()
	Lunging = true
	local Target = InvokeClient("MousePosition")
	if not Target then
		return
	end
	local TargetPosition = Target.Position
	local Direction = (CFrame.new(Torso.Position, TargetPosition).lookVector * Vector3.new(1, 0, 1))
	Tool.Grip = Grips.Out
	Sounds.Lunge:Play()
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Create("StringValue"){
				Name = "toolanim",
				Value = "Lunge",
			}
			Debris:AddItem(Anim, 2)
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Lunge")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end
	local SwordFire = Fire:Clone()
	SwordFire.Enabled = true
	Debris:AddItem(SwordFire, 1.5)
	SwordFire.Parent = Handle
	Delay(1, (function()
		SwordFire.Enabled = false
	end))
	if Direction.Magnitude > 0.01 then
		Direction = Direction.Unit 
		local NewBV = Create("BodyVelocity"){
			P = 100000,
			maxForce = Vector3.new(100000, 0, 100000),
			velocity = (Direction * 50),
		}
		Debris:AddItem(NewBV, 0.75)
		NewBV.Parent = Torso
		Torso.CFrame = CFrame.new(Torso.Position, (TargetPosition * Vector3.new(1, 0, 1) + Vector3.new(0, Torso.Position.Y, 0)))
	end
	wait(0.75)
	Lunging = false 
	Tool.Grip = Grips.Up
	wait(0.5)
end

function Attack()		
	Tool.Grip = Grips.Up
	Sounds.Slash:Play()
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Create("StringValue"){
				Name = "toolanim",
				Value = "Slash",
			}
			Debris:AddItem(Anim, 2)
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Slash")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end
	Tool.Grip = Grips.Up
end

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 500, IgnoreList)
end

function BurnNearbyPlayers()
	local PlayersBurning = {}
	local function Burn()
		local HumanoidsHit = {}
		local PlayersNearby = {}
		local Radius = 20
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= Player and not Functions.IsTeamMate(Player, v) and v.Character and v.Character.Parent then
				local character = v.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
				if humanoid and humanoid.Health > 0 and torso then
					local DistanceApart = (Torso.Position - torso.Position).Magnitude
					if DistanceApart <= Radius then
						table.insert(HumanoidsHit, humanoid)
						table.insert(PlayersNearby, {Character = character, Humanoid = humanoid})
					end
				end
			end
		end
		local Region = Region3.new((Torso.Position - Vector3.new(Radius, Radius, Radius)), (Torso.Position + Vector3.new(Radius, Radius, Radius)))
		for i, v in pairs(GetNearbyObjects(Region)) do
			if v and v.Parent then
				local character = v.Parent
				if character ~= Character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
						local player = Players:GetPlayerFromCharacter(character)
						if not player or (player and not Functions.IsTeamMate(Player, player)) then
							if not Functions.CheckTableForInstance(HumanoidsHit, humanoid) then
								table.insert(HumanoidsHit, humanoid)
								table.insert(PlayersNearby, {Character = character, Humanoid = humanoid})
							end
						end
					end
				end
			end
		end
		for i, v in pairs(PlayersNearby) do
			local character = v.Character
			local humanoid = v.Humanoid
			local BurningIndex = nil
			for ii, vv in pairs(PlayersBurning) do
				if vv.Character == character then
					BurningIndex = ii
					break
				end
			end
			local Now = tick()
			local BurntTable = {Character = character, LastBurned = Now, BurnStart = Now}
			if BurningIndex then
				local PlayerIndex = PlayersBurning[BurningIndex]
				local LastBurnTime = (Now - PlayerIndex.LastBurned)
				BurntTable.BurnStart = PlayerIndex.BurnStart
				if BurntTable.BurnStart == 0 then
					BurntTable.BurnStart = Now
				end
				if LastBurnTime <= 1.5 then
					if (Now - PlayerIndex.BurnStart) > 1.5 then
						DealDamage(humanoid, (humanoid.MaxHealth * 0.002))
						for i, v in pairs(character:GetChildren()) do
							if v:IsA("BasePart") and v.Transparency < 1 then
								local FlameEffect = v:FindFirstChild(FireEffect.Name)
								if FlameEffect then
									local Duration = FlameEffect:FindFirstChild("Duration")
									if Duration then
										Duration.Value = 2
									end
								elseif not FlameEffect then
									local Flame = FireEffect:Clone()
									Flame.Enabled = true
									local Duration = Create("NumberValue"){
										Name = "Duration",
										Value = 2,
										Parent = Flame,
									}
									local ParticleScriptCopy = ParticleScript:Clone()
									ParticleScriptCopy.Disabled = false
									ParticleScriptCopy.Parent = Flame
									Flame.Parent = v
								end
							end
						end
					end
				else
					BurntTable.BurnStart = Now
				end
			end
			if BurningIndex then
				PlayersBurning[BurningIndex] = BurntTable
			else
				table.insert(PlayersBurning, BurntTable)
			end
		end
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	wait(1.5) --Prevents burn from being instant
	if BurnEffect then
		BurnEffect:disconnect()
	end
	BurnEffect = RunService.Stepped:connect(function(Time, Step)
		if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
			BurnEffect:disconnect()
			return
		end
		Burn()
		wait(0.25)
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false 
	local Time = RunService.Stepped:wait()
	if (Time - LastAttack) < 0.2 then
		Lunge()
	else
		Attack()
	end
	LastAttack = Time
	
	local SlashAnim = Create("Animation"){
		Name = "R15Slash",
		AnimationId = BaseUrl .. Animations.R15Slash,
		Parent = Tool
	}
	
	local LungeAnim = Create("Animation"){
		Name = "R15Lunge",
		AnimationId = BaseUrl .. Animations.R15Lunge,
		Parent = Tool
	}	
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		BurnNearbyPlayers()
	end)
	ToolEquipped = true
	Sounds.Unsheath:Play()
end

function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Down and Tool.Enabled then
			if Key == "q" then
				local Ability = Abilities.Bind
				if Ability.Enabled and not Ability.Active then
					Ability.Enabled = false
					Ability.Active = true
					wait(1.5)
					Ability.Active = false
					wait(Ability.ReloadTime)
					Ability.Enabled = true
				end
			end
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

Blow(Handle, SwordDamage)