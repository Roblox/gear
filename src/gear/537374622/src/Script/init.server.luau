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

BalloonScript = script:WaitForChild("BalloonScript")
Gui = script:WaitForChild("Gui")

MaxSpeed = 15

IdleDuration = 15 --If the owner of the balloon doesn't sit in a seat for this long, the balloon is removed.
DeployTick = 0

Connections = {}

Seated = false
Flying = false
MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

function Slerp(t, v1, v2)
	local om = math.acos(math.min(1, v1:Dot(v2)))
	return ((om < 0.01 and ((1 - t) * v1 + t * v2)) or ((math.sin((1 - t) * om) / math.sin(om)) * v1 + (math.sin(t * om) / math.sin(om)) * v2))
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

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function CreateBalloon()
	local BaseSize = Vector3.new(7, 0.5, 6.5)
	local SeatSize = Vector3.new(2, 0.6, 2)
	local WallSize = Vector2.new(2.5, 0.5) --Y, Z
	local XWallSize = Vector3.new(BaseSize.X, WallSize.X, WallSize.Y)
	local ZWallSize = Vector3.new(WallSize.Y, WallSize.X, (BaseSize.Z - (WallSize.Y * 2)))
	local Model = Create("Model"){
		Name = "HotAirBalloon",
		Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
		},
		Create("NumberValue"){
			Name = "IdleDuration",
			Value = IdleDuration,
		},
		Create("Part"){
			Name = "MainPart",
			Transparency = 1,
			Material = Enum.Material.Plastic, 
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth, 
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom, 
			Size = BaseSize,
			Locked = true,
			Create("Weld"){
				Name = "SeatWeld",
			}, 
			Create("Weld"){
				Name = "LeftSeatWeld",
			}, 
			Create("Weld"){
				Name = "BalloonWeld",
			}, 
			Create("Weld"){
				Name = "FireWeld1"
			},
			Create("Weld"){
				Name = "FireWeld2"
			},
			Create("Weld"){
				Name = "LeftWallWeld",
			}, 
			Create("Weld"){
				Name = "RightWallWeld",
			}, 
			Create("Weld"){
				Name = "FrontWallWeld",
			}, 
			Create("Weld"){
				Name = "BackWallWeld",
			}, 
			Create("BodyGyro"){
				Name = "FlyingGyro",
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				P = 5000,
				D = 500,
				cframe = CFrame.new(),
			}, 
			Create("BodyVelocity"){
				Name = "FlyingForce", 
				velocity = Vector3.new(),
				P = 1000,
			}, 
		},
		Create("Part"){
			Name = "LeftWall",
			Transparency = 1,
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = ZWallSize,
			Locked = true,
		},
		Create("Part"){
			Name = "RightWall",
			Transparency = 1,
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom, 
			Size = ZWallSize,
			Locked = true,
		},
		Create("Part"){
			Name = "FrontWall",
			Transparency = 1,
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = XWallSize,
			Locked = true,
		},
		Create("Part"){
			Name = "BackWall",
			Transparency = 1,
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = XWallSize,
			Locked = true,
		},
		Create("Seat"){
			Name = "Seat",
			BrickColor = BrickColor.new("Really black"),
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = SeatSize,
			Locked = true,
		}, 
		Create("Part"){
			Name = "FirePart1",
			Transparency = 1,
			CanCollide = false,
			Create("Fire"){
				Name = "Fire",
				Heat = 9,
				Size = 5,
				Color = Color3.new((236 / 255), (139 / 255), (70 / 255)),
				SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255)),
				Enabled = false,
			}, 
			Create("Sound"){
				Name = "FireSound",
				SoundId = (BaseUrl .. 30624426),
				Looped = true,
			}, 
		},
		Create("Part"){
			Name = "Balloon",
			Material = Enum.Material.Plastic,
			Shape = Enum.PartType.Block, 
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = Vector3.new(1, 1, 1),
			CanCollide = false,
			Locked = true,
			Create("SpecialMesh"){
				Name = "Mesh",
				MeshType = "FileMesh",
				MeshId = (BaseUrl .. 536830948),
				TextureId = (BaseUrl .. 536831193),
				Scale = Vector3.new(1, 1, 1),
			}, 
		}, 
	}
	
	local SeatWeld = Model.MainPart.SeatWeld
	SeatWeld.Part0 = SeatWeld.Parent
	SeatWeld.Part1 = Model.Seat
	SeatWeld.C0 = CFrame.new(0, SeatSize.Y, 0)
	
	local BalloonWeld = Model.MainPart.BalloonWeld
	BalloonWeld.Part0 = BalloonWeld.Parent
	BalloonWeld.Part1 = Model.Balloon
	BalloonWeld.C0 = CFrame.new(0, 12, 0)
	
	local LeftWeld = Model.MainPart.LeftWallWeld
	LeftWeld.Part0 = LeftWeld.Parent
	LeftWeld.Part1 = Model.LeftWall
	LeftWeld.C0 = CFrame.new(((Model.LeftWall.Size.X / 2) + (Model.MainPart.Size.X / 2) - Model.FrontWall.Size.X), ((Model.LeftWall.Size.Y / 2) + (Model.MainPart.Size.Y / 2)), 0)

	local RightWeld = Model.MainPart.RightWallWeld
	RightWeld.Part0 = RightWeld.Parent
	RightWeld.Part1 = Model.RightWall
	RightWeld.C0 = CFrame.new(-((Model.RightWall.Size.X / 2) + (Model.MainPart.Size.X / 2) - Model.FrontWall.Size.X), ((Model.RightWall.Size.Y / 2) + (Model.MainPart.Size.Y / 2)), 0)
	
	local FrontWeld = Model.MainPart.FrontWallWeld
	FrontWeld.Part0 = FrontWeld.Parent
	FrontWeld.Part1 = Model.FrontWall
	FrontWeld.C0 = CFrame.new(0, ((Model.FrontWall.Size.Y / 2) + (Model.MainPart.Size.Y / 2)), ((Model.FrontWall.Size.Z / 2) + (Model.MainPart.Size.Z / 2) - Model.FrontWall.Size.Z))

	local BackWeld = Model.MainPart.BackWallWeld
	BackWeld.Part0 = BackWeld.Parent
	BackWeld.Part1 = Model.BackWall
	BackWeld.C0 = CFrame.new(0, ((Model.BackWall.Size.Y / 2) + (Model.MainPart.Size.Y / 2)), -((Model.BackWall.Size.Z / 2) + (Model.MainPart.Size.Z / 2) - Model.BackWall.Size.Z))
	
	local FireWeld1 = Model.MainPart.FireWeld1
	FireWeld1.Part0 = FireWeld1.Parent
	FireWeld1.Part1 = Model.FirePart1
	FireWeld1.C0 = CFrame.new(0, 9.5, -0.25)
	
	local BalloonScriptClone = BalloonScript:Clone()
	BalloonScriptClone.Disabled = false
	BalloonScriptClone.Parent = Model
		
	return {
		Balloon = Model,
		Creator = Model.Creator,
		MainPart = Model.MainPart,
		BodyGyro = Model.MainPart.FlyingGyro,
		BodyVelocity = Model.MainPart.FlyingForce,
		FirePart = Model.FirePart1,
		Fire = Model.FirePart1.Fire,
		FireSound = Model.FirePart1.FireSound,
	}
	
end

function BeginFlight()
	
	if not CurrentBalloon or not CurrentBalloon.Balloon or not CurrentBalloon.Balloon.Parent then
		return
	end
		
	local MainPart = CurrentBalloon.Balloon:FindFirstChild("MainPart")
	if not MainPart then
		return
	end
	
	Flying = true
	
	pcall(function()
		GuiClone.Frame.Message.Text = "Click and Hold to direct the Balloon in the" .. "\n" .. "direction you are looking. Holding with both" .. "\n".. "mouse buttons gives easy free flight."
	end)
	
	ControlBalloon()
	
end

function EndFlight()
	
	if CurrentBalloon and CurrentBalloon.Balloon.Parent then
		for i, v in pairs({CurrentBalloon.Fire}) do
			if v and v.Parent then
				v.Enabled = false
			end
		end
	end
	
	Flying = false
	
	pcall(function()
		GuiClone.Frame.Message.Text = "Click to place a Balloon." .. "\n".. "Get into a Balloon to fly it."
	end)
	
end

function ControlBalloon()
	
	if not CurrentBalloon or not CurrentBalloon.Balloon.Parent or not CurrentBalloon.MainPart.Parent or not CurrentBalloon.BodyGyro.Parent or not CurrentBalloon.BodyVelocity.Parent then
		return
	end
	
	local MainPart = CurrentBalloon.MainPart
	local FlyingForce = CurrentBalloon.BodyVelocity
	local FlyingGyro = CurrentBalloon.BodyGyro
	local FirePart1 = CurrentBalloon.FirePart1
	local Fire = CurrentBalloon.Fire
	
	local SoundPlaying = false	
	
	local BalloonMass = 0
	for i, v in pairs(GetAllConnectedParts(MainPart)) do
		BalloonMass = (BalloonMass + v:GetMass())
	end
	BalloonMass = (BalloonMass * 2 * 196.20)
	FlyingForce.maxForce = Vector3.new(BalloonMass, BalloonMass, BalloonMass)
	
	local CurrentVelocity = math.min(MaxSpeed, FlyingForce.velocity.magnitude)	
	
	local LastTime = tick()
	local DesiredFlightCFrame = MainPart.CFrame
	
	while ToolEquipped and Flying do
		local Now = tick()
		local Time = (Now - LastTime)
		LastTime = Now
		
		if Flying then
			
			local CoordinateFrame = InvokeClient("GetCamera", {Property = "CoordinateFrame"})
			local MoveDirection = (CoordinateFrame * CFrame.Angles(0.6, 0, 0))
			if MouseDown then
				local Theta = math.acos(DesiredFlightCFrame.lookVector:Dot(MoveDirection.lookVector))
				local Frac = math.min(0.7, (0.7 * Time / Theta))
				local Unit = Slerp(Frac, DesiredFlightCFrame.lookVector, MoveDirection.lookVector)
				DesiredFlightCFrame = CFrame.new(Vector3.new(0, 0, 0), Unit)
				
				if CurrentVelocity < MaxSpeed then
					CurrentVelocity = math.min((CurrentVelocity + 8 * Time), MaxSpeed)
				end
			else
				if CurrentVelocity > 2 then
					CurrentVelocity = math.max(0, (CurrentVelocity - 3 * Time))
				end
			end
			
			local Direction = DesiredFlightCFrame.lookVector
			local DirectionXZ = Vector3.new(Direction.X, 0, Direction.Z).unit
			
			FlyingGyro.cframe = CFrame.new(Vector3.new(), DirectionXZ) * CFrame.Angles(0, 0, 0) --CFrame.Angles(0, 0, (MainPart.RotVelocity.y / 3 * (1 - math.abs(Direction.Y) ^ 2)))
			
			if FirePart1 and FirePart1.Parent then
				local FireSound = FirePart1:FindFirstChild("FireSound")
				if FireSound then
					if Direction.y > 0 then
						if not SoundPlaying then
							SoundPlaying = true
							FireSound:Play()
						end
					else
						SoundPlaying = false
						FireSound:Stop()
					end
				end
			end
			for i, v in pairs({Fire}) do
				if v and v.Parent then
					v.Enabled = MouseDown --(Direction.y > 0 and CurrentVelocity > 2)
				end
			end
			local SlowDownFactor = math.abs(MainPart.RotVelocity.Y / 3)
			FlyingForce.velocity = (Direction.unit * (CurrentVelocity - SlowDownFactor) * (1 - Direction.Y ^ 2))
		end
		wait()
	end
end

function SetUpConnections()
	for i, v in pairs(Connections) do
		if v then
			v:disconnect()
		end
	end
	Connections = {}
	if CurrentBalloon and CurrentBalloon.Balloon then
		local Balloon = CurrentBalloon.Balloon
		local BalloonRemoved = Balloon.Changed:connect(function(Property)
			if Property == "Parent" and not Balloon.Parent then
				Handle.Transparency = 0
			end
		end)
		for i, v in pairs(Balloon:GetChildren()) do
			if v:IsA("Seat") then
				local SeatWeldAdded = v.ChildAdded:connect(function(Child)
					if Child:IsA("JointInstance") and Child.Name == "SeatWeld" and not Flying then
						if ((Child.Part0 and Child.Part0.Parent == Character) or (Child.Part1 and Child.Part1.Parent == Character)) then
							Seated = true
							BeginFlight()
						end
					end
				end)
				local SeatWeldRemoved = v.ChildRemoved:connect(function(Child)
					if Child:IsA("JointInstance") and Child.Name == "SeatWeld" and Flying then
						if ((Child.Part0 and Child.Part0.Parent == Character) or (Child.Part1 and Child.Part1.Parent == Character)) then
							Seated = false
							EndFlight()
						end
					end
				end)
				for i, v in pairs({BalloonRemoved, SeatWeldAdded, SeatWeldRemoved}) do
					if v then
						table.insert(Connections, v)
					end
				end
			end
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			GuiClone = Gui:Clone()
			GuiClone.Frame.Message.Text = "Click to create a Balloon." .. "\n" .. "Get into a Balloon to fly it."
			GuiClone.Parent = PlayerGui
		end
	end)
	Spawn(function()
		if CurrentBalloon and CurrentBalloon.Balloon.Parent then
			Handle.Transparency = 1
			if Seated then
				BeginFlight()
			end
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	MouseDown = false
	EndFlight()
	if GuiClone and GuiClone.Parent then
		GuiClone:Destroy()
	end
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "MouseClick" then
			local Down = value.Down
			if Down then
				MouseDown = true
				if (tick() - DeployTick) > IdleDuration and (not CurrentBalloon or not CurrentBalloon.Balloon.Parent) then
					DeployTick = tick()
					Seated = false
					Flying = false
					Handle.Transparency = 1
					local MousePosition = InvokeClient("MousePosition")
					local Direction = CFrame.new(Torso.Position, MousePosition.Position)
					CurrentBalloon = CreateBalloon()
					local Balloon = CurrentBalloon.Balloon
					local MainPart = CurrentBalloon.MainPart
					TransformModel(Balloon, Balloon:GetModelCFrame(), (((Torso.CFrame + Vector3.new(0, 3, 0)) + Direction.lookVector * 10) * CFrame.Angles(0, 0, 0)), true)
					MainPart.CFrame = CFrame.new(Vector3.new(MainPart.Position.X, Torso.Position.Y, MainPart.Position.Z), Torso.Position)
					CurrentBalloon.BodyGyro.cframe = MainPart.CFrame
					Balloon.Parent = game:GetService("Workspace")
					SetUpConnections(CurrentBalloon)
				end
			else
				MouseDown = false
			end
		elseif mode == "KeyPress" then
			local Key = value.Key
			local ByteKey = string.byte(Key)
			local Down = value.Down
			if Key == "x" and Down then
				if CurrentBalloon and CurrentBalloon.Balloon.Parent then
					CurrentBalloon.Balloon:Destroy()
				end
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		if CurrentBalloon and CurrentBalloon.Balloon.Parent then
			CurrentBalloon.Balloon:Destroy()
		end
	end
end)

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)