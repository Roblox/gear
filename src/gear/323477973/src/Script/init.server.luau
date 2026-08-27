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

HitScript = script:WaitForChild("HitScript")

Particles = script:WaitForChild("Particles")

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
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

ReloadTime = 3

Gravity = 196.20

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

function CreateDualWield()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if LeftArm then
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		FakeHandle.Mesh.MeshId = (BaseUrl .. "323372374")
		local LeftGrip = Create("Weld"){
			Part0 = LeftArm,
			Part1 = FakeHandle,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = ((Tool.Grip + Vector3.new(0.1, 0, 0)) * CFrame.Angles(0, (math.pi / 3), 0)),
			Parent = FakeHandle,
		}
		FakeHandle.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Fire:Play()
	for i, v in pairs({Handle, FakeHandle}) do
		if v and v.Parent then
			v.Transparency = 1
			local Punch = v:Clone()
			Punch.Name = "RocketPunch"
			Punch.Transparency = 0
			Punch.CanCollide = true
			for i, v in pairs(Punch:GetChildren()) do
				if v:IsA("JointInstance") then
					v:Destroy()
				end
			end
			for i, v in pairs(Particles:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					local Particle = v:Clone()
					Particle.Enabled = true
					Particle.Parent = Punch
				end
			end
			local Mass = (Punch:GetMass() * Gravity)
			local Force = 70
			local Direction = CFrame.new(Torso.Position, (Torso.CFrame + Torso.CFrame.lookVector * 2).p).lookVector
			local Velocity = (Direction * Force)
			local ForceMass = (Mass * 50)
			local BodyForce = Create("BodyVelocity"){
				maxForce = Vector3.new(ForceMass, ForceMass, ForceMass),
				velocity = Velocity,
				Parent = Punch,
			}
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				cframe = v.CFrame,
				Parent = Punch,
			}
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = 30},
				{Name = "PushStrength", Class = "NumberValue", Value = 50},
				{Name = "FadeDelay", Class = "NumberValue", Value = 1},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = Punch,
				}
			end
			local HitScriptCopy = HitScript:Clone()
			HitScriptCopy.Disabled = false
			HitScriptCopy.Parent = Punch
			Punch.Velocity = Velocity
			Debris:AddItem(Punch, 5)
			Punch.CFrame = v.CFrame
			Punch.Parent = game:GetService("Workspace")
		end
	end
	wait(ReloadTime)
	local TimeToFade = 0.5
	local FadeRate = 0.05
	local OrigTransparency = 1
	for i = 1, (TimeToFade / FadeRate) do
		wait(FadeRate)
		for ii, vv in pairs({Handle, FakeHandle}) do
			vv.Transparency = (OrigTransparency - (i / (TimeToFade / FadeRate)))
		end
	end
	Tool.Enabled = true
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
		CreateDualWield()
		for i, v in pairs({"Left Arm", "Right Arm"}) do
			local Arm = Character:FindFirstChild(v)
			if Arm then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({FakeHandle}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
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

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		local ToolIsEquipped = ((Players:GetPlayerFromCharacter(Tool.Parent) and true) or false)
		if ToolIsEquipped then
			Handle.Transparency = ((Tool.Enabled and 0) or 1)
		else
			Handle.Transparency = 0
		end
	end
end)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)