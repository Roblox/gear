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

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 5, Max = 8},
	Hit = {Min = 18, Max = 25},
}

RemovalMonitor = script:WaitForChild("RemovalMonitor")
EagleScript = script:WaitForChild("EagleScript")
DisableScript = script:WaitForChild("DisableScript")

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

ColorPart = BasePart:Clone()
ColorPart.Name = "ColorPart"
ColorPart.Reflectance = 0.25
ColorPart.Transparency = 0.1
ColorPart.Material = Enum.Material.SmoothPlastic
ColorPart.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.BackSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.RightSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.Size = Vector3.new(1, 1, 1)
ColorPart.Anchored = true
ColorPart.CanCollide = false
ColorMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "9856898"),
	TextureId = (BaseUrl .. "1361097"),
	Scale = (ColorPart.Size * 2), --Default mesh scale is 1/2 the size of a 1x1x1 brick.
	Offset = Vector3.new(0, 0, 0),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = ColorPart,
}
ColorLight = Create("PointLight"){
	Name = "Light",
	Brightness = 50,
	Range = 8,
	Shadows = false,
	Enabled = true,
	Parent = ColorPart,
}
StripesColors = {
	Vector3.new(1, 0, 0),
	Vector3.new(1, 1, 1),
	Vector3.new(0, 0, 255),
}

local BaseEagle = BasePart:Clone()
BaseEagle.Name = "AttackEagle"
BaseEagle.Size = Vector3.new(0.7, 0.88, 3)
BaseEagle.Anchored = false
BaseEagle.CanCollide = false
EagleMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "120647529"),
	TextureId = (BaseUrl .. "120647378"),
	Scale = Vector3.new(1.25, 1.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseEagle,
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	EagleCall = Handle:WaitForChild("EagleCall"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
}

Flying = false
ToolEquipped = false

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

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		CurrentAnimation = nil
		wait(Animation.Duration)
	end
end

function SendEagle(character)
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or humanoid.Health == 0 or not head then
		return
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	local EagleSettings = {
		Height = 80,
		Distance = 300,
	}
	local Eagle = BaseEagle:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Target", Class = "ObjectValue", Value = character},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Eagle,
		}
	end
	local EagleCFrame = ((head.CFrame + Vector3.new(0, EagleSettings.Height, 0)) * CFrame.Angles(0, (math.pi * 2 * math.random()), 0) * CFrame.new(0, 0, EagleSettings.Distance))
	Eagle.CFrame = EagleCFrame
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		Parent = Eagle,
	}
	local BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(math.huge, math.huge, math.huge),
		position = EagleCFrame.p,
		Parent = Eagle,
	}
	local EagleScriptCopy = EagleScript:Clone()
	EagleScriptCopy.Disabled = false
	EagleScriptCopy.Parent = Eagle
	Debris:AddItem(Eagle, 15)
	Eagle.Parent = game:GetService("Workspace")
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
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
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local EagleAttacking = character:FindFirstChild("EagleAttacking")
	if EagleAttacking then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	humanoid:TakeDamage(DamageValue)
	if humanoid.Health == 0 or HealthAfter <= 0 then
		humanoid.Health = 1
		local BodyGyro = Create("BodyGyro"){
			Parent = torso,
		}
		local DisableScriptCopy = DisableScript:Clone()
		DisableScriptCopy.Name = "EagleAttacking"
		DisableScriptCopy.Disabled = false
		DisableScriptCopy.Parent = character
		Sounds.EagleCall:Play()
		SendEagle(character)
	end
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	local Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function CreateStripes(Length)
	local StripesModel = Instance.new("Model")
	StripesModel.Name = "StripesPart"
	for i, v in pairs(StripesColors) do
		local Part = ColorPart:Clone()
		Part.Name = "Part"
		Part.Size = Vector3.new(1, 0.2, Length)
		Part.CFrame = Part.CFrame * CFrame.new((Part.Size.X * (i - 1)), 0, 0)
		Part.Mesh.Scale = (Part.Size * 2)
		Part.Mesh.VertexColor = v
		Part.Light.Color = Color3.new(v.X, v.Y, v.Z)
		Part.Parent = StripesModel
	end
	return StripesModel
end

function GetStripesModel()
	local ModelName = (Player.Name .. "'s Stripes")
	local Model = game:GetService("Workspace"):FindFirstChild(ModelName)
	if not Model then
		Model = Instance.new("Model")
		Model.Name = ModelName
		local RemovalMonitorClone = RemovalMonitor:Clone()
		RemovalMonitorClone.Disabled = false
		RemovalMonitorClone.Parent = Model
	end
	return Model
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
	Attack(AttackAnims)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.25)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		local LastPlace = nil
		while ToolEquipped and CheckIfAlive() do
			local CurrentPlace = (Torso.CFrame * CFrame.new(0, 0, 0.25)).p
			local Velocity = Torso.Velocity
			Velocity = Vector3.new(Velocity.X, 0, Velocity.Z).magnitude
			if LastPlace and Velocity > 5 and not CurrentAnimation then
				Spawn(function()
					local Model = GetStripesModel()
					local Distance = (LastPlace - CurrentPlace).magnitude
					if Distance > 8 then
						LastPlace = nil
						return
					end
					local Length = (Distance + 0)
					local StripesModel = CreateStripes(Length)
					local StripesCFrame = CFrame.new((LastPlace + (CurrentPlace - LastPlace).Unit * (Distance / 2)), CurrentPlace) * CFrame.Angles(0, 0, -(math.pi / 2))					
					TransformModel(StripesModel, StripesModel:GetModelCFrame(), StripesCFrame, true)
					Debris:AddItem(StripesModel, 1.5)
					StripesModel.Parent = Model
					if Model and not Model.Parent then
						Model.Parent = game:GetService("Workspace")
					end					
					LastPlace = CurrentPlace
				end)
			elseif not LastPlace then
				LastPlace = CurrentPlace
			end
			wait(Rate)
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)