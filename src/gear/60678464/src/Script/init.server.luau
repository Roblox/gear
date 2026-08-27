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

DanceScript = script:WaitForChild("DanceScript")

Animations = {
	Equipped = {Animation = AnimationsFolder:WaitForChild("Equipped"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Song1 = Handle:WaitForChild("Song1"),
	Song2 = Handle:WaitForChild("Song2"),
	Song3 = Handle:WaitForChild("Song3"),
	Song4 = Handle:WaitForChild("Song4"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

NoteData = {
	Chords = {
		{Key = "F", Sound = Sounds.Song4},
	},
}

BaseUrl = "http://www.roblox.com/asset/?id="
Gravity = 196.20

DanceEnabled = true
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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Player, Position, Radius)
	local NegativeRegion = (Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {((Player and Player.Character) or nil)}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = GetParts(Region, 500, IgnoreList)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

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
	
	SetUpGuitar()	
	
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equipped)
	end)
	
	local Songs = {Sounds.Song1, Sounds.Song2, Sounds.Song3}
	local Song = Songs[math.random(1, #Songs)]
	
	Song:Play()
	
	wait(12)
	
	if CurrentlyEquipped then
		DismountGuitar()
		Spawn(function()
			InvokeClient("StopAnimation", Animations.Equipped)
		end)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
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
		C1 = (CFrame.new(0, 0.2, -0.9) * CFrame.Angles(math.pi, 0, -(math.pi / 4))),
		Parent = FakeHandle,
	}
	FakeHandle.Parent = Tool
end

function DismountGuitar()
	Handle.Transparency = 0
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
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Sounds) do
		v:Stop()
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
	if Mode == "KeyPressed" and Value and Tool.Enabled then
		local Key = Value.Key
		local Down = Value.Down
		if Down then
			if Key == "Q" and DanceEnabled then

				local NoteTextures = {60667024, 60667032, 60667053, 60667087}

				Tool.Enabled = false
				DanceEnabled = false
				
				SetUpGuitar()
				
				if ToolUnequipped then
					ToolUnequipped:disconnect()
				end
				local CurrentlyEquipped = true
				ToolUnequipped = Tool.Unequipped:connect(function()
					CurrentlyEquipped = false
				end)
				
				Sounds.Song4:Play()

				for i = 1, 12 do
				
					local Note = BasePart:Clone()
					Note.Name = "Note"
					Note.Size = Vector3.new(1, 1, 1)
					Note.CanCollide = false
	
					local NoteMesh = Create("SpecialMesh"){
						MeshId = (BaseUrl .. "60666966"),
						TextureId = (BaseUrl.. NoteTextures[math.random(1, #NoteTextures)]),
						Parent = Note,
					}
	
					local BF = Create("BodyForce"){
						force = Vector3.new(0, (Note:GetMass() * Gravity), 0),
						Parent = Note,
					}
						
					local Pos = (CFrame.Angles(-(math.pi / 12), (i * (math.pi / 6)), 0) * Torso.CFrame.lookVector)
					local SpawnPos = (Torso.Position + (Pos * 5))
					
					Note.Velocity = (Pos * 4)
					Debris:AddItem(Note, 2)
					
					Note.Parent = game:GetService("Workspace")
					
					Note.CFrame = CFrame.new(SpawnPos, (SpawnPos + Pos)) 
				
				end

				local PlayersNearby = GetPlayersNearby(Player, Torso.Position, 10)
				for i, v in pairs(PlayersNearby) do
					local humanoid = v
					local character = v.Parent
					if character then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 then
							local DanceScriptCopy = character:FindFirstChild(DanceScript.Name)
							if not DanceScriptCopy then
								DanceScriptCopy = DanceScript:Clone()
								DanceScriptCopy.Disabled = false
								Debris:AddItem(DanceScriptCopy, 7.5)
								DanceScriptCopy.Parent = character
							end
						end
					end
				end
				
				wait(2)
				
				if CurrentlyEquipped then
					if ToolUnequipped then
						ToolUnequipped:disconnect()
					end
					DismountGuitar()
				end
				
				Tool.Enabled = true
				
				wait(10)				
				
				DanceEnabled = true
				
			end
		end
	end
end

DismountGuitar()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)