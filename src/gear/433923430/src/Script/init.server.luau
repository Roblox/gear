--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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

Logo = script:FindFirstChild("Logo")

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

Butterfly = BasePart:Clone()
Butterfly.Name = "Effect"
Butterfly.Transparency = 0
Butterfly.Size = Vector3.new(0.2, 0.2, 0.2)
Butterfly.CanCollide = false
Butterfly.Anchored = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = "",
	TextureId = (BaseUrl .. "433786064"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Butterfly,
}

Butterflies = {433785575, 433785629, 433785670, 433785744}

Animations = {
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = 0.25, Weight = nil, Speed = nil, Duration = 1.5},
}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

function MakeButterflies()
	
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	
	local CurrentlyEquipped = true
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	local FlyingButterflies = {}
	for i, v in pairs(Butterflies) do
		local ButterflyCopy = Butterfly:Clone()
		ButterflyCopy.Mesh.MeshId = (BaseUrl .. v)
		local Gravity = 196.20
		local Mass = (ButterflyCopy:GetMass() * Gravity * 100)
		local BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			D = 500,
			P = 3000,
			Parent = ButterflyCopy,
		}
		local BodyPosition = Create("BodyPosition"){
			maxForce = Vector3.new(Mass, Mass, Mass),
			position = Vector3.new(0, 0, 0),
			P = 15000,
			D = 1500,
			Parent = ButterflyCopy,
		}
		table.insert(FlyingButterflies, {
			Butterfly = ButterflyCopy,
			BodyGyro = BodyGyro,
			BodyPosition = BodyPosition,
			Origin = {CFrame = nil, Nearby = false, Traveling = false},
			LastFlyUpdate = 0,
			FlyWait = 0,
			TargetPoint = nil
		})
		ButterflyCopy.CFrame = (CFrame.new(Handle.Position) + CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360)).lookVector * (math.random(1500, 3000) * 0.001))
		BodyGyro.cframe = ButterflyCopy.CFrame
		ButterflyCopy.Parent = Tool
	end
	local Range = {Min = Vector3.new(-3.5, -0.5, -3.5), Max = Vector3.new(3.5, 2.75, 3.5)}
	for i, v in pairs(Range) do
		Range[i] = (v * 1000)
	end
	local Target = Head
	local TargetOffset = Vector3.new(0, 1.75, -2)
	local MaxDistance = 8
	while ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
		local Now = tick()
		for i, v in pairs(FlyingButterflies) do
			local DistanceApart = (v.Butterfly.Position - Target.Position).Magnitude
			if (Now - v.LastFlyUpdate) >= v.FlyWait or DistanceApart > MaxDistance then
				v.LastFlyUpdate = Now
				v.FlyWait = (math.random(25, 175) * 0.01)
				if (not v.Origin.Nearby and not v.Traveling) or not v.Origin.CFrame then
					v.Origin.Traveling = true
					local RandomOffset = (Vector3.new(math.random(Range.Min.X, Range.Max.X), math.random(Range.Min.Y, Range.Max.Y), math.random(Range.Min.Z, Range.Max.Z)) * 0.001)
					v.RandomOffset = RandomOffset
					local TargetPoint =( (Target.CFrame * CFrame.new(TargetOffset + RandomOffset)) * CFrame.Angles(math.rad(-360, 360), math.random(-360, 360), math.random(-360, 360)))
					v.Origin.CFrame = TargetPoint
					v.BodyGyro.cframe = (CFrame.new(v.Butterfly.Position, TargetPoint.p) * CFrame.Angles(-(math.pi / 2), 0, 0))
					local Speed = ((DistanceApart > 2 and 25) or 25)
					v.BodyPosition.position = TargetPoint.p--CFrame.new(v.Butterfly.Position, TargetPoint.p).lookVector * Speed
					if v.Origin.CFrame and (v.Butterfly.Position - v.Origin.CFrame.p).Magnitude <= 6 then
						v.Traveling = false
						v.Origin.Nearby = true
					else
					end
				else
					v.Origin.Nearby = false
				end
			end
		end
		wait()
	end
	for i, v in pairs(FlyingButterflies) do
		if v and v.Butterfly and v.Butterfly.Parent then
			v.Butterfly:Destroy()
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Animation = Animations.Swing
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		if Logo then
			LogoCopy = Logo:Clone()
			LogoCopy.Adornee = Head
			LogoCopy.Enabled = true
			Debris:AddItem(LogoCopy, 5)
			LogoCopy.Parent = Tool
		end
	end)
	ToolEquipped = true
	Spawn(function()
		MakeButterflies()
	end)
end

function Unequipped()
	if LogoCopy and LogoCopy.Parent then
		LogoCopy:Destroy()
	end
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