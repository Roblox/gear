Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local GearService = require(1075123174)

local AnimationsFolder = Tool:WaitForChild("Animations")
local R6Folder = AnimationsFolder:WaitForChild("R6")
local R15Folder = AnimationsFolder:WaitForChild("R15")

Animations = {
	Throw = {Animation = R6Folder:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil},
	Sit = {Animation = R6Folder:WaitForChild("Sit"), FadeTime = 0.25, Weight = nil, Speed = nil}
}

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
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BasePlane = BasePart:Clone()
BasePlane.Name = "Plane"
BasePlane.Size = Vector3.new(1.75, 1.25, 3)
BasePlane.CanCollide = true
Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "1230437773"),
	TextureId = (BaseUrl .. "1230438086"),
	Scale = Vector3.new(0.25, 0.25, 0.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BasePlane,
}
local PlanePropellerAttachment = Instance.new("Attachment")
PlanePropellerAttachment.Name = "PropellerAttachment"
PlanePropellerAttachment.CFrame = CFrame.new(-8.1671169e-07, -0.150005698, -4.95000172, 1, 0, 0, 0, 1, 0, 0, 0, 1)
PlanePropellerAttachment.Parent = BasePlane
BasePropeller = BasePart:Clone()
BasePropeller.Name = "Propeller"
BasePropeller.Size = Vector3.new(1, 1, 1)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "1230437509"),
	TextureId = (BaseUrl .. "1230438086"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BasePropeller,
}
local PropellerAttachment = Instance.new("Attachment")
PropellerAttachment.Name = "PropellerAttachment"
PropellerAttachment.CFrame = CFrame.new(-1.09920802e-06, 0.300003767, 0.349999219, 1, 0, 0, 0, 1, 0, 0, 0, 1)
PropellerAttachment.Parent = BasePropeller

Rate = (1 / 30)
Gravity = workspace.Gravity

Control = 0
EndFlight = false

MouseDown = Create("BoolValue"){
	Value = false,
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

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

function ThrowPlane()
	
	if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
		return
	end
	
	Plane = BasePlane:Clone()
	Propeller = BasePropeller:Clone()
	Propeller.CanCollide = false
	
	Plane.Name = (Player.Name .. "'s Plane")
	Plane.CanCollide = false
	Plane.CFrame = Handle.CFrame
	
	local PlaneMesh = Plane.Mesh
	
	BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(math.huge, math.huge, math.huge),
		position = Plane.Position,
		Parent = Plane,
	}
	
	BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		Parent = Plane,
	}
	
	Plane.Parent = game:GetService("Workspace")
	
	local Delta = 0
	Mode = 0
	EndFlight = false
	PlaneGoTo = nil
	
	Spawn(function()
		local EaseRate = (1 / 60)
		local ChangeRate = 30
		local Duration = 1.5
		local Frames = (Duration * ChangeRate)
		for i = 1, Frames do
			if not Plane or not Plane.Parent or not CheckIfAlive() or not ToolEquipped or EndFlight then
				return
			end
			local Size = ((Vector3.new(7.5, 5.25, 13) / Frames) * i)
			local Scale = ((Vector3.new(1,1,1) / Frames) * i)
			if (Size.X * Size.Y * Size.Z) > BasePlane:GetMass() then
				local OrigCF = Plane.CFrame
				Plane.Size = Size
				PlaneMesh.Scale = Scale
				Plane.CFrame = OrigCF
			end
			wait(EaseRate)
		end	
		Mode = 1
		PropellerMotor = GearService:WeldToAttachment(Plane:FindFirstChild("PropellerAttachment"), Propeller:FindFirstChild("PropellerAttachment"))
		Propeller.Parent = Plane
		PlaneMesh.MeshId = BaseUrl .. 1230437228
	end)
	
	local ParticleParts = {}
	
	local Flames = {}
	local Smokes = {}
	
	if MouseDownChanged then
		MouseDownChanged:disconnect()
	end
	
	local LastValue = MouseDown.Value	
	
	MouseDownChanged = MouseDown.Changed:connect(function()
		if not CheckIfAlive() or not ToolEquipped or LastValue == MouseDown.Value then
			return
		end
		LastValue = MouseDown.Value
		for i, v in pairs({Flames, Smokes}) do
			for ii, vv in pairs(v) do
				if vv and vv.Parent then
					vv.Enabled = false
					Debris:AddItem(vv, 1.5)
				end
			end
		end
	end)
	local RandomEffect = {Tick = 0, Delay = -1}
	
	local angle = 0	
	local Stepped = game:GetService("RunService").Stepped:Connect(function(delta)
		local Speed = ((MouseDown.Value and 10) or 4)
		angle = (angle + delta) % 360
		if PropellerMotor then
			PropellerMotor.Transform = CFrame.Angles(0, 0, math.rad(angle * Speed))
		end
	end)	

	while CheckIfAlive() and ToolEquipped and Plane and Plane.Parent and not EndFlight and CurrentlyEquipped do
		local Speed = ((MouseDown.Value and 10) or 4)
		if Mode == 0 then
			BodyPosition.position = (Plane.Position + Plane.CFrame.lookVector * Speed)
			BodyGyro.cframe = CFrame.new(Plane.Position, BodyPosition.position)
		elseif (Mode == 1) then
			if not Plane or not Plane.Parent then
				EndFlight = true
				break
			end
			Plane.CanCollide = true
			TorsoWeld = Create("Motor6D"){
				Part0 = Plane,
				Part1 = Torso,
				C0 = (CFrame.new(-0.1, 1, 0.5) * CFrame.Angles(0, 0, 0)),
				C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)),
				Parent = Plane,
			}
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.Sit)
			end)
			Humanoid.Sit = true
			Plane.Parent = Tool
			Mode = 3
		elseif Mode == 3 then
			if not TorsoWeld or not TorsoWeld.Parent or TorsoWeld.Part0 ~= Plane or TorsoWeld.Part1 ~= Torso then
				EndFlight = true
				break
			end
			Control = 1
			Humanoid.Sit = true
			local DeltaSpeed = (Speed * (Delta / Rate))
			BodyPosition.position = (Plane.Position + Plane.CFrame.lookVector * DeltaSpeed)
			BodyGyro.cframe = (CFrame.new(BodyPosition.position) * CFrame.Angles(Plane.CFrame:toEulerAnglesXYZ()))
			if PlaneGoTo then
				local PlaneGoToWorld = (Plane.Position + PlaneGoTo)
				BodyGyro.cframe = CFrame.new(Plane.Position, PlaneGoToWorld)
			end
		end	
		Delta = wait()
	end
	if Stepped then
		Stepped:Disconnect()
	end	
	
	Spawn(function()
		InvokeClient("StopAnimation", Animations.Sit)
	end)
	if MouseDownChanged then
		MouseDownChanged:disconnect()
	end
	Debris:AddItem(Plane, 5)
	Plane.Parent = game:GetService("Workspace")
	for i, v in pairs(ParticleParts) do
		if v.Part and v.Part.Parent then
			if v.Weld then
				v.Weld.Part0 = nil
				v.Weld.Part1 = nil
			end
			v.Part.Anchored = true
			v.Part.CanCollide = false
			for ii, vv in pairs(v.Part:GetChildren()) do
				if vv:IsA("ParticleEmitter") then
					vv.Enabled = false
				end
			end
		end
	end
	Plane.Anchored = true
	Plane.CanCollide = false
	local Explosion = Create("Explosion"){
		BlastPressure = 0,
		BlastRadius = 50,
		ExplosionType = Enum.ExplosionType.NoCraters,
		Position = Plane.Position,
		Parent = game:GetService("Workspace")
	}
	local EaseRate = (1 / 60)
	local ChangeRate = 30
	local Duration = 0.25
	local Frames = (Duration * ChangeRate)
	for i = 1, Frames do
		if not Plane or not Plane.Parent then
			return
		end
		local Size = (Vector3.new(7.5, 5.25, 13) - ((Vector3.new(7.5, 5.25, 13) / Frames) * i))
		local Scale = (Vector3.new(9, 9, 9) - ((Vector3.new(9, 9, 9) / Frames) * i))
		--if (Size.X * Size.Y * Size.Z) > BasePlane:GetMass() then
			local OrigCF = Plane.CFrame
			Plane.Size = Size
			PlaneMesh.Scale = Scale
			Plane.CFrame = OrigCF
--		end
		wait(EaseRate)
	end	
	if Plane and Plane.Parent then
		Plane:Destroy()
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent and Player:IsA("Player")) and true) or false)
end

function Activated()
	if not CheckIfAlive() or not ToolEquipped or not Tool.Enabled or (Plane and Plane.Parent) then
		return
	end
	Tool.Enabled = false
	if AnimationTrack then
		AnimationTrack:Stop()
	end
	CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.Throw
	AnimationTrack = Humanoid:LoadAnimation(Animation.Animation)
	AnimationTrack.KeyframeReached:connect(function(Keyframe)
		if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
			Tool.Enabled = true
			return
		end
		if Keyframe == "throw" then
			Handle.Transparency = 1
			ThrowPlane()
			Handle.Transparency = 0
			Tool.Enabled = true
		end
	end)
	AnimationTrack:Play(Animation.FadeTime, Animation.Weight, Animation.Speed)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations = {
			Throw = {Animation = R15Folder:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil},
			Sit = {Animation = R15Folder:WaitForChild("Sit"), FadeTime = 0.25, Weight = nil, Speed = nil}
		}
	else
		Animations = {
			Throw = {Animation = R6Folder:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil},
			Sit = {Animation = R6Folder:WaitForChild("Sit"), FadeTime = 0.25, Weight = nil, Speed = nil}
		}
	end
	
	ToolEquipped = true
	Tool.Enabled = true
end

function Unequipped()
	if AnimationTrack then
		AnimationTrack:Stop()
	end
	MouseDown.Value = false
	ToolEquipped = false
	Tool.Enabled = true
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(client, action, value)
	if client ~= Player or not action or not CheckIfAlive() or not ToolEquipped then
		return
	end
	if action == "Mouse1" then
		local Down = value.Down
		MouseDown.Value = Down
	elseif action == "Key" then
		local Key = value.Key
		local Down = value.Down
	elseif action == "MouseUpdate" then
		local hit = value
		if Control == 1 and MouseDown.Value and Plane and Plane.Parent then
			PlaneGoTo = (hit.p - Plane.Position)
		end
	elseif action == "Dismount" and Mode == 3 then
		local Dismount = value.Dismount
		if Dismount then
			EndFlight = true
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)