--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SparkleParticle = script:WaitForChild("Sparkles")

Animations = {
	Sit = {Animation = Tool:WaitForChild("Sit"), FadeTime = nil, Weight = nil, Speed = nil},	
	R15Sit = {Animation = Tool:WaitForChild("R15Sit"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	VacuumSound = Handle:WaitForChild("VacuumSound"),
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

Rate = (1 / 30)
Gravity = 196.20

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

Handle.Transparency = 0
Tool.Enabled = true

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

function CraftBroom(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle then
			v:Destroy()
		end
	end
	Handle.Transparency = ((CreateNew and 1) or 0)
	if not CreateNew or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local BroomModel = Create("Model"){
		Name = "Broom",
	}
	Broom = BasePart:Clone()
	Broom.Name = "Broom"
	Broom.Size = Vector3.new(1, 1, 8)
	Broom.CanCollide = true
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshId = (BaseUrl .. "313011675"),
		TextureId = (BaseUrl .. "313011815"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Broom,
	}
	Sparkles = SparkleParticle:Clone()
	Sparkles.Enabled = false
	Sparkles.Parent = Broom
	local Lantern = BasePart:Clone()
	Lantern.Name = "Lantern"
	Lantern.CanCollide = false
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshId = (BaseUrl .. "313011730"),
		TextureId = (BaseUrl .. "313011815"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Lantern,
	}
	Create("PointLight"){
		Name = "Light",
		Color = Color3.new((255 / 255), (255 / 255), (127 / 255)),
		Brightness = 50,
		Range = 6,
		Shadows = false,
		Enabled = true,
		Parent = Lantern,
	}
	local Weld = Create("Weld"){
		Part0 = Broom,
		Part1 = Lantern,
		C0 = CFrame.new(0, -1, -3.05),
		C1 = CFrame.new(0, 0, 0),
		Parent = Lantern,
	}
	local Cogs = {
		{Name = "FrontLeftCog", MeshId = "313011792", C0 = (CFrame.new(0.15, 1.15, 2) * CFrame.Angles(0, (math.pi / 2), 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2),0))},
		{Name = "FrontRightCog", MeshId = "313011792", C0 = (CFrame.new(-0.15, 1.15, 2) * CFrame.Angles(0, (math.pi - (math.pi / 2)), 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 2),0))},
		{Name = "BackLeftCog", MeshId = "313011756", C0 = (CFrame.new(0.15, 0.8125, 3.4) * CFrame.Angles(0, (math.pi / 2), 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2),0))},
		{Name = "BackRightCog", MeshId = "313011756", C0 = (CFrame.new(-0.15, 0.8125, 3.4) * CFrame.Angles(0, (math.pi - (math.pi / 2)), 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 2),0))},
	}
	CogParts = {}
	for i, v in pairs(Cogs) do
		local Cog = BasePart:Clone()
		Cog.Name = "Cog"
		Cog.CanCollide = false
		Create("SpecialMesh"){
			Name = "Mesh",
			MeshId = (BaseUrl .. v.MeshId),
			TextureId = (BaseUrl .. "313011815"),
			Scale = Vector3.new(1, 1, 1),
			VertexColor = Vector3.new(1, 1, 1),
			Offset = Vector3.new(0, 0, 0),
			Parent = Cog,
		}
		local Motor = Create("Motor6D"){
			Part0 = Broom,
			Part1 = Cog,
			C0 = v.C0,
			C1 = v.C1,
			MaxVelocity = 0,
			DesiredAngle = 99999999,
			CurrentAngle = 0,
			Parent = Cog,
		}
		table.insert(CogParts, {Part = Cog, Motor = Motor})
	end
	Broom.CFrame = Handle.CFrame
	BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(math.huge, math.huge, math.huge),
		position = Broom.Position,
		Parent = Broom,
	}
	BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Torso.CFrame,
		Parent = Broom,
	}
	Broom.CanCollide = true
	TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = Broom,
		C0 = (CFrame.new(0, -1.5, 1.5) * CFrame.Angles(0, 0, 0)),
		C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)),
		Parent = Broom,
	}
	for i, v in pairs({Broom, Lantern}) do
		v.Parent = BroomModel
	end
	for i, v in pairs(CogParts) do
		v.Part.Parent = BroomModel
	end
	BroomModel.Parent = Tool
end

function FlyBroom()
	
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	
	CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	local Delta = 0
	BroomGoTo = nil
	
	if MouseDownChanged then
		MouseDownChanged:disconnect()
	end
	
	local LastValue = MouseDown.Value	
	
	local Charge = {Start = tick(), Max = 1.5}
	
	local Sound
	
	MouseDownChanged = MouseDown.Changed:connect(function()
		if not CheckIfAlive() or not ToolEquipped or LastValue == MouseDown.Value then
			return
		end
		LastValue = MouseDown.Value
		if MouseDown.Value then
			Sparkles.Enabled = true
			Sound = Sounds.VacuumSound:Clone()
			Sound.Parent = Broom
			for i, v in pairs(CogParts) do
				v.Motor.MaxVelocity = 0.05
			end
			Sound.Pitch = 0
			Sound.Volume = 0
			Sound:Play()
			Charge.Start = tick()
		elseif not MouseDown.Value then
			Sparkles.Enabled = false
			local CurrentSound = Sound
			for i, v in pairs(CogParts) do
				v.Motor.MaxVelocity = 0
			end
			Spawn(function()
				if ButtonClickedAgain then
					ButtonClickedAgain:disconnect()
				end
				local ClickedAgain = false
				ButtonClickedAgain = MouseDown.Changed:connect(function()
					if MouseDown.Value then
						ClickedAgain = true
					end
				end)
				local DecreaseRate = 25
				local WaitRate = 0.025
				local Volume = (CurrentSound.Volume / DecreaseRate)
				local Pitch = (CurrentSound.Pitch / DecreaseRate)
				for i = 1, DecreaseRate do
					if ClickedAgain or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() or not CurrentSound or not CurrentSound.Parent then
						break
					end
					local DecreaseAmount = (DecreaseRate - i)
					CurrentSound.Volume = (Volume * DecreaseAmount)
					CurrentSound.Pitch = (Pitch * DecreaseAmount)
					wait(WaitRate)
				end
				if ButtonClickedAgain then
					ButtonClickedAgain:disconnect()
				end
				CurrentSound.Volume = 0
				CurrentSound.Pitch = 0
				CurrentSound:Stop()
				if CurrentSound and CurrentSound.Parent then
					CurrentSound:Destroy()
				end
			end)
		end
	end)
	while CheckIfAlive() and ToolEquipped and Broom and Broom.Parent and TorsoWeld and TorsoWeld.Parent and TorsoWeld.Part0 == Torso and TorsoWeld.Part1 == Broom and CurrentlyEquipped do
		local Now = tick()
		local ChargePercent = (Clamp(GetPercentage(Charge.Start, (Charge.Start + Charge.Max), Now), 0, 100) * 0.01)
		if MouseDown.Value and Sound and Sound.Parent then
			Sound.Volume = Clamp((1 * ChargePercent), 0, 0.25)
			Sound.Pitch = Clamp((1 * ChargePercent), 1, 2)
		end
		local Speed = ((MouseDown.Value and 20) or 0)
		local DeltaSpeed = (Speed * (Delta / Rate))
		if BroomGoTo then
			local BroomGoToWorld = (Broom.Position + BroomGoTo)
			BodyGyro.cframe = CFrame.new(Broom.Position, BroomGoToWorld)
		end
		BodyPosition.position = (Broom.Position + Broom.CFrame.lookVector * Speed)
		Delta = wait()
	end
	if MouseDownChanged then
		MouseDownChanged:disconnect()
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent and Player:IsA("Player")) and true) or false)
end

function Activated()
	if not CheckIfAlive() or not ToolEquipped or not Tool.Enabled or (Broom and Broom.Parent) then
		return
	end
	Tool.Enabled = false
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", Animations.R15Sit)
			elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
				InvokeClient("PlayAnimation", Animations.Sit)
			end
		end
	end)
	Spawn(function()
		InvokeClient("DisableJump", true)
	end)
	Spawn(function()
		Humanoid.WalkSpeed = 0
		Humanoid.AutoRotate = false
		CraftBroom(true)
		FlyBroom()
	end)
	Tool.Enabled = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
	end
	CraftBroom(false)
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
		local Hit = value
		if MouseDown.Value and Broom and Broom.Parent then
			BroomGoTo = (Hit.p - Broom.Position)
		end
	elseif action == "Dismount" then
		local Dismount = value.Dismount
		if Dismount then
			EndFlight = true
		end
	end
end

CraftBroom(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)