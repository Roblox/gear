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


BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 1.75, Duration = 0.75},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = nil, Weight = nil, Speed = 1.75, Duration = 0.75},
}

Sounds = {
	Throw = Handle:WaitForChild("Throw"),
	Hit = Handle:WaitForChild("Hit"),
}

StarsReady = {}
Projectiles = {}

Gravity = 196.20
Rate = (1 / 60)
ReloadTime = 2
Damage = 22

ManagingProjectiles = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Enabled = true

function CreateMultiThrow(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs(StarsReady) do
		if v.Part and v.Part.Parent then
			v.Part:Destroy()
		end
	end
	StarsReady = {}
	Handle.Transparency = ((CreateNew and 1) or 0)
	if not CreateNew then
		return
	end
	local StarShapes = {"340607397", "340607397"}
	local BaseStar = BasePart:Clone()
	BaseStar.Name = "Star"
	BaseStar.Size = Vector3.new(0.85, 0.2, 0.85)
	BaseStar.CanCollide = false
	local Mesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = "",
		TextureId = (BaseUrl .. "340607306"),
		Scale = Vector3.new(0.75, 0.75, 0.75),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = BaseStar,
	}
	for i = 1, #StarShapes do
		local ShapeNumber = math.random(1, #StarShapes)
		local StarShape = StarShapes[ShapeNumber]
		table.remove(StarShapes, ShapeNumber)
		local Star = BaseStar:Clone()
		Star.Mesh.MeshId = (BaseUrl .. StarShape)
		local Weld = Create("Weld"){
			Part0 = Handle,
			Part1 = Star,
			C0 = (CFrame.new((math.random(-10, 10) * 0.01), (-0.625 + (0.3 * i)), 0) * CFrame.Angles((math.random(-15, 15) * 0.01), (math.random(-360, 360) * 0.01), 0)),
			C1 = CFrame.new(0, 0, 0),
			Parent = Star,
		}
		table.insert(StarsReady, {Part = Star, Weld = Weld})
		Star.Parent = Tool
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	Sounds.Throw:Play()
	local MousePosition = MouseData.Position
	local Animation = Animations.Throw
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Throw
	end
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	for i, v in pairs(StarsReady) do
		if v.Part and v.Part.Parent then
			if v.Weld and v.Weld.Parent then
				v.Weld:Destroy()
			end
			local Part = v.Part
			local StartPosition = Part.Position
			local Direction = CFrame.new(StartPosition, MousePosition)
			local Force = 60
			local Velocity = (Direction.lookVector * Force)
			local SideDirection = (Direction * CFrame.Angles(0, (math.pi / 2), 0))
			local SideForce = math.random(-3, 3)
			local SideVelocity = (SideDirection.lookVector * SideForce)
			local Mass = (Part:GetMass() * Gravity)
			local BodyVelocity = Create("BodyVelocity"){
				maxForce = Vector3.new(Mass, Mass, Mass),
				velocity = (Velocity + (SideVelocity * Vector3.new(1, 0, 1))),
				Parent = Part,
			}
			local BodyAngularVelocity = Create("BodyAngularVelocity"){
				maxTorque = Vector3.new(0, Mass, 0),
				angularvelocity = Vector3.new(0, 15, 0),
				Parent = Part,
			}
			table.insert(Projectiles, Part)
			Part.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				FlyProjectile(Part, Hit)
			end)
			Part.Changed:connect(function(Property)
				if Property == "Parent" and not Part or not Part.Parent then
					for i, v in pairs(Projectiles) do
						if v == Part then
							table.remove(Projectiles, i)
						end
					end
				end
			end)
			Debris:AddItem(Part, 5)
			Part.Parent = game:GetService("Workspace")
			Part.Velocity = Velocity
		end
	end
	StarsReady = {}
	wait(Animation.Duration)
	if ToolEquipped and CurrentlyEquipped then
		CreateMultiThrow(true)
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function FlyProjectile(Part, Hit)
	if Part.Name == "Effect" then
		return
	end
	local AlreadyHit = false
	local function PartHit(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or Part.Name == "Effect" then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)
		return character
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.Velocity.Unit, Length = 1.5}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = 1.5}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = Functions.CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {((Player and Player.Character) or nil), Part}, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
		end
		return ((ClosestRay.Hit and ClosestRay) or nil)
	end
	local ClosestRay = CheckForContact(Hit)
	if ClosestRay then
		for i, v in pairs(Part:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end
		Part.Velocity = Vector3.new(0, 0, 0)
		Part.RotVelocity = Vector3.new(0, 0, 0)
		Part.Size = Vector3.new(0.2, 0.2, 0.2)
		Part.CanCollide = false
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		local StickCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
		StickCFrame = (StickCFrame * CFrame.new(0, -((Part.Size.Y / 1.5) - ((SuccessfullyHit and 0.125) or 0)), 0))
		StickCFrame = (CFrame.new(StickCFrame.p, Handle.Position) * CFrame.Angles(Part.CFrame:toEulerAnglesXYZ()))
		local Weld = Create("Motor6D"){
			Part0 = Part,
			Part1 = ClosestRay.Hit,
			C0 = StickCFrame:inverse(),
			C1 = ClosestRay.Hit.CFrame:inverse(),
			Parent = Part,
		}
		local Hit = ClosestRay.Hit
		local SoundPart = BasePart:Clone()
		SoundPart.Name = "Effect"
		SoundPart.Transparency = 1
		SoundPart.Anchored = true
		SoundPart.CanCollide = false
		local Sound = Sounds.Hit:Clone()
		Sound.Pitch = (math.random(1000, 1500) * 0.001)
		Sound.Parent = SoundPart
		Debris:AddItem(SoundPart, 1.5)
		SoundPart.CFrame = Part.CFrame
		SoundPart.Parent = game:GetService("Workspace")
		Sound:Play()
		Part.Name = "Effect"
	end
	if not ManagingProjectiles then
		ManagingProjectiles = true
		Spawn(function()
			while #Projectiles > 0 and ManagingProjectiles and CheckIfAlive() do
				for i, v in pairs(Projectiles) do
					if v and v.Parent and v.Name ~= "Effect" then
						FlyProjectile(v)
					end
				end
				wait()
			end
		end)
	end
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
		CreateMultiThrow(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		CreateMultiThrow(false)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

CreateMultiThrow(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)