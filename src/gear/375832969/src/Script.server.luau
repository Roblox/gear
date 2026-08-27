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


Damage = {
	Idle = {Min = 8, Max = 8},
	Slash = {Min = 14, Max = 18},
	Lunge = {Min = 18, Max = 26},
}

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

BaseSword = BasePart:Clone()
BaseSword.Name = "Sword"
BaseSword.Size = Vector3.new(0.2, 0.2, 0.2)
BaseSword.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = "",
	TextureId = (BaseUrl .. "371986827"),
	Scale = Vector3.new(0.6, 0.6, 0.6),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseSword,
}

SwordPiece = BasePart:Clone()
SwordPiece.Name = "Blade"
SwordPiece.Transparency = 1
SwordPiece.Size = Vector3.new(0.2, 0.65, 3)
SwordPiece.CanCollide = false
Create("Weld"){
	Name = "Weld",
	Part0 = BaseSword,
	Part1 = SwordPiece,
	C0 = (CFrame.new(0, -0.65, 0.5) * CFrame.Angles((math.pi / 4.5), 0, 0)),
	C1 = CFrame.new(0, 0, 0),
	Parent = SwordPiece,
}
SwordPiece.Parent = BaseSword

BaseLeftSword = BaseSword:Clone()
BaseLeftSword.Mesh.MeshId = (BaseUrl .. "371986573")

BaseRightSword = BaseSword:Clone()
BaseRightSword.Mesh.MeshId = (BaseUrl .. "371986683")

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.5, Duration = 1.5},
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.25, Weight = nil, Speed = nil, Duration = nil},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.25},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.25},
	DualSlash = {Animation = Tool:WaitForChild("DualSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
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
AttackMode = "Idle"

SwordsEquipped = false
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

function Blow(Part)
	local PartTouched
	local HitDelay = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDelay then
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
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		local DamageType = ((AttackMode == "Slash" and Damage.Slash) or (AttackMode == "Lunge" and Damage.Lunge) or Damage.Idle)
		local DamageDetermined = (math.random((DamageType.Min * 1000), (DamageType.Max * 1000)) * 0.001)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(DamageDetermined)
		wait(0.1)
		HitDelay = false
	end)
end

function Slash()
	local PossibleAnimations = {Animations.LeftSlash, Animations.RightSlash}
	local Animation = PossibleAnimations[math.random(1, #PossibleAnimations)]
	Sounds.Slash:Play()
	AttackMode = "Slash"
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait((Animation.Duration > 0.5 and Animation.Duration) or 0.5)
	if AttackMode == "Slash" then
		AttackMode = "Idle"
	end
end

function Attack()
	local Time = RunService.Stepped:wait()
	if (Time - LastAttack) < 0.2 then
		Lunge()
	else
		Spawn(Slash)
	end
	LastAttack = Time
end
	
function Lunge()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	local TargetPosition = MouseData.Position
	local Direction = (CFrame.new(Torso.Position, TargetPosition).lookVector * Vector3.new(1, 0, 1))
	AttackMode = "Lunge"
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.DualSlash)
	end)
	local Fire = Create("Fire"){
		Name = "Fire",
		Color = Color3.new((0 / 255), (170 / 255), (0 / 255)),
		SecondaryColor = Color3.new((0 / 255), (255 / 255), (0 / 255)),
		Heat = 9,
		Size = 5,
		Enabled = true,
	}
	Debris:AddItem(Fire, 2)
	Fire.Parent = Torso
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
	if AttackMode == "Lunge" then
		AttackMode = "Idle"
	end
	Fire.Enabled = false
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if not SwordsEquipped then
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		local Animation = Animations.Equip
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Equip)
		end)
		wait((Animation.Duration / 4) * 0.5)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if CurrentlyEquipped then
			Sounds.Unsheath:Play()
			EquipSwords()
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.Hold)
			end)
			SwordsEquipped = true
		end
	else
		Attack()
	end
	Tool.Enabled = true
end

function SetUpSwordPack(CreateNew)
	Handle.Transparency = ((CreateNew and 1) or 0)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	SwordPack = BasePart:Clone()
	SwordPack.Name = "SwordPack"
	SwordPack.CanCollide = false
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "371986862"),
		TextureId = (BaseUrl .. "371986827"),
		Scale = Vector3.new(0.6, 0.6, 0.6),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = SwordPack,
	}
	Create("Weld"){
		Name = "Weld",
		Part0 = Torso,
		Part1 = SwordPack,
		C0 = CFrame.new(0, 0.25, 0.65),
		C1 = CFrame.new(0, 0, 0),
		Parent = SwordPack,
	}
	SwordPack.Parent = Tool
end

function EquipSwords()
	if SwordPack and SwordPack.Parent then
		SwordPack:Destroy()
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if LeftArm then
		LeftSword = BaseLeftSword:Clone()
		local LeftWeld = Create("Weld"){
			Name = "Weld",
			Part0 = LeftArm,
			Part1 = LeftSword,
			C0 = (CFrame.new(0, -1.15, -1.5) * CFrame.Angles((math.pi / 6), math.pi, (math.pi * 2))),
			C1 = CFrame.new(0, 0, 0),
			Parent = LeftSword,
		}
		Blow(LeftSword.Blade)
		LeftSword.Parent = Tool
	end
	if RightArm then
		RightSword = BaseRightSword:Clone()
		local RightWeld = Create("Weld"){
			Name = "Weld",
			Part0 = RightArm,
			Part1 = RightSword,
			C0 = (CFrame.new(0, -1.15, -1.5) * CFrame.Angles((math.pi / 6), math.pi, (math.pi * 2))),
			C1 = CFrame.new(0, 0, 0),
			Parent = RightSword,
		}
		Blow(RightSword.Blade)
		RightSword.Parent = Tool
	end
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
	SwordsEquipped = false
	AttackMode = "Idle"
	Spawn(function()
		SetUpSwordPack(true)
	end)
end

function Unequipped()
	SetUpSwordPack(false)
	AttackMode = "Idle"
	SwordsEquipped = false
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

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)