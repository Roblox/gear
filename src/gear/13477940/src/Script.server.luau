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
RemoteFolder = Folders:WaitForChild("Remotes")

NoteData = {
	Chords = {
		{Key = "F", Sound = 13032178, Pitch = 0.8, Message = "Space I Chord"},
		{Key = "G", Sound = 13032191, Pitch = 0.8, Message = "Space I-VII Transition"},
		{Key = "H", Sound = 13032199, Pitch = 0.8, Message = "Space V Chord"},
		{Key = "J", Sound = 13032204, Pitch = 1, Message = "Space V-VII Transition"},
		{Key = "K", Sound = 13032190, Pitch = 1, Message = "Space IV Chord"},
		{Key = "L", Sound = 13032184, Pitch = 1, Message = "Space III Chord"},
	},
	Pitches = {
	},
}

Sound = {
	Volume = 1,
	Pitch = 1,
}

CurrentSound = NoteData.Chords[1]

IsPlaying = true
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
	UnequippedDisplay = {Enabled = false},
	SpecialEnabled = {Enabled = false, AcceptedRatio = 0.75},
})

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	Tool.Enabled = false
	GuitarFunctions.PlaySound({
		Object = Handle,
		Sound = {SoundId = CurrentSound, ShiftDown = ShiftDown},
		Pitch = (Sound.Pitch or CurrentSound.Pitch or nil),
		Volume = (Sound.Volume or CurrentSound.Volume or nil),
	})
	GuitarFunctions.PlayNote()
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
	IsPlaying = true
	ShiftDown = false
	ToolEquipped = true
end

function Unequipped()
	IsPlaying = true
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
						CurrentSound = v
						GuitarFunctions.DisplayTune(CurrentSound.Message)
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