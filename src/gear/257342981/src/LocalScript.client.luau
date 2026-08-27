--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

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

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

InputCheck = Create("ScreenGui"){
	Name = "InputCheck",
	Create("ImageButton"){
		Name = "InputButton",
		Image = "",
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = InputCheck,
	}
}

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

Arrow = BasePart:Clone()
Arrow.Name = "Arrow"
Arrow.BrickColor = BrickColor.new("Lime green")
Arrow.Size = Vector3.new(1, 0.25, 1)
Arrow.CanCollide = false
Arrow.Anchored = true
ArrowMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "14656345"),
	TextureId = (BaseUrl .. "109635220"),
	Scale = Vector3.new(0.05, 0.1, 0.03),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Arrow,
}

Rate = (1 / 60)

MouseDown = false
ToolEquipped = false

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
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function MouseClick(Down)
	if Down and not MouseDown and Tool.Enabled then
		if not PlayerMouse.Target then
			return
		end
		local StartPoint = PlayerMouse.Hit.p
		if (Handle.Position - StartPoint).magnitude > 50 then
			return
		end
		MouseDown = true
		Spawn(function()
			local Camera = game:GetService("Workspace").CurrentCamera
			local DisplayArrow, Direction
			while MouseDown and ToolEquipped and CheckIfAlive() do
				local CurrentPoint = PlayerMouse.Hit.p
				local DistanceCap = {Min = 15, Max = 100}
				local OriginalDistance = (StartPoint - CurrentPoint).magnitude
				local Distance = Clamp(OriginalDistance, DistanceCap.Min, DistanceCap.Max)
				if OriginalDistance >= DistanceCap.Min then
					if not DisplayArrow or not DisplayArrow.Parent then
						DisplayArrow = Arrow:Clone()
						Debris:AddItem(DisplayArrow, 15)
						DisplayArrow.Parent = Camera
					end
					local DistancePercent = GetPercentage(DistanceCap.Min, DistanceCap.Max, Distance)
					local Color = {
						R = Clamp((1 * DistancePercent / 100), 0, 1),
						G = Clamp(((DistancePercent < 100 and (2 / DistancePercent * 100)) or 0), 0, 1),
						B = 0,
					}
					DisplayArrow.Mesh.VertexColor = Vector3.new(Color.R, Color.G, Color.B)
					Direction = CFrame.new(StartPoint, Vector3.new(CurrentPoint.X, StartPoint.Y, CurrentPoint.Z))
					local OriginPoint = (CFrame.new(StartPoint) + Direction.lookVector * (Distance / 2))
					DisplayArrow.CFrame = CFrame.new(OriginPoint.p, Vector3.new(CurrentPoint.X, OriginPoint.p.Y, CurrentPoint.Z))
					DisplayArrow.Mesh.Scale = Vector3.new((15 * Arrow.Mesh.Scale.X), Arrow.Mesh.Scale.Y, (Distance * Arrow.Mesh.Scale.Z))
				else
					if DisplayArrow and DisplayArrow.Parent then
						DisplayArrow.Parent = nil
						Direction = nil
					end
				end
				wait(Rate)
			end
			if DisplayArrow and DisplayArrow.Parent then
				DisplayArrow:Destroy()
			end
			if not ToolEquipped or not CheckIfAlive() then
				return
			end
			if not StartPoint or not Direction then
				StartPoint = (Torso.CFrame * CFrame.new(8, 0, 0)).p
				Direction = Torso.CFrame
			end
			InvokeServer("SpawnStampede", {SpawnPoint = StartPoint, Direction = Direction})
			MouseDown = false
		end)
	elseif not Down and MouseDown then
		MouseDown = false
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		PlayerMouse = Player:GetMouse()
		Mouse.Button1Down:connect(function()
			MouseClick(true)
		end)
		Mouse.Button1Up:connect(function()
			MouseClick(false)
		end)
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			if UserInputService.TouchEnabled then
				InputCheckClone = InputCheck:Clone()
				InputCheckClone.InputButton.InputBegan:connect(function()
					MouseClick(true)
				end)
				InputCheckClone.InputButton.InputEnded:connect(function()
					MouseClick(false)
				end)
				InputCheckClone.Parent = PlayerGui
			end
		end
	end)
end

function Unequipped()
	if InputCheckClone and InputCheckClone.Parent then
		InputCheckClone:Destroy()
	end
	MouseDown = false
	ToolEquipped = false
end

function InvokeServer(mode, value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(mode, value)
		return ServerReturn
	end)
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not value then
		return
	end
	if mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)