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

Sounds = {
	Song1 = Handle:WaitForChild("Song1"),
	Song2 = Handle:WaitForChild("Song2"),
	Song3 = Handle:WaitForChild("Song3"),
}

Animations = {
	Playing = {Animation = AnimationsFolder:WaitForChild("Playing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

ToolEquipped = false

ServerControl = (RemoteFolder:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = RemoteFolder,
})

ClientControl = (RemoteFolder:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = RemoteFolder,
})

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	local Arms = {"Left Arm", "Right Arm"}
	for i, v in pairs(Arms) do
		local Arm = Character:FindFirstChild(v)
		if not Arm then
			Tool.Enabled = true
			return
		end
	end
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	SetUpGuitar()
	
	local Duration = 15	
	
	local RandomSongs = {Sounds.Song1, Sounds.Song2, Sounds.Song3}
	local RandomSong = RandomSongs[math.random(1, #RandomSongs)]
	
	RandomSong:Play()
	
	wait(Duration)
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	RandomSong:Stop()
	
	if CurrentlyEquipped then
		DismountGuitar()
	end
	
	Tool.Enabled = true
	
end

function SetUpGuitar()
	Handle.Transparency = 1
	FakeHandle = Handle:Clone()
	FakeHandle.Name = "FakeHandle"
	FakeHandle.Transparency = 0
	local TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = FakeHandle,
		C0 = CFrame.new(0, 0, 0),
		C1 = (CFrame.new(0, -1, -0.5) * CFrame.Angles((math.pi / 2), 0, -(math.pi / 4))),
		Parent = FakeHandle,
	}
	FakeHandle.Parent = Tool
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Playing)
	end)
end

function DismountGuitar()
	for i, v in pairs(Animations) do
		Spawn(function()
			InvokeClient("StopAnimation", v)
		end)
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "FakeHandle" then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
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
	ToolEquipped = true
end

function Unequipped()
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	DismountGuitar()
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
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)