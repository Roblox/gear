--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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

Animations = {
	Equipped = {Animation = AnimationsFolder:WaitForChild("Equipped"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Strum = {Animation = AnimationsFolder:WaitForChild("Strum"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Song1 = {Sound = Handle:WaitForChild("Song1"), WaitTime = 11, StepTime = 0.37},
	Song2 = {Sound = Handle:WaitForChild("Song2"), WaitTime = 9.1, StepTime = 0.52},
	Song3 = {Sound = Handle:WaitForChild("Song3"), WaitTime = 8.1, StepTime = 0.49},
}

Damage = 12

NoteData = {
	Chords = {
		{Key = "F", Sound = 55741213},
		{Key = "T", Sound = 55741275},
		{Key = "G", Sound = 55741329},
		{Key = "Y", Sound = 55741380},
		{Key = "H", Sound = 55741420},
		{Key = "J", Sound = 55741464},
		{Key = "N", Sound = 55741505},
		{Key = "K", Sound = 55741543},
		{Key = "M", Sound = 55741584},
		{Key = "L", Sound = 55741617},
		{Key = "P", Sound = 55741662},
		{Key = "Semicolon", Sound = 55741702},
		{Key = "Quote", Sound = 55741744},
	},
	Pitches = {
	},
}

Sound = {
	Volume = 1,
	Pitch = 1,
}

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
})

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if not LeftArm or not RightArm then
		return
	end

	Tool.Enabled = false
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	local Songs = {Sounds.Song1, Sounds.Song2, Sounds.Song3}
	local Song = Songs[math.random(1, #Songs)]
	
	Song.Sound:Play()
	
	local TimeWaited = 0
	while TimeWaited < Song.WaitTime and CurrentlyEquipped do
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Strum)
		end)
		wait(Song.StepTime)
		TimeWaited = (TimeWaited + Song.StepTime)
	end
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	Tool.Enabled = true
end

function SetUpGuitar()
	Handle.Transparency = 1
	local FakeHandle = Handle:Clone()
	FakeHandle.Name = "FakeHandle"
	FakeHandle.Transparency = 0
	local TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = FakeHandle,
		C1 = (CFrame.new(-0.2, 0.6, -0.4) * CFrame.Angles((math.pi / 2), math.pi, -(math.pi / 4))),
		Parent = FakeHandle,
	}
	FakeHandle.Parent = Tool
end

function DismountGuitar()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
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
	Spawn(SetUpGuitar)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equipped)
	end)
	ShiftDown = false
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Sounds) do
		v.Sound:Stop()
	end
	DismountGuitar()
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
	if Mode == "KeyPressed" and Value and Tool.Enabled then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "LeftShift" or Key == "RightShift" then
			ShiftDown = Down
		elseif Down then
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
							InvokeClient("PlayAnimation", Animations.Strum)
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
	end
end

DismountGuitar()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)