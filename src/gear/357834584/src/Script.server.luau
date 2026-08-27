--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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


Rate = (1 / 60)
Gravity = 196.20

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

Animations = {}

Sounds = {
	Blast = Handle:WaitForChild("Blast"),
	Hit = Handle:WaitForChild("Hit"),
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

OrbMaxChargeTime = 10
OrbSize = {Min = 1.25, Max = 3}

OrbPresent = false
ControllingOrb = false
ToolEquipped = false

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

function ToggleHandleVisibility(Visible, Fade)
	if not Fade then
		Handle.Transparency = ((Visible and 0) or 1)
	else
		Spawn(function()
			TweenNumber(Handle, "Transparency", (Visible and 0 or 1), 1)
		end)
	end
	for i, v in pairs(Handle:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") then
			v.Enabled = Visible
		end
	end
	if Visible then
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v ~= Handle then
				v:Destroy()
			end
		end
	end
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function TweenNumber(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = ((Goal - Object[Property]) / Time)
	for i = 1, Time do
		Object[Property] = (Object[Property] + Increment)
		wait(Rate)
	end
	return true
end

function DecayOrb(CurrentOrb)
	for i, v in pairs(CurrentOrb:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") then
			v.Enabled = false
		end
	end
	Spawn(function()
		TweenNumber(CurrentOrb, "Transparency", 1, 1)
	end)
end

function PoisonOrb(CurrentOrb)
	local HitDelay = false
	Orb.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or HitDelay then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		if CurrentOrb:FindFirstChild("Powered") then
			local OrbDamage = {Min = 15, Max = 75}
			local OrbSizePercent = (Clamp(GetPercentage(OrbSize.Min, OrbSize.Max, Orb.Size.X), 0, 100) * 0.01)
			local OrbDamage = Clamp((OrbDamage.Max * OrbSizePercent), OrbDamage.Min, OrbDamage.Max)
			humanoid:TakeDamage(OrbDamage)
		else
			humanoid:TakeDamage(10)
		end
		wait(0.1)
		HitDelay = false
	end)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if not OrbPresent then
		OrbPresent = true
		ControllingOrb = true
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
			ToolUnequipped:disconnect()
		end)
		ToggleHandleVisibility(true)
		Orb = BaseOrb:Clone()
		Orb.CFrame = Handle.CFrame
		PoisonOrb(Orb)
		local Mass = (Orb:GetMass() * Gravity * 100)
		BodyPosition = Create("BodyPosition"){
			maxForce = Vector3.new(Mass, Mass, Mass),
			position = Orb.CFrame.p,
			Parent = Orb,
		}
		BodyAngularVelocity = Create("BodyAngularVelocity"){
			maxTorque = Vector3.new(Mass, Mass, Mass),
			angularvelocity = Vector3.new((math.random() * 2), (math.random() * 2), (math.random() * 2)),
			Parent = Orb,
		}
		ToggleHandleVisibility(false)
		Orb.Parent = Tool
		Spawn(function()
			local OrbParticles = {}
			for i, v in pairs(Orb:GetChildren()) do
				if v:IsA("SpecialMesh") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("ParticleEmitter") then
					table.insert(OrbParticles, {Original = v:Clone(), Current = v})
				end
			end
			local StartTick = tick()
			while ControllingOrb and ToolEquipped and CurrentlyEquipped and CheckIfAlive() and Orb and Orb.Parent do
				local CalculatedCharge = Clamp((tick() - StartTick), 0, OrbMaxChargeTime)
				local ChargePercent = (Round((GetPercentage(0, OrbMaxChargeTime, CalculatedCharge)), 0.5) * 0.01)
				local ChargeSize = Clamp((OrbSize.Max * ChargePercent), OrbSize.Min, OrbSize.Max)
				if ChargeSize ~= Orb.Size.X then
					local OrbCF = Orb.CFrame
					Orb.Size = Vector3.new(ChargeSize, ChargeSize, ChargeSize)
					for i, v in pairs(OrbParticles) do
						if v.Original:IsA("SpecialMesh") and v.Current.MeshType == Enum.MeshType.FileMesh then
							v.Current.Scale = (v.Original.Scale * (ChargeSize * 0.75))
						elseif v.Original:IsA("Fire") or v.Original:IsA("Smoke") then
							v.Current.Size = (v.Original.Size * (ChargeSize * 1))
						elseif v.Original:IsA("ParticleEmitter") then
							local OriginalSize = v.Original.Size.Keypoints[1].Value
							v.Current.Size = NumberSequence.new((OriginalSize * (ChargeSize * 1)))
						end
					end
					local Mass = (Orb:GetMass() * Gravity * 100)
					BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
					BodyAngularVelocity.maxTorque = Vector3.new(Mass, Mass, Mass)
					Orb.CFrame = OrbCF
				end
				Spawn(function()
					MouseData = InvokeClient("MouseData")
					if MouseData and MouseData.Position then
						local StartPos = Handle.Position
						local TargetPos = MouseData.Position
						local TargetDirection = CFrame.new(StartPos, TargetPos)
						local TargetDistance = (StartPos - TargetPos).Magnitude
						if TargetDistance > 10 then
							TargetDistance = 10
						end
						local DesiredPos = (StartPos + TargetDirection.lookVector * TargetDistance)
						BodyPosition.position = DesiredPos
					end
				end)
				wait()
			end
			ControllingOrb = false
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
				DecayOrb(Orb)
				ToggleHandleVisibility(true, true)
			end
		end)
		wait(2)
	else
		if OrbPresent then
			ControllingOrb = false
			if Orb and Orb.Parent then
				if BodyPosition and BodyPosition.Parent then
					BodyPosition:Destroy()
				end
				if not MouseData then
					MouseData = InvokeClient("MouseData")
				end
				local ThisOrb = Orb
				if MouseData and MouseData.Position then
					local Powered = Create("StringValue"){
						Name = "Powered",
						Parent = Orb,
					}
					Sounds.Blast:Play()
					local Mass = (Orb:GetMass() * Gravity)
					local BodyVelocity = Create("BodyForce"){
						force = Vector3.new(0, Mass, 0),
						Parent = Orb,
					}
					local Force = 100
					local StartPos = Orb.Position
					local TargetPos = MouseData.Position
					local TargetDirection = CFrame.new(StartPos, TargetPos)
					local DesiredVelocity = (TargetDirection.lookVector * Force)
					local OrbCF = Orb.CFrame
					Debris:AddItem(Orb, 5)
					Delay(1, (function()
						DecayOrb(ThisOrb)
					end))
					Orb.Parent = game:GetService("Workspace")
					Orb.CFrame = OrbCF
					Orb.Velocity = DesiredVelocity
				else
					DecayOrb(ThisOrb)
				end
			end
			OrbPresent = false
		end
		wait(3)
		ToggleHandleVisibility(true, true)
		wait(2)
	end
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
	OrbPresent = false
	ControllingOrb = false
	ToolEquipped = true
end

function Unequipped()
	OrbPresent = false
	ControllingOrb = false
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

ToggleHandleVisibility(true)

BaseOrb = Handle:Clone()
BaseOrb.Name = "Orb"
BaseOrb.CanCollide = false

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)