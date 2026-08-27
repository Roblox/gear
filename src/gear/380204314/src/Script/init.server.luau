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

HitScript = script:WaitForChild("HitScript")

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
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = 0, Weight = nil, Speed = 3, Duration = nil},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = 0, Weight = nil, Speed = 3, Duration = nil},	
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Throw = Handle:WaitForChild("Throw"),
}

Gravity = 196.20
Rate = (1 / 60)

ReloadTime = 3

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
	local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftLowerArm")
	if LeftArm then
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		local LeftGrip = Create("Weld"){
			Part0 = LeftArm,
			Part1 = FakeHandle,
			C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
			C1 = (Tool.Grip * CFrame.Angles(0, 0, 0)),
			Parent = FakeHandle,
		}
		FakeHandle.Parent = Tool
	end
end

function ThrowObjects(Parts, TargetPosition)
	if not Parts or not TargetPosition then
		return
	end
	
	local HeightMultiplier = (math.random() - 0.85)
	local Alpha = (HeightMultiplier * math.pi / 8 + math.pi / 3)
	
	for i, v in pairs(Parts) do	
		
		local Axe = v:Clone()
		
		for i, v in pairs(Axe:GetChildren()) do
			if v:IsA("JointInstance") then
				v.Part0 = nil
				v.Part1 = nil
				v:Destroy()
			end
		end	
		
		Axe.Name = "ThrowingAxe"
		Axe.Size = (Axe.Size * Vector3.new(1, 2, 1.5))
		Axe.CanCollide = true
		Axe.Transparency = 0
		Axe.CFrame = v.CFrame
		Axe.Friction = 1
		Axe.Elasticity = 0
		Debris:AddItem(Axe, 8)
		Axe.Parent = game:GetService("Workspace")

		local SpawnPosition = ((v.CFrame + Vector3.new(0, 2, 0)) + Torso.CFrame.lookVector * (v.Size.Z * 2.5))		
		local DirectionPos = (TargetPosition - v.Position)
		DirectionPos = (DirectionPos - DirectionPos.Unit * 5)
		--Convert to a 2D space
		local DeltaXZSquared = (DirectionPos.X * DirectionPos.X + DirectionPos.Z * DirectionPos.Z)
		local DeltaXZ = math.sqrt(DeltaXZSquared)
		local DeltaY = DirectionPos.Y
		Axe.CFrame = CFrame.new(SpawnPosition.p, Vector3.new(TargetPosition.X, SpawnPosition.p.Y, TargetPosition.Z))
		--Back-solve for the velocity required to hit the target point
		local Gravity = 196.1643
		local Numerator = (-0.5 * Gravity * DeltaXZSquared)
		local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
		if Denominator == 0 then
			return
		end
		local MaxSpeed = 300
		local Speed = math.sqrt(Numerator / Denominator)
		Speed = ((Speed > MaxSpeed and MaxSpeed) or Speed)
		local VectorXZ = (Speed * math.cos(Alpha))
		local VectorY = (Speed * math.sin(Alpha))
		local VectorX = (VectorXZ * DirectionPos.X / DeltaXZ)
		local VectorZ = (VectorXZ * DirectionPos.Z / DeltaXZ)
		Axe.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
		--Axe.RotVelocity = Vector3.new((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01))
		
		local Mass = (Axe:GetMass() * Gravity)
		local Gyro = Create("BodyGyro"){
			maxTorque = Vector3.new(0, math.huge, 0),
			cframe = Axe.CFrame,
			Parent = Axe,
		}
		local Velocity = ((Axe.CFrame * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * 20)
		local RotVelocity = Create("BodyAngularVelocity"){
			maxTorque = Vector3.new(Mass, Mass, Mass),
			angularvelocity = Velocity,
			Parent = Axe,
		}
		local Values = {
			{Name = "Creator", Value = Player, Class = "ObjectValue"},
			{Name = "Damage", Value = 28, Class = "NumberValue"},
		}
		for i, v in pairs(Values) do
			local Creator = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = Axe,
			}
		end
		
		local HitScriptCopy = HitScript:Clone()
		HitScriptCopy.Disabled = false
		HitScriptCopy.Parent = Axe
		
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	local MousePosition = MouseData.Position
	if (Handle.Position - MousePosition).Magnitude > 200 then
		return
	end
	Tool.Enabled = false
	Sounds.Throw:Play()
	Spawn(function()
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
 				InvokeClient("PlayAnimation", Animations.Throw)
			elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", Animations.R15Throw)
			end	
		end	
	end)
	local Objects = {Handle, FakeHandle}
	for i, v in pairs(Objects) do
		v.Transparency = 1
	end
	ThrowObjects(Objects, MousePosition)
	wait(ReloadTime)
	for i, v in pairs(Objects) do
		v.Transparency = 0
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
	Sounds.Unsheath:Play()
	Spawn(function()
		CreateDualWield()
		local Limbs = {}
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
				Limbs = {"Left Arm", "Right Arm"}
			elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Limbs = {"LeftLowerArm", "LeftUpperArm", "LeftHand", "RightHand", "RightLowerArm", "RightUpperArm"}
			end
		end
		for i, v in pairs(Limbs) do
			local Arm = Character:FindFirstChild(v)
			if Arm then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
 				InvokeClient("PlayAnimation", Animations.Equip)
			elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", Animations.R15Equip)
			end	
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
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

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "q" then
		end
	end
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		for i, v in pairs({Handle, FakeHandle}) do
			if v and v.Parent then
				v.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((Tool.Enabled and 0) or 1)) or 0)
			end
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)