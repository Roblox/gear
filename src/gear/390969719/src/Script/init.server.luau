--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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
	BaseDamage = 8,
	SlashDamage = 13,
	LungeDamage = 16,
	Bonus = 15,
}

--For R15 avatars
Animations = {
	R15Slash = 522635514,
	R15Lunge = 522638767
}

Damage = DamageValues.BaseDamage

BaseUrl = "http://www.roblox.com/asset/?id="

TixGui = script:WaitForChild("TixGui")

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

BaseTicket = BasePart:Clone()
BaseTicket.Name = "TicketEffect"
BaseTicket.BrickColor = BrickColor.new("Bright yellow")
BaseTicket.Material = Enum.Material.Plastic
BaseTicket.Size = Vector3.new(0.2, 0.6, 1.1)
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "383200694"),
	TextureId = (BaseUrl .. "383200798"),
	Scale = Vector3.new(1.25, 1.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseTicket,
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	ChaChing = Handle:WaitForChild("ChaChing"),
}

Grips = {
	Up = CFrame.new(0, 0.05, 1.5, 1, 0, -0, 0, 0, 1, 0, -1, 0),
	Out = CFrame.new(0, 0.05, 1.5, 1, 0, -0, 0, 1, 0, 0, 0, 1),
}

LastAttack = 0
TouchEvents = {}
Tickets = {Collected = 0, Required = 50}

ToolEquipped = false

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

function DealDamage(character, damage, apply)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local apply = ((apply == nil and true) or apply)
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		for i = 1, math.random(8, 16) do
			local Ticket = BaseTicket:Clone()
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = Ticket,
			}
			Ticket.CFrame = ((torso.CFrame * CFrame.new((math.random(-150, 150) * 0.01), (math.random(-150, 150) * 0.01), (math.random(-150, 150) * 0.01))) * CFrame.Angles(math.random(), math.random(), math.random()))
			Debris:AddItem(Ticket, 15)
			Ticket.Parent = game:GetService("Workspace")
		end
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
		if not humanoid or humanoid.Health == 0 or not torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		local DeterminedDamage = Damage
		local BonusDamagePercent = (Clamp(GetPercentage(0, 100, Tickets.Collected), 0, 100) * 0.01)
		local BonusDamage = (DamageValues.Bonus * BonusDamagePercent)
		DeterminedDamage = (DeterminedDamage + BonusDamage)
		HitDelay = true
		DealDamage(character, DeterminedDamage)
		wait(0.05)
		HitDelay = false
	end)
end

function Attack()
	Damage = DamageValues.SlashDamage
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
end

function Lunge()
	Damage = DamageValues.LungeDamage
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
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			TixGuiCopy = TixGui:Clone()
			local Count = TixGuiCopy.Frame.Count
			local function FixCount()
				Count.Text = ("x" .. Tickets.Collected)
			end
			FixCount()
			TixGuiCopy.Parent = PlayerGui
			for i, v in pairs(TouchEvents) do
				if v then
					v:disconnect()
				end
			end
			TouchEvents = {}
			for i, v in pairs(Character:GetChildren()) do
				if v:IsA("BasePart") and v.Transparency < 1 then
					local LimbTouched = v.Touched:connect(function(Hit)
						if not Hit or not Hit.Parent or not CheckIfAlive() then
							return
						end
						if Hit.Name == "TicketEffect" or Hit.Name == "RobuckEffect" then
							local Creator = Hit:FindFirstChild("Creator")
							if Creator and Creator.Value == Player then
								Tickets.Collected = (Tickets.Collected + ((Hit.Name == "RobuckEffect" and 10) or 1))
								if Tickets.Collected >= Tickets.Required then
									Humanoid.Health = (Humanoid.Health + 5)
								end
								FixCount()
								Hit:Destroy()
								local Sound = Sounds.ChaChing:Clone()
								Sound.Pitch = (math.random(950, 1225) * 0.001)
								Debris:AddItem(Sound, 1.5)
								Sound.Parent = Handle
								Sound:Play()
							end
						end
					end)
					table.insert(TouchEvents, LimbTouched)
				end
			end
		end
	end)
	ToolEquipped = true
	Sounds.Unsheath:Play()
end

function Unequipped()
	if TixGuiCopy and TixGuiCopy.Parent then
		TixGuiCopy:Destroy()
	end
	for i, v in pairs(TouchEvents) do
		if v then
			v:disconnect()
		end
	end
	TouchEvents = {}
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)