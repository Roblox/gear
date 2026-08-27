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


Handle.Transparency = 0
Tool.Enabled = true

LastAttack = 0
Slashing = false
Debounce = false
ToolEquipped = false

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

Sounds = {
	Slash = Handle:WaitForChild("Slash")
}

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), Weight = nil, FadeTime = nil, Speed = 1},
	Equip = {Animation = Tool:WaitForChild("Equip"), Weight = nil, FadeTime = nil, Speed = 1},
}

SkeletonRemains = {
	["Head"] = {MeshId = "4770583", TextureId = "36869975", Scale = Vector3.new(3, 3, 3)},
	["Torso"] = {MeshId = "36780113", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	["Left Arm"] = {MeshId = "36780032", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	["Right Arm"] = {MeshId = "36780156", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	["Left Leg"] = {MeshId = "36780079", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
	["Right Leg"] = {MeshId = "36780195", TextureId = "36780292", Scale = Vector3.new(1, 1, 1)},
}

BaseUrl = "http://www.roblox.com/asset/?id="

NPCScripts = script:WaitForChild("NPCScripts")

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

function MakeNPCMinion(Table)
	local HumanoidProperties = (Table.HumanoidProperties or {})
	local Values = (Table.Values or {})
	local Limbs = {
		["Head"] = {Properties = {BrickColor = BrickColor.new("Bright yellow"), Size = Vector3.new(2, 1, 1),}},
		["HumanoidRootPart"] = {Properties = {BrickColor = BrickColor.new("Bright blue"), Transparency = 1, Size = Vector3.new(2, 2, 1),},},
		["Torso"] = {Properties = {BrickColor = BrickColor.new("Bright blue"), Size = Vector3.new(2, 2, 1),},},
		["Left Arm"] = {Properties = {BrickColor = BrickColor.new("Bright yellow"), Size = Vector3.new(1, 2, 1),},},
		["Right Arm"] = {Properties = {BrickColor = BrickColor.new("Bright yellow"), Size = Vector3.new(1, 2, 1),},},
		["Left Leg"] = {Properties = {BrickColor = BrickColor.new("Br. yellowish green"), Size = Vector3.new(1, 2, 1),},},
		["Right Leg"] = {Properties = {BrickColor = BrickColor.new("Br. yellowish green"), Size = Vector3.new(1, 2, 1),},},
	}
	local Joints = {
		["RootJoint"] = {Parent = "HumanoidRootPart", Part0 = "HumanoidRootPart", Part1 = "Torso", Properties = {C0 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0), C1 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
		["Neck"] = {Parent = "Torso", Part0 = "Torso", Part1 = "Head", Properties = {C0 = CFrame.new(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0), C1 = CFrame.new(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
		["Left Shoulder"] = {Parent = "Torso", Part0 = "Torso", Part1 = "Left Arm", Properties = {C0 = CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), C1 = CFrame.new(0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
		["Right Shoulder"] = {Parent = "Torso", Part0 = "Torso", Part1 = "Right Arm", Properties = {C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
		["Left Hip"] = {Parent = "Torso", Part0 = "Torso", Part1 = "Left Leg", Properties = {C0 = CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), C1 = CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
		["Right Hip"] = {Parent = "Torso", Part0 = "Torso", Part1 = "Right Leg", Properties = {C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), MaxVelocity = 0.1, DesiredAngle = 0, CurrentAngle = 0}},
	}
	local Misc = {
		{Class = "Decal", Parent = "Head", Properties = {Name = "face", Texture = (BaseUrl .. "144080495"), Shiny = 20, Specular = 0, Transparency = 0, Face = Enum.NormalId.Front}},
		{Class = "Decal", Parent = "Torso", Properties = {Name = "roblox", Texture = "", Shiny = 20, Specular = 0, Transparency = 0, Face = Enum.NormalId.Front}},
		{Class = "SpecialMesh", Parent = "Head", Properties = {MeshType = Enum.MeshType.Head, Scale = Vector3.new(1.25, 1.25, 1.25)}},
	}
	local NPC = Create("Model"){
		Name = "NPC",
	}
	local Humanoid = Create("Humanoid"){
		Name = "Humanoid",
	}
	for i, v in pairs(HumanoidProperties) do
		pcall(function()
			Humanoid[i] = v
		end)
	end
	Humanoid.Name = "Humanoid"
	Humanoid.Parent = NPC
	Humanoid.Health = Humanoid.MaxHealth
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = NPC,
		}
	end
	for i, v in pairs(Limbs) do
		local Limb = BasePart:Clone()
		for ii, vv in pairs(v.Properties) do
			pcall(function()
				Limb[ii] = vv
			end)
		end
		Limb.Name = i
		Limb.Parent = NPC
	end
	for i, v in pairs(Joints) do
		local Joint = Create("Motor"){
		}
		for ii, vv in pairs(v.Properties) do
			pcall(function()
				Joint[ii] = vv
			end)
		end
		Joint.Name = i
		Joint.Part0 = NPC:FindFirstChild(v.Part0)
		Joint.Part1 = NPC:FindFirstChild(v.Part1)
		Joint.Parent = NPC:FindFirstChild(v.Parent)
	end
	for i, v in pairs(Misc) do
		local Decal = Create(v.Class){
		}
		for ii, vv in pairs(v.Properties) do
			pcall(function()
				Decal[ii] = vv
			end)
		end
		Decal.Parent = NPC:FindFirstChild(v.Parent)
	end
	local FakeHat = Create("Hat"){
		Name = "NoHat",
		Parent = NPC,
	}
	for i, v in pairs(NPCScripts:GetChildren()) do
		if v:IsA("Script") then
			local ScriptCopy = v:Clone()
			ScriptCopy.Disabled = false
			ScriptCopy.Parent = NPC
		end
	end
	return NPC
end

function DeathEffect(character, Alive)
	local NoEffect = character:FindFirstChild("NoEffect")
	if NoEffect then
		return
	end
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
					TextureId = (BaseUrl .. Remains.TextureId),
					Scale = Remains.Scale,
					VertexColor = Vector3.new(1, 1, 1),
					Offset = Vector3.new(0, 0, 0),
					Parent = Object,
				}
			end
			for ii, vv in pairs(Object:GetChildren()) do
				if vv:IsA("DataModelMesh") then
					vv.VertexColor = Vector3.new(0, 0, 0)
				end
			end
		elseif Object:IsA("CharacterMesh") or Object:IsA("Clothing") then
			Object:Destroy()
		elseif Object:IsA("DataModelMesh") then
			Object.VertexColor = Vector3.new(0, 0, 0)
		end
	end
	local function Effect(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			Materialize(v)
			Effect(v)
		end
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local OwnerCreator = character:FindFirstChild("Creator")
	if humanoid and humanoid.Health <= 0 and (not OwnerCreator or (OwnerCreator and OwnerCreator.Value ~= Player)) then
		local DeadTorso = character:FindFirstChild("Torso")
		local Killer = humanoid:FindFirstChild("creator")
		if Killer and Killer.Value == Player then
			local NoTransform = Killer:FindFirstChild("NoTransform")
			if not NoTransform then
				for i, v in pairs(character:GetChildren()) do
					if not v:IsA("Humanoid") then
						v:Destroy()
					end
				end
				local NPCValues = {
					{Name = "Damage", Class = "NumberValue", Value = 15},
					{Name = "HitDelay", Class = "NumberValue", Value = 0.1},
					{Name = "Creator", Class = "ObjectValue", Value = Player},
				}
				local NPC = MakeNPCMinion({HumanoidProperties = {MaxHealth = 250, WalkSpeed = 24}, Values = NPCValues})
				NPC.Name = "Skeleton"
				NPC.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				for i, v in pairs(NPC:GetChildren()) do
					if v:IsA("BaseScript") then
						v.Disabled = true
					end
				end
				local ForceField = Create("ForceField"){
				}
				Debris:AddItem(ForceField, 0.75)
				ForceField.Parent = NPC
				DeathEffect(NPC, true)
				local NoEffect = Create("BoolValue"){
					Name = "NoEffect",
					Value = true,
					Parent = NPC
				}
				Debris:AddItem(NPC, 20)
				NPC.Parent = game:GetService("Workspace")
				local torso = NPC:FindFirstChild("Torso")
				if torso then
					torso.CFrame = DeadTorso.CFrame
				end
				for i, v in pairs(NPC:GetChildren()) do
					if v:IsA("BaseScript") then
						v.Disabled = false
					end
				end
			end
		end
	end
	Materialize(character)
	Effect(character)
end

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not ToolEquipped or not CheckIfAlive() or Debounce then
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
	Debounce = true
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(22)
	if humanoid.Health <= 0 then
		DeathEffect(character, true)
	end
	wait(0.1)
	Debounce = false
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		wait(1)
	else
		if not Slashing then
			Slashing = true
			LastAttack = Tick
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.Slash)
			end)
			Sounds.Slash:Play()
			wait(1)
			Slashing = false
		end
	end
	
	Tool.Enabled = true
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	ToolEquipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
end

function Unequipped()	
	ToolEquipped = false
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)