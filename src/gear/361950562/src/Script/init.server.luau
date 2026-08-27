--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Particles = Handle:WaitForChild("Particles")

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


InfernusModel = InsertService:LoadAsset(31101391)
Infernus = InfernusModel:GetChildren()[1]:Clone()
Debris:AddItem(InfernusModel, 1)

Damage = {
	Touch = {Min = 12, Max = 16},
	Slash = {Min = 15, Max = 19},
	Lunge = {Min = 18, Max = 23},
}

Gravity = 196.20

Functions = require(script:WaitForChild("Functions"))

DeathEffect = script:WaitForChild("DeathEffect")

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

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	Lunge = {Animation = Tool:WaitForChild("Lunge"), FadeTime = nil, Weight = nil, Speed = 1.75, Duration = 0.75},
	Toss = {Animation = Tool:WaitForChild("Toss"), FadeTime = nil, Weight = nil, Speed = 0.65, Duration = 0.75},
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Grips = {
	Up = CFrame.new(0, 0, 2.375, 1, 0, -0, 0, 0, 1, 0, -1, 0),
	Out = CFrame.new(0, 0, 2.375, 1, 0, -0, 0, 1, 0, 0, 0, 1),
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

LastAttack = 0

Specials = {
	Throw = {
		Key = "Z",
		ReloadTime = 20,
		Enabled = true,
		Active = false,
	},
	Reach = {
		Key = "X",
		ReloadTime = 5,
		Enabled = true,
		Active = false,
	},
	Transport = {
		Key = "V",
		ReloadTime = 5,
		Enabled = true,
		Active = false,
	},
}

AttackMode = "Idle"
Throwing = false
ToolEquipped = false

Handle.Transparency = 0
Particles.Enabled = true
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

function DealDamage(character, damage, apply)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local apply = ((apply == nil and true) or apply)
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		local character = humanoid.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			Humanoid.Health = (Humanoid.Health + (Humanoid.MaxHealth * ((CheckIfWearingDominus() and 0.35) or 0.15)))
		end
		if apply then
			local HitOrigin = (((Throwing and Sword and Sword.Parent) and Sword) or Torso)
			local WindDir = (CFrame.new(Torso.Position, Vector3.new(torso.Position.X, Torso.Position.Y, torso.Position.Z)) * CFrame.Angles(0, math.pi, 0)).lookVector
			ApplyDeathEffect(character, Vector3.new(WindDir.X, 1, WindDir.Z), ((WindDir * 6.5) + Vector3.new(0, 15, 0)))
		end
	end
end

function CheckIfWearingDominus()
	return Character:FindFirstChild(Infernus.Name)
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
	DealDamage(character, 0, false)
	DeathEffectCopy = DeathEffect:Clone()
	DeathEffectCopy.WindDirection.Value = Direction
	DeathEffectCopy.Force.Value = Force
	DeathEffectCopy.Disabled = false
	DeathEffectCopy.Parent = character
end

function TweenNumber(Start, Goal, Time)
	return ((Goal - Start) / Time)
end

function MimicFadeEffect(Position)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Parts = {}
	local FakeParts = {}
	local CharacterMeshes = {}
	for i, v in pairs(Functions.GetAllConnectedParts(Torso)) do
		if v:IsA("BasePart") and v.Transparency < 1 then
			table.insert(Parts, v)
		end
	end
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("CharacterMesh") then
			table.insert(CharacterMeshes, v)
		end
	end
	local FadeModel = Create("Model"){
		Name = "RedFadeEffect",		
	}
	for i, v in pairs(Parts) do
		local NewPart = v:Clone()
		for ii, vv in pairs(NewPart:GetChildren()) do
			if not vv:IsA("DataModelMesh") then
				vv:Destroy()
			elseif vv:IsA("DataModelMesh") then
				vv.TextureId = ""
			end
		end
		for ii, vv in pairs(CharacterMeshes) do
			if string.lower(string.gsub(NewPart.Name, " ", "")) == string.lower(vv.BodyPart.Name) then
				local Mesh = Create("SpecialMesh"){
					Name = "Mesh",
					MeshId = (BaseUrl .. vv.MeshId),
					TextureId = "",
					Scale = Vector3.new(1, 1, 1),
					VertexColor = Vector3.new(1, 1, 1),
					Offset = Vector3.new(0, 0, 0),
					Parent = NewPart,
				}
				break
			end
		end
		if NewPart.Name == "Torso" then
			FadeModel.PrimaryPart = NewPart
		end
		NewPart.Name = "Part"
		NewPart.BrickColor = BrickColor.new("Really red")
		NewPart.Material = Enum.Material.Plastic
		NewPart.TopSurface = Enum.SurfaceType.Smooth
		NewPart.BottomSurface = Enum.SurfaceType.Smooth
		NewPart.LeftSurface = Enum.SurfaceType.Smooth
		NewPart.RightSurface = Enum.SurfaceType.Smooth
		NewPart.FrontSurface = Enum.SurfaceType.Smooth
		NewPart.BackSurface = Enum.SurfaceType.Smooth
		NewPart.Reflectance = 0
		NewPart.Transparency = 0.75
		NewPart.CanCollide = false
		NewPart.Anchored = true
		NewPart.CFrame = v.CFrame
		table.insert(FakeParts, NewPart)
		NewPart.Parent = FadeModel
	end
	Spawn(function()
		local Start = 0.75
		local End = 1
		local Time = 0.75
		local Rate = (1 / 30)
		local Frames = (Time / Rate)
		for i = 1, Frames do
			local Transparency = (Start + TweenNumber(Start, End, (Frames / (i + 1))))
			for ii, vv in pairs(FakeParts) do
				if vv and vv.Parent then
					vv.Transparency = Transparency
				end
			end
			wait(Rate)
		end
	end)
	Debris:AddItem(FadeModel, 3)
	FadeModel.Parent = game:GetService("Workspace")
	if Position then
		Functions.TransformModel(FadeModel, FadeModel:GetModelCFrame(), Position, true)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function MakeVisible(Boolean)
	Handle.Transparency = ((Boolean and 0) or 1)
	Particles.Enabled = Boolean
end

function Throw(TargetPos)
	
	Throwing = true
	
	local StartPos = Handle.CFrame
	local Direction = CFrame.new(StartPos.p, TargetPos)
	local Force = 50
	
	Sword = Handle:Clone()
	Sword.Name = "Sword"
	Sword.Transparency = 0
	Sword.Friction = 2
	Sword.Elasticity = 0
	Sword.CanCollide = true
	
	local Mass = (Sword:GetMass() * Gravity)	
	
	Sword.Velocity = (Direction.lookVector * Force)
	Sword.CFrame = (Direction + Direction.lookVector * (Sword.Size.Z * 1.25))
	local StartPosition = (Handle.CFrame + Handle.CFrame.lookVector * Handle.Size.Z).p
	local Direction = CFrame.new(StartPosition, TargetPos)
	Sword.CanCollide = true
	local Mass = (Sword:GetMass() * Gravity)
	local Force = 300
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = (Direction.lookVector * Force),
		Parent = Sword,
	}
	BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
		Parent = Sword,
	}
	Sword.CFrame = CFrame.new(StartPosition, TargetPos)
	Sword.Velocity = (Direction.lookVector * Force)
	MakeVisible(false)
	Debris:AddItem(Sword, 5)
	Sword.Parent = game:GetService("Workspace")
	local Repelling = Create("BoolValue"){
		Value = false,
	}
	local StartPosition = Sword.Position
	local AlreadyHit = false
	local function PartHit(Part, Hit)
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
		if humanoid then
			if humanoid.Health > 0 then
				DealDamage(character, 100)
			end
		else
			Repelling.Value = true
			return true
		end
	end
	local function CheckHit(Hit)
		local Directions = {{Vector = Sword.Velocity.Unit, Length = 3}, {Vector = Vector3.new(0, -1, 0), Length = 1.5}, ((Hit and {Vector = CFrame.new(Sword.Position, Hit.Position).lookVector, Length = 3}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			local Direction = CFrame.new(Sword.Position, (Sword.CFrame + v.Vector * 2).p).lookVector
			local RayHit, RayPos, RayNormal = Functions.CastRay((Sword.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {Character, Sword}, false)
			if RayHit then
				local DistanceApart = (Sword.Position - RayPos).Magnitude
				if DistanceApart < ClosestRay.DistanceApart then
					ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
				end
			end
		end
		return ClosestRay
	end
	local function ManageHit(Hit)
		local ClosestRay = CheckHit(Hit)
		if ClosestRay and ClosestRay.Hit then
			if AlreadyHit then
				return
			end
			local SuccessfullyHit = PartHit(Sword, ClosestRay.Hit)
			if SuccessfullyHit then
				AlreadyHit = true
			end
			--local PartCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
			--PartCFrame = (PartCFrame * CFrame.new(0, -(Sword.Size.Y / 1.5), 0))
			--PartCFrame = (CFrame.new(PartCFrame.p, Handle.Position) * CFrame.Angles(0, math.pi, 0))
			Repelling.Value = true
		end
	end
	Sword.Touched:connect(function(Hit)
		if AlreadyHit then
			return
		end
		ManageHit(Hit)
	end)
	while CheckIfAlive() and ToolEquipped and Sword and Sword.Parent and Sword.Name ~= "Effect" and Sword.Velocity.Magnitude > 2 and not Repelling.Value do
		local DistanceApart = (StartPosition - Sword.Position).Magnitude
		ManageHit()
		if DistanceApart > 300 then
			Repelling.Value = true
			break
		end
		wait()
	end
	if Sword and Sword.Parent then
		Repelling.Value = true
	end
	if Repelling.Value then
		local Direction = CFrame.new(Sword.Position, Handle.Position)
		Sword.CFrame = Direction
		while CheckIfAlive() and ToolEquipped and Sword and Sword.Parent and Sword.Name ~= "Effect" and Repelling.Value do
			local DistanceApart = (Handle.Position - Sword.Position).Magnitude
			if DistanceApart <= 3 then
				Sword.Name = "Effect"
				Sword.Transparency = 1
				Sword.CanCollide = false
				Sword.Anchored = true
				if Sword and Sword.Parent then
					Sword:Destroy()
				end
			else
				Direction = CFrame.new(Sword.Position, Handle.Position)
				local Force = 200
				local Velocity = (Direction.lookVector * Force)
				Sword.Velocity = Velocity
				BodyGyro.cframe = Direction
			end
			wait()
		end
	end
	if Sword and Sword.Parent then
		Sword:Destroy()
	end
	MakeVisible(true)
	Throwing = false
end

function Blow(Part)
	local PartTouched
	local HitDelay = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDelay or Throwing then
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
		local torso = character:FindFirstChild("Torso")
		if not humanoid or humanoid.Health == 0 or not torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		local DamageAmount = ((AttackMode == "Slash" and Damage.Slash) or (AttackMode == "Lunge" and Damage.Lunge) or Damage.Touch)
		local DamageDetermined = (math.random((DamageAmount.Min * 1000), (DamageAmount.Max * 1000)) * 0.001)
		DealDamage(character, DamageDetermined)
		HitDelay = false
	end)
end

function Lunge()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	AttackMode = "Lunge"
	local Lunging = true
	local TargetPosition = MouseData.Position
	local Direction = (CFrame.new(Torso.Position, TargetPosition).lookVector * Vector3.new(1, 0, 1))
	Tool.Grip = Grips.Out
	Sounds.Lunge:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Lunge)
	end)
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
	Spawn(function()
		while Lunging and ToolEquipped and CheckIfAlive() do
			MimicFadeEffect()
			wait(1 / 30)
		end
	end)
	wait(0.75)
	Tool.Grip = Grips.Up
	wait(0.5)
	Lunging = false
	if AttackMode == "Lunge" then
		AttackMode = "Idle"
	end
end

function Slash()
	AttackMode = "Slash"
	local PossibleAnimations = {Animations.LeftSlash, Animations.RightSlash, Animations.Slash}
	local Animation = PossibleAnimations[math.random(1, #PossibleAnimations)]
	Sounds.Slash:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait((Animation.Duration > 0.5 and Animation.Duration) or 0.5)
	if AttackMode == "Slash" then
		AttackMode = "Idle"
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or Throwing then
		return
	end
	Tool.Enabled = false 
	local Time = RunService.Stepped:wait()
	if (Time - LastAttack) < 0.2 then
		Lunge()
	elseif AttackMode == "Idle" then
		Spawn(Slash)
	end
	LastAttack = Time
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.Unsheath:Play()
	Spawn(function()
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
			ToolUnequipped:disconnect()
		end)
		if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
			while ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
				if CheckIfWearingDominus() then
					local TorsoSpeed = Torso.Velocity.Magnitude
					if TorsoSpeed >= 5 then
						MimicFadeEffect()
					end
				end
				wait(0.5)
			end
		end
	end)
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
	if Mode == "KeyPressed" then
		local Key = Value.Key
		local Down = Value.Down
		if not Down then
			return
		end
		local MouseData = InvokeClient("MouseData")
		if not MouseData or not MouseData.Position or not ToolEquipped or not CheckIfAlive() then
			return
		end
		if Key == "" then
		else
			for i, v in pairs(Specials) do
				if Key == string.lower(v.Key) then
					if not v.Enabled or v.Active then
						return
					end
					v.Enabled = false
					v.Active = true
					if v == Specials.Toss then
					elseif v == Specials.Throw then
						Tool.Enabled = false
						local Animation = Animations.Throw
						Spawn(function()
							InvokeClient("PlayAnimation", Animation)
						end)
						wait(Animation.Duration)
						Throw(MouseData.Position)
						Tool.Enabled = true
					elseif v == Specials.Transport and CheckIfWearingDominus() then
						local StartPosition = Torso.CFrame
						for i = 1, 100 do
							if not ToolEquipped or not CheckIfAlive() then
								return
							end
							local Offset = (Torso.Position + Vector3.new(0, 5, 0))
							local Radius = 50
							Radius = (Radius * 1000)
							local RandomOffset = (Offset + (Vector3.new(math.random(-Radius, Radius), 0, math.random(-Radius, Radius)) * 0.001))
							local RayHit, RayPos, RayNormal, RayMaterial = Functions.CastRay(RandomOffset, Vector3.new(0, -1, 0), (Torso.Size.Y * 10), {Character})
							if RayHit then
								Torso.CFrame = ((CFrame.new(RayPos) + Vector3.new(0, (Torso.Size.Y * 2), 0)) * CFrame.Angles(Torso.CFrame:toEulerAnglesXYZ()))
								local EndPosition = Torso.CFrame
								local DistanceApart = (StartPosition.p - EndPosition.p).Magnitude
								local Direction = CFrame.new(StartPosition.p, EndPosition.p)
								for ii = 1, math.floor(DistanceApart / 3) do
									MimicFadeEffect(CFrame.new((Direction + Direction.lookVector * (ii * 3)).p) * CFrame.Angles(Torso.CFrame:toEulerAnglesXYZ()))
								end
								break
							end
						end
					elseif v == Specials.Reach and Specials.Throw.Active and Throwing then
						if Throwing and Sword and Sword.Parent then
							local StartPosition = Torso.CFrame
							local EndPosition = Sword.CFrame
							local DistanceApart = (StartPosition.p - EndPosition.p).Magnitude
							local Direction = CFrame.new(StartPosition.p, EndPosition.p)
							for ii = 1, math.floor(DistanceApart / 6) do
								MimicFadeEffect(CFrame.new((Direction + Direction.lookVector * (ii * 6)).p) * CFrame.Angles(Torso.CFrame:toEulerAnglesXYZ()))
							end
							if Sword and Sword.Parent then
								Sword:Destroy()
							end
							Torso.CFrame = (EndPosition * CFrame.Angles(Torso.CFrame:toEulerAnglesXYZ()))
						end
					end
					v.Active = false
					wait(v.ReloadTime)
					v.Enabled = true
				end
			end
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)