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
	Playing = {Animation = AnimationsFolder:WaitForChild("Playing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	TwoHandEquip = {Animation = AnimationsFolder:WaitForChild("TwoHandEquip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	AxeSlash = {Animation = AnimationsFolder:WaitForChild("AxeSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	MusicTable = { 
		Handle:FindFirstChild("C5"), 
		Handle:FindFirstChild("CSharp5"), 
		Handle:FindFirstChild("D5"), 
		Handle:FindFirstChild("EFlat5"), 
		Handle:FindFirstChild("E5"), 
		Handle:FindFirstChild("F5"), 
		Handle:FindFirstChild("FSharp5"), 
		Handle:FindFirstChild("G5"), 
		Handle:FindFirstChild("AFlat5"), 
		Handle:FindFirstChild("A5"), 
		Handle:FindFirstChild("BFlat5"), 
		Handle:FindFirstChild("B5"), 
		Handle:FindFirstChild("C6"),
	},
	Songs = {
		Song1 = Handle:WaitForChild("Song1"),
		Song2 = Handle:WaitForChild("Song2"),
		Song3 = Handle:WaitForChild("Song3"),
	},
	Attacks = {
		Unsheath = Handle:WaitForChild("Unsheath"),
		Slash = Handle:WaitForChild("Slash"),
		Lunge = Handle:WaitForChild("Lunge"),
	}
}

Damage = 12

Grips = {
	Equipped = CFrame.new(-0.25, 2.25, 0, 0, 0, -1, 0, -1, -0, -1, 0, -0),
	Playing = CFrame.new(0, 1.2, 0, 0, 0, -1, 0, -1, -0, -1, 0, -0),
}

NoteData = {
	Chords = {
		{Key = "Q", Sound = Sounds.Songs.Song1, Duration = 11.5},
		{Key = "E", Sound = Sounds.Songs.Song2, Duration = 9.5},
		{Key = "R", Sound = Sounds.Songs.Song3, Duration = 8.5},
	},
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

GuitarModule = require(191816425)
GuitarTable = GuitarModule.GetTable({Key = "Guitars"})
GuitarFunctions = GuitarTable.GetData({
	Tool = Tool,
	Communication = {Server = ServerControl, Client = ClientControl},
	KeyData = NoteData,
})

Tool.Grip = Grips.Equipped
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not ToolEquipped or not Character then
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
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	local character = Hit.Parent
	local humanoid = character:findFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 and humanoid ~= Humanoid then
		local RightArm = Character:FindFirstChild("Right Arm")
		if RightArm then
			local RightGrip = RightArm:FindFirstChild("RightGrip")
			if RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle) then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				local Sound = Sounds.MusicTable[math.random(1, #Sounds.MusicTable)]
				Sound:Play()
			end
		end
	end
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end    

	Tool.Enabled = false
	
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.AxeSlash)
	end)
	
	wait(1)
	
	Tool.Enabled = true
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
	Tool.Grip = Grips.Equipped
	Sounds.Attacks.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Sounds) do
		for ii, vv in pairs(v) do
			if vv and vv.Parent then
				vv:Stop()
			end
		end
	end
	Tool.Grip = Grips.Equipped
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
		if Down and Tool.Enabled and CheckIfAlive() then
			for i, v in pairs(NoteData.Chords) do
				if string.lower(v.Key) == string.lower(Key) then
					Tool.Enabled = false
					v.Sound:Play()
					Tool.Grip = Grips.Playing
					Spawn(function()
						InvokeClient("PlayAnimation", Animations.Playing)
					end)
					if ToolUnequipped then
						ToolUnequipped:disconnect()
					end
					local CurrentlyEquipped = true
					ToolUnequipped = Tool.Unequipped:connect(function()
						v.Sound:Stop()
						CurrentlyEquipped = false
					end)
					wait(v.Duration)
					if CurrentlyEquipped then
						Spawn(function()
							InvokeClient("StopAnimation", Animations.Playing)
						end)
						v.Sound:Stop()
						if ToolUnequipped then
							ToolUnequipped:disconnect()
						end
						Tool.Grip = Grips.Equipped
					end
					Tool.Enabled = true
					return
				end
			end
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Handle.Touched:connect(Blow)