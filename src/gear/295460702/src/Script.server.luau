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

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 8, Duration = 0.25},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 8, Duration = 0.25},
	DoubleSlash = {Animation = Tool:WaitForChild("DoubleSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	CatScream = Handle:WaitForChild("CatScream"),
}

Gravity = 196.20

SlashDamage = 15

Clicks = 0
FirstClick = false
SoundDelay = false
Lunging = false
ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

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

function Lunge(MousePosition)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, 0, Mass),
		velocity = (Direction.lookVector * 100),
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
	}
	for i, v in pairs({BodyVelocity, BodyGyro}) do
		Debris:AddItem(v, 0.5)
		v.Parent = Torso
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		if (not (LeftPaw and LeftPaw.Parent) and not (RightPaw and RightPaw.Parent)) then
			return
		end
		Tool.Enabled = false
		local SingleClickAnims = {}
		local DoubleClickAnims = {}
		local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
		local Lungable = false
		if ((LeftPaw and LeftPaw.Parent) and (RightPaw and RightPaw.Parent)) and not Lunging then
			Lunging = true
			Lungable = true
			table.insert(DoubleClickAnims, Animations.DoubleSlash)
			Delay(2, (function()
				Lunging = false
			end))
		end
		for i, v in pairs({LeftPaw, RightPaw}) do
			if v and v.Parent then
				table.insert(SingleClickAnims, ((v == LeftPaw and Animations.LeftSlash) or Animations.RightSlash))
			end
		end
		SlashSounds[math.random(1, #SlashSounds)]:Play()
		AnimationChosen = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		Spawn(function()
			InvokeClient("PlayAnimation", AnimationChosen)
		end)
		if Clicks >= 2 and Lungable then
			Spawn(function()
				local MousePosition = InvokeClient("MousePosition")
				if MousePosition then
					Lunge(MousePosition.Position)
				end
			end)
		end
		wait(AnimationChosen.Duration)
		Spawn(function()
			InvokeClient("StopAnimation", AnimationChosen)
		end)
		AnimationChosen = nil
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function PartTouched(Table)
	local Part = Table.Part
	local Animation = Table.Animation
	if not Part or not Animation then
		return
	end
	local TouchedConnection
	TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or (AnimationChosen ~= Animations.DoubleSlash and AnimationChosen ~= Animation) then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player == Player or IsTeamMate(Player, player) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local HealthAfter = (humanoid.Health - SlashDamage)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(SlashDamage)
		if HealthAfter <= 0 and not SoundDelay then
			SoundDelay = true
			Spawn(function()
				local Sound = Sounds.CatScream:Clone()
				Debris:AddItem(Sound, 2)
				Sound.Parent = Handle
				Sound:Play()
				wait(2)
				SoundDelay = false
			end)
		end
	end)
end

function EquipPaws(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local Paw = BasePart:Clone()
	Paw.Name = "Paw"
	Paw.Transparency = 0
	Paw.Size = Vector3.new(1.25, 1.85, 1.25)
	Paw.CanCollide = false
	local Mesh = Create("SpecialMesh"){
		TextureId = (BaseUrl .. "287439050"),
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1.25, 1.25, 1.25),
		Parent = Paw,
	}
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if LeftArm then
		LeftPaw = Paw:Clone()
		LeftPaw.Name = "LeftPaw"
		LeftPaw.Mesh.MeshId = (BaseUrl .. "287438965")
		local Weld = Create("Weld"){
			Part0 = LeftArm,
			Part1 = LeftPaw,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (CFrame.new(0, 0.75, -0.9, -1, 8.9011528e-006, 0, 0, 0, 1, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)),
			Parent = LeftPaw,
		}
		LeftClaw = Paw:Clone()
		LeftClaw.Name = "LeftClaw"
		LeftClaw.Size = Vector3.new(0.5, 1, 1.5)
		LeftClaw.Mesh.MeshId = (BaseUrl .. "287438918")
		local Weld = Create("Weld"){
			Part0 = LeftPaw,
			Part1 = LeftClaw,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (CFrame.new(0.05, 0.05, 0.9, -1, 8.9011528e-006, 0, 0, 0, 1, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)),
			Parent = LeftPaw,
		}
		PartTouched({Part = LeftPaw, Animation = Animations.LeftSlash})
		LeftPaw.Parent = Tool
		LeftClaw.Parent = Tool
	end
	if RightArm then
		RightPaw = Paw:Clone()
		RightPaw.Name = "RightPaw"
		RightPaw.Mesh.MeshId = (BaseUrl .. "287438941")
		local Weld = Create("Weld"){
			Part0 = RightArm,
			Part1 = RightPaw,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (CFrame.new(0, 0.75, -0.9, -1, 8.9011528e-006, 0, 0, 0, 1, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)),
			Parent = RightPaw,
		}
		RightClaw = Paw:Clone()
		RightClaw.Name = "RightClaw"
		RightClaw.Size = Vector3.new(0.5, 1, 1.5)
		RightClaw.Mesh.MeshId = (BaseUrl .. "287438840")
		local Weld = Create("Weld"){
			Part0 = RightPaw,
			Part1 = RightClaw,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (CFrame.new(0.05, 0.05, 0.9, -1, 8.9011528e-006, 0, 0, 0, 1, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)),
			Parent = RightPaw,
		}
		PartTouched({Part = RightPaw, Animation = Animations.RightSlash})
		RightPaw.Parent = Tool
		RightClaw.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		Sounds.Unsheath:Play()
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Equip)
		end)
		Handle.Transparency = 1
		EquipPaws(true)
		ToolEquipped = true
	end)
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = 0
	Spawn(function()
		EquipPaws(false)
	end)
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
	if player ~= Player or not CheckIfAlive() or not ToolEquipped or not Mode or not Value then
		return
	end
end

EquipPaws(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)