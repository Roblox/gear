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
	Hold = CFrame.new(-0.3, 0.35, -0.05, 0.780771196, -0.624816954, -9.65498657e-006, 0.624816895, 0.780771315, 1.2064872e-005, 0, -1.5452506e-005, 1),
	Play = CFrame.new(-1.1, 1.25, -0.1, 0.775343955, -0.196550965, 0.600174427, 0.552064478, 0.672464013, -0.492967427, -0.306702495, 0.713554323, 0.62989974),
	Unequipped = CFrame.new(0.5, -1.25, 0.7, -1, 8.10044585e-005, -1.06224526e-011, 0, 1.31134158e-007, 1, 8.10044585e-005, 1, -1.31134158e-007),
}

Animations = {
	Hold = {Animation = AnimationsFolder:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	Pluck = {Animation = AnimationsFolder:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = 6},
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
		{Key = "G", Pitch = 2},
		{Key = "H", Pitch = 2.25},
		{Key = "J", Pitch = 2.5},
		{Key = "K", Pitch = 2.75},
		{Key = "L", Pitch = 3},
	},
}

Sound = {
	Volume = 0.75,
	Pitch = NoteData.Pitches[3].Pitch,
}

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
	UnequippedDisplay = {Enabled = true, Grips = Grips},
	SpecialEnabled = {Enabled = true, AcceptedRatio = 0.75},
})

LightningModule = require(script:WaitForChild("LightningModule"))()

Handle.Transparency = 0
Tool.Grip = Grips.Hold
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
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
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
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
			LightningModule.Strike({
				Player = Player,
				Position = (Handle.CFrame * CFrame.new((Handle.Size.X / 3.5), -(Handle.Size.Y / 3.5), 0)).p,
			})
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)