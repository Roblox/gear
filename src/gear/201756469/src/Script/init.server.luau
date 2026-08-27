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


Folders = Tool:WaitForChild("Folders")
AnimationsFolder = Folders:WaitForChild("Animations")
RemoteFolder = Folders:WaitForChild("Remotes")

Grips = {
	Hold = CFrame.new(0, 0.3, -0.05, 1, 0, -0, 0, 1, 1.97913341e-005, 0, -1.97913341e-005, 1),
	Play = CFrame.new(0, 1.25, -0.1, 0.90927124, 0.381022066, 0.167475626, -0.138348684, 0.6562047, -0.741791666, -0.392537355, 0.651319802, 0.649381936),
	Unequipped = CFrame.new(-0.8, -1.25, 0.7, -0.699250817, 8.10044512e-005, 0.714876533, 0.714876533, 1.1920929e-007, 0.699250817, 5.65572336e-005, 1, -5.79915431e-005),
	Smash = CFrame.new(0, 1.25, -0.1, 0.862269044, 0.497923523, 0.092543155, -0.505507767, 0.85731715, 0.0973098949, -0.030885946, -0.130688593, 0.990942299),
}

Animations = {
	Hold = {Animation = AnimationsFolder:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	Pluck = {Animation = AnimationsFolder:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = 6},
	Smash = {Animation = AnimationsFolder:WaitForChild("Smash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.6},
}

Sounds = {
	GuitarSmash = Handle:WaitForChild("GuitarSmash"),
}

NoteData = {
	Chords = {
		{Key = "Z", Sound = {Normal = 99170172, Sharp = 99189531}},
		{Key = "X", Sound = {Normal = 99170311, Sharp = 99189711}},
		{Key = "C", Sound = {Normal = 99170354, Sharp = 99189785}},
		{Key = "V", Sound = {Normal = 99170403, Sharp = 99190216}},
		{Key = "B", Sound = {Normal = 99170481, Sharp = 99189905}},
		{Key = "N", Sound = {Normal = 99170537, Sharp = 99190021}},
		{Key = "M", Sound = {Normal = 99170583, Sharp = 99190550}},
	},
	Pitches = {
		{Key = "G", Pitch = 0.5},
		{Key = "H", Pitch = 0.75},
		{Key = "J", Pitch = 1},
		{Key = "K", Pitch = 1.25},
		{Key = "L", Pitch = 1.5},
	},
}

Sound = {
	Volume = 0.75,
	Pitch = NoteData.Pitches[3].Pitch,
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

Clicks = 0
FirstClick = false
Broken = false

IsPlaying = false
ShiftDown = false
ToolEquipped = false

ServerControl = (RemoteFolder:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = RemoteFolder,
})

ClientControl = (RemoteFolder:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = RemoteFolder,
})

GuitarModule = require(191816425)
GuitarTable = GuitarModule.GetTable({Key = "Guitars"})
GuitarFunctions = GuitarTable.GetData({
	Tool = Tool,
	Communication = {Server = ServerControl, Client = ClientControl},
	KeyData = NoteData,
	SpecialEnabled = {Enabled = false, AcceptedRatio = 0.75},
})

SmashingGuitar = require(script:WaitForChild("GuitarParts"))

Handle.Transparency = 0
Tool.Grip = Grips.Hold
Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or Broken then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		if IsPlaying and Clicks > 1 then
			Broken = true
			local humanoid = Humanoid
			humanoid.WalkSpeed = 0
			Tool.Grip = Grips.Smash
			local Animation = Animations.Smash
			InvokeClient("PlayAnimation", Animation)
			wait(Animation.Duration)
			if CurrentlyEquipped then
				local RayHit, RayPos, RayNormal = RayCast(Handle.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
				if RayHit then
					local Duration = 10
					local FirePart = BasePart:Clone()
					FirePart.Name = "FirePart"
					FirePart.Transparency = 1
					FirePart.Size = Vector3.new(0.2, 0.2, 0.2)
					FirePart.Anchored = true
					FirePart.CanCollide = false
					FirePart.Locked = true
					local Fire = Create("Fire"){
						Color = Color3.new((236 / 255), (139 / 255), (70 / 255)),
						SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255)),
						Heat = 25,
						Size = 15,
						Enabled = true,
						Parent = FirePart,
					}
					FirePart.CFrame = (CFrame.new(RayPos) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
					Handle.Transparency = 1
					Sounds.GuitarSmash:Play()
					local SmashedGuitar = SmashingGuitar()
					table.sort(SmashedGuitar.Welds, (function(a, b)
						return a.Part1.Position.Y < b.Part1.Position.Y
					end))
					Debris:AddItem(SmashedGuitar.GuitarModel, (Duration + 5))
					local Weld = Create("Weld"){
						Part0 = Handle,
						Part1 = SmashedGuitar.CenterPart,
						C0 = CFrame.new(0, 0, 0),
						C1 = CFrame.new(0, 0, 0),
						Parent = SmashedGuitar.CenterPart,
					}
					SmashedGuitar.GuitarModel.Parent = game:GetService("Workspace")
					for i, v in pairs(SmashedGuitar.Welds) do
						if v and v.Parent then
							v:Destroy()
						end
						for i, v in pairs(SmashedGuitar.Parts) do
							if v and v.Parent and v.Velocity.Y > 2 then
								v.Velocity = Vector3.new(0, 0, 0)
								v.RotVelocity = Vector3.new(0, 0, 0)
							end
						end
					end
					Debris:AddItem(FirePart, Duration)
					FirePart.Parent = game:GetService("Workspace")
				else
					Broken = false
				end
			else
				Broken = false
			end
			humanoid.WalkSpeed = 16
			if Broken then
				humanoid:UnequipTools()
				Tool:Destroy()
			else
				Tool.Grip = Grips.Play
			end
		else
			IsPlaying = not IsPlaying
			if IsPlaying then
				Tool.Grip = Grips.Play
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.Hold)
				end)
			else
				Tool.Grip = Grips.Hold
				for i, v in pairs(Animations) do
					Spawn(function()
						InvokeClient("StopAnimation", v)
					end)
				end
			end
		end
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Hold
	IsPlaying = false
	ShiftDown = false
	ToolEquipped = true
end

function Unequipped()
	IsPlaying = false
	ShiftDown = false
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
	if player ~= Player then
		return
	end
	if Mode == "KeyPressed" and Value then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "LeftShift" or Key == "RightShift" then
			ShiftDown = Down
		elseif IsPlaying and Down then
			if NoteData.Chords then
				for i, v in pairs(NoteData.Chords) do
					if string.lower(v.Key) == string.lower(Key) then
						GuitarFunctions.PlaySound({
							Object = Handle,
							Sound = {SoundId = v, ShiftDown = ShiftDown},
							Pitch = (Sound.Pitch or v.Pitch or nil),
							Volume = (Sound.Volume or v.Volume or nil),
						})
						Spawn(function()
							InvokeClient("PlayAnimation", Animations.Pluck)
						end)
						return
					end
				end
			end
			if NoteData.Pitches then
				for i, v in pairs(NoteData.Pitches) do
					if string.lower(v.Key) == string.lower(Key) then
						Sound.Pitch = v.Pitch
						return
					end
				end
			end
		end
	elseif Mode == "IsPlaying" then
		return IsPlaying
	elseif Mode == "SpecialCompleted" and Value then
		local Success = Value.Success
		local SuccessRatio = Value.SuccessRatio
		if Success then
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)