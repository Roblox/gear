--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

SpiderModel = InsertService:LoadAsset(285590061)
Spider = SpiderModel:GetChildren()[1]:Clone()
Debris:AddItem(SpiderModel, 1)

CobWebShot = script:WaitForChild("CobWebShot")

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


Remover = script:WaitForChild("Remover")

NPCModule = require(191816425)

BaseUrl = "rbxassetid://"

Sounds = {}

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

ReloadTime = 10
Duration = (60 * 0.75)

SpidersSpawned = false
SpidersReady = false

CurrentSpiders = {}

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

function CreateSpiderModel()
	local SpiderModel = Create("Model"){
		Name = ToolName,
	}
	local CobWebShotScript = CobWebShot:Clone()
	CobWebShotScript.Disabled = false
	CobWebShotScript.Parent = SpiderModel
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = SpiderModel,
		}
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = SpiderModel
	return SpiderModel
end

function SetUpSpider(Figure)
	NPCData.MakeNPC({NPC = Figure, AIControl = {Creator = Player, Mode = "Wander", MaxDistance = math.huge, Follow = nil, Offset = Vector3.new(0, 0, 0), Chase = true, ChaseDistance = 35, Target = nil, TargetPos = Vector3.new(0, 0, 0), Damage = 5, NormalSpeed = 12, ChaseSpeed = 17, SelfSufficient = false}})
	Figure.Name = "RobotSpider"
	local Humanoid = Figure:FindFirstChild("Humanoid")
	local Torso = Figure:FindFirstChild("Torso")
	if Humanoid and Torso then
		Humanoid.Died:connect(function()
			Debris:AddItem(Figure, 2)
		end)
		Humanoid.Jumping:connect(function()
		end)
		Figure.Changed:connect(function(Property)
			if Property == "Parent" and not Figure.Parent then
				Debris:AddItem(Figure, 2)
			end
		end)
	end
	return Figure
end

function SpawnSpiders()
	local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	if not Data then
		return
	end
	NPCData = Data.GetData({Player = Player, Tool = Tool})
	SpidersReady = false
	CurrentSpiders = {}
	local SpiderModel = CreateSpiderModel()
	NPCData.MakeNPC({NPC = SpiderModel, AIControl = {Creator = Player, SelfSufficient = true}})
	local BaseNPC = SetUpSpider(Spider:Clone())
	SpiderModel.Changed:connect(function(Property)
		if Property == "Parent" and not SpiderModel.Parent then
			for i, v in pairs(CurrentSpiders) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentSpiders = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			SpidersSpawned = false
		end
	end)	
	Debris:AddItem(SpiderModel, Duration)
	SpiderModel.Parent = game:GetService("Workspace")
	local function CreatePawn()
		local SpiderCopy = BaseNPC:Clone()
		local SpiderHumanoid = SpiderCopy.Humanoid
		local SpiderTorso = SpiderCopy.Torso
		table.insert(CurrentSpiders, SpiderCopy)
		SpiderCopy.Changed:connect(function(Property)
			if Property == "Parent" and not SpiderCopy.Parent then
				for i, v in pairs(CurrentSpiders) do
					if v == SpiderCopy then
						table.remove(CurrentSpiders, i)
						if #CurrentSpiders == 0 then
							if SpiderModel and SpiderModel.Parent then
								Debris:AddItem(SpiderModel, 1)
								SpiderModel:Destroy()
							end
						end
					end
				end
			end
		end)
		local RandomOffset = Vector3.new(5, 0, 5)
		RandomOffset = (RandomOffset * 1000)
		RandomOffset = Vector3.new((math.random(-RandomOffset.X, RandomOffset.X) * 0.001), (math.random(-RandomOffset.Y, RandomOffset.Y) * 0.001), (math.random(-RandomOffset.Z, RandomOffset.Z) * 0.001))
		local OffsetValue = SpiderCopy.Offset
		OffsetValue.Value = RandomOffset
		SpiderCopy.Parent = SpiderModel
		SpiderTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
		SpiderHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	for i = 1, 6 do
		CreatePawn()
	end
	SpidersReady = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if not SpidersSpawned then
		local SpiderModel = game:GetService("Workspace"):FindFirstChild(ToolName)
		if SpiderModel then
			return
		end
		Handle.Transparency = 1
		SpidersSpawned = true
		SpawnSpiders()
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolName = (Player.Name .. "'sRobotSpiders")
	ToolEquipped = true
end

function Unequipped()
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not SpidersSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)