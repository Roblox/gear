--Rescripted by Luckymaxer

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

ThrowVelocity = {Min = 0.2, Max = 0.6, Boost = Vector3.new(0, 30, 0)}
PopSounds = {114745014, 114745028, 114745043, 114745060, 114745081}

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

PlungerScript = script:WaitForChild("PlungerScript")

PlungerEffects = {
	Fire = script:WaitForChild("Fire"),
	Light = script:WaitForChild("Light"),
}

DisplayEffects = {}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = 0, Weight = nil, Speed = 0.25},
}

Sounds = {
	Spin = Handle:WaitForChild("Spin"),
	Swish = Handle:WaitForChild("Swish"),
	Hit = Handle:WaitForChild("Hit"),
}

ReloadTime = 3

Spinning = false
EffectsOn = false
ToolEquipped = false

Gravity = 196.20
Rate = (1 / 30)

BasePlunger = BasePart:Clone()
BasePlunger.Name = "Plunger"
BasePlunger.Size = Vector3.new(1, 2.8, 1)
BasePlunger.CanCollide = true
PlungerMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "114692902"),
	TextureId = (BaseUrl .. "114692941"),
	Scale = Vector3.new(1.5, 1.5, 1.5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BasePlunger,
}

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

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Light") or v:IsA("Sparkles") then
		v:Destroy()
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
	Spawn(function()
		Humanoid.WalkSpeed = 24
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightArm = Character:FindFirstChild("Right Arm")
		for i, v in pairs({LeftArm, RightArm}) do
			if v then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v ~= Handle then
				v:Destroy()
			end
		end
		if LeftArm then
			FakeHandle = Handle:Clone()
			FakeHandle.Name = "FakeHandle"
			local FakeHandleWeld = Create("Weld"){
				Part0 = LeftArm,
				Part1 = FakeHandle,
				C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
				C1 = Tool.Grip,
				Parent = FakeHandle,
			}
			FakeHandle.Parent = Tool
		end
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Hold)
		end)
	end)
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	EffectsOn = false
	Spinning = false
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
	if Mode == "KeyframeChanged" then
		local Keyframe = Value.Keyframe
		if not Keyframe then
			return
		end
		for i, v in pairs(Limbs) do
			if v.Limb and v.Joint and (v.Joint.Part0 == v.Limb or v.Joint.Part1 == v.Limb) and v.Object and v.Object.Parent then
				local Plunger = BasePlunger:Clone()
				Plunger.CanCollide = false
				Plunger.CFrame = v.Object.CFrame
				if (Keyframe == "Start" and v.Limb.Name == "Right Arm") or (Keyframe == "Middle" and v.Limb.Name == "Left Arm") then
					local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Torso.CFrame:components()
					Plunger.Velocity = (CFrame.new(Plunger.Position.X, Plunger.Position.Y, Plunger.Position.Z, R00, R01, R02, R10, R11, R12, R20, R21, R22).lookVector * (75 + (250 * DesiredThrowVelocity ^ 2)) + ThrowVelocity.Boost)
					if EffectsOn then
						for ii, vv in pairs(PlungerEffects) do
							local Effect = vv:Clone()
							if Effect:IsA("Fire") or Effect:IsA("Smoke") or Effect:IsA("Light") or Effect:IsA("Sparkles") then
								Effect.Enabled = true
							end
							Effect.Parent = Plunger
						end
					end
					local Sound = Sounds.Hit:Clone()
					Sound.SoundId = (BaseUrl .. PopSounds[math.random(1, #PopSounds)])
					Sound.Parent = Plunger
					local PlungerScriptClone = PlungerScript:Clone()
					local Values = {
						{Name = "Creator", Class = "ObjectValue", Value = Player},
						{Name = "Damage", Class = "NumberValue", Value = 22},
					}
					for i, v in pairs(Values) do
						local Value = Create(v.Class){
							Name = v.Name,
							Value = v.Value,
							Parent = Plunger
						}
					end
					PlungerScriptClone.Disabled = false
					PlungerScriptClone.Parent = Plunger
					local Sound = Sounds.Swish:Clone()
					Sound.Pitch = (1.1 + (0.15 * math.random()))
					Sound.Parent = Plunger
					Debris:AddItem(Plunger, 6)
					Plunger.Parent = Character
					Delay(0.25, (function()
						if Plunger and Plunger.Parent then
							Plunger.CanCollide = true
						end
					end))				
					Delay(0.5, (function()
						if Plunger and Plunger.Parent then
							Plunger.Parent = game:GetService("Workspace")
						end
					end))
					Sound:Play()
					v.Object.Transparency = 1
				else
					v.Object.Transparency = 0
				end
			end
		end
	elseif Mode == "MouseClick" then
		local Down = Value.Down
		if Down and Tool.Enabled and not Spinning then
			Spinning = true
			Sounds.Spin.Pitch = 1
			Sounds.Spin:Stop()
			Spawn(function()
				local StartTime = tick()
				local EndTime = (StartTime + 2.5)
				local MaxSpeed = 1.25
				EffectsOn = false
				local Animation = Animations.Spin
				DesiredSpeed = Animation.Speed
				DesiredThrowVelocity = ThrowVelocity.Min
				Limbs = {
					{Limb = Character:FindFirstChild("Left Arm"), Joint = Torso:FindFirstChild("Left Shoulder"), Object = FakeHandle},
					{Limb = Character:FindFirstChild("Right Arm"), Joint = Torso:FindFirstChild("Right Shoulder"), Object = Handle},
				}
				while ToolEquipped and Spinning and CheckIfAlive() do
					local CurrentTime = tick()
					local CurrentCharge = math.abs(CurrentTime - StartTime)
					local ChargePercent = Clamp((GetPercentage(StartTime, EndTime, CurrentTime) * 0.5), 0, 100)
					local ChargePercentToDecimal = (ChargePercent * 0.01)
					DesiredSpeed = Clamp((MaxSpeed * ChargePercentToDecimal), Animation.Speed, MaxSpeed)
					DesiredThrowVelocity = Clamp((ThrowVelocity.Max * ChargePercentToDecimal), ThrowVelocity.Min, ThrowVelocity.Max)
					if DesiredSpeed >= 0.75 and not Sounds.Spin.IsPlaying then
						Sounds.Spin:Play()
					end
					if ChargePercentToDecimal >= 0.5 and not EffectsOn then
						EffectsOn = true
						for i, v in pairs({Handle, FakeHandle}) do
							for ii, vv in pairs(PlungerEffects) do
								local Effect = vv:Clone()
								if Effect:IsA("Fire") or Effect:IsA("Smoke") or Effect:IsA("Light") or Effect:IsA("Sparkles") then
									Effect.Enabled = true
								end
								table.insert(DisplayEffects, Effect)
								Effect.Parent = v
							end
						end
					end
					Sounds.Spin.Pitch = Clamp((1 * ChargePercentToDecimal), 1, 1.75)
					local AnimationTrack = InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = DesiredSpeed, KeyframeMonitor = true})
					wait(Rate)
				end
				EffectsOn = false
				Sounds.Spin:Stop()
				for i, v in pairs(DisplayEffects) do
					if v and v.Parent then
						v:Destroy()
					end
				end
				for i, v in pairs({Handle, FakeHandle}) do
					if v and v.Parent then
						v.Transparency = 0
					end
				end
				Spawn(function()
					InvokeClient("StopAnimation", {Animation = Animations.Spin.Animation, FadeTime = nil})
				end)
				Tool.Enabled = false
				wait(2)
				Tool.Enabled = true
			end)
		elseif not Down and Spinning then
			Spinning = false
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)