Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

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

Damage = {
	Touch = {Min = 0, Max = 0},
	Hit = {Min = 18, Max = 26},
}

Sounds = {
	Swing = {Sound = Handle:WaitForChild("Swing"), Pitch = {Min = 1, Max = 5}},
	Hit = {Sound = Handle:WaitForChild("Hit"), Pitch = {Min = 2, Max = 7}},
	Woosh = {Sound = Handle:WaitForChild("Woosh"), Pitch = {Min = 0.75, Max = 1}},
	Smack = {Sound = Handle:WaitForChild("Smack")},
	Spin = {Sound = Handle:WaitForChild("Spin")},
}

Animations = {
	CenterSwing = {Animation = Tool:WaitForChild("CenterSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	LeftSwing = {Animation = Tool:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	RightSwing = {Animation = Tool:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	R15CenterSwing = {Animation = Tool:WaitForChild("R15CenterSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	R15LeftSwing = {Animation = Tool:WaitForChild("R15LeftSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	R15RightSwing = {Animation = Tool:WaitForChild("R15RightSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1}	
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

Display = Tool:FindFirstChild("Display")
DisplayModel = Tool:FindFirstChild("DisplayModel")
ThumbnailPose = Tool:FindFirstChild("ThumbnailPose")
if Display then
	Display:Destroy()
end

local NunchuckModel = nil
local CurrentNunchucks = nil
if DisplayModel then
	NunchuckModel = DisplayModel:Clone()
	DisplayModel:Destroy()
end
if ThumbnailPose then
	ThumbnailPose:Destroy()
end

ReloadTime = 1.5
MouseDown = false
ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function PlaySound(Sound)
	if type(Sound) == "table" then
		if Sound.Sound then
			Sound = Sound.Sound
		else
			Sound = Sound[math.random(1, #Sound)].Sound
		end
	end
	for i, v in pairs(Sounds) do
		if v.Sound == Sound then
			if v.Pitch then
				v.Sound.Pitch = (math.random((v.Pitch.Min * 1000), (v.Pitch.Max * 1000)) * 0.001)
			end
			v.Sound:Play()
		end
	end
end

function Blow(Part)
	local HitDelay = false
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or HitDelay then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Functions.IsTeamMate(Player, player) or player == Player) then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if character == Character or not humanoid or humanoid.Health == 0 then
			return
		end
		local DamageValue = Damage.Touch
		if CurrentAnimation then
			DamageValue = Damage.Hit
		end
		if not DamageValue then
			return
		end
		HitDelay = true
		Delay(0.05, (function()
			HitDelay = false
		end))
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		if FinalizedDamage <= 0 then
			return
		end
		local EstimatedHealth = (humanoid.Health - FinalizedDamage)
		humanoid:TakeDamage(FinalizedDamage)
		PlaySound({Sounds.Hit, Sounds.Smack})
	end)
	return TouchedConnection
end

function ConstructWeapon(MakeNew)
	if not MakeNew then
		return
	end
	NunchuckParts = {}
	
	local NewModel = NunchuckModel:Clone()
	
	for _, Motor in next, NewModel.Joints:GetChildren() do
		if Motor:IsA("Motor6D") then
			if Motor.Part0.Name == "TopHandle" then
				table.insert(NunchuckParts, {Part = Motor.Part0, Motor = Motor, DefaultPose = Motor.DesiredAngle, DefaultSpeed = 0.1})
				break
			end
		end
	end	
	
	NewModel.Parent = Tool

	CurrentNunchucks = NewModel
	Blow(NewModel.BottomHandle)
end

function SetPose(PoseData)
	local PoseType = type(PoseData)
	for i, v in pairs(NunchuckParts) do
		if PoseType == "nil" then
			v.Motor.DesiredAngle = v.DefaultPose
			v.Motor.MaxVelocity = v.DefaultSpeed
		elseif PoseType == "number" then
			v.Motor.DesiredAngle = PoseData
			v.Motor.MaxVelocity = v.DefaultSpeed
		elseif PoseType == "table" then
			for ii, vv in pairs(PoseData) do
				if type(vv) == "number" then
					if i == ii then
						v.Motor.DesiredAngle = vv
					end
				elseif type(vv) == "table" then
					if v.Part == vv.Part then
						if vv.DesiredAngle then
							v.Motor.DesiredAngle = vv.DesiredAngle
						end
						if vv.DesiredSpeed then
							v.Motor.MaxVelocity = vv.DesiredSpeed
						end
					end
				end
			end
		end
	end
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyActive = true
	CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local function DoStuff(DelayTime, Function)
		if not CurrentlyActive or not CurrentlyEquipped or not ToolEquipped or not CheckIfAlive() then
			return
		end
		Delay(DelayTime, Function)
	end
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		Tool.Enabled = true
		return
	end
	local TargetPos = MouseData.Position
	local Angle = CFrame.new(Head.Position, Vector3.new(TargetPos.X, Head.Position.Y, TargetPos.Z)):toObjectSpace(Head.CFrame).lookVector.X
	local Direction = (math.abs(Angle) <= 0.45 and Enum.NormalId.Front or Angle > 0 and Enum.NormalId.Left or Angle < 0 and Enum.NormalId.Right)
	local Animation = ((Direction == Enum.NormalId.Left and Animations.CenterSwing) or (Direction == Enum.NormalId.Right and Animations.CenterSwing) or Animations.CenterSwing)
	local RotAngle = CFrame.new(Torso.Position, Vector3.new(TargetPos.X, Torso.Position.Y, TargetPos.Z))
	local BodyGyro = Create("BodyGyro"){
		Name = "TurnForce",
		maxTorque = Vector3.new(0, math.huge, 0),
		cframe = RotAngle,
	}
	Debris:AddItem(BodyGyro, 0.5)
	BodyGyro.Parent = Torso
	Humanoid.AutoRotate = false
	CurrentAnimation = Animation
	--RightHandleMotor.DesiredAngle = Functions.GetAngle(CFrame.new(Handle.Position, TargetPos).lookVector)
	SetPose({2, 2, -1.5, -0.5, 0})
	DoStuff(0.25, (function()
		PlaySound({Sounds.Swing, Sounds.Woosh})
		SetPose(0)
		DoStuff(0.25, (function()
			SetPose()
		end))
	end))
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	if CheckIfAlive() and CurrentlyEquipped and ToolEquipped then
		Humanoid.AutoRotate = true
	end
	CurrentlyActive = false
	CurrentAnimation = nil
	Delay(0.6, (function()
		if not CurrentlyEquipped or not ToolEquipped or not CheckIfAlive() then
			return
		end
		SetPose()
	end))
	if BodyGyro and BodyGyro.Parent then
		BodyGyro:Destroy()
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	--Handle.Transparency = 1
	MouseDown = false
	ToolEquipped = true
	Spawn(function()
		ConstructWeapon(true)
	end)
end

function Unequipped()
	MouseDown = false
	ToolEquipped = false
	if CheckIfAlive() then
		Humanoid.AutoRotate = true
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	--Handle.Transparency = 0
	if Torso and Torso.Parent then
		Handle.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * (Torso.Size.Z * 2))
	end
	
	if CurrentNunchucks then
		CurrentNunchucks:Destroy()
	end
	CurrentNunchucks = nil
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
	if Mode == "Button1Click" then
		local Down = Value.Down
		if not Down and MouseDown then
			MouseDown = false
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Transparency = 1
--ConstructWeapon(true)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)